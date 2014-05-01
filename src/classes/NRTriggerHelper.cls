public with sharing class NRTriggerHelper {
	
/*	public static void sendUpdatesToPqm(List<Nutrition_Review__c> triggerNew){ NOT NEEDED PER NEW APPROACH TO SYNC TO PQM
		Set<String> relatedCases = new Set<String>();
		for(Nutrition_Review__c a : triggerNew){
			relatedCases.add(a.NR_Associated_Case__c);
		}
		for (Id caseId: relatedCases){
			CaseTriggerHelper.isFromChild=true;
			CaseTriggerHelper.sendCaseToPqm(caseId);
		}
	}*/
	/*
	public static void lockAllRelatedRecords(List<Nutrition_Review__c> triggerNew)
	{
		Set<String> relatedCases = new Set<String>();
		for(Nutrition_Review__c a : triggerNew){
			relatedCases.add(a.NR_Associated_Case__c);
		}
		for (Id caseId: relatedCases){
			CaseTriggerHelper.isFromChild=true;
		}
	}*/
	
	public static void countForNameModification(List<Nutrition_Review__c> triggerNew)
	{
		List<String> listOfCaseIds = new List<String>();
		
		for(Nutrition_Review__c aReview : triggerNew)
		{
			listOfCaseIds.add(aReview.NR_Associated_Case__c);
		}
		
		List<Case> currentCase = [SELECT Id, CaseNumber From Case WHERE Id IN :listOfCaseIds LIMIT 1];
		List<Nutrition_Review__c> currentCaseNRs = [SELECT Id, NR_Associated_Case__c FROM Nutrition_Review__c WHERE NR_Associated_Case__c IN :listOfCaseIds LIMIT 1];
		
		integer currentNRListSize = 0;
		for(Nutrition_Review__c anNR : currentCaseNRs)
		{
			currentNRListSize++;
		}
		
		integer numberOfNRsUpdated = 1;
		for(Nutrition_Review__c anUpdatedNR : triggerNew)
		{
			anUpdatedNR.Name = currentCase[0].CaseNumber + '-' + (currentNRListSize + numberOfNRsUpdated);
			numberOfNRsUpdated++;
		}

	}
	
	public static void InternationalComplaintValidation(List<Nutrition_Review__c> triggerNew){
		Set<String> relatedCases = new Set<String>();
		for(Nutrition_Review__c a : triggerNew){
			relatedCases.add(a.NR_Associated_Case__c);
		}
		List<Case> caseQuery = [SELECT Id, International_Complaint__c FROM Case WHERE Id IN :relatedCases];
		
		Map<Id, Case> caseToAER = new Map<Id, Case>();
		for(Nutrition_Review__c aReview : triggerNew){
			for(Case aCase : caseQuery){
				if(aCase.Id == aReview.NR_Associated_Case__c){
					caseToAER.put(aReview.Id, aCase);
				}
			}
		}
		
		for(Nutrition_Review__c aReview : triggerNew){
			Case validationCase = caseToAER.get(aReview.Id);
			if(validationCase != null)
			{
				if(validationCase.International_Complaint__c){
					aReview.addError('Cannot add reviews to international complaints');
				}
			}	
		}
	}
	
	public static void beforeDelete(List<Nutrition_Review__c> triggerNew)
	{
		List<String> nrRelatedCases = New List<String>();
		
		for(Nutrition_Review__c aRelatedId : triggerNew)
		{
			nrRelatedCases.add(aRelatedId.NR_Associated_Case__c);
		}
		
		List<Case> parentCases = [SELECT Id, Agile_Status__c FROM Case WHERE Id IN :nrRelatedCases];
		
		for(Case aParent : parentCases)
		{
			if(aParent.Agile_Status__c == '0')
			{
				aParent.addError('The Nutrition Review attched to the parent case ' + aParent.Id + ' is unable to be deleted because the record was already synced with PQM');
			}
		}
		for(Nutrition_Review__c aReview : triggerNew)
		{
			if(aReview.Synced_With_PQM__c == 'Yes')
			{
				aReview.addError('The Nutrition Review ' + aReview.Name + ' is synced with PQM and cannot be deleted.');
			}
		}
	}
	
	// DE859 -- NR records not updating case correctly for resending to PQM.
	public static void beforeUpdate(List<Nutrition_Review__c> triggerNew){
		List<Case> cases;
		Set<String> ids = new Set<String>();
		for (Nutrition_Review__c nr : triggerNew){
			ids.add(nr.NR_Associated_Case__c);
		}
		cases = [SELECT Id, Agile_Status__c, Agile_Status_Description__c FROM Case WHERE Id IN :ids];
		
		for (Case c: cases){
			c.Agile_Status__c = null;
			c.Agile_Status_Description__c = null;
		}
		
		update cases;
	}
}