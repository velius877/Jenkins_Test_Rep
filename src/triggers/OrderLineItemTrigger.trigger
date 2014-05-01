trigger OrderLineItemTrigger on Order_Line_Items__c (after delete, before insert, after insert, after update, before delete, before update) {
	if (!NBTYUtils.bTriggersOff){
		if (trigger.isInsert&&trigger.isBefore){
			OrderLineItemTriggerHelper.countForInsert(trigger.new);
			OrderLineItemTriggerHelper.checkForRestrictions(trigger.new);
			OrderLineItemTriggerHelper.setFinalPrice(trigger.new);
			OrderLineItemTriggerHelper.checkOverridePrice(trigger.new);
		}
		if (trigger.isAfter&& trigger.isDelete){
			OrderLineItemTriggerHelper.countForDelete(trigger.old);
		}
		
		if(trigger.isBefore && trigger.isDelete){
			OrderLineItemTriggerHelper.ValidateBeforeDelete(trigger.old);
		}
		
		if(trigger.isAfter){
			if(trigger.isUpdate || trigger.isInsert){
				OrderLineItemTriggerHelper.setShippingStatus(trigger.new);
			}
		}
		
		if(trigger.isBefore && trigger.isUpdate){
			//OrderLineItemTriggerHelper.setShipCompleteStatus(trigger.new, null);
			OrderLineItemTriggerHelper.checkOverridePrice(trigger.new);
		}
	}
}