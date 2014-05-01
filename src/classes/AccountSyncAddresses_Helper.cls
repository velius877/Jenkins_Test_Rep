public with sharing class AccountSyncAddresses_Helper {

	public static boolean bAddressBatch = false; 
	public static Address__c generateAddressRecord(Account a, boolean isShipping, boolean isBilling, boolean isPrimary){
		Address__c newAddress = new Address__c(Customer__c=a.id, Active__c=true);
		if (isShipping&&isBilling){
			 newAddress.Address_Type__c='Shipping; Billing';
		}
		else if (isShipping){
			newAddress.Address_Type__c='Shipping'; 
		}
		else {
			newAddress.Address_Type__c='Billing';
		}
		if(isShipping){
			 if (isPrimary) newAddress.Primary_Ship_to_Address__c=true;
			 newAddress.Address_Line_1__c=a.shippingStreet;
			newAddress.City__c=a.shippingCity;
			newAddress.Country__c=a.shippingCountry;
			newAddress.State_Providence__c=a.shippingState;
			newAddress.Zip_Code__c=a.shippingPostalCode;
		}
		if (isBilling){
			 if (isPrimary) newAddress.Primary_Bill_to_Address__c=true;
			newAddress.Address_Line_1__c=a.BillingStreet;
			newAddress.City__c=a.BillingCity;
			newAddress.Country__c=a.BillingCountry;
			newAddress.State_Providence__c=a.BillingState;
			newAddress.Zip_Code__c=a.BillingPostalCode;
		}
		return newAddress;
	}
}