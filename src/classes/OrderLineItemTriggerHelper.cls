public with sharing class OrderLineItemTriggerHelper {

	public static boolean isDeleteAllowed = false;
	public static boolean isIgnoreRestrictions = false;
	
	//Set the ship complete status automatically to override any changes from AS400 - used for both order and order line item triggers
	public static void setShipCompleteStatus(List <Order_Line_Items__c> triggerNew, List<Orders__c> triggerNew2){
		Set<Id> orderIds = new Set<Id>();
		if(triggerNew.Size() > 0){
			for(Order_Line_Items__c oli1 : triggerNew){
				orderIds.add(oli1.Order__c);
			}
		}else if(triggerNew2.Size() > 0){
			for(Orders__c ord1 : triggerNew2){
				orderIds.add(ord1.Id);
			}
		}
		
		List<Order_Line_Items__c> oliList = [SELECT Id, Name, Item_Status__c, Item_Status_Code__c, Shipped_Complete__c, Order__c FROM Order_Line_Items__c
												WHERE Order__c IN :orderIds];
		//Map Order Id to a list of Order Line Items
		Map<Id, List<Order_Line_Items__c>> ordToOliMap = new Map<Id, List<Order_Line_Items__c>>();
		for(Id a : orderIds){
			List<Order_Line_Items__c> tempList = new List<Order_Line_Items__c>();
			for(Order_Line_Items__c oli2 : oliList){
				if(oli2.Order__c == a){
					tempList.add(oli2);
				}
			}
			ordToOliMap.put(a, tempList);
		}
		
		//Since we don't know what trigger will fire this just get a list of orders to loop through
		List<Orders__c> ordList = [SELECT Id, Order_Status__c FROM Orders__c WHERE Id IN :orderIds];
		List<Orders__c> ordUpdateList = new List<Orders__c>();
		//Loop through orders
		for(Orders__c ord2 : ordList){
			Boolean isSC = true;
			//get oli records from map
			List<Order_Line_Items__c> olis = ordToOliMap.get(ord2.Id);
			//as long as the list isn't empty loop through olis
			if(olis.Size() > 0){
				for(Order_Line_Items__c oli3 : olis){
					if(oli3.Item_Status_Code__c != 'SC'){
						isSC = false;
					}
				}
			}
			if(isSC){
				ord2.Order_Status__c = 'Shipped Complete';
				ordUpdateList.add(ord2);
			}
			if(ordUpdateList.Size() > 0){
				update ordUpdateList;
			}
		}
		
		
	}
	
	public static void checkForRestrictions(List <Order_Line_Items__c> newLines){
		Set <Id> OrderIds = new Set <Id>();
		Set <Id> ItemIds = new Set <Id>();
		Map <Id, Orders__c> orderMap = new Map <Id, Orders__c>();
		Map <Id, Set <String>> itemMap = new Map <Id, Set <String>>();
		// first add ids to sets so we can query them for additonal data
		for (Order_Line_Items__c oli: newLines){
			OrderIds.add(oli.order__c);
			ItemIds.add(oli.product_name__c);
		}
		for (Orders__c o: [select  Webstack_ID__c, Ship_To_Address__r.Country__c, Ship_To_Address__r.Foreign_Country_Code__c, Ship_To_Address__r.PO_Box__c from  Orders__c where id in:orderIds  ]){
			orderMap.put(o.id, o);
		}
		for (Item__c i: [select id, (select restriction_text__c from Item_Restrictions__r) from Item__c where id in:ItemIds ]){
			if (i.item_restrictions__r.size()>0){
				Set <String> tempRestrictionSet = new Set <String>();
				for (Item_Restriction__c ir: i.item_restrictions__r){
					string restrictionsText = ir.restriction_text__c.contains('UPS')? 'UPS' : ir.restriction_text__c;
					tempRestrictionSet.add(restrictionsText);
				}
				itemMap.put(i.id,tempRestrictionSet);
			}
		} 
		
		if (!itemMap.isEmpty()){
			for (Order_Line_Items__c oli: newLines){
				Orders__c ord = orderMap.get(oli.order__c);
				WebStoresData__c wsd = WebStoresData__c.getInstance(ord.webstack_id__c);  
				boolean applyRestrictions = true;
				if (wsd!=null){
					applyRestrictions =wsd.apply_restrictions__c;
				}
				//Country_code_mapping__c.getValues(address.country_picklist__c).Code__c;
				String CountryCode = orderMap.get(oli.order__c).Ship_To_Address__r.Foreign_Country_Code__c;
				system.debug('CountryCode~~~~'+CountryCode);
				Set <String> ItemRestrictions = itemMap.containsKey(oli.product_name__c) ? itemMap.get(oli.product_name__c) : null;
				system.debug('ItemRestrictions~~~~'+ItemRestrictions);
				Country_Code_Mapping__c ccm = Country_Code_Mapping__c.getValues(CountryCode);
				if(ItemRestrictions != null)
				{
					if(ccm!=null && ccm.Restriction_Text__c != null &&applyRestrictions ){
						if (ItemRestrictions.contains(ccm.Restriction_Text__c)){
							oli.addError('This Item cannot be shipped to '+ccm.Name__c);
						}
					}
					if (orderMap.get(oli.order__c).ship_to_address__r.Po_box__c&&ItemRestrictions.contains('UPS')){
						oli.addError('This item cannot be shipped to a PO Box; it can only be shipped via UPS');
					}
					
					if (orderMap.get(oli.order__c).Ship_To_Address__r.Country__c!='US'&&ItemRestrictions.contains('Domestic Only')){
						oli.addError('This item can only be shipped domestically.');
					}
				}
			}
		}
	}
	
	public static void countForInsert(List <Order_Line_Items__c> newLines){
		Map <Id, Integer> orderCountMap = new Map <Id, Integer>();
		Map <Id, Orders__c> orderMap			= new Map <Id, Orders__c>();
		Set <Id> orderIds = new Set <Id>();
		for (Order_Line_Items__c oli: newLines){
			orderIds.add(oli.order__c);
			orderCountMap.put(oli.order__c, 0);
		}
		AggregateResult[] groupedResults= [select order__c orderId, count(id) cnt from Order_Line_Items__c where order__c in :orderIds group by order__c];
		
		
		for (AggregateResult ar : groupedResults)  {
			orderCountMap.put((ID)ar.get('orderId'),(integer)ar.get('cnt'));
		}
		for (Orders__c o: [select id, name from Orders__c where id in:orderIds]){
			orderMap.put(o.id,o);
		}
		system.debug('---------------------------------------------------OrderMap: ' + orderMap);
		for (Order_Line_Items__c oli: newLines){
			string OrderNumber = orderMap.get(oli.order__c).name;
			system.debug('------------------------------------------------OrderNumber: ' + OrderNumber);
			integer LineCount		= 	orderCountMap.get(oli.order__c);
			LineCount++;
			String OliKey			= OrderNumber+'-'+LineCount;
			orderCountMap.put(oli.order__c,LineCount);
			oli.name=OliKey;
			oli.Line_Number__c=string.valueOf(LineCount);
		}
	}
	
	public static void countForDelete(List <Order_Line_Items__c> oldLines){
		Map <Id, Integer> orderCountMap = new Map <Id, Integer>();
		Map <Id, Orders__c> orderMap			= new Map <Id, Orders__c>();
		List <Order_Line_Items__c> updOliList = new List <Order_Line_Items__c>();
		Set <Id> orderIds = new Set <Id>();
		for (Order_Line_Items__c oli: oldLines){
			orderIds.add(oli.order__c);
			orderCountMap.put(oli.order__c,1);
		}
		
		for (Order_Line_Items__c oli: [select id, order__r.name, line_number__c from Order_Line_Items__c where Order__c in:orderIds order by name]){
			string OrderNumber =oli.order__r.name;
			integer LineCount		= 	orderCountMap.get(oli.order__c);
			String OliKey			= OrderNumber+'-'+LineCount;
			orderCountMap.put(oli.order__c,LineCount);
			oli.name=OliKey;
			oli.Line_Number__c=string.valueOf(LineCount);
			updOliList.add(oli);
		}
		if (!updOliList.isEmpty()){
			update updOliList;
		}
	}
	
	public static void ValidateBeforeDelete(List<Order_Line_Items__c> triggerOld){
		Set<Id> orderIds = new Set<Id>();
		for(Order_Line_Items__c oli : triggerOld){
			orderIds.add(oli.Order__c);
		}
		Map<Id, Orders__c> ordMap = new Map<Id, Orders__c>([SELECT Id, Name, Order_Submitted__c FROM Orders__c WHERE Id IN :orderIds]);
		
		for(Order_Line_Items__c olis : triggerOld){
			Orders__c thisOrder = ordMap.get(olis.Order__c);
			if(thisOrder.Order_Submitted__c && !isDeleteAllowed){
				olis.addError('Order has been submitted to AS400 and cannot be deleted.');
			}
		}
	}
	
	public static void setShippingStatus(List<Order_Line_Items__c> triggerNew){
		Set<Id> ordIds = new Set<Id>();
		for (Order_Line_Items__c oli1 : triggerNew) {
			ordIds.add(oli1.Order__c);
		}
		// DE574 -- added Discount__c
		List<Orders__c> ordList = [SELECT Id, Allowance_Discount__c, Discount__c, Order_Status__c, Amazon_Model__c, Webstack_Order_ID__c, Sales_Channel__c, Tax__c, Misc_Charge_Amount__c, Shipping_Total__c, Shipping_Tax__c, Order_Sub_Total__c, Order_Total__c FROM Orders__c WHERE Id IN :ordIds];
		
		List<Order_Line_Items__c> oliList = [SELECT Id, Final_Price__c, Original_Quantity__c, Price_Override__c, Item_Buy__c, Product_Quantity__c,  Website_Price__c, Item_Status__c, Shipped_Complete__c, Item_Status_Code__c, Order__c , Tax__c
												FROM Order_Line_Items__c WHERE Order__c IN :ordIds];
		Map<Id, List<Order_Line_Items__c>> oliMap = new Map<Id, List<Order_Line_Items__c>>();
		for (Orders__c ord2 : ordList) {
			List<Order_Line_Items__c> oli2List = new List<Order_Line_Items__c>();
			for (Order_Line_Items__c oli1 : oliList) {
				if (oli1.Order__c == ord2.Id) {
					oli2List.add(oli1);
				}
			}
			if (oli2List.size() > 0) {
				oliMap.put(ord2.Id, oli2List);
			}
		}
		List<Orders__c> updatedOrders = new List<Orders__c>();
		for (Orders__c ord : ordList) {
			if (ord.Webstack_Order_ID__c != null && ord.Webstack_Order_ID__c != '') {
				ord.Tax__c = ord.Shipping_Tax__c==NULL?0:ord.Shipping_Tax__c;
				ord.Order_Sub_Total__c = 0;
				ord.Order_Total__c = 0;
				ord.Misc_Charge_Amount__c = ord.Misc_Charge_Amount__c != null?ord.Misc_Charge_Amount__c:0;
			}
			
			List<Order_Line_Items__c> myOlis = oliMap.get(ord.Id);
			
			if (myOlis.size() > 0) {
				Set<String> mySet = new Set<String>();
				for (Order_Line_Items__c oli : myOlis) {
					mySet.add(oli.Item_Status_Code__c);
					
					if (ord.Webstack_Order_ID__c != null && ord.Webstack_Order_ID__c != '') {
						ord.Tax__c += oli.Tax__c;
						
						if (oli.Price_Override__c > 0) {
							oli.Final_Price__c = oli.Price_Override__c * oli.Original_Quantity__c;
						} else if (ord.Sales_Channel__c == 'Brand Website') {
							oli.Final_Price__c = oli.Website_Price__c * oli.Original_Quantity__c;
						}
						
						ord.Order_Sub_Total__c += oli.Final_Price__c;
					}
				}
				
				if (mySet.contains('SC') && mySet.Size() > 1) {
					if (ord.Order_Status__c!='Shipped/Complete') ord.Order_Status__c = 'Partially Shipped';
				}
				
				if (ord.Webstack_Order_ID__c != null && ord.Webstack_Order_ID__c != '') {
					// DE645 -- Corrects calculation bug on sub total to total discovered while testing
					// Subtotal is original total, not after discount
					if (ord.Discount__c != null && ord.Discount__c > 0.00) {
						ord.Order_Sub_Total__c += ord.Discount__c;
						// The Discount__c contains all discounts; remove shipping from sub
						if (ord.Shipping_Total__c != null && ord.Shipping_Total__c != 0.00){
							ord.Order_Sub_Total__c -= ord.Shipping_Total__c;
						}
					}
					// DE574 -- Add in Discount__c
					// DE645 changed + to - for discount__c; seems we store as positive.
					if (ord.Discount__c != null) {
						ord.Order_Total__c = ord.Order_Sub_Total__c + ord.Shipping_Total__c + ord.Tax__c + ord.Misc_Charge_Amount__c - ord.Discount__c-ord.Allowance_Discount__c;
					} else {
						ord.Order_Total__c = ord.Order_Sub_Total__c + ord.Shipping_Total__c + ord.Tax__c + ord.Misc_Charge_Amount__c-ord.Allowance_Discount__c;
					}
				}
				
				updatedOrders.add(ord);
			}
		}
		
		if (updatedOrders.size() > 0) {
			update updatedOrders;
		}
	}
	
	public static void checkOverridePrice(List<Order_Line_Items__c> triggerNew){
		for(Order_Line_Items__c oli : triggerNew){
			if(oli.Price_Override__c > 0){
				if(oli.Price_Override__c > oli.Unit_Price__c){
					oli.addError('Price override cannot be greater than unit price.');
				}
			}
		}
	}
	
	public static void setFinalPrice(List<Order_Line_Items__c> triggerNew){
		for(Order_Line_Items__c oli : triggerNew){
			if(oli.Price_Override__c > 0){
				if(oli.Price_Override__c <= oli.Unit_Price__c){
					oli.Final_Price__c = oli.Price_Override__c * oli.Original_Quantity__c;
				}else{
					oli.addError('Price override cannot be greater than unit price.');
				}
				
			}
			else if(oli.Final_Price__c == 0){
				oli.Final_Price__c = oli.Website_Price__c * oli.Original_Quantity__c;
			}
			
		}
	}
	
}