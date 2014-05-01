/* 
	CiscoIVR_WS
	DESCRIPTION
	------------------------------------------------------------------
	Author		|	Date		|	Description
	------------------------------------------------------------------
	Gary Alfrey |	4/30/2013	|	Created

*/

global class CiscoIVR_WS {
	
	public static CiscoIVR_ComplexTypes.Response GenerateResponse(String objId, String Status, Boolean isValid){
		CiscoIVR_ComplexTypes.Response resp = new CiscoIVR_ComplexTypes.Response();
		if(objId != null){
			resp.objectId = objId;
		}
		resp.isValid = isValid;
		resp.status = Status;
		return resp;
	}
	
	webservice static CiscoIVR_ComplexTypes.Response CiscoIVR(CiscoIVR_ComplexTypes.Cisco_IVR ivr){
		return IVRHelper(ivr);
	}
	
	public static CiscoIVR_ComplexTypes.Response IVRHelper(CiscoIVR_ComplexTypes.Cisco_IVR ivr){
		try {
			
			String ceds = ivr.CED;
			Integer x = ceds.length();
			Integer y;
			if(ivr.searchType == 'Case'){
				y = 8;
			}else if(ivr.searchType == 'Customer'){
				y = x;
			}
			String z = '';
			if(x < y){
				for(Integer i=x;i<y;i++){
					z = z + '0';
				}
				system.debug('----------------------------z: ' + z);
				ceds = z + ceds; 
			}
			system.debug('----------------------------ceds: ' + ceds);
			List<Case> cse;
			List<Account> acct;
			system.debug('----------------------------SearchType: ' + ivr.searchType);
			if(ivr.searchType == 'Case'){
				cse = [SELECT Id FROM Case WHERE CaseNumber = :ceds ];
				system.debug('----------------------------CASE: ' + cse);
				if(cse.size() > 0){
					return GenerateResponse(cse[0].Id, 'Case Success', true);
				}
			}else if(ivr.searchType == 'Customer'){
				acct = [SELECT Id FROM Account WHERE Customer_Number__c = :ceds ];
				if(acct.size() < 1){
					acct = [SELECT Id FROM Account WHERE AS_400_Customer_Number__c = :ceds ];
				}
				if(acct.size() < 1){
					acct = [SELECT Id FROM Account WHERE VW_Passport_Number__c = :ceds];
				}
				system.debug('----------------------------Account: ' + acct);
				if(acct.size() > 0){
					return GenerateResponse(acct[0].Id, 'Customer Success', true);
				}
			}
			
			return GenerateResponse(null, ivr.searchType + ' Failure', false);
			
		}catch(Exception e){
			return GenerateResponse(null, 'Fatal Error: ' + e, false);
			
		}
	}
	
	
}