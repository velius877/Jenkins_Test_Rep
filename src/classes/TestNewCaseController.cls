@isTest
private class TestNewCaseController {

	static testMethod void myUnitTest1() {
		Case c = new Case();
       TestDataSetupUtil.SetupCoreData(2);
       Account acct = testDataSetupUtil.acct;
		
		RecordType rt = [SELECT Id FROM RecordType WHERE DeveloperName = 'Pre_Case' AND sObjectType = 'Case'];
		c.RecordTypeId = rt.Id;
		ApexPages.StandardController controller = new ApexPages.StandardController(c);
		PageReference pageRef = Page.NewCase;
		pageRef.getParameters().put('AccountId', acct.Id);
		Test.setCurrentPage(pageRef);
		NewCaseController ext = new NewCaseController(controller);
	//	ext.redirect();
	}
}