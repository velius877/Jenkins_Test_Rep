/********************************************************************************
 ********************************************************************************    
 *  Class            : Case Trigger Helper
 *  Author           : Acumen Solutions: Mitch Malleo
 *  Version History  : 
 *  Creation         : 09/13/13
 *  Description      : Trigger helper for the case object
 *                      
 ********************************************************************************
 ********************************************************************************/

public with sharing class CaseTriggerHelper {
	
	public static boolean isFromChild = false;
	public static boolean alreadyFired = false;
	
	public static Map <Id, RecordType> rtMap ;
	
	public static Map <Id, RecordType> getRtMap(){
		if (rtMap==null){
			rtMap = new Map <Id, RecordType>();
			for (RecordType rt: [select id, developername, name from RecordType where sObjectType='Case' ]){
				rtMap.put(rt.id,rt);
			}
		}
		return rtMap;
	}
	
	public static void beforeInsert(List<Case> triggerNew){
		syncAccountLookups(triggerNew, null);
		for (Case c: triggerNew){
			// DE854 -- State not maping correctly. If the state field is not blank and is only 2 characters assume good
			if (!String.isBlank(c.Consumer_State__c)){
				if (c.Consumer_State__c.length() == 2){
					c.Consumer_State_PickList__c = c.Consumer_State__c;
				}
			}
			// DE854 -- If the state pick list is filled in, copy it over to state field as long as it's blank
			// otherwise, use the state field to look up the abbreviation, assuming they put in full state name.
			if (!String.isBlank(c.Consumer_State_Picklist__c) && String.isBlank(c.Consumer_State__c)){
				c.Consumer_State__c = c.Consumer_State_Picklist__c;
			} else if (!String.isBlank(c.Consumer_State__c) && String.isBlank(c.Consumer_State_Picklist__c)){
				c.Consumer_State_Picklist__c = String.valueOf(State_Abbreviation_Mapping__c.getValues(c.Consumer_State__c.toLowerCase().Capitalize()).Abbreviation__c);
			}
		}
	}
	
	public static void beforeUpdate(List<Case> triggerNew, Map <Id, Case> triggerOld){
		syncAccountLookups(triggerNew, triggerOld);
		isEscalatedStandardFieldUpdate(triggerNew);
		if (!isFromChild&!alreadyFired) checkForPqmCaseUpdates(triggerNew);
		if(triggerNew != null && triggerOld != null)
		{
			setAgileStatusDetail(triggerNew,triggerOld);
		}
		
		for (Case c: triggerNew){
			if (!String.isBlank(c.Consumer_State_Picklist__c)&&String.isBlank(c.Consumer_State__c)){
				
			}
		}
	}
	
	// DE857 -- added triggerOld param; using the Id, Case to verify old vs new to allow deleting
	public static void syncAccountLookups(List<Case> triggerNew, Map<Id, Case> triggerOld){
		for(Case c : triggerNew){
			// DE857 -- If the new case has a blank AccountId/Customer__c while the old one did not
			// then it was deleted and we should allow it. Also, make them both blank.
			if (c.Id != null && ((String.isBlank(c.AccountId) && !String.isBlank(triggerOld.get(c.Id).AccountId)) ||
			    (String.isBlank(c.Customer__c) && !String.isBlank(triggerOld.get(c.Id).Customer__c)))){
				c.Customer__c = null;
				c.AccountId = null;
			} else {
				if(c.AccountId == null && c.Customer__c != null){//second case = only Customer__c has a value: record this to accountId field
					c.AccountId = c.Customer__c;
				}else if(c.AccountId != null && c.Customer__c == null){//third case = only accountId has a value: record this to the Customer__c field
					c.Customer__c = c.AccountId;
				}
			}
		}
	}
	
	public static void checkForPqmCaseUpdates(List <Case> triggerNew){
		alreadyFired = true;
		for (Case c: triggerNew){
			if (getRtMap().get(c.RecordTypeId).developerName =='Product_Complaint'&&C.Status!='Closed'){
				c.Agile_Status__c=null;
				c.Agile_Status_Description__c=null;
				//soa_WebservicesClientUtil.sendCaseToPQM(c.id); not needed; called by batch every 5 minutes
			}
		}
	}
	
	public static void setAgileStatusDetail(List <Case> triggerNew, Map<Id, Case> triggerOld){
		
		for (Case c: triggerNew){
			boolean bContinue = true;
			if (triggerOld !=null) {
				if (c.Agile_Status__c==triggerOld.get(c.id).agile_status__c){
					bContinue=false;
				}
			}
			if (bContinue){
				system.debug(c);
				PQM_Return_Code__c codeDetail = PQM_Return_Code__c.getInstance(c.agile_status__c);
				if (codeDetail!=null)			c.agile_status_description__c = codeDetail.description__c;
				if (c.Agile_Status__c != null && c.Agile_Status__c != '-99' && c.Agile_Status__c != '-98' && !triggerOld.get(c.id).Sent_to_PQM__c){
					c.Sent_to_PQM__c=true;
					c.Sent_to_PQM_date__c = system.now();
				}
				system.debug(c.agile_status_description__c);
			}
		}
	}
	
	@Future(callout=true) 
	public static void sendCaseToPqm(Id caseId){
		soa_WebservicesClientUtil.sendCaseToPQM(caseId);
	}
	
	public static void isEscalatedStandardFieldUpdate(List<Case> triggerNew)
	{
		for(Case c : triggerNew)
		{
			if(c.Escalated__c == 'Yes')
			{
				c.IsEscalated = true;
			} 
			else
			{
				c.IsEscalated = false;
			}
		}
	}
}