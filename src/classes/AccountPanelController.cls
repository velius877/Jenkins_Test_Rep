public with sharing class AccountPanelController {
		private Account acct;
	public AccountPaymentProfileController payprofileController {get;set;}
	public OrderLookupController ohController {get;set;}
	public LoyaltySnippetController loyaltyController {get;set;}
	public boolean bpaymentCalloutDone {get;set;}
	public boolean bOHCalloutDone  {get;set;}
	public boolean bLoyaltyDone {get;set;}
	public AccountPanelController(ApexPages.StandardController stdController){
		payprofileController = new AccountPaymentProfileController(stdController);
		ohController= new OrderLookupController();
		loyaltyController = new loyaltySnippetController(stdController);
		bPaymentCalloutDone = false;
		bOHCalloutDone =false;
		bLoyaltyDone = false;
		Id aId = stdController.getId();
		acct = [SELECT Id, Name, As_400_Customer_Number__c, Payment_Profile_Id__c, VW_Passport_Number__c, RecordType.DeveloperName, PersonEmail FROM Account Where Id = :aId];
	
	}
	
	public  void init (){
		system.debug('acct.payment_profile_id__c~~~~'+acct.payment_profile_id__c);
		if (acct.Payment_Profile_Id__c!=null){
			paymentCallout();
		} 
		else if (acct.RecordType.DeveloperName == 'Vitamin_World_Customer' && acct.VW_Passport_Number__c!=null && acct.VW_Passport_Number__c!='000000000000') {
			loyaltyCallout();
		}
		
	}
	
	public void ohCallout(){
		//if (!bOHCalloutDone){
			try {
				ohController.getSubmittedOrders();
				ohController.fromAccountPanel=true;
				ohController.submittedOrdersMode=true;
				bOHCalloutDone=true;
			}
			catch (exception e){
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'An issue occurred with integration: '+e.getMessage()));
			}
	//	}
	}
	 
	public void paymentCallout(){
		if (!bPaymentCalloutDone){
			try {
	
				payprofileController.makeCallout();
				bPaymentCalloutDone=true;
			}
			catch (exception e){
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'An issue occurred with integration: '+e.getMessage()));
			}
		}
	
	}
	
	public void loyaltyCallout(){
		if (!bLoyaltyDone){
			try {
	
				loyaltyController.makeCallout();
				bLoyaltyDone=true;
			}
			catch (exception e){
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'An issue occurred with integration: '+e.getMessage()));
			}
		}
	
	}
}