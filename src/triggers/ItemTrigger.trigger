/************************************* MODIFICATION LOG ********************************************************************************
*
* DESCRIPTION :  Item Trigger; writes to Price object for any new items/price changes
*
*---------------------------------------------------------------------------------------------------------------------------------------
* DEVELOPER                     DATE                  REASON
*---------------------------------------------------------------------------------------------------------------------------------------
* Peter Nebel            04/12/2013          - Original Version
*
*                                                    
*/
trigger ItemTrigger on Item__c (before insert, after insert, before update, after update) {
	if (!NBTYUtils.bTriggersOff){	
		 if (trigger.isBefore && trigger.isInsert){
		 	ItemTriggerHelper.SetupItemData(trigger.new);
		 	ItemTriggerHelper.updateBackorderStatus(trigger.new,null);
		 }
		  if (trigger.isAfter && trigger.isInsert){
		 	ItemTriggerHelper.ProcessSubstituteItemLinks(trigger.newMap, null);
		 }
		  if (trigger.isBefore && trigger.isUpdate){
		 	ItemTriggerHelper.SetupItemData(trigger.new);
		 	ItemTriggerHelper.updateBackorderStatus(trigger.new,trigger.oldMap);
		 }
		   if (trigger.isAfter && trigger.isUpdate){
		 	ItemTriggerHelper.ProcessSubstituteItemLinks(trigger.newMap, trigger.oldMap);
		 }
	}
}