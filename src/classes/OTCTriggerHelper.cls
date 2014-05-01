public with sharing class OTCTriggerHelper {
	
	public static void BeforeDelete(List<Other_Medications_OTC__c> triggerNew)
	{
		List<String> otcRelatedCases = New List<String>();
		
		for(Other_Medications_OTC__c aRelatedId : triggerNew)
		{
			otcRelatedCases.add(aRelatedId.OTC_Related_Case__c);
		}
		
		List<Case> parentCases = [SELECT Id, Agile_Status__c FROM Case WHERE Id IN :otcRelatedCases];
		
		for(Case aParent : parentCases)
		{
			if(aParent.Agile_Status__c == '0')
			{
				aParent.addError('The Nutrition Review attched to the parent case ' + aParent.Id + ' is unable to be deleted because the record was already synced with PQM');
			}
		}
		
		for(Other_Medications_OTC__c aReview : triggerNew)
		{
			if(aReview.Synced_With_PQM__c == 'Yes')
			{
				aReview.addError('The Nutrition Review ' + aReview.Name + ' is synced with PQM and cannot be deleted.');
			}
		}
	}

}