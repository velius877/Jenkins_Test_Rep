@isTest
public class OrderTriggerHelperTest {
	static testMethod void testPossibleFraudStatusChange(){
		//US236
		//INC703623 - make sure order is created using CSR profile
		testDataSetupUtil.SetupCoreData(2); //set up the basic data
		testDataSetupUtil.acct.possible_fraud__c=true; //flag the account as possible fraud
		update testDataSetupUtil.acct; //update dml
				test.startTest();
		testDataSetupUtil.order1.Order_Status__c = 'Pending Submission'; //submit the order
		update testDataSetupUtil.order1; //update dml for the order
		test.stopTest();
		//system.assert([select order_status__c from Orders__c where id =:testDataSetupUtil.order1.id].order_status__c=='Internal Review');//verify it was automatically set to internal review
		
	}
	
	static testMethod void testBatchAggregate(){
		testDataSetupUtil.SetupCoreData(2); //set up the basic data
		testDataSetupUtil.order1.Batch_Number__c='1234';
		testDataSetupUtil.order1.payment_value__c = 12;
		testDataSetupUtil.order1.Order_Total__c=12;
		test.startTest();
		
		update testDataSetupUtil.order1; //update dml for the order
		system.assert([select count() from Batch__c ]==1);
			testDataSetupUtil.order1.Batch_Number__c='1235';
		testDataSetupUtil.order1.payment_value__c = 12;
		testDataSetupUtil.order1.Order_Total__c=12;

		update testDataSetupUtil.order1; //update dml for the order
		
		test.stopTest();
					List <Batch__c> batchList = [select id, Aggregate_Value__c from Batch__c order by Batch_number__c];
					system.debug(batchList);
				system.assertEquals(1,batchList.size()); 
				system.assertEquals(12.00,batchList[0].Aggregate_Value__c);	
	
		
	}
	
	static testMethod void testFormatAddressData(){
		testDataSetupUtil.SetupCoreData(2); 
		
		test.startTest();
		
		for (Address__c a: testDataSetupUtil.addressList){
			orderTriggerHelper.formatAddressData(a);
		}
		
		test.stopTest();
	}
	
	static testMethod void testSetDefaultShippingMethod(){
		testDataSetupUtil.SetupCoreData(2); 
		
		test.startTest();
		List<Orders__c> orders = new List<Orders__c>();
		
		orders.add(testDataSetupUtil.order1);
		
		orderTriggerHelper.setDefaultShippingMethod(orders);
		
		test.stopTest();
	}

	static testMethod void testValidateBeforeDelete(){
		testDataSetupUtil.SetupCoreData(2);
		
		test.startTest();
		List<Orders__c> orders = new List<Orders__c>();
		testDataSetupUtil.order1.Order_Submitted__c = true;
		update testDataSetupUtil.order1;
		
		orders.add(testDataSetupUtil.order1);
		OrderTriggerHelper.isDeleteAllowed = false;
		
		OrderTriggerHelper.ValidateBeforeDelete(orders);
		
		test.stopTest();
	}
}