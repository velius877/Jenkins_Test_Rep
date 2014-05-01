public with sharing class AccountPaymentProfileController {
	public string AccountId 				{get;set;}
	public Account acct 					 {get;set;}
	private String state = 'no';
	public list<OrderWizard_Wrapper.PaymentProfile> lstPaymentTokens {get;set;}
	 public void setState(String n) {
        state = n;
    }
            
    public String getState() {
        return state;
    }
    
    
    public void makeCallout(){
    		lstPaymentTokens = new list<OrderWizard_Wrapper.PaymentProfile>();
	    	 if (acct.payment_profile_id__C!=null){
	    	 	WS_SOA_Payment_Services.BasicHttpBinding_ITwoWayAsyncQSPort getAllCards = new WS_SOA_Payment_Services.BasicHttpBinding_ITwoWayAsyncQSPort();
				WS_SOA_Payment_DS_V2.SFSearchPaymentProfileByProfileIDResponse_element response_x = getAllCards.SFSearchPaymentProfileByProfileID(acct.payment_profile_id__C);
				system.debug('~~~' + acct.payment_profile_id__C);
				if(response_x.Tokens != null){
					lstPaymentTokens = WS_soa_AuthorizePaymentService.getAllPaymentProfieList(response_x.tokens);
				}
				system.debug('~~~ Total Size' + lstPaymentTokens.size());
	    	 }
    }
	
	public  AccountPaymentProfileController(ApexPages.StandardController stdController)
	    {     	 
	    	 AccountId = stdController.getId();
	    	 acct  = (Account) stdController.getRecord();
	    	 acct = [select payment_profile_id__C, id,recordType.developerName from Account where id =:accountId];
	    	
	    }
	    
	    public void DeleteToken(){
		string deltoken = ApexPages.CurrentPage().getParameters().get('deltokenid');
		//ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Cannot Delete..' + state));
		//boolean retValue = soa_WebservicesClientUtil.WS_DeletePaymentProfile(wrap.newOrder.id,deltoken);
		string merchantKey =NBTYUtils.getRecordTypeBrandMappingMap().get( acct.recordType.developerName).merchant_key__c;
		string CustomerPaymentProfile = acct.Payment_Profile_Id__c;
		WS_SOA_Payment_DS_V2.SFUpdatePaymentProfileResponse_element updateProfileResponse = new WS_SOA_Payment_DS_V2.SFUpdatePaymentProfileResponse_element();
			WS_SOA_Payment_DS_V2.URQCreditCardInfo_element ccinfo = new WS_SOA_Payment_DS_V2.URQCreditCardInfo_element();
			WS_SOA_Payment_Services.BasicHttpBinding_ITwoWayAsyncQSPort paymentService = new WS_SOA_Payment_Services.BasicHttpBinding_ITwoWayAsyncQSPort();
			ccinfo.TokenNumber = deltoken;
			updateProfileResponse = paymentService.SFUpdatePaymentProfile(merchantKey,'EC',CustomerPaymentProfile,true,'DELETE_TOKEN',false,ccinfo);
			system.debug('~~ Inside Error Processing' + updateProfileResponse.SFUpdatePaymentProfileResponseResult); 
			//processResultforProfileUpdate(updateProfileResponse.SFUpdatePaymentProfileResponseResult);
			//processResponseResult(updateProfileResponse.SFUpdatePaymentProfileResponseResult.Status,updateProfileResponse.SFUpdatePaymentProfileResponseResult.Message,updateProfileResponse.SFUpdatePaymentProfileResponseResult.ErrorMessage);
			if(updateProfileResponse.SFUpdatePaymentProfileResponseResult.Status != 'PROFILE_DELETED')
			{
				system.debug('~~~~ Response' + updateProfileResponse.SFUpdatePaymentProfileResponseResult);
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error processing Deletion.\n Please contact Administrator.'));
			
			}
			else
			{
				boolean retValue = true;
				List<OrderWizard_Wrapper.PaymentProfile> lstPaymentTokenTemp =  new List<OrderWizard_Wrapper.PaymentProfile>();
				if(retValue)
				{
					for(OrderWizard_Wrapper.PaymentProfile temp :lstPaymentTokens)
					if(temp.TokenId == deltoken)
						system.debug('~~~-----Deleted Token' +  deltoken);
					else
						lstPaymentTokenTemp.add(temp);
				}
				lstPaymentTokens = lstPaymentTokenTemp;
			}
		
		// Refresh lstpayment list
		
	}
	    
	    
	    static testMethod void testCommentsController(){
	    	testDataSetupUtil.SetupCoreData(2);
	    	testDataSetupUtil.acct.Converted_Customer_Notes__c = '3/28/67|3/28/67|UNPKD AS PER ABOVE,11/15/66|11/15/66|ORD SHPD 10/31PP,11/23/66|11/23/66|10279400713 SHP PP';
			update testDataSetupUtil.acct;
			PageReference  p = Page.AccountComments;
			Test.setCurrentPage(p); 
			test.startTest();
			ApexPages.currentPage().getParameters().put('Id', testDataSetupUtil.acct.id);
  		    ApexPages.StandardController sc = new ApexPages.StandardController(testDataSetupUtil.acct);
  		     AccountCommentsController acctCommentsController = new AccountCommentsController(sc);
  		    
	    }
}