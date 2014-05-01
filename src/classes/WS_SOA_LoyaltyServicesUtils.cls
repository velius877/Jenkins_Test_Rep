/* 
	WS_SOA_LoyaltyServicesUtils
	DESCRIPTION
	------------------------------------------------------------------
	Author		|	Date		|	Description
	------------------------------------------------------------------
	Gary Alfrey |	2/17/14 	|	Created

*/

public class WS_SOA_LoyaltyServicesUtils {
	
	public static final String VW_CUST = 'Vitamin_World_Customer';
	
/*****************************************************Retrieve info Methods Start******************************************************************************************************/
	public static ws_Soa_Loyalty_RetrieveInfo.retrieveInfoResponse retrieveInfoCallout(String AS400CustomerNumber, String LoyaltyNumber) {
		try {
			ws_Soa_Loyalty_RetrieveInfo.retrieveInfoResponse response = WS_SOA_LoyaltyServicesUtils.getInfoResponse(AS400CustomerNumber, LoyaltyNumber);
			return response;
		} catch (Exception e) {
			
			return null;
		}
	}
	
	public static ws_Soa_Loyalty_RetrieveInfo.retrieveInfoResponse getInfoResponse(String AS400CustomerNumber, String LoyaltyNumber) {
		ws_Soa_LoyaltyServices.LoyaltyServiceSOAP loyaltySOAP = new ws_Soa_LoyaltyServices.LoyaltyServiceSOAP();
		return loyaltySOAP.LoyaltyRetrieveInfo(AS400CustomerNumber, LoyaltyNumber, null, null, null, null, null, null, null, null, null, null);
	}
/*****************************************************Retrieve info Methods End******************************************************************************************************/

/*****************************************************RedeemCoupon Methods Start******************************************************************************************************/
	public static ws_Soa_Loyalty_RedeemCoupon.redeemCouponResponse redeemCouponCallout(String AS400CustomerNumber, String LoyaltyNumber, list<String> couponNumber, String redeem) {
		try {
			ws_Soa_Loyalty_RedeemCoupon.redeemCouponResponse response = WS_SOA_LoyaltyServicesUtils.getCouponResponse(AS400CustomerNumber, LoyaltyNumber, couponNumber, redeem);
			return response;
		} catch (Exception e) {
			
			return null;
		}
	}
	
	public static ws_Soa_Loyalty_RedeemCoupon.redeemCouponResponse getCouponResponse(String AS400CustomerNumber, String LoyaltyNumber, list<String> couponNumber, String redeem) {
		ws_Soa_LoyaltyServices.LoyaltyServiceSOAP loyaltySOAP = new ws_Soa_LoyaltyServices.LoyaltyServiceSOAP();
		return loyaltySOAP.LoyaltyRedeemCoupon(AS400CustomerNumber, LoyaltyNumber, couponNumber, redeem, null, null, null, null, null, null, null, null, null, null);
	}
	
	public static List<String> getCouponList(List<Allowance__c> allow) {
		List<String> coupon = new List<String>();
		coupon.add(allow[0].VW_Loyalty_Coupon_Code__c);
		return coupon;
	}
	
	public static List<Allowance__c> queryAllowance(Set<Id> allowIds) {
		List<Allowance__c> aList = [SELECT Id, VW_Loyalty_Coupon_Code__c, Redeemed__c, Order__c, Order__r.Customer__r.AS_400_Customer_Number__c, 
									Order__r.Customer__r.VW_Passport_Number__c FROM Allowance__c WHERE Id IN :allowIds];
		return aList;
	}
	
	public static void redeemVWCoupon(Id orderId) {
		Orders__c ord = [SELECT Id, Customer__r.RecordType.DeveloperName, Customer__r.AS_400_Customer_Number__c, Customer__r.VW_Passport_Number__c 
							FROM Orders__c WHERE Id = :orderId];
		if (ord.Customer__r.RecordType.DeveloperName == VW_CUST) {
			List<Allowance__c> allowList = [SELECT Id, Allowance_Code__c, VW_Loyalty_Coupon_Code__c, Order__c, Redeemed__c FROM Allowance__c 
											WHERE Order__c = :orderId];
			List<String> coupons = new List<String>();
			ws_Soa_Loyalty_RedeemCoupon.redeemCouponResponse resp = new ws_Soa_Loyalty_RedeemCoupon.redeemCouponResponse();
			Allowance__c allow;
			for (Allowance__c al : allowList) {
				system.debug('------------------------------------------------AL: ' + al);
				if (String.isNotBlank(al.VW_Loyalty_Coupon_Code__c) && !al.Redeemed__c) {
					system.debug('------------------------------------------------Inside loop1');
					coupons.add(al.VW_Loyalty_Coupon_Code__c);
					allow = new Allowance__c();
					allow = al;
				}
			}
			if (allow != null) {
				resp = WS_SOA_LoyaltyServicesUtils.redeemCouponCallout(ord.Customer__r.AS_400_Customer_Number__c, ord.Customer__r.VW_Passport_Number__c, coupons, 'T');
				system.debug('------------------------------------------------Redeem resp: ' + resp);
				if (resp.redeemCouponSuccessResponse != null) {
					allow.Redeemed__c = true;
					update allow;
				}
			}
		}
	}
	
	@future(callout=true) //future method for unredeeming coupons on order cancel only
	public static void futureUnRedeem(Set<Id> orderIds, Set<Id> allowanceIds) {
		system.debug('---------------------- start future method');
		List<Orders__c> ordList = [SELECT Id, Customer__r.AS_400_Customer_Number__c, Customer__r.VW_Passport_Number__c FROM Orders__c WHERE Id IN :orderIds LIMIT 1];
		List<Allowance__c> allowList = [SELECT Id, Allowance_Code__c, VW_Loyalty_Coupon_Code__c, Order__c, Redeemed__c FROM Allowance__c WHERE Id IN :allowanceIds LIMIT 1];
		system.debug('---------------------------------------------ordList: ' + ordList);
		system.debug('---------------------------------------------allowList: ' + allowList);
		List<String> coupons = new List<String>{allowList[0].VW_Loyalty_Coupon_Code__c};
		ws_Soa_Loyalty_RedeemCoupon.redeemCouponResponse resp = new ws_Soa_Loyalty_RedeemCoupon.redeemCouponResponse();
		resp = WS_SOA_LoyaltyServicesUtils.redeemCouponCallout(ordList[0].Customer__r.AS_400_Customer_Number__c, ordList[0].Customer__r.VW_Passport_Number__c, coupons, 'F');
		system.debug('------------------------------------------------unRedeem resp: ' + resp);
		if (resp.redeemCouponSuccessResponse != null) {
			allowList[0].Redeemed__c = false;
			update allowList[0];
		}
	}
	
/*****************************************************RedeemCoupon Methods End******************************************************************************************************/

/*****************************************************Update Billing Info Methods Start******************************************************************************************************/
	public static ws_Soa_Loyalty_UpdateBillingInfo.updateBillingInformationResponse updateBillInfoCallout(String AS400CustomerNumber, String LoyaltyNumber, String addLine1, String addLine2, String addLine3, String addLine4, String country, String state, String province, String zip) {
		try {
			ws_Soa_Loyalty_UpdateBillingInfo.billingInfo billTo = new ws_Soa_Loyalty_UpdateBillingInfo.billingInfo();
			billTo.addressLine1 = addLine1;
			billTo.addressLine2 = addLine2;
			billTo.addressLine3 = addLine3;
			billTo.addressLine4 = addLine4;
			billTo.country = country;
			billTo.province = province;
			billTo.state = state;
			billTo.zipCode = zip;
			ws_Soa_Loyalty_UpdateBillingInfo.updateBillingInformationResponse response = WS_SOA_LoyaltyServicesUtils.getUpdateResponse(AS400CustomerNumber, LoyaltyNumber, billTo);
			return response;
		} catch (Exception e) {
			
			return null;
		}
	}
	
	public static ws_Soa_Loyalty_UpdateBillingInfo.updateBillingInformationResponse getUpdateResponse(String AS400CustomerNumber, String LoyaltyNumber, ws_Soa_Loyalty_UpdateBillingInfo.billingInfo billTo) {
		ws_Soa_LoyaltyServices.LoyaltyServiceSOAP loyaltySOAP = new ws_Soa_LoyaltyServices.LoyaltyServiceSOAP();
		return loyaltySOAP.LoyaltyUpdateBillinInformation(AS400CustomerNumber, LoyaltyNumber, billTo, null, null, null, null, null, null, null, null, null, null);
	}
/*****************************************************Update Billing Info Methods End******************************************************************************************************/
	
}