@isTest
global class MockResponse_OrderAdjustmentService  implements WebServiceMock {
	
	global void doInvoke(Object stub,Object request,Map<String, Object> response,String endpoint,String soapAction,
							String requestName,String responseNS,String responseName,String responseType) {
		
		WS_soa_OrderAdjustmentService.OrderAdjustmentResponse resp;
		Order_Adjustment__c testOA = [select id,name,  Refund_or_Misc_Amount__c,Payment_Method__c, recordType.developerName from Order_Adjustment__c where id =:testDataSetupUtil.oa.id];
		if (testOA.Refund_or_Misc_Amount__c!=0) {
			resp = new WS_soa_OrderAdjustmentService.OrderAdjustmentResponse ();
			resp.OrderAdjustmentSuccess  = new WS_soa_OrderAdjustmentService.OrderAdjustmentSuccess ();
			if (testOA.recordType.developerName == 'Refund' && testOA.Payment_Method__c != 'Credit Card') {
				if (testOA.Payment_Method__c=='Check') { 
					WS_soa_OrderAdjustmentService.CheckSuccess checkSuccess = new WS_soa_OrderAdjustmentService.CheckSuccess();
					checkSuccess.status='Success';
					resp.OrderAdjustmentSuccess.checkSuccess=checkSuccess;
				} else if (testOA.Payment_Method__c == 'Paypal') {
					WS_soa_OrderAdjustmentService.PaypalSuccess ppSuccess = new WS_soa_OrderAdjustmentService.PaypalSuccess();
					ppSuccess.status='Success';
					ppSuccess.refundID='ZZZ987';
					resp.OrderAdjustmentSuccess.PaypalSuccess=ppSuccess;
				}
			} else {
				WS_soa_OrderAdjustmentService.CreditSuccess creditSuccess= new WS_soa_OrderAdjustmentService.CreditSuccess();
				creditSuccess.tokenNumber='@Y8VFTY@WM3-4113';
				creditSuccess.orderID=testOA.name;
				creditSuccess.transactionReferenceNumber='XXX123';
				creditSuccess.transactionReferenceIndex='2';
				creditSuccess.respDateTime='2014-02-20T16:01:57';
				creditSuccess.status='@Y8VFTY@WM3-4113';
				creditSuccess.message='@Y8VFTY@WM3-4113';				
				resp.OrderAdjustmentSuccess.creditSuccess=creditSuccess;
			}
		}
		response.put('response_x', resp);
	}
}