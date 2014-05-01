@isTest
public with sharing class AccountSearchandAddControllerTest {
	
testmethod static void testSearchforResult(){	
  PageReference pageRef = Page.AccountQuickSearchAdd;
  TestDataSetupUtil.setupAccount();
  Test.setCurrentPage(pageRef);
  Account acct = new Account();
  ApexPages.StandardController sc = new ApexPages.StandardController(acct);
  AccountSearchAddController cont = new AccountSearchAddController(sc);
  cont.inputFirstName = 'Jane';
  cont.inputLastName = 'Doe';
  cont.inputEmail = 'jDoe@test.com';
  cont.inputAS400 = '123456';
  //cont.inputPhone = '7031001000';
  test.startTest();
  cont.doSearch();
  cont.doAdd();
  system.assert(cont.searchResult.size() > 0);
  test.stopTest();
  
}

testmethod static void testSearchforNegativeResult(){	
  PageReference pageRef = Page.AccountQuickSearchAdd;
  TestDataSetupUtil.setupAccount();
  Test.setCurrentPage(pageRef);
  Account acct = new Account();
  ApexPages.StandardController sc = new ApexPages.StandardController(acct);
  AccountSearchAddController cont = new AccountSearchAddController(sc);
  AccountSearchAddController cont1 = new AccountSearchAddController(sc);
  cont.inputFirstName = 'xx';
  cont.inputLastName = 'xx';
  cont.inputEmail = 'xx';
  cont.inputPhone = 'xx';
  cont.inputAS400 = 'XX';
  cont1.inputFirstName = 'Jane';
  cont1.inputLastName = 'Doe';
  cont1.inputEmail = 'Jane.Doe@mail.com';
  cont1.inputPhone = '7031001000';
  cont1.inputAS400 = '9999999999';
  test.startTest();
  cont.doSearch();
  cont1.doSearch();   
  test.stopTest();
  
}

testmethod static void testSearchforCreate(){	
  PageReference pageRef = Page.AccountQuickSearchAdd;
  TestDataSetupUtil.setupAccount();
  Test.setCurrentPage(pageRef);
  Account acct1 = new Account();
  ApexPages.StandardController sc = new ApexPages.StandardController(acct1);
  AccountSearchAddController cont = new AccountSearchAddController(sc);
  List<SelectOption> lst = cont.getRecordTypeOptions();

  cont.acct.PersonEmail = 'TestFirst.TestLast@email.com';
  cont.acct.Phone = '7031001000';
  cont.acct.LastName = 'TestLastName';
  cont.acct.FirstName = 'TestFirstname';
  cont.RecordTypeId = lst[0].getvalue();
  test.startTest();
  PageReference prAccount = cont.doSave();
  cont.doCancel();
  test.stopTest();
}

testmethod static void testSearchforNullCreate(){	
  PageReference pageRef = Page.AccountQuickSearchAdd;
  TestDataSetupUtil.setupAccount();
  Test.setCurrentPage(pageRef);
  Account acct1 = new Account();
  ApexPages.StandardController sc = new ApexPages.StandardController(acct1);
  AccountSearchAddController cont = new AccountSearchAddController(sc);
  List<SelectOption> lst = cont.getRecordTypeOptions();

  cont.acct.PersonEmail = '';
  cont.acct.Phone = '';
  cont.acct.LastName = '';
  cont.acct.FirstName = '';
  cont.RecordTypeId = '';
  test.startTest();
  PageReference prAccount = cont.doSave();
  cont.doCancel();
  test.stopTest();
}


}