@isTest
global class MockResponse_Loyalty_RedeemCoupon  implements WebServiceMock {
		global void doInvoke(Object stub,Object request,Map<String, Object> response,String endpoint,String soapAction,String requestName,String responseNS,String responseName,String responseType) {
			
			ws_Soa_Loyalty_RedeemCoupon.redeemCouponResponse  resp= new ws_Soa_Loyalty_RedeemCoupon.redeemCouponResponse();
			//resp.success='T';
			ws_Soa_Loyalty_RedeemCoupon.RedeemCouponSuccessResponse success = new ws_Soa_Loyalty_RedeemCoupon.RedeemCouponSuccessResponse();
			List<ws_Soa_Loyalty_RedeemCoupon.RedeemCouponStatus> statusList = new List<ws_Soa_Loyalty_RedeemCoupon.RedeemCouponStatus>();
			ws_Soa_Loyalty_RedeemCoupon.RedeemCouponStatus status = new ws_Soa_Loyalty_RedeemCoupon.RedeemCouponStatus();
			status.success = 'T';
			statusList.add(status);
			success.redeemCouponStatus = statusList;
			resp.redeemCouponSuccessResponse = success;
			
			response.put('response_x', resp);
				
		}
}