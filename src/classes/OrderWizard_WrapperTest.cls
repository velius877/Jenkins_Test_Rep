@isTest
private class OrderWizard_WrapperTest 
{
	static testMethod void testOrderWrapper()
	{
		TestDataSetupUtil.SetupCoreData(1);
		
		Test.startTest();  
		
			OrderWizard_Wrapper OWWrap = new OrderWizard_Wrapper(TestDataSetupUtil.order1);
						
			System.assert(OWWrap.newOrder.Sequence_Number__c == '2166549802', 'This is not a valid order');
			System.assert(OWWrap.selectedShippingAddress == OWWrap.newOrder.Ship_To_Address__c);
			
		Test.stopTest();  
	}
	
	static testMethod void testUndoAppliedCredit(){
		testDataSetupUtil.SetupCoreData(2);
		
		OrderWizard_Wrapper wrap = new OrderWizard_Wrapper(testDataSetupUtil.order1);
		
		Test.startTest();
		
		wrap.newOrder.Credit_Applied__c = true;
		wrap.newOrder.Credit_Amount_Applied__c = 27.00;
		update wrap.newOrder;
		
		wrap.UndoAppliedCredit();
		
		Test.stopTest();
	}
	
	static testMethod void testGetCreditCardForType(){
		testDataSetupUtil.SetupCoreData(2);
		
		OrderWizard_Wrapper wrap = new OrderWizard_Wrapper(testDataSetupUtil.order1);
		
		Test.startTest();
		
		wrap.newOrder.Credit_Applied__c = true;
		wrap.newOrder.Credit_Amount_Applied__c = 27.00;
		update wrap.newOrder;
		
		wrap.getCreditCardForType(1);
		wrap.getCreditCardForType(2);
		wrap.getCreditCardForType(3);
		wrap.getCreditCardForType(4);
		wrap.getCreditCardForType(5);
		
		Test.stopTest();
	}
	
	static testMethod void testPaymentProfile(){
		testDataSetupUtil.SetupCoreData(2);
		
		OrderWizard_Wrapper wrap = new OrderWizard_Wrapper(testDataSetupUtil.order1);
		
		Test.startTest();
		
		wrap.newOrder.Credit_Applied__c = true;
		wrap.newOrder.Credit_Amount_Applied__c = 27.00;
		update wrap.newOrder;
		
		OrderWizard_Wrapper.PaymentProfile pp = new OrderWizard_Wrapper.PaymentProfile();
		
		Test.stopTest();
	}
}