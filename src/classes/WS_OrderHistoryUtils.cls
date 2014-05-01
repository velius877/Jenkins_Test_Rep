/* 
 *  Class           : WS_OrderHistoryUtils 
 *  Author          : Pavan Jasthi - Acumen Solutions
 *  Creation         : 02/26/2014
 *  Description     : Utils for order history webservice.
 *                      
*/

public with sharing class WS_OrderHistoryUtils {
	
	public static ws_Soa_OrderHistoryService.retrieveOrdersHistoryResponse doCallout(String as400CustomerNumber,String email,string sku, String minOrderSequence,String maxOrderSequence)													
	{
		ws_Soa_OrderHistoryService.OrderHistoryServiceSOAP ordHservice = new ws_Soa_OrderHistoryService.OrderHistoryServiceSOAP();
		ws_Soa_OrderHistoryService.customers customers= new ws_Soa_OrderHistoryService.customers();
		if (as400CustomerNumber!=null){
			ws_Soa_OrderHistoryService.customer customer= new ws_Soa_OrderHistoryService.customer();
			customer.customerNumber=as400CustomerNumber;
			customers.customer = new List <ws_Soa_OrderHistoryService.customer>();
			customers.customer.add(customer);
		}
		else {
			customers.email=email;
		}
		ws_Soa_OrderHistoryService.retrieveOrdersHistoryResponse ordHres = ordHservice.RetrieveOrdersHistory(customers,sku, minOrderSequence,maxOrderSequence,null,null,null,null,null,null,null,null,null,null);
		return ordHres;
	}
}