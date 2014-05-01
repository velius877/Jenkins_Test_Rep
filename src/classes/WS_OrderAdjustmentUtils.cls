/* 
*  Class		   : WS_OrderAdjustmentUtils 
*  Author		  : Pavan Jasthi - Acumen Solutions
*  Creation		 : 02/10/2014
*  Description	 : Process Order adjustments  Batch Creation.
*
*/
public with sharing class WS_OrderAdjustmentUtils {
	
	public static WS_soa_OrderAdjustmentService.RefundRequest refundRequest ;
	public static WS_soa_OrderAdjustmentService.MiscChargeRequest chargeRequest;
	public static string PROCESSED_STATUS = 'Processed';
	public static set <String> validTransStatuses = new Set <String>{'ST', 'AS'};
	public static set <String> nonSubmittedOrderCodes = new Set <String>{'ER','BO'};
	public static decimal neededAmount;
	

	public static string getExpDate(Order_Adjustment__c oa){
		string expDate = oa.credit_card_expiration_date__c;
		if (expDate!=null){
			expDate = expDate.substring(4,6)+expDate.substring(2,4);
		}
		return expDate;
	}
	
	public static string getRefundPaymentType(order_adjustment__c oa){
		string ccType; 
		if (oa.recordType.developerName=='Refund'){
			ccType=oa.Credit_Card_Type__c;
			if (NBTYUtils.getCCTypeMappings('Name').get(ccType)!=null){
				return NBTYUtils.getCCTypeMappings('Name').get(ccType).Gateway_value__c;
			}
			else return null;
		}
		else return null;
	}
	
	public static string getPaymentType(order_adjustment__c oa){
		if (oa.Payment_Method__c=='Check'){
			return 'C';
		} else if (oa.Payment_Method__c=='Paypal'){
			return 'Y';
		} else {
			if (oa.Payment_Method__c == 'Credit Card') {
				Map<String, Credit_Card_Type_Mapping__c> ccTypeMap = new Map<String, Credit_Card_Type_Mapping__c>();
				system.debug('-------------------------Credit_Card_Type__c: ' + oa.Credit_Card_Type__c);
				string ccType = oa.Credit_Card_Type__c;
				if (ccType != null) {
					if (ccType.length() > 1) {
						ccTypeMap = NBTYUtils.getCCTypeMappings('Name');
						system.debug('----------------------------------------ccTypeMap1: ' + ccTypeMap);
						Credit_Card_Type_Mapping__c cctm = ccTypeMap.get(ccType);
						system.debug('----------------------------------------cctm1: ' + cctm);
						if (cctm != null) {
							return cctm.web_value__c;
						}
					} else {
						ccTypeMap = NBTYUtils.getCCTypeMappings('Web');
						system.debug('----------------------------------------ccTypeMap2: ' + ccTypeMap);
						Credit_Card_Type_Mapping__c cctm = ccTypeMap.get(ccType);
						system.debug('----------------------------------------cctm2: ' + cctm);
						if (cctm != null) {
							return cctm.web_value__c;
						}
					}
				} else {
					return null;
				}
				//return NBTYUtils.getCCTypeMappings('Name').get(ccType).web_value__c;
			} else {
				 return null;
			}
			return null;
		}
	}

	
	public static void createCase(Order_Adjustment__c odj,string subreason, string reason) {
		Case newCase = new Case();
		RecordType recType = [SELECT Id, Name, DeveloperName FROM RecordType WHERE sObjectType = 'Case' and DeveloperName = 'Follow_Up' limit 1];
		QueueSobject qu = [SELECT Id, QueueId FROM QueueSobject WHERE Queue.DeveloperName = 'Admin_Support' limit 1];
		newCase.AccountId = odj.Customer__c;
		newCase.RecordTypeId = recType.Id;
		newCase.Related_Order_Adjustment__c = odj.Id;
		newCase.Origin = 'Refund Auto Generated Case';
		newCase.Case_Sub_Reason__c = 'Could Not be Posted to AS400';
		newCase.Case_Reason__c = reason;
		//newCase.Case_Resolution__c = 'Manually Posted Refund to AS400'; Commented out per JLB 04072014
		newCase.Related_Order__c = odj.Related_Order__c;
		newCase.OwnerId = qu.QueueId;
		insert newCase;
	}
	
	public static Map <String, Decimal> calcMaxAmountPerTxn(List <Credit_Refund_Detail__c> crdList , Order_Adjustment__c oa){
		/*Begin logic to store already refunded amounts to properly calc remaining amount*/
		Map <String, Decimal> alreadyProcessedCrdMap = new Map <String, Decimal>();
		for (Credit_Refund_Detail__c tempcrd: crdList){
			alreadyProcessedCrdMap.put(tempcrd.Original_Transaction_reference_Number__c,tempcrd.Original_Amount__c);  //put all possible refunded transaction reference numbers in a set to query ahead...
		}
		if (!alreadyProcessedCrdMap.isEmpty()){
			for (Credit_Refund_Detail__c tempcrd: [select id, Original_Amount__c, Refund_Amount__c, order_adjustment__r.name, Original_Transaction_reference_Number__c
													from Credit_Refund_Detail__c 
													where order_adjustment__c !=:oa.id 
													and refund_status__c =:WS_OrderAdjustmentUtils.PROCESSED_STATUS 
													and status__c in :WS_OrderAdjustmentUtils.validTransStatuses]){
				decimal maxAmount = alreadyProcessedCrdMap.get(tempcrd.Original_Transaction_reference_Number__c); // this is the max amount value for the refunds individual txn
				
				if (tempcrd.Original_Amount__c>0&& maxAmount > 0 ){  //really doesnt matter unless found result and current line have value on it
					maxAmount-=tempcrd.Refund_Amount__c; //deduct the already processed amount
					alreadyProcessedCrdMap.put(tempcrd.Original_Transaction_reference_Number__c, maxAmount);
				}
			}
		}
		return alreadyProcessedCrdMap;
	}
	
	public static WS_soa_OrderAdjustmentService.OrderAdjustmentResponse doCallout(Order_Adjustment__c oa) {
		WS_soa_OrderAdjustmentService.OrderAdjustmentSOAP oaService = new WS_soa_OrderAdjustmentService.OrderAdjustmentSOAP();
		oa = [select id,  Customer__r.payment_profile_id__c, Related_Order_Paypal_Transaction_ID__c, Salesforce_Order_Number__c, customer__r.AS_400_Customer_Number__c, customer__r.personEmail, customer__r.lastname, customer__r.recordType.developerName, as400_order_number__c, Refund_Type__c, Payment_Method__c, Credit_Card_Type__c, Credit_Card_Token__c,Owner.Alias, currencyIsoCode, recordType.developerName, related_order__c, Credit_Card_Number__c,  Refund_or_Misc_Amount__c,  Credit_Card_Expiration_Date__c, Credit_Card_Name__c, Name  from Order_Adjustment__c where id =:oa.id];//requiry to make sure  have fields
		List <Credit_Refund_Detail__c>crdList;
		boolean bNeedsCallout = true; // boolean to determine whether to actually call service or not
		string orderNumber = oa.Salesforce_Order_Number__c;
		boolean bCreditDetail = false;
		if (oa.RecordType.DeveloperName == 'Refund') {
 			refundRequest = new WS_soa_OrderAdjustmentService.RefundRequest();
			if (oa.Payment_Method__c=='Credit Card'){
				try {
					crdList = [select Credit_Card_Token__c, Refund_Status__c, Order_Adjustment__c, Original_Amount__c, Credit_Card_Type__c, Original_Transaction_Reference_Number__c, Refund_Amount__c, Status__c, Status_Detail__c 
								FROM Credit_Refund_Detail__c 
								where order_Adjustment__c =:oa.id and refund_status__c !=:PROCESSED_STATUS
								and status__c in :validTransStatuses];
				} catch (exception e) {
					system.debug('No Credit Details... ');
				}
				//orderNumber = oa.as400_order_number__c;
				refundRequest.creditDetail = new WS_soa_OrderAdjustmentService.CreditDetail();
				refundRequest.refundType='K';
				refundRequest.creditDetail.IndustryType='EC';
				refundRequest.creditDetail.IsBankLinkDownReprocessing ='N';
				refundRequest.creditDetail.MerchantKey=NBTYUtils.getRecordTypeBrandMappingMap().get( oa.customer__r.recordType.developerName).merchant_key__c;
				refundRequest.creditDetail.OrderID=orderutilities.zeroLPAD(oa.as400_order_number__c, 10);
				WS_soa_OrderAdjustmentService.OrderAdjustmentResponse oaResponse ;
				if (neededAmount==null) neededAmount = oa.Refund_or_Misc_Amount__c;
								
			} else if (oa.Payment_Method__c=='Paypal'){
				refundRequest.refundType='Y';
				refundRequest.PaypalDetail = new WS_soa_OrderAdjustmentService.PaypalDetail();
				refundRequest.PaypalDetail.refundType =  oa.Refund_Type__c =='Full Refund'? 'F':'P';
				//refundRequest.PaypalDetail = new WS_soa_OrderAdjustmentService.PaypalDetail();
				if (oa.Related_Order_Paypal_Transaction_ID__c!=null)
					refundRequest.PaypalDetail.transactionID=oa.Related_Order_Paypal_Transaction_ID__c;
				else {
					oa.Status__c = 'Error';
					oa.Error_Reason__c = 'No Paypal Transaction ID available; refund manually'; 
					bNeedsCallout=false;
				}
				refundRequest.PaypalDetail.userReqElement1=NBTYUtils.getRecordTypeBrandMappingMap().get( oa.customer__r.RecordType.DeveloperName).server_prefix__c;
			} else if (oa.Payment_Method__c=='Check'){
				refundRequest.refundType='C'; //Check refund Type
			} else {
				bNeedsCallout=false;
			}
			//callout
		} else {
			boolean bIn400 = true;
			if (oa.AS400_Order_Number__c==null){
				if (oa.Related_Order__c==null){
					bIn400=false;
				}
				else {
					Orders__c ord =[select id, Order_Submitted__c , Order_Status_Code__c From Orders__c where id =:oa.Related_Order__c];
					if (ord.order_submitted__c==false|| ord.order_submitted__c==true && (ord.order_status_code__c==null|| nonSubmittedOrderCodes.contains(ord.order_status_code__c)) ){
						bIn400=false;
					}
				}
			}
			if (!bIn400){
				oa.Status__c = 'Error';
				oa.Error_Reason__c = 'Order is not in AS400';
				bNeedsCallout=false;
			}
			else {
				chargeRequest = new WS_soa_OrderAdjustmentService.MiscChargeRequest();
				if (oa.Payment_Method__c=='Credit Card'){
					chargeRequest.miscChargeType='N';
					chargeRequest.creditDetail = new WS_soa_OrderAdjustmentService.CreditDetailType();
					chargeRequest.creditDetail.NewCreditCardDetails = new WS_soa_OrderAdjustmentService.NewCreditCardDetails();
					chargeRequest.creditDetail.NewCreditCardDetails.Amount=STRING.VALUEOF(oa.Refund_or_Misc_Amount__c);
					chargeRequest.creditDetail.NewCreditCardDetails.IndustryType='EC';
					chargeRequest.creditDetail.NewCreditCardDetails.SaveCCInfoOnBankLinkDown='N';
					chargeRequest.creditDetail.NewCreditCardDetails.MerchantKey=NBTYUtils.getRecordTypeBrandMappingMap().get( oa.customer__r.recordType.developerName).merchant_key__c;
					chargeRequest.creditDetail.NewCreditCardDetails.OrderID=oa.name;
					chargeRequest.creditDetail.NewCreditCardDetails.CreditCardNumber = oa.Credit_Card_Number__c;
					chargeRequest.creditDetail.NewCreditCardDetails.CreditCardExpiryDate =oa.Credit_Card_Expiration_Date__c;
					chargeRequest.creditDetail.NewCreditCardDetails.CreditCardTypeID = WS_soa_AuthorizePaymentService.getCreditCardTypeId(oa.Credit_Card_Type__c);
					chargeRequest.creditDetail.NewCreditCardDetails.nameOnTheCreditCard = oa.Credit_Card_Name__c;
					chargeRequest.creditDetail.NewCreditCardDetails.CreatePaymentProfileIndicator='0';
					chargeRequest.creditDetail.NewCreditCardDetails.PaymentProfileID=oa.Customer__r.payment_profile_id__c;
				} else if (oa.Payment_Method__c=='Existing Card'){
					chargeRequest.creditDetail = new WS_soa_OrderAdjustmentService.CreditDetailType();
					chargeRequest.miscChargeType='E';
					chargeRequest.creditDetail.ExistingCreditCardDetails = new WS_soa_OrderAdjustmentService.ExistingCreditCardDetails();
					chargeRequest.creditDetail.ExistingCreditCardDetails.amount=string.valueOf(oa.Refund_or_Misc_Amount__c);
					chargeRequest.creditDetail.ExistingCreditCardDetails.IndustryType='EC';
					chargeRequest.creditDetail.ExistingCreditCardDetails.IsBankLinkDownReprocessing='N';
					chargeRequest.creditDetail.ExistingCreditCardDetails.MerchantKey=NBTYUtils.getRecordTypeBrandMappingMap().get( oa.customer__r.recordType.developerName).merchant_key__c;
					chargeRequest.creditDetail.ExistingCreditCardDetails.OrderID=oa.name;
					chargeRequest.creditDetail.ExistingCreditCardDetails.TokenNumber=oa.Credit_Card_Token__c; 
					chargeRequest.creditDetail.ExistingCreditCardDetails.PaymentProfileID=oa.Customer__r.payment_profile_id__c;
				} else {
					bNeedsCallout=false;//Cash or Check
				}
			//callout
			}
		}
		WS_soa_OrderAdjustmentService.OrderAdjustmentResponse oaResponse;
		if (bNeedsCallout) {
			string requestType = oa.RecordType.DeveloperName == 'Refund'? 'C':'D';
			string paymentType = getPaymentType(oa);
			string expDate= oa.Credit_Card_Expiration_Date__c;
			string refundPaymentType = getRefundPaymentType(oa);
			try{
				boolean bMock = false;
				if (WS_Integration__c.getValues('OrderAdjustmentMockService')!=NULL){
					if (WS_Integration__c.getValues('OrderAdjustmentMockService').value__c=='TRUE' ){
						bMock=true;
						oaResponse =  temp_Release3MockServices.test_mockOrderAdjustmentService(oa.name);
					}
				}
				if (!bMock){ //must be approved to be sent through I/F
					if (oa.Payment_Method__c=='Credit Card'&&requestType=='C'){
						if (!crdList.isEmpty()){
							Map <String, Decimal> maxAllowedCrdMap  = WS_OrderAdjustmentUtils.calcMaxAmountPerTxn(crdList,oa);
							for (Credit_refund_Detail__c crd: crdList){
								if (crd.refund_status__c!='Rejected'){
									refundRequest.creditDetail.TokenNumber=crd.Credit_Card_Token__c; 
									decimal MaxAmountAllowed = maxAllowedCrdMap.get(crd.Original_Transaction_reference_Number__c);
									crd.Refund_Amount__c = neededAmount > MaxAmountAllowed ? MaxAmountAllowed :neededAmount;
									refundRequest.creditDetail.transactionReferenceNumber=crd.Original_Transaction_Reference_Number__c; 
									if (crd.Refund_Amount__c>0){
											try {
											oaResponse = oaService.OrderAdjustment(orderutilities.zeroLPAD(orderNumber, 10),  crd.Refund_Amount__c, oa.CurrencyIsoCode, paymentType, oa.customer__r.AS_400_Customer_Number__c,  oa.customer__r.personEmail, oa.customer__r.lastName, oa.Owner.alias, requestType, RefundRequest, chargeRequest, refundPaymentType, expDate, null, null, null, null, null, null, null, null);	
												
											} catch(exception e){
											system.debug(e.getMessage());
											crd.refund_status__c = 'Error';
											crd.Status_Detail__c = 'An error occurred making web service callout.  Contact Administrator';
										}
										try {
											WS_OrderAdjustmentUtils.processOrderAdjustmentResponse(oaResponse,crd,oa);
										} catch(exception e){
											system.debug(e.getMessage());
											crd.refund_status__c = 'Error';
											crd.Status_Detail__c = 'An error occurred parsing web service response.  Contact Administrator';
										}
									}
								}
							}
							update crdList;
							Set <String> crdStatusSet = new Set <String>();
							for (Credit_refund_Detail__c crd: crdList){
							if (crd.Refund_Status__c!=null) crdStatusSet.add(crd.refund_status__c);
						}
						if (crdStatusSet.size()>1){
							oa.Status__c='Partially Processed';
						} else {
							if (crdStatusSet.contains('Processed')) oa.Status__c = 'Processed';
							else oa.Status__c = 'Error';
							}
						} 
						else {
							oa.Status__c = 'Error';
							oa.Error_Reason__c= 'No Credit Card Settlement Information Available';
						}
						update oa;
					}
					else {
						try {
							oaResponse = oaService.OrderAdjustment(orderutilities.zeroLPAD(orderNumber, 10),  oa.Refund_or_Misc_Amount__c, oa.CurrencyIsoCode, paymentType, oa.customer__r.AS_400_Customer_Number__c,  oa.customer__r.personEmail, oa.customer__r.lastName, oa.Owner.alias, requestType, RefundRequest, chargeRequest, null, null, null, null, null, null, null, null, null, null);	
						} catch(exception e){
							system.debug(e.getMessage());
							oa.Status__c = 'Error';
							oa.Error_Reason__c = 'An error occurred making web service callout.  Contact Administrator';
						}
						try {
							WS_OrderAdjustmentUtils.processOrderAdjustmentResponse(oaResponse,oa);
						} catch(exception e){
							system.debug(e.getMessage());
							oa.Status__c = 'Error';
							oa.Error_Reason__c = 'An error occurred parsing web service response.  Contact Administrator';
						}
						update oa;
					}
				}
			} catch(exception e){
				system.debug(LoggingLevel.info, 'Error Occurred~~~~:'+ e.getMessage());
			}
		} else {
			if (oa.Status__c!='Error') oa.Status__c='Processed';//
			UPDATE OA;
		}
		return oaResponse;
	}
	
	public static void processOrderAdjustmentResponse(WS_soa_OrderAdjustmentService.OrderAdjustmentResponse orderAdjustResponse, Order_Adjustment__c oa) {
		if (orderAdjustResponse!=null) {
			if (orderAdjustResponse.orderAdjustmentSuccess != null) {
				if (orderAdjustResponse.orderAdjustmentSuccess.CreditSuccess <> null) {
					if (orderAdjustResponse.orderAdjustmentSuccess.CreditSuccess.status=='APPROVED') {
						oa.status__c ='Processed';
						 oa.Error_Reason__c = '' ;	
					} else {
						oa.status__c ='Error';
						oa.Error_Reason__c = orderAdjustResponse.orderAdjustmentSuccess.CreditSuccess.status;
					}
					
					oa.Transaction_Reference_Number__c = orderAdjustResponse.orderAdjustmentSuccess.creditSuccess.TransactionReferenceNumber;
					oa.Credit_Card_Token__c = orderAdjustResponse.orderAdjustmentSuccess.creditSuccess.tokenNumber;
					// Case is created if transcation is successful in Payment gateway but not in AS400
					if (orderAdjustResponse.OrderAdjustmentFailure != null && orderAdjustResponse.OrderAdjustmentFailure.FailureMessage != '' && oa.RecordType.DeveloperName == 'Refund') {
						WS_OrderAdjustmentUtils.createCase(oa,orderAdjustResponse.OrderAdjustmentFailure.FailureMessage,'Credit Card Refund Exception'); // creating case for this specific case
						return;
					}
				}
				
				if (orderAdjustResponse.orderAdjustmentSuccess.PaypalSuccess <> null) {
					if (orderAdjustResponse.orderAdjustmentSuccess.PaypalSuccess.RefundID <> null) {
						oa.status__c ='Processed';
						oa.PayPal_Reference_ID__c = orderAdjustResponse.orderAdjustmentSuccess.PaypalSuccess.RefundID;
						oa.Error_Reason__c = '' ;
					} else {
						oa.status__c ='Error'; 
						oa.Error_Reason__c = 'PayPal was not able to provide RefundID.' ;
					}
				}
				if (orderAdjustResponse.orderAdjustmentSuccess.CheckSuccess <> null) {
					oa.status__c ='Processed';
					oa.Error_Reason__c = '' ;
				}
			} else if(orderAdjustResponse.OrderAdjustmentFailure != null) {
				string FailureCode = orderAdjustResponse.OrderAdjustmentFailure.FailureCode;
				string FailureMessage = orderAdjustResponse.OrderAdjustmentFailure.FailureMessage;
				oa.Error_Reason__c = 'Error code:'+FailureCode + ' : '+ FailureMessage;
				oa.status__c ='Error';
			}
		} else {
			oa.Error_Reason__c = 'Callout Failed';
			oa.status__c ='Error';
		}
	}
	
	public static void processOrderAdjustmentResponse(WS_soa_OrderAdjustmentService.OrderAdjustmentResponse orderAdjustResponse, Credit_Refund_Detail__c crd, order_adjustment__c oa) {
		if (orderAdjustResponse!=null){
			if(orderAdjustResponse.orderAdjustmentSuccess != null) {
				if(orderAdjustResponse.orderAdjustmentSuccess.CreditSuccess <> null) {
					if (orderAdjustResponse.orderAdjustmentSuccess.CreditSuccess.status=='APPROVED'){
						crd.refund_status__c ='Processed';
						crd.Status_Detail__c = '' ;	
						system.debug('Needed amount before~~~ '+neededAmount);
						neededAmount-=crd.refund_amount__c;
						system.debug('Needed amount after~~~ '+neededAmount);
					} else {
						crd.refund_status__c ='Error';
						crd.Status_Detail__c = orderAdjustResponse.orderAdjustmentSuccess.CreditSuccess.status;
					}
					
					crd.Refund_Transaction_Reference_Number__c = orderAdjustResponse.orderAdjustmentSuccess.creditSuccess.TransactionReferenceNumber;
					crd.Credit_Card_Token__c = orderAdjustResponse.orderAdjustmentSuccess.creditSuccess.tokenNumber;
					// Case is created if transcation is successful in Payment gateway but not in AS400
					if(orderAdjustResponse.OrderAdjustmentFailure != null && orderAdjustResponse.OrderAdjustmentFailure.FailureMessage != '' && oa.RecordType.DeveloperName == 'Refund') {
						WS_OrderAdjustmentUtils.createCase(oa,orderAdjustResponse.OrderAdjustmentFailure.FailureMessage,'Credit Card Refund Exception'); // creating case for this specific case
						return;
					}
				}
			} else if(orderAdjustResponse.OrderAdjustmentFailure != null) {
				string FailureCode = orderAdjustResponse.OrderAdjustmentFailure.FailureCode;
				string FailureMessage = orderAdjustResponse.OrderAdjustmentFailure.FailureMessage;
				crd.Status_Detail__c = 'Error code:'+FailureCode + ' : '+ FailureMessage;
				crd.Refund_status__c ='Error';
			}
		} else {
			crd.Status_Detail__c = 'Callout Failed';
			crd.refund_status__c ='Error';
		}
	}
	
}