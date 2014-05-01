trigger TaskTrigger on Task (after insert, after update) {
	if (!NBTYUtils.bTriggersOff){
		if(trigger.isInsert && trigger.isAfter){
			TaskTriggerHelper.CopyToParent(trigger.new);
		}
		if(trigger.isUpdate && trigger.isAfter){
			TaskTriggerHelper.CopyToParent(trigger.new);
		}
	}
}