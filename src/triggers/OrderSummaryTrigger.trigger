/************************************* MODIFICATION LOG ********************************************************************************
*
* DESCRIPTION : Order Summary Trigger that executes after insert operation
*
*---------------------------------------------------------------------------------------------------------------------------------------
* DEVELOPER                     DATE                  REASON
*---------------------------------------------------------------------------------------------------------------------------------------
* Shivkant Vadlamani            03/25/2013          - Original Version
*
*                                                    
*/

trigger OrderSummaryTrigger on Order_Summary__c (after insert) 
{
	if (!NBTYUtils.bTriggersOff){
		// To create Customer, Order, Order Line Items, Billing and Shipping Addresses after Order Summary record is inserted
	    if(trigger.isAfter && trigger.isInsert)
	    {
	        OrderSummaryTriggerHelper.ProcessOrderSummaryAfterInsert(trigger.new);
	    }
	}
}