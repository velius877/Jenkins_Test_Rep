@isTest
private class AccountSyncAddresses_HelperTest {

    static testMethod void myUnitTest() {
        TestDataSetupUtil.processCcMapping();
        Test.startTest();
        AccountSyncAddresses_Helper.generateAddressRecord(TestDataSetupUtil.setupAccount(), true, false, true);
        Test.stopTest();
        
    }
}