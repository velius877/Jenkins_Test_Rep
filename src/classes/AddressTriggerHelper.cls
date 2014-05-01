/************************************* MODIFICATION LOG ********************************************************************************
*
* DESCRIPTION : Address Trigger Helper class to validate Inserted/Updated/Deleted Address records
*
*---------------------------------------------------------------------------------------------------------------------------------------
* DEVELOPER								 DATE				  REASON
*---------------------------------------------------------------------------------------------------------------------------------------
* Acumen Solutions: Latha Davuluri		  04/02/2013		  - Origininal Version
* Acumen Solutions: Shivkant Vadlamani	  04/15/2013		  - Mapping Residential/Commercial Values on Address
* Acumen Solutions: Caleb Poitevien	  07/09/2013		  - Refactor													  
*
*/

public with sharing class AddressTriggerHelper {
	
	//check for primary billing/shipping flags
	public static boolean primaryFlags = true; 
		
	// When (USAddress or country = null) and validateAddress = true, then callout made to Avalara address validation service
	public static boolean validateAddress = false; 
		
	// standardized address = Customer ID + Address Line 1 + Address Line 2 ..+ City + State + Country + Postal Code
	private static string stdAddr;
	public static boolean dupCheck = false;
 
 
	public static void addressBeforeInsertTrigger (List<Address__c> triggerNew){
	 	
	 	//Before Insert checks the primaries and sets the R/C; thats all
		set<String> acctIds = new set<String>();
		Map<Id,Account> updAccountMap = new Map<Id,Account>();
		Map<Id, List<Address__c>> addrMap = new Map<Id, List<Address__c>>();
					
		//Set primary flags for new records		
		for(Address__c primAddr : triggerNew){
			acctIds.add(primAddr.customer__c);
		}
		
		for (Account acct: [select id, (select id from Addresses__r) from Account where id in:acctIds]){
			addrMap.put(acct.id, acct.Addresses__r);
		}
				  
		for (Address__c primAddr: triggerNew){
			
			addrClean(primAddr);
			
			if (addrMap.get(primAddr.customer__c).isEmpty() && !updAccountMap.containsKey(primAddr.customer__c)){
				primAddr.Address_Type__c = 'Billing;Shipping';
				primAddr.Primary_Bill_To_Address__c=true;
				primAddr.Primary_Ship_To_Address__c=true;
				updAccountMap.put(primAddr.customer__c,cascadePrimaryToAccount(primAddr,true,true));
		  	}
			
			if (primAddr.Validation_Override__c) 
				{	primAddr.Pending_Avalara_Response__c = false;	}
			else if (!isUSAddress(primAddr.Country__c) && !String.isempty(primAddr.Country__c)){
				primAddr.International_Address__c= true;
				primAddr.Validated__c = false;
				primAddr.Validation_Error_Reason__c = null;
				primAddr.Pending_Avalara_Response__c = false;
			}
		}
		
		if (!updAccountMap.isEmpty())
			{	
				update updAccountMap.values();	
			}
		AddressTriggerHelper.checkIntlAddressAllowed(triggerNew,null);
	}
 
 
	public static void addressAfterInsertTrigger(List<Address__c> triggerNew){ 
		
		//After insert will kick off the validation for US addresses; thats it
		set<Id> adrToVal = new set<Id>();
		set <Id> primAddressSet = new Set <Id>();
		List <Address__c> checkDupAdr = new List<Address__c>();
		Map<Id, Account> acctMap = new Map <Id, Account>();
	 	Map<Id, List<Address__c>> addrMap = new Map<Id, List<Address__c>>();
	  	Map<Id,Address__c> updAddressMap = new Map<Id,Address__c>();
	  	Map<Id,Account>	updAccountMap = new Map<Id,Account>();
		
		for(Address__c nwAddr : triggerNew){
			if (!nwAddr.Validation_Override__c && (isUSAddress(nwAddr.Country__c) || String.isempty(nwAddr.Country__c)) && !nwAddr.Validated__c)
				{	adrToVal.add(nwAddr.Id);	}
			
			//collect addresses to check for dups for intl
			else if(!dupCheck) {	checkDupAdr.add(nwAddr);	}
			if (nwAddr.Primary_Bill_To_Address__c||nwAddr.Primary_Ship_To_Address__c){  //If primaries
				primAddressSet.add(nwAddr.customer__c);
			}
		}
		
		if (!adrToVal.isEmpty()&&!system.isBatch()&&!system.isFuture())
			{	callAddressValidate(adrToVal, true);	}
		
		//run check for dup addresses
		if (!checkDupAdr.isEmpty())
			{	checkForDupAddresses(checkDupAdr); 	}
			
		if (!primAddressSet.isEmpty()){
			for (Account acct:[ SELECT Id, ( Select Id, Primary_Ship_To_Address__c,  Primary_Bill_To_Address__c From Addresses__r) 
												FROM Account where Id IN : primAddressSet]){
				acctMap.put(acct.id, acct);
				addrMap.put(acct.id, acct.Addresses__r);													
				}
				
				for (Address__c pAddr : triggerNew){
				
					for (Address__c addr:addrMap.get(pAddr.customer__c)){
						if (addr.Id != pAddr.Id && transferPrimaryFlags(pAddr,addr)){
							updAddressMap.put(addr.Id,addr);
							}
				 	}
				 	boolean isBilling =false;
				 	boolean isShipping = false;
					if (pAddr.Primary_Bill_To_Address__c)	{	isBilling =true;	}
					if (pAddr.Primary_Ship_to_Address__c)	{	isShipping=true;	}
					updAccountMap.put(pAddr.customer__c,cascadePrimaryToAccount(pAddr,isBilling,isShipping));
				}
					if (!updAddressMap.isEmpty()){ 
				primaryFlags=false;
				update updAddressMap.values();
				primaryFlags=true;
		 	}
		  	if (!updAccountMap.isEmpty()) 
		  		{	update updAccountMap.values();	}	
		}
	}
 
	
	public static void addressBeforeUpdateTrigger(Map<Id,Address__c> triggerOldMap, Map<Id,Address__c> triggerNewMap){
		
		//Before Update sets R/Cs, but also can validate the addresses too
		set<Id> addrIds = new set<Id>();
				 
		for (Address__c primAddr: triggerNewMap.values()){
			addrClean(primAddr);
			
			if (primAddr.Validation_Override__c && !triggerOldMap.get(primAddr.id).Validation_Override__c){
				primAddr.Pending_Avalara_Response__c = false;
				primAddr.Validated__c = false;
				primAddr.Validation_Error_Reason__c = null;
			}
			
			if ( isUSAddress( primAddr.Country__c ) || String.isEmpty( primAddr.Country__c )){
				primAddr.International_Address__c= false;
					validateAddress = true;
					
					if(triggerOldMap != null){
					validatePrimaryFlags(primAddr, triggerOldMap.get(primAddr.id));  //Its an update so 
					validateAddress = checkUpdatesToValidate(primAddr,triggerOldMap.get(primAddr.id));
			  	}
			  	
			  	//only if you are going to validate should you add to set
				if(validateAddress && !AddressValidator.Pending_Avalara_Response)
					{	addrIds.add(primAddr.Id);	}	
			}
			
			else {
				if (!isUSAddress(primAddr.Country__c)) 
					{	primAddr.International_Address__c= true;	}
				primAddr.Validated__c = false;
				primAddr.Validation_Error_Reason__c = null;
			}
			  
		}  
		
		if (!addrIds.isEmpty()){
			callAddressValidate(addrIds,true);
		}
		AddressTriggerHelper.checkIntlAddressAllowed(triggerNewMap.values(),triggeroldMap);
	} 
	
	public static void addressAfterUpdateTrigger(Map<Id,Address__c> triggerNewMap, Map<Id,Address__c> triggerOldMap){
	
		/*	Uncheck the primaries and cascade the primary when changed 
  	 	*	After update needs to check for dups, mainly after avalara returns response and its a dup address
  		*/
	 	List <Address__c> checkDupAdr = new List <Address__c>(); 
	 	set<String> acctIds = new set<String>();
	 	Map<Id, Account> acctMap = new Map <Id, Account>();
	 	Map<Id, List<Address__c>> addrMap = new Map<Id, List<Address__c>>();
	 
	 	for(Address__c ad : triggerOldMap.values()){
	 		acctIds.add(ad.Customer__c);
			if ( checkUpdatesToValidate( ad, triggerOldMap.get(ad.id) ) && !dupCheck || (Test.isRunningTest() && !dupCheck) )
				{	checkDupAdr.add(ad);	}
	 	}
	 
	 	if (!checkDupAdr.isEmpty())
	 		{	checkForDupAddresses(checkDupAdr);	}
	 
	 	for (Account acct:[ SELECT ShippingStreet,ShippingState, ShippingCountry, ShippingCity, 
									ShippingPostalCode, BillingStreet, BillingState, 
									BillingPostalCode, BillingCountry, BillingCity, 
								 	(Select Id,Primary_Bill_To_Address__c, Primary_Ship_To_Address__c, Address_Type__c,Customer__c,Standardized_Address__c,Zip_Code_4__c,Validation_Override__c From Addresses__r) 
							FROM Account where Id IN : acctIds]){
			acctMap.put(acct.id, acct);
			system.debug('addresses Size:'+acct.addresses__r.size());
			addrMap.put(acct.id, acct.Addresses__r);													
			}
		
	  	 
	  	Map<Id,Address__c> updAddressMap = new Map<Id,Address__c>();
	  	Map<Id,Account>	updAccountMap = new Map<Id,Account>();
	  	boolean isBilling,isShipping;
	  	isBilling = isShipping = false;

		for (Address__c pAddr : triggernewMap.values()){
			if (addrMap.get(pAddr.customer__c)!=null){
				system.debug('pAddr~~~~'+pAddr); 
				//Need to add condition for when both are unchecked
				//Transfer flags on Update
				// DE622 -- added additional logic for allowing updating when both are primary.
				// on the customer record correctly.
				if (((pAddr.Primary_Bill_To_Address__c && !triggerOldMap.get(pAddr.id).Primary_Bill_To_Address__c) 
					|| (pAddr.Primary_Ship_to_Address__c && !triggerOldMap.get(pAddr.id).Primary_Ship_to_Address__c)) ||
					((pAddr.Primary_Bill_To_Address__c && triggerOldMap.get(pAddr.id).Primary_Bill_To_Address__c) 
					|| (pAddr.Primary_Ship_to_Address__c && triggerOldMap.get(pAddr.id).Primary_Ship_to_Address__c))){
					
					for (Address__c addr:addrMap.get(pAddr.customer__c)){
						if (addr.Id != pAddr.Id && transferPrimaryFlags(pAddr,addr)){
							updAddressMap.put(addr.Id,addr);
							}
				 	}
				 	
					if (pAddr.Primary_Bill_To_Address__c)	{	isBilling =true;	}
					if (pAddr.Primary_Ship_to_Address__c)	{	isShipping=true;	}
					updAccountMap.put(pAddr.customer__c,cascadePrimaryToAccount(pAddr,isBilling,isShipping));
					}
					
			}
		}

		if (!updAddressMap.isEmpty()){ 
			primaryFlags=false;
			update updAddressMap.values();
			primaryFlags=true;
	 	}
	  	if (!updAccountMap.isEmpty()) 
	  		{	update updAccountMap.values();	}
	  
	}
	
	 
	public static void addressBeforeDeleteTrigger(List<Address__c> triggerOld){
		if (!dupCheck){
			for(Address__c pAddr : triggerOld){
				if(pAddr.Primary_Bill_To_Address__c ){
					pAddr.addError('You cannot delete a customer\'s primary billing address.  Please associate another primary billing address prior to deleting this record.');	
					}
				if(pAddr.Primary_Ship_to_Address__c){
					pAddr.addError('You cannot delete a customer\'s primary shipping address.  Please associate another primary shipping address prior to deleting this record.');
				}
				}			 
	 	}
	} 
	 
		
	public static boolean transferPrimaryFlags(Address__c pAddr, Address__c oAddr){
		
		boolean changeMade = false;
	 	
	 	if (pAddr.Primary_Bill_To_Address__c && oAddr.Primary_Bill_To_Address__c ){
			oAddr.Primary_Bill_To_Address__c=false;
		 	changeMade = true;
	  	}
		
		if (pAddr.Primary_Ship_to_Address__c && oAddr.Primary_Ship_to_Address__c){
	 		oAddr.Primary_Ship_to_Address__c=false;
			changeMade = true;
	  	}
		return changeMade;
	}
	
	public static  void validatePrimaryFlags(Address__c primAddr, Address__c oldAddr){
		
		//Part 1:Start:- Code for Primary Address field validation..
		if ((primAddr.Primary_Bill_To_Address__c != oldAddr.Primary_Bill_To_Address__c) || 
				(primAddr.Primary_Ship_to_Address__c != oldAddr.Primary_Ship_to_Address__c)){ 
			if(primaryFlags && !primAddr.Primary_Bill_To_Address__c && oldAddr.Primary_Bill_To_Address__c){
		  		primAddr.Primary_Bill_To_Address__c.addError('A customer must have at least 1 Primary Billing Address, please check another address prior to removing this address.');
				primaryFlags = false;
			}
			if(primaryFlags && !primAddr.Primary_Ship_to_Address__c && oldAddr.Primary_Ship_to_Address__c){
			  	primAddr.Primary_Ship_to_Address__c.addError('A customer must have at least 1 Primary Shipping Address, please check another address prior to removing this address.');	
				primaryFlags = false;
			}
		 }
	}
	
	public static boolean checkUpdatesToValidate(Address__c newAddress, Address__c oldAddress){
		return (newAddress.Address_Line_1__c != oldAddress.Address_Line_1__c ||
					newAddress.Address_Line_2__c != oldAddress.Address_Line_2__c ||
					newAddress.Address_Line_3__c != oldAddress.Address_Line_3__c ||
					newAddress.Address_Line_4__c != oldAddress.Address_Line_4__c ||
					newAddress.City__c != oldAddress.City__c|| newAddress.State_Providence__c != oldAddress.State_Providence__c ||
					newAddress.Country__c != oldAddress.Country__c ||
					newAddress.Zip_Code__c != oldAddress.Zip_Code__c) && (!newAddress.Validation_Override__c);
	}
	
	public static void setStandardizedAddress(Address__c primAddr){
		
		stdAddr = primAddr.Customer__c;
	
		/*
			DE856 -- protect against null fields and set them to blank for string
			More often than not, the first is not blank while others are.
			Should protect against null as well just in case.
		*/
		if (!String.isEmpty(primAddr.Address_Line_1__c)){
			stdAddr +=  '+' + primAddr.Address_Line_1__c;
		} else {
			stdAddr += '+';
		}

		if (!String.isEmpty(primAddr.Address_Line_2__c)){
			stdAddr +=  '+' + primAddr.Address_Line_2__c;
		} else {
			stdAddr += '+';
		}

		if (!String.isEmpty(primAddr.Address_Line_3__c )){
			stdAddr +=  '+' + primAddr.Address_Line_3__c;
		} else {
			stdAddr += '+';
		}
		
		/*
			DE856 -- protect against null fields and set them to blank for string
			For example: 123 main china would have been 123 main+null+null+china+null+null
			Now it will be 123 main+++china++ preventing the word null from interferring.
		*/
		if(primAddr.City__c != null && primAddr.City__c != ''){
			stdAddr +=  '+' + primAddr.City__c;
		}else{
			stdAddr +=  '+';
		}
		if(primAddr.State_Providence__c != null && primAddr.State_Providence__c != ''){
			stdAddr +=  '+' + primAddr.State_Providence__c;
		}else{
			stdAddr +=  '+';
		}
		if(primAddr.Country__c != null && primAddr.Country__c != ''){
			stdAddr +=  '+' + primAddr.Country__c;
		}else{
			stdAddr +=  '+';
		}
		if(primAddr.Zip_Code__c != null && primAddr.Zip_Code__c != ''){
			stdAddr +=  '+' + primAddr.Zip_Code__c;
		}else{
			stdAddr +=  '+';
		}
		//stdAddr +=  '+' + primAddr.City__c;
		//stdAddr +=  '+' + primAddr.State_Providence__c; 
		//stdAddr +=  '+' + primAddr.Country__c;
		//stdAddr +=  '+' + primAddr.Zip_Code__c;

		if (primAddr.Zip_Code_4__c != null && primAddr.Zip_Code_4__c != ''){
			stdAddr +=  '+' + primAddr.Zip_Code_4__c;
		}
		primAddr.Standardized_Address__c = stdAddr;
	}
	
	public static void callAddressValidate(set <Id> addrIds, boolean asynCallOut){
			
			if(addrIds.isEmpty()){	return; }
			
			//Address Validator WS 'avalara'
			else if (!AddressValidator.Pending_Avalara_Response){
			//Asynchronous call  
			if (asynCallOut){	AddressValidator.addressToValidate_Future(addrIds);	}
		  	//Synchronous call 
		  	else{	AddressValidator.addressToValidate(addrIds);	}
		}
	}
	
		public static boolean isUSAddress(String country){
		Set <String>  countryList = new Set <String> {'US','CA','UNITED STATES','CANADA','USA'};
		if(String.isNotEmpty(country)){
			return countryList.contains(country.toUpperCase());
		} return false;
		
	}
	
	public static void checkIntlAddressAllowed(List <Address__c> addressList,Map <Id, Address__c> oldAddrMap){
		Set <Id> acctIds = new Set <Id>();
		Map <Id, Account> accountMap = new Map <Id, Account>(); 
		for (Address__c addr: addressList){
			if (oldAddrMap!=null){
				if (oldAddrMap.get(addr.id).Country__c != addr.Country__c){
					if (!isUsAddress(addr.country__c)){
						acctIds.add(addr.customer__c);
					}
				}
			}
			else {
					if (!isUsAddress(addr.country__c)){
						acctIds.add(addr.customer__c);
					}
			}
		}
		if (!acctIds.isEmpty()){
			for (Account a: [select id, recordType.developerName from Account where id in : acctIds]){
				accountMap.put(a.id,a);
			}
			for (Address__c addr: addressList){
				if (acctIds.contains(addr.customer__c)){
					Customer_Rec_Type_Brand_Mapping__c crtbm = nbtyutils.getRecordTypeBrandMappingMap().get(accountMap.get(addr.customer__c).recordType.developerName);
					if (crtbm.US_Only__c&&addr.Address_Type__c.contains('Shipping')){
						addr.addError(crtbm.RecordTypeName__c+  ' orders can only be shipped to addresses in the Domestic US');
					}
				}
			}
		}
	
	}
	
	public static Account cascadePrimaryToAccount(Address__c pAddr, boolean isBilling, boolean isShipping){
			Account acct = new Account (id=pAddr.customer__c);
			if (isBilling){
				acct.BillingStreet = pAddr.Address_Line_1__c;
				if ( !String.isEmpty(pAddr.Address_Line_2__c)){
					acct.BillingStreet = acct.BillingStreet + ', ' + pAddr.Address_Line_2__c;
				}
		
				if ( !String.isEmpty(pAddr.Address_Line_3__c)){
					acct.BillingStreet = acct.BillingStreet + ', ' + pAddr.Address_Line_3__c;
				}
		
				if ( !String.isEmpty(pAddr.Address_Line_4__c)){
					acct.BillingStreet = acct.BillingStreet + ', ' + pAddr.Address_Line_4__c;
				}
				acct.BillingCity = pAddr.City__c;
				acct.BillingState = pAddr.State_Providence__c;
				acct.BillingCountry = pAddr.Country__c;
				acct.BillingPostalCode = pAddr.Zip_Code__c;
			}
			if (isShipping){
				acct.ShippingStreet = pAddr.Address_Line_1__c;
					
					if( !String.isEmpty(pAddr.Address_Line_2__c )){
 			  		acct.ShippingStreet = acct.ShippingStreet + ', ' + pAddr.Address_Line_2__c;
				}
				
				if( !String.isEmpty(pAddr.Address_Line_3__c )){
				  	acct.ShippingStreet = acct.ShippingStreet + ', ' + pAddr.Address_Line_3__c;
				}
				
				if( !String.isEmpty(pAddr.Address_Line_4__c )){
					acct.ShippingStreet = acct.ShippingStreet + ', ' + pAddr.Address_Line_4__c;
				}
				acct.ShippingCity = pAddr.City__c;
				acct.ShippingState = pAddr.State_Providence__c;
				acct.ShippingCountry = pAddr.Country__c;
				acct.ShippingPostalCode = pAddr.Zip_Code__c;
		  	} 
			return acct;
	}
	
	public static void checkForDupAddresses(List <Address__c> dupAddrList){
		
		set<String> acctIds = new set<String>();
		List <Address__c> addressesToDelete = new List <Address__c>();
		Map<Id,Address__c> addressesToUpdateMap = new Map<Id,Address__c>();
		
		for(Address__c ad : dupAddrList){
			acctIds.add(ad.Customer__c);
		 }
			 
		for (Account a: [SELECT ShippingStreet,ShippingState, ShippingCountry, ShippingCity, 
									ShippingPostalCode, BillingStreet, BillingState, 
									BillingPostalCode, BillingCountry, BillingCity, 
								(Select Id, Primary_Bill_To_Address__c, Primary_Ship_To_Address__c, 
								 		Address_Type__c,Customer__c,Standardized_Address__c,
								 		Zip_Code_4__c,Validation_Override__c 
 					From Addresses__r Order by Id)
					FROM ACCOUNT WHERE id in:acctIds ]){
				
			set <String> uniqueAddrSet = new set <String>();
			Map <String, Address__c> standAddrMap = new Map <String, Address__c>();
				 
			for (Address__c addr : a.Addresses__r){
				
				system.debug(LoggingLevel.info, addr.id);
				system.debug(LoggingLevel.info, addr.Standardized_Address__c);
				system.debug('uniqueAddrSet..............:'+ uniqueAddrSet);
				
				
				if (uniqueAddrSet.contains(addr.Standardized_Address__c)) {
					addressesToDelete.add(addr);
					Address__c addrToUpdate = standAddrMap.get(addr.Standardized_Address__c);
						
					if ( !String.isEmpty(addr.Address_Type__c)){
						if (addr.Address_Type__c.contains('Billing') && addr.Address_Type__c.contains('Shipping')){
							addrToUpdate.Address_Type__c = 'Billing;Shipping';  
							addressesToUpdateMap.put(addrToUpdate.Id,addrToUpdate);
						}
						else{ 
							if(addr.Address_Type__c.contains('Billing')){
								
								if ( !String.isEmpty(addrToUpdate.Address_Type__c) && addrToUpdate.Address_Type__c.contains('Shipping'))
									{	addrToUpdate.Address_Type__c = 'Billing;Shipping';	}
									else
									{	addrToUpdate.Address_Type__c = 'Billing';	}
							  	addressesToUpdateMap.put(addrToUpdate.Id,addrToUpdate);	
						 	}
							
							if( addr.Address_Type__c.contains('Shipping') ){
								if ( !String.isEmpty(addrToUpdate.Address_Type__c) && addrToUpdate.Address_Type__c.contains('Billing'))
									{	addrToUpdate.Address_Type__c = 'Billing;Shipping';	}
									else
									{	addrToUpdate.Address_Type__c = 'Shipping';	}
							  	addressesToUpdateMap.put(addrToUpdate.Id,addrToUpdate);
							}
							 
							}
					}
					
					if (addr.Primary_Ship_To_Address__c||addr.Primary_Bill_To_Address__c){
						
						if (addr.Primary_Bill_To_Address__c){
							addrToUpdate.Primary_Bill_To_Address__c=true;
							addressesToUpdateMap.put(addrToUpdate.Id,addrToUpdate);
						 }
				 
						if (addr.Primary_Ship_To_Address__c){
							addrToUpdate.Primary_Ship_To_Address__c=true;
							addressesToUpdateMap.put(addrToUpdate.Id,addrToUpdate);
						}
				 	}
										 
				 	if(addr.Validation_Override__c){
						addrToUpdate.Validation_Override__c = true;
						addrToUpdate.Validated__c = false;
						addrToUpdate.Validation_Error_Reason__c = null;
						addressesToUpdateMap.put(addrToUpdate.Id,addrToUpdate);
				 	}
		 		}
		 		else{
					uniqueAddrSet.add(addr.Standardized_Address__c);
					standAddrMap.put(addr.Standardized_Address__c, addr);
				}
			}							
		}
		if (!addressesToDelete.isEmpty()){
			dupCheck=true;
			delete addressesToDelete;
			dupCheck=false;
		}
			
		if (!addressesToUpdateMap.isEmpty()){
			dupCheck=true;
			update addressesToUpdateMap.values();
			dupCheck=false;				
		}
	}
	
	public static void setCountryCode(Address__c address){
		
		if( String.isEmpty(address.country_picklist__c) ){
			address.country__c = '' ;	
			address.Foreign_Country_Code__c = '';
		} else { 
			system.debug('~~~~~'+address.country_picklist__c);
			system.debug('~~~~~'+Country_code_mapping__c.getValues(address.country_picklist__c));
			address.country__c = String.valueOf(Country_code_mapping__c.getValues(address.country_picklist__c).Abbreviation__c); 
			address.Foreign_Country_Code__c = String.valueOf(Country_code_mapping__c.getValues(address.country_picklist__c).Code__c );
		}
	}
	
	public static Address__c addrClean(Address__c addr){ 
			if (setRequiredFields(addr))
				{	setCountryCode(addr);	}
			setStandardizedAddress(addr);
			if(addr.Residential_Commercial__c == 'R')						
			{ 	addr.Residential_Commercial__c = 'Residential'; }
		if(addr.Residential_Commercial__c == 'C')				
			{	addr.Residential_Commercial__c = 'Commercial';	}	
			return addr;
		}
	
	public static boolean setRequiredFields(Address__c addr){		
		
		if( String.isEmpty(addr.country_picklist__c )){
				addr.Country_Picklist__c.addError('The address must have a Country selected.');	
				return false;
		}
		
		if(addr.country_picklist__c == 'United States' && ( String.isEmpty(addr.City__c))){
				addr.City__c.addError('The City cannot be blank for a USA address.');
				return false;	
	 	}
		
		if(addr.country_picklist__c == 'United States' && ( String.isEmpty(addr.State_Providence__c ))){
			addr.State_Providence__c.addError('The State/Province cannot be blank for a USA address.');
				return false;	
	 	}
			return true;
	}
	
	// Call before insert, before update
	public static void validateAddressLength(List<Address__c> triggerNew){
		for(Address__c addr : triggerNew){
			if(String.isNotBlank(addr.Address_Line_1__c) && addr.Address_Line_1__c.length() > 30){
				addr.addError('Address Line 1 cannot be longer than 30 characters.');
			}
			if(String.isNotBlank(addr.Address_Line_2__c) && addr.Address_Line_2__c.length() > 30){
				addr.addError('Address Line 2 cannot be longer than 30 characters.');
			}
			if(String.isNotBlank(addr.Address_Line_3__c) && addr.Address_Line_3__c.length() > 30){
				addr.addError('Address Line 3 cannot be longer than 30 characters.');
			}
			if(String.isNotBlank(addr.Address_Line_4__c) && addr.Address_Line_4__c.length() > 30){
				addr.addError('Address Line 4 cannot be longer than 30 characters.');
			}
		}
	}

}