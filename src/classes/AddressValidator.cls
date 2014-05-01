/********************************************************************************
 ********************************************************************************	
 *	Class			: AddressValidator
 *	Author			: Acumen Solutions: Latha Davuluri
 *	Version History	: 
 *	Creation		 : 04/09/13
 *	Description		: Class uses the Future method to validate Address records Inserted/Updated against Avalara Address Service.
 *						
 ********************************************************************************
 * Acumen Solutions: Latha Davuluri		05/20/2013		- Modified makeCallOut() method to validate single/list of Address(es).													
 ********************************************************************************/

global class AddressValidator {
	
	public static boolean Pending_Avalara_Response = false;
	public static string StandardizedAddr = null;
	public static boolean addressValidated = true;
	
	@future(callout=true)
	public static void addressToValidate_Future(Set<Id> adrIds){
		 if (Test.isRunningTest()){
			List<Address__c> adrList = [Select Id, Customer__c,Validated__c, Address_Line_1__c,Address_Line_2__c,Address_Line_3__c,City__c,State_Providence__c,Country__c,Zip_Code__c,Pending_Avalara_Response__c	From Address__c Where Id in :adrIds]; 
				//update adrList;
		 }
		 else{
			addressToValidate(adrIds);
		 }
	}
		
	public static void addressToValidate(Set<Id> adrIds){
		 if (Test.isRunningTest()){
			List<Address__c> adrList = [Select Id, Customer__c,Validated__c, Address_Line_1__c,Address_Line_2__c,Address_Line_3__c,City__c,State_Providence__c,Country__c,Zip_Code__c,Pending_Avalara_Response__c	From Address__c Where Id in :adrIds]; 
				update adrList;
		 }
		 else{
		 	 List<Address__c> adrToUpd = new List<Address__c>();
			
			 Set <Id> chunkedIdsSet = new Set <Id>();
			 for (Id addrId: adrIds){ 
				 chunkedIdsSet.add(addrId);
				 List<Address__c> addrUpdList = new List<Address__c>();
				 if (chunkedIdsSet.size()==10)	{
						 addrUpdList = makeCallOut(chunkedIdsSet);
						 for(Address__c adr : addrUpdList){
						 	adrToUpd.add(adr);
						 }
						 chunkedIdsSet.clear();
				 }
				}
				if (!chunkedIdsSet.isEmpty()){
					 List<Address__c> addrUpdList = new List<Address__c>();
					 addrUpdList = makeCallOut(chunkedIdsSet);
					 for(Address__c adr : addrUpdList){
						adrToUpd.add(adr);
					 }
				}	
							
				try{
				 if(Pending_Avalara_Response){
					if (adrToUpd != null && adrToUpd.size()>0 ){
						update adrToUpd;
					 }
					Pending_Avalara_Response = false;
					}
				}
				catch(Exception ex){
					System.debug('**NBTY Error standardizing the address :'+ex.getMessage());
				}
		 }
		}
		
		public static List<Address__c> makeCallOut(Set<ID> adrIds){
				if(!adrIds.isEmpty()){
					List<Address__c> adrList = [Select Id, Customer__c,Validated__c, Address_Line_1__c,Address_Line_2__c,Address_Line_3__c,City__c,State_Providence__c,Country__c,Zip_Code__c,Pending_Avalara_Response__c	From Address__c Where Id in :adrIds]; 
				List<Address__c> adrToUpd = new List<Address__c>();
				 
				for(Address__c addrVal : adrList){
					Address__c addr = validateAddress(addrVal);	
					Pending_Avalara_Response = true;
					adrToUpd.add(addr);
				}// end of for
				return adrToUpd; 
				}
				return null;		
		}
		
		public static Address__c validateAddress(Address__c addrVal){
			if (addrVal != null){
				AddressSvc.AddressSvcSoap addressSvc = new AddressSvc.AddressSvcSoap(WS_Integration__c.getValues('AvaTaxEndPoint').value__C);
			addressSvc.Security = NBTYAddressService.setupSecurity();
			addressSvc.Profile.Client = 'SFDemo,1,0'; 
			 
			AddressSvc.ValidateResult vres = null;
			String SampleResult;
			String PostalCode;
			String StdAddr;
			List<String> Zipcode;
				AddressSvc.ValidateRequest vreq = new AddressSvc.ValidateRequest();
				
			vreq.Address = new AddressSvc.BaseAddress();
				
			vreq.Address.Line1 = addrVal.Address_Line_1__c;
			vreq.Address.Line2 = addrVal.Address_Line_2__c;
			vreq.Address.Line3 = addrVal.Address_Line_3__c;
			vreq.Address.City = addrVal.City__c;
			vreq.Address.Country = addrVal.Country__c;
			vreq.Address.Region = addrVal.State_Providence__c;
			vreq.Address.PostalCode = addrVal.Zip_Code__c;
				 
			try{
				if(vreq != null)	vres=addressSvc.Validate(vreq);
			}
			catch(Exception ex) {
				SampleResult = 'Address Validation Excepted: ' + ex.getmessage();
			}
	
			if(vres.ResultCode == 'Success'){
				SampleResult = 'Address Validation Returned Success - Standardized Address Appears below';
					 
				addrVal.Address_Line_1__c = vres.ValidAddresses.ValidAddress[0].Line1;
				addrVal.Address_Line_2__c = vres.ValidAddresses.ValidAddress[0].Line2;
				addrVal.Address_Line_3__c = vres.ValidAddresses.ValidAddress[0].Line3;
				addrVal.City__c = vres.ValidAddresses.ValidAddress[0].City;
				addrVal.State_Providence__c = vres.ValidAddresses.ValidAddress[0].Region;
				PostalCode = vres.ValidAddresses.ValidAddress[0].PostalCode;
				if (PostalCode.contains('-')){
					Zipcode = PostalCode.trim().split('-');
					addrVal.Zip_Code__c = Zipcode[0];
					addrVal.Zip_Code_4__c = Zipcode[1];
				}
				else{
					addrVal.Zip_Code__c = vres.ValidAddresses.ValidAddress[0].PostalCode;
				}
				addrVal.Country__c = vres.ValidAddresses.ValidAddress[0].Country; 
				addrVal.Validated__c = true;
				addrVal.Validation_Error_Reason__c = null;
				addrVal.Pending_Avalara_Response__c = false;
			}
			else {
				SampleResult = 'Address Validation Returned Other Than Success: ' + vres.ResultCode + 
				' : ' + vres.Messages.Message[0].Name + ' : ' + vres.Messages.Message[0].Summary;
				system.debug(LoggingLevel.info, SampleResult);
				addrVal.Validated__c = false;
				addrVal.Validation_Error_Reason__c = vres.Messages.Message[0].Summary;
			 }
			return addrVal;
			}
			return null; 
		}
	
}