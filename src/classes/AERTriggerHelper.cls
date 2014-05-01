public class AERTriggerHelper {
	
	public static void beforeDelete(List<Adverse_Event_Review__c> triggerNew)
	{
		List<String> aerRelatedCases = new List<String>();
		for(Adverse_Event_Review__c aRelatedId : triggerNew)
		{
			aerRelatedCases.add(aRelatedId.AER_Related_Case__c);
		}
		
		List<Case> parentCases = [SELECT Id, Agile_Status__c FROM Case WHERE Id IN :aerRelatedCases];
		
		for(Case aParent : parentCases)
		{
			if(aParent.Agile_Status__c == '0')
			{
				aParent.addError('The Adverse Event Review attched to the parent case ' + aParent.Id + ' is unable to be deleted because the record was already synced with PQM');
			}
		}
		
		for(Adverse_Event_Review__c aReview : triggerNew)
		{
			if(aReview.Synced_With_PQM__c == 'Yes')
			{
				aReview.addError('The Adverse Event Review ' + aReview.Name + ' is already synced with PQM');
			}
		}
		
	}
	
	public static void countForNameModification(List<Adverse_Event_Review__c> triggerNew)
	{
		List<String> listOfCaseIds = new List<String>();
		
		for(Adverse_Event_Review__c aReview : triggerNew)
		{
			listOfCaseIds.add(aReview.AER_Related_Case__c);
		}
		
		List<Case> currentCase = [SELECT Id, CaseNumber From Case WHERE Id IN :listOfCaseIds LIMIT 1];
		List<Adverse_Event_Review__c> currentCaseAERs = [SELECT Id, AER_Related_Case__c FROM Adverse_Event_Review__c WHERE AER_Related_Case__c IN :listOfCaseIds];
		
		integer currentAERListSize = 0;
		for(Adverse_Event_Review__c anAER : currentCaseAERs)
		{
			currentAERListSize++;
		}
		
		integer numberOfAERsUpdated = 1;
		for(Adverse_Event_Review__c anUpdatedAER : triggerNew)
		{
			anUpdatedAER.Name = currentCase[0].CaseNumber + '-' + (currentAERListSize + numberofAERsUpdated);
			numberOfAERsUpdated++;
		}
		
	}
	
	public static void sendUpdatesToPqm(List<Adverse_Event_Review__c> triggerNew){
		Set<String> relatedCases = new Set<String>();
		for(Adverse_Event_Review__c a : triggerNew){
			relatedCases.add(a.AER_Related_Case__c);
		}
		for (Id caseId: relatedCases){
			CaseTriggerHelper.isFromChild=true;
			CaseTriggerHelper.sendCaseToPqm(caseId);
		}
	}
	/* THIS LOGIC SHOULD HAPPEN WHEN THE CASE IS SYNCED WITH PQM NOT OTHER WAY AROUND
	public static void lockAllRelatedRecords(List<Adverse_Event_Review__c> triggerNew){
		Set<String> relatedCases = new Set<String>();
		for(Adverse_Event_Review__c a : triggerNew){
			relatedCases.add(a.AER_Related_Case__c);
		}
		for (Id caseId: relatedCases){
			CaseTriggerHelper.isFromChild=true;
			CaseTriggerHelper.lockAllRelatedRecords(caseId);
		}
	}*/
	
	public static void InternationalComplaintValidation(List<Adverse_Event_Review__c> triggerNew){
		Set<String> relatedCases = new Set<String>();
		for(Adverse_Event_Review__c a : triggerNew){
			relatedCases.add(a.AER_Related_Case__c);
		}
		Map <Id, Case> caseMap = new Map <Id, Case> ();
		for (Case c:  [SELECT Id, International_Complaint__c FROM Case WHERE Id IN :relatedCases]){
			caseMap.put(c.id,c);
		}
		
		for(Adverse_Event_Review__c aReview : triggerNew){
			Case validationCase = caseMap.get(aReview.AER_Related_Case__c);
			if(validationCase.International_Complaint__c){
				aReview.addError('Cannot add reviews to international complaints');
			}
		}
	}
	
	// DE859 -- AER records not updating case correctly for resending to PQM.
	// DE888 -- Update to update the Seriousness of the AER record with the parent's understanding
	public static void beforeUpdate(List<Adverse_Event_Review__c> triggerNew){
		List<Case> cases;
		Set<String> ids = new Set<String>();
		Set<String> idsThatAreSerious = new Set<String>();
		Set<String> idsThatAreNotSerious = new Set<String>();
		Set<String> idsThatAreNeitherSeriousNorNotSerious = new Set<String>();
		
		for (Adverse_Event_Review__c aer : triggerNew){
			if (aer.Assessment_List__c == 'Serious'){
				idsThatAreSerious.add(aer.AER_Related_Case__c);
			} else if (aer.Assessment_List__c == 'Potentially Serious'){
				idsThatAreSerious.add(aer.AER_Related_Case__c);
			} else if (aer.Assessment_List__c == 'Non-Serious'){
				idsThatAreNotSerious.add(aer.AER_Related_Case__c);
			} else if (aer.Assessment_List__c == 'N/A') {
				idsThatAreNotSerious.add(aer.AER_Related_Case__c);
			} else {
				idsThatAreNeitherSeriousNorNotSerious.add(aer.AER_Related_Case__c);
			}
			ids.add(aer.AER_Related_Case__c);
		}
		//Assessment_List__c -- Serious, Potentially Serious, Non-Serious, N/A, --None--
		cases = [SELECT Id, Agile_Status__c, Agile_Status_Description__c, Serious_Adverse_Event_Status__c FROM Case WHERE Id IN :ids];
		
		for (Case c: cases){
			if (idsThatAreSerious.Contains(c.Id)){
				c.Serious_Adverse_Event_Status__c = 'Yes';
			} else if (idsThatAreNotSerious.Contains(c.Id)) {
				c.Serious_Adverse_Event_Status__c = 'No';
			} else { // didn't find it before?
				c.Serious_Adverse_Event_Status__c = null;
			}
			
			c.Agile_Status__c = null;
			c.Agile_Status_Description__c = '';
		}
		
		update cases;
	}
}