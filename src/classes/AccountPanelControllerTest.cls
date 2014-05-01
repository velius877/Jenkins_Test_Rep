@isTest
public with sharing class AccountPanelControllerTest {
	public static void setupData(){
		testDataSetupUtil.SetupCoreData(2);
	}
	
	public static testMethod void testPayprofile(){
		Test.setMock(WebServiceMock.class, new MockControllerCallout());
			setupData();
	    	testDataSetupUtil.acct.payment_profile_id__c='123';
			update testDataSetupUtil.acct;
			PageReference  p = Page.AccountPanel;
			Test.setCurrentPage(p); 
			test.startTest();
			ApexPages.currentPage().getParameters().put('Id', testDataSetupUtil.acct.id);
  		    ApexPages.StandardController sc = new ApexPages.StandardController(testDataSetupUtil.acct);
  		     AccountPanelController panelController = new AccountPanelController(sc);
  		     panelController.paymentCallout();
  		system.assert(panelController.payprofileController.lstPaymentTokens[0]!=null);
	}
	
	
	public static testMethod void testLoyaltyPanel(){
		Test.setMock(WebServiceMock.class, new MockResponse_Loyalty_RetrieveInfo());
			setupData();
	    	testDataSetupUtil.vwAcct.VW_Passport_Number__c='123';
	    	testDataSetupUtil.vwAcct.payment_profile_id__c=null;
			update testDataSetupUtil.vwAcct;
			PageReference  p = Page.AccountPanel;
			Test.setCurrentPage(p); 
			test.startTest();
			ApexPages.currentPage().getParameters().put('Id', testDataSetupUtil.vwAcct.id);
  		    ApexPages.StandardController sc = new ApexPages.StandardController(testDataSetupUtil.vwAcct);
  		     AccountPanelController panelController = new AccountPanelController(sc);
  		     panelController.init();
  		     	system.assert(panelController.loyaltyController.response.retrieveInfoSuccessResponse.pointsToDate!=null);
	}
	
	public static testMethod void testHistoryPanel(){
		    Test.setMock(WebServiceMock.class, new OrderHistoryMockTest());
			setupData();
	    	testDataSetupUtil.acct.payment_profile_id__c='123';
			update testDataSetupUtil.acct;
			PageReference  p = Page.AccountPanel;
			Test.setCurrentPage(p); 
			test.startTest();
			ApexPages.currentPage().getParameters().put('Id', testDataSetupUtil.acct.id);
  		    ApexPages.StandardController sc = new ApexPages.StandardController(testDataSetupUtil.acct);
  		     AccountPanelController panelController = new AccountPanelController(sc);
  		     panelController.ohCallout();
  		     system.assert(panelController.ohController.submittedOrderWrapList!=null);
	}
	

	
}