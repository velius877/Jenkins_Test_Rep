/*
 * Author       : Pavan Jasti, Acumen
 * Class        : OrderAdjustmentController 
 * Date         : 02/04/2014
 * Description  : Test class for OrderAdjustmentTriggerHelper.cls
*/
@isTest
public with sharing class OrderAdjustmentTriggerHelperTest {
	 
	 static Order_Adjustment__c testOA;
	 static Orders__c testorder;
	 
	 public static void setupTestData(){
        TestDataSetupUtil.SetupCoreData(1);
        testOA = TestDataSetupUtil.setupOrderAdjustment(null,TestDataSetupUtil.order1.Id,TestDataSetupUtil.acct.Id);
        testorder = TestDataSetupUtil.order1;
     } 
      
     testMethod static void testOrderStatusupdates(){
        setupTestData();
        RecordType miscRecType = [SELECT Id FROM RecordType WHERE DeveloperName = 'Misc_Charge' AND sObjectType = 'Order_Adjustment__c' AND IsActive = true limit 1];
        Test.startTest();
            testOA.RecordTypeId = miscRecType.Id ;
        	testOA.status__c = 'Processed';
        	testOA.Payment_Method__c = 'Credit Card';
        	update testOA;
        	testOA.status__c = 'Customer Paid';
        	testOA.Payment_Method__c = 'Cash';
        	update testOA;
        	testorder = [Select Id,Order_status__c from orders__c where Id=:testorder.id];
        	System.assertEquals(testorder.Order_Status__c, 'Pending Submission');
        	
        Test.stopTest();
     }
     
     testMethod static void testRelatedOARecords(){
        setupTestData();
        // Credit creation
        Test.startTest();
            testOA.Refund_or_Misc_Amount__c = 10.00;
            testOA.Payment_Method__c = 'Customer Credit';
            testOA.status__c = 'Approved';
        	update testOA;
            system.assertequals([select count() from Credit__c where Account__c =:testOA.Customer__c], 1);     	
        Test.stopTest();
     }
      
}