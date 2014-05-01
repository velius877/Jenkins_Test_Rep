/********************************************************************************
 ********************************************************************************	
 *	Class			: Case_UpdatePQMBatch
 *	Author			: Acumen Solutions: Peter Nebel
	*	Version History	: 
 *	Creation		 : 10/10/13
 *	Description		: Batch process to send cases not in status 0 to PQM.
 *						
 ********************************************************************************
 ********************************************************************************/
global class Case_UpdatePQMBatch implements Database.Batchable<sobject>,Database.AllowsCallouts
{
	global String Query;
	global Set <String> statusCodes ;
	global Set <String> caseNumbers;
	global string sendStatus =null;
	global string recordTypeName = 'Product_Complaint';
	//constructor
	global Case_UpdatePQMBatch(Set<string >sStatus){
	 statusCodes=sStatus;
		
	
	}
	global Case_UpdatePQMBatch(){
	
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC){
		query = 'SELECT Id FROM Case ';
		if (statusCodes !=null) query+= ' WHERE	agile_status__c in:statusCodes ';
		else query +=' WHERE agile_status__c =:sendStatus ';
		query+=' AND recordType.developerName =:recordTypeName ';
		if (caseNumbers!=null) query+= ' AND caseNumber in :caseNumbers ';

		system.debug(Query);
		return Database.getQueryLocator(Query);
	}

	global void execute(Database.BatchableContext BC, sobject[] scope){
		List<Case> caseList = new List<Case>();
		for(Sobject s : scope)
		{
			Case c = (Case)s;
			 ws_Soa_CaseCreateService_v2.ComplaintUpdateResult updateResult =soa_WebservicesClientUtil.sendCaseToPQM(c.id);
		}
		
	}

	global void finish(Database.BatchableContext BC){
		BatchUtilities.batchEmailSuccess(BC, 'Case_UpdatePQMBatch');
	}
	

}