/* 
	ReplayBatch
	DESCRIPTION
	------------------------------------------------------------------
	Author		|	Date		|	Description
	------------------------------------------------------------------
	Gary Alfrey   |	??/??/???	|	Created

*/


global class ReplayBatch implements Database.Batchable<sObject> , Database.AllowsCallouts{
	
	public Set<String> ordStatuses;
	
	global ReplayBatch(){
		if(ordStatuses == null){
			ordStatuses = new Set<String>{'Awaiting Authorization','Payment Authorization Failed'};
		}
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC){
		String query = 'SELECT Id, Name, Replay_Existing_CC__c, Credit_Card_Expiration_Date__c, Credit_Card_Type__c, Credit_Card_Number__c, Card_Holder_Name__c, Re_Authorize__c, CreatedById, ';
		query += 'Credit_Card_Token__c, Order_Status__c, customer__r.Payment_Profile_Id__c, customer__r.recordType.developerName, Bill_To_Address__c, Order_Total__c FROM Orders__c WHERE Re_Authorize__c = true AND Order_Status__c IN :ordStatuses';
		return Database.getQueryLocator(query);
	}
	
	global static void processReAuth(List <Orders__c> ordlist) {
		string groupType = 'Queue';
		Map <String, QueueSobject> oQueueMap = new Map <String, QueueSobject>();
		for (QueueSobject q : [SELECT Id, QueueId, Queue.DeveloperName FROM QueueSobject WHERE SobjectType = 'Orders__c']) {
			oQueueMap.put(q.Queue.DeveloperName, q);
		}
		
		for (Orders__c ord : ordList) {
			WS_soa_AuthorizePaymentService.paymentResponse resp = new WS_soa_AuthorizePaymentService.paymentResponse();
			WS_soa_AuthorizePaymentService.PaymentInfo paymentInfo = new WS_soa_AuthorizePaymentService.PaymentInfo();
			system.debug('-----------------------------------------------------Order Total: ' + ord.Order_Total__c);
			try {
				if (ord.Replay_Existing_CC__c) {
					resp = soa_WebservicesClientUtil.payfromExistingCard(ord.id,ord.Credit_Card_Token__c);
				} else {
					Address__c addr = [SELECT Id, Zip_Code__c, State_Providence__c, Country__c, Country_Picklist__c, City__c, 
										Address_Line_2__c, Address_Line_1__c FROM Address__c WHERE Id = :ord.Bill_To_Address__c];
					
					paymentInfo.orderId = ord.name;
					paymentInfo.amount = ord.Order_Total__c.setScale(2);
					system.debug('-----------------------------------------------------paymentInfo.amount: ' + paymentInfo.amount);
					paymentInfo.creditCardNumber = ord.Credit_Card_Number__c.replace('-','');
					paymentInfo.expiryYYYYMM = ord.Credit_Card_Expiration_Date__c;
					paymentInfo.creditCardType = ord.Credit_Card_Type__c;
					paymentInfo.nameOnCard = ord.Card_Holder_Name__c;
					paymentInfo.countryCode = addr.Country__c;
					if (paymentInfo.state == null && paymentInfo.countryCode != 'US' && paymentInfo.countryCode != 'CA') {
						paymentInfo.state = 'FO';
					} else {
						paymentInfo.state = addr.State_Providence__c;
					}
					paymentInfo.city = addr.City__c;
					paymentInfo.zipCode = addr.Zip_Code__c;
					paymentInfo.addressLine1 = addr.Address_Line_1__c==null? '': addr.Address_Line_1__c;
					paymentInfo.addressLine2 =  addr.Address_Line_2__c==null? '': addr.Address_Line_2__c;
					paymentInfo.merchantKey = NBTYUtils.getRecordTypeBrandMappingMap().get(ord.customer__r.recordType.developerName).merchant_key__c;
					boolean hasPaymentProfile =  ord.customer__r.Payment_Profile_Id__c != null;
					paymentInfo.paymentProfileID = hasPaymentProfile? ord.customer__r.Payment_Profile_Id__c : '';
					system.debug('paymentInfo~~~'+paymentInfo);
					resp = soa_WebservicesClientUtil.ProcessPaymentForNewCard(paymentInfo,hasPaymentProfile);
					
				}
			} catch (exception e) {
				ord.Order_Status__c='Payment Authorization Failed';
				ord.OwnerId = oQueueMap.get('Orders_Payment_Authorization_Failed').QueueId;
				//Set Queue to Orders - Payment Authorization Failed
			}
		
			system.debug('----------------------------------------------------------Response resp: ' + resp);
			if (resp.TokenNumber != '') {
				system.debug('----------------------------------------------------------Replay Success');
				//ord.ownerId=userInfo.getUserId();//US468 this needs to be the original owner CreatedByID
				ord.OwnerId = ord.CreatedById;
				// 060982013 RB changes for Payment information
				system.debug('~~~~~ Expiration date of existing card' + paymentInfo.expiryYYYYMM);
				ord.Payment_Authorization_Code__c = resp.AuthorizationCode;
				ord.Credit_Card_Token__c = resp.TokenNumber;
				ord.Payment_Profile_ID__c = resp.PaymentProfileID;
				ord.Payment_Transaction_Reference_Number__c = resp.TransactionReferenceNumber;
				ord.Payment_Transaction_Reference_Index__c = resp.TransactionReferenceIndex;
				ord.Bank_Response_Date_Time__c = resp.BankResponseDateTime;
				if (ord.Replay_Existing_CC__c) {
					ord.Authorization_Amount__c = ord.Order_Total__c;
				} else {
					ord.Authorization_Amount__c = paymentInfo.amount;
				}
				ord.Order_Status__c='Pending Submission';
				//Null out the CC # encrypted field
				ord.Credit_Card_Number__c = null;
				ord.Re_Authorize__c = false;
			} else if(resp.StatusCode != '') {
				//Leave all fields
				//Set status to Payment Authorization Declined
				ord.Order_Status__c = 'Payment Declined';
				//Set Queue to Orders - Payment Declined
				ord.OwnerId = oQueueMap.get('Orders_Payment_Declined').QueueId;
			} else {
				system.debug('----------------------------------------------------------Replay Fault');
				//Leave all fields
				//Set status to Payment Authorization Failed
				ord.Order_Status__c = 'Payment Authorization Failed';
				//Set Queue to Orders - Payment Authorization Failed
				ord.OwnerId = oQueueMap.get('Orders_Payment_Authorization_Failed').QueueId;
			}
		}
		update ordList;
	}
	
	global static void processRequest() {
		
	}

	global void execute(Database.BatchableContext BC, List<sObject> scope) {
		//Scope is always 1
		List<Orders__c> ordList = (List<Orders__c>)scope;
		processReAuth(ordList);
	}

	global void finish(Database.BatchableContext BC) {
		AuthDownTimeUtils.checkScheduleStatus2();
	}
}