/* 
	AuthDownTimeTest
	DESCRIPTION
	------------------------------------------------------------------
	Author		|	Date		|	Description
	------------------------------------------------------------------
	Your Name   |	??/??/???	|	Created

*/

@isTest
public class AuthDownTimeTest {
	public static WS_soa_AuthorizePaymentService.PaymentInfo testpayinfo;
	
	public static void setupPaymentsResponse(){
		testpayinfo = new WS_soa_AuthorizePaymentService.PaymentInfo();
		testpayinfo.orderId = '123456789';
		testpayinfo.amount = 100.00;
		testpayinfo.creditCardNumber = '341134113411347';
		testpayinfo.creditCardType =WS_soa_AuthorizePaymentService.getCreditCardTypeId('American Express');
		testpayinfo.expiryYYYYMM = '201512';
		testpayinfo.nameOnCard = 'Test Test';
		testpayinfo.addressLine1 = '123 Main Street';
		testpayinfo.addressLine2 = 'Test Block';
		testpayinfo.city = 'Test City';
		testpayinfo.state = 'TS';
		testpayinfo.countryCode = 'USA';
	}
	
	static testMethod void testAuthDownTimeUtils(){
		testDataSetupUtil.SetupCoreData(2);
		setupPaymentsResponse();
		
		PageReference  p = Page.OrderWizard;
		Test.setCurrentPage(p);
		Test.setMock(WebserviceMock.class, new MockControllerCallout());
		test.startTest();
		ApexPages.currentPage().getParameters().put('Id', testDataSetupUtil.order1.id);
		ApexPages.StandardController sc = new ApexPages.StandardController(testDataSetupUtil.order1);
		OrderWizard_NewOrder orderController = new OrderWizard_NewOrder(sc);
		orderController.Checkout();
		orderController.wrap.selectedpaymentType = 'Credit Card';
		orderController.wrap.paymentInfo=testpayinfo;
		orderController.wrap.selectedccType='American Express';
		orderController.wrap.paymentInfo.creditCardNumber='123';
		orderController.wrap.newOrder.Replay_Existing_CC__c = false;
		WS_Integration__c authService = new WS_Integration__c();
		authService.Value__c = 'False';
		authService.Name = 'AuthServiceAvailable';
		insert authService;
		AuthDownTimeUtils.setOrderReAuth(orderController.wrap, '');
		
	}
	
	static testMethod void testAuthDownTimeUtils2(){
		testDataSetupUtil.SetupCoreData(2);
		Orders__c si = AuthDownTimeUtils.queryOrder(testDataSetupUtil.order1.id);
	}
	
	static testMethod void testManualDownTime(){
		testDataSetupUtil.SetupCoreData(2);
		testDataSetupUtil.order1.Order_Status__c = 'Awaiting Authorization';
		update testDataSetupUtil.order1;
		WS_Integration__c wsi = new WS_Integration__c();
		wsi.Name = 'AuthServiceAvailable';
		wsi.Value__c = 'True';
		insert wsi;
		test.startTest();
		ManualDownTimeController mdtc = new ManualDownTimeController();
		mdtc.refresh();
		mdtc.downTimeStart = Datetime.now().addDays(1);
		mdtc.downTimeEnd = Datetime.now().addDays(2);
		mdtc.replayStart = Datetime.now().addDays(3);
		mdtc.changeStatus();
		mdtc.changeStatus();
		mdtc.setDownTime();
		mdtc.scheduleSysDownTime();
		mdtc.doCancel();
		mdtc.setReplay();
		mdtc.scheduleReplay();
		test.stopTest();
	}
	
	static testMethod void testReplayBatch(){
		
	}
	
	
	
	
	
	
	
}