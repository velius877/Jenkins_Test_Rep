trigger OTCTrigger on Other_Medications_OTC__c (before delete) {
	
	if(trigger.isBefore && trigger.isDelete)
	{
		if(trigger.new != null)
		{
			OTCTriggerHelper.BeforeDelete(trigger.new);
		}
	}
}