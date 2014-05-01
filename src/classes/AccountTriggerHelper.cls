public   class AccountTriggerHelper {


	public static string formatTelephone (string inputPhone){
			
		    if(inputPhone!=null && inputPhone!=''){
		      if(inputPhone.length()==10){
		        inputPhone = '('+inputPhone.substring(0, 3) + ') ' +inputPhone.substring(3, 6) + '-' + inputPhone.substring(6, 10);
		    	}
			}
		return inputPhone;
	}
	
	public static void AccountBeforeInsert(List <Account> newAccounts){
		for (Account a: newAccounts){
			if (a.Gender__c=='NULL') a.Gender__c=null;
			a.Phone = formatTelephone(a.Phone);
			a.PersonHomePhone = formatTelephone(a.PersonHomePhone);
		}
	}
}