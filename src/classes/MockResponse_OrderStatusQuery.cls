/* 
	MockResponse_OrderStatusQuery
	DESCRIPTION
	------------------------------------------------------------------
	Author		|	Date		|	Description
	------------------------------------------------------------------
	Your Name   |	??/??/???	|	Created

*/

@isTest
global class MockResponse_OrderStatusQuery implements WebServiceMock {
	
	global void doInvoke(Object stub, Object request,Map<String, Object> response,String endpoint,String soapAction,String requestName,String responseNS,String responseName,String responseType){
		WS_OrderStatusQuery.OrderStatusQueryResponse_element response_x = new WS_OrderStatusQuery.OrderStatusQueryResponse_element();
		
		WS_OrderStatusQuery.ShippingDetail s = new WS_OrderStatusQuery.ShippingDetail();
		s.NewQuantity = '10';
		s.OriginalQuantity = '10';
		s.Shipper = '';
		s.TrackingNumber = '';
		
		WS_OrderStatusQuery.LineItem a1 = new WS_OrderStatusQuery.LineItem();
		a1.CreditReject = '';
		a1.DispositionNumber = '';
		a1.NewItemStatus = 'PR';
		a1.NewSkuId = '009991';
		a1.OriginalSkuId = '009991';
		a1.ShippingDetail = s;
		
		WS_OrderStatusQuery.LineItem a2 = new WS_OrderStatusQuery.LineItem();
		a2.CreditReject = '';
		a2.DispositionNumber = '';
		a2.NewItemStatus = 'PA';
		a2.NewSkuId = '009990';
		a2.OriginalSkuId = '009990';
		a2.ShippingDetail = s;
		
		List<WS_OrderStatusQuery.LineItem> aList = new List<WS_OrderStatusQuery.LineItem>();
		aList.add(a1);
		aList.add(a2);
		
		WS_OrderStatusQuery.LineItemList lineItemList = new WS_OrderStatusQuery.LineItemList();
		lineItemList.LineItem = aList;
		
		Orders__c ord = [SELECT Id, Name FROM Orders__c WHERE Id = :TestDataSetupUtil.order1.Id];
		
		WS_OrderStatusQuery.OrderStatusSuccess successResp = new WS_OrderStatusQuery.OrderStatusSuccess();
		successResp.OrderStatus = 'PA';
		successResp.OrderStatusDetail = 'In Progress';
		successResp.SFOrderNumber = ord.Name;
		successResp.WebOrderNumber = '';
		successResp.LineItemList = lineItemList;
		
		response_x.OrderStatusSuccess = successResp;
		
		response.put('response_x', response_x);
	}
}