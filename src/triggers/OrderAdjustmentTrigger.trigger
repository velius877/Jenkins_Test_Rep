/* 
 *  Trigger           : OrderAdjustmentTrigger 
 *  Author          : Pavan Jasthi - Acumen Solutions
 *  Creation         : 02/10/2014
 *  Description     : Trigger fires for various DML operations on Order adjustment object.
 *                      
*/

trigger OrderAdjustmentTrigger on Order_Adjustment__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
	
	if (trigger.isInsert) {
		if (trigger.isAfter) {
			OrderAdjustmentTriggerHelper.isAfterInsert(trigger.new);
		}
		if (trigger.isBefore) {
			OrderAdjustmentTriggerHelper.isBeforeInsert(trigger.new);
		}
	}
	if (trigger.isUpdate) {
		if (trigger.isAfter) {
			OrderAdjustmentTriggerHelper.isAfterUpdate(trigger.new, trigger.oldMap);
		}
		if(trigger.isBefore) {
			OrderAdjustmentTriggerHelper.isBeforeUpdate(trigger.new, trigger.oldMap);
		}
		
	}
	if(trigger.isDelete) {
		if (trigger.isAfter) {
			//OrderAdjustmentTriggerHelper.isAfterDelete(trigger.old, trigger.oldMap);
		}
	}
	
}