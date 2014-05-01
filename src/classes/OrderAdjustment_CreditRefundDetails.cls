public with sharing class OrderAdjustment_CreditRefundDetails {

	public static Id OrderAdjustmentId;
	
	
	public static List <Credit_Refund_Detail__c> populateCrdList( ws_Soa_OrderHistoryService.orders ord){
		system.debug('------------------------------------------------start populateCrdList');
		List <Credit_Refund_Detail__c> crdList = new List <Credit_Refund_Detail__c>();
		if (ord.payments != null && ord.payments.payment != null) {
			//List <ws_Soa_OrderHistoryService.payment> paymentList =ord.payments.payment;
			for (ws_Soa_OrderHistoryService.payment pay: ord.payments.payment) {
				Credit_Refund_Detail__c crd = new Credit_Refund_Detail__c(Order_Adjustment__c=OrderAdjustmentId);
				crd.Original_Amount__c=decimal.valueOf(pay.authorizationAmount);
				crd.Original_Transaction_Reference_Number__c = pay.transactionReferenceNumber;
				crd.Unique_Key__c= OrderAdjustmentId+'-'+pay.transactionReferenceNumber+'-'+pay.transactionType;
				crd.Original_Order_Total__c = decimal.valueOf(ord.orderHeader.totalNetPurchaseAmount);
				crd.Credit_Card_Token__c = pay.tokenNumber;
				crd.Credit_Card_Type__c = NBTYUtils.getCCTypeMappings('AS400').get( ord.orderHeader.creditCardType)!=null ? NBTYUtils.getCCTypeMappings('AS400').get( ord.orderHeader.creditCardType).Name: null;
				crd.Status__c = pay.transactionType;
				CRD.Original_Bank_Response_DateTime__c = pay.bankResponseDateTime;
				crdList.add(crd);
			}
		}
		return crdList;
	}
}