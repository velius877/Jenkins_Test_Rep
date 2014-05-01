@isTest
public class AffectedItemTriggerHelperTest {
	
	public static Case c;
	public static Affected_Item__c AI;
	public static List<Affected_Item__c> AiList;
	public static List<Item__c> newItem;
	
	public static void setupData()
	{
		c = new Case();
		AI = new Affected_Item__c();
		newItem = new List<Item__c>();
    	string selectedRecordType = 'Product_Complaint';
       	RecordType rt = [SELECT Id, DeveloperName FROM RecordType WHERE developerName = :selectedRecordType];
    	c.RecordTypeId = rt.id;
    	c.International_Complaint__c = false;
    	CaseTriggerHelper.isFromChild=true;
		insert c;
		newItem = testDataSetupUtil.setupItems(1);
		AI.Item__c = newItem[0].Id;
		AI.Case__c = c.Id;
		AI.Product__c = newItem[0].Product_ID__c;
		AI.Brand__c = 'Putitans Pride';
		AI.Bulk_Description__c = 'Test';
		AI.Bulk_Number__c = '1231242243';
		AI.Expiration_Date__c = '11/08/2020';
		AI.Formula_Revision__c = 'Test';
		AI.Item_Number__c = newItem[0].Product_Number__c;
		AI.Label_Number__c = '2387461827';
		AI.Label_Revision_Code__c = 'wiurg2r';
		AI.Lot_Number_Sequence__c = '14241431';
		AI.Manufacturing_Site__c = 'Orlando';
		AI.NBTY_Lot__c = '234234342634';
		AI.Oracle_Bulk_Number__c = '345464113';
		AI.Oracle_Product_Number__c = '6784323577';
		AI.Packaging_Site__c = 'Orlando';
		AI.Product_Suffix__c = '12ojty5';
		AI.sku__c = '2343251';
		AI.Synced_With_PQM__c = 'No';
		AI.Vendor_Lot__c = '343452';
		AiList = new List<Affected_Item__c>();
		AiList.add(AI);
		insert AI;
	}
	
	static testMethod void beforeDeleteHelperTest()
	{
		setupData();
		test.startTest();
		AffectedItemTriggerHelper.BeforeDelete(AiList);
		test.stopTest();
	}
	
	static testMethod void beforeDeleteTriggerTest()
	{
		setupData();
		test.startTest();
		delete AI;
		test.stopTest();
	}
}