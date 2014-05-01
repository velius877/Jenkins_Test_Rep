/************************************* MODIFICATION LOG ********************************************************************************
*
* DESCRIPTION :  Bundle Trigger;  
*
*---------------------------------------------------------------------------------------------------------------------------------------
* DEVELOPER                     DATE                  REASON
*---------------------------------------------------------------------------------------------------------------------------------------
* Peter Nebel            04/12/2013          - Original Version
*
*                                                    
*/ 
trigger BundleTrigger on Bundle__c (before insert, before update) {
	if (!NBTYUtils.bTriggersOff){
		if (trigger.isBefore && trigger.isInsert){ 
			BundleTriggerHelper.validateMaxActiveBundles(trigger.new, trigger.oldMap); 
		}
	   
	  	if (trigger.isBefore && trigger.isUpdate){
	      BundleTriggerHelper.validateMaxActiveBundles(trigger.new, trigger.oldMap); 
	   }
	}
}