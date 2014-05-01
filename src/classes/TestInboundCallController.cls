/* 
	TestInboundCallController
	Test Class for CTI
	------------------------------------------------------------------
	Author			|	Date		|	Description
	------------------------------------------------------------------
	Gary Alfrey   	|	4/16/2013	|	Created

*/

@isTest
private class TestInboundCallController {

	static testMethod void myUnitTest() {
		TestDataSetupUtil.processCrtBrandMapping();
		WS_Integration__c turnOffBadCust = new WS_Integration__c();
		turnOffBadCust.Name = 'BadCustOff';
		turnOffBadCust.Value__c = 'true';
		insert turnOffBadCust;
		JSONGenerator gen = JSON.createGenerator(true);
		gen.writeStartObject();
		gen.writeStringField('PerVar1', '');
		gen.writeStringField('PerVar2', '');
		gen.writeStringField('PerVar3', '');
		gen.writeStringField('PerVar4', 'Vitamin World');
		gen.writeStringField('PerVar5', '');
		gen.writeStringField('PerVar6', '');
		gen.writeStringField('PerVar7', 'Ent.Tele_Sales');
		gen.writeStringField('PerVar8', '');
		gen.writeStringField('PerVar9', '');
		gen.writeStringField('PerVar10', '');
		gen.writeStringField('Id', '33556862');
		gen.writeStringField('State', 'ACTIVE');
		gen.writeStringField('DNIS', '155917');
		gen.writeStringField('DialedNumber', '4997');
		gen.writeStringField('Sender', '4195715968');
		gen.writeStringField('Direction', 'Inbound');
		gen.writeStringField('UniqueId', '1.23456789');
		gen.writeEndObject();
		String jsonText = gen.getAsString();
		
		Task t = new Task();
		t.CNX2__UniqueCallId__c = '1.23456789';
		insert t;
		
		List<Task> tList = new List<Task>();
		for(Integer i=0; i<20; i++){
			Task t2 = new Task();
			t2.Brand__c = 'Vitamin World';
			t2.ANI__c = '4195715968';
			t2.CNX2__UniqueCallId__c = '1.23456780' + String.valueOf(i);
			tList.add(t2);
		}
		for(Integer i=0; i<10; i++){
			Task t2 = new Task();
			t2.Brand__c = 'Puritan\'s Pride';
			t2.ANI__c = '4195715968';
			t2.CNX2__UniqueCallId__c = '1.23456700' + String.valueOf(i);
			tList.add(t2);
		}
		insert tList;
		
		RecordType vw = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'Vitamin_World_Customer' AND isPersonType = true];
		RecordType pp = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'Puritans_Pride_Customer' AND isPersonType = true];
		List<Account> aList = new List<Account>();
		for(Integer i=0; i<20; i++){
			Account a = new Account();
			a.RecordTypeId = vw.Id;
			a.Salutation = 'Mr.';
			a.FirstName = 'John';
			a.LastName = 'Doe' + String.valueOf(i);
			a.AS_400_Customer_Number__c = '987654321';
			a.PersonEmail = 'jDoe@test'+ String.valueOf(i) +'.com';
			a.Phone = '(419) 571-5968';
			aList.add(a);
		}
		for(Integer i=0; i<20; i++){
			Account a = new Account();
			a.RecordTypeId = pp.Id;
			a.Salutation = 'Mr.';
			a.FirstName = 'James' + String.valueOf(i);
			a.LastName = 'Doe';
			a.AS_400_Customer_Number__c = '987654321' + String.valueOf(i);
			a.PersonEmail = 'jDoe' + String.valueOf(i) + '@test.com';
			a.Phone = '(419) 571-5968';
			aList.add(a);
		}
		insert aList;
		
		List<Orders__c> ordList = new List<Orders__c>();
		for(Account acct : aList){
			Orders__c ord = new Orders__c();
			ord.Customer__c = acct.Id;
			ord.Order_Date__c = date.today();
			//ord.Order_Status__c = 'Internal Review';
			ord.Sales_Channel__c = 'Phone';
			ord.Sequence_Number__c = '2166549802';
			ord.Webstack_Order_ID__c = '1234567890';
			ord.CTI_Search__c = '(419) 571-5968';
			ordList.add(ord);
		}
		insert ordList;
		
		List<Case> cList = new List<Case>();
		for(Integer i=0; i<20; i++){
			Case c = new Case();
			c.CTI_Search__c = '4195715968';
			c.Brand__c = 'Vitamin World';
			cList.add(c);
		}
		for(Integer i=0; i<20; i++){
			Case c = new Case();
			c.CTI_Search__c = '4195715968';
			c.Brand__c = 'Puritan\'s Pride';
			cList.add(c);
		}
		insert cList;
		test.startTest();
		CnxCustomerEnhancements.updateCallLog(null, jsonText);
		
		InboundCallController a = new InboundCallController();
		a.Init();
		a.DoSearch();
		a.ABLast();
		a.ABFirst();
		a.ABNext();
		a.ABPrevious();
		a.AOLast();
		a.AOFirst();
		a.AONext();
		a.AOPrevious();
		a.lastAAB();
		a.firstAAB();
		a.nextAAB();
		a.previousAAB();
		a.lastAAO();
		a.firstAAO();
		a.nextAAO();
		a.previousAAO();
		a.lastCAB();
		a.firstCAB();
		a.nextCAB();
		a.previousCAB();
		a.lastCAO();
		a.firstCAO();
		a.nextCAO();
		a.previousCAO();
		test.stopTest();
	}
}