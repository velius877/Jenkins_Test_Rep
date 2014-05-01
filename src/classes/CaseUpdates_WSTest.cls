@isTest
public class CaseUpdates_WSTest {

	public static Case c;
	public static CaseUpdates_ComplexTypes.CaseUpdate newCaseUpdate;
	
	public static void setupData()
	{
		c = new Case();
    	string selectedRecordType = 'Product_Complaint';
       	RecordType rt = [SELECT Id, DeveloperName FROM RecordType WHERE developerName = :selectedRecordType];
    	c.RecordTypeId = rt.id;
    	c.International_Complaint__c = false;
    	CaseTriggerHelper.isFromChild=true;
		insert c;
		c = [select caseNumber, id from Case where id=:c.id];
	}
	
	static testMethod void testCaseUpdateWS()
	{
		setupData();		
		CaseUpdates_ComplexTypes.serviceResponse resp;
		newCaseUpdate = new CaseUpdates_ComplexTypes.CaseUpdate();
		newCaseUpdate.caseNumber = c.CaseNumber;
		newCaseUpdate.status = 'Closed';
		
		test.startTest();
		resp = CaseUpdates_WS.processCaseUpdate(newCaseUpdate);
		test.stopTest();
		system.assert(resp.successMessage!=null);
	}
	
	static testMethod void testCaseUpdateWS_Error()
	{
		setupData();		
		 CaseUpdates_ComplexTypes.serviceResponse resp;
		newCaseUpdate = new CaseUpdates_ComplexTypes.CaseUpdate();
		newCaseUpdate.caseNumber = c.CaseNumber+'jgk';//junk to test failure
		newCaseUpdate.status = 'Closed';
		
		test.startTest();
		resp= CaseUpdates_WS.processCaseUpdate(newCaseUpdate);
		test.stopTest();
		system.assert(resp.errorMessage!=null);
	}
}