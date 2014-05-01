/*
	WS_OrderStatusQueryUtils
	DESCRIPTION
	------------------------------------------------------------------
	Author		|	Date		|	Description
	------------------------------------------------------------------
	Gary Alfrey |	4/9/14		|	Created

*/
@isTest
private class WS_SOA_OrderHistory_Test {

	static testMethod void myUnitTest() {
		ws_Soa_OrderHistoryService.promotionsDiscounts pd = new ws_Soa_OrderHistoryService.promotionsDiscounts();
		ws_Soa_OrderHistoryService.payment pay = new ws_Soa_OrderHistoryService.payment();
		ws_Soa_OrderHistoryService.miscellaneousCharges mc = new ws_Soa_OrderHistoryService.miscellaneousCharges();
		ws_Soa_OrderHistoryService.retrieveOrdersHistoryFailure ohf = new ws_Soa_OrderHistoryService.retrieveOrdersHistoryFailure();
		ws_Soa_OrderHistoryService.orderHeader oh = new ws_Soa_OrderHistoryService.orderHeader();
		ws_Soa_OrderHistoryService.payments pays = new ws_Soa_OrderHistoryService.payments();
		ws_Soa_OrderHistoryService.shipTo st = new ws_Soa_OrderHistoryService.shipTo();
	}
}