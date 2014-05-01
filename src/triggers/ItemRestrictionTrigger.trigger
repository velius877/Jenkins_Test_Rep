trigger ItemRestrictionTrigger on Item_Restriction__c (before insert) {
	if (!NBTYUtils.bTriggersOff){
		if (trigger.isBefore){
			ItemRestrictionHelper.setItemOnRestriction(trigger.new);
		}
	}
}