/* 
	NewCaseController
	DESCRIPTION
	------------------------------------------------------------------
	Author		|	Date		|	Description
	------------------------------------------------------------------
	Gary Alfrey |	5/20/2013	|	Created
	Gary Alfrey |	10/30/13	|	Completely Refactored

*/

public with sharing class NewCaseController {
	
	public Case newCase {get;set;}
	private Case editCase {get;set;}
	private String caseId;
	private String editRedirectStr;
	public String newCaseId {get;set;}
	private String accountId;
	private String orderId;
	public String selectedRecType {get;set;}
	private Map<String, String> recMap;
	public	boolean closeTab {get;set;}
	
	
	public NewCaseController(ApexPages.StandardController controller){
		caseId = controller.getId();
		newCase = new Case();
		closeTab = false;
	}
	
	public void setupRTMap(){
		Set<String> mySet = new Set<String>{'Pre_Case','Follow_Up','Product_Complaint'};
		List<RecordType> recList = [SELECT Id, Name, DeveloperName FROM RecordType WHERE sObjectType = 'Case' AND DeveloperName IN: mySet];
		recMap = new Map<String, String>();
		for(RecordType a : recList){
			
			recMap.put(a.Id, a.DeveloperName);
			recMap.put(string.valueOf(a.Id).substring(0,15), a.DeveloperName);
		}
	}
	
	public List<SelectOption> getRecTypes(){
			setupRtMap();
			Set<String> mySet = new Set<String>{'Pre_Case','Follow_Up','Product_Complaint'};
			List<RecordType> recList = [SELECT Id, Name, DeveloperName FROM RecordType WHERE sObjectType = 'Case' AND DeveloperName IN: mySet];
		List<SelectOption> options = new List<SelectOption>();
		for(RecordType a : recList){
			options.add(new SelectOption(a.Id,a.Name));
		}
	
		return options;
	}
	
	public PageReference init(){
		accountId = ApexPages.currentPage().getParameters().get('def_account_id');
		system.debug('-----------------------------------------------------------accountId: ' + accountId);
		system.debug('-----------------------------------------------------------retURL: ' + ApexPages.currentPage().getParameters().get('retURL'));
		//orderId = ApexPages.currentPage().getParameters().get('retURL').substring(22,37);
		String retURL = ApexPages.currentPage().getParameters().get('retURL');
		if (retURL != null) {
			if (retURL.length()>=37){
				orderId = retURL.substring(22,37);
			}
			system.debug('-----------------------------------------------------------orderId: ' + orderId);
		} else {
			orderId = '';
		}
		
		setupRTMap();
		string rtId = ApexPages.currentPage().getParameters().get('RecordType');
		string recordTypeName ;
		if (rtId!=null){
			recordTypeName = recMap.get(rtId);
		}
		if(caseId != null && caseId != ''){  //edit  change record type or clone scenario
			if (recordTypeName==null){
				recordTypeName = [select recordType.DeveloperName from Case where id =:caseId].recordType.developerName;
			}
			if(recordTypeName == 'Product_Complaint'){
				editRedirectStr = '/apex/Case_ICM?id=' + caseId + '&retURL=%2F' + caseId;
			}else{
				if(rtId != null){
					editRedirectStr = '/' + caseId + '/e?retURL=%2F' + caseId + '&nooverride=1' + '&RecordType='+rtId;
				}else{
					editRedirectStr = '/' + caseId + '/e?retURL=%2F' + caseId + '&nooverride=1';
				}
			}
			PageReference ref = new PageReference(editRedirectStr);
			ref.setRedirect(true);
			return ref;
		}
		else {// clone or new scenario
			Schema.DescribeSObjectResult caseDescribe = Case.SObjectType.getDescribe();
			system.debug('1-2-2-2-2' + ApexPages.currentPage().getParameters().get('RecordType'));
			//string rtId = ApexPages.currentPage().getParameters().get('RecordType');
			Account acct;
			Orders__c ord;
			Customer_Rec_Type_Brand_Mapping__c crtbm;
			if (accountId!=null){
				acct=[select id, recordType.DeveloperName from Account where id =:accountId];
				crtbm = NBTYUtils.getRecordTypeBrandMappingMap().get(acct.recordType.developerName);
			}
			if (orderId!=null){
				if (orderId.startsWith('a07')) {//this means the substring contains an order Id
					ord = [SELECT Id, Customer__c, Customer__r.RecordType.DeveloperName, Name FROM Orders__c WHERE Id = :orderId];
					crtbm = NBTYUtils.getRecordTypeBrandMappingMap().get(ord.Customer__r.RecordType.DeveloperName);
					AccountId = ord.Customer__c;
					orderId = ord.Id;
				}
			}

			if (rtId != null){
				newCase.RecordTypeId = rtId;
				system.debug('-------------------' + newCase.RecordTypeId);
				if (recMap.get(rtId)=='Product_Complaint') {
					editRedirectStr = '/apex/Case_ICM' + '?RecordType='+rtId;
					if (AccountId!=null) {
						editRedirectStr+='&AccountId='+AccountId;
					}
				} else {
					editRedirectStr = '/' + caseDescribe.getKeyPrefix() + '/e?retURL=%2F' + AccountId + '&RecordType='+rtId+'&nooverride=1';
					if (AccountId!=null) {
						editRedirectStr+='&def_account_id='+AccountId+'&'+WS_Integration__c.getInstance('CaseBrandID').value__c+'='+crtbm.Picklist_Brand__c;
					}
					if (orderId != null && ord != null) {
						editRedirectStr += '&' + WS_Integration__c.getInstance('CaseOrderNameId').value__c + '=' + ord.Name + '&' + WS_Integration__c.getInstance('CaseOrderlkId').value__c + '=' + ord.Id;
					}
					system.debug('-----------------------------------------------------------editRedirectStr: ' + editRedirectStr);
				}
				
			 	PageReference ref = new PageReference(editRedirectStr);
				ref.setRedirect(true);
				return ref;
			//return null;
			}
			else return null;
		}
		//return null;
	}
	
	public PageReference createNewCase(){
		
		/*
		system.debug('--------------------------------AccountId1: ' + accountId);
		if (accountId != null && accountId != ''){
			accountId = String.escapeSingleQuotes(accountId);
			Account acct = [SELECT Id, RecordTypeId, Phone, FirstName, LastName, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, 
							RecordType.Name, RecordType.DeveloperName, PersonEmail, PersonHomePhone FROM Account WHERE Id = :accountId];
			newCase.Reporter_Name_del__c = acct.FirstName + ' ' + acct.LastName;
			newCase.Reporter_Street__c = acct.BillingStreet;
			newCase.Reporter_City__c = acct.BillingCity;
			newCase.Reporter_State__c = acct.BillingState;
			newCase.Reporter_Zip_Code__c = acct.BillingPostalCode;
			newCase.Reporter_Country__c = acct.BillingCountry;
			newCase.Reporter_Email__c = acct.PersonEmail;
			newCase.Reporter_Phone__c = acct.PersonHomePhone;
			Country_Code_Mapping__c ccm = NBTYUtils.getcountryCodeToCCMMap().get(newCase.Reporter_Country__c);
			if (ccm!=null) {
				Country_Code_Mapping__c ccm2 = Country_Code_Mapping__c.getValues(ccm.Name__c);
				if (ccm2!=null){
					newCase.PQM_Consumer_Country__c = ccm2.PQM_Country__c;
				}
			}
			Customer_Rec_Type_Brand_Mapping__c rtbm = NBTYUtils.getRecordTypeBrandMappingMap().get(acct.recordType.developerName);
			newCase.Brand__c = rtbm.Picklist_Brand__c;
			newCase.RecordTypeId = selectedRecType;
			newCase.AccountId = accountId;
			newCase.Origin = 'Phone';
			
			
		} else {
			newCase.RecordTypeId = selectedRecType;
			newCase.Origin = 'Phone';
		}
		*/
		
		system.debug('-------------------' + newCase.RecordTypeId);
		newCase.RecordTypeId = recMap.get(selectedRecType);
		insert newCase;
		string recTypeName = recMap.get(selectedRecType);
		string redirectStr;
		if(recTypeName == 'Product_Complaint'){
			redirectStr = '/apex/Case_ICM?id=' + newCase.Id + '&retURL=%2F' + newCase.Id;
		}else{
			redirectStr = '/'+newCase.id + '/e?retURL=%2F' + newCase.id + '&nooverride=1';
		}
		
		PageReference ref = new PageReference(redirectStr);
		ref.setRedirect(true);
		return ref;
	}
	
	public void cancelCase(){
		closeTab = true;
	}
	
}