/*
	OrderStatusQuery_Test
	DESCRIPTION
	------------------------------------------------------------------
	Author		|	Date		|	Description
	------------------------------------------------------------------
	Gary Alfrey |	10/14/13	|	Created

*/

@isTest
private class OrderStatusQuery_Test {

	static testMethod void testOSQController() {
		
		Test.setMock(WebServiceMock.class, new MockResponse_OrderStatusQuery());
		TestDataSetupUtil.SetupCoreData(2);
		
		OrderStatusMap__c a1 = new OrderStatusMap__c();
		a1.Name = 'PA';
		a1.Value__c = 4;
		a1.AS400_Status_Description__c = 'IN PROCESS STATUS, DATING IS DONE,ITEM IS AVAILABLE';
		a1.ATG_Order_Status__c = 'INPROGRESS';
		a1.SFDC_Order_Line_Status__c = 'In Progress';
		a1.SFDC_Order_Status__c = 'In Progress';
		insert a1;
		
		OrderStatusMap__c a2 = new OrderStatusMap__c();
		a2.Name = 'PR';
		a2.Value__c = 1;
		a2.AS400_Status_Description__c = 'CC AUTHORIZATION REQUESTED, AUTHORIZATION NOT YET GRANTED';
		a2.ATG_Order_Status__c = 'PENDING MERCHANT ACT';
		a2.SFDC_Order_Line_Status__c = 'Awaiting CC Approval';
		a2.SFDC_Order_Status__c = 'Awaiting CC Approval';
		insert a2;
		
		Orders__c x = TestDataSetupUtil.order1;
		x.Order_Submitted__c = true;
		update x;
		
		test.startTest();
		ApexPages.StandardController controller = new ApexPages.StandardController(TestDataSetupUtil.order1);
		//PageReference pageRef = Page.Order_Detail;
		//Test.setCurrentPage(pageRef);
		OrderStatusQueryController oqs2 = new OrderStatusQueryController(controller);
		OrderStatusQueryController oqs = new OrderStatusQueryController(TestDataSetupUtil.order1.Id);
		oqs.showSnippet = true;
		oqs.init();
		test.stopTest();
		
	}
	
	static testMethod void testFaultWrapper() {
		WS_OrderStatusQuery.OrderStatusFault f = new WS_OrderStatusQuery.OrderStatusFault();
		f.FaultCode = 'TT';
		f.FaultMessage = 'TEST';
		
		OrderStatusQueryController.faultWrapper fw = new OrderStatusQueryController.faultWrapper(f);
		fw.code = 'TT';
		fw.msg = 'TEST';
	}
	
	static testMethod void testProcessOrderPostWarehouse(){
		TestDataSetupUtil.SetupCoreData(2);
		OrderStatusQueryController oqs = new OrderStatusQueryController(TestDataSetupUtil.order1.Id);
		oqs.showCancelOrderPanel = false;
		oqs.processOrderPOSTwarehouseCancel();
		oqs.ProcessAllOrderCancelCancel();
		oqs.ProcessAllOrderCancelSave();
		oqs.init();
		
	}
	
	static testMethod void testProcessOrderPreWarehouse(){
		TestDataSetupUtil.SetupCoreData(2);
		OrderStatusQueryController oqs = new OrderStatusQueryController(TestDataSetupUtil.order1.Id);
		oqs.showCancelOrderPanel = false;
		oqs.processOrderPrewarehouseCancel();
	}
	
	static testMethod void testSetPageMessages(){
		TestDataSetupUtil.SetupCoreData(2);
		OrderStatusQueryController oqs = new OrderStatusQueryController(TestDataSetupUtil.order1.Id);
		oqs.setPageMessages('TEST');
		oqs.setPageMessagesError('TEST');
	}
	
	static testMethod void testOrderStatusQueryBatch(){
		Test.setMock(WebServiceMock.class, new MockResponse_OrderStatusQuery());
		OrderStatusMap__c a1 = new OrderStatusMap__c();
		a1.Name = 'PA';
		a1.Value__c = 4;
		a1.AS400_Status_Description__c = 'IN PROCESS STATUS, DATING IS DONE,ITEM IS AVAILABLE';
		a1.ATG_Order_Status__c = 'INPROGRESS';
		a1.SFDC_Order_Line_Status__c = 'In Progress';
		a1.SFDC_Order_Status__c = 'In Progress';
		insert a1;
		
		OrderStatusMap__c a2 = new OrderStatusMap__c();
		a2.Name = 'PR';
		a2.Value__c = 1;
		a2.AS400_Status_Description__c = 'CC AUTHORIZATION REQUESTED, AUTHORIZATION NOT YET GRANTED';
		a2.ATG_Order_Status__c = 'PENDING MERCHANT ACT';
		a2.SFDC_Order_Line_Status__c = 'Awaiting CC Approval';
		a2.SFDC_Order_Status__c = 'Awaiting CC Approval';
		insert a2;
		
		TestDataSetupUtil.SetupCoreData(2);
		Orders__c x = TestDataSetupUtil.order1;
		x.Order_Submitted__c = true;
		update x;
		
		//OrderStatusQueryBatch osub = new OrderStatusQueryBatch(true);
		//ID myBatchJobID = database.executebatch(osub);
	}
	
	
	
}