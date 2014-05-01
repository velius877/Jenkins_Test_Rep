public with sharing class NBTYAddressService {

  public NBTYAddressService(){}
  
  public static AddressSvc.Security setupSecurity(){
	AddressSvc.AddressSvcSoap addSvc = new AddressSvc.AddressSvcSoap(WS_Integration__c.getValues('AvaTaxEndPoint').value__C);
	addSvc.Security = new AddressSvc.Security();
	addSvc.Security.UsernameToken.Username = WS_Integration__c.getValues('AvaTaxUserID').value__C;
	addSvc.Security.UsernameToken.Password =  WS_Integration__c.getValues('AvaTaxPassword').value__C;
	return addSvc.Security ;
   } 
}