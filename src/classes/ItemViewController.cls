public with sharing class ItemViewController {
	
	public static final String PtP_BRAND = 'Perfectly_Pure_Customer';
	public static final String PP_BRAND = 'Puritans_Pride_Customer';
	public static final String VW_BRAND = 'Vitamin_World_Customer';
	public Item__c Item {get;set;}
	public Boolean showCancel {get;set;}
	public String EffectiveDate {get;set;}
	public String ItemId {get;set;}
	
	public ItemViewController(ApexPages.StandardController stdController) {
		ItemID = stdController.getId();
		showCancel = true;
		Item = [SELECT Id, Product_Suffix__c,Name, Product_Number__c, CreatedDate FROM Item__c WHERE Id =:ItemID];
	}
	public void BulkCancel() {
		Date dttoday = Date.today();
		try {
			date dtEffective = date.parse(EffectiveDate);
			if (dtEffective > dttoday) {
				ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Selected date should not be a future date.'));
				return;
			}
		} catch (exception e) {
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Invalid Effective date.'));
			return;
		}
		try {
			WS_OrderLineItemCancellation.CancelOrderPort wsCancelOrder = new WS_OrderLineItemCancellation.CancelOrderPort();
			WS_OrderLineItemCancellation.OrderCancellationResponse_element cancelResponse = new WS_OrderLineItemCancellation.OrderCancellationResponse_element();
			string SFDCOrderNumber = '';
			
			cancelResponse = wsCancelOrder.CancelOrder(SFDCOrderNumber, SFDCOrderNumber, '4', EffectiveDate, Item.Product_Number__c, Item.Product_Suffix__c, '', '' , '','');
			
			//process response
			if (cancelResponse.Status != 'Success') {
				ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Error Cancelling order: ' + cancelResponse.StatusCode + '-'+ cancelResponse.StatusMessage ));
				return;	
			} else {
				//Update orderlineitem status
				ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'Successfully initiated process of Bulk Order Cancellation'));
				massBackOrderCancel(Item);
			}
		} catch (exception e) {
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Error invoking cancellation web service'));
			system.debug('--------Error invoking cancellation Web Service' + e.getmessage());
			
		}
	}
	
	public static void massBackOrderCancel(Item__c item) {
		List<Order_Line_Items__c> backOrderedOLI = getOliList(item.Id);
		system.debug('-----------------------------------------backOrderedOLI: ' + backOrderedOLI);
		Set<Id> orderIds = extractOrderIds(backOrderedOLI);
		system.debug('-----------------------------------------orderIds: ' + orderIds);
		List<Orders__c> orders = getOrdersList(orderIds);
		system.debug('-----------------------------------------orders: ' + orders);
		Map<Id, List<Order_Line_Items__c>> ordToOliMap = mapOrdersToLines(orders, backOrderedOLI);
		system.debug('-----------------------------------------ordToOliMap: ' + ordToOliMap);
		List<Case> cseList = createCases(orders);
		createOrderAdjustments(ordToOliMap, cseList);
	}
	
	public static List<Case> createCases(List<Orders__c> orders) {
		List<Case> cseList = new List<Case>();
		RecordType rt = [SELECT Id FROM RecordType WHERE SobjectType = 'Case' AND DeveloperName = 'Follow_Up' LIMIT 1];
		QueueSobject qso = [SELECT QueueId, Id FROM QueueSobject WHERE SobjectType = 'Case' AND Queue.DeveloperName = 'Case_for_Cancelled_Orders' LIMIT 1];
		for (Orders__c o : orders) {
			if (o.Payment_Type__c != 'Credit Card') {
				Case cse = new Case();
				cse.RecordTypeId = rt.Id;
				cse.Case_Reason__c = 'Order';
				cse.Case_Sub_Reason__c = 'Cancelled Order';
				cse.Case_Resolution__c = 'Issued Refund/Credit';
				cse.Customer__c = o.Customer__c;
				if (o.Customer__r.RecordType.DeveloperName == PtP_BRAND) {
					cse.Brand__c = 'Perfectly Pure';
				} else if (o.Customer__r.RecordType.DeveloperName == PP_BRAND) {
					cse.Brand__c = 'Puritan\'s Pride';
				} else if (o.Customer__r.RecordType.DeveloperName == VW_BRAND) {
					cse.Brand__c = 'Vitamin World';
				}
				cse.Status = 'New';
				cse.Origin = 'Refund Auto Generated Case';
				cse.Related_Order__c = o.Id;
				//Waiting for queue to be created for ownership assignment
				cse.OwnerId = qso.QueueId;
				cseList.add(cse);
			}
		}
		insert cseList;
		system.debug('-----------------------------------------cseList1: ' + cseList);
		Set<Id> cseIds = new Set<Id>();
		for (Case c : cseList) {
			cseIds.add(c.Id);
		}
		return [SELECT Id, Customer__c, Related_Order__c FROM Case WHERE Id IN :cseIds];
	}
	
	public static void createOrderAdjustments(Map<Id, List<Order_Line_Items__c>> ordToOliMap, List<Case> cseList) {
		List<Order_Adjustment__c> oaList = new List<Order_Adjustment__c>();
		RecordType rt = [SELECT Id FROM RecordType WHERE SobjectType = 'Order_Adjustment__c' AND DeveloperName = 'Refund' LIMIT 1];
		for (Case c : cseList) {
			Order_Adjustment__c oa = new Order_Adjustment__c();
			oa.Refund_Type__c = 'Partial Refund';
			oa.Related_Order__c = c.Related_Order__c;
			oa.Related_Case__c = c.Id;
			oa.Related_Order_Line_Item__c = ordToOliMap.get(c.Related_Order__c)[0].Id;
			oa.Status__c = 'Draft';
			oa.RecordTypeId = rt.Id;
			oaList.add(oa);
		}
		insert oaList;
		system.debug('-----------------------------------------oaList: ' + oaList);
	}
	
	public static List<Order_Line_Items__c> getOliList(Id itemId) {
		Set<String> statuses = new Set<String>{'SHIPPED', 'CANCELLED'};
		List<Order_Line_Items__c> oliList = [SELECT Id, Order__c, Order__r.Order_Submitted__c, Product_Name__c, Item_Status__c, Related_Order_Adjustment__c, Order__r.Payment_Type__c 
												FROM Order_Line_Items__c 
												WHERE Product_Name__c = :itemId 
												AND Order__r.Payment_Type__c != 'Credit Card'
												AND Item_Status__c NOT IN :statuses 
												AND Order__r.Order_Submitted__c = true];
		return oliList;
	}
	
	public static Set<Id> extractOrderIds(List<Order_Line_Items__c> olis) {
		Set<Id> mySet1 = new Set<Id>();
		for (Order_Line_Items__c oli : olis) {
			mySet1.add(oli.Order__c);
		}
		return mySet1;
	}
	
	public static List<Orders__c> getOrdersList(Set<Id> ordIds) {
		List<Orders__c> ordList = [SELECT Id, Order_status__c, Related_Order_Adjustment__c, Customer__c, Customer__r.RecordType.DeveloperName, Payment_Type__c 
									FROM Orders__c WHERE Id IN :ordIds];
		return ordList;
	}
	
	public static Map<Id, List<Order_Line_Items__c>> mapOrdersToLines(List<Orders__c> ordList, List<Order_Line_Items__c> oliList) {
		Map<Id, List<Order_Line_Items__c>> myMap1 = new Map<Id, List<Order_Line_Items__c>>();
		for (Orders__c o : ordList) {
			List<Order_Line_Items__c> oliMapList = new List<Order_Line_Items__c>();
			for (Order_Line_Items__c oli : oliList) {
				if (oli.Order__c == o.Id) {
					oliMapList.add(oli);
				}
			}
			myMap1.put(o.Id,oliMapList);
		}
		return myMap1;
	}
	
}