trigger NRTrigger on Nutrition_Review__c (before insert, before delete, before update) {
		
	if(trigger.isBefore && trigger.isInsert) {
		NRTriggerHelper.InternationalComplaintValidation(trigger.new);
		NRTriggerHelper.countForNameModification(trigger.new);
	}
	
	// DE870 before delete can only have access to trigger.old
	if (trigger.isBefore && trigger.isDelete) {
		NRTriggerHelper.beforeDelete(trigger.old);
	}
	
	// DE859 -- NR records not updating case correctly for resending to PQM.
	if (trigger.isBefore && trigger.isUpdate) {
		NRTriggerHelper.beforeUpdate(trigger.new);
	}
}