/* 
 *  Class           : OrderAdjustmentTriggerHelper 
 *  Author          : Pavan Jasthi - Acumen Solutions
 *  Creation         : 02/10/2014
 *  Description     : Helper class for OrderAdjustmentTrigger
 *                      
*/
public with sharing class OrderAdjustmentTriggerHelper {

	public static void isAfterInsert(List<Order_Adjustment__c> orderAdjList) {
		OrderAdjustmentTriggerHelper.UpdateOrderStatus(orderAdjList,null);
	}
	
	public static void isAfterUpdate(List<Order_Adjustment__c> orderAdjList, Map <Id, Order_Adjustment__c> oldMap) {
		OrderAdjustmentTriggerHelper.UpdateOrderStatus(orderAdjList,oldMap);
		createCredit(orderAdjList,oldMap);
		OrderAdjustmentTriggerHelper.autoCloseCases(orderAdjList);
		//updateRecordTypeOnProcessed(orderAdjList,oldMap);
	}
	
	public static void isBeforeUpdate(List<Order_Adjustment__c> orderAdjList,Map <Id, Order_Adjustment__c> oldMap) {
		preCheckDupRefund(orderAdjList, oldMap);
		updateRecordTypeToReadOnly(orderAdjList, oldMap);
	}
	
	public static void isBeforeInsert(List<Order_Adjustment__c> triggerNew) {
		OrderAdjustmentTriggerHelper.setTypeValue(triggerNew);
		OrderAdjustmentTriggerHelper.blockOrderAdjustments(triggerNew);
	}
	
	public static void setTypeValue(List <Order_Adjustment__c> ordAdjList){
		Map <Id, RecordType> oaRtMap= new Map <Id, RecordType>();
		for (RecordType rt: [select id, developerName, Name from RecordType where sObjectType='Order_Adjustment__c']){
			oaRtMap.put(rt.id, rt);
		}
		for (Order_Adjustment__c oa: ordAdjList){
			oa.Type__c=oaRtMap.get(oa.RecordTypeId).Name;
		}
	}
	
	
	public static void preCheckDupRefund(List <Order_Adjustment__c> ordAdjList, Map<Id, Order_Adjustment__c> oldMap){
			List <Order_Adjustment__c> checkOAList = new List <Order_Adjustment__c>();
			for (Order_Adjustment__c oa:ordAdjList){
				if ((oa.Status__c=='Approved')&&(oldMap.get(oa.id).status__c!='Approved')){
					checkOAList.add(oa);
				}
			}
			if (!checkOAList.isEmpty()){
				checkDupRefund(checkOAList);
			}
	}
	
	public static void checkDupRefund(List <Order_Adjustment__c> ordAdjList){
		/*Begin check on validation to prevent same orders/lines from being refunded*/
								/* check for full refund, block same order*/
				Set <String> ordAdjustmentsToCheck = new Set <String>();
				Map <String,Order_Adjustment__c> alreadyProcessedOrdNumMap = new Map <String,Order_Adjustment__c>();
				Set <Id> oaIds = new Set <Id>();
				for (Order_Adjustment__c oa: ordAdjList){
					ordAdjustmentsToCheck.add(oa.AS400_Order_Number__c);
					ordAdjustmentsToCheck.add(oa.Related_Order__c);
					ordAdjustmentsToCheck.add(oa.Salesforce_Order_Number__c);
					ordAdjustmentsToCheck.add(oa.Web_Order_Number__c);
					oaIds.add(oa.id);//needed for order line checking for partial refunds
				}
				for (Order_Adjustment__c tempoa : [select id, name , AS400_Order_Number__c, Salesforce_Order_Number__c
																		from Order_Adjustment__c 
																		where (AS400_Order_Number__c in :ordAdjustmentsToCheck
																		or Related_Order__c  in :ordAdjustmentsToCheck
																		or Salesforce_Order_Number__c  in :ordAdjustmentsToCheck
																		or Web_Order_Number__c  in :ordAdjustmentsToCheck)
																		and (Status__c ='Processed'
																		or 	Status__c ='Approved')
																		//and recordType.developerName = 'Read_Only'
																		and Refund_Type__c ='Full Refund'	 ]){
					if (tempoa.AS400_Order_Number__c!=null) alreadyProcessedOrdNumMap.put(tempoa.AS400_Order_Number__c, tempoa);
					if (tempoa.Salesforce_Order_Number__c!=null)  alreadyProcessedOrdNumMap.put(tempoa.Salesforce_Order_Number__c, tempoa);
				}
				/* check for partial refund, block lines*/
				Set <String> checkLineKeySet = new Set <String>();
				Map <Id, List <Order_Adjustment_Line_Item__c>> oalMap = new Map <Id, List <Order_Adjustment_Line_Item__c>>();
				for (Order_Adjustment_Line_Item__c oal: [select id, External_Key__c ,Order_Adjustment__c, Order_Adjustment__r.name
																							from Order_Adjustment_Line_Item__c 
																							where order_adjustment__c in:oaIds
																							and isChecked__c = true		 ]){
																								checkLineKeySet.add(oal.external_key__c);
																							if (oalMap.get(oal.Order_Adjustment__c)==null){
																								oalMap.put(oal.Order_Adjustment__c, new List <Order_Adjustment_Line_Item__c>{oal});
																							}
																							else {
																								oalMap.get(oal.Order_Adjustment__c).add(oal);
																							}
					}
				if (!checkLineKeySet.isEmpty()){
					for (Order_Adjustment_Line_Item__c oal : [select id, Order_Adjustment__c, order_adjustment__r.name, order_adjustment__r.AS400_Order_Number__c, order_adjustment__r.Salesforce_Order_Number__c, external_key__c
																			from Order_Adjustment_Line_Item__c 
																			where (  order_adjustment__r.Status__c ='Processed'
																			or order_adjustment__r.Status__c ='Approved')
																		//	and order_Adjustment__r.recordType.developerName = 'Read_Only'
																			and order_adjustment__r.Refund_Type__c ='Partial Refund'	 
																			and isChecked__c = true
																			and external_key__c in :checkLineKeySet]){
						alreadyProcessedOrdNumMap.put(oal.external_key__c, oal.order_adjustment__r);
					}
				}
				if (!alreadyProcessedOrdNumMap.isEmpty()){
					for (Order_Adjustment__c oa: ordAdjList){
						string checkNumber = oa.AS400_Order_Number__c!=null?  oa.AS400_Order_Number__c :oa.Salesforce_Order_Number__c ;
						if (alreadyProcessedOrdNumMap.keySet().contains(checkNumber)){
							oa.status__c = 'Rejected';
							oa.Error_Reason__c='Refund already processed through Order Adjustment: '+alreadyProcessedOrdNumMap.get(checkNumber).name;		
						}
					}
					for (Order_Adjustment__c oa: ordAdjList){
						if (oalMap.get(oa.id)!=null){
							for (Order_Adjustment_Line_Item__c oal: oalMap.get(oa.id)){
								if (alreadyProcessedOrdNumMap.keySet().contains(oal.External_Key__c)){
									oa.status__c = 'Rejected';
									oa.Error_Reason__c='Refund already processed through Order Adjustment: '+alreadyProcessedOrdNumMap.get(oal.External_Key__c).name;		
								}													
							}
						}
					}
				}
	}
	
	public static void updateRecordTypeToReadOnly (List<Order_Adjustment__c> orderAdjList,Map <Id, Order_Adjustment__c> oldMap) {
		RecordType roRecType = [SELECT Id, Name, DeveloperName FROM RecordType WHERE sObjectType = 'Order_Adjustment__c' and DeveloperName = 'Read_Only' limit 1];
		for(Order_Adjustment__c oa : orderAdjList) {
			if ((oa.Status__c=='Processed'||oa.Status__c=='Customer Paid')&&(oldMap.get(oa.id).status__c!='Processed'&&oldMap.get(oa.id).status__c!='Customer Paid')){
				oa.RecordTypeId=roRecType.id;
			}
		}
	}
	
	public static void UpdateOrderStatus(List <Order_Adjustment__c> orderAdjList, Map <Id, Order_Adjustment__c> oldMap) {
		system.debug('-------------------------------------------------------------------START');
		set<string> orderIds = new set<string>();
		RecordType miscRecType = [SELECT Id, Name, DeveloperName FROM RecordType WHERE sObjectType = 'Order_Adjustment__c' and DeveloperName = 'Misc_Charge' limit 1];
		for(Order_Adjustment__c oa : orderAdjList) {
			if (oa.Related_Order__c!=null) orderIds.add(oa.Related_order__c); 
		}
		if (!orderIds.isEmpty()){
			system.debug('-------------------------------------------------------------------orderIds: ' + orderIds);
			map<Id, orders__c> ordersMap = new map<Id, orders__c>([SELECT Id, Order_Status__c, Order_Submitted__c, CreatedById, OwnerId FROM Orders__c WHERE Id IN :orderIds]);
			system.debug('-------------------------------------------------------------------ordersMap: ' + ordersMap);
			//update trigger
			List<Orders__c> ordersToUpdate = new List<Orders__c>();
			if (oldMap != null && !oldMap.isEmpty()) {
				for(Order_Adjustment__c odj : orderAdjList) {
					system.debug('-------------------------------------------------------------------odj1: ' + odj);
					//if(odj.RecordTypeId == miscRecType.Id) {
						//Only when either status fields change for misc charges
						system.debug('-------------------------------------------------------------------oldMap.get(odj.Id).status__c: ' + oldMap.get(odj.Id).status__c);
						if((oldMap.get(odj.Id).status__c != 'Processed' && odj.status__c =='Processed') || (oldMap.get(odj.Id).Status__c != 'Customer Paid' && odj.Status__c =='Customer Paid')) {
							//"Customer paid" through cash or check , "Processed" when paid through credit card
							if((odj.Status__c == 'Customer Paid' && (odj.Payment_Method__c == 'Cash' || odj.Payment_Method__c =='Check')) || (odj.status__c =='Processed' && (odj.Payment_Method__c == 'Credit Card' || odj.Payment_Method__c =='Existing Card'))) {
								//If its not already sumbitted for order fullfilment to AS400 then change to Pending Submission
								orders__c ord = ordersMap.get(odj.Related_Order__c);
								if(!ord.order_submitted__c && ord.Order_Status__c != 'Pending Submission')
									ord.Order_Status__c = 'Pending Submission';
									ord.OwnerId = ord.CreatedById;
									ordersToUpdate.add(ord);
							}
						}
					//}
				}	
			} else {//insert trigger
				for(Order_Adjustment__c odj : orderAdjList) {
					system.debug('-------------------------------------------------------------------odj2: ' + odj);
					//if(odj.RecordTypeId == miscRecType.Id) {
						//"Customer paid" through cash or check , "Processed" when paid through credit card
						if((odj.Status__c == 'Customer Paid' && (odj.Payment_Method__c == 'Cash' || odj.Payment_Method__c =='Check')) || (odj.status__c =='Processed' && (odj.Payment_Method__c == 'Credit Card' || odj.Payment_Method__c =='Existing Card'))) {
							//If its not already sumbitted for order fullfilment to AS400 then change to Pending Submission
							orders__c ord = ordersMap.get(odj.Related_Order__c);
							if(!ord.order_submitted__c && ord.Order_Status__c != 'Pending Submission')
								ord.Order_Status__c = 'Pending Submission';
								ordersToUpdate.add(ord);
						}
					//}
				}
			}
			update ordersToUpdate;
			//update ordersMap.values();
		}
	}
	
	public static void createCredit(List <Order_Adjustment__c> orderAdjList, Map <Id, Order_Adjustment__c> oldMap) {
		list<Credit__c> credits = new list<Credit__c>();
		Set<string> tempAdjIds = new Set<string>();
		Set<Id> caseIds = new Set<Id>();
		List <Order_Adjustment__c> tempOdjList = new List <Order_Adjustment__c>();
		for(Order_Adjustment__c odj : orderAdjList) {
			if(odj.Payment_method__c == 'Customer Credit' && odj.status__c == 'Approved' && oldmap.get(odj.Id).status__c != 'Approved') {
				
				credit__c newCredit = new Credit__c();
				newCredit.Account__c = odj.Customer__c;
				newCredit.Credit_Amount__c = odj.Refund_or_Misc_Amount__c; 
				newCredit.Credit_Notes__c = 'Refund for OA #'+odj.Name;
				newCredit.Credit_Reason__c = 'Refund';
				tempAdjIds.add(odj.Id);
				credits.add(newCredit);
				if (odj.Related_Case__c != null) {
					caseIds.add(odj.Related_Case__c);
				}
			}
		}
		if(credits.size() > 0)
			insert credits;
		//Flipping Orderadjustments status to processed once customer credit is created
		if(tempAdjIds.size() > 0) {
			for(Order_Adjustment__c odj : [select Id,Status__c from Order_Adjustment__c where Id IN:tempAdjIds ]) {
				odj.Status__c = 'Processed'; // flipping to processed
				tempOdjList.add(odj);
			}
			if(tempOdjList.size() > 0) {
				update tempOdjList;
			}
			//closeCaseForProcessed(caseIds);
		}
	}
	
	public static void autoCloseCases(List<Order_Adjustment__c> triggerNew) {
		Set<Id> cseIds = new Set<Id>();
		for (Order_Adjustment__c a : triggerNew) {
			if (a.Status__c == 'Processed') {
				cseIds.add(a.Related_Case__c);
			}
		}
		RecordType rt = [SELECT Id FROM RecordType WHERE DeveloperName = 'Product_Complaint' LIMIT 1];
		Map<Id, Case> caseMap = new Map<Id, Case>([SELECT Id, Status FROM Case WHERE Id IN :cseIds AND RecordTypeId != :rt.Id]);
		List<Case> cseList = new List<Case>();
		for (Order_Adjustment__c oa : triggerNew) {
			if (oa.Status__c == 'Processed') {
				Case cse = caseMap.get(oa.Related_Case__c);
				if (cse != null) {
					cse.Status = 'Closed';
					cseList.add(cse);
				}
			}
		}
		update cseList;
	}
	
	public static void blockOrderAdjustments(List<Order_Adjustment__c> triggerNew) {
		system.debug('-----------------------------------------Start blockOrderAdjustments');
		Set<String> oaSet = new Set<String>();
		for (Order_Adjustment__c oa1 : triggerNew) {
			oaSet.add(oa1.Related_Order__c);
			system.debug('-----------------------------------------oa1: ' + oa1);
		}
		system.debug('-----------------------------------------oaSet: ' + oaSet);
		Map<Id, Orders__c> wsidMap = new Map<Id, Orders__c>([SELECT Id, Webstack_ID__c, Third_Party_Order_Number__c FROM Orders__c WHERE Id IN :oaSet]);
		system.debug('-----------------------------------------wsidMap: ' + wsidMap);
		
		for (Order_Adjustment__c oa3 : triggerNew) {
			Orders__c oa = wsidMap.get(oa3.Related_Order__c);
			system.debug('-----------------------------------------oa: ' + oa);
			if (oa != null) {
				String wsid = oa.Webstack_ID__c;
				system.debug('-----------------------------------------wsid: ' + wsid);
				if (!String.isBlank(wsId)) {
					WebStoresData__c wsd = WebStoresData__c.getValues(wsid);
					system.debug('-----------------------------------------wsd: ' + wsd);
					if (wsd != null) {
						if (wsd.Block_Order_Adjustments__c) {
							oa3.addError('Cannot create Order Adjustments for Web Stack Id: ' + wsid);
						} else if (wsid == '1' && !String.isBlank(oa.Third_Party_Order_Number__c)) {
							oa3.addError('Cannot create Order Adjustments for Order Groove orders.');
						}
					}
				}
			}
		}
	}
	
	
	
	
}