@isTest
global class soa_WebservicesClientUtil_Test {
	static testMethod void testSubmitOrderService(){
		testDataSetupUtil.SetupCoreData(2);
		OrderSummaryTriggerHelperTest.setupInboundOrderMapping();
		OrderSummaryTriggerHelperTest.setupWebStoresData();
		Order_Summary__c OSRec = OrderSummaryTriggerHelperTest.setupOrderSummary();
		Orders__c OrdGenerated = [SELECT Id, Webstack_Order_ID__c, Customer__c, (Select Id From Order_Line_Items__r), Bill_To_Address__c, Ship_To_Address__c FROM Orders__c WHERE Webstack_Order_ID__c = :OSRec.Webstack_Order_ID__c];
		
		Set <String> submitRespSet = soa_WebservicesClientUtil.submitOrderBySendOrderService2(OrdGenerated.id);
		
	}
	static testMethod void testAdditionalOrderServiceObjects(){
			testDataSetupUtil.SetupCoreData(2);
		WS_soa_SendOrderService_v2 sendOrderService = new WS_soa_SendOrderService_v2();
		WS_soa_SendOrderService_v2.loyaltyPoints_element lpe= new WS_soa_SendOrderService_v2.loyaltyPoints_element();
		WS_soa_SendOrderService_v2.extendedRecord_element ext= new WS_soa_SendOrderService_v2.extendedRecord_element();
		WS_soa_SendOrderService_v2.secureCode_element sec= new WS_soa_SendOrderService_v2.secureCode_element();
		WS_soa_SendOrderService_v2.SendOrderResponse_element sor= new WS_soa_SendOrderService_v2.SendOrderResponse_element();
		WS_soa_SendOrderService_v2.clickToCollect_element ctc= new WS_soa_SendOrderService_v2.clickToCollect_element();
		WS_soa_SendOrderService_v2.loyalty_element le= new WS_soa_SendOrderService_v2.loyalty_element();
		WS_soa_SendOrderService_v2.batchCountRecord_element bcre= new WS_soa_SendOrderService_v2.batchCountRecord_element();
		WS_soa_SendOrderService_v2.order_element oe= new WS_soa_SendOrderService_v2.order_element();
		WS_soa_SendOrderService_v2.discountRecord_element dre= new WS_soa_SendOrderService_v2.discountRecord_element();
		WS_soa_SendOrderService_v2.SendOrderSOAP soap= new WS_soa_SendOrderService_v2.SendOrderSOAP ();
		

	}
	
	static testmethod void testCancelOrder(){
		testDataSetupUtil.SetupCoreData(2);
		WS_soa_CancelOrderService.OrderCancellationRequest_element orreq = new WS_soa_CancelOrderService.OrderCancellationRequest_element();
		WS_soa_CancelOrderService.OrderCancellationResponse_element orrep = new WS_soa_CancelOrderService.OrderCancellationResponse_element();
		WS_soa_CancelOrderService.CancelOrderPort Corp = new WS_soa_CancelOrderService.CancelOrderPort();
		string CancelReason = soa_WebservicesClientUtil.cancelOrderbyCancelOrder_US_v1(testDataSetupUtil.order1.id, 'Test Reason');
	}
	static testmethod void testPayments(){
		testDataSetupUtil.processWsIntData();
		testDataSetupUtil.createCCTM();
		WS_soa_AuthorizePaymentService.PaymentInfo testpayinfo = new WS_soa_AuthorizePaymentService.PaymentInfo();
		testpayinfo.orderId = '123456789';
		testpayinfo.amount = 100.00;
		testpayinfo.creditCardNumber = '1234567890';
		testpayinfo.expiryYYYYMM = '201512';
		testpayinfo.nameOnCard = 'Test Test';
		testpayinfo.addressLine1 = '123 Main Street';
		testpayinfo.addressLine2 = 'Test Block';
		testpayinfo.city = 'Test City';
		testpayinfo.state = 'TS';
		testpayinfo.countryCode = 'USA';
		testpayinfo.creditCardType = 'Discover';
		StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
		mock.setStaticResource('PaymentResponse');
		mock.setStatusCode(200);
		mock.setHeader('Content-Type', 'text/xml');
		// Set the mock callout mode
		Test.setMock(HttpCalloutMock.class, mock);
		// Call the method that performs the callout
		Test.startTest();
		WS_soa_AuthorizePaymentService.PaymentResponse payresponse = soa_WebservicesClientUtil.ProcessPayment(testPayinfo);
		//string paymentToken  = soa_WebservicesClientUtil.ProcessPayment(testPayinfo);
		System.assertEquals('TestToken', payResponse.TokenNumber); // Test for sorted result
		Test.stoptest();
	}
		
	static testmethod void testPaymentsfromExistingCard(){
		testDataSetupUtil.SetupCoreData(2);
		testDataSetupUtil.acct.Payment_Profile_Id__c='123';

		Test.setMock(WebServiceMock.class, new PaymentServicesMockTest ());
		// Call the method that performs the callout
		Test.startTest();
		WS_soa_AuthorizePaymentService.PaymentResponse payresponse = soa_WebservicesClientUtil.payfromExistingCard(testDataSetupUtil.order1.id, '12345');
		//string paymentToken  = soa_WebservicesClientUtil.ProcessPayment(testPayinfo);
		System.assertEquals('TestToken', payResponse.TokenNumber); // Test for sorted result
		Test.stoptest();
	}
		
	static testmethod void testPaymentsReversals(){
		testDataSetupUtil.SetupCoreData(2);
		StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
		mock.setStaticResource('PaymentReversalResponse');
		mock.setStatusCode(200);
		mock.setHeader('Content-Type', 'text/xml');
		// Set the mock callout mode
		Test.setMock(HttpCalloutMock.class, mock);
		// Call the method that performs the callout
		OrderWizard_Wrapper or1 = new OrderWizard_Wrapper(testDataSetupUtil.order1);
		or1.Total = 100.00;
		Account acct = [select recordType.developerName, id, name from Account where id =:testDataSetupUtil.acct.id];
		or1.newOrder.customer__r=acct;
		WS_soa_AuthorizePaymentService.PaymentInfo pr1 = new WS_soa_AuthorizePaymentService.PaymentInfo(or1);
		Test.startTest();
		 WS_soa_AuthorizePaymentService.PaymentReversalResponse payreverseresponse = soa_WebservicesClientUtil.orderPaymentReversal(testDataSetupUtil.order1.id);
		//string paymentToken  = soa_WebservicesClientUtil.ProcessPayment(testPayinfo);
		System.assertEquals('APPROVED', payreverseresponse.Status); // Test for sorted result
		Test.stoptest();
	}
	
}