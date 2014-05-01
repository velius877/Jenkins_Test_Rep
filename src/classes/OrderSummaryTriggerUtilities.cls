/************************************* MODIFICATION LOG ********************************************************************************
*
* DESCRIPTION : OrderSummaryTriggerUtilities.cls  has methods that perform common, often re-used functions in Order Summary Trigger
*
*---------------------------------------------------------------------------------------------------------------------------------------
* DEVELOPER					 DATE				  REASON
*---------------------------------------------------------------------------------------------------------------------------------------
* Shivkant Vadlamani			03/25/2013		  - Origininal Version
*													
*/

public with sharing class OrderSummaryTriggerUtilities 
{
	// Map that represents the relationship between all the field names (keys) and the field tokens (values) for Order Summary Object
	private static Map<String, Schema.SObjectField> OrdSumFieldsMap = Order_Summary__c.sObjectType.getDescribe().fields.getMap();
	
	// WebStoreData custom setting has the mapping of WebStoreId and associated Currency Code, Website 
	private static Map<String, WebStoresData__c> WebStoresMap = WebStoresData__c.getALL();
	public static 	WebStoresData__c wsData;

	
	// Method to generate Customer and Order from Order Summary fields
	public static sObject GenerateObjects(Order_Summary__c OSRec, Map<String,List<Inbound_Order_Mapping__c>> InboundOrderValuesMap, String ObjType) {
		try {
			sObject NewObj;
			wsData = WebStoresMap.get(OSRec.Webstack_ID__c);
			if (ObjType == 'Customer') {
				NewObj = new Account();
			} else if(ObjType == 'Order') {
				NewObj = new Orders__c();
				NewObj.put('Order_Total__c', 0);
			}
			
			setCurrency(OSRec, NewObj);
			
			for (Schema.SObjectField OrdSumField : OrdSumFieldsMap.values()) {
				if (OrdSumField != null) {
					String OrdSumFieldAsString = String.valueOf(OrdSumField);
					String CurrFieldInProcessVal = String.valueOf(OSRec.get(OrdSumFieldAsString));
					
					if (OrdSumFieldAsString.endsWith('__c') && CurrFieldInProcessVal != null && CurrFieldInProcessVal != '' && InboundOrderValuesMap.get(ObjType + '+' + OrdSumFieldAsString.removeEnd('__c')) != null) {
						NewObj = setFieldValueMapping(InboundOrderValuesMap, ObjType, OrdSumFieldAsString, CurrFieldInProcessVal, NewObj);  
					}
				}
			}
			
			if (ObjType == 'Order') {
				processComments(OSRec, InboundOrderValuesMap, NewObj);
			}
			return NewObj;
		} catch(NBTYException e) {
			throw new NBTYException(e.getMessage());
		} 
	}
	
	// Method to generate Addresses from Order Summary - Header and Ship to String	
	public static List<Address__c> GenerateAddresses(Order_Summary__c OSRec, Map<String,List<Inbound_Order_Mapping__c>> InboundOrderValuesMap) {
		try {
			List<Address__c> NewAddresses = new List<Address__c>();
			for (Schema.SObjectField OrdSumField : OrdSumFieldsMap.values()) {
				Address__c AddrRec;
				
				if (OrdSumField != null) {
					String OrdSumFieldAsString = String.valueOf(OrdSumField);
					String CurrFieldInProcessVal = String.valueOf(OSRec.get(OrdSumFieldAsString));
					
					if ((OrdSumFieldAsString.equals('Ship_To__c') || OrdSumFieldAsString.equals('Header__c')) && CurrFieldInProcessVal != null && CurrFieldInProcessVal != '' && InboundOrderValuesMap.get('Address+' + OrdSumFieldAsString.removeEnd('__c')) != null) {
						AddrRec = new Address__c();
						if (OrdSumFieldAsString.equals('Ship_To__c')) {
							AddrRec.Address_Type__c = 'Shipping';
						} else {
							AddrRec.Address_Type__c = 'Billing';
						}
						AddrRec = (Address__c)setFieldValueMapping(InboundOrderValuesMap, 'Address', OrdSumFieldAsString, CurrFieldInProcessVal, AddrRec);  
					}
				}
				
				if (AddrRec != null) {
					NewAddresses.add(AddrRec);
				}
			}
			return NewAddresses;
		} catch(NBTYException e) {
			throw new NBTYException(e.getMessage());
		}
	}
	
	// Method to generate Order Line Items from Order Summary - Detail String
	public static Map<String, List<Order_Line_Items__c>> GenerateOrderLineItems(Order_Summary__c OSRec, Map<String,List<Inbound_Order_Mapping__c>> InboundOrderValuesMap) {
		try {
			Map<String, List<Order_Line_Items__c>> NewOrderLineItemsMap = new Map<String, List<Order_Line_Items__c>>();
			String OrdSumFieldAsString = String.valueOf(OrdSumFieldsMap.get('Detail__c'));
			if (OrdSumFieldAsString != null && OrdSumFieldAsString != '' && String.valueOf(OSRec.get(OrdSumFieldAsString)) != null && String.valueOf(OSRec.get(OrdSumFieldAsString)) != '' ){
				for(String CurrFieldInProcessVal : String.valueOf(OSRec.get(OrdSumFieldAsString)).split('[|#|]',0)) {
					if(CurrFieldInProcessVal != null && CurrFieldInProcessVal != '' && InboundOrderValuesMap.get('Line Item+' + OrdSumFieldAsString.removeEnd('__c')) != null) {
						Order_Line_Items__c OrdLineItemRec = new Order_Line_Items__c();
						setCurrency(OSRec, OrdLineItemRec);
						OrdLineItemRec = (Order_Line_Items__c)setFieldValueMapping(InboundOrderValuesMap, 'Line Item', OrdSumFieldAsString, CurrFieldInProcessVal, OrdLineItemRec);
						List<Order_Line_Items__c> OrdLineItemList = NewOrderLineItemsMap.get(OrdLineItemRec.Sequence_Number__c);
						if (OrdLineItemList == null) {
							OrdLineItemList = new List<Order_Line_Items__c>();
						}
						OrdLineItemList.add(OrdLineItemRec);
						NewOrderLineItemsMap.put(OrdLineItemRec.Sequence_Number__c, OrdLineItemList);				
					}
				}
			}
			return NewOrderLineItemsMap;
		} catch(NBTYException e) {
			throw new NBTYException(e.getMessage());
		}
	}
	
	// Method to generate Allowances from Order Summary - Allowances String
	public static Map<String, List<Allowance__c>> GenerateAllowances(Order_Summary__c OSRec, Map<String,List<Inbound_Order_Mapping__c>> InboundOrderValuesMap) {
		try {
			Map<String, List<Allowance__c>> NewAllowancesMap = new Map<String, List<Allowance__c>>();
			String OrdSumFieldAsString = String.valueOf(OrdSumFieldsMap.get('Allowance_Charge__c'));
			if (OrdSumFieldAsString != null && OrdSumFieldAsString != '' && String.valueOf(OSRec.get(OrdSumFieldAsString)) != null && String.valueOf(OSRec.get(OrdSumFieldAsString)) != '' ) {
				for (String CurrFieldInProcessVal : String.valueOf(OSRec.get(OrdSumFieldAsString)).split('[|#|]',0)) {
					if (CurrFieldInProcessVal != null && CurrFieldInProcessVal != '' && InboundOrderValuesMap.get('Allowance+' + OrdSumFieldAsString.removeEnd('__c')) != null) {
						Allowance__c AllowanceRec = new Allowance__c();
						
						setCurrency(OSRec, AllowanceRec);
						AllowanceRec = (Allowance__c)setFieldValueMapping(InboundOrderValuesMap, 'Allowance', OrdSumFieldAsString, CurrFieldInProcessVal, AllowanceRec);			 	
						
						List<Allowance__c> AllowanceList = NewAllowancesMap.get(AllowanceRec.Sequence_Number__c);
						
						if (AllowanceList == null) {
							AllowanceList = new List<Allowance__c>();
						}
						AllowanceList.add(AllowanceRec);
						NewAllowancesMap.put(AllowanceRec.Sequence_Number__c, AllowanceList);				
					}
				}
			}
			return NewAllowancesMap;
		} catch(NBTYException e) {
			throw new NBTYException(e.getMessage());
		}
	}
	
	
	// Handling multiple comments
	public static void  processComments(Order_Summary__c OSRec, Map<String,List<Inbound_Order_Mapping__c>> InboundOrderValuesMap, sObject NewObj) {
		try {
			String OrdSumFieldAsString = String.valueOf(OrdSumFieldsMap.get('comment__c'));
			NewObj.put('Comments__c', null);
			
			if (OrdSumFieldAsString != null && OrdSumFieldAsString != '' && String.valueOf(OSRec.get(OrdSumFieldAsString)) != null && String.valueOf(OSRec.get(OrdSumFieldAsString)) != '' ) {
				for (String CurrFieldInProcessVal : String.valueOf(OSRec.get(OrdSumFieldAsString)).split('[|#|]',0)) {
					if (CurrFieldInProcessVal != null && CurrFieldInProcessVal != '' && InboundOrderValuesMap.get('Order+' + OrdSumFieldAsString.removeEnd('__c')) != null) {
						setFieldValueMapping(InboundOrderValuesMap, 'Order', OrdSumFieldAsString, CurrFieldInProcessVal, NewObj);						
					}
				}
			}
		} catch(NBTYException e) {
			throw new NBTYException(e.getMessage());
		}
	}
	
	// Method to avoid duplicate Customer records creation
	public static Map<String, Account> DeDupeOnCustomers(Map<String, Account> NewCustomersMap) {
		try {
			Set<String> FirstNamesSet = new Set<String>();
			Set<String> LastNamesSet = new Set<String>();
			Map<String, Account> CustomersEmailInDB = new Map<String, Account>();
			Map<String, Account> CustomersPhoneInDB = new Map<String, Account>();
			// DE855 -- adding AS/400 matching
			Map<String, Account> CustomersAS400MatchInDB = new Map<String, Account>();
			
			// DE882 -- filter by recordtypeid
			String CustomerRecordTypeId;
			for (Account Customer : NewCustomersMap.values()) {
				CustomerRecordTypeId = Customer.RecordTypeId;
				if (Customer.FirstName != '') {
					FirstNamesSet.add(Customer.FirstName);
				}
				
				if (Customer.LastName != '') {
					LastNamesSet.add(Customer.LastName);
				}
			}
			
			for (Account Customer : [SELECT Id, FirstName, BillingPostalCode, BillingStreet, LastName, RecordTypeId, VW_Passport_Number__c, PersonBirthdate, Phone, PersonEmail, International_Fax__c, International_Phone__c
											FROM Account 
											WHERE (FirstName IN :FirstNamesSet AND LastName IN :LastNamesSet AND Potential_Duplicate__c = false AND RecordTypeId =: CustomerRecordTypeId)])
			{
				String fn = Customer.FirstName == null ? '' : Customer.FirstName.toUpperCase();
				String ln = Customer.LastName == null ? '' : Customer.LastName.toUpperCase();
				String pe = Customer.PersonEmail == null ? '' : Customer.PersonEmail.toUpperCase();
				CustomersEmailInDB.put(fn + '+' + ln + '+' + pe + '+' + Customer.RecordTypeId, Customer );
				
				String FormattedPhone = Customer.Phone != null ? WS_soa_SendOrderService_v2_Utils.replacePhoneChars(Customer.Phone): null;
				
				// DE855 -- Customer Matching Change ignore the customers whom has a phone number that is all zeros.
				if (FormattedPhone != '0000000000'){
					CustomersPhoneInDB.put(fn + '+' + ln + '+' + FormattedPhone + '+' + Customer.RecordTypeId, Customer );
				}
				
				// DE855 -- AS/400 matching
				CustomersAS400MatchInDB.put(matchCodeDefinition(Customer), Customer);
			}
			
			if (!CustomersAS400MatchInDB.isEmpty() || !CustomersEmailInDB.isEmpty() || !CustomersPhoneInDB.isEmpty()) {
				for (String Key : NewCustomersMap.keySet()) {
					Account NewCustomer = NewCustomersMap.get(Key);
					Account ExistingCust;
					
					// DE855 -- AS/400 matching
					if (!CustomersAS400MatchInDB.isEmpty()) {
						ExistingCust = CustomersAS400MatchInDB.get(matchCodeDefinition(NewCustomer));
					}
					
					if (!CustomersEmailInDB.isEmpty() && ExistingCust == null) {
						// DE889 -- set to uppercase for more reliable matching.
						ExistingCust = CustomersEmailInDB.get(NewCustomer.FirstName == null ? NewCustomer.FirstName : NewCustomer.FirstName.ToUpperCase() +
														'+' + NewCustomer.LastName == null ? NewCustomer.FirstName : NewCustomer.FirstName.ToUpperCase() +
														'+' + NewCustomer.PersonEmail == null ? NewCustomer.FirstName : NewCustomer.FirstName.ToUpperCase() +
														'+' + NewCustomer.RecordTypeId);
					}
					if (!CustomersPhoneInDB.isEmpty() && ExistingCust == null) {
						ExistingCust = CustomersPhoneInDB.get(NewCustomer.FirstName + '+' + NewCustomer.LastName + '+' + NewCustomer.Phone + '+' + NewCustomer.RecordTypeId);
					}
					
					if (ExistingCust != null) {
						if (NewCustomer.VW_Passport_Number__c != null && ExistingCust.VW_Passport_Number__c == null) ExistingCust.VW_Passport_Number__c = NewCustomer.VW_Passport_Number__c;
						if (NewCustomer.PersonBirthdate != null && ExistingCust.PersonBirthdate == null) ExistingCust.PersonBirthdate = NewCustomer.PersonBirthdate;
						if (NewCustomer.International_Fax__c != null && ExistingCust.International_Fax__c == null) ExistingCust.International_Fax__c = NewCustomer.International_Fax__c;
						if (NewCustomer.International_Phone__c != null && ExistingCust.International_Phone__c == null) ExistingCust.International_Phone__c = NewCustomer.International_Phone__c;
						if (NewCustomer.PersonEmail != null && ExistingCust.PersonEmail == null) ExistingCust.PersonEmail = NewCustomer.PersonEmail;
						if (NewCustomer.Phone != null && ExistingCust.Phone == null) ExistingCust.Phone = NewCustomer.Phone;
						NewCustomersMap.put(Key, ExistingCust);
					}
				}
			}
			return NewCustomersMap;
		} catch(NBTYException e) {
			throw new NBTYException(e.getMessage());
		}
	}
	
	// DE855 -- Method to generate string based on AS/400 matching definition
	public static String matchCodeDefinition(Account acct) {
		String matchCode = '';
		String temp = null;
		
		// all 5 digits of the zip code
		matchCode = acct.BillingPostalCode;
		
		// 1st, 3rd, 4th character of the last name.
		if (acct.LastName != null && acct.LastName.Length() >= 4) {
			temp = acct.LastName.subString(0, 1) + acct.LastName.subString(2, 3) + acct.LastName.subString(3, 4);
		} else {
			if (acct.LastName.Length() == 3) {
				temp = acct.LastName.SubString(0, 1) + acct.LastName.subString(2, 3) + '*';
			} else if (acct.LastName.Length() <= 2) {
				temp = acct.LastName.subString(0, 2) + '**';
			} else {
				temp = '***';
			}
		}
		
		if (temp != null) {
			matchCode += temp;
			temp = null;
		}
		
		// First 3 characters of the premise number (house number)
		if (acct.BillingStreet != null) {
			List<String> parts = acct.BillingStreet.split(' ');
			List<String> goodParts = new List<String>();
			
			for (String s : parts) {
				try {
					integer i = integer.ValueOf(s);
					goodParts.add(s);
				} catch (exception e) {
					continue;
				}
			}
			
			// Take 1st one; if there's more than one there could apt # and such
			integer diff = 0;
			if (!goodParts.isEmpty()) {
				diff = 3 - goodParts.get(0).length();
			}
			if (diff < 0) {
				temp = goodParts.get(0).subString(0, 3);
			} else {
				temp = !goodParts.isEmpty() ? goodParts.get(0) : '';
				for (integer i = 0; i < diff; i++) {
					temp += '*';
				}
			}
			
			if (temp != null) {
				matchCode += temp;
				temp = null;
			}
		}
		
		// First letter of First name.
		matchCode += acct.FirstName.subString(0, 1);
		
		// any characters from before that could have not had enough characters
		// they are replaced with an * so the total length is 12 characters.
		// Only caveat is the country code is used as postal code for foriegn addresses
		return matchCode.toUpperCase();
	}
	
	// Method to associate Customer to Address	
	public static Map<String, List<Address__c>> setCustomerOnAddress(Map<String, List<Address__c>> NewAddressesMap, Map<String, Account> NewCustomersMap)
	{
		try
		{
			for(String WSID : NewAddressesMap.keySet())
			{
				for(Address__c Addr : NewAddressesMap.get(WSID))
				{
					Addr.Customer__c = NewCustomersMap.get(WSID).Id;
				}			
			}
			
			return NewAddressesMap;
		}
		catch(NBTYException e)
		{
			throw new NBTYException(e.getMessage());
		} 
	}
	
	// Method to associate Customer and Address to Order
	public static List<Orders__c> setCustomerAndAddressOnOrder(List<Orders__c> NewOrders, Map<String, Account> NewCustomersMap, Map<String, List<Address__c>> NewAddressesMap)
	{		
		try
		{
			Set<String> AddressesToCheckInDB = new Set<String>();
			
			for(List<Address__c> tempListOfAddrs : NewAddressesMap.values())
			{
				for(Address__c addr : tempListOfAddrs)
				{				
					AddressTriggerHelper.setStandardizedAddress(addr);
					AddressesToCheckInDB.add(addr.Standardized_Address__c);
					system.debug(LoggingLevel.info, 'standarardAddr~~~'+addr.Standardized_Address__c);
				}
			}
					
			Map<String, Address__c> AddrExistingInDB = new Map<String, Address__c>();
			
			for(Address__c Addr : [SELECT Id, Address_Type__c, Standardized_Address__c FROM Address__c WHERE Standardized_Address__c IN :AddressesToCheckInDB])
			{
				AddrExistingInDB.put(Addr.Standardized_Address__c, Addr);
			}
			
			Map<String, List<Address__c>> TempAddressesMap = new Map<String, List<Address__c>>();
			
			for(String WSID : NewAddressesMap.keySet())
			{
				for(Address__c Addr : NewAddressesMap.get(WSID))
				{
					AddressTriggerHelper.setStandardizedAddress(Addr);
					if(AddrExistingInDB.containsKey(Addr.Standardized_Address__c))
					{
						List<Address__c> tempAddrList = TempAddressesMap.get(WSID);
						
						if(tempAddrList == null)
						{
							tempAddrList = new List<Address__c>();
						}
						
						tempAddrList.add(AddrExistingInDB.get(Addr.Standardized_Address__c));
						
						TempAddressesMap.put(WSID, tempAddrList);
					}
				}
			}
			system.debug(LoggingLevel.info, TempAddressesMap);
			NewAddressesMap.clear();
			NewAddressesMap.putAll(TempAddressesMap);
					
			for(Orders__c OrdRec : NewOrders)
			{
				OrdRec.Customer__c = NewCustomersMap.get(OrdRec.Webstack_Order_ID__c).Id;
				
				system.debug(LoggingLevel.info,'OrdRec.Webstack_Order_ID__c~~'+OrdRec.Webstack_Order_ID__c );
				system.debug(LoggingLevel.info,'NewAddressesMap~~'+NewAddressesMap.get(OrdRec.Webstack_Order_ID__c));
				for(Address__c Addr : NewAddressesMap.get(OrdRec.Webstack_Order_ID__c))
				{
					if(Addr.Address_Type__c.containsIgnoreCase('Billing') && Addr.Address_Type__c.containsIgnoreCase('Shipping'))
					{
						OrdRec.Bill_To_Address__c = Addr.Id;
						OrdRec.Ship_To_Address__c = Addr.Id;
					}
					else if(Addr.Address_Type__c.containsIgnoreCase('Billing'))
					{
						OrdRec.Bill_To_Address__c = Addr.Id;
					}
					else if(Addr.Address_Type__c.containsIgnoreCase('Shipping'))
					{
						OrdRec.Ship_To_Address__c = Addr.Id;
					}
				}
				// DE615 -- associate address to order when deduping causes them to vanish.
				if ((NewAddressesMap.get(OrdRec.WebStack_Order_ID__c) == null)){
					if (OrdRec.Bill_To_Address__c == null || OrdRec.Ship_To_Address__c == null){
						if (OrdRec.Sales_Channel__c == 'Brand Website'){
							// has more than just one address. 
							// Check if they're dupes with different case?
							// Attemp to find match from Order_Summary__c with Webstack_Order_Id__c
							Order_Summary__c summary = [SELECT Id, Header__c, Ship_To__c, Webstack_Order_Id__c from Order_Summary__c where Webstack_Order_Id__c = :OrdRec.Webstack_Order_ID__c];
							List <Address__c> customerAddresses = [SELECT Customer__c, Primary_Bill_To_Address__c, Primary_Ship_To_Address__c, Id, Country__c,
																	Zip_Code_4__c, Address_Line_1__c, Address_Line_2__c, Address_Line_3__c, Residential_Commercial__c,
																	Address_Line_4__c, Zip_Code__c, City__c, State_Providence__c, Foreign_Postal_Code__c, Country_Picklist__c,
																	Foreign_Country_Code__c  
																	from Address__c Where Customer__c = :OrdRec.Customer__c];
								
							string summaryHeader;
							string summaryShipTo;
							if (summary != null){
								summaryHeader = summary.Header__c;
								summaryShipTo = summary.Ship_To__c;
							}
							
							if (summaryHeader != null && summaryShipTo != null){
								for (Address__c a : customerAddresses){
									// DE615 adjustment; booleans for tracking if each item was matched.
									Boolean billAddr1 = false;
									Boolean billAddr2 = false;
									Boolean billState = false;
									Boolean billCity = false;
									Boolean shipAddr1 = false;
									Boolean shipAddr2 = false;
									Boolean shipCity = false;
									Boolean shipState = false;
									if (a.Address_Line_1__c != null){
										billAddr1 = summaryHeader.containsIgnoreCase(a.Address_Line_1__c);
									}
									if (a.Address_Line_2__c != null){
										billAddr2 = summaryHeader.containsIgnoreCase(a.Address_Line_2__c);
									} else {
										billAddr2 = true; // set to true when Address Line 2 was null
									}
									if (a.City__c != null){
										billCity = summaryHeader.containsIgnoreCase(a.City__c);
									} else {
										billCity = true; // set to true when city wasn't supplied (foriegn)
									}
									if (a.State_Providence__c != null){
										billState = summaryHeader.containsIgnoreCase(a.State_Providence__c);
									} else {
										billState = true; // set to true when state was not supplied, usually FO if foriegn
									}
									
									if (a.Address_Line_1__c != null){
										shipAddr1 = summaryHeader.containsIgnoreCase(a.Address_Line_1__c);
									}
									if (a.Address_Line_2__c != null){
										shipAddr2 = summaryHeader.containsIgnoreCase(a.Address_Line_2__c);
									} else {
										shipAddr2 = true; // set to true when Address Line 2 was null
									}
									if (a.City__c != null){
										shipCity = summaryHeader.containsIgnoreCase(a.City__c);
									} else {
										shipCity = true; // set to true when city wasn't supplied (foriegn)
									}
									if (a.State_Providence__c != null){
										shipState = summaryHeader.containsIgnoreCase(a.State_Providence__c);
									} else {
										shipState = true; // set to true when state was not supplied, usually FO if foriegn
									}
									
									if (billAddr1 && billAddr2 && billCity && billState){
										// save first match or update if state was null
										if (OrdRec.Bill_To_Address__c != null || a.State_Providence__c == null){
											OrdRec.Bill_To_Address__c = a.id;
										}
									}
									if (shipAddr1 && shipAddr2 && shipCity && shipState){
										// save first match or update if state was null
										if (OrdRec.Ship_To_Address__c != null || a.State_Providence__c == null){
											OrdRec.Ship_To_Address__c = a.id;
										}	
									}
								}
							}
						}
					}
				}else{ // if the address map was not empty, then we're able to attach normally.
					for(Address__c Addr : NewAddressesMap.get(OrdRec.Webstack_Order_ID__c))
					{
						if(Addr.Address_Type__c.containsIgnoreCase('Billing') && Addr.Address_Type__c.containsIgnoreCase('Shipping'))
						{
							OrdRec.Bill_To_Address__c = Addr.Id;
							OrdRec.Ship_To_Address__c = Addr.Id;
						}
						else if(Addr.Address_Type__c.containsIgnoreCase('Billing'))
						{
							OrdRec.Bill_To_Address__c = Addr.Id;
						}
						else if(Addr.Address_Type__c.containsIgnoreCase('Shipping'))
						{
							OrdRec.Ship_To_Address__c = Addr.Id;
						}
					}
				}
				OrdRec.Shipping_Method__c = returnShippingMethod_reverse(OrdRec);
			}
			
			return NewOrders;
			
		}
		catch(NBTYException e)
		{
			throw new NBTYException(e.getMessage());
		} 
	}
	
	// Set Shipping Method
	
	public static string returnShippingMethod_reverse(Orders__c orderObj) {
		try {
			Map<String, String> shipMethMap = new Map<String,String>();
			shipMethMap.put('S','TwoDay');
			shipMethMap.put('I','International');
			shipMethMap.put('N','NextDay');
			shipMethMap.put('P','USPS');
			shipMethMap.put('A', 'Air');
			shipMethMap.put('R','R');
			string wsShipmentMethod = orderObj.Shipping_Method__c;
			String transformShipMethod = shipMethMap.get(wsShipmentMethod);
			if (transformShipMethod != null) {
				return transformShipMethod;
			} else {
				return 'UPS';
			}
			/*if (wsShipmentMethod=='S') return 'TwoDay'; ///ups 2nd day
			else if (wsShipmentMethod=='I') return ''; //‘I’ -  UPS (International )
			else if (wsShipmentMethod=='N') return 'NextDay';//‘N’ – UPS (Next Day)
			else if (wsShipmentMethod=='P') return 'USPS';//‘P’ -Puritan’s Pride – Parcel Post
			//else if (wsShipmentMethod=='U') return 'UPS'; //‘U’- UPS (Residential or Commercial must be entered)
			else return 'UPS'; //‘U’- UPS (Residential or Commercial must be entered)*/
		} catch(NBTYException e) {
			throw new NBTYException(e.getMessage());
		}
	}
	
	/*	public static string returnShippingMethod_reverse(Orders__c orderObj)
	{
		string wsShipmentMethod=orderObj.Shipping_Method__c;
		Order_Picklist_Map__c osm = Order_Picklist_Map__c.getValues(wsShipmentMethod);
		if (osm!=null) return osm.value__c;
		else return ' ';
	}*/
	
	// Method to set Product from SKU number and Order on Order Line Item
	public static Map<String, List<Order_Line_Items__c>> setOrderAndProductOnOrderLineItem(Map<String, List<Order_Line_Items__c>> NewOrderLineItemsMap, List<Orders__c> NewOrders)
	{
		try
		{
			Set<String> SKUNumbers = new Set<String>();
			Map<String, Item__c> ProductsMap = new Map<String, Item__c>();
			Map <Id, Boolean> CuatomerAssociateMap = new Map<Id, Boolean>();
			Set <Id> customerIds = new Set <Id>();
			Set <Id> orderIds = new Set <Id>(); //needed to ensure we don't add same order to the list
			List<Orders__c> OrdersToUpdate = new List<Orders__c>();
			
			for(Orders__c ordr : NewOrders)
			{
				customerIds.add(ordr.customer__c);
				for(Order_Line_Items__c OLIRec : NewOrderLineItemsMap.get(ordr.Sequence_Number__c))
				{
					OLIRec.Order__c = ordr.Id;
					if(OLIRec.SKU_Number__c != '')
					{
						SKUNumbers.add(OLIRec.SKU_Number__c);
					}
				}
			}
			
			if (!customerIds.isEmpty()){
				for (Account a: [select id, Associate_Customer__c, recordType.developerName from Account where id in :customerIds]){
					CuatomerAssociateMap.put( a.Id, a.Associate_Customer__c);
				}
			}
			
			if(!SKUNumbers.isEmpty())
			{
				for(Item__c item : [SELECT Id, Product_Number__c, Product_Suffix__c, Sale_Offer__c FROM Item__c WHERE Product_Number__c IN : SKUNumbers])
				{
					string prodKey = item.product_suffix__c+'-'+item.product_number__c;
					ProductsMap.put(prodKey, item);
				}
			}
			
			if(!ProductsMap.isEmpty())
			{
				for(Orders__c ordr : NewOrders)
				{
					string Suffix = wsData.product_suffix__c;
					
					for(Order_Line_Items__c OLIRec : NewOrderLineItemsMap.get(ordr.Sequence_Number__c))
					{
						
						if((OLIRec.Final_Price__c != null &&  OLIRec.Final_Price__c > 0) || (OLIRec.Item_Buy__c != null && OLIRec.Item_Buy__c > 0) || (OLIRec.Item_Receive__c != null && OLIRec.Item_Receive__c > 0))
						{
							if (!orderIds.contains(ordr.id)){
								ordr.Amazon_Model__c = true;
								orderIds.add(ordr.id);
								OrdersToUpdate.add(ordr);
							}
							
							if(OLIRec.Item_Buy__c != null && OLIRec.Item_Buy__c > 0 && OLIRec.Item_Receive__c != null && OLIRec.Item_Receive__c > 0)
							{
								OLIRec.Product_Quantity__c = OLIRec.Original_Quantity__c *OLIRec.Item_Receive__c / OLIRec.Item_Buy__c;
							}
							else
							{
								OLIRec.Product_Quantity__c = OLIRec.Original_Quantity__c ;
							}
						}
						else
						{
							OLIRec.Product_Quantity__c = OLIRec.Original_Quantity__c ;
						}
						
						if(ProductsMap.containsKey(Suffix+'-'+OLIRec.SKU_Number__c))
						{
							Item__c item = ProductsMap.get(Suffix+'-'+OLIRec.SKU_Number__c);
							OLIRec.Product_Name__c = item.Id;
							if(!ordr.Amazon_Model__c && wsData.Apply_Sale_Offer__c && CuatomerAssociateMap.containsKey(ordr.customer__c) && item.Sale_Offer__c != null && Sale_Offer_Settings__c.getAll().containsKey(item.Sale_Offer__c))
							{
								ApplySaleOffer(OLIRec, item);
							}						
						}
						else
						{
							throw new NBTYException('There are no matching Items');
						}				
					}
				}
			}
			else
			{
				throw new NBTYException('There are no matching Items');
			}
			
			if(OrdersToUpdate.size() > 0)
			{
				update OrdersToUpdate;
			}
			
			return NewOrderLineItemsMap;
		}
		catch(NBTYException e)
		{
			throw new NBTYException(e.getMessage());
		}
	}
	
	public static void ApplySaleOffer(Order_Line_Items__c OLIRec, Item__c item)
	{
		try
		{
			Integer FreeQuantity = 0;
		
			if(Sale_Offer_Settings__c.getAll().containsKey(item.Sale_Offer__c))	
			{
				if(item.Sale_Offer__c == '5 for 2')
				{	
					Integer remainder = math.mod(Integer.valueOf(OLIRec.Original_Quantity__c), 2);
					Integer Multiplier = Integer.valueOf(OLIRec.Original_Quantity__c / 2);
					
					Sale_Offer_Settings__c SOSRec1 = Sale_Offer_Settings__c.getInstance(item.Sale_Offer__c);	
					OLIRec.Original_Quantity__c = Integer.valueOf(OLIRec.Original_Quantity__c) - remainder;
					FreeQuantity = Multiplier * Integer.valueOf(SOSRec1.Free_Quantity__c) ;
													
					if(remainder != 0)
					{						
						Sale_Offer_Settings__c SOSRec2 = Sale_Offer_Settings__c.getInstance('2 for 1');
						FreeQuantity += Integer.valueOf(SOSRec2.Free_Quantity__c) ;
						OLIRec.Original_Quantity__c += remainder;
					}								
				}			
				else
				{
					Sale_Offer_Settings__c SOSRec = Sale_Offer_Settings__c.getInstance(item.Sale_Offer__c);
					FreeQuantity = Integer.valueOf(OLIRec.Original_Quantity__c) * Integer.valueOf(SOSRec.Free_Quantity__c) ;
					system.debug('free quantity~~~~'+FreeQuantity);
				}
			}		
			OLIRec.Product_Quantity__c = OLIRec.Original_Quantity__c  + Decimal.valueOf(FreeQuantity);
		}
		catch(NBTYException e)
		{
			throw new NBTYException(e.getMessage());
		}
	}
	
	 // Method to set Order on Allowance
	public static Map<String, List<Allowance__c>> setOrderOnAllowance(Map<String, List<Allowance__c>> NewAllowancesMap, List<Orders__c> NewOrders)
	{
		try
		{
			NewOrders = [SELECT Id, Order_Total__c, Sequence_Number__c, Customer__r.RecordType.DeveloperName FROM Orders__c WHERE Id IN :NewOrders];		
			for(Orders__c ordr : NewOrders)
			{
				for(Allowance__c AllowanceRec : NewAllowancesMap.get(ordr.Sequence_Number__c))
				{
					AllowanceRec.Order__c = ordr.Id;  
					AllowanceRec.Allowance_Amount__c = AllowanceRec.Allowance_Amount__c == NULL?0:AllowanceRec.Allowance_Amount__c;
					ordr.Order_Total__c -= AllowanceRec.Allowance_Amount__c; 			
				}
			}
			
			update NewOrders;
													
			return NewAllowancesMap;
		}	
		catch(NBTYException e)
		{
			throw new NBTYException(e.getMessage());
		}
	}
	
	// Method to set Field and Value on Objects
	public static sObject setFieldValueMapping(Map<String,List<Inbound_Order_Mapping__c>> InboundOrderValuesMap, String ObjType, String OrdSumFieldAsString, String CurrFieldInProcessVal, sObject NewObj)	
	{  
		try
		{  	
			for(Inbound_Order_Mapping__c IOM : InboundOrderValuesMap.get(ObjType + '+' + OrdSumFieldAsString.removeEnd('__c')))
			{	
				String Val = '';
				
				if(CurrFieldInProcessVal.length() >= IOM.Start_Position__c)
				{
					if(CurrFieldInProcessVal.length() >= IOM.End_Position__c)
					{
						 Val = CurrFieldInProcessVal.substring(Integer.valueOf(IOM.Start_Position__c - 1), Integer.valueOf(IOM.End_Position__c)).trim();
					}
					else
					{
						Val = CurrFieldInProcessVal.substring(Integer.valueOf(IOM.Start_Position__c - 1), Integer.valueOf(CurrFieldInProcessVal.length())).trim();
					}				
					
					if(IOM.Data_Type__c == 'Text' || IOM.Data_Type__c == 'Phone')
					{
						String PrevComments = '';
						
						if(OrdSumFieldAsString == 'Comment__c')
						{
							PrevComments = String.valueOF(NewObj.get(IOM.Field_Name__c));  
						}
						
						if(String.isNotBlank(PrevComments))
							NewObj.put(IOM.Field_Name__c, PrevComments + Val);
						else					
							NewObj.put(IOM.Field_Name__c, Val);																	
					}
					else if(IOM.Data_Type__c == 'Checkbox')
					{	
						if(Val.equalsIgnoreCase('Y'))
						{									
							NewObj.put(IOM.Field_Name__c, true);
						}
						else if(Val.equalsIgnoreCase('N'))
						{
							NewObj.put(IOM.Field_Name__c, false);
						}								
					}						
					else if(IOM.Data_Type__c == 'Number' || IOM.Data_Type__c == 'Currency')
					{
						Val = Val.remove('.');
						Val = Val.remove(',');
						Integer ValLen = Val.length();
						
						if(ValLen >= 2)
						{
							String afterDecimal = Val.substring(ValLen - 2, ValLen);
							String beforeDecimal = Val.removeEnd(Val.substring(ValLen - 2, ValLen)); 
							
							NewObj.put(IOM.Field_Name__c, Decimal.valueOf(beforeDecimal +'.'+ afterDecimal).setScale(2));						
						}					
					}
					else if(IOM.Data_Type__c=='Integer' && String.isNotBlank(Val))
					{					
						NewObj.put(IOM.Field_Name__c, Integer.valueOf(val));					
					}  
					else if(IOM.Data_Type__c == 'Date')  
					{
					//	NewObj.put(IOM.Field_Name__c, Date.valueOf(Val));
					} 
					else if(IOM.Data_Type__c == 'DateTime')  
					{
						NewObj.put(IOM.Field_Name__c, DateTime.valueOf(Val.replace('T',' ')));
					}						 
				}										
			}  
			
			return NewObj;  
		}
		catch(NBTYException e)
		{
			throw new NBTYException(e.getMessage());
		}		
	} 
	
	// Method to set Currency on objects
	public static void setCurrency(Order_Summary__c OSRec, sObject NewObj)
	{
		try
		{
			if(OSRec.Webstack_ID__c != '')
			{
				// Currency Code will be utilized when Multi-Currency is implemented
				String CurrencyCode = wsData.Currency_Code__c;
				NewObj.put('currencyISOCode', CurrencyCode);
			}
		}
		catch(NBTYException e)
		{
			throw new NBTYException(e.getMessage());
		}		
	}		
}