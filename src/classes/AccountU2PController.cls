/********************************************************************************
 ********************************************************************************    
 *	Class            : AccountU2PController
 *	Author		     : Acumen Solutions: Rahul Badal
 *	Version History  : 1.0
 *	Creation         : 03/22/13
 *	Description      : Controller for AccountU2P Page
 *						
 ********************************************************************************
 ********************************************************************************/
public with sharing class AccountU2PController {
	
private ApexPages.StandardController ctrl;
  public Account acct {get;set;}
  public RecommendationsWrapper recWrap {get;set;}
  public boolean isUserforMailorder {get;set;}
  public AccountU2PController(ApexPages.StandardController stdController){
      ctrl = stdController;
      Account tempacct  = (Account) ctrl.getRecord();
      recWrap = new RecommendationsWrapper(tempacct);
      isUserforMailorder = OrderUtilities.isUserForMailOrder();
  }
  
  static testMethod void testAccountU2PController(){
  	        PageReference pref = Page.AccountU2P;
        	Test.setCurrentPage(pref);
        	TestDataSetupUtil.SetupCoreData(1);
            NBTYWSUtilTest.setupData();  
        	account a = [select id, AS_400_Customer_Number__c from Account limit 1];
        	a.AS_400_Customer_Number__c='123';
        	Test.startTest();
          	ApexPages.StandardController con = new ApexPages.StandardController(a);
           	AccountU2PController controller = new AccountU2PController(con);
           	Test.stopTest();
           system.assert(!controller.recWrap.productList.isEmpty());
  }
 
}