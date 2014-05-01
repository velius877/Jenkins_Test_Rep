@isTest
private class ConvertToProductComplaintTest {
	public static Case c;
	
	public static void setupData(){
		c = new Case(customer__c =TestDataSetupUtil.acct.id );
    	string selectedRecordType = 'Product_Complaint';
       	RecordType rt = [SELECT Id, DeveloperName FROM RecordType WHERE developerName = :selectedRecordType];
    	c.RecordTypeId = rt.id;
    	CaseTriggerHelper.isFromChild=true;
		insert c;
		CaseTriggerHelper.isFromChild=false;
	}
	
	static testMethod void initConvertToProductComplaint()
	{
		TestDataSetupUtil.SetupCoreData(2);
    	setupData();
    	ApexPages.StandardController controller = new ApexPages.StandardController(c);
   		PageReference pageRef = Page.CaseClone;
    	Test.setCurrentPage(pageRef);
    	Test.startTest();
    	ConvertToProductComplaint cloneController = new ConvertToProductComplaint(controller);
    	cloneController.init();
	}
}