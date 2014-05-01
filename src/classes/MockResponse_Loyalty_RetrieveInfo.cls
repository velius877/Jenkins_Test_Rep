@isTest
global class MockResponse_Loyalty_RetrieveInfo  implements WebServiceMock {
	
	public static string maketoken(integer tokenLength) {
		string text = '';
		string possible = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
		for( integer i=0; i < tokenLength; i++ ){
			integer loc = integer.valueOf(Math.floor(Math.random() * possible.length()));
			text += possible.substring(loc,loc+1);
		}
		system.debug(text);
		return text;
	} 
	global void doInvoke(Object stub,Object request,Map<String, Object> response,String endpoint,String soapAction,
							String requestName,
							String responseNS,
							String responseName,
							String responseType) {
		
		ws_Soa_Loyalty_RetrieveInfo.retrieveInfoResponse retrieveInfoResponse = new ws_Soa_Loyalty_RetrieveInfo.retrieveInfoResponse();
		ws_Soa_Loyalty_RetrieveInfo.retrieveInfoSuccessResponse successResponse;
		ws_Soa_Loyalty_RetrieveInfo.retrieveInfoFailureResponse  failureResponse;
		// retrieveInfoResponse.customerNumber=CustomerNumber;
		Account  acct = [select id, AS_400_Customer_Number__c,VW_Passport_Number__c from Account where AS_400_Customer_Number__c='987654321' and recordType.developerName ='Vitamin_World_Customer' limit 1 ];
		if (acct!=null){
		//if (string.valueOf(acct.AS_400_Customer_Number__c).substring(string.valueOf(acct.AS_400_Customer_Number__c).length()-1,string.valueOf(acct.AS_400_Customer_Number__c).length())=='1'){
			//failureResponse = new ws_Soa_Loyalty_RetrieveInfo.retrieveInfoFailureResponse ();
		//} else {
				successResponse = new ws_Soa_Loyalty_RetrieveInfo.retrieveInfoSuccessResponse();
				Address__c address = [select Address_Line_1__c, Address_Line_2__c, Address_Line_3__c, Address_Line_4__c,City__c,Zip_Code__c,State_Providence__c, Country_Picklist__c from Address__c where customer__c=:acct.id and primary_bill_to_address__c = true];
			//	retrieveInfoResponse.LoyaltyNumber=acct.VW_Passport_Number__c;
			//	retrieveInfoResponse.passportNumber=integer.valueOf(math.floor(math.random()*100));
				successResponse.BillingInfo = new ws_Soa_Loyalty_RetrieveInfo.billingInfo ();
				successResponse.BillingInfo.AddressLine1=address.Address_Line_1__c;
				successResponse.BillingInfo.AddressLine2=address.Address_Line_2__c;
				successResponse.BillingInfo.AddressLine3=address.Address_Line_3__c;
				successResponse.BillingInfo.AddressLine4=address.Address_Line_4__c;
			//	successResponse.BillingInfo.City=address.City__c;
				successResponse.BillingInfo.Country=address.Country_Picklist__c;
				successResponse.BillingInfo.State=address.State_Providence__c;
				successResponse.BillingInfo.ZipCode=address.Zip_Code__c;
				successResponse.pointsToDate=string.valueOf(math.floor(math.random()*100));
				successResponse.Coupons = new List <ws_Soa_Loyalty_RetrieveInfo.couponDetail >();
				integer randomSize = integer.valueOf(math.floor(math.random()*10));
				
				for (integer k=0; k<randomSize; k++){
					ws_Soa_Loyalty_RetrieveInfo.couponDetail coupon = new ws_Soa_Loyalty_RetrieveInfo.couponDetail();
					boolean randomBool = math.random() > .5?true:false;
					coupon.Amount=string.valueOf(decimal.valueOf(math.random()*10).setScale(2));
					coupon.Code=makeToken(4);
					integer randomNeg = math.random()> .5 ? -1 : 1;
					coupon.ExpirationDate=string.valueOf(system.today().addDays(integer.valueOf(math.floor(randomNeg*math.random()*365))));
					coupon.status = date.valueOf(coupon.ExpirationDate) > system.today() ? (randomBool ?  'active': 'redeemed') : (randomBool ?  'expired': 'redeemed');
					successResponse.Coupons.add(coupon);
				}
		//}
		}
		retrieveInfoResponse.retrieveInfoSuccessResponse=successResponse;
		retrieveInfoResponse.retrieveInfoFailureResponse=failureResponse;
		system.debug('response~~~~'+retrieveInfoResponse);

			

			response.put('response_x', retrieveInfoResponse);
				
		}

}