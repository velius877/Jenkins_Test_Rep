/*
	OrderStatusQueryBatch
	DESCRIPTION
	------------------------------------------------------------------
	Author		|	Date		|	Description
	------------------------------------------------------------------
	Gary Alfrey |	10/14/13	|	Created

*/


global class OrderStatusQueryBatch implements Database.Batchable<sObject>, Database.AllowsCallouts{
	
	public Set<String> orderNumbers;
	public date filterDate;
	public Set<String> statuses;
	public String query;
	public datetime minDateTime;
	public datetime maxDateTime;
	public datetime dt;
	public boolean isNight;
	
	global OrderStatusQueryBatch(Boolean isNightly){
		statuses = new Set <String>{'Cancelled','Shipped/Complete'};
		isNight = isNightly;
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC){
		system.debug('----------------------------------------------------orderNumbers: ' + orderNumbers);
		if (isNight) {
			if(orderNumbers != null){
				query = 'SELECT Id, Name FROM Orders__c WHERE Name IN :orderNumbers';
			}else{
				query = 'SELECT Id, Name FROM Orders__c WHERE Order_Submitted__c = true AND Order_Status__c NOT IN :statuses';
			}
			if(filterDate != null){
				query += ' AND Order_Date__c > :filterDate ';
			}else if(minDateTime != null && maxDateTime != null){
				query += ' AND Order_Date__c > :minDateTime AND Order_Date__c < :maxDateTime ';
			}
		} else {
			//set to hourly query
			//query details: only query orders that have been submitted in the last hour.
			dt = DateTime.now().addHours(-6);
			statuses = new Set <String>{'Submitted','Bad Order','Error Screen'};
			query = 'SELECT Id, Name FROM Orders__c WHERE Order_Submitted__c = true AND Order_Date__c >= :dt AND Order_Status__c IN :statuses';
		}
		system.debug('-----------------------------------------------QUERY: ' + query);
		return Database.getQueryLocator(query);
	}

	global void execute(Database.BatchableContext BC, List<sObject> scope){
		List<Orders__c> orderList = (List<Orders__c>) scope;
		WS_OrderStatusQuery.OrderStatusQueryResponse_element response_Element;
		
		for(Orders__c ord : orderList){
			response_Element = new WS_OrderStatusQuery.OrderStatusQueryResponse_element();
			response_Element = WS_OrderStatusQueryUtils.doCallout(ord.Id);
			if(response_Element.OrderStatusSuccess != null){
				List<Order_Line_Item_Status_Detail__c> ordStatusDetails = WS_OrderStatusQueryUtils.processSuccess(response_Element.OrderStatusSuccess);
				if(ordStatusDetails != null){
					OrderStatusQueryUtils.processItemSubtitution(ordStatusDetails);
				}
			}else if(response_Element.OrderStatusFault != null){
				system.debug('---------------------------------------------------------Failure');
				WS_OrderStatusQuery.OrderStatusSuccess oss = new WS_OrderStatusQuery.OrderStatusSuccess();
				oss.OrderStatus = response_Element.OrderStatusFault.FaultCode;
				oss.OrderStatusDetail = response_Element.OrderStatusFault.FaultMessage;
				oss.SFOrderNumber = ord.Name;
				List<WS_OrderStatusQuery.LineItem> aList = null;
				WS_OrderStatusQuery.LineItemList lineItemList = new WS_OrderStatusQuery.LineItemList();
				lineItemList.LineItem = aList;
				oss.LineItemList = lineItemList;
				List<Order_Line_Item_Status_Detail__c> xp = WS_OrderStatusQueryUtils.processSuccess(oss);
				system.debug('---------------------------------------------------------xp: ' + xp);
				if(xp != null){
					Set<String> olisdIds = new Set<String>();
					for(Order_Line_Item_Status_Detail__c a : xp){
						olisdIds.add(a.Id);
					}
					OrderStatusQueryUtils.processItemSubtitution(xp);
				}
			}
		}
	}

	global void finish(Database.BatchableContext BC){
		
	}
}