public with sharing class temp_Release3MockServices {

	public static string maketoken(integer tokenLength) {
		string text = '';
		string possible = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';

		for( integer i=0; i < tokenLength; i++ ){
			integer loc = integer.valueOf(Math.floor(Math.random() * possible.length()));
			text += possible.substring(loc,loc+1);
		}
		system.debug(text);
		return text;
	}

	public static WS_soa_OrderAdjustmentService.OrderAdjustmentResponse test_mockOrderAdjustmentService(String OANumber){
		//Credit scenarios
		Order_Adjustment__c oa = [select id, name, recordType.developerName, Customer__r.Payment_Profile_Id__c,Customer__r.AS_400_Customer_Number__c,Credit_Card_Number__c, Credit_Card_Expiration_Date__c, Credit_Card_Name__c, Credit_Card_CVV__c, Credit_Card_Type__c,
									Payment_Method__c, customer__r.recordType.developerName, customer__r.Customer_Number__c,customer__r.personEmail, customer__r.LastName, Related_Case__r.owner.alias, CurrencyIsoCode, 
									Refund_or_Misc_Amount__c, Related_Order__c ,Refund_Type__c, related_order__r.customer__c from Order_Adjustment__c where name=:OANumber];
		
		if (oa.recordType.developerName=='Refund'){
				Orders__c ord = [select name, Paypal_Authorization_Code__c, Order_Total__c, replacement_order__c, credit_card_type__c, payment_type__c, sales_channel__c,
													 customer__r.Customer_Number__c, customer__r.recordType.developerName, CurrencyIsoCode, owner.alias, customer__r.LastName , customer__r.personEmail from Orders__c where id =:oa.Related_Order__c];
		
							WS_soa_OrderAdjustmentService.RefundRequest refundRequest = new WS_soa_OrderAdjustmentService.RefundRequest();
							string paymentType;
							
							if (oa.Payment_Method__c=='Credit Card'){
								refundRequest.creditDetail = new WS_soa_OrderAdjustmentService.CreditDetail();
								refundRequest.creditDetail.IndustryType='EC';
								refundRequest.creditDetail.IsBankLinkDownReprocessing  ='N';
								refundRequest.creditDetail.MerchantKey=NBTYUtils.getRecordTypeBrandMappingMap().get( ord.customer__r.recordType.developerName).merchant_key__c;
								refundRequest.creditDetail.OrderID=ord.name;
								refundRequest.creditDetail.TokenNumber=makeToken(10); 
								paymentType = returnCcCode(oRD.credit_card_type__c);
							} 
							else if (oa.Payment_Method__c=='Paypal'){
								refundRequest.PaypalDetail = new WS_soa_OrderAdjustmentService.PaypalDetail();
								refundRequest.PaypalDetail.transactionID = ord.Paypal_Authorization_Code__c;
								paymentType = 'Y';
							}
							else {
								paymentType='C';
							}
		return mockOrderAdjustmentService(ord.name, oa.Refund_or_Misc_Amount__c, ord.CurrencyIsoCode, paymentType , oa.customer__r.Customer_Number__c,oa.customer__r.personEmail ,oa.customer__r.LastName,oa.Related_Case__r.owner.alias,'C',refundRequest,null);
		}
		 
		else {
				WS_soa_OrderAdjustmentService.MiscChargeRequest chargeRequest = new WS_soa_OrderAdjustmentService.MiscChargeRequest();
				chargeRequest.creditDetail = new WS_soa_OrderAdjustmentService.CreditDetailType();
				if (oa.Payment_Method__c=='Credit Card'){
								Address__c add = [select Address_Line_1__c, City__c, address_line_2__c, State_Providence__c, Zip_Code__c, Country__c from Address__c where customer__c=:oa.related_order__r.customer__c and primary_bill_to_address__c=true];
								chargeRequest.creditDetail.NewCreditCardDetails = new WS_soa_OrderAdjustmentService.NewCreditCardDetails();
								chargeRequest.creditDetail.NewCreditCardDetails.Amount = String.valueOf(oa.Refund_or_Misc_Amount__c); //with or without decimals?
								chargeRequest.creditDetail.NewCreditCardDetails.IndustryType='EC';
								chargeRequest.creditDetail.NewCreditCardDetails.SaveCCInfoOnBankLinkDown='0';
								chargeRequest.creditDetail.NewCreditCardDetails.MerchantKey=NBTYUtils.getRecordTypeBrandMappingMap().get( oa.customer__r.recordType.developerName).merchant_key__c;
								chargeRequest.creditDetail.NewCreditCardDetails.OrderID=oa.name;
								chargeRequest.creditDetail.NewCreditCardDetails.LOBCustomerNumber= oa.Customer__r.AS_400_Customer_Number__c;
								//chargeRequest.creditDetail.NewCreditCardDetails.PartialAuthIndicator
								chargeRequest.creditDetail.NewCreditCardDetails.PaymentProfileID=oa.Customer__r.Payment_Profile_Id__c;
								chargeRequest.creditDetail.NewCreditCardDetails.CreditCardTypeID=WS_soa_AuthorizePaymentService.getCreditCardTypeId(oa.credit_card_type__c);
								chargeRequest.creditDetail.NewCreditCardDetails.CreditCardNumber=oa.Credit_Card_Number__c;
								chargeRequest.creditDetail.NewCreditCardDetails.CreditCardExpiryDate=oa.Credit_Card_Expiration_Date__c;
								chargeRequest.creditDetail.NewCreditCardDetails.nameOnTheCreditCard = oa.Credit_Card_Name__c;
								chargeRequest.creditDetail.NewCreditCardDetails.CCVerifyNumber = oa.Credit_Card_CVV__c;
								chargeRequest.creditDetail.NewCreditCardDetails.CreatePaymentProfileIndicator='0';
								chargeRequest.creditDetail.NewCreditCardDetails.Address1=add.Address_Line_1__c;
								chargeRequest.creditDetail.NewCreditCardDetails.Address2=add.Address_Line_2__c;
								chargeRequest.creditDetail.NewCreditCardDetails.City=add.City__c;
								chargeRequest.creditDetail.NewCreditCardDetails.State=add.State_Providence__c;
								chargeRequest.creditDetail.NewCreditCardDetails.Zip=add.Zip_Code__c;
								chargeRequest.creditDetail.NewCreditCardDetails.CountryCode=add.country__c;
							}
						else	if (oa.Payment_Method__c=='Existing Card'){
								chargeRequest.creditDetail = new WS_soa_OrderAdjustmentService.CreditDetailType();
								chargeRequest.creditDetail.ExistingCreditCardDetails = new WS_soa_OrderAdjustmentService.ExistingCreditCardDetails();
								chargeRequest.creditDetail.ExistingCreditCardDetails.Amount = String.valueOf(oa.Refund_or_Misc_Amount__c);
								chargeRequest.creditDetail.ExistingCreditCardDetails.IndustryType='EC';
								chargeRequest.creditDetail.ExistingCreditCardDetails.IsBankLinkDownReprocessing='0';
								chargeRequest.creditDetail.ExistingCreditCardDetails.MerchantKey=NBTYUtils.getRecordTypeBrandMappingMap().get( oa.customer__r.recordType.developerName).merchant_key__c;
								chargeRequest.creditDetail.ExistingCreditCardDetails.OrderID=oa.name;
								chargeRequest.creditDetail.ExistingCreditCardDetails.TokenNumber=makeToken(10); 
							}
					else {
						//Cash or Check
					}
				return mockOrderAdjustmentService(oa.name, oa.Refund_or_Misc_Amount__c, oa.CurrencyIsoCode,returnCcCode(oa.credit_card_type__c) , oa.customer__r.Customer_Number__c,oa.customer__r.personEmail ,oa.customer__r.LastName,oa.Related_Case__r.owner.alias,'D',null,chargeRequest );
	
		}
	}
	public static string returnCcCode(string inputCardType){

				if (inputCardType=='Visa') return 'V';
				else if (inputCardType=='Discover') return 'D';
				else if (inputCardType=='American Express') return 'A';
				else if (inputCardType=='MasterCard') return 'M';
				else return 'J';
			
		}
		
	
	
	public static WS_soa_OrderAdjustmentService.OrderAdjustmentResponse processCreditMockResponse(	string OrderNumber, decimal amount, WS_soa_OrderAdjustmentService.CreditDetail creditDetail){
		WS_soa_OrderAdjustmentService.OrderAdjustmentResponse orderAdjustResponse = new WS_soa_OrderAdjustmentService.OrderAdjustmentResponse();
		WS_soa_OrderAdjustmentService.OrderAdjustmentFailure failureResp;
		WS_soa_OrderAdjustmentService.OrderAdjustmentSuccess successResp;
			if (string.valueOf(amount).substring(string.valueOf(amount).length()-1,string.valueOf(amount).length())=='1'){  //Mock failure, can't reach Gateway 
							 failureResp = new WS_soa_OrderAdjustmentService.OrderAdjustmentFailure();
							 failureResp.FailureMessage='Failure to Reach Gateway; Contact Administrator';		
						}
						else {
							 successResp  = new WS_soa_OrderAdjustmentService.OrderAdjustmentSuccess();
							 successResp.CreditSuccess = new WS_soa_OrderAdjustmentService.CreditSuccess();
							 successResp.CreditSuccess.ErrorMessage=null;
						//	 successResp.CreditSuccess.Message
							 successResp.CreditSuccess.OrderID=orderNumber;
							 successResp.CreditSuccess.RespDateTime=system.now().format('YYYYMMDDhhmmss');
							 if (string.valueOf(amount).substring(string.valueOf(amount).length()-1,string.valueOf(amount).length())=='2'){ // Credit card Decline
								successResp.CreditSuccess.Status='DECLINED';
								string statusMessage = 'ApprovalStatus:1 RespCode:01 ';
								list<string> statusDetails = statusMessage.split(' '); // Split with space ApprovalStatus:1 RespCode:00
								string responseCode = statusDetails[1].split(':')[1];
								string responseDesc = CCReturnCode__c.getValues(responseCode).Definition__c;
								successResp.CreditSuccess.Status = 'DECLINED: ' + responseCode + '-' + responseDesc;         
								// integer cclength = RefundRequest.CreditDetail.NewCreditCardDetails.CreditCardNumber.length();
							 	//successResp.CreditSuccess.TokenNumber=RefundRequest.CreditDetail.ExistingCreditCardDetails.TokenNumber;
							
							  }
							 else {
								successResp.CreditSuccess.Status='APPROVED';
								// integer cclength = RefundRequest.CreditDetail.NewCreditCardDetails.CreditCardNumber.length();
								if (CreditDetail.TokenNumber!=null) { 
									successResp.CreditSuccess.TokenNumber=CreditDetail.TokenNumber;
								} else {
										successResp.CreditSuccess.TokenNumber=makeToken(11);
								}
								successResp.CreditSuccess.TransactionReferenceIndex='1';
								successResp.CreditSuccess.TransactionReferenceNumber=maketoken(30);
								if (string.valueOf(amount).substring(string.valueOf(amount).length()-1,string.valueOf(amount).length())=='0'){
									failureResp = new WS_soa_OrderAdjustmentService.OrderAdjustmentFailure();
									failureResp.FailureMessage='Could Not be Posted to AS400';
								} 
							}
						}
			
			orderAdjustResponse.OrderAdjustmentFailure=failureResp;
			orderAdjustResponse.OrderAdjustmentSuccess=successResp;
			return orderAdjustResponse;
		
	}
	
	public static WS_soa_OrderAdjustmentService.OrderAdjustmentFailure processCreditValidation(WS_soa_OrderAdjustmentService.CreditDetail creditDetail, string requestType){
		WS_soa_OrderAdjustmentService.OrderAdjustmentFailure failureResp;
		/*if (CreditDetail.ExistingCreditCardDetails!=null){
			if (CreditDetail.ExistingCreditCardDetails.Amount==null || 
									CreditDetail.ExistingCreditCardDetails.IndustryType==null ||
									CreditDetail.ExistingCreditCardDetails.IsBankLinkDownReprocessing==null ||
									CreditDetail.ExistingCreditCardDetails.MerchantKey==null ||
									CreditDetail.ExistingCreditCardDetails.OrderID==null ||
									CreditDetail.ExistingCreditCardDetails.TokenNumber==null ){
							failureResp = new WS_soa_OrderAdjustmentService.OrderAdjustmentFailure();
							if (requestType=='C'){
								failureResp.FailureMessage='All Existing Card Details Must Be Populated for Credit Refund';			
							}
							else {
								failureResp.FailureMessage='All Existing Card Details Must Be Populated for Credit Transaction';			
							}		
			}
		}
		else {
			if (CreditDetail.NewCreditCardDetails.Amount==null ||
									CreditDetail.NewCreditCardDetails.IndustryType==null ||
									CreditDetail.NewCreditCardDetails.CreatePaymentProfileIndicator==null ||
									CreditDetail.NewCreditCardDetails.MerchantKey==null ||
									CreditDetail.NewCreditCardDetails.OrderID==null ||
									CreditDetail.NewCreditCardDetails.CreditCardNumber==null ){
							failureResp = new WS_soa_OrderAdjustmentService.OrderAdjustmentFailure();
							failureResp.FailureMessage='All Mandatory New Card Details Must Be Populated for Misc Transaction';			
			}
		}*/
		return failureResp;
	}
	
	

	public static WS_soa_OrderAdjustmentService.OrderAdjustmentResponse mockOrderAdjustmentService (String OrderNumber,Decimal Amount,String Currency_x,String PaymentType,String CustomerNumber,String Email,String LastName,String UserAlias,String RequestType,WS_soa_OrderAdjustmentService.RefundRequest RefundRequest,WS_soa_OrderAdjustmentService.MiscChargeRequest MiscChargeRequest){
		
		WS_soa_OrderAdjustmentService.OrderAdjustmentResponse orderAdjustResponse = new WS_soa_OrderAdjustmentService.OrderAdjustmentResponse();
		WS_soa_OrderAdjustmentService.OrderAdjustmentFailure failureResp;
		WS_soa_OrderAdjustmentService.OrderAdjustmentSuccess successResp;
		try {Set <String> creditSet = new Set <String>{'A','V','D','J','M'};
		
		if (RequestType==null){
			failureResp = new WS_soa_OrderAdjustmentService.OrderAdjustmentFailure();
			failureResp.FailureMessage='Request Type Cannot be Null';
		}
		else {
			system.debug('requestType~~~~'+requestType);
				system.debug('paymentType~~~~'+paymentType);
			if (requestType =='C'){
				if (creditSet.contains(paymentType)){  //Credit Card Refund
					if (refundRequest.CreditDetail==null){
						failureResp = new WS_soa_OrderAdjustmentService.OrderAdjustmentFailure();
						failureResp.FailureMessage='Credit Detail Cannot be Null for Credit Refund'; 
						orderAdjustResponse.OrderAdjustmentFailure=failureResp;
					}
					failureResp=processCreditValidation(refundRequest.CreditDetail,'C'); 
					if (failureResp==null){
						orderAdjustResponse=processCreditMockResponse(orderNumber, amount, refundRequest.creditDetail);
					}
				} 
				else if (paymentType=='C'){
					if (string.valueOf(amount).substring(string.valueOf(amount).length()-1,string.valueOf(amount).length())=='1'){
						failureResp = new WS_soa_OrderAdjustmentService.OrderAdjustmentFailure();
						failureResp.FailureMessage='Check Request Could Not be Made to AS400';
					}
					else {
						successResp  = new WS_soa_OrderAdjustmentService.OrderAdjustmentSuccess();
						successResp.CheckSuccess = new  WS_soa_OrderAdjustmentService.CheckSuccess();
						successResp.CheckSuccess.Status='Success';
					}
					orderAdjustResponse.OrderAdjustmentFailure=failureResp;
					orderAdjustResponse.OrderAdjustmentSuccess=successResp;
				}
				else { //Paypal
					if (string.valueOf(amount).substring(string.valueOf(amount).length()-1,string.valueOf(amount).length())=='1'){
						failureResp = new WS_soa_OrderAdjustmentService.OrderAdjustmentFailure();
						failureResp.FailureCode='500000';
						failureResp.FailureMessage='There is a system error';
					}
					else  if (string.valueOf(amount).substring(string.valueOf(amount).length()-1,string.valueOf(amount).length())=='2'){
						successResp  = new WS_soa_OrderAdjustmentService.OrderAdjustmentSuccess();
						successResp.PaypalSuccess = new WS_soa_OrderAdjustmentService.PaypalSuccess();
						successResp.PaypalSuccess.Message='ALREADY_REVERSED_OR_REFUNDED';
						//successResp.PaypalSuccess.RefundID= makeToken(8);
						successResp.PaypalSuccess.Status='Failure';
					}
					else {
						successResp  = new WS_soa_OrderAdjustmentService.OrderAdjustmentSuccess();
						successResp.PaypalSuccess = new WS_soa_OrderAdjustmentService.PaypalSuccess();
						successResp.PaypalSuccess.Message='REFUNDED';
						successResp.PaypalSuccess.RefundID= makeToken(8);
						successResp.PaypalSuccess.Status='Success';
					}
					orderAdjustResponse.OrderAdjustmentFailure=failureResp;
					orderAdjustResponse.OrderAdjustmentSuccess=successResp;
				}
			}
			else {
				system.debug('paymentType~~~'+paymentType);
			if (creditSet.contains(paymentType)){  //Misc Credit Card Txn
					if (MiscChargeRequest.CreditDetail==null){
						failureResp = new WS_soa_OrderAdjustmentService.OrderAdjustmentFailure();
						failureResp.FailureMessage='Credit Detail Cannot be Null for Credit Transaction';
						orderAdjustResponse.OrderAdjustmentFailure=failureResp;
					}
					else {
						//failureResp=processCreditValidation(MiscChargeRequest.CreditDetail,'D'); 
						if (failureResp==null){
							//orderAdjustResponse=processCreditMockResponse(orderNumber, amount, MiscChargeRequest.creditDetail);
						}
					}
				}
			}
		}
		
		if (orderAdjustResponse.OrderAdjustmentFailure!=null) SYSTEM.DEBUG('failure RESP~~~~'+orderAdjustResponse.OrderAdjustmentFailure.FailureMessage);
		if (orderAdjustResponse.OrderAdjustmentSuccess!=null) {
			if (orderAdjustResponse.OrderAdjustmentSuccess.CheckSuccess!=null) SYSTEM.DEBUG('success RESP~~~~'+orderAdjustResponse.OrderAdjustmentSuccess.CheckSuccess.Status);
			if (orderAdjustResponse.OrderAdjustmentSuccess.CreditSuccess!=null) SYSTEM.DEBUG('success RESP~~~~'+orderAdjustResponse.OrderAdjustmentSuccess.CreditSuccess.Status);
			if (orderAdjustResponse.OrderAdjustmentSuccess.PaypalSuccess!=null) SYSTEM.DEBUG('success RESP~~~~'+orderAdjustResponse.OrderAdjustmentSuccess.PaypalSuccess.Status);
		}}
		catch (exception e){}
		return orderAdjustResponse;
	}
	
	public static WS_soa_ClearOrderService.ER_BO_Response_element mockERBO_PopulateResponse(string status, string statusCode, string statusMessage){
		WS_soa_ClearOrderService.ER_BO_Response_element erBoResponse = new WS_soa_ClearOrderService.ER_BO_Response_element();
		erBoResponse.Status= status;
		erBoResponse.StatusCode= statusCode;
		erBoResponse.StatusMessage=statusMessage;
		system.debug( 'Status~~'+erBoResponse.Status);
		system.debug( 'StatusCode~~'+erBoResponse.StatusCode);
		system.debug( 'StatusMessage~~'+erBoResponse.StatusMessage);
		system.debug( erBoResponse);
		return erBoResponse;
	}

	public static WS_soa_ClearOrderService.ER_BO_Response_element mockERBOService(string orderNumber){
		
		if(orderNumber.endsWith('1')||  orderNumber.endsWith('6'))
			return mockERBO_PopulateResponse('Success', 'NF', 'Order Not Found');
		else if(orderNumber.endsWith('2')||orderNumber.endsWith('7'))
			return mockERBO_PopulateResponse('Success', 'BOC', 'Bad Order Cleared');
		else if(orderNumber.endsWith('3')||orderNumber.endsWith('8'))
			return mockERBO_PopulateResponse('Success', 'BON', 'Bad Order Clear Unsucessful');
		else if(orderNumber.endsWith('4')||orderNumber.endsWith('9'))
			return mockERBO_PopulateResponse('Success', 'ERC', 'Error Order Cleared');
		else if(orderNumber.endsWith('5'))
			return mockERBO_PopulateResponse('Success', 'ERN', 'Error Order Clear Unsuccessful');
		else if (orderNumber.endsWith('0')){
			try {
				WS_soa_ClearOrderService.ER_BO_RemovalPort  wsClearOrder = new WS_soa_ClearOrderService.ER_BO_RemovalPort ();
				return wsClearOrder.ER_BO_Removal(orderNumber, null, null, null, null, null, null, null, null, null, null);
			}
			catch (exception e){
				return mockERBO_PopulateResponse('Error', '', 'Unexpected Error Occurred');
			}
		}
		else
			return mockERBO_PopulateResponse('Success', 'NF', 'Order Not Found');
		
	}

}