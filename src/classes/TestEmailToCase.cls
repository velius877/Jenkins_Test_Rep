/* 
	TestEmailToCase
	DESCRIPTION
	------------------------------------------------------------------
	Author		|	Date		|	Description
	------------------------------------------------------------------
	Gary Alfrey |	5/9/2013	|	Created

*/

@isTest
private class TestEmailToCase {
	
	static testMethod void myUnitTest() {
		TestDataSetupUtil.SetupCoreData(1);
		
		EmailToCaseMapping__c mc = new EmailToCaseMapping__c();
		mc.Brand__c = 'Puritan'+'s Pride';
		mc.Name = 'test1';
		mc.NBTY_Email__c = 'sfdc_dev@puritan.com';
		mc.Queue__c = 'BO_Puritain_s_Pride_E2C';
		mc.RecordType_Dev_Name__c = 'Puritans_Pride_Customer';
		insert mc;
		
		Email_Domain_Map__c edm = new Email_Domain_Map__c();
		edm.Name = 'puritan.com';
		insert edm;
		
		
		// create a new email and envelope object
		Messaging.InboundEmail email = new Messaging.InboundEmail() ;
		Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
		
		// setup the data for the email
		email.subject = 'Test Email ';
		email.fromname = 'FirstName LastName';
		email.plainTextBody = 'this is a test and only a test ';
		email.fromAddress = 'jDoe@test.com';
		List<String> mystr = new List<String>();
		mystr.add('nbty_inbound_service@3eyy0z337xlbau6703n07k4pj8ng0tgprm7xnr6zs1102of53.z-pan1maa.z.apex.sandbox.salesforce.com');
		myStr.add('sfdc_dev@puritan.com');
		email.toAddresses = mystr;
		
		// add an attachment
		Messaging.InboundEmail.BinaryAttachment attachment = new Messaging.InboundEmail.BinaryAttachment();
		attachment.body = blob.valueOf('my attachment text');
		attachment.fileName = 'textfile.txt';
		attachment.mimeTypeSubType = 'text/plain';
		
		email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { attachment };
		
		// call the email service class and test it with the data in the testMethod
  		EmailToCaseProcessor emailProcess = new EmailToCaseProcessor();
		emailProcess.handleInboundEmail(email, env);
	}
	
	static testMethod void test2(){
		
		TestDataSetupUtil.SetupCoreData(1);
		
		EmailToCaseMapping__c mc = new EmailToCaseMapping__c();
		mc.Brand__c = 'Puritan'+'s Pride';
		mc.Name = 'test1';
		mc.NBTY_Email__c = 'sfdc_dev@puritan.com';
		mc.Queue__c = 'BO_Puritain_s_Pride_E2C';
		mc.RecordType_Dev_Name__c = 'Puritans_Pride_Customer';
		insert mc;
		
		Email_Domain_Map__c edm = new Email_Domain_Map__c();
		edm.Name = 'puritan.com';
		insert edm;
		
		RecordType rt3 = [SELECT Id FROM RecordType WHERE DeveloperName = 'Pre_Case' AND SobjectType = 'Case'];
		Case myCase = new Case();
		myCase.RecordTypeId = rt3.Id;
		myCase.Status = 'Waiting on Customer';
		myCase.Origin = 'Email';
		myCase.Type = 'Question';
		myCase.Consumer_Email__c = 'jdoe@test.com';
		myCase.AccountId = TestDataSetupUtil.acct.Id;
		insert myCase;
		
		// create a new email and envelope object
		Messaging.InboundEmail email = new Messaging.InboundEmail() ;
		Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
		
		// setup the data for the email
		email.subject = 'Test Email ';
		email.fromname = 'FirstName LastName';
		email.plainTextBody = 'this is a test and only a test ref:' + myCase.Id + ':ref';
		email.fromAddress = 'jDoe@test.com';
		List<String> mystr = new List<String>();
		mystr.add('nbty_inbound_service@3eyy0z337xlbau6703n07k4pj8ng0tgprm7xnr6zs1102of53.z-pan1maa.z.apex.sandbox.salesforce.com');
		myStr.add('sfdc_dev@puritan.com');
		email.toAddresses = mystr;
		
		// add an attachment
		Messaging.InboundEmail.BinaryAttachment attachment = new Messaging.InboundEmail.BinaryAttachment();
		attachment.body = blob.valueOf('my attachment text');
		attachment.fileName = 'textfile.txt';
		attachment.mimeTypeSubType = 'text/plain';
		
		email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { attachment };
		
		// call the email service class and test it with the data in the testMethod
		EmailToCaseProcessor emailProcess = new EmailToCaseProcessor();
		emailProcess.handleInboundEmail(email, env);
	}
}