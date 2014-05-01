@isTest
public with sharing class WS_OrderAdjustment_Utils_Test {

	public static Case testCase;

	public static void setupData(){
		testDataSetupUtil.SetupCoreData(2);
		Case c = new Case (accountId=testDataSetupUtil.acct.id, status='New', related_order__c=testDataSetupUtil.order1.id);
		insert c;
		testCase=c;
	}

	public static testMethod void test_OA_Refund_Failure(){
		setupData();
		testDataSetupUtil.order1.Order_Submitted__c=true;
		testDataSetupUtil.order1.Order_Status__c='Submitted';
		testDataSetupUtil.order1.Payment_Type__c='Credit Card';
		testDataSetupUtil.order1.Credit_Card_Type__c = 'MasterCard';
		testDataSetupUtil.order1.Credit_Card_Token__c='@Y8VFTY@WM3-4113';
		testDataSetupUtil.order1.Payment_Transaction_Reference_Number__c='53066D458FD0195E40B3DF0690BAE4624B77545F';
		update  testDataSetupUtil.order1;
			Order_Adjustment__c oa = new Order_Adjustment__c(related_order__c=testDataSetupUtil.order1.id, customer__c=testDataSetupUtil.acct.id);
		RecordType rt = [select id from RecordType where developerName='Refund' and sobjectType='Order_Adjustment__c'];

		oa.recordTypeId=rt.id;
		oa.Refund_Type__c='Full Refund';
		oa.Payment_Method__c='Credit Card';
		oa.Credit_Card_Type__c = 'MasterCard';
		oa.Refund_or_Misc_Amount__c=0;
		insert oa;
		testDataSetupUtil.oa=oa;
		test.startTest();
		Test.setMock(WebServiceMock.class, new MockResponse_OrderAdjustmentService ());
		WS_soa_OrderAdjustmentService.OrderAdjustmentResponse resp =WS_OrderAdjustmentUtils.doCallout(oa);
		test.stopTest();
		system.assert(WS_OrderAdjustmentUtils.refundRequest.refundType=='K');
		system.assert([select status__c from Order_Adjustment__c where id=:oa.id].status__c=='Error');
	}


	public static testMethod void test_OA_Refund_Credit(){
		setupData();
		testDataSetupUtil.order1.Order_Submitted__c=true;
		testDataSetupUtil.order1.Order_Status__c='Submitted';
		testDataSetupUtil.order1.Payment_Type__c='Credit Card';
		testDataSetupUtil.order1.Credit_Card_Token__c='@Y8VFTY@WM3-4113';
		testDataSetupUtil.order1.Credit_Card_Type__c = 'MasterCard';
		testDataSetupUtil.order1.Payment_Transaction_Reference_Number__c='53066D458FD0195E40B3DF0690BAE4624B77545F';
		update  testDataSetupUtil.order1;
			Order_Adjustment__c oa = new Order_Adjustment__c(related_order__c=testDataSetupUtil.order1.id, customer__c=testDataSetupUtil.acct.id);
		RecordType rt = [select id from RecordType where developerName='Refund' and sobjectType='Order_Adjustment__c'];
		Test.setMock(WebServiceMock.class, new MockResponse_OrderAdjustmentService ());
		oa.recordTypeId=rt.id;
		oa.Refund_Type__c='Full Refund';
		oa.Payment_Method__c='Credit Card';
		oa.Refund_or_Misc_Amount__c=10;
		oa.Credit_Card_Type__c = 'MasterCard';
		insert oa;
		testDataSetupUtil.oa=oa;
		test.startTest();
		WS_soa_OrderAdjustmentService.OrderAdjustmentResponse resp = WS_OrderAdjustmentUtils.doCallout(oa);
		test.stopTest();
		system.assert(WS_OrderAdjustmentUtils.refundRequest.refundType=='K');
		//system.assert(WS_OrderAdjustmentUtils.refundRequest.creditDetail.transactionReferenceNumber=='XXX123');
		//system.assert(WS_OrderAdjustmentUtils.refundRequest.creditDetail.TokenNumber=='@Y8VFTY@WM3-4113');
		//system.assert([select status__c from Order_Adjustment__c where id=:oa.id].status__c=='Processed');
		//system.assert([select Transaction_Reference_Number__c from Order_Adjustment__c where id=:oa.id].Transaction_Reference_Number__c=='XXX123');
	}

	public static testMethod void test_OA_Refund_Paypal(){
		setupData();
		testDataSetupUtil.order1.Order_Submitted__c=true;
		testDataSetupUtil.order1.Order_Status__c='Submitted';
		testDataSetupUtil.order1.Payment_Type__c='Paypal';
		testDataSetupUtil.order1.Paypal_Authorization_Code__c='ZZZ123';
		update  testDataSetupUtil.order1;
			Order_Adjustment__c oa = new Order_Adjustment__c(related_order__c=testDataSetupUtil.order1.id, customer__c=testDataSetupUtil.acct.id);
		RecordType rt = [select id from RecordType where developerName='Refund' and sobjectType='Order_Adjustment__c'];

		oa.recordTypeId=rt.id;
		oa.Refund_Type__c='Full Refund';
		oa.Payment_Method__c='Paypal';
		oa.Refund_or_Misc_Amount__c=10;
		oa.Related_Order_Paypal_Transaction_ID__c='ZZZ123';
		insert oa;
		testDataSetupUtil.oa=oa;
		test.startTest();
		Test.setMock(WebServiceMock.class, new MockResponse_OrderAdjustmentService ());
		WS_soa_OrderAdjustmentService.OrderAdjustmentResponse resp =WS_OrderAdjustmentUtils.doCallout(oa);
		test.stopTest();
		//system.assert(WS_OrderAdjustmentUtils.refundRequest.paypalDetail.transactionID=='ZZZ123');
		system.assert(WS_OrderAdjustmentUtils.refundRequest.refundType=='Y');
		system.assert([select status__c from Order_Adjustment__c where id=:oa.id].status__c=='Processed');
		system.assert([select PayPal_Reference_ID__c from Order_Adjustment__c where id=:oa.id].PayPal_Reference_ID__c=='ZZZ987');
		
	}

	public static testMethod void test_OA_Refund_Check(){
		setupData();
		testDataSetupUtil.order1.Order_Submitted__c=true;
		testDataSetupUtil.order1.Order_Status__c='Submitted';
		testDataSetupUtil.order1.Payment_Type__c='Check';
		update  testDataSetupUtil.order1;
			Order_Adjustment__c oa = new Order_Adjustment__c(related_order__c=testDataSetupUtil.order1.id, customer__c=testDataSetupUtil.acct.id);
		RecordType rt = [select id from RecordType where developerName='Refund' and sobjectType='Order_Adjustment__c'];

		oa.recordTypeId=rt.id;
		oa.Refund_Type__c='Full Refund';
		oa.Payment_Method__c='Check';
		oa.Refund_or_Misc_Amount__c=10;
		insert oa;
		testDataSetupUtil.oa=oa;
		test.startTest();
		Test.setMock(WebServiceMock.class, new MockResponse_OrderAdjustmentService ());
		WS_soa_OrderAdjustmentService.OrderAdjustmentResponse resp =WS_OrderAdjustmentUtils.doCallout(oa);
		test.stopTest();
		system.assert(WS_OrderAdjustmentUtils.refundRequest.refundType=='C');
		system.assert([select status__c from Order_Adjustment__c where id=:oa.id].status__c=='Processed');
	}

	public static testMethod void test_OA_Debit_Existing(){
		setupData();
			Order_Adjustment__c oa = new Order_Adjustment__c(related_order__c=testDataSetupUtil.order1.id, customer__c=testDataSetupUtil.acct.id);
		RecordType rt = [select id from RecordType where developerName='Misc_Charge' and sobjectType='Order_Adjustment__c'];
		oa.recordTypeId=rt.id;
		oa.Refund_Type__c='Full Refund';
		oa.Payment_Method__c='Existing Card';
		oa.Refund_or_Misc_Amount__c=10;
		oa.credit_card_token__c='@Y8VFTY@WM3-4113';
		insert oa;
		testDataSetupUtil.oa=oa;
		test.startTest();
		Test.setMock(WebServiceMock.class, new MockResponse_OrderAdjustmentService ());
		WS_soa_OrderAdjustmentService.OrderAdjustmentResponse resp =WS_OrderAdjustmentUtils.doCallout(oa);
		test.stopTest();
		system.assert(WS_OrderAdjustmentUtils.refundRequest==NULL);
		//system.assert([select status__c from Order_Adjustment__c where id=:oa.id].status__c=='Processed');
		
	}

	public static testMethod void test_OA_Debit_New(){
		setupData();
		Order_Adjustment__c oa = new Order_Adjustment__c(related_order__c=testDataSetupUtil.order1.id, customer__c=testDataSetupUtil.acct.id);
		RecordType rt = [select id from RecordType where developerName='Misc_Charge' and sobjectType='Order_Adjustment__c'];
		oa.recordTypeId=rt.id;
		oa.Refund_Type__c='Full Refund';
		oa.Payment_Method__c='Credit Card';
		oa.Refund_or_Misc_Amount__c=10;
		oa.Credit_Card_Expiration_Date__c='201504';
		oa.Credit_Card_Type__c='Visa';
		oa.Credit_Card_Name__c='Bob Jones';
		oa.Credit_Card_Number__c='4112344112344113';
		insert oa;
		testDataSetupUtil.oa=oa;
		test.startTest();
		
		Test.setMock(WebServiceMock.class, new MockResponse_OrderAdjustmentService ());
		WS_soa_OrderAdjustmentService.OrderAdjustmentResponse resp =WS_OrderAdjustmentUtils.doCallout(oa);
		test.stopTest();
		system.assert(WS_OrderAdjustmentUtils.refundRequest==NULL);
		//system.assert([select Transaction_Reference_Number__c from Order_Adjustment__c where id=:oa.id].Transaction_Reference_Number__c=='XXX123');
		
	}

}