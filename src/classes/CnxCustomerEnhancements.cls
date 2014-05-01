global with sharing class CnxCustomerEnhancements {
	
	public static String generateJsonFailureCallLog(String result, String longResult, String description){
		JSONGenerator gen = JSON.createGenerator(true);
		gen.writeStartObject();
		gen.writeFieldName(result);
		gen.writeStartObject();
		gen.writeStringField('Title', longResult ); 
		gen.writeStringField('Text', description );
		gen.writeEndObject();          
		gen.writeEndObject();
		return gen.getAsString();
	}
	
	public static String generateJsonSuccessCallLog(){
		JSONGenerator gen = JSON.createGenerator(true);
		gen.writeStartObject();
		gen.writeStringField('result', '');
		gen.writeEndObject();
		return gen.getAsString();
	}
	
	webservice static String updateCallLog( String sfdcId, String callObject){
		try {
			system.debug('---------------------------------callObject: ' + callObject);
			
/****************************Transformation logic for url encoded strings**********************************************/
			if(!callObject.startsWith('{')){
				callObject = encodingUtil.urlDecode(callObject, 'UTF-8');
				callObject = callObject.removeStart('callObject=');
				system.debug('----------------------------callObject Post transformation: ' + callObject);
			}
/*******************************************End transformation*********************************************************/
			
			JSONParser parser = JSON.createParser(callObject);
			String uniqueId;
			String id;
			String dnis; //DNIS__c
			String sender; //ANI__c
			String callType;
			String perVar1 = ''; //Customer
			String perVar2 = ''; //Order
			String perVar3 = ''; //Case
			String perVar4 = ''; //Brand
			String perVar5 = ''; //IVR Status
			String perVar6 = ''; //CED
			String perVar7 = ''; //QueueName
			String perVar8 = '';
			String perVar9 = '';
			String perVar10 = '';
			while (parser.nextToken() != null) {
				system.debug('------------------------------------getCurrentToken: ' + parser.getCurrentToken());
				if (parser.getCurrentToken() == JSONToken.FIELD_NAME){
					String fieldName = parser.getText();
					system.debug('------------------------------------fieldName: ' + fieldName);
					// Get the value.
					parser.nextToken();
					system.debug('------------------------------------getText: ' + parser.getText());
					if(fieldName == 'UniqueId'){
						uniqueId = parser.getText();
					}else if(fieldName == 'DNIS'){
						dnis = parser.getText();
					}else if(fieldName == 'Sender'){
						sender = parser.getText();
					}else if(fieldName == 'PerVar1'){
						perVar1 = parser.getText();
					}else if(fieldName == 'PerVar2'){
						perVar2 = parser.getText();
					}else if(fieldName == 'PerVar6'){
						perVar6 = parser.getText();
					}else if(fieldName == 'PerVar4'){
						perVar4 = parser.getText();
					}else if(fieldName == 'PerVar5'){
						perVar5 = parser.getText();
					}
				}
			}
			
			system.debug('------------------------------------UniqueId: ' + uniqueId);
			system.debug('------------------------------------sender: ' + sender);
			system.debug('------------------------------------dnis: ' + dnis);
			system.debug('------------------------------------perVar1: ' + perVar1);
			system.debug('------------------------------------perVar2: ' + perVar2);
			system.debug('------------------------------------perVar3: ' + perVar3);
			system.debug('------------------------------------perVar4: ' + perVar4);
			system.debug('------------------------------------perVar5: ' + perVar5);
			system.debug('------------------------------------perVar6: ' + perVar6);
			
			Task t = [SELECT Id,ANI__c, DNIS__c, IVR_Customer__c,IVR_Order__c, Description, CED__c, Brand__c FROM Task WHERE CNX2__UniqueCallId__c = :uniqueId];
			t.ANI__c = sender;
			t.DNIS__c = dnis;
			if(perVar1 != null && perVar1 != ''){
				t.IVR_Customer__c = perVar1;
			}
			if(perVar2 != null && perVar2 != ''){
				t.IVR_Order__c = perVar2;
			}
			if(perVar3 != null && perVar3 != ''){
				t.IVR_Case__c = perVar3;
			}
			t.Brand__c = perVar4;
			if(perVar5 != null){
				t.IVR_Status__c = perVar5;
			}
			if(perVar6 != null && perVar6 != ''){
				t.CED__c = integer.valueOf(perVar6);
			}
			
			t.Description = callObject;
			update t;
			
			String userId = userInfo.getUserId();
			User c = [SELECT Id FROM User WHERE Id = :userId];
			c.Task_Record__c = t.Id;
			system.debug('-------------------------------------------User ' + c.Task_Record__c);
			update c;
			
			system.debug('-------------------------------------------User ' + c);
			
			return generateJsonSuccessCallLog();
		
		}catch(Exception e){
			return generateJsonFailureCallLog('Failure', 'Call Failure', 'Failed to create activity');
		}
	}
	
	public static String generateJsonTransfer(String result, String objectId, String objectType){
		JSONGenerator gen = JSON.createGenerator(true);
		gen.writeStartObject();
		gen.writeFieldName(result);
		gen.writeStartObject();
		gen.writeStringField('objectId', objectId  );
		gen.writeStringField('object', objectType );
		gen.writeEndObject();  
        gen.writeEndObject();
		return gen.getAsString();
	}
	
	webService static String getScreenTransferInfo(String pageInfo, String callObject){
		try{
			//parse the pageInfo Argument
			Map<String, Object> pageInfoMap = (Map<String, Object>)JSON.deserializeUntyped(EncodingUtil.urlDecode(pageInfo, 'UTF-8'));
			String objectType = (String)pageInfoMap.get('object');
			String objectId = (String)pageInfoMap.get('objectId');
			
			//parse the callObject Argument
			Map<String, Object> callObjectMap = (Map<String, Object>)JSON.deserializeUntyped(EncodingUtil.urlDecode(callObject, 'UTF-8'));
			String sender = (String)callObjectMap .get('Sender');
			
			return generateJsonTransfer('result', objectId, objectType);
		}catch(Exception e){
			return generateJsonTransfer('error', 'Transfer Error', 'Unable to Transfer Screen');
		}
	}
	
	
	
	
}