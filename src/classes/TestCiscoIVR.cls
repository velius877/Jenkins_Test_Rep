/* 
	TestCiscoIVR
	Test Class Cisco WS 
	------------------------------------------------------------------
	Author			|	Date		|	Description
	------------------------------------------------------------------
	Gary Alfrey   	|	4/16/2013	|	Created

*/

@isTest
private class TestCiscoIVR {

    static testMethod void myUnitTest() {
    	Account acct = TestDataSetupUtil.setupAccount();
    	//insert acct;
    	system.debug('-----------------------------------------------------------------acct ' + acct);
    	Account acct1 = [SELECT Id, Customer_Number__c FROM Account WHERE Id = :acct.Id];
    	system.debug('-----------------------------------------------------------------acct1 ' + acct1);
        CiscoIVR_ComplexTypes.Cisco_IVR ct = new CiscoIVR_ComplexTypes.Cisco_IVR();
        ct.brand = '';
        ct.CED = acct1.Customer_Number__c;
        ct.searchType = 'Customer';
        
        CiscoIVR_WS.IVRHelper(ct);
    }
    
    static testMethod void myUnitTest2() {
    	RecordType rt = [SELECT Id FROM RecordType WHERE DeveloperName = 'Pre_Case' AND sObjectType = 'Case'];
    	Account acct = TestDataSetupUtil.setupAccount();
    	Case c = new Case();
    	c.AccountId = acct.Id;
    	c.RecordTypeId = rt.Id;
    	c.Origin = 'Phone';
    	insert c;
    	system.debug('-----------------------------------------------------------------case ' + c);
    	Case cs = [SELECT Id, CaseNumber FROM Case WHERE Id = :c.Id];
    	system.debug('-----------------------------------------------------------------cs ' + cs);
        CiscoIVR_ComplexTypes.Cisco_IVR ct = new CiscoIVR_ComplexTypes.Cisco_IVR();
        ct.brand = '';
        ct.CED = cs.CaseNumber;
        ct.searchType = 'Case';
        
        CiscoIVR_WS.IVRHelper(ct);
    }
}