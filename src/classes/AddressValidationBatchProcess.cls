/********************************************************************************
 ********************************************************************************	
 *	Class			: AddressValidationBatchProcess
 *	Author			: Acumen Solutions: Latha Davuluri
 *	Version History	: 
 *	Creation		 : 04/29/13
 *	Description		: Batch process to validate address whose Pending_Avalara_Response__c = true.
 *						
 ********************************************************************************
 ********************************************************************************/

global class AddressValidationBatchProcess implements Database.Batchable<sobject>,Database.AllowsCallouts,Database.Stateful
{
	
	//constructor
	global AddressValidationBatchProcess(){ }
		
	global Database.QueryLocator start(Database.BatchableContext BC)
	{
		List<String> countryList = new List<String> {'US','USA','UNITED STATES','UNITES STATES OF AMERICA','CANADA','CA',''};
		string Query = 'Select Id from Address__c Where Pending_Avalara_Response__c=true and Validated__c=false and Validation_Error_Reason__c=null and Validation_Override__c=false and Country__c in :countryList';
		
		return Database.getQueryLocator(Query);
	}

	global void execute(Database.BatchableContext BC, sobject[] scope)
	{
		Set<Id> adrToVal = new Set<Id>();
		for(Sobject s : scope)
		{
			Address__c a = (Address__c)s;
			adrToVal.add(a.Id);
		}
		
		if (!adrToVal.isEmpty()){
			try{
				AddressTriggerHelper.callAddressValidate(adrToVal,false); //Synchronous call out for Avalara WS
			}
			catch(Exception e){
				system.debug('**Error in Batch job :'+ e.getMessage());
			}
		}
	 }

	global void finish(Database.BatchableContext BC)
	{
		BatchUtilities.batchEmailSuccess(BC, 'AddressValidationBatch');
	}
	
	
}