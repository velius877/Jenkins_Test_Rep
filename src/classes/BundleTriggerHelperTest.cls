@isTest
public  class BundleTriggerHelperTest {
	static testMethod void testBundles(){
		testDataSetupUtil.SetupCoreData(3);
		Configuration_Setting__c cs = new Configuration_Setting__c(Name='Active_Bundle_Limit', Value__c='2');
		insert cs;
		Bundle__c bund = new Bundle__c(Item__c = testDataSetupUtil.itemList[0].id, Active__c = true, Start_date__c=system.today().addDays(-1), end_Date__c = system.today().addDays(1));
		insert bund;
		Bundle__c bund2 = bund.clone(false);
		bund2.item__c= testDataSetupUtil.itemList[1].id;
		insert bund2;
		Bundle__c bund3 = bund.clone(false);
		bund3.item__c= testDataSetupUtil.itemList[2].id;
		boolean bFail = false;
		test.startTest();
		try {
			insert bund3;
		}
		catch (exception e){
			bFail=true;//It fails here because trying to insert an active when there is already 2 active
		}
		system.assert(bFail);
		bund3.active__c=false;
		insert bund3;
		bund3.active__c=true;
		 bFail = false;
		try {
			update bund3;
		}
		catch (exception e){
			bFail=true;//It fails here because trying to update to active when there is already 2 active
		}
		test.stopTest();
				system.assert(bFail);
	}
}