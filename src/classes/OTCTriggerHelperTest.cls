@isTest
public class OTCTriggerHelperTest {

	public static Case c;
	public static Other_Medications_OTC__c newOTC;
	public static List<Other_Medications_OTC__c> OTCList;

	public static void setupData()
	{
		c = new Case();
		OTCList = new List<Other_Medications_OTC__c>();
		newOTC = new Other_Medications_OTC__c();
    	string selectedRecordType = 'Product_Complaint';
       	RecordType rt = [SELECT Id, DeveloperName FROM RecordType WHERE developerName = :selectedRecordType];
    	c.RecordTypeId = rt.id;
    	c.International_Complaint__c = false;
    	CaseTriggerHelper.isFromChild=true;
		insert c;
		newOTC.OTC_Related_Case__c = c.Id;
		insert newOTC;
		OTCList.add(newOTC);
	}
	
	static testMethod void OTCTriggerHelperTest()
	{
		setupData();
		test.startTest();
		OTCTriggerHelper.BeforeDelete(OTCList);
		test.stopTest();
	}
	
	static testMethod void OTCTriggerTest()
	{
		setupData();
		test.startTest();
		delete newOTC;
		test.stopTest();
	}
}