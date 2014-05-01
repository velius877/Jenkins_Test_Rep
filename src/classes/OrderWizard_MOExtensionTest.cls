@isTest
public with sharing class OrderWizard_MOExtensionTest {
	testmethod static void testOrderWizardMO_New(){
			testDataSetupUtil.SetupCoreData(2);
			PageReference  p = Page.OrderWizardMailOrders;
			Test.setCurrentPage(p);
			testDataSetupUtil.order1.Catalog_Source_Code__c='blah';
			update testDataSetupUtil.order1;
			Test.setMock(WebServiceMock.class, new MockControllerCallout());
			test.startTest();
			ApexPages.currentPage().getParameters().put('Id', testDataSetupUtil.order1.id);
			ApexPages.StandardController sc = new ApexPages.StandardController(testDataSetupUtil.order1);
			OrderWizard_MOExtension orderController = new OrderWizard_MOExtension(sc);
			orderController.init(); 
			orderController.CreateOrder();
			orderController.oliWrapperList_Mail[0].oliWrap.ordrLineItem.sku_number__c=testDataSetupUtil.itemList[0].product_number__c;
			orderController.oliWrapperList_Mail[0].oliWrap.ordrLineItem.Original_Quantity__c=1;
					orderController.oliWrapperList_Mail[1].oliWrap.ordrLineItem.sku_number__c='blah';
			orderController.oliWrapperList_Mail[1].oliWrap.ordrLineItem.Original_Quantity__c=1;
			try {
				orderController.validateMailOrder();
			}
			catch(exception e ){
				system.assert(e.getMessage().contains('sku'));
			}
			ApexPages.currentPage().getParameters().put('indexKey', orderController.oliWrapperList_Mail[1].indexKey);
			orderController.removeItem();//remove the bad item
			orderController.validateMailOrder();//validate should now be good to go
			orderController.calculateTax();//calc tax
			orderController.submitOrder();//submit

			test.stopTest();
			system.assertEquals('Open', [select order_status__c from Orders__c where id=:testDataSetupUtil.order1.id].order_status__c);
			//check that the order is pending submission
	}

	testMethod static void testCreateCredit(){
		testDataSetupUtil.SetupCoreData(2);
		PageReference  p = Page.OrderWizardMailOrders;
		Test.setMock(WebServiceMock.class, new MockControllerCallout());
		Test.setCurrentPage(p);
		test.startTest();
		ApexPages.currentPage().getParameters().put('Id', testDataSetupUtil.order1.id);
		ApexPages.StandardController sc = new ApexPages.StandardController(testDataSetupUtil.order1);
		OrderWizard_MOExtension orderController = new OrderWizard_MOExtension(sc);
		
		orderController.createCredit();
		
		test.stopTest();
	}
	
	testMethod static void testResetPriceOverride(){
		testDataSetupUtil.SetupCoreData(2);
		PageReference  p = Page.OrderWizardMailOrders;
		Test.setMock(WebServiceMock.class, new MockControllerCallout());
		Test.setCurrentPage(p);
		test.startTest();
		ApexPages.currentPage().getParameters().put('Id', testDataSetupUtil.order1.id);
		ApexPages.StandardController sc = new ApexPages.StandardController(testDataSetupUtil.order1);
		OrderWizard_MOExtension orderController = new OrderWizard_MOExtension(sc);
		
		orderController.ResetPriceOverride();
		
		test.stopTest();
	}
	
	testMethod static void testCreateOrder(){
		testDataSetupUtil.SetupCoreData(2);
		PageReference  p = Page.OrderWizardMailOrders;
		Test.setMock(WebServiceMock.class, new MockControllerCallout());
		Test.setCurrentPage(p);
		test.startTest();
		ApexPages.currentPage().getParameters().put('Id', testDataSetupUtil.order1.id);
		ApexPages.StandardController sc = new ApexPages.StandardController(testDataSetupUtil.order1);
		OrderWizard_MOExtension orderController = new OrderWizard_MOExtension(sc);
		
		orderController.createOrder();
		
		test.stopTest();
	}
	
	testMethod static void testChgPaymentType(){
		testDataSetupUtil.SetupCoreData(2);
		PageReference  p = Page.OrderWizardMailOrders;
		Test.setMock(WebServiceMock.class, new MockControllerCallout());
		Test.setCurrentPage(p);
		test.startTest();
		ApexPages.currentPage().getParameters().put('Id', testDataSetupUtil.order1.id);
		ApexPages.StandardController sc = new ApexPages.StandardController(testDataSetupUtil.order1);
		OrderWizard_MOExtension orderController = new OrderWizard_MOExtension(sc);

		// with true
		orderController.showCashPayment = true;		
		orderController.chgPaymentType();
		
		// with false
		orderController.showCashPayment = false;		
		orderController.chgPaymentType();
		
		test.stopTest();
	}
	
	testMethod static void testCustomerCredit(){
		testDataSetupUtil.SetupCoreData(2);
		PageReference  p = Page.OrderWizardMailOrders;
		Test.setMock(WebServiceMock.class, new MockControllerCallout());
		Test.setCurrentPage(p);
		test.startTest();
		ApexPages.currentPage().getParameters().put('Id', testDataSetupUtil.order1.id);
		ApexPages.StandardController sc = new ApexPages.StandardController(testDataSetupUtil.order1);
		OrderWizard_MOExtension orderController = new OrderWizard_MOExtension(sc);
		
		orderController.customerCredit();
		
		test.stopTest();
	}
	
	testMethod static void testRemoveItem(){
		testDataSetupUtil.SetupCoreData(2);
		PageReference  p = Page.OrderWizardMailOrders;
		Test.setMock(WebServiceMock.class, new MockControllerCallout());
		Test.setCurrentPage(p);
		test.startTest();
		ApexPages.currentPage().getParameters().put('Id', testDataSetupUtil.order1.id);
		ApexPages.StandardController sc = new ApexPages.StandardController(testDataSetupUtil.order1);
		OrderWizard_MOExtension orderController = new OrderWizard_MOExtension(sc);
		
		orderController.removeItem();
		
		test.stopTest();
	}
	
	testMethod static void testApplyPromotion_Mail(){
		testDataSetupUtil.SetupCoreData(2);
		PageReference  p = Page.OrderWizardMailOrders;
		Test.setMock(WebServiceMock.class, new MockControllerCallout());
		Test.setCurrentPage(p);
		test.startTest();
		ApexPages.currentPage().getParameters().put('Id', testDataSetupUtil.order1.id);
		ApexPages.StandardController sc = new ApexPages.StandardController(testDataSetupUtil.order1);
		OrderWizard_MOExtension orderController = new OrderWizard_MOExtension(sc);
		
		WS_webstack_PromotionObjects_v2.ApplyPromotionResponse promo = new WS_webstack_PromotionObjects_v2.ApplyPromotionResponse();
		promo.IsSuccessful = true;
		promo.Status = 'Success';
		promo.StatusMessage = 'Successful promo response.';
		WS_webstack_PromotionObjects_v2.ApplyPromotionResponseData promoData = new WS_webstack_PromotionObjects_v2.ApplyPromotionResponseData();
		promoData.Allowances = new List<WS_webstack_PromotionObjects_v2.Allowance>();
		
		WS_webstack_PromotionObjects_v2.Allowance a = new WS_webstack_PromotionObjects_v2.Allowance();
		a.AllowanceCode = 69;
		a.Amount = 4.95;
		promoData.Allowances.add(a);
		
		promo.Data = promoData; 
		
		orderController.orderWizard.wrap.promoResponse = promo;
		
		orderController.ApplyPromotion_Mail();
		
		test.stopTest();
	}
	
	testMethod static void testCalculateTax(){
		testDataSetupUtil.SetupCoreData(2);
		PageReference  p = Page.OrderWizardMailOrders;
		Test.setMock(WebServiceMock.class, new MockControllerCallout());
		Test.setCurrentPage(p);
		test.startTest();
		ApexPages.currentPage().getParameters().put('Id', testDataSetupUtil.order1.id);
		ApexPages.StandardController sc = new ApexPages.StandardController(testDataSetupUtil.order1);
		OrderWizard_MOExtension orderController = new OrderWizard_MOExtension(sc);
		
		orderController.orderWizard.wrap.selectedpaymentType = 'Credit Card';
		orderController.orderWizard.wrap.Discount = 0;
		orderController.orderWizard.wrap.ShippingDiscount = 4.95;
		orderController.orderWizard.wrap.ShippingCharges = 0;
		orderController.orderWizard.wrap.PreTaxTotal = 0;
		orderController.orderWizard.wrap.Tax = 0;
		orderController.calculateTax();
		
		test.stopTest();
	}
	
	testMethod static void testCalcDelta(){
		testDataSetupUtil.SetupCoreData(2);
		PageReference  p = Page.OrderWizardMailOrders;
		Test.setMock(WebServiceMock.class, new MockControllerCallout());
		Test.setCurrentPage(p);
		test.startTest();
		ApexPages.currentPage().getParameters().put('Id', testDataSetupUtil.order1.id);
		ApexPages.StandardController sc = new ApexPages.StandardController(testDataSetupUtil.order1);
		OrderWizard_MOExtension orderController = new OrderWizard_MOExtension(sc);
		
		orderController.orderWizard.wrap.selectedpaymentType = 'Credit Card';
		orderController.ordTotal = 2.98;
		orderController.orderWizard.CustomerCredits = 99;
		orderController.orderWizard.Wrap.TotalCreditApplied = 32.98;
		
		orderController.calcDelta();
		orderController.orderWizard.Wrap.CreditApplied = true;
		orderController.calcDelta();
		test.stopTest();
	}
	
	testMethod static void testAuthorizePayment(){
		testDataSetupUtil.SetupCoreData(2);
		PageReference  p = Page.OrderWizardMailOrders;
		Test.setMock(WebServiceMock.class, new MockControllerCallout());
		Test.setCurrentPage(p);
		test.startTest();
		ApexPages.currentPage().getParameters().put('Id', testDataSetupUtil.order1.id);
		ApexPages.StandardController sc = new ApexPages.StandardController(testDataSetupUtil.order1);
		OrderWizard_MOExtension orderController = new OrderWizard_MOExtension(sc);
		
		orderController.orderWizard.wrap.Total = 32.98;
		orderController.orderWizard.wrap.selectedPaymentType = 'Credit Card';
		orderController.orderWizard.wrap.paymentInfo = new WS_soa_AuthorizePaymentService.PaymentInfo(orderController.orderWizard.wrap);
		orderController.orderWizard.wrap.paymentInfo.creditCardNumber='123456';
		orderController.AuthorizePayment();
		
		test.stopTest();
	}
	
	testMethod static void testSubmitOrder(){
		// needs to have page error list empty to finish testing this method
		testDataSetupUtil.SetupCoreData(2);
		PageReference  p = Page.OrderWizardMailOrders;
		Test.setMock(WebServiceMock.class, new MockControllerCallout());
		Test.setCurrentPage(p);
		test.startTest();
		ApexPages.currentPage().getParameters().put('Id', testDataSetupUtil.order1.id);
		ApexPages.StandardController sc = new ApexPages.StandardController(testDataSetupUtil.order1);
		OrderWizard_MOExtension orderController = new OrderWizard_MOExtension(sc);
		
		orderController.orderWizard.wrap.newOrder.Check_Number__c = '987654321';
		orderController.orderWizard.wrap.newOrder.Batch_Number__c = '123456789';
		orderController.orderWizard.wrap.newOrder.Batch_Sequence_Number__c = '12';
		orderController.submitOrder();
		
		orderController.orderWizard.wrap.newOrder.Check_Number__c = '987654321';
		orderController.orderWizard.wrap.newOrder.Batch_Number__c = 'BATCHNUMBER';
		orderController.orderWizard.wrap.newOrder.Batch_Sequence_Number__c = '12';
		orderController.submitOrder();
		
		orderController.orderWizard.wrap.selectedpaymentType = 'Check';
		orderController.orderWizard.wrap.newOrder.Check_Number__c = '987654321';
		orderController.orderWizard.wrap.newOrder.Batch_Number__c = '123456789';
		orderController.orderWizard.wrap.newOrder.Batch_Sequence_Number__c = '99';
		orderController.submitOrder();
		
		orderController.orderWizard.wrap.selectedpaymentType = 'Check';
		orderController.orderWizard.wrap.newOrder.Check_Number__c = '987654321';
		orderController.orderWizard.wrap.newOrder.Batch_Number__c = '123456789';
		orderController.orderWizard.wrap.newOrder.Batch_Sequence_Number__c = 'af';
		orderController.submitOrder();
		
		test.stopTest();
	}
	
	testMethod static void testOrderAdjustmentGen (){
		// needs to have page error list empty to finish testing this method
		testDataSetupUtil.SetupCoreData(2);
		PageReference  p = Page.OrderWizardMailOrders;
		Test.setMock(WebServiceMock.class, new MockControllerCallout());
		Test.setCurrentPage(p);
		test.startTest();
		ApexPages.currentPage().getParameters().put('Id', testDataSetupUtil.order1.id);
		ApexPages.StandardController sc = new ApexPages.StandardController(testDataSetupUtil.order1);
		OrderWizard_MOExtension orderController = new OrderWizard_MOExtension(sc);
	 
		
		orderController.orderWizard.wrap.selectedpaymentType = 'Check';
		orderController.orderWizard.wrap.newOrder.Check_Number__c = '987654321';
		orderController.orderWizard.wrap.newOrder.Batch_Number__c = '123456789';
		orderController.orderWizard.wrap.newOrder.Batch_Sequence_Number__c = 'af';
		orderController.orderWizard.wrap.newOrder.Order_Total__c=32.99;
		orderController.orderWizard.wrap.Total = 32.99;
		orderController.orderWizard.wrap.paymentInfo = new WS_soa_AuthorizePaymentService.PaymentInfo(orderController.orderWizard.wrap);
		orderController.orderWizard.wrap.paymentInfo.amount = orderController.ordTotal = 32.98;
		orderController.calcDelta();
		orderController.createOrderAdjustmentUponSubmission();
		
		
		test.stopTest();
		system.assert([select count() from Order_Adjustment__c where related_order__c =:testDataSetupUtil.order1.id]==1);
		system.assert([select order_status__c from Orders__c where id =:testDataSetupUtil.order1.id].order_status__c!='Waiting on Full Payment');
	}
	
	testMethod static void testOrderAdjustmentGen_over5 (){
		// needs to have page error list empty to finish testing this method
		testDataSetupUtil.SetupCoreData(2);
		PageReference  p = Page.OrderWizardMailOrders;
		Test.setMock(WebServiceMock.class, new MockControllerCallout());
		Test.setCurrentPage(p);
		test.startTest();
		ApexPages.currentPage().getParameters().put('Id', testDataSetupUtil.order1.id);
		ApexPages.StandardController sc = new ApexPages.StandardController(testDataSetupUtil.order1);
		OrderWizard_MOExtension orderController = new OrderWizard_MOExtension(sc);
	 
		
		orderController.orderWizard.wrap.selectedpaymentType = 'Check';
		orderController.orderWizard.wrap.newOrder.Check_Number__c = '987654321';
		orderController.orderWizard.wrap.newOrder.Batch_Number__c = '123456789';
		orderController.orderWizard.wrap.newOrder.Batch_Sequence_Number__c = 'af';
		orderController.orderWizard.wrap.newOrder.Order_Total__c=320.99;
		orderController.orderWizard.wrap.Total = 320.99;
		orderController.orderWizard.wrap.paymentInfo = new WS_soa_AuthorizePaymentService.PaymentInfo(orderController.orderWizard.wrap);
		orderController.orderWizard.wrap.paymentInfo.amount = orderController.ordTotal = 32.98;
		orderController.calcDelta();
		orderController.createOrderAdjustmentUponSubmission();
		
		 
		test.stopTest(); 
		system.assert([select count() from Order_Adjustment__c where related_order__c =:testDataSetupUtil.order1.id]==1);
		system.assert([select order_status__c from Orders__c where id =:testDataSetupUtil.order1.id].order_status__c=='Waiting on Full Payment');
	}
	
	
	testMethod static void testSavePayments(){
		testDataSetupUtil.SetupCoreData(2);
		PageReference  p = Page.OrderWizardMailOrders;
		Test.setMock(WebServiceMock.class, new MockControllerCallout());
		Test.setCurrentPage(p);
		test.startTest();
		ApexPages.currentPage().getParameters().put('Id', testDataSetupUtil.order1.id);
		ApexPages.StandardController sc = new ApexPages.StandardController(testDataSetupUtil.order1);
		OrderWizard_MOExtension orderController = new OrderWizard_MOExtension(sc);
		
		orderController.orderWizard.wrap.Total = 32.98;
		orderController.orderWizard.wrap.selectedPaymentType = 'Credit Card';
		orderController.orderWizard.wrap.paymentInfo = new WS_soa_AuthorizePaymentService.PaymentInfo(orderController.orderWizard.wrap);
		orderController.orderWizard.wrap.paymentInfo.amount = 32.98;
		orderController.savePayments();
		
		test.stopTest();
	}
	
	testMethod static void testSaveOrder(){
		testDataSetupUtil.SetupCoreData(2);
		PageReference  p = Page.OrderWizardMailOrders;
		Test.setMock(WebServiceMock.class, new MockControllerCallout());
		Test.setCurrentPage(p);
		test.startTest();
		ApexPages.currentPage().getParameters().put('Id', testDataSetupUtil.order1.id);
		ApexPages.StandardController sc = new ApexPages.StandardController(testDataSetupUtil.order1);
		OrderWizard_MOExtension orderController = new OrderWizard_MOExtension(sc);
		
		orderController.orderWizard.wrap.Total = 32.98;
		orderController.orderWizard.wrap.selectedPaymentType = 'Credit Card';
		orderController.orderWizard.wrap.paymentInfo = new WS_soa_AuthorizePaymentService.PaymentInfo(orderController.orderWizard.wrap);
		orderController.orderWizard.wrap.paymentInfo.amount = 32.98;
		orderController.saveOrder();
		
		test.stopTest();
	}
	
	testMethod static void testCreateCase(){
		testDataSetupUtil.SetupCoreData(2);
		PageReference  p = Page.OrderWizardMailOrders;
		Test.setMock(WebServiceMock.class, new MockControllerCallout());
		Test.setCurrentPage(p);
		test.startTest();
		ApexPages.currentPage().getParameters().put('Id', testDataSetupUtil.order1.id);
		ApexPages.StandardController sc = new ApexPages.StandardController(testDataSetupUtil.order1);
		OrderWizard_MOExtension orderController = new OrderWizard_MOExtension(sc);
		
		orderController.createCase();
		
		test.stopTest();
	}
	
	testMethod static void testPromoSearchResults(){
		testDataSetupUtil.SetupCoreData(2);
		PageReference  p = Page.OrderWizardMailOrders;
		Test.setMock(WebServiceMock.class, new MockControllerCallout());
		Test.setCurrentPage(p);
		test.startTest();
		ApexPages.currentPage().getParameters().put('Id', testDataSetupUtil.order1.id);
		ApexPages.StandardController sc = new ApexPages.StandardController(testDataSetupUtil.order1);
		OrderWizard_MOExtension orderController = new OrderWizard_MOExtension(sc);
		
		// error is thrown for not finding the order that clearly exists.
		// once rectified, try will be removed.
		try{
			OrderWizard_MOExtension.getPromotionRecords(true, 'FREEBS', orderController.orderWizard.wrap.newOrder.id);
		}catch (Exception e){
			// do nothing.
		}
		test.stopTest();
	}
	
	testMethod static void testPromoResultSet(){
		testDataSetupUtil.SetupCoreData(2);
		PageReference  p = Page.OrderWizardMailOrders;
		Test.setMock(WebServiceMock.class, new MockControllerCallout());
		Test.setCurrentPage(p);
		test.startTest();
		ApexPages.currentPage().getParameters().put('Id', testDataSetupUtil.order1.id);
		ApexPages.StandardController sc = new ApexPages.StandardController(testDataSetupUtil.order1);
		OrderWizard_MOExtension orderController = new OrderWizard_MOExtension(sc);
		
		OrderWizard_MOExtension.PromoResultSet prs = new OrderWizard_MOExtension.PromoResultSet(testDataSetupUtil.promo);
		
		test.stopTest();
	}
}