trigger AERTrigger on Adverse_Event_Review__c (before insert, before update, before delete) {
	
	if(trigger.isBefore && trigger.isInsert) {
		AERTriggerHelper.InternationalComplaintValidation(trigger.new);
		AERTriggerHelper.countForNameModification(trigger.new);
	}
	
	// DE870 before delete can only have access to trigger.old
	if(trigger.isBefore && trigger.isDelete) {
		AERTriggerHelper.beforeDelete(trigger.old);
	}
	
	// DE859 -- AER records not updating case correctly for resending to PQM.
	if (trigger.isBefore && trigger.isUpdate) {
		AERTriggerHelper.beforeUpdate(trigger.new);
	}
}