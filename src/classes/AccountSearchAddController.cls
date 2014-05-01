/********************************************************************************
 ********************************************************************************   
 *  Class		   : AccountSearchAddController
 *  Author		   : Acumen Solutions: Rahul Badal
 *  Version History : 1.0
 *  Creation		 : 04/19/13
 *  Description	 : Controller for AccountSearchAndAdd Page
 *					  
 ********************************************************************************
 ********************************************************************************/
public with sharing class AccountSearchAddController {
	public List<Account> searchResult{get;set;}
	public Account acct {get;set;}
	public string inputFirstName {get;set;}
	public string inputLastName {get;set;}
	public string inputEmail {get;set;}
	public string inputPhone {get;set;}
	public string inputAS400 {get;set;}
	public boolean showSearch{get;set;}
	public boolean showResults{get;set;}
	public boolean showAdd{get;set;}
	public string strInputValue{get;set;}
	public string RecordTypeID {get ; set ;}
	public string selectedAccount {get;set;}
	static final Integer SEARCH_CHAR = 3;
	public List<RecordType> rType {get;set;}
	public String devName {get;set;}
	public Boolean showAllOption {get;set;}
	public List<SelectOption> myRecordTypes {get;set;}
	public String autoRedirectStr {get;set;}
	public Boolean doRedirect {get;set;}
	public String redirectName {get;set;}

	/*public List<selectOption> RecordTypeOptions {
		get {
			List<selectOption> myRecordTypes = new List<selectOption>();
			for (RecordType rt : [select Id,Name from RecordType where RecordType.SobjectType = 'Account' and   IsPersonType=true and RecordType.IsActive = True ])
				myRecordTypes.add(new selectOption(rt.id, rt.name));
			return myRecordTypes;
		}
		private set;
	}*/

	public AccountSearchAddController(ApexPages.StandardController stdController){
			acct	= (Account) stdController.getRecord();
			doRedirect = false;
			autoRedirectStr = '';
			showSearch = true;
			showResults = false;
			showAdd = false;
			inputFirstName = '';
			inputLastName = '';
			inputEmail = '';
			inputPhone = '';
			devName = '';
			devName = System.currentPageReference().getParameters().get('RecType');
	}
	
	public List<SelectOption> getRecordTypeOptions() {
		if(devName != null && devName != ''){
			rType = [SELECT Id, Name, DeveloperName,IsPersonType FROM RecordType WHERE SobjectType = 'Account' AND IsPersonType = true AND IsActive = true AND DeveloperName = :devName];
			showAllOption = false;
		}else {
			rType = [SELECT Id, Name, DeveloperName,IsPersonType FROM RecordType WHERE SobjectType = 'Account' AND IsPersonType = true AND IsActive = true];
			showAllOption = true;
		}
		myRecordTypes = new List<SelectOption>();
		//myRecordTypes.add(new SelectOption('', '--All--'));
		for(RecordType rt: rType){
			myRecordTypes.add(new SelectOption(rt.Id, rt.Name));
		}
		return myRecordTypes;
	}

	public void doSearch(){
		showSearch = true;
		showResults = true;
		showAdd = false;
		boolean noError = true;
		if(string.isnotblank(acct.Phone))
		{
			inputPhone = acct.Phone;
			string tempphone = inputphone.replace('(','').replace(')','').replace(' ','').replace('-','');
			if(tempphone.length() > 0 && tempphone.length() != 10)
			{
				ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, '<h3>Please provide 10 digit telephone number.</h3>'));
				//<br/> You can use "*" as a wildcard next to other characters to improve your search results
				showResults = false;				
			}
			
			if (pattern.matches('[a-zA-Z]+',tempphone)) {
					ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, '<h3>Please provide only numeric values.</h3>'));
					showResults = false;
				}
			
				
			
		}
		else
		inputPhone = '';
		
		if(inputFirstName.length() < SEARCH_CHAR && inputLastName.length() < SEARCH_CHAR && inputEmail.length() < SEARCH_CHAR && inputPhone.length() < SEARCH_CHAR && inputAS400.length() < SEARCH_CHAR )
		{
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'<h3>Please enter atleast one search criteria with minimum ' + string.valueof(SEARCH_CHAR) + ' characters.</h3>'));
			//<br/> You can use "*" as a wildcard next to other characters to improve your search results
			showResults = false;
		}
		
		if(!showResults) 
		{
			return;
		}
		// Fix for escape character
		
		string soql = 'select Id,Phone,Name,FirstName,LastName,PersonEmail,AS_400_Customer_Number__c,RecordType.Name From Account';
			soql = soql +   ' where Name LIKE \'%' + string.escapeSingleQuotes(inputFirstName)+ '%' + string.escapeSingleQuotes(inputLastName) + '%\'';
		/*if(inputEmail != '' && inputEmail != null)
			soql = soql +   ' And PersonEmail LIKE \'%' + inputEmail +'%\'';
		if(inputPhone != '' && inputPhone != null)
			soql = soql +   ' And Phone LIKE \'%' + inputPhone +'%\'';*/
		if(RecordTypeID != '' && RecordTypeID != null)
			soql = soql +   ' And RecordTypeId = \'' + string.escapeSingleQuotes(RecordTypeID) + '\'';
			
		soql = soql + ' ORDER BY Name LIMIT 200';
		List<Account> nameResults = database.query(soql);
		
		searchResult = filterSearchResults(nameResults);
		
		if(searchResult.size() < 1)
		{
			//ApexPages.Message noRecMsg = new ApexPages.Message(ApexPages.Severity.INFO, 'No Record Found!');
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'No Record Found!'));
			showSearch = false;
				showResults = false;
				showAdd = true;
				acct.PersonEmail = inputEmail;
			//acct.Phone = inputPhone;
			acct.LastName = inputLastName;
			acct.FirstName = inputFirstName;
			acct.AS_400_Customer_Number__c = inputAS400;
		
		} 
		//return null; 

	}
	
	private List<Account> filterSearchResults(List<Account> results){
		Set<Account> myResults = new Set<Account>();
		List<Account> filteredResults = new List<Account>();
		for(Account a : results){
			try{
				if(inputEmail != '' && inputEmail != null && inputPhone != '' && inputPhone != null){
					Boolean hasPhone = false;
					Boolean hasEmail = false;
					if(a.Phone.startsWith(inputPhone) || a.Phone.endsWith(inputPhone) || a.Phone.contains(inputPhone)){
						hasPhone = true;
					}
					if(a.PersonEmail.startsWithIgnoreCase(inputEmail) || a.PersonEmail.endsWithIgnoreCase(inputEmail)){
						hasEmail = true;
					}
					if(hasEmail && hasPhone){
						myResults.add(a);
					}
				}
				
				if((inputPhone == '' || inputPhone == null) && (inputEmail == '' || inputEmail == null) && (inputAS400 == '' || inputAS400 == null)){
					myResults.add(a);
					}
				if(inputPhone != '' && inputPhone != null && (inputEmail == '' || inputEmail == null)){
					if(a.Phone.startsWith(inputPhone) || a.Phone.endsWith(inputPhone) || a.Phone.contains(inputPhone)){
						myResults.add(a);
					}
				}
				if(inputEmail != '' && inputEmail != null && (inputPhone == '' || inputPhone == null)){
					if(a.PersonEmail.startsWithIgnoreCase(inputEmail) || a.PersonEmail.endsWithIgnoreCase(inputEmail)){
						myResults.add(a);
					}
				}
				
				if(inputAS400 != '' && inputAS400 != null)
				{
					   if(a.AS_400_Customer_Number__c.startsWithIgnoreCase(inputAS400) || a.AS_400_Customer_Number__c.endsWithIgnoreCase(inputAS400)){
					   	system.debug('**** Added AS400#### ' + a.AS_400_Customer_Number__c);
						myResults.add(a); 
					}
				}
			}
			
			catch(Exception E)
			{} // Data quality issue
		   
			
			
		}
		filteredResults.addAll(myResults);
		return filteredResults;
	}

	public PageReference doSave(){
		try{
			string errorMsg = '';
			//if(inputFirstName.length() < SEARCH_CHAR && inputLastName.length() < SEARCH_CHAR && inputEmail.length() < SEARCH_CHAR && inputPhone.length() < SEARCH_CHAR )
			If(string.isblank(acct.firstName))
				errorMsg += 'Please enter First Name<br/>';
			If(string.isblank(RecordTypeID))
				errorMsg += 'Please select Brand<br/>'; 
			If(string.isblank(acct.LastName))
				errorMsg += 'Please enter Last Name<br/>';
			If(string.isblank(acct.PersonEmail) && string.isblank(acct.Phone) )
				errorMsg += 'Please enter Email or Phone number';
			
			
			if(errorMsg.length() > 0)
			{
				ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,errorMsg));
				return null;
			}
			else
			{
				list<Account> acctlist = [select Id from Account where Firstname =:acct.FirstName and LastName =:acct.LastName and PersonEmail =:acct.PersonEmail];
				if(acctlist.size() > 0)
					acct.Potential_Duplicate__c = true;
			
				acct.RecordTypeId = RecordTypeID;
				insert acct;
				
				//PageReference acctPage = new ApexPages.StandardController(acct).view();
				//acctPage.setRedirect(true);
				//return acctPage;
				autoRedirectStr = '/'+acct.id + '/e?retURL=%2F' + acct.id + '&nooverride=1';
				doRedirect = true;
				redirectName = acct.Name;
				return null;
			}
		
		}
			
		
		
		catch(exception e)
		{
		 ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Error in creating accounts'));
		}
		return null;
	}

	public void doCancel(){
		showAdd = false;
		showSearch = true;
	}

	public void doAdd(){
		showResults = false;
		showAdd = true;
		showSearch = false;
		acct.PersonEmail = inputEmail;
		acct.Phone = inputPhone;
		acct.LastName = inputLastName;
		acct.FirstName = inputFirstName;
		acct.AS_400_Customer_Number__c = inputAS400;
	}

}