/* 
	TestCILController
	Test Class for CIL 
	------------------------------------------------------------------
	Author			|	Date		|	Description
	------------------------------------------------------------------
	Gary Alfrey   	|	4/16/2013	|	Created

*/

@isTest
private class TestCILController {

	static testMethod void myUnitTest() {
		TestDataSetupUtil.SetupCoreData(2);
		
		ApexPages.StandardController controller = new ApexPages.StandardController(TestDataSetupUtil.vwAcct);
		PageReference pageRef = Page.CIL_v2;		
		Test.setCurrentPage(pageRef);
		CILController ext = new CILController(controller);
		ext.selectedRecId = TestDataSetupUtil.order1.Id;
		Account a = [Select Id, Name, (Select Id, Name From Contacts), (Select Id, CaseNumber From Cases) From Account WHERE Id = :TestDataSetupUtil.vwAcct.Id];
		Case c = new Case();
		c.CTI_Search__c = '4195715968';
		c.Brand__c = 'Vitamin World';
		c.AccountId = a.Id;
		insert c;
		ext.getNowStr();
		ext.setRecId();
		ext.whoID = a.Contacts[0].Id;
		ext.whatID = TestDataSetupUtil.order1.Id;
		ext.callBothWhoWhat();
		ext.selectedRecId = TestDataSetupUtil.vwAcct.Id;
		ext.setRecId();
		ext.whoID = a.Contacts[0].Id;
		ext.whatID = TestDataSetupUtil.order1.Id;
		ext.selectedRecId = c.Id;
		ext.setRecId();
		ext.whoID = a.Contacts[0].Id;
		ext.whatID = c.Id;
		ext.save();
	}
}