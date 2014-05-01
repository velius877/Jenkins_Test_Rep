@isTest
public class OrderUtilities_Test {
	
	testmethod static void processInternalReviewBtnTest(){
	    testDataSetupUtil.SetupCoreData(2);
		PageReference  p = Page.Order_Detail;
		Test.setCurrentPage(p);
		test.startTest();
		testDataSetupUtil.order1.Payment_Type__c = 'Credit Card';
		ApexPages.currentPage().getParameters().put('Id', testDataSetupUtil.order1.id);
  		ApexPages.StandardController sc = new ApexPages.StandardController(testDataSetupUtil.order1);
		Order_DetailsExtension detailsExt= new Order_DetailsExtension(sc);
		detailsExt.processInternalReviewBtn(); 
		detailsExt.processOrderCancelBtn();
		test.stopTest();
		//system.assert(detailsExt.showInternalReviewBtn);
		//system.assert(detailsExt.orderSObj.Order_Status__c != 'Internal Review');
	}
	
	testmethod static void testCancellation(){
		testDataSetupUtil.SetupCoreData(2);
		 StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
		mock.setStaticResource('PaymentReversalResponse');
		mock.setStatusCode(200);
		mock.setHeader('Content-Type', 'text/xml');
		// Set the mock callout mode
		Test.setMock(HttpCalloutMock.class, mock);
		// Call the method that performs the callout
		test.startTest();
		testDataSetupUtil.order1.order_submitted__c = true;
		testDataSetupUtil.order1.payment_type__c = 'Credit Card';
		testDataSetupUtil.order1.Credit_Card_Token__c ='123xyz';
		testDataSetupUtil.order1.order_status__c = 'Partially Shipped';
		update testDataSetupUtil.order1;
		OrderUtilities.processOrderCancel(testDataSetupUtil.order1.id,'Customer Cancelled');
		OrderUtilities.forceCancel(testDataSetupUtil.order1.id,'Customer Cancelled');
			system.assertEquals([select order_status__c from Orders__c where id =:testDataSetupUtil.order1.id].order_status__c, 'Cancelled');
		test.stopTest();
	}
	
		testmethod static void testCancellation_2(){
		testDataSetupUtil.SetupCoreData(2);
		 StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
		mock.setStaticResource('PaymentReversalResponse');
		mock.setStatusCode(200);
		mock.setHeader('Content-Type', 'text/xml');
		// Set the mock callout mode
		Test.setMock(HttpCalloutMock.class, mock);
		// Call the method that performs the callout
		test.startTest();

		testDataSetupUtil.order1.order_submitted__c = false;
		testDataSetupUtil.order1.payment_type__c = 'Credit Card';
		testDataSetupUtil.order1.Credit_Card_Token__c ='123xyz';
		testDataSetupUtil.order1.order_status__c = 'In Progress';
		update testDataSetupUtil.order1;
				string s = OrderUtilities.isOrderValidForSubmit(testDataSetupUtil.order1.id);
		system.assert(s.contains('ayment Authorization code')!=null);
		OrderUtilities.processOrderCancel(testDataSetupUtil.order1.id,'Customer Cancelled');
	
		test.stopTest();
	}
	
		testmethod static void teststraightreversal(){
		testDataSetupUtil.SetupCoreData(2);
		 StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
		mock.setStaticResource('PaymentReversalResponse');
		mock.setStatusCode(200);
		mock.setHeader('Content-Type', 'text/xml');
		// Set the mock callout mode
		Test.setMock(HttpCalloutMock.class, mock);
		// Call the method that performs the callout
		test.startTest();

		testDataSetupUtil.order1.order_submitted__c = false;
		testDataSetupUtil.order1.payment_type__c = 'Credit Card';
		testDataSetupUtil.order1.Credit_Card_Token__c ='123xyz';
		testDataSetupUtil.order1.order_status__c = 'In Progress';
		update testDataSetupUtil.order1;
		

		OrderUtilities.processAuthReversal(testDataSetupUtil.order1, false);
		
		OrderUtilities.processInternalReview(testDataSetupUtil.order1.id, 'yup');
		system.assertEquals([select internal_review_reason__c from Orders__c where id =:testDataSetupUtil.order1.id].internal_review_reason__c, 'yup');
		test.stopTest();
	}
	
	
	

}