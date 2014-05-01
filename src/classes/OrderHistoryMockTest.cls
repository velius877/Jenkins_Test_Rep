/*
 * Author       : Pavan Jasti, Acumen
 * Class        : OrderHistoryMockTest 
 * Date         : 03/06/2014
 * Description  : Mock service class for ws_Soa_OrderHistoryService.cls
*/
@isTest
global with sharing class OrderHistoryMockTest implements WebServiceMock {
	global void doInvoke(
           Object stub,
           Object request,
           Map<String, Object> response,
           String endpoint,
           String soapAction,
           String requestName,
           String responseNS,
           String responseName,
           String responseType) {
        
        // Populate response element.
        ws_Soa_OrderHistoryService.retrieveOrdersHistoryResponse responseElement = new ws_Soa_OrderHistoryService.retrieveOrdersHistoryResponse();
        
        list<ws_Soa_OrderHistoryService.orders> orderList = new list<ws_Soa_OrderHistoryService.orders>();
        ws_Soa_OrderHistoryService.orders ord = new ws_Soa_OrderHistoryService.orders();
        ws_Soa_OrderHistoryService.lineItems lineItems = new ws_Soa_OrderHistoryService.lineItems();
        //one order with two line items 
        list<ws_Soa_OrderHistoryService.lineItem> lineItemslist = new list<ws_Soa_OrderHistoryService.lineItem>();
        ws_soa_orderHistoryService.lineItem li1= new ws_soa_orderHistoryService.lineItem();
        li1.enterSku = '009991';
        lineItemslist.add(li1);
        ws_Soa_OrderHistoryService.lineItem li2 = new ws_Soa_OrderHistoryService.lineItem();
        li2.enterSku = '009992';
        lineItemslist.add(li2);
		lineItems.lineItem = lineItemslist;
        ord.lineItems = lineItems;
        orderList.add(ord);  
        responseElement.orders = orderList;
        responseElement.retrieveOrdersHistorySuccess = 'Success';
        responseElement.totalOrderCount = '1';
        response.put('response_x', responseElement); 
   }

}