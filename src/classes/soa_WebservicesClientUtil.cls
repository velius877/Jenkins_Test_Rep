public with sharing class soa_WebservicesClientUtil {
	public static string SOA_ENDPOINT = WS_Integration__c.getValues('SOAEndpoint').value__c;
	
	public static ws_Soa_CaseCreateService_v2.ComplaintUpdateResult  sendCaseToPQM(Id CaseId){
		system.debug('------------------------------Inside sendCasetoPQM');
		ws_Soa_CaseCreateService_v2.ComplaintService caseCreateService = new ws_Soa_CaseCreateService_v2.ComplaintService();
		ws_Soa_CaseCreateService_v2.ComplaintUpdateResult caseUpdateResult = new ws_Soa_CaseCreateService_v2.ComplaintUpdateResult();
		ws_Soa_CaseCreateService_v2.ComplaintDataInput caseUpdateInput = ws_Soa_CaseCreateServiceUtils.init(caseId);
		if (ws_Soa_CaseCreateServiceUtils.bHasAffectedItems) {
			system.debug('------------------------------Inside first if()');
			integer i_result;
			boolean isFailed = false;
			try { 
				system.debug('making callout');
				i_result=caseCreateService.updateComplaint(caseUpdateInput);
			} 
			catch (exception e){
				system.debug(e.getMessage());
				system.debug('first retry');
				isFailed=true;
			}
			if (isFailed){
				try { i_result = caseCreateService.updateComplaint(caseUpdateInput);}
				catch (exception e){
					Error_Log__c err = new Error_Log__c();
					err.Error_Line_Number__c = e.getLineNumber();
					err.Error_Message__c = e.getMessage();
					err.Error_Stack_Trace__c = e.getStackTraceString();
					err.Error_Type__c = e.getTypeName();
					insert err;
					i_result=-99;//unknown error;
					// add in lookup for error log
				}
			}
			
			caseUpdateResult.result = i_result; 
			system.debug('i_result~~~~'+i_result);
			Case c = new Case (Id=caseId);
			c.agile_status__c = string.valueOf( i_result);
			PQM_Return_Code__c codeDetail = PQM_Return_Code__c.getInstance(string.valueOf(i_result));
			if (codeDetail!=null)           c.agile_status_description__c = codeDetail.description__c;
			caseTriggerHelper.isFromChild=true;
			system.debug('case~~~~'+c);
			try {
				update c;
			}
			catch (exception e){
				
			}
			if (!isFailed){
				ws_Soa_CaseCreateServiceUtils.lockAllRelatedRecords(c.id);
			}
			
		}
		return caseUpdateResult;
	}
	private static string GetSOASOAPHeader()
	{
		//return '<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/"><s:Header xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"><wsse:Security s:mustUnderstand="1" xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd"><wsse:UsernameToken><wsse:Username>' + WS_Integration__c.getValues('SOAUserID').value__C + '</wsse:Username><wsse:Password>' + WS_Integration__c.getValues('SOAPassword').value__C + '</wsse:Password></wsse:UsernameToken></wsse:Security></s:Header>';
				
		string header = '<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/" xmlns:nrq="http://NBTY.com/GI/PGWY/SF/Schemas/Authorization/NRQ"><s:Header xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">';
		header+='<Security xmlns:wsu="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd" xmlns="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd"><UsernameToken><Username>';
		header+= WS_Integration__c.getValues('SOAUserID').value__c;
		header+= '</Username><Password>';
		header+=  WS_Integration__c.getValues('SOAPassword').value__c;
		header+= '</Password></UsernameToken></Security>';
		header+='</s:Header>';
		return header;
	} 
	public static ws_Soa_OrderHistoryService.retrieveOrdersHistoryResponse doCallout(String as400CustomerNumber,String email,String minOrderSequence,String maxOrderSequence)													
	{
		ws_Soa_OrderHistoryService.OrderHistoryServiceSOAP ordHservice = new ws_Soa_OrderHistoryService.OrderHistoryServiceSOAP();
		ws_Soa_OrderHistoryService.customers customers= new ws_Soa_OrderHistoryService.customers();
		if (as400CustomerNumber!=null){
			ws_Soa_OrderHistoryService.customer customer= new ws_Soa_OrderHistoryService.customer();
			customer.customerNumber=as400CustomerNumber;
			customers.customer = new List <ws_Soa_OrderHistoryService.customer>();
			customers.customer.add(customer);
		}
		else {
			customers.email=email;
		}
		ws_Soa_OrderHistoryService.retrieveOrdersHistoryResponse ordHres = ordHservice.RetrieveOrdersHistory(customers,null, minOrderSequence,maxOrderSequence,null,null,null,null,null,null,null,null,null,null);
		return ordHres;
	}
	
	
	public static WS_soa_ClearOrderService.ER_BO_Response_element ClearERBOByOrderNumber(string orderNumber){
		WS_soa_ClearOrderService.ER_BO_RemovalPort  wsClearOrder = new WS_soa_ClearOrderService.ER_BO_RemovalPort ();
		return wsClearOrder.ER_BO_Removal(orderNumber, null, null, null, null, null, null, null, null, null, null);
		
	}
	
	public static WS_OrderLineItemCancellation.OrderCancellationResponse_element CancelOrderbyProgId(string ProgramId,string SFDCOrderNumber,string selectedCancelReason, string selectedDisposition){
		WS_OrderLineItemCancellation.CancelOrderPort wsCancelOrder = new WS_OrderLineItemCancellation.CancelOrderPort();
		WS_OrderLineItemCancellation.OrderCancellationResponse_element cancelResponse = new WS_OrderLineItemCancellation.OrderCancellationResponse_element();
		return  wsCancelOrder.CancelOrder(SFDCOrderNumber, SFDCOrderNumber, ProgramId, '', '', '', '' , selectedCancelReason,'' , selectedDisposition);
		//process response
	}
	
	public static WS_OrderLineItemCancellation.OrderCancellationResponse_element CancelOrderbyLineId(string ProgramId,string SFDCOrderNumber,string ProductNumber, string ProductSuffix,string ProductQuantity,String CancelReason){
		WS_OrderLineItemCancellation.CancelOrderPort wsCancelOrder = new WS_OrderLineItemCancellation.CancelOrderPort();
		WS_OrderLineItemCancellation.OrderCancellationResponse_element cancelResponse = new WS_OrderLineItemCancellation.OrderCancellationResponse_element();
		return  wsCancelOrder.CancelOrder(SFDCOrderNumber, SFDCOrderNumber, ProgramId, '', ProductNumber, ProductSuffix, ProductQuantity, CancelReason,'' , '');
		//process response
	}
	
	public static boolean WS_DeletePaymentProfile(string OrderId,string tokenNumber){
		Orders__c sOrder = [Select Name, Credit_Card_Token__c,Customer__r.Payment_Profile_Id__c, Payment_Transaction_Reference_Index__c, Payment_Profile_ID__c, Payment_Authorization_Code__c, customer__r.recordType.developerName From Orders__c where id=:orderId];
		string merchantKey =NBTYUtils.getRecordTypeBrandMappingMap().get( sOrder.customer__r.recordType.developerName).merchant_key__c;
		string CustomerPaymentProfile = sOrder.customer__r.Payment_Profile_Id__c;
		if(string.isblank(CustomerPaymentProfile))
			throw new NBTYException('Error processing payments from existing token. No Payment Profile found');
		WS_SOA_Payment_DS_V2.SFUpdatePaymentProfileResponse_element updateProfileResponse = new WS_SOA_Payment_DS_V2.SFUpdatePaymentProfileResponse_element();
		WS_SOA_Payment_DS_V2.URQCreditCardInfo_element ccinfo = new WS_SOA_Payment_DS_V2.URQCreditCardInfo_element();
		WS_SOA_Payment_Services.BasicHttpBinding_ITwoWayAsyncQSPort paymentService = new WS_SOA_Payment_Services.BasicHttpBinding_ITwoWayAsyncQSPort();
		ccinfo.TokenNumber = tokenNumber;
		updateProfileResponse = paymentService.SFUpdatePaymentProfile(merchantKey,'EC',sOrder.customer__r.Payment_Profile_Id__c,true,'DELETE_TOKEN',false,ccinfo);
		system.debug('~~ Inside Error Processing' + updateProfileResponse.SFUpdatePaymentProfileResponseResult); 
		//processResultforProfileUpdate(updateProfileResponse.SFUpdatePaymentProfileResponseResult);
		//processResponseResult(updateProfileResponse.SFUpdatePaymentProfileResponseResult.Status,updateProfileResponse.SFUpdatePaymentProfileResponseResult.Message,updateProfileResponse.SFUpdatePaymentProfileResponseResult.ErrorMessage);
		return true;
	}
		
	public static WS_soa_AuthorizePaymentService.PaymentResponse ProcessPaymentForNewCard(WS_soa_AuthorizePaymentService.Paymentinfo paymentDetails, boolean isProfileInfo)
	{
		WS_soa_AuthorizePaymentService.PaymentResponse paymentResponse = new WS_soa_AuthorizePaymentService.PaymentResponse();
		if(isProfileInfo)
		{
			// Step 1 Update Profile with this Card
			WS_SOA_Payment_DS_V2.SFUpdatePaymentProfileResponse_element updateProfileResponse = new WS_SOA_Payment_DS_V2.SFUpdatePaymentProfileResponse_element();
			WS_SOA_Payment_DS_V2.URQCreditCardInfo_element ccinfo = new WS_SOA_Payment_DS_V2.URQCreditCardInfo_element();
			WS_SOA_Payment_DS_V2.URQAddressInfo_element addressInfo = new WS_SOA_Payment_DS_V2.URQAddressInfo_element();
			WS_SOA_Payment_Services.BasicHttpBinding_ITwoWayAsyncQSPort paymentService = new WS_SOA_Payment_Services.BasicHttpBinding_ITwoWayAsyncQSPort();
			ccinfo.CreditCardNumber = paymentDetails.creditCardNumber;
			ccinfo.CreditCardExpiryDate = paymentDetails.expiryYYYYMM;
			ccinfo.CreditCardTypeID = WS_soa_AuthorizePaymentService.getCreditCardTypeId(paymentDetails.creditCardType);
			ccinfo.NameOnTheCreditCard = paymentDetails.nameOnCard;
			ccinfo.CreatePaymentProfileIndicator = '1';
			addressinfo.Address1 = paymentDetails.addressLine1.left(30);
			addressinfo.Address2 = paymentdetails.addressLine2.left(30);
			addressinfo.City = paymentdetails.city.left(10);
			addressinfo.State = paymentdetails.state;
			addressinfo.ZipCode = paymentdetails.zipCode;
			addressinfo.CountryCode = paymentdetails.countryCode;
			ccinfo.AddressInfo = addressinfo;
			updateProfileResponse = paymentService.SFUpdatePaymentProfile(paymentDetails.MerchantKey,'EC',paymentDetails.paymentProfileid,true,'ADD_TOKEN',false,ccinfo);
			//Error handling for the response from Payment Gateway;
			//processResponseResult(updateProfileResponse.SFUpdatePaymentProfileResponseResult.Status,updateProfileResponse.SFUpdatePaymentProfileResponseResult.Message,updateProfileResponse.SFUpdatePaymentProfileResponseResult.ErrorMessage);
			if(updateProfileResponse.SFUpdatePaymentProfileResponseResult.Status != 'PROFILE_UPDATED')
			{
				system.debug('~~~~ Response' + updateProfileResponse);
				// DE861 -- Adding error message to display.
				throw new NBTYException('Error processing profile update.\n Please contact Administrator. [' + updateProfileResponse.SFUpdatePaymentProfileResponseResult.ErrorMessage + ']');                
			}
			
			string paymentAmount = formatCurrencyForGateway(string.valueof(paymentdetails.amount));
					
			// STep 2 PreAuthorize Existing Card using this...
			WS_SOA_Payment_DS_V2.ERQCreditCardInfo_element ccinfoforexistingcard = new WS_SOA_Payment_DS_V2.ERQCreditCardInfo_element();
			WS_SOA_Payment_DS_V2.ERQFraudAnalysis_element fraudanalysis = new WS_SOA_Payment_DS_V2.ERQFraudAnalysis_element();
			ccinfoforexistingcard.TokenNumber = updateProfileResponse.TokenNumber;
			WS_SOA_Payment_DS_V2.SFExistingCreditCardAuthorizationResponse_element preAuthExistingCardResponse = new WS_SOA_Payment_DS_V2.SFExistingCreditCardAuthorizationResponse_element();  
			preAuthExistingCardResponse = paymentService.SFPreAuthorizeExistingCreditCard(paymentDetails.MerchantKey,'EC',paymentDetails.paymentProfileid,paymentDetails.orderId, paymentAmount, '',false,ccinfoforexistingcard,fraudanalysis) ;
			
			//Error handling for the response from Payment Gateway;
			//processResponseResult(preAuthExistingCardResponse.Result.Status,preAuthExistingCardResponse.Result.Message,preAuthExistingCardResponse.Result.ErrorMessage);
			processResultforExistingCard(preAuthExistingCardResponse.Result);
			 
			paymentResponse.TokenNumber = updateProfileResponse.TokenNumber;
			paymentResponse.AuthorizationCode = preAuthExistingCardResponse.AuthorizationCode;
			paymentResponse.PaymentProfileID = paymentDetails.paymentProfileid;
			paymentResponse.TransactionReferenceNumber = preAuthExistingCardResponse.TransactionReferenceNumber;
			paymentResponse.TransactionReferenceIndex = preAuthExistingCardResponse.TransactionReferenceIndex;
			paymentResponse.BankResponseDateTime = string.valueof(preAuthExistingCardResponse.ResponseDateTime).trim().replace(' ','T');
		
		
			// TODO: Error handling
		}
		else
		{
			//Authorize New Card
			paymentResponse = ProcessPayment(paymentDetails);
			// Update Profile Id on Account-
		}
		return paymentResponse;
	}
	
	public static boolean UpdatePaymentProfile(WS_soa_AuthorizePaymentService.Paymentinfo paymentDetails, string paymentToken)
	{
		WS_soa_AuthorizePaymentService.PaymentResponse paymentResponse = new WS_soa_AuthorizePaymentService.PaymentResponse();
		// Step 1 Update Profile with this Card
		WS_SOA_Payment_DS_V2.SFUpdatePaymentProfileResponse_element updateProfileResponse = new WS_SOA_Payment_DS_V2.SFUpdatePaymentProfileResponse_element();
		WS_SOA_Payment_DS_V2.URQCreditCardInfo_element ccinfo = new WS_SOA_Payment_DS_V2.URQCreditCardInfo_element();
		WS_SOA_Payment_DS_V2.URQAddressInfo_element addressInfo = new WS_SOA_Payment_DS_V2.URQAddressInfo_element();
		WS_SOA_Payment_Services.BasicHttpBinding_ITwoWayAsyncQSPort paymentService = new WS_SOA_Payment_Services.BasicHttpBinding_ITwoWayAsyncQSPort();
		// only updating address informat
		/*ccinfo.CreditCardNumber = paymentDetails.creditCardNumber;
		ccinfo.CreditCardExpiryDate = paymentDetails.expiryYYYYMM;
		ccinfo.CreditCardTypeID = WS_soa_AuthorizePaymentService.getCreditCardTypeId(paymentDetails.creditCardType);
		ccinfo.NameOnTheCreditCard = paymentDetails.nameOnCard;
		ccinfo.CreatePaymentProfileIndicator = '0';*/
		ccinfo.TokenNumber = paymentToken;
		
		addressinfo.Address1 = paymentDetails.addressLine1.left(30);
		addressinfo.Address2 = paymentdetails.addressLine2.left(30);
		addressinfo.City = paymentdetails.city.left(10);
		addressinfo.State = paymentdetails.state;
		addressinfo.ZipCode = paymentdetails.zipCode;
		addressinfo.CountryCode = paymentdetails.countryCode;
		ccinfo.AddressInfo = addressinfo;
		updateProfileResponse = paymentService.SFUpdatePaymentProfile(paymentDetails.MerchantKey,'EC',paymentDetails.paymentProfileid,true,'UPDATE_TOKEN',false,ccinfo);
		//Error handling for the response from Payment Gateway;
		//processResponseResult(updateProfileResponse.SFUpdatePaymentProfileResponseResult.Status,updateProfileResponse.SFUpdatePaymentProfileResponseResult.Message,updateProfileResponse.SFUpdatePaymentProfileResponseResult.ErrorMessage);
		if(updateProfileResponse.SFUpdatePaymentProfileResponseResult.Status != 'PROFILE_UPDATED'){
			system.debug('~~~~ Response' + updateProfileResponse);
			// DE861 -- adding the error message to the error itself to be more specific to the problem.
			throw new NBTYException('Error processing profile update.\n Please contact Administrator. [' + updateProfileResponse.SFUpdatePaymentProfileResponseResult.ErrorMessage + ']');                
		}
		return true;
	}

	public static Set <String>  submitOrderBySendOrderService2(Id orderId){
		Set <String> errorArray = new Set <String>();
		WS_soa_SendOrderService_v2.SendOrderResponse_element responseElement;           
		WS_soa_SendOrderService_v2.header_element headerElement = new WS_soa_SendOrderService_v2.header_element();
		WS_soa_SendOrderService_v2.shipToRecord_element shipToElement = new WS_soa_SendOrderService_v2.shipToRecord_element();
		WS_soa_SendOrderService_v2.billTo_element billToElement = new WS_soa_SendOrderService_v2.billTo_element();
		WS_soa_SendOrderService_v2.address1_element address1 = new WS_soa_SendOrderService_v2.address1_element();
		WS_soa_SendOrderService_v2.address2_element address2 = new WS_soa_SendOrderService_v2.address2_element();
		List<WS_soa_SendOrderService_v2.detailRecord_element> detailElementArray= new List <WS_soa_SendOrderService_v2.detailRecord_element>();
		List<WS_soa_SendOrderService_v2.allowanceChargeReocord_element> allowanceElementArray;//optional so initialize further down
		//List<WS_soa_SendOrderService_v2.batchCountRecord_element> batchElementArray = new  List <WS_soa_SendOrderService_v2.batchCountRecord_element>();
		List<WS_soa_SendOrderService_v2.commentRecord_element> commentElementArray ;//optional, so initialize further down
		WS_soa_SendOrderService_v2.miscellaneousChargeRecord_element miscellaneousChargeElement; ////optional, so initialize further down
		//List<WS_soa_SendOrderService_v2.discountRecord_element> discountElementArray = new  List <WS_soa_SendOrderService_v2.discountRecord_element>();
		//List<WS_soa_SendOrderService_v2.extendedRecord_element> extendedElementArray = new  List <WS_soa_SendOrderService_v2.extendedRecord_element>();
		WS_soa_SendOrderService_v2.paymentRecord_element paymentElement ;//no payment record for amazon
		//WS_soa_SendOrderService_v2_4.loyaltyPoints_element loyaltyElement = new WS_soa_SendOrderService_v2_4.loyaltyPoints_element();
		try {    
			WS_soa_SendOrderService_v2_Utils.doSOQLs(orderId);
			// scrub names now that the order has been retrived
			if(WS_soa_SendOrderService_v2_Utils.ord != null){
				// DE564
				WS_soa_SendOrderService_v2_Utils.ord.Ship_to_First_Name__c = scrubInvalidTokens(WS_soa_SendOrderService_v2_Utils.ord.Ship_to_First_Name__c);
				WS_soa_SendOrderService_v2_Utils.ord.Ship_to_Last_Name__c = scrubInvalidTokens(WS_soa_SendOrderService_v2_Utils.ord.Ship_to_Last_Name__c);
			}
			// scrub name on account object
			if(WS_soa_SendOrderService_v2_Utils.acct != null){
				// DE564
				WS_soa_SendOrderService_v2_Utils.acct.FirstName = scrubInvalidTokens(WS_soa_SendOrderService_v2_Utils.acct.FirstName);
				WS_soa_SendOrderService_v2_Utils.acct.LastName = scrubInvalidTokens(WS_soa_SendOrderService_v2_Utils.acct.LastName);
			}
			WS_soa_SendOrderService_v2_Utils.lineNumber=10;
			address1 = WS_soa_SendOrderService_v2_Utils.settingAddress1();
			// Scrub address lines
			if (address1 != null){
				// DE564
				address1.addressLine1 = scrubInvalidTokens(address1.addressLine1);
				address1.addressLine2 = scrubInvalidTokens(address1.addressLine2);
				address1.addressLine3 = scrubInvalidTokens(address1.addressLine3);
				address1.addressLine4 = scrubInvalidTokens(address1.addressLine4);
				address1.addressLine5 = scrubInvalidTokens(address1.addressLine5);
				address1.city = scrubInvalidTokens(address1.city);
				address1.state = scrubInvalidTokens(address1.state);
			}
			billToElement = WS_soa_SendOrderService_v2_Utils.settingBillTo(address1);  
			headerElement = WS_soa_SendOrderService_v2_Utils.settingHeader(billToElement);
			address2 = WS_soa_SendOrderService_v2_Utils.settingAddress2();
			// Scrub address lines
			if (address2 != null){
				// DE564
				address2.addressLine1 = scrubInvalidTokens(address2.addressLine1);
				address2.addressLine2 = scrubInvalidTokens(address2.addressLine2);
				address2.addressLine3 = scrubInvalidTokens(address2.addressLine3);
				address2.addressLine4 = scrubInvalidTokens(address2.addressLine4);
				address2.addressLine5 = scrubInvalidTokens(address2.addressLine5);
				address2.city = scrubInvalidTokens(address2.city);
				address2.state = scrubInvalidTokens(address2.state);
			}
			shipToElement = WS_soa_SendOrderService_v2_Utils.settingShipTo(address2);
			detailElementArray = WS_soa_SendOrderService_v2_Utils.settingDetail();
			if (WS_soa_SendOrderService_v2_Utils.hasAllowances){
				allowanceElementArray=WS_soa_SendOrderService_v2_Utils.settingAllowanceCharge();
			}
			if (WS_soa_SendOrderService_v2_Utils.hasComments){
				commentElementArray=WS_soa_SendOrderService_v2_Utils.settingComment();
				if (!commentElementArray.isEmpty()){
					for(WS_soa_SendOrderService_v2.commentRecord_element c: commentElementArray){
						// DE564
						c.comment = scrubInvalidTokens(c.comment);
					}
				}	
			}
		}
		catch (exception e){
			errorArray.add(e.getMessage());
		}
		if (errorArray.isEmpty()){      
			// Z is credit card type for all amazon orders.
			String sNoPaymentMiscAllowanceRecords = WS_Integration__c.getValues('No Payment Misc Allowance Records') != null ? WS_Integration__c.getValues('No Payment Misc Allowance Records').value__c : 'Z K';
			String sNoPaymentRecords = WS_Integration__c.getValues('No Payment Records') != null ? WS_Integration__c.getValues('No Payment Records').value__c : 'Y';
			if (!sNoPaymentMiscAllowanceRecords.contains(headerElement.CardType)) {
			// DE880 comment this line add previous line 
			// if(headerElement.cardType != 'Z' && headerElement.cardType != 'K'
			//	&& headerElement.cardType != 'N' && headerElement.cardType != 'H' && headerElement.cardType != 'T'){  //no payment, misc, allowance record for Amazon and Rakuten, Amazon JP, Yahoo JP, Tmall Globa
				miscellaneousChargeElement = WS_soa_SendOrderService_v2_Utils.settingMiscCharge();
				//if (!sNoPaymentRecords.contains(headerElement.cardType) && !ws_soa_SendOrderService_v2_Utils.ord.Replacement_Order__c) {
				// DE880 commment this line add previous line 
				if(headerElement.cardType!='Y' && !WS_soa_SendOrderService_v2_Utils.ord.Replacement_Order__c) {
					paymentElement = WS_soa_SendOrderService_v2_Utils.settingPayment(); //no payment record for Paypal
				}
				if(allowanceElementArray!=null){
					Boolean invalidCoupon = false;
					for(WS_soa_SendOrderService_v2.allowanceChargeReocord_element allowance : allowanceElementArray){
						system.debug(allowance.allowanceCode);
						if(!allowance.allowanceCode.isNumeric()){
							invalidCoupon = true;
						}
					}
					if(invalidCoupon){
						errorArray.add( 'Invalid Coupon Entered, Please check and try again');
					}
				}
			}
			if(detailElementArray.size() > 0){
				Boolean invalidTaxRate = false;
				Boolean invalidTaxAmount = false;
				Boolean invalidBuyReceiveQty = false;
				Boolean invalidDiscount = false;
				Set<Boolean> mixedTaxInfo = new Set<Boolean>();
				for(WS_soa_SendOrderService_v2.detailRecord_element detail : detailElementArray){
					system.debug(detail.fullLineItemPriceTaxRate);
					if(!WS_soa_SendOrderService_v2_Utils.isNumeric(detail.fullLineItemPriceTaxRate)){
						system.debug(detail.fullLineItemPriceTaxRate);
						invalidTaxRate = true;
					}
					if(!WS_soa_SendOrderService_v2_Utils.isNumeric(detail.fullLineItemPriceTaxAmount)){
						invalidTaxAmount = true;
					}
					if(detail.fullLineItemPriceTaxAmount == null || detail.fullLineItemPriceTaxAmount == ''){
						Boolean a = true;
						mixedTaxInfo.add(a);
					}else {
						Boolean b = false;
						mixedTaxInfo.add(b);
					}
					// DE563
					if(detail.itemBuy > detail.itemReceive){
						invalidBuyReceiveQty = true;
					}
					System.debug('-----------------------discount: ' + detail.fullLineItemDiscountAmount);
					if(detail.fullLineItemDiscountAmount != null){
						system.debug('------------------------------------------DetailElementArray: ' + decimal.valueOf(detail.fullLineItemDiscountAmount));
						if(decimal.valueOf(detail.fullLineItemDiscountAmount) < 0){
							// DE852 -- Allow upto a nickle to pass by
							System.debug('-----------------------: ' + Math.abs(decimal.valueOf(detail.fullLineItemDiscountAmount)));
							if (Math.abs(decimal.valueOf(detail.fullLineItemDiscountAmount)) <= 0.05){
								detail.fullLineItemDiscountAmount = null;
							} else {
								invalidDiscount = true;
							}
						}
					}
					System.debug('-----------------------discount: ' + detail.fullLineItemDiscountAmount);
				}
				if(invalidTaxRate){
					errorArray.add( 'Invalid Tax Rate.');
				}
				if(invalidTaxAmount){
					errorArray.add( 'Invalid Tax Amount.');
				}
				if(mixedTaxInfo.size() > 1){
					errorArray.add( 'Cannot have mixed  tax info.  Either all lines have tax or none have tax.');
				}
				// DE563
				if(invalidBuyReceiveQty){
					errorArray.add( 'Item Buy field & Item Rcv field combination is invalid.' );
				}
				if(invalidDiscount){
					errorArray.add('Discount Cannot Be a Negative Amount.');
				}
				
			}else{
				errorArray.add( 'Order must include a minimum of 1 detail record.');
			}
			
			if(string.isNotBlank(headerElement.billTo.phoneNumber)){
				if(headerElement.billTo.phoneNumber.length() > 12){
					headerElement.billTo.foreignTelephone=headerElement.billTo.phoneNumber;
					headerElement.billTo.phoneNumber='0000000000';
				} else {
					if(!headerElement.billTo.phoneNumber.isNumeric()){
						headerElement.billTo.phoneNumber='0000000000';
					}
				}
			}
			
			if(string.isNotBlank(headerElement.billTo.foreignTelephone)){
				if(headerElement.billTo.foreignTelephone.length() > 20){
					headerElement.billTo.foreignTelephone=null;
				} else {
					if(!headerElement.billTo.foreignTelephone.isNumeric()){
						if (headerElement.billTo.foreignTelephone.contains('E')){
							headerElement.billTo.foreignTelephone=null;//catches E issue
						}
					}
				}
			}   
		
			system.debug(paymentElement);
			if (paymentElement!=null){
				if(WS_soa_SendOrderService_v2_Utils.ord.Payment_Type__c == 'Credit Card' && (paymentElement.recordType != 'P' || 
				paymentElement.sequenceNumber == '' || paymentElement.sequenceNumber == null || 
				paymentElement.lineNumber != '11' || paymentElement.profileID == '' || paymentElement.profileID == null ||
				paymentElement.authCode == '' || paymentElement.authCode == null || paymentElement.authorizationAmount == '' ||
				paymentElement.authorizationAmount == null || paymentElement.bankResponseDateTime == '' || 
				paymentElement.bankResponseDateTime == null || paymentElement.transactionReferenceNumber == '' ||
				paymentElement.transactionReferenceNumber == null || paymentElement.transactionRefIndex == '' ||
				paymentElement.transactionRefIndex == null)){       
					errorArray.add( 'Payment information is incomplete for payment type Credit Card.');
				}
				
				if(WS_soa_SendOrderService_v2_Utils.ord.Payment_Type__c != 'Credit Card' && (
				(paymentElement.profileID != null )||  
				(paymentElement.authCode != null )||  
				(paymentElement.transactionReferenceNumber != null) ||
				(paymentElement.transactionRefIndex != null) || 
				(paymentElement.bankResponseDateTime != null))){ 
					errorArray.add( 'Payment information is not valid for payment type Other (non-credit).');
				}

				if (WS_soa_SendOrderService_v2_Utils.ord.Sales_Channel__c!='Brand Website' && 
					WS_soa_SendOrderService_v2_Utils.ord.Order_Total__c!=WS_soa_SendOrderService_v2_Utils.ord.Authorization_Amount__c &&
					WS_soa_SendOrderService_v2_Utils.ord.Payment_Type__c == 'Credit Card'){
					errorArray.add( 'Authorization amount mismatches the order total');
				}
			}
			//DE551 Canada postal code validation & better catches for null addresses
			// Added additional validation for Canada zip codes. They are in the format of A0A 0A0 and may or may not have space.
			// Added additional validation for Canada Zip Codes. If it's in the wrong place, copy it over.
			if (WS_soa_SendOrderService_v2_Utils.shipaddress!=null ){
				if (WS_soa_SendOrderService_v2_Utils.shipaddress.country__c =='CA' && WS_soa_SendOrderService_v2_Utils.shipaddress.Foreign_Postal_Code__c==null){
					string zip = WS_soa_SendOrderService_v2_Utils.shipaddress.Zip_Code__c;
					if (zip != null && Pattern.matches('^[ABCEGHJKLMNPRSTVXY]{1}\\d{1}[A-Z]{1} *\\d{1}[A-Z]{1}\\d{1}$', zip)){
						WS_soa_SendOrderService_v2_Utils.shipaddress.Foreign_Postal_Code__c = zip;
					}else {
						errorArray.add( 'Ship to Address - Canada - Missing Postal Code');
					}     
				}
			} else {
				errorArray.add( 'Ship to Address - Null');    
			}
			// Added additional validation for Canada zip codes. They are in the format of A0A 0A0 and may or may not have space.
			if (WS_soa_SendOrderService_v2_Utils.billaddress!=null ){
				if (WS_soa_SendOrderService_v2_Utils.billaddress.country__c =='CA' && WS_soa_SendOrderService_v2_Utils.billaddress.Foreign_Postal_Code__c==null){
					string zip = WS_soa_SendOrderService_v2_Utils.billaddress.Zip_Code__c;
					if (zip != null && Pattern.matches('^[ABCEGHJKLMNPRSTVXY]{1}\\d{1}[A-Z]{1} *\\d{1}[A-Z]{1}\\d{1}$', zip)){
						WS_soa_SendOrderService_v2_Utils.billaddress.Foreign_Postal_Code__c = zip;
					}else {
						errorArray.add( 'Bill to Address - Canada - Missing Postal Code');
					}     
				}
			} else {
				errorArray.add( 'Bill to Address - Null');    
			}
		}
		if (!errorArray.isEmpty()){
			return errorArray;
		} else {  
			if (!test.isRunningTest()){
				WS_soa_SendOrderService_v2.SendOrderSOAP sendOrderService = new WS_soa_SendOrderService_v2.SendOrderSOAP();             //SendOrderRequest
				responseElement = sendOrderService.SendOrderRequest(headerElement, shipToElement, detailElementArray, allowanceElementArray, null,
																		commentElementArray, miscellaneousChargeElement, null, null, paymentElement);
				
				system.debug(responseElement);
				return new Set <String>{responseElement.StatusCode,responseElement.StatusMessage};
			} else {
				return new Set <String>{'200',null};
			}
		}                                                                                                                                                               
	}
	
	public static WS_soa_AuthorizePaymentService.PaymentReversalResponse orderPaymentReversal(Id OrderId)
	{
		map<string,string> responseMap = new map<string,string>();
		Orders__c sOrder = [Select Name,Authorization_Amount__c,Webstack_Order_ID__c,Payment_Transaction_Reference_Number__c, Credit_Card_Token__c, Payment_Transaction_Reference_Index__c, Payment_Profile_ID__c, Payment_Authorization_Code__c, Order_Total__c, Order_Id__c, customer__r.recordType.developerName From Orders__c where id=:orderId];
		
		string merchantKey =NBTYUtils.getRecordTypeBrandMappingMap().get(sOrder.customer__r.recordType.developerName).merchant_key__c;
			string reversalOrderId = string.isNotBlank(sOrder.Webstack_Order_ID__c) ? sOrder.Webstack_Order_ID__c : sOrder.Name ;
		string retMessage = '';
		string errMessage = '';
		HttpRequest req = new HttpRequest();
		//Validatins for Amount and TransactionReferenceNumber
		if(sOrder.Authorization_Amount__c == null){
			throw new NBTYException('Error processing payment reversals.\n Invalid Authorization Amount.');
		}
		if(string.isblank(sOrder.Payment_Transaction_Reference_Number__c)){
			throw new NBTYException('Error processing payment reversals.\n Invalid Transaction Reference number.');
		}
		string paymentEndPoint = WS_Integration__c.getValues('SOAEndpoint').value__C + WS_Integration__c.getValues('PaymentEndPoint').value__C;
		req.setEndpoint(paymentEndPoint);
		req.setHeader('Content-Type', 'text/xml;charset=UTF-8');
		req.setHeader('Accept-Encoding','gzip,deflate'); 
		req.setHeader('SOAPAction','\"SFReversePreAuthAmountOnCreditCard\"');
		req.setTimeout(120000);
		req.setMethod('POST');
		string xmlString = '<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"  xmlns:erq="http://NBTY.com/GI/PGWY/SF/Schemas/Authorization/RVQ"><soap:Header> ';
		xmlString +='<Security xmlns:wsu="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd" xmlns="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd"><UsernameToken><Username>';
		xmlString += WS_Integration__c.getValues('SOAUserID').value__c;
		xmlString += '</Username><Password>';
		xmlString +=  WS_Integration__c.getValues('SOAPassword').value__c;
		xmlString += '</Password></UsernameToken></Security>';
		xmlString +='</soap:Header>';
		xmlString += '<soap:Body><erq:SFReversalRequest >';
		xmlString += '<erq:MerchantKey>' + merchantKey + '</erq:MerchantKey>';
		xmlString += '<erq:IndustryType>EC</erq:IndustryType>';
		xmlString += '<erq:TokenNumber>' + sOrder.Credit_Card_Token__c + '</erq:TokenNumber>';
		xmlString += '<erq:OrderID>' + reversalOrderId + '</erq:OrderID>';
		xmlString += '<erq:AdjustedAmount>' + formatCurrencyForGateway(string.valueof(sOrder.Authorization_Amount__c)) + '</erq:AdjustedAmount>';
		xmlString += '<erq:TransactionReferenceNumber>' + sOrder.Payment_Transaction_Reference_Number__c + '</erq:TransactionReferenceNumber>';
		xmlString += '</erq:SFReversalRequest></soap:Body></soap:Envelope>';  
		req.setBody(xmlString);
		Http httpreq = new Http();
		HTTPResponse res = new HTTPResponse();
		try{
			SYSTEM.DEBUG('REQ'+REQ.getBody());
			res = httpreq.send(req);
		} catch(Exception e) { 
			system.debug(e.getMessage());
			throw new NBTYException('Error processing payment reversals.\n Please contact System Administrator.');
		}

		system.debug(res.toString());
				
		Integer responseCode = res.getStatusCode();
		String ResponseString = ''; 
	
		system.debug(responseCode);
		if(responseCode < 300) { // Success 
			ResponseString = res.getBody();
			system.debug(ResponseString);
		} else {
			system.debug(ResponseString);
			string strErrorMessage = '[' + string.valueof(responseCode) + '] ' ;
			if(responseCode == 408){
				strErrorMessage += 'Delay in processing payment.\n Please try again.';
			} else {
				strErrorMessage += 'Error processing payment.\n Please contact System Administrator.';
			}
			throw new NBTYException(strErrorMessage);
		}
		
		responseMap = NBTYWSUtil.ParseXML(ResponseString);
		WS_soa_AuthorizePaymentService.PaymentReversalResponse reversalResponse = new WS_soa_AuthorizePaymentService.PaymentReversalResponse();
		reversalResponse.status = responseMap.get('Status');
		reversalResponse.ErrorMessage = responseMap.get('ErrorMessage'); 
		reversalResponse.Message = responseMap.get('Message');
	
		return reversalResponse;
	}
	
	public static WS_soa_AuthorizePaymentService.PaymentResponse payfromNewCard(WS_soa_AuthorizePaymentService.Paymentinfo paymentDetails) {
		WS_soa_AuthorizePaymentService.PaymentResponse paymentResponse = new WS_soa_AuthorizePaymentService.PaymentResponse();
		/*WS_SOA_Payment_Services.BasicHttpBinding_ITwoWayAsyncQSPort paymentService = new WS_SOA_Payment_Services.BasicHttpBinding_ITwoWayAsyncQSPort();
		WS_SOA_Payment_DS_V2.ERQCreditCardInfo_element ccInfoForeNewCard = new WS_SOA_Payment_DS_V2.ERQCreditCardInfo_element();
		WS_SOA_Payment_DS_V2.ERQFraudAnalysis_element fraudanalysis = new WS_SOA_Payment_DS_V2.ERQFraudAnalysis_element();
		//ccinfoforexistingcard.TokenNumber = tokenNumber;
		ccInfoForeNewCard.
		WS_SOA_Payment_DS_V2.SFExistingCreditCardAuthorizationResponse_element preAuthExistingCardResponse = new WS_SOA_Payment_DS_V2.SFExistingCreditCardAuthorizationResponse_element();
		preAuthExistingCardResponse = paymentService.SFPreAuthorizeExistingCreditCard(merchantKey,'EC',CustomerPaymentProfile,iOrderId, formatCurrencyForGateway(string.valueof(sOrder.Order_Total__c)), '',false,ccinfoforexistingcard,fraudanalysis) ;
		// Error Handling 
		system.debug('~~ Inside Error Processing' + preAuthExistingCardResponse.Result); 
		//Error handling for the response received from Payment gateway
		processResponseResult(preAuthExistingCardResponse.Result.Status,preAuthExistingCardResponse.Result.Message,preAuthExistingCardResponse.Result.ErrorMessage);
		WS_soa_AuthorizePaymentService.PaymentResponse paymentResponse = new WS_soa_AuthorizePaymentService.PaymentResponse();
		paymentResponse.TokenNumber = preAuthExistingCardResponse.TokenNumber;
		paymentResponse.AuthorizationCode = preAuthExistingCardResponse.AuthorizationCode;
		paymentResponse.PaymentProfileID = CustomerPaymentProfile;
		paymentResponse.TransactionReferenceNumber = preAuthExistingCardResponse.TransactionReferenceNumber;
		paymentResponse.BankResponseDateTime = string.valueof(preAuthExistingCardResponse.ResponseDateTime);
		// Return Token number
	
		system.debug('paymentres~~'+paymentResponse);*/
		
		return paymentResponse;
	}
	
	public static WS_soa_AuthorizePaymentService.PaymentResponse payfromExistingCard(string OrderId,string tokenNumber) {
		map<string,string> responseMap = new map<string,string>();
		Orders__c sOrder = [Select Name, Order_Total__c,Payment_Transaction_Reference_Number__c, Webstack_Order_ID__c, Credit_Card_Token__c,Customer__r.Payment_Profile_Id__c, Payment_Transaction_Reference_Index__c, Payment_Profile_ID__c, Payment_Authorization_Code__c, customer__r.recordType.developerName From Orders__c where id=:orderId];
		string merchantKey =NBTYUtils.getRecordTypeBrandMappingMap().get( sOrder.customer__r.recordType.developerName).merchant_key__c;
		string CustomerPaymentProfile = sOrder.customer__r.Payment_Profile_Id__c==null?  sOrder.Payment_Profile_ID__c : sOrder.customer__r.Payment_Profile_Id__c;
		if(string.isblank(CustomerPaymentProfile)){
			throw new NBTYException('Error processing payments from existing token. No Payment Profile found');
		}
		string retMessage = '';
		string iOrderId = string.isNotBlank(sOrder.Webstack_Order_ID__c) ? sOrder.Webstack_Order_ID__c : sOrder.Name ;
		WS_SOA_Payment_Services.BasicHttpBinding_ITwoWayAsyncQSPort paymentService = new WS_SOA_Payment_Services.BasicHttpBinding_ITwoWayAsyncQSPort();
		WS_SOA_Payment_DS_V2.ERQCreditCardInfo_element ccinfoforexistingcard = new WS_SOA_Payment_DS_V2.ERQCreditCardInfo_element();
		WS_SOA_Payment_DS_V2.ERQFraudAnalysis_element fraudanalysis = new WS_SOA_Payment_DS_V2.ERQFraudAnalysis_element();
		string strTokenNumber = '';
		if(string.isblank(sOrder.Credit_Card_Token__c)) {
			strTokenNumber = tokenNumber;
		} else {
			strTokenNumber = sOrder.Credit_Card_Token__c;
		}
			
		if(string.isblank(strTokenNumber)) {
			throw new NBTYException('Please select one of the existing credit card.');
		}
		
		 // use existing token
		ccinfoforexistingcard.TokenNumber = strTokenNumber;
		WS_SOA_Payment_DS_V2.SFExistingCreditCardAuthorizationResponse_element preAuthExistingCardResponse = new WS_SOA_Payment_DS_V2.SFExistingCreditCardAuthorizationResponse_element();
		preAuthExistingCardResponse = paymentService.SFPreAuthorizeExistingCreditCard(merchantKey,'EC',CustomerPaymentProfile,iOrderId, formatCurrencyForGateway(string.valueof(sOrder.Order_Total__c)), '',false,ccinfoforexistingcard,fraudanalysis) ;
		// Error Handling 
		system.debug('~~ Inside Error Processing' + preAuthExistingCardResponse.Result); 
		//Error handling for the response received from Payment gateway
		processResultforExistingCard(preAuthExistingCardResponse.Result); 
		WS_soa_AuthorizePaymentService.PaymentResponse paymentResponse = new WS_soa_AuthorizePaymentService.PaymentResponse();
		paymentResponse.TokenNumber = preAuthExistingCardResponse.TokenNumber;
		paymentResponse.AuthorizationCode = preAuthExistingCardResponse.AuthorizationCode;  
		paymentResponse.PaymentProfileID = CustomerPaymentProfile ;
		paymentResponse.TransactionReferenceNumber = preAuthExistingCardResponse.TransactionReferenceNumber;
		paymentResponse.TransactionReferenceIndex = preAuthExistingCardResponse.TransactionReferenceIndex;
		paymentResponse.BankResponseDateTime = string.valueof(preAuthExistingCardResponse.ResponseDateTime).trim().replace(' ','T');
		// Return Token number
	
		system.debug('paymentres~~'+paymentResponse);
		
		return paymentResponse;
	}

	private static void processResultforExistingCard(WS_SOA_Payment_DS_V2.SFExistingCreditCardAuthorizationResponseResult_element Result) {
		string statusMessage = Result.Status;
		string errorMessage = '';
		if(!statusMessage.equalsIgnoreCase('APPROVED')) {
			errorMessage = 'Invalid Code - Invalid Message';
			try {
				if(statusMessage.equalsIgnoreCase('GENERAL_ERROR')) {
					errorMessage = statusMessage + ' - ' + Result.ErrorMessage;
				} else {
					list<string> statusDetails = Result.Message.split(' '); // Split with space ApprovalStatus:1 RespCode:00
					string responseCode = statusDetails[1].split(':')[1];
					string responseDesc = CCReturnCode__c.getValues(responseCode).Definition__c;
					errorMessage = 'DECLINED: ' + responseCode + '-' + responseDesc;
				}
			} catch(exception E) {
				
			}
			throw new NBTYException('Error processing Credit card request: ' + errorMessage );
		}
	}
	
	/*private static void processResponseResult(string Status, string Message, string ErrorMessage) // Seems no generic responses for the 
	{
		string statusMessage = Status;
		string temperrorMessage = '';
		If(!statusMessage.equalsIgnoreCase('APPROVED'))
		{
			temperrorMessage = 'Invalid Code - Invalid Message';
			try{
				if(statusMessage.equalsIgnoreCase('GENERAL_ERROR'))
				{
					temperrorMessage = statusMessage + ' - ' + ErrorMessage;
				}
				else
				{
					list<string> statusDetails = Message.split(' '); // Split with space ApprovalStatus:1 RespCode:00
					string responseCode = statusDetails[1].split(':')[1];
					string responseDesc = CCReturnCode__c.getValues(responseCode).Definition__c;
					temperrorMessage = 'DECLINED: ' + responseCode + '-' + responseDesc;                
				}
			}
	
			catch(exception E)
			{
				
			}
			throw new NBTYException('Error processing Credit card request: ' + temperrorMessage );
			
		}
	}*/
	
	public static string cancelOrderbyCancelOrder_US_v1(Id orderId, string sReason){
		string serviceResponse ;
		string serviceStatus;
		Orders__c sfdcOrderObj = [select id, name from Orders__c where id=:orderId];
		WS_soa_CancelOrderService.OrderCancellationResponse_element  cancelOrderResponseObj;
		try { 
			WS_soa_CancelOrderService.CancelOrderPort   cancelOrderService = new WS_soa_CancelOrderService.CancelOrderPort();
			string orderNumber =sfdcOrderObj.name;
			if (orderNumber.length()==8) {
				orderNumber='00'+orderNumber;
			} else if (orderNumber.length()==9) {
				orderNumber='0'+orderNumber;
			}
			cancelOrderResponseObj =cancelOrderService.CancelOrder(orderNumber, sReason);
			serviceResponse = cancelOrderResponseObj.reason;
			serviceStatus= cancelorderresponseobj.status;
			if(string.isnotblank(Order_Canc_Error_Code__c.getValues(serviceStatus).Error_Description__c)) {
			 serviceResponse = serviceResponse + ' [' + serviceStatus + '] ' + Order_Canc_Error_Code__c.getValues(serviceStatus).Error_Description__c;
			} else {
			 serviceResponse = serviceResponse + ' [' + serviceStatus + '] - Error code not defined';
			}
		} catch (exception e){
			serviceResponse = e.getMessage();
		}
		
		return serviceResponse;
	}
	
	public static WS_soa_AuthorizePaymentService.PaymentResponse ProcessPayment(WS_soa_AuthorizePaymentService.Paymentinfo paymentDetails){
		//<NewCreditCardAuthorizationRequest xmlns="http://NBTY.com/GI/PGWY/Schemas/Authorization/2.6"> <MerchantKey>DRMKEY1008</MerchantKey> <IndustryType>EC</IndustryType> <OrderID>123456789</OrderID> <Amount>85.53</Amount> <SaveCCInfoOnBankLinkDown>false</SaveCCInfoOnBankLinkDown> <CreditCardInfo> <CreditCardNumber>1234567890123456</CreditCardNumber> <CreditCardExpiryDate>201512</CreditCardExpiryDate> <CreditCardTypeID>3</CreditCardTypeID> <NameOnTheCreditCard>Fred Flyntstone</NameOnTheCreditCard> <CreatePaymentProfileIndicator>No</CreatePaymentProfileIndicator> <AddressInfo> <Address1>450 SE Rubble Ave</Address1> <Address2>Apt 100</Address2> <City>Rockville</City> <State>MD</State> <ZipCode>21000</ZipCode> <CountryCode>US</CountryCode> </AddressInfo> </CreditCardInfo></NewCreditCardAuthorizationRequest>
		string xmlString = GetSOASOAPHeader(); 
		map<string,string> responseMap = new map<string,string>();
		xmlString += '<s:Body>';
		xmlString += '<SFNewCreditCardAuthorizationRequest xmlns="http://NBTY.com/GI/PGWY/SF/Schemas/Authorization/NRQ"> ';
		xmlString += '<MerchantKey>'+paymentDetails.merchantKey+'</MerchantKey> <IndustryType>EC</IndustryType>';
		xmlString += '<OrderID>' + paymentDetails.orderId + '</OrderID>';
		xmlString += '<Amount>' + formatCurrencyForGateway(string.valueof(paymentDetails.Amount)) + '</Amount>';
		xmlString += '<SaveCCInfoOnBankLinkDown>false</SaveCCInfoOnBankLinkDown> <CreditCardInfo>';
		xmlString += '<CreditCardNumber>' + paymentDetails.creditCardNumber.deleteWhitespace() + '</CreditCardNumber>';
		xmlString += '<CreditCardExpiryDate>' + paymentDetails.expiryYYYYMM + '</CreditCardExpiryDate>';
		xmlString += '<CreditCardTypeID>' + WS_soa_AuthorizePaymentService.getCreditCardTypeId(paymentDetails.creditCardType)  + '</CreditCardTypeID>';
		xmlString += '<NameOnTheCreditCard>' + paymentDetails.nameOnCard + '</NameOnTheCreditCard>';
		xmlString += '<CreatePaymentProfileIndicator>Yes</CreatePaymentProfileIndicator> <AddressInfo>';
		xmlString += '<Address1>' + paymentDetails.addressLine1.left(30) + '</Address1>';
		xmlString += '<Address2>' + paymentDetails.addressLine2.left(30) + '</Address2>';
		xmlString += '<City>' + paymentDetails.city.left(10) + '</City>';
		
		if(!AddressTriggerHelper.isUSAddress(paymentDetails.countryCode)) {
			xmlString += '<State>FO</State>';
		} else {
			xmlString += '<State>' + paymentDetails.state + '</State>';
		}
		
		xmlString += '<ZipCode>' + paymentDetails.zipCode + '</ZipCode>';
		xmlString += '<CountryCode>' + paymentDetails.countryCode + '</CountryCode>';
		xmlString += '</AddressInfo> </CreditCardInfo>';
		xmlString += '</SFNewCreditCardAuthorizationRequest></s:Body></s:Envelope>';
		string responseString =WS_soa_AuthorizePaymentService.authorizePayment(xmlString);
		responseMap = NBTYWSUtil.ParseXML(responseString);
		WS_soa_AuthorizePaymentService.PaymentResponse paymentRes = new WS_soa_AuthorizePaymentService.PaymentResponse();
		
		if(!responsemap.containskey('Status')) {
			// Not a valid response as no Staus code
			system.debug('Error response from Payment gateway - ' + responseString);
			throw new NBTYException('Error processing new authorization request: No status code present in the response from payment gateway. \n Please contact System Administrator.');
		}
		
		if (!responseMap.get('Status').equalsIgnoreCase('APPROVED')) {
			string errorMessage = 'Invalid Code - Invalid Message';
			try{
				if(responseMap.get('Status').equalsIgnoreCase('GENERAL_ERROR')) {
					errorMessage = responseMap.get('Status') + ' - ' + responseMap.get('ErrorMessage');
				} else {
					list<string> statusDetails = responseMap.get('Message').split(' '); // Split with space ApprovalStatus:1 RespCode:00
					String responseCode = statusDetails[1].split(':')[1];
					String responseDesc = CCReturnCode__c.getValues(responseCode).Definition__c;
					String respStatus = CCReturnCode__c.getValues(responseCode).Status__c;
					errorMessage = 'DECLINED: ' + responseCode + '-' + responseDesc;
					paymentRes.StatusCode = responseCode;
					paymentRes.StatusMessage = responseDesc;
					paymentRes.StatusType = respStatus;
				}
			} catch(exception E) {
				
			}
			//throw new NBTYException('Error processing Credit card request: ' + errorMessage );
			system.debug('Payment Processing: ' +  responseString);
		} else {
			// Return Token number
			paymentRes.AuthorizationCode = responseMap.get('AuthorizationCode');
			paymentRes.BankResponseDateTime = responseMap.get('ResponseDateTime');
			paymentRes.PaymentProfileID = responseMap.get('PaymentProfileID');
			paymentRes.TokenNumber = responseMap.get('TokenNumber');
			paymentRes.TransactionReferenceIndex = responseMap.get('TransactionReferenceIndex');
			paymentRes.TransactionReferenceNumber = responseMap.get('TransactionReferenceNumber');
			system.debug('paymentres~~'+paymentres);
		}
		
		return paymentRes;
		//  return res.getBody();
	}

	public static string formatCurrencyForGateway(string strAmount){
		string formattedAmount;
		system.debug('### Incoming Dollar Amount - ' + strAmount);
		integer totalLength =  strAmount.length();
		integer position = strAmount.indexOf('.');
		integer diff = totalLength - position;
		formattedAmount = strAmount;
		if (diff == 3) {
			formattedAmount = strAmount.replace('.','');
		}
		if (diff == 2) {
			formattedAmount = strAmount.replace('.','') + '0';
			}
		if (diff == 1) {
			formattedAmount = strAmount.replace('.','') + '00';
		}
		return formattedAmount;
	}
	
	/* 
	 * Takes in a string and removes special accented characters and replaces them with their
	 * non-accented counter parts. Each pair is mapped 1:1 DE564
	 */
	public static string scrubInvalidTokens(string input) {
		if (input == null)
			return input;
		// bad chars
		List<string> invalidTokens = new List<string> {'â','ä','à','á','ã','å','ç','ñ','é','ê','ë','è','í','î','ï','ì','ß','Â','Ä',
														'À','Á','Ã','Å','Ç','Ñ','ø','É','Ê','Ë','È','Í','Î','Ï','Ì','Ø','«','»','ð',
														'ý','þ','±','°','ª','º','æ','¸','Æ','¤','µ','¡','¿','Ð','Ý','Þ','®','^','£',
														'¥','·','©','§','¶','¼','½','¾','[','¯','¨','´','×','­','ô','ö','ò','ó','õ',
														'¹','û','ü','ù','ú','ÿ','÷','²','Ô','Ö','Ò','Ó','Õ','³','Û','Ü','Ù','Ú','¬',
														'¢', '&'};
		// good chars may not have a valid equiv and as such will have nothing in its place.                                                        
		List<string> validTokens = new List<string> {'a','a','a','a','a','a','c','n','e','e','e','e','i','i','i','i','B','A','A',
														'A','A','A','A','C','N','o','E','E','E','E','I','I','I','I','O','<','>','d',
														'U','b','+','','a','','a',',','A','o','u','i','?','D','Y','p','','','',
														'','','','','','','','','','','"','','x','-','o','o','o','o','o',
														'','u','u','u','','u','','','O','O','O','O','O','','U','U','U','U','',
														'', ''};
		System.debug('size is: ' + invalidTokens.size() + ' -- ' + invalidTokens);
		System.debug('size is: ' + validTokens.size() + ' -- ' + validTokens);
		string output = input;

		for (integer i = 0; i < invalidTokens.size(); i++) {
			if (output.contains(invalidTokens.get(i))) {
				System.debug('token: ' + invalidTokens.get(i) + ' : ' + validTokens.get(i));
				output = output.replace(invalidTokens.get(i), validTokens.get(i));
			}
		}
		
		System.debug('Before scrubbing: ' + input);
		System.debug('length is: ' + output.length() + ' -- ' + output);
		return output;
	}
}