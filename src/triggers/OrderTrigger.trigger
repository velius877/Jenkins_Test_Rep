/************************************* MODIFICATION LOG ********************************************************************************
*
* DESCRIPTION : Order Trigger that executes before insert operation
*
*---------------------------------------------------------------------------------------------------------------------------------------
* DEVELOPER					 DATE				  REASON
*---------------------------------------------------------------------------------------------------------------------------------------
* Shivkant Vadlamani			04/22/2013		  - Original Version
*
* Latha Davuluri				05/25/2013		  - Added a check for Orders returned.   
*
* Latha Davuluri				05/29/2013		  - Failed orders sent to Brand-specific BOQ											   
*/
trigger OrderTrigger on Orders__c (before insert, before update, before delete, after insert, after update) {
	if (trigger.isInsert){
		if (trigger.isBefore) OrderTriggerHelper.isBeforeInsert(trigger.new);
		if (trigger.isAfter)		OrderTriggerHelper.isAfterInsert(trigger.new);
	}
	if (trigger.isUpdate){
		if (trigger.isBefore){
			OrderTriggerHelper.isBeforeUpdate(trigger.new, trigger.oldMap); 
			//OrderLineItemTriggerHelper.setShipCompleteStatus(null,trigger.new);
			
		}
		if (trigger.isAfter){
			OrderTriggerHelper.isAfterUpdate(trigger.new, trigger.oldMap);
			//OrderTriggerHelper.setStaticUnitPrice(trigger.new, trigger.old); PN commented out per PTN
		}
	}
	if(trigger.isBefore && trigger.isDelete){
		OrderTriggerHelper.ValidateBeforeDelete(trigger.old);
	}
}