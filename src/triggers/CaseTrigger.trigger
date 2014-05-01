trigger CaseTrigger on Case (before insert, before update) {
	if (!NBTYUtils.bTriggersOff){
		if(trigger.isBefore && trigger.isInsert){
			CaseTriggerHelper.beforeInsert(trigger.new);
		}
		
		if(trigger.isBefore && trigger.isUpdate){
			CaseTriggerHelper.beforeUpdate(trigger.new, trigger.oldMap);
		}
	}
}