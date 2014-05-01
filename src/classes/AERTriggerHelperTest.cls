@isTest	
public class AERTriggerHelperTest {
	
	public static Adverse_Event_Review__c aer;
	public static Case c;
	public static List<Adverse_Event_Review__c> pqmUpdate;
	
	public static void setupData()
	{
		c = new Case();
    	string selectedRecordType = 'Product_Complaint';
       	RecordType rt = [SELECT Id, DeveloperName FROM RecordType WHERE developerName = :selectedRecordType];
    	c.RecordTypeId = rt.id;
    	c.International_Complaint__c = false;
    	CaseTriggerHelper.isFromChild=true;
		insert c;
		
		aer = new Adverse_Event_Review__c();
		aer.AER_Related_Case__c = c.Id;
		pqmUpdate = new List<Adverse_Event_Review__c>();
		pqmUpdate.add(aer);
		insert aer;
	}

	static testMethod void AERTriggerHelperTest()
	{
		
		test.startTest();
		setupData();
		aer.Synced_With_PQM__c = 'No';
		update aer;
		//delete aer;
		test.stopTest();
	}
	
	// Test the new before update seriousness items.
	static testMethod void beforeUpdate_Test(){
		test.startTest();
		setupData();
		aer.Assessment_List__c = 'Serious';
		aer.Synced_With_PQM__c = 'No';
		update aer;
		aer.Assessment_List__c = 'Potentially Serious';
		aer.Synced_With_PQM__c = 'No';
		update aer;
		aer.Assessment_List__c = 'Non-Serious';
		aer.Synced_With_PQM__c = 'No';
		update aer;
		aer.Assessment_List__c = 'N/A';
		aer.Synced_With_PQM__c = 'No';
		update aer;
		aer.Assessment_List__c = null;
		aer.Synced_With_PQM__c = 'No';
		update aer;
		test.stopTest();
	}
	
	static testMethod void beforeDelete_Test(){
		test.startTest();
		setupData();
		try {
			c.Agile_Status__c = '0';
		update c;
		} catch (NBTYException e) {
			System.debug(e);
		}
		try {
			aer.Synced_With_PQM__c = 'Yes';
			update aer;
		} catch (NBTYException e) {
			System.debug(e);
		}
		delete aer;
		test.stopTest();
	}
}