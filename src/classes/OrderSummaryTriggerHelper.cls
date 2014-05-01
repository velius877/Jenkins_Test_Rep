/************************************* MODIFICATION LOG ********************************************************************************
*
* DESCRIPTION : OrderSummaryTriggerHelper.cls has methods that govern behaviour of inserted Order Summary records
*
*---------------------------------------------------------------------------------------------------------------------------------------
* DEVELOPER					 DATE				  REASON
*---------------------------------------------------------------------------------------------------------------------------------------
* Shivkant Vadlamani			03/25/2013		  - Origininal Version
*
*													
*/

public with sharing class OrderSummaryTriggerHelper 
{	
	// Map to hold the values from Custom Setting - Inbound Order Mapping. 
	// This custom setting has the information about Objects, Fields and thier Start Positions, End Positions in the Order Summary String
	public static Map<String,List<Inbound_Order_Mapping__c>> InboundOrderValuesMap = new Map<String,List<Inbound_Order_Mapping__c>>();
	
	// Map that matches Account record labels to their associated record type
	public static Map<String,Schema.RecordTypeInfo> AccountRTMapByName = Schema.SObjectType.Account.getRecordTypeInfosByName();
	
	 // WebStoreData custom setting has the mapping of WebStoreId and associated Currency Code, Website 
	private static Map<String, WebStoresData__c> WebStoresMap = WebStoresData__c.getALL();
	
	// Id of Person Account that will used to create Customer record 
	public static Id PersonAccountRTId;  
	public static Customer_Rec_Type_Brand_Mapping__c rtbm; 
	public static WebStoresData__c wsdata; 
		
	public static void ProcessOrderSummaryAfterInsert(List<Order_Summary__c> NewOrderSummaryRecords)
	{		
		Map<String, Account> NewCustomersMap = new Map<String, Account>();												
		Map<String, List<Address__c>> NewAddressesMap = new Map<String, List<Address__c>>();
		List<Orders__c> NewOrders = new List<Orders__c>();
		Map<String, List<Order_Line_Items__c>> NewOrderLineItemsMap = new Map<String, List<Order_Line_Items__c>>(); 
		Map<String, List<Allowance__c>> NewAllowancesMap = new Map<String, List<Allowance__c>>(); 
		System.debug('NewOrderSummaryRecords...........: '+ NewOrderSummaryRecords);  	
		if(InboundOrderValuesMap != null && InboundOrderValuesMap.isEmpty())
		{
			processInboundOrderValues();
		}		
		
		try
		{
			for(Order_Summary__c OSRec : NewOrderSummaryRecords)
			{	
				wsdata = WebStoresMap.get(OSRec.Webstack_ID__c);		
				PersonAccountRTId = AccountRTMapByName.get(WebStoresMap.get(OSRec.Webstack_ID__c).Record_Type_Name__c).getRecordTypeId();
				rtbm = 	NBTYUtils.getSuffixToBrandMappingMap().get(WebStoresMap.get(OSRec.Webstack_ID__c).Product_Suffix__c);
				if(InboundOrderValuesMap != null && OSRec.Webstack_Order_ID__c != null)
				{		
					// Create New Customer					
					Account AccRec = (Account)OrderSummaryTriggerUtilities.GenerateObjects(OSRec, InboundOrderValuesMap, 'Customer');
					system.debug(LoggingLevel.info, 'accRec~~~~'+AccRec);
					if(AccRec != null)
					{
						system.debug(LoggingLevel.info, AccRec);
						AccRec.RecordTypeId = PersonAccountRTId;
						NewCustomersMap.put(OSRec.Webstack_Order_ID__c.trim(), AccRec);
					}
					
					// Create New Addresses
					NewAddressesMap.put(OSRec.Webstack_Order_ID__c.trim(), OrderSummaryTriggerUtilities.GenerateAddresses(OSRec, InboundOrderValuesMap));
					
					// Create New Order
					Orders__c OrderRec = (Orders__c)OrderSummaryTriggerUtilities.GenerateObjects(OSRec, InboundOrderValuesMap, 'Order');
					OrderRec.Order_Status__c = 'Pending Submission';
					NewOrders.add(OrderRec);		
					
					// Create Order Line Items
					NewOrderLineItemsMap.putAll(OrderSummaryTriggerUtilities.GenerateOrderLineItems(OSRec, InboundOrderValuesMap));	  
					
					// Create Allowances
					NewAllowancesMap.putAll(OrderSummaryTriggerUtilities.GenerateAllowances(OSRec, InboundOrderValuesMap));  																 							  			
				}
			}
		}
		catch(NBTYException e)
		{
			throw new NBTYException(e.getMessage());
		}	 	
		
		// Check for Customer duplication before creating
		if(!NewCustomersMap.isEmpty())
		{			
			try
			{
				NewCustomersMap = OrderSummaryTriggerUtilities.DeDupeOnCustomers(NewCustomersMap);				
				upsert NewCustomersMap.values();				
			}	
			catch(NBTYException e)
			{
				throw new NBTYException(e.getMessage());
			}  		
		}		
		
		// Connect Customer to Address and Create Address										
		if(!NewAddressesMap.isEmpty() && !NewCustomersMap.isEmpty())
		{			
			try
			{
				NewAddressesMap = OrderSummaryTriggerUtilities.setCustomerOnAddress(NewAddressesMap, NewCustomersMap);
			
				List<Address__c> AddrToCreate = new List<Address__c>();
				
				for(String WSID : NewAddressesMap.keySet())
				{
					AddrToCreate.addAll(NewAddressesMap.get(WSID));
				}
				
				for(Address__c Addr : AddrToCreate)
				{
					Addr.Validated__c = true;
					
					if((Addr.country_picklist__c == '' || Addr.country_picklist__c == null) && Addr.Foreign_Country_Code__c != null && Addr.Foreign_Country_Code__c != '')
					{
						Addr.country_picklist__c = Country_code_mapping__c.getValues(Addr.Foreign_Country_Code__c).Name__c != null ? Country_code_mapping__c.getValues(Addr.Foreign_Country_Code__c).Name__c : Country_code_mapping__c.getValues(Addr.Foreign_Country_Code__c).Abbreviation__c;
					}
					
					if(Addr.country_picklist__c == '' || Addr.country_picklist__c == null)
					{
						Addr.country_picklist__c = 'UNITED STATES';
					}
					
					Addr.country__c = Country_code_mapping__c.getValues(Addr.country_picklist__c) != null ? Country_code_mapping__c.getValues(Addr.country_picklist__c).Abbreviation__c : '' ;
				}
				
				insert AddrToCreate;
			}  
			catch(NBTYException e)
			{
				throw new NBTYException(e.getMessage());
			}			
		}
		
		// Connect Order to Customer and Billing/Shipping Address to Order
		if(NewOrders.size() > 0 && !NewCustomersMap.isEmpty() && !NewAddressesMap.isEmpty())
		{
			try
			{
				system.debug(LoggingLevel.info, 'newOrders'+NewOrders);
				system.debug(LoggingLevel.info, 'NewAddressesMap'+NewAddressesMap);
				system.debug(LoggingLevel.info, 'NewCustomersMap'+NewCustomersMap);
				NewOrders = OrderSummaryTriggerUtilities.setCustomerAndAddressOnOrder(NewOrders, NewCustomersMap, NewAddressesMap);
			
				insert NewOrders;
				set <Id> orderIds = new SEt <Id>();
				for (Orders__c ord: newORders){
					orderIds.add(ord.id);
				}
				Map <Id, Orders__c>orderMap = new Map<Id,Orders__c>();
				for (Orders__c ord :[select id, order_Status__c from Orders__c where id in:orderIds]){
					orderMap.put(ord.id, ord);
				}
					for (Orders__c ord: newORders){
						ord.Order_Status__c=orderMap.get(ord.id).order_status__c;
					}
			}  
			catch(NBTYException e)
			{
				throw new NBTYException(e.getMessage());
			}	  		
		}
		
		// Connect Order line item to Order
		if(NewOrders.size() > 0  && !NewOrderLineItemsMap.isEmpty())
		{			
			try
			{
				NewOrderLineItemsMap = OrderSummaryTriggerUtilities.setOrderAndProductOnOrderLineItem(NewOrderLineItemsMap, NewOrders);
			
				List<Order_Line_Items__c> OLIToCreate = new List<Order_Line_Items__c>();
				
				for(String SeqNum : NewOrderLineItemsMap.keySet())
				{
					OLIToCreate.addAll(NewOrderLineItemsMap.get(SeqNum));
				}
				
				insert OLIToCreate;
			}  
			catch(NBTYException e)
			{
				throw new NBTYException(e.getMessage());
			}			
		}
		
		// Connect Allowances to Order
		if(NewOrders.size() > 0  && !NewAllowancesMap.isEmpty())
		{			
			try
			{
				NewAllowancesMap = OrderSummaryTriggerUtilities.setOrderOnAllowance(NewAllowancesMap, NewOrders);
			
				List<Allowance__c> AllowanceToCreate = new List<Allowance__c>();
				
				for(String SeqNum : NewAllowancesMap.keySet())
				{
					AllowanceToCreate.addAll(NewAllowancesMap.get(SeqNum));
				}
				
				insert AllowanceToCreate;
			}  
			catch(NBTYException e)
			{
				throw new NBTYException(e.getMessage());
			}			
		}
		
	}
	
	// Method to create a Map of Object and entry string field name as key and values are list of associated fields, start and end positions and data type information
	public static void processInboundOrderValues()
	{
		try
		{
			for(Inbound_Order_Mapping__c IOM : Inbound_Order_Mapping__c.getAll().values())
			{
				List<Inbound_Order_Mapping__c> tempIOMList = InboundOrderValuesMap.get(IOM.Object_Name__c + '+' + IOM.Record_Type__c);
				
				if(tempIOMList == null)
				{
					tempIOMList = new List<Inbound_Order_Mapping__c>();
				}
				
				tempIOMList.add(IOM);
				InboundOrderValuesMap.put(IOM.Object_Name__c + '+' + IOM.Record_Type__c, tempIOMList);			
			}	
		}
		catch(NBTYException e)
		{
			throw new NBTYException(e.getMessage());
		} 	
	}
}