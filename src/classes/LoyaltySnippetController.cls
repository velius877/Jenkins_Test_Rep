/* 
	LoyaltySnippetController
	DESCRIPTION
	------------------------------------------------------------------
	Author		|	Date		|	Description
	------------------------------------------------------------------
	Gary Alfrey |	2/17/14 	|	Created

*/

public class LoyaltySnippetController {
	
	private Account acct;
	public ws_Soa_Loyalty_RetrieveInfo.retrieveInfoResponse response {get;set;}
	public List<couponWrapper> coupons {get;set;}
	//public ws_Soa_Loyalty_RetrieveInfo.billingInfo billingInfo {get;set;}
	public String msg {get;set;}
	public String currPoints {get;set;}
	public String formattedAddressLine1 {get;set;}
	public String formattedAddressLine2 {get;set;}
	public String formattedAddressLine3 {get;set;}
	public Boolean showLoyalty {get;set;}
	public Boolean showAdditionalLines {get;set;}
	
	
	public class couponWrapper{
		public ws_Soa_Loyalty_RetrieveInfo.couponDetail cpnDetail {get;set;} 
		public date expDate {get;set;}
		public couponWrapper(ws_Soa_Loyalty_RetrieveInfo.couponDetail cpn){
			cpnDetail = cpn ;
			system.debug('expDate~~~'+cpn.expirationDate);
			try {
				expDate = date.newInstance(integer.valueOf('20'+cpn.expirationDate.substring(0,2)), integer.valueOf(cpn.expirationDate.substring(2,4)),integer.valueOf(cpn.expirationDate.substring(4,6)));
			}
			catch (exception e){
				system.debug('cannot parse expiration date~~~'+cpn.expirationDate);
			}
		}
	}
	
	public LoyaltySnippetController(ApexPages.StandardController stdCont) {
		showAdditionalLines = false;
		Id aId = stdCont.getId();
		acct = [SELECT Id, Name, As_400_Customer_Number__c, VW_Passport_Number__c, RecordType.DeveloperName, PersonEmail FROM Account Where Id = :aId];
		if (acct.RecordType.DeveloperName == 'Vitamin_World_Customer') {
			showLoyalty=true;
		} 
	}
	
	public void makeCallout(){
		makeCallout(acct.As_400_Customer_Number__c, acct.VW_Passport_Number__c);
	}
	
	public void makeCallout(String customerNum, String loyalty){
		response = init(customerNum, loyalty);
	}
	
	public ws_Soa_Loyalty_RetrieveInfo.retrieveInfoResponse init(String customerNum, String loyalty) {
		if (acct.RecordType.DeveloperName == 'Vitamin_World_Customer') {
			// go ahead and do the callout
			response = WS_SOA_LoyaltyServicesUtils.retrieveInfoCallout(customerNum, loyalty);
			system.debug('-------------------------------------response: ' + response);
			if (response.retrieveInfoSuccessResponse != null) {
				currPoints = response.retrieveInfoSuccessResponse.pointsToDate;
				coupons = new List <couponWrapper>();
				for (ws_Soa_Loyalty_RetrieveInfo.couponDetail  cpn: response.retrieveInfoSuccessResponse.coupons){
					if (cpn.status == 'E' || string.isBlank(cpn.status)) {
						coupons.add(new CouponWrapper(cpn));
					}
				}
				for (ws_Soa_Loyalty_RetrieveInfo.couponDetail  cpn: response.retrieveInfoSuccessResponse.coupons){
					if (cpn.status == 'A') {
						coupons.add(new CouponWrapper(cpn));
					}
				}
				for (ws_Soa_Loyalty_RetrieveInfo.couponDetail  cpn: response.retrieveInfoSuccessResponse.coupons){
					if (cpn.status == 'R') {
						coupons.add(new CouponWrapper(cpn));
					}
				}
				
				formattedAddressLine1 = response.retrieveInfoSuccessResponse.billingInfo.addressLine1;
				if (response.retrieveInfoSuccessResponse.billingInfo.addressLine2 != null) {
					formattedAddressLine1 += ' ' + response.retrieveInfoSuccessResponse.billingInfo.addressLine2;
				}
				 
				if (response.retrieveInfoSuccessResponse.billingInfo.addressLine3 != null) {
					formattedAddressLine2 = response.retrieveInfoSuccessResponse.billingInfo.addressLine3;
					showAdditionalLines = true;
				}
				
				if (response.retrieveInfoSuccessResponse.billingInfo.addressLine4 != null){
					formattedAddressLine2 += ', ' + response.retrieveInfoSuccessResponse.billingInfo.addressLine4;
				}
				
				if (response.retrieveInfoSuccessResponse.billingInfo.state != null) {
					formattedAddressLine3 = response.retrieveInfoSuccessResponse.billingInfo.state + ', ' + response.retrieveInfoSuccessResponse.billingInfo.country;
				} else {
					formattedAddressLine3 = response.retrieveInfoSuccessResponse.billingInfo.province + ', ' + response.retrieveInfoSuccessResponse.billingInfo.country;
				}
				
				showLoyalty = true;
			} else if (response.retrieveInfoFailureResponse != null) {
				showLoyalty = false;
				msg = response.retrieveInfoFailureResponse.detailMsg;
			} else {
				showLoyalty = false;
				msg = 'An unknown error was encountered';
			}
		} else {
			//set some message to display
			msg = 'Only Available for Vitamin World Customers';
		}
		return WS_SOA_LoyaltyServicesUtils.retrieveInfoCallout(customerNum, loyalty);
	}
	
	
}