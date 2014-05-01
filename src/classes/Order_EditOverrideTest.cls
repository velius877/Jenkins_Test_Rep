@isTest
public  class Order_EditOverrideTest {

	static testMethod void test_EditOverride(){
		testDataSetupUtil.SetupCoreData(2);
		testDataSetupUtil.order1.Order_Status__c = 'Open';
        update testDataSetupUtil.order1;
		PageReference pref = Page.Order_EditOverride;
        Test.setCurrentPage(pref);
        test.startTest();
		ApexPages.StandardController con = new ApexPages.StandardController(testDataSetupUtil.order1);
        Order_EditOverride controller = new Order_EditOverride(con);
        system.assert(Order_EditOverride.isEditableOrder(testDataSetupUtil.order1));
        system.assert(!Order_EditOverride.isWipeOrder(testDataSetupUtil.order1));
      //  Orders__c ord = controller.createOrder(testDataSetupUtil.acct.id);
      ApexPages.currentPage().getParameters().put('CustId',testDataSetupUtil.acct.id);
        controller.isNew = true;
        controller.redirect();
        test.stopTest();	
	}
	
	static testMethod void test_EditOverride_SC(){
		testDataSetupUtil.SetupCoreData(2);
		testDataSetupUtil.order1.Order_Status__c = 'Shipped/Complete';
        update testDataSetupUtil.order1;
		PageReference pref = Page.Order_EditOverride;
        Test.setCurrentPage(pref);
        test.startTest();
		ApexPages.StandardController con = new ApexPages.StandardController(testDataSetupUtil.order1);
        Order_EditOverride controller = new Order_EditOverride(con);
        system.assert(!Order_EditOverride.isEditableOrder(testDataSetupUtil.order1));
        system.assert(!Order_EditOverride.isWipeOrder(testDataSetupUtil.order1));
        controller.isClone = true;
        controller.redirect();
        test.stopTest();
	}
}