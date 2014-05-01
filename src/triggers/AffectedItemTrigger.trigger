trigger AffectedItemTrigger on Affected_Item__c (before delete) {

	if(trigger.isBefore && trigger.isDelete)
	{
		if(trigger.new != null)
		{
			AffectedItemTriggerHelper.beforeDelete(trigger.new);
		}
	}
}