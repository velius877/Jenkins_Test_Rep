public with sharing class AccountCommentsController {

	public static string lineBreakChar = ',';
	public static string fieldBreakChar='\\|';
	public string AccountId 				{get;set;}
	public Account acct 					 {get;set;}
	public List <commentWrapper> commentWrapperList  {get;set;}
	public  AccountCommentsController(ApexPages.StandardController stdController)
	    {     	 
	    	 AccountId = stdController.getId();
	    	 acct  = (Account) stdController.getRecord();
	    	 acct = [select Converted_Customer_Notes__c, id from Account where id =:accountId];
	    	 commentWrapperList = new List <commentWrapper>();
	    	 if (acct.Converted_Customer_Notes__c!=null){
	    	 	string[] lineArray =acct.Converted_Customer_Notes__c.split(lineBreakChar);
	    	 	for (string s: lineArray){
	    	 		commentWrapperList.add(new commentWrapper(s));
	    	 	}
	    	 	commentWrapperList.sort();
	    	 }

	    }
	    
	    public class commentWrapper implements Comparable{
	    	public Date complaintDate {get;set;}
	    	//public string complaintDate {get;set;}
	    	public Date activityDate {get;set;}
	    	//public string activityDate {get;set;}
	    	public String	comment {get;set;}
	    	public commentWrapper(string s){
	    		system.debug('s~~~~'+s);
	    			string [] valuesArray = s.split(fieldBreakChar);
	    			// Only if valid values are present
	    			if(valuesArray.size() == 3){ 
		    			string[] complaintDateArray =valuesArray[0].split('/');
						string[] activityDateArray =valuesArray[1].split('/'); 
						system.debug('~~~~~~~'+valuesArray);
						//complaintDate = valuesArray[0];
						//activityDate = valuesArray[1];
						try{
						complaintDate = date.newinstance(integer.valueOf(complaintDateArray[2])+ 1928, integer.valueOf(complaintDateArray[0]), integer.valueOf(complaintDateArray[1]));
						}
						catch(exception e)
						{
							complaintDate = date.newinstance(1900,1,1);
						}
						try{
		    			activityDate = date.newinstance(integer.valueOf(activityDateArray[2]) + 1928, integer.valueOf(activityDateArray[0]),integer.valueOf(activityDateArray[1]));
						}
						catch(exception e){
							activityDate = date.newinstance(1900,1,1);
						}
		    			comment = valuesArray[2];
	    			}
	    	}
	    	
	    	public Integer compareTo(Object compareTo) {
				commentWrapper compareToEmp = (commentWrapper)compareTo;
				if (complaintDate == compareToEmp.complaintDate) return 0;
				if (complaintDate > compareToEmp.complaintDate) return 1;
    			return -1;        
 			}
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
  		    system.assert(!acctCommentsController.commentWrapperList.isEmpty());
	    }
}