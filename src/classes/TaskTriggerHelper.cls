/* 
	TaskTriggerHelper
	DESCRIPTION
	------------------------------------------------------------------
	Author		|	Date		|	Description
	------------------------------------------------------------------
	Gary Alfrey |	5/24/2013	|	Created

*/

public with sharing class TaskTriggerHelper {
	
	public static void CopyToParent(List<Task> triggerNew){
		Set<Id> whatIds = new Set<Id>();
		for(Task myTask : triggerNew){
			whatIds.add(myTask.WhatId);
		}
	
		Map<Id, Case> caseMap = new Map<Id, Case>([SELECT Id, CTI_Search__c, Web_Form_Comments__c FROM Case WHERE Id IN :whatIds]);
		Map<Id, Orders__c> orderMap = new Map<Id, Orders__c>([SELECT Id, CTI_Search__c FROM Orders__c WHERE Id IN :whatIds]);
		List<Case> caseList = new List<Case>();
		List<Orders__c> ordersList = new List<Orders__c>();
		Case myCase;
		Orders__c myOrder;
		for(Task t : triggerNew){
			if(t.CallType == 'Inbound' || t.CallType == 'Outbound'){
				if(t.WhatId != null){
					myCase = caseMap.get(t.WhatId);
					myOrder = orderMap.get(t.WhatId);
					if(myCase != null){
						myCase.CTI_Search__c = t.ANI__c;
						myCase.Description += '\n' + t.Description;
						caseList.add(myCase);
					}
					if(myOrder != null){
						myOrder.CTI_Search__c = t.ANI__c;
						ordersList.add(myOrder);
					}
				}
			}
	      
		}
		if(ordersList.size() > 0){
			update ordersList;
		}
		if(caseList.size() > 0){
			update caseList;
		}
	}
	
}