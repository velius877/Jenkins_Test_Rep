@isTest
public class CaseDetailTest {
	
	public static Case c;

	public static void setupData()
	{
		c = new Case(customer__c =TestDataSetupUtil.acct.id );
    	string selectedRecordType = 'Product_Complaint';
       	RecordType rt = [SELECT Id, DeveloperName FROM RecordType WHERE developerName = :selectedRecordType];
    	c.RecordTypeId = rt.id;
    	CaseTriggerHelper.isFromChild=true;
		insert c;
	}
	
	static testMethod void testingCaseDetail()
	{
		TestDataSetupUtil.SetupCoreData(2);
	    setupData();
	    ApexPages.StandardController controller = new ApexPages.StandardController(c);
	    PageReference pageRef = Page.CaseDetail;
	    Test.setCurrentPage(pageRef);
	    test.startTest();
	    CaseDetail caseDetailController = new CaseDetail(controller);
	    
	    caseDetailController.c.Complaint_Type__c = 'Class I';
	    caseDetailController.c.Category__c = 'Class I Packaging';
	    update c;
	    caseDetailController.init();
	    
	    caseDetailController.c.Complaint_Type__c = 'Class II Non-Illness';
	    caseDetailController.c.Category__c = 'Choking';
	    update c;
	    caseDetailController.init();
	    
	    caseDetailController.c.Complaint_Type__c = 'Class II Illness';
	    caseDetailController.c.Category__c = 'Eye Disorder';
	    update c;
	    caseDetailController.init();
	    
	    caseDetailController = new CaseDetail();
	    test.stopTest();
	}
	
	// Test case history functionality.
	static testMethod void getSomeObjectHistory_Test(){
		TestDataSetupUtil.SetupCoreData(2);
	    setupData();
	    ApexPages.StandardController controller = new ApexPages.StandardController(c);
	    PageReference pageRef = Page.CaseDetail;
	    Test.setCurrentPage(pageRef);
	    test.startTest();
	    CaseDetail caseDetailController = new CaseDetail(controller);
	    c.Category__c = 'Class I Packaging';
	    update c;
	    caseDetailController.getSomeObjectHistory(c.Id);
	    test.stopTest();
	}
	
	static testMethod void someObjectHistory_Test(){
		test.startTest();
		CaseDetail.SomeObjectHistory soh = new CaseDetail.SomeObjectHistory(new CaseHistory());
		String actionFormat = soh.ActionFormat;
		soh = new CaseDetail.SomeObjectHistory(new CaseHistory());
		test.stopTest();
	}
}