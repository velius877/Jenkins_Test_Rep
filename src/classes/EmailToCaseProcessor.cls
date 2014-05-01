/* 
	EmailToCaseProcessor
	DESCRIPTION
	------------------------------------------------------------------
	Author		|	Date		|	Description
	------------------------------------------------------------------
	Gary Alfrey |	5/1/2013	|	Created

*/


global class EmailToCaseProcessor implements Messaging.InboundEmailHandler {

	//Tag for CaseId
	private static final String START_CASE_MATCH = 'ref:';
	private static final String END_CASE_MATCH = ':ref';
	
	//Body type of message:   HTML or Text
	//private static String whichBody;
	private static Boolean bodyText;
	
	//Field to hold the long subject > 80 chars
	private static String longSubject;

	global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
		Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
		
		system.debug('Email Object: ' + email);
		system.debug('Envelope Object: ' + envelope);
			
		try {
			// Process incoming email
			processIncomingEmail(email, envelope);
			
			// success
			result.success = true;
		}catch (Exception e){
			// Send error back to user
			result.success = false;
			result.message = 'An error occured processing your message. ' + e.getMessage();
		}
		
		return result;
	}
	
	
	/******************************************************************
		Process email - determine plain text or html body.
		determine if update or new case
	******************************************************************/
	public static void processIncomingEmail(Messaging.inboundEmail email, Messaging.InboundEnvelope envelope){
		
		Case cas = null;
		
		//Determine if email body is plain text or html
		if(email.plainTextBody != null){
			bodyText = true;
		}
		
		/*if(email.htmlBody != null){
			bodyText = false;
		}*/
		
		if(bodyText){
			cas = searchforCurrentCase(email.plainTextBody, email.Subject);
		}else{
			//cas = searchforCurrentCase(email.htmlBody, email.Subject);
		}
		
		System.debug('-----------------------------------------Email Subject: ' + email.Subject);
		System.debug('-----------------------------------------Email Plain Text Body: ' + email.plainTextBody);
		System.debug('-----------------------------------------Email Html Body: ' + email.htmlBody);
		
		
		// if case exist add email to activity and change status to customer replied
		if(cas != null){
			updateCaseActivity(email, cas, envelope);
		}
		
		// if case does not exist create a new case 
		if(cas == null){
			createNewCase(email, envelope);
		}
		
	}
	/*************************************************************
		Look for ref Id in email body
		use ref to query for case
		return case if found
		return null if no case is found
	*************************************************************/
	private static Case searchForCurrentCase(String str, String eSubject){
		
		Case cas = null;
		
		//Get case number from email body
		Integer startCaseMatchNum = str.indexOf(START_CASE_MATCH);
		Integer endCaseMatchNum = str.indexOf(END_CASE_MATCH);
		
		Integer startCaseMatchNumSubject = eSubject.indexOf(START_CASE_MATCH);
		Integer endCaseMatchNumSubject = eSubject.indexOf(END_CASE_MATCH);
		
		String caseId;
		List<Case> caseList;
		
		if(startCaseMatchNum >= 0 && endCaseMatchNum >= 0){
			System.debug('------------- Searching for Case by Ref Id');
			caseId = str.substringBetween(START_CASE_MATCH, END_CASE_MATCH);
			//caseId = str.substring(startCaseMatchNum + START_CASE_MATCH.length(), endCaseMatchNum);
			caseId = caseId.trim();
			System.debug('---------CaseId: ' + caseId);
			caseList = [SELECT Id, OwnerId, CaseNumber, ContactId, Status, Priority, Type FROM Case WHERE Id = :caseId];
		}else if(startCaseMatchNumSubject >= 0 && startCaseMatchNumSubject >= 0){
			System.debug('------------- Searching for Case by Ref Id');
			caseId = eSubject.substringBetween(START_CASE_MATCH, END_CASE_MATCH);
			//caseId = str.substring(startCaseMatchNum + START_CASE_MATCH.length(), endCaseMatchNum);
			caseId = caseId.trim();
			System.debug('---------CaseId: ' + caseId);
			caseList = [SELECT Id, OwnerId, CaseNumber, ContactId, Status, Priority, Type FROM Case WHERE Id = :caseId];
		}else{
			return null;
		}
		
		System.debug('-------------caseList Size: ' + caseList.size());
		
		if(caseList != null && caseList.size() > 0){
			cas = caseList[0];
		}
		
		return cas;
	}
	
	/***********************************************************************
		Called by processIncomingEmail: Existing Case Found
		Takes in a case and email
		Updates case status and 
		adds email to case activity (Task!!!)
	***********************************************************************/
	private static void updateCaseActivity(Messaging.inboundEmail email, Case cas, Messaging.InboundEnvelope envelope){
		Task t = new Task();
		// assign activity to case
		t.WhatId = cas.Id;
		// populate description with email body - Use text body - fields do not parse html tags.
		if(bodyText){
			t.Description = email.plainTextBody;
		}else{
			//t.Description = email.htmlBody;
		}
		t.Subject = email.Subject;
		// assign task to case owner
		t.OwnerId = cas.OwnerId;
		t.Priority = cas.Priority;
		
		// insert new task
		insert t;
		
		cas.Status = 'Customer Replied';
		update cas;
		
		// pass email and task to method to handle any attachments contained
		insertNewAttachments(email, cas, t);
		
		
	}
	
	/**********************************************************************
		Called by processIncomingEmail: Existing Case Not Found
		Takes in an email
		Search for a contact based on fromAddress
		if not found create a new contact?
		create new case (record type precase)
		How to assign case owner?
		insert attachments
	**********************************************************************/
	private static void createNewCase(Messaging.inboundEmail email, Messaging.InboundEnvelope envelope){
		//Set<String> EMAIL_DOMAIN_SET = new set<String> {'perfectlypure.com','puritan.com','vitaminworld.com','nbty.com','healthsmartvitamins.com','puritanspride.co.uk','puritanspride.com.au','es.puritan.com','puritan.jp'};
		List<Email_Domain_Map__c> emailDomainMap = Email_Domain_Map__c.getall().values();
		Set<String> EMAIL_DOMAIN_SET = new set<String>();
		for(Email_Domain_Map__c edm : emailDomainMap){
			EMAIL_DOMAIN_SET.add(edm.Name);
		}
		Case cas = new Case();
		RecordType rt = [SELECT Id, Name FROM RecordType WHERE DeveloperName = 'Pre_Case' LIMIT 1];
		system.debug('from Address--------------------: ' + email.fromAddress);
		
		List<String> e2 = email.toAddresses;
		system.debug('---------------------------------To Addresses: ' + e2);
		String toAddress;
		for(String x : e2){
			system.debug('---------------------------------To Address loop: ' + x);
			for (string domain: EMAIL_DOMAIN_SET){
				if(x.contains(domain)){
					String str = x.removeEnd(')');
					toAddress = str.removeStart('(');
					toAddress.trim();
				}
			}
		}
		System.debug('----------------------------------------------toAddress: ' + toAddress);
		
		List<EmailToCaseMapping__c> etcm = [SELECT Id, Name, Queue__c, NBTY_Email__c, Brand__c, RecordType_Dev_Name__c FROM EmailToCaseMapping__c
			WHERE NBTY_Email__c = :toAddress LIMIT 1];
		
		List<Account> acct = [SELECT Id, Name, PersonEmail FROM Account WHERE PersonEmail = :email.fromAddress AND RecordType.DeveloperName = :etcm[0].RecordType_Dev_Name__c LIMIT 1];
		if(acct != null && acct.size() > 0){
			cas.AccountId = acct[0].Id;
		}
		cas.Origin = 'Email to Case';
		if(bodyText){
			cas.Description = email.plainTextBody;
		}else{
			//cas.Description = email.htmlBody;
		}
		system.debug('---------------------------: ' + email.subject);
		cas.Subject = email.subject;
		cas.RecordTypeId = rt.Id;
		system.debug('---------------------------------from Address: ' + email.fromAddress);
		system.debug('---------------------------------to Address: ' + email.toAddresses);
		cas.Original_From__c = email.fromAddress;
		cas.Brand__c = etcm[0].Brand__c;
		// find owner queue from incoming address used;
		
		//String toAddress = envelope.toAddress;
		
		cas.Original_To__c = toAddress;
		
		if(etcm != null && etcm.size() > 0){
			QueueSobject queue =  [SELECT Id, QueueId, Queue.DeveloperName FROM QueueSobject WHERE Queue.DeveloperName = :etcm[0].Queue__c LIMIT 1];
			cas.OwnerId = queue.QueueId;
		}else{
			QueueSobject queue =  [SELECT Id, QueueId, Queue.DeveloperName FROM QueueSobject WHERE Queue.DeveloperName = 'Q_Unassigned_Cases' LIMIT 1];
			cas.OwnerId = queue.QueueId;
		}
		
		if(email.binaryAttachments != null){
			//cas.Web_Attachment__c = true;
		}
		
		insert cas;
		
		Task t = new Task();
		// assign activity to case
		t.WhatId = cas.Id;
		// populate description with email body
		if(bodyText){
			t.Description = email.plainTextBody;
		}else{
			t.Description = email.htmlBody;
		}
		t.Subject = email.Subject;
		// assign task to case owner
		//t.OwnerId = cas.OwnerId;
		t.Priority = 'Normal';
		t.Status = 'Completed';
		// insert new task
		insert t;
		
		
		insertNewAttachments(email, cas, null);
	}
	
	/**************************************************************************************
	***************************************************************************************
	**************************************************************************************/
	
	private static void insertNewAttachments(Messaging.inboundEmail email, Case cas, Task tas){
		List<Attachment> docList = new List<Attachment>();
		system.debug('--------------------: ' + email.binaryAttachments);
		if(email.binaryAttachments != null){
			for(Messaging.Inboundemail.Binaryattachment att : email.binaryAttachments){
				system.debug('--------------------: ' + att.body);
				system.debug('--------------------: ' + att.fileName);
				Attachment doc = new Attachment();
				//doc.OwnerId = ;
				//if(tas != null){
				//  doc.ParentId = tas.Id;
				//}else{
					doc.ParentId = cas.Id;
				//}
				
				doc.Body = att.body;
				doc.Name = att.fileName;
				docList.add(doc);
			}
		}
		/*if(email.textAttachments != null){
			for(Messaging.Inboundemail.Textattachment att : email.textAttachments){
				Attachment doc = new Attachment();
				doc.OwnerId = cas.ContactId;
				doc.ParentId = tas.Id;
				doc.Body = att.body;
				doc.Name = att.fileName;
				docList.add(doc);
			}
		}*/
		insert docList;
	}
	
	
}