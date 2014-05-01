trigger AccountTrigger on Account (before insert, before update, after insert, after update) {
	if (!NBTYUtils.bTriggersOff){
		List <Address__c> addressList = new List <Address__c>();
		List <Account> updAccount = new List <Account>();
		for (Account acct: trigger.new){
			if (trigger.isAfter){
				if (AccountSyncAddresses_Helper.bAddressBatch){
					AccountSyncAddresses_Helper.bAddressBatch=false;
			        addressList.add(AccountSyncAddresses_Helper.generateAddressRecord(acct,acct.ShippingStreet!=null,acct.BillingStreet!=null,true));   
				}
				if (Trigger.isAfter&Trigger.isInsert){ 
					Account acct2 = new Account (id=acct.id);
					acct2.external_key__c =acct.customer_number__c; //Needed for external integration
					updAccount.add(acct2);
				}
			}			
		}
		
		if (trigger.isBefore&&trigger.isInsert)	{
			AccountTriggerHelper.AccountBeforeInsert(trigger.new);
		}
			 
		if (!addressList.isEmpty()){
			insert addressList;
		} 
		if (!updAccount.isEmpty()){
			update updAccount;
		}
	}
}