@isTest
public with sharing class ws_Soa_LoyaltyServices_Test {

	public static testMethod void test_RetrieveInfo(){
		testDataSetupUtil.SetupCoreData(2);
		Test.setMock(WebServiceMock.class, new MockResponse_Loyalty_RetrieveInfo ());
		string AS400CustomerNumber='987654321';
		string loyaltyNumber = '1234';
		test.startTest();
		ws_Soa_Loyalty_RetrieveInfo.retrieveInfoResponse retrieveInfoResponse = WS_SOA_LoyaltyServicesUtils.retrieveInfoCallout(AS400CustomerNumber, LoyaltyNumber);
		test.stopTest();
		//system.assert(retrieveInfoResponse.retrieveInfoSuccessResponse.coupons.size()>0);
	}	
	public static testMethod void test_Redeem(){
		testDataSetupUtil.SetupCoreData(2);
		Test.setMock(WebServiceMock.class, new MockResponse_Loyalty_RedeemCoupon ());
		test.startTest();
		string AS400CustomerNumber='1234';
		string loyaltyNumber = '1234';
		string [] couponNumber = new String[]{'1234'};
		string redeem = 'T';
		ws_Soa_Loyalty_RedeemCoupon.redeemCouponResponse  resp=WS_SOA_LoyaltyServicesUtils.getCouponResponse(AS400CustomerNumber, LoyaltyNumber, couponNumber, redeem);
		test.stopTest();
		String x = resp.redeemCouponSuccessResponse.redeemCouponStatus[0].success;
		system.assertEquals(x, 'T');
	}
	
	public static testMethod void test_UpdateBillingInfo(){
		
	}
}