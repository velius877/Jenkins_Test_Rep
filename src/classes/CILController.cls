/************************************* MODIFICATION LOG ********************************************************************************
*
* DESCRIPTION : CILController.cls has methods with RemoteAction annotation that provides support for JavaScript remoting used in CIL Visualforce Page. 
*
*---------------------------------------------------------------------------------------------------------------------------------------
* DEVELOPER						DATE				  REASON
*---------------------------------------------------------------------------------------------------------------------------------------
* Shivkant Vadlamani			04/10/2013			- Original Version
* Gary Alfrey					04/22/2013			- Refactored for NBTY
*	
*/

global with sharing class CILController {
	public Task task {get;set;}
	public String ANI {get;set;}	
	public List<SelectOption> whatList {get;set;}
	public Map<String, String> whatMap {get;set;}
	public List<SelectOption> whoList {get{system.debug(whoList);return whoList;}set;}
	public Map<String, String> whoMap {get;set;}
	public Map<String, String> discCaseMap {get;set;}
	public Map<String, String> discNumMap {get;set;}
	public Set<ID> recordIDSet {get;set;}
	public String whoID {get;set;}
	public String whatID {get;set;}
	public String whoobjID {get;set;}
	public String whatobjID {get;set;}
	public String discPrefix {get;set;}
	public List<SelectOption> wrapupOptionList {get;set;}
	public String OutboundCallObjID {get;set;}
	public Boolean isOutbound;
	public Boolean isCallend;
	public Boolean callDrop;
	public String selectedRecId {get;set;}
	public String callDriver {get;set;}
	public List<SelectOption> callDriverList {get;set;}
	public String jsonString {get;set;}
	public String statusMessage {get;set;}
	private User user {get;set;}
	private Account acct {get;set;}
	public List<Orders__c> orderHistory {get;set;}
	public Orders__c lastOrder {get;set;}
	public List<Order_Line_Items__c> lastOrderItems {get;set;}
	public boolean	bHasOrders {get;set;}
	public boolean isLastOrderCancellable {get;set;}
	public boolean showNone {get;set;}
	public List<Order_Line_Item_Status_Detail__c> ordStatusDetails {get;set;}
	public Order_Line_Item_Status_Detail__c olisd {get;set;}
	public Boolean showOrderStatusUpdates {get;set;}

	public CILController(ApexPages.StandardController controller){
		bHasOrders = true;
		String userId = userinfo.getUserId();
		user = [SELECT Id, Task_Record__c FROM User WHERE Id = :userId];
		try{
			task = [SELECT Id, Description, IVR_Case__c, IVR_Customer__c, IVR_Order__c, IVR_Status__c, Subject, CNX2__UniqueCallId__c FROM Task WHERE Id = :user.Task_Record__c];
		}catch(exception e){
			task = new Task();
			task.Subject = 'Call '+DateTime.now().format();
			task.CNX2__UniqueCallId__c = String.valueOf(Math.random()) + DateTime.now().gettime();
			task.ActivityDate = date.today();
		}
		jsonString = task.Description;
		task.Description = '';
		acct = (Account)controller.getRecord();
		
		orderHistory = [SELECT Id, Name, Order_Date__c, Order_Status__c,Archive_Summary__c , Order_Total__c FROM Orders__c WHERE Customer__c = :acct.Id AND Order_Submitted__c=true ORDER BY Order_Date__c DESC LIMIT 10];
		system.debug(orderHistory);
		if(orderHistory.size() > 0){
			lastOrder = orderHistory[0];
			isLastOrderCancellable = orderUtilities.statusSetToCancel(lastOrder.id);
			if(lastOrder.Order_Status__c != 'Shipped/Complete'){ 
				lastOrderItems = [SELECT Id, Product_Name__r.Product_Number__c, Product_Name__r.Name, Product_Quantity__c, Final_Price__c, Unit_Price__c FROM Order_Line_Items__c WHERE Order__c = :lastOrder.Id LIMIT 5];
			}else{
				lastOrderItems = OrderLineItemArchiveUtilities.restoreOlisFromArchive(lastOrder);
			}
		}else{
			bHasOrders=false;
		}
		
		init();				
		wrapupOptionList = new List<SelectOption>{new SelectOption('','-Select-')};			
	}

	public void init(){
		whatList = new List<SelectOption>();
		whoList = new List<SelectOption>();
		whatMap = new Map<String, String>();
		whoMap = new Map<String, String>();
		discCaseMap = new Map<String, String>();
		discNumMap = new Map<String, String>();
		recordIDSet = new Set<ID>();
		isOutbound = false;
		isCallend = false;
		callDrop = false;
		whoId = '';
		whatId = '';
		callDriver = '';
		callDriverList =  new List<SelectOption>();
	   
		for (Schema.PicklistEntry p : Schema.SObjectType.Task.fields.getMap().get('Call_Driver__c').getDescribe().getPicklistValues()){
			callDriverList.add(new SelectOption(p.getLabel(), p.getValue()));
		}
	}
	
	public String getNowStr(){
		return DateTime.now().format();
	}
	
	public void setRecId(){
		if(whoList.size() > 0){
			whoList.clear();
			whoId = '';	 
		}
		
		if(whatList.size() > 0){
			whatList.clear();
			whatId = ''; 
		}
		
		Schema.DescribeSObjectResult dsr = Orders__c.SObjectType.getDescribe();
		String orderPrefix = dsr.getKeyPrefix();
		system.debug('------------------------------' + dsr);
		system.debug('------------------------------' + orderPrefix);
		system.debug('------------------------------SELECTEDRECID ' + selectedRecId);
		
		if (selectedRecId.startsWith('500')){
		 	List<Case> caseList = [SELECT Id, ContactId, Contact.Name, CaseNumber, AccountId FROM Case WHERE Id = :selectedRecId];
		 	Set<Id> acctIds = new Set<Id>();
		 	for(Case c : caseList){
		 		acctIds.add(c.AccountId);
		 	}
		 	List<Account> acctList = [Select Id, Name, (Select Id, Name From Contacts) From Account WHERE Id IN :acctIds];
		 	Map<Id, List<Contact>> myMap = new Map<Id, List<Contact>>();
		 	for(Account a : acctList){
		 		myMap.put(a.Id, a.Contacts);
		 	}
			// Case. Return Case's contact.
			for(Case cs : [SELECT Id, ContactId, Contact.Name, CaseNumber, AccountId, Account.Id, Account.Name FROM Case WHERE Id = :selectedRecId]){
				if(cs.ContactId != null){
					whoList.add(new SelectOption(cs.ContactId, cs.Contact.Name));
				}
				
				whatList.add(new SelectOption(cs.Id, cs.CaseNumber));
				
				if(cs.AccountId != null){
					whatList.add(new SelectOption(cs.Account.Id, cs.Account.Name));
					List<Contact> con = myMap.get(cs.AccountId);
					for(Contact x : con){
						whoList.add(new SelectOption(x.Id, x.Name));
					}	
				}				
			}
			
		}else if (selectedRecId.startsWith('003')) {
		
			for(Contact con : [SELECT Id, Name, AccountId, Account.Name, (Select Id, CaseNumber From Cases) FROM Contact WHERE Id = :selectedRecId]){
				whoList.add(new SelectOption(con.Id, con.Name));
				whatList.add(new SelectOption(con.AccountId, con.Account.Name));
				
				for(Case cs : con.Cases){
					whatList.add(new SelectOption(cs.Id, cs.CaseNumber));
				}
			}
		}else if (selectedRecId.startsWith('001')) {
		 
			for(Account Acct : [Select Id, Name, (Select Id, Name From Contacts), (Select Id, CaseNumber From Cases) From Account WHERE Id = :selectedRecId ]){
				for(Contact con : Acct.Contacts){
					whoList.add(new SelectOption(con.Id, con.Name));
				}
				
				whatList.add(new SelectOption(Acct.Id, Acct.Name));
				
				for(Case cs : Acct.Cases){
					whatList.add(new SelectOption(cs.Id, cs.CaseNumber));
				}
			}
			
		}else if (selectedRecId.startsWith(orderPrefix)) {
			List<Orders__c> orderList = [SELECT Id, Name, Customer__r.Name, Customer__r.Id FROM Orders__c WHERE Id = :selectedRecId];
		 	Set<Id> acctIds = new Set<Id>();
		 	for(Orders__c o : orderList){
		 		acctIds.add(o.Customer__r.Id);
		 	}
		 	List<Account> acctList = [Select Id, Name, (Select Id, Name From Contacts) From Account WHERE Id IN :acctIds];
		 	Map<Id, List<Contact>> myMap = new Map<Id, List<Contact>>();
		 	for(Account a : acctList){
		 		myMap.put(a.Id, a.Contacts);
		 	}
			for(Orders__c ord : orderList){
				List<Contact> con = myMap.get(ord.Customer__r.Id);
				whatList.add(new SelectOption(ord.Id, ord.Name));
				for(Contact x : con){
					whoList.add(new SelectOption(x.Id, x.Name));
				}
			}
			
		}
		
	}
	
	public void callBothWhoWhat(){
		saveWhoWhatId();
	}
	
	public void saveWhoWhatId(){
		task.WhatId = whatId;
		task.WhoId = whoId;
		task.Status = 'In Progress';
		statusMessage = 'Last update on ' + DateTime.now().format();
		upsert task;
	}

	public void save(){
		task.WhatId = whatId;
		task.WhoId = whoId;
		task.CallType = isOutbound ? 'Outbound' : 'Inbound';
		task.Status = 'Completed';
		//task.CallDisposition = CallDisposition;
		//task.ActivityDate = system.today();
		task.Call_Driver__c = callDriver;
		upsert task;
		user.Task_Record__c = '';
		update user;
		statusMessage = 'Saved on ' + DateTime.now().format();
	}
	
	public void cancelOrder(){
		OrderUtilities.processOrderCancel(lastOrder.id,'Customer Cancelled');
	}
	
	public void dummyRefresh(){
		//do not remove, this is needed to refresh the page
	}
	
	
	
}