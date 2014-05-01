/*
	OrderAdjustmentstBatch
	DESCRIPTION
	Process Order adjustments Batch Creation.
	------------------------------------------------------------------
	Author			|		Date		|	Description
	------------------------------------------------------------------
	Pavan Jasthi	|	2/10/2014		|	Created

*/

global class OrderAdjustmentstBatch implements Database.Batchable<sobject>,Database.AllowsCallouts {
	
	public Set<string> ordAdjustStatuses;
	public String errorReason;
	public String oaQuery;
	
	//constructor
	global OrderAdjustmentstBatch() {
		
	}
	
	global OrderAdjustmentstBatch(Boolean isErrorRun) {
		if (isErrorRun) {
			ordAdjustStatuses = new Set<String>{'Error'};
			errorReason = 'Order is not in AS400';
		} else {
			 ordAdjustStatuses = new Set<String>{'Approved', 'Waiting for Processing'};
		}
		oaQuery = 'SELECT Id, Related_Order__c, Customer__c,Refund_or_Misc_Amount__c, RecordType.DeveloperName, Status__c,Payment_Method__c, ';
		oaQuery += 'PayPal_Reference_ID__c,Transaction_Reference_Number__c,Credit_Card_Number__c,Credit_Card_Expiration_Date__c,Credit_Card_Type__c,Credit_Card_Name__c,Credit_Card_CVV__c ';
		oaQuery += 'FROM Order_Adjustment__c WHERE Status__c IN :ordAdjustStatuses ';
		if (isErrorRun) {
			oaQuery += 'AND Error_Reason__c = :errorReason';
		}
		system.debug('@@@@ batch query'+oaQuery);
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(oaQuery);
	}
	
	global void execute(Database.BatchableContext BC, sobject[] scope) {
		try {
			List<Order_Adjustment__c> ordAdjList = new List<Order_Adjustment__c>();
			ordAdjList = (List<Order_Adjustment__c>) scope;
			for (Order_Adjustment__c oa : ordAdjList) {
				WS_soa_OrderAdjustmentService.OrderAdjustmentResponse resp=WS_OrderAdjustmentUtils.doCallout(oa);
			}	
			
		}
		catch(Exception ex){
			System.debug('Error Processing Order Adjustments batch : '+ex.getMessage());
		}
	}
	
	global void finish(Database.BatchableContext BC) {
		system.debug('@@In Finish Method');
		BatchUtilities.batchEmailSuccess(BC, 'OrderAdjustmentstBatch');
	
	}
}