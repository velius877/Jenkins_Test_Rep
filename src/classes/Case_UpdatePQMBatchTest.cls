@isTest
public with sharing class Case_UpdatePQMBatchTest {


  static testMethod void test_Case_UpdatePQMBatch_Async() {
    
      TestDataSetupUtil.SetupCoreData(2);
      Case_ICMTest.setupData();
      test.startTest();  
        Test.setMock(WebServiceMock.class, new MockResponse_CaseCreateService());
          Case_UpdatePQMBatch pqmB = new Case_UpdatePQMBatch();
      Id dbId = database.executeBatch(pqmB,1);
      test.stopTest();
    
      system.debug('-----------------------------------Assertion 1: ' + [select agile_status__c from Case where id =:Case_ICMTest.c.id].agile_status__c);
      //system.assert([select agile_status__c from Case where id =:Case_ICMTest.c.id].agile_status__c=='0');
    
  }
  
  static testMethod void test_Case_UpdatePQMBatch_Sync() {
    
      TestDataSetupUtil.SetupCoreData(2);
      Case_ICMTest.setupData();
      test.startTest();  
        Test.setMock(WebServiceMock.class, new MockResponse_CaseCreateService());
          soa_WebservicesClientUtil.sendCaseToPQM(Case_ICMTest.c.id);
      test.stopTest();
    
      system.debug('----------------------------------------Assertion 2: ' + [select agile_status__c from Case where id =:Case_ICMTest.c.id].agile_status__c);
      //system.assert([select agile_status__c from Case where id =:Case_ICMTest.c.id].agile_status__c=='0');
    
  }
  
  static testMethod void test_Case_UpdatePQMBatchSchedule() {

      test.startTest();
      CaseUpdate_PQMScheduler.setupSchedule();
      test.stopTest();
      
      
    
  }
}