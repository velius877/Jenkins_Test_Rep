trigger AddressTrigger on Address__c (before insert,before update, before delete,after insert,after update) {
	if (!NBTYUtils.bTriggersOff){		
		if (trigger.isBefore && trigger.isInsert){
			AddressTriggerHelper.validateAddressLength(trigger.new);
			AddressTriggerHelper.addressBeforeInsertTrigger(trigger.new);
		}
		
		if (trigger.isBefore && trigger.isUpdate){
			AddressTriggerHelper.validateAddressLength(trigger.new);
			AddressTriggerHelper.addressBeforeUpdateTrigger(trigger.oldMap, trigger.newMap); 
	   	}
		
	   	if (trigger.isAfter && trigger.isInsert){
			AddressTriggerHelper.addressAfterInsertTrigger(trigger.new);
		}
		
	  	if (trigger.isAfter && trigger.isUpdate){
			AddressTriggerHelper.addressAfterUpdateTrigger(trigger.newMap,trigger.oldMap);
	   	}
			 
	   	if (trigger.isBefore && trigger.isDelete){
			AddressTriggerHelper.addressBeforeDeleteTrigger(trigger.old);
		}
	}
}