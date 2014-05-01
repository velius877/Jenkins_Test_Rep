/************************************* MODIFICATION LOG ********************************************************************************
*
* DESCRIPTION : OrderSummaryTriggerUtilitiesTest is a test class for OrderSummaryTriggerUtilities
*
*---------------------------------------------------------------------------------------------------------------------------------------
* DEVELOPER                     DATE                  REASON
*---------------------------------------------------------------------------------------------------------------------------------------
* Shivkant Vadlamani            04/15/2013          - Origininal Version
*
*                                                    
*/

@isTest
global class OrderSummaryTriggerUtilitiesTest 
{
    static testMethod void testGenerateObjects()
    {
    	testDataSetupUtil.SetupCoreData(2);
		OrderSummaryTriggerHelperTest.setupInboundOrderMapping();
		OrderSummaryTriggerHelperTest.setupWebStoresData();
    	Order_Summary__c OSRec = OrderSummaryTriggerHelperTest.setupOrderSummary();
    	
    	OrderSummaryTriggerHelper.processInboundOrderValues();    	
    	
        Account CustomerRec = (Account)OrderSummaryTriggerUtilities.GenerateObjects(OSRec, OrderSummaryTriggerHelper.InboundOrderValuesMap, 'Customer');
        
        System.assertEquals('ANDREA', CustomerRec.FirstName, 'Customer First Name should be ANDREA');
        System.assertEquals('FUST', CustomerRec.LastName, 'Customer First Name should be FUST');
        
        Orders__c OrderRec = (Orders__c)OrderSummaryTriggerUtilities.GenerateObjects(OSRec, OrderSummaryTriggerHelper.InboundOrderValuesMap, 'Order');
        System.assertEquals('0048888888', OrderRec.Sequence_Number__c, 'Order Sequence Number should be 0048888888');        
    }
    
    static testMethod void testMatchCodeDefinition(){
    	testDataSetupUtil.SetupCoreData(2);
    	
    	OrderSummaryTriggerUtilities.matchCodeDefinition(TestDataSetupUtil.acct);
    	OrderSummaryTriggerUtilities.matchCodeDefinition(TestDataSetupUtil.vwAcct);
    }
}