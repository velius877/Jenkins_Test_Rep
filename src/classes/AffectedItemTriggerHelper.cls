public with sharing class AffectedItemTriggerHelper {
	
	public static void BeforeDelete(List<Affected_Item__c> triggerNew)
	{
	
		List<String> affectedItemsRelatedCases = New List<String>();
		
		system.debug('+++++++++++' + triggerNew);
		for(Affected_Item__c aRelatedId : triggerNew)
		{
			affectedItemsRelatedCases.add(aRelatedId.Case__c);
		}
		
		List<Case> parentCases = [SELECT Id, Agile_Status__c FROM Case WHERE Id IN :affectedItemsRelatedCases];
		
		for(Case aParent : parentCases)
		{
			if(aParent.Agile_Status__c == '0')
			{
				aParent.addError('The Nutrition Review attched to the parent case ' + aParent.Id + ' is unable to be deleted because the record was already synced with PQM');
			}
		}
		
		for(Affected_Item__c aReview : triggerNew)
		{
			if(aReview.Synced_With_PQM__c == 'Yes')
			{
				aReview.addError('The Nutrition Review ' + aReview.Name + ' is synced with PQM and cannot be deleted.');
			}
		}
	}

}