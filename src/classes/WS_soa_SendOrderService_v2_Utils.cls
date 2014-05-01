public with sharing class WS_soa_SendOrderService_v2_Utils {

	
	public static Orders__c ord {get;set;}
	public static Account acct {get;set;}
	public static List<Order_Line_Items__c> olis {get;set;}
	public static Address__c shipaddress {get;set;}
	public static Address__c billaddress {get;set;}
	public static List <Allowance__c> allowances ;
	public static string sequenceNumber ;
	public static User user1 {get;set;}
	public static integer lineNumber = 10;
	public static boolean btIntl =false;
	public static boolean stIntl =false;
	public static boolean hasAllowances =false;
	public static boolean hasComments= false;
	public static boolean hasMiscCharges = false;
	
	public static boolean isPhoneOrder (Orders__c orderObj){
		return ord.Sales_Channel__c=='Phone' || ord.Sales_Channel__c=='Mail' ;
	}
	
	public static boolean isAmazonModel (Orders__c orderObj )
	{
		if ((orderObj.Sales_Channel__c=='Brand Website' && !orderObj.Amazon_Model__c) || (orderObj.Sales_Channel__c=='OrderGroove') && !orderObj.Amazon_Model__c)
		{
			return false;
		}
		else return true;
	}
	
	public static string getCountryCodeValue(string fullCountryName){
		system.debug(LoggingLevel.info, 'fullCountryName~~~'+fullCountryName);
		Country_code_mapping__c ccm=Country_code_mapping__c.getValues(fullCountryName);
		system.debug(LoggingLevel.info, 'ccm~~~'+ccm);
		if (ccm!=null)  return ccm.code__c;
		else return null;
	}
	
	public static string setBrandString(orders__c orderObj, Account act){
		string brandString ='';
		if (isPhoneOrder(orderObj)){
			if (act.Associate_Customer__c){
				brandString = 'EO';
			}
			else {
				brandString=NBTYUtils.getRecordTypeBrandMappingMap().get( act.RecordType.DeveloperName).server_prefix__c;
			}
		}
		else {
			brandString=WebStoresData__c.getValues(orderObj.Webstack_Id__c).server_prefix__c==null? 'PP': WebStoresData__c.getValues(orderObj.Webstack_Id__c).server_prefix__c;
		}
		return brandString;
	}
	

	public static string setCardExpiry(orders__c orderObj){
		if (ord.Payment_Type__c=='Credit Card'&&ord.Credit_Card_Expiration_Date__c!=null){
				if (ord.Credit_Card_Expiration_Date__c.length()==6){
					return ord.Credit_Card_Expiration_Date__c.substring(4,6)+ord.Credit_Card_Expiration_Date__c.substring(2,4);
				}
				else return ord.Credit_Card_Expiration_Date__c;
		}
		else {
			string month = string.valueOf(system.today().month());
			if (month.length()==1) month='0'+month;
			integer intYear = system.today().year()+1;
			string year = string.valueOf(intYear).substring(2,4);
			return month+year;
		}
	}
	
	public static boolean isNumeric(string numField){
		if (numField==null){
			return false;
		}
		else {
			boolean isValid = false;
			try {
			  decimal x = decimal.valueOf(numField);
			  isValid=true;
			}
			Catch (exception e) {
				isValid =false;
			}
			return isValid;
		}
	}
	
	public static string formatCurrencies(decimal currencyAmount){
		system.debug('currency Amount'+currencyAmount);
		string returnCurrencyAmount;
		if (currencyAmount==null){
			returnCurrencyAmount='0';
		}
		else {
			
			returnCurrencyAmount=string.valueOf(currencyAmount.setScale(2));
				if(returnCurrencyAmount != null){
					returnCurrencyAmount.remove(',');
				}
			}
		return returnCurrencyAmount;
	}
	
	public static decimal formatCurrenciesDecimal(decimal currencyAmount){
		system.debug('currency Amount'+currencyAmount);
		decimal returnCurrencyAmount;
		if (currencyAmount==null){
			returnCurrencyAmount=0;
		}
		else {
			
			returnCurrencyAmount=currencyAmount.setScale(2);
				/*if(returnCurrencyAmount != null){
					returnCurrencyAmount.remove(',');
				}*/
			}
		return returnCurrencyAmount;
	}
	
	public static string setLineNumber (){
		string tempLineNumber = string.valueOf(lineNumber);
		lineNumber+=10;
		return tempLineNumber;
	}
	
	public static string returnSequenceNumber(Orders__c orderObj){
		//if (sequenceNumber==null){
			if (orderObj.Webstack_Order_ID__c!=null){
				sequenceNumber= orderObj.Webstack_Order_ID__c	;
			}
			else{
				sequenceNumber = orderObj.name;
			}
		//}
		return sequenceNumber;		
	}
	
	public static string replacePhoneChars(string s){
		s=s.replace('(', '');
		s=s.replace(')', '');
		s=s.replace('-', ''); 
		s=s.replace(' ', '');
		return s;
	}
	
	public static string setOrderPhone(){
		string str ='';
		if ( ord.Phone_Number__c !=null ){
			str=replacePhoneChars(ord.Phone_Number__c);
		}
		else if (acct.Phone!=null){
			str=replacePhoneChars(acct.Phone);
		}
		else {
			str='0000000000';
		}
		return str;
	}
	
	public static integer[] setItemBuyReceive (integer[] inputArray){
		system.debug(inputArray);
		integer originalItemBuy = inputArray[0];
		integer originalItemReceive = inputArray[1];
		integer newItemBuy, newItemReceive;
		integer []returnArray;
		if (originalItemBuy==1){
			returnArray=inputArray;
		}
		else {
			if (math.mod(originalItemReceive,originalItemBuy)==0){//if divisible by each other you can pull it down to a itemBuy w/1
				newItemBuy=1;
				newItemReceive=originalItemReceive/originalItemBuy;
			}
			else{
				decimal dtempItemBuy = decimal.valueOf(originalItemBuy);
				integer itempItemBuy = originalItemBuy;
				if (originalItemBuy==2){
					newItemBuy=originalItemBuy;
					newItemReceive=originalItemReceive;
				}
				else {
					integer ifactor =1;
					while(itempItemBuy!=2&&math.mod(itempItemBuy,2)==0){
						dtempItemBuy=dtempItemBuy/2;
						itempItemBuy=itempItemBuy/2;
							iFactor=iFactor*2;

					}
					if(itempItemBuy==2){
						newItemBuy=originalItemBuy/iFactor;
						newITemReceive=originalItemReceive/iFactor;
					}
					else {
						newItemBuy=2;
						newItemReceive=5;//funky case
					}
				}

			}
			returnArray = new Integer[]{newItemBuy,newItemReceive};
		}
		
		return returnArray;
		
	}
	
	public static string returnCcCode(Orders__c orderObj){ 
		// return 'R' if replacment order
		if (orderObj.Replacement_Order__c == true) {
			return 'R';
		}
		Set<String> salesChannels = new Set<String>{'Amazon','Amazon JP','Yahoo JP','Tmall Global','Paypal','Rakuten'};
		Map<String, Credit_Card_Type_Mapping__c> ccTMap = new Map<String, Credit_Card_Type_Mapping__c>();
		if (orderObj.Payment_Type__c == 'Credit Card') {
			system.debug('---------------------------------------Credit Card Type: ' + orderObj.Credit_Card_Type__c);
			if (orderObj.Credit_Card_Type__c.length() > 1) {
				cctMap = NBTYUtils.getCCTypeMappings('Name');
				Credit_Card_Type_Mapping__c cctm1 = ccTMap.get(orderObj.Credit_Card_Type__c);
				return cctm1.Web_Value__c;
			} else {
				cctMap = NBTYUtils.getCCTypeMappings('Web');
				Credit_Card_Type_Mapping__c cctm2 = ccTMap.get(orderObj.Credit_Card_Type__c);
				return cctm2.Web_Value__c;
			}
		} else if (orderObj.Payment_Type__c != 'Credit Card' && salesChannels.contains(orderObj.Sales_Channel__c)) {
			system.debug('---------------------------------------Sales Channel: ' + orderObj.Sales_Channel__c);
			cctMap = NBTYUtils.getCCTypeMappings('Name');
			Credit_Card_Type_Mapping__c cctm3 = ccTMap.get(orderObj.Sales_Channel__c);
			return cctm3.Web_Value__c;
		} else {
			return 'C';
		}
		
		/*Set <String> validCcSet = new Set <String>{'V','D','A','M','Z','Y'};
		
		if (orderObj.Payment_Type__c=='Credit Card'){
			if (validCcSet.contains(orderObj.Credit_Card_Type__c)){
				return orderObj.Credit_Card_Type__c;
			}
			else {
				return NBTYUtils.getCCTypeMappings('Name').get(orderObj.Credit_Card_Type__c).web_value__c;
			}
		} else if (orderObj.Sales_Channel__c=='Amazon') {
			return 'Z';
		} else if (orderObj.Sales_Channel__c=='Amazon JP') {
			return 'N';
		} else if (orderObj.Sales_Channel__c=='Yahoo JP') {
			return 'H';
		} else if (orderObj.Sales_Channel__c=='Tmall Global') {
			return 'T';
		} else if (orderObj.Payment_Type__c=='Paypal') {
			return 'Y';
		} else if (orderObj.Sales_Channel__c == 'Rakuten') {
			return 'K';
		} else {
			return 'C';
		}*/
	}
	
/********************************************Validation Methods********************************************************/	
	public static String validateOCHID(){
		String str;
		if (acct.OCH_Id__c!=null){
			if(acct.OCH_ID__c.length() <= 10){
				str = acct.OCH_ID__c;
			}else {
				str = acct.OCH_ID__c.substring(0,9);
			}
		}
		return str;
	}
	
	public static String validateFirstName(string inputString){
		String str;
		if (inputString!=null){
			if(inputString.length() <= 12){
				str = inputString.toUpperCase();
			}else {
				str = inputString.substring(0,11).toUpperCase();
			}
		}
		return str;
	}
	
	public static String validateLastName(string inputString){
		String str;
		if (inputString!=null){
			if(inputString.length() <= 15){
				str = inputString.toUpperCase();
			}else {
				str =inputString.substring(0,14).toUpperCase();
			}
		}
		return str;
	}
	
	public static String validateEmail(){
		String str;
		if (acct.PersonEmail!=null){
			if(acct.PersonEmail.length() <= 50){
				str = acct.PersonEmail.toUpperCase();
			}else {
				str = acct.PersonEmail.substring(0,49).toUpperCase();
			}
		}
		return str;
	}
	
	
	public static String validatePaypal(){
		String str;
		if (ord.Paypal_Authorization_Code__c!=null){
			if(ord.Paypal_Authorization_Code__c.length() <= 19){
				str = ord.Paypal_Authorization_Code__c;//19 max string
				}else {
				str = ord.Paypal_Authorization_Code__c.substring(0,18);//19 max string
			}
		}
		return str;
	}
/*********************************************End Validation Methods********************************************************/
	
	public static string returnShippingMethod(Orders__c orderObj){
		Map<String, String> shipMethMap = new Map<String,String>();
		shipMethMap.put('TwoDay','S');
		shipMethMap.put('International',' ');
		shipMethMap.put('NextDay','N');
		shipMethMap.put('USPS','P');
		shipMethMap.put('Air', 'A');
		shipMethMap.put('R','R');
		string sfdcShipmentMethod = orderObj.Shipping_Method__c;
		String transformShipMethod = shipMethMap.get(sfdcShipmentMethod);
		if (transformShipMethod != null) {
			return transformShipMethod;
		} else {
			return ' ';
		}
		/*if (sfdcShipmentMethod=='TwoDay') return 'S'; ///ups 2nd day
		else if (sfdcShipmentMethod=='International') return 'I'; //		   ‘I’ -  UPS (International )
		else if (sfdcShipmentMethod=='NextDay') return 'N';//		   ‘N’ – UPS (Next Day)
		else if (sfdcShipmentMethod=='USPS') return 'P';//‘P’ -Puritan’s Pride – Parcel Post
		else if (sfdcShipmentMethod=='UPS') return 'U'; //‘U’- UPS (Residential or Commercial must be entered)
		else return ' ';*/
		
	}
	
	
	public static void doSOQLs(Id orderId){
		ord = [SELECT Id, Name, Sequence_Number__c, Amazon_Model__c, Ship_To_Address__c, Paypal_Authorization_Code__c, Shipping_Total__c, Tax__c,
				Webstack_Order_ID__c, Payment_Transaction_Reference_Index__c, Payment_Transaction_Reference_Number__c, Valid_Duplicate__c, 
				Authorization_Amount__c, Bank_Response_Date_Time__c, Payment_Authorization_Code__c, Credit_Card_Expiration_Date__c, 
				Credit_Card_Type__c, Catalog_Source_Code__c,  Credit_Card_Token__c, Misc_Charge_Code__c, Misc_Charge_Amount__c, 
				Bill_To_Address__c, Shipping_Method__c, Internal_Review_Reason__c, Gift_Order__c, Customer__c, Third_Party_Order_Number__c ,
				Payment_Type__c, Payment_Profile_ID__c, Sales_Channel__c, Pull_Order__c,Order_Total__c, CreatedById, Webstack_Id__c,ship_to_email_address__c,
				No_Invoice__c, No_Peanuts__c, No_Substitutes__c, Ship_Complete__c,Pull_Order_Reason__c,Shipping_Tax__c, ownerId,Phone_Number__c, Comments__c, Source_Code__c,
				Ship_to_First_Name__c, Ship_to_Last_Name__c,Ship_to_Salutation__c,Foreign_Phone_Number__c, Replacement_Order__c, Pull_Order_Reason_Multi__c, Pull_Order_Reason_Other__c
				FROM Orders__c WHERE Id = :orderId LIMIT 1];//Name = '10000181' 
		
		acct = [SELECT Id, Salutation, FirstName, LastName, PersonEmail, SMS_Opt_In__c, Email_Opt_Out__c, AS_400_Customer_Number__c, 
				RecordType.Name, Customer_Number__c, OCH_ID__c, VW_Passport_Number__c, Phone,RecordType.DeveloperName, Associate_Customer__c,
				PersonBirthdate FROM Account WHERE Id = :ord.Customer__c];
		
		olis = [SELECT Id, Line_Number__c, Tax__c, Product_Number__c, Product_Quantity__c, Comments__c, Unit_Price__c, Item_Buy__c, Item_Receive__c, 
				Price_Override__c, SKU_Number__c, Final_Price__c, Tax_Code__c, Substituted_Item__r.Product_Number__c,  Website_Price__c,
				Quantity_Shipped__c, Original_Quantity__c, Tax_Rate__c, Discount__c , Static_Unit_Price__c
				FROM Order_Line_Items__c 
				WHERE Order__c = :ord.Id
				AND Product_Quantity__c > 0 
				AND Original_Quantity__c> 0];
		
			try {		
				shipaddress = [SELECT Id, Country__c, Zip_Code_4__c, Address_Line_1__c, Address_Line_2__c, Address_Line_3__c, Residential_Commercial__c,
								Address_Line_4__c, Zip_Code__c, City__c, State_Providence__c, Foreign_Postal_Code__c, Country_Picklist__c,
								Foreign_Country_Code__c FROM Address__c WHERE Id = :ord.Ship_To_Address__c ];
				stIntl = WS_soa_SendOrderService_v2_Utils.shipaddress.Country__c!='US';
					
				billaddress = [SELECT Id, Country__c, Zip_Code_4__c, Address_Line_1__c, Address_Line_2__c, Address_Line_3__c, Residential_Commercial__c,
								Address_Line_4__c, Zip_Code__c, City__c, State_Providence__c, Foreign_Postal_Code__c, Country_Picklist__c,Foreign_Country_Code__c
								 FROM Address__c WHERE Id = :ord.Bill_To_Address__c];
				btIntl = WS_soa_SendOrderService_v2_Utils.billaddress.Country__c!='US';	
			}
			catch (exception e){
				// Attemp to rectify missing address record on order. -- DE522
				system.debug('null addresses');
				try {
					system.debug('attempt to find proper address');
					if (ord.Sales_Channel__c != 'Brand Website'){
						// If this is a phone or mail order; thus not Brand Website then grab the default.
						if (billaddress == null){
							billaddress = [SELECT Customer__c, Primary_Bill_To_Address__c, Id, Country__c, Zip_Code_4__c, Address_Line_1__c, Address_Line_2__c, Address_Line_3__c, Residential_Commercial__c,
								Address_Line_4__c, Zip_Code__c, City__c, State_Providence__c, Foreign_Postal_Code__c, Country_Picklist__c,Foreign_Country_Code__c
								FROM Address__c WHERE Primary_Bill_To_Address__c = true AND Customer__c = :ord.Customer__c];
						}
						if (shipaddress == null){
							shipaddress = [SELECT Customer__c, Primary_Ship_To_Address__c, Id, Country__c, Zip_Code_4__c, Address_Line_1__c, Address_Line_2__c, Address_Line_3__c, Residential_Commercial__c,
							Address_Line_4__c, Zip_Code__c, City__c, State_Providence__c, Foreign_Postal_Code__c, Country_Picklist__c,
							Foreign_Country_Code__c FROM Address__c WHERE Primary_Ship_To_Address__c = true AND Customer__c = :ord.Customer__c];
						}
					} else {
						System.debug('Brand Website was the channel.');
						// if there is only 1 then there is no question about it.
						List<Address__c> brandOrderAddressList = [SELECT Customer__c, Primary_Bill_To_Address__c, Primary_Ship_To_Address__c, Id, Country__c,
							Zip_Code_4__c, Address_Line_1__c, Address_Line_2__c, Address_Line_3__c, Residential_Commercial__c, Address_Line_4__c, Zip_Code__c,
							City__c, State_Providence__c, Foreign_Postal_Code__c, Country_Picklist__c, Foreign_Country_Code__c 
							FROM Address__c WHERE Customer__c = :ord.Customer__c];
							
						if (brandOrderAddressList.size() == 1){
							// can set if there's only one address for web orders.
							if (billaddress == null){
								billaddress = brandOrderAddressList[0];
							}
							if (shipaddress == null){
								shipaddress = brandOrderAddressList[0];
							}
						}else{
							// has more than just one address. 
							// Check if they're dupes with different case?
							// Attemp to find match from Order_Summary__c with Webstack_Order_Id__c
							Order_Summary__c summary = [SELECT Id, Header__c, Ship_To__c, Webstack_Order_Id__c from Order_Summary__c where Webstack_Order_Id__c = :ord.Webstack_Order_ID__c];
							List <Address__c> customerAddresses = [SELECT Customer__c, Primary_Bill_To_Address__c, Primary_Ship_To_Address__c, Id, Country__c,
																	Zip_Code_4__c, Address_Line_1__c, Address_Line_2__c, Address_Line_3__c, Residential_Commercial__c,
																	Address_Line_4__c, Zip_Code__c, City__c, State_Providence__c, Foreign_Postal_Code__c, Country_Picklist__c,
																	Foreign_Country_Code__c  
																	from Address__c Where Customer__c = :ord.Customer__c];
							
							string summaryHeader;
							string summaryShipTo;
							if (summary != null){
								summaryHeader = summary.Header__c;
								summaryShipTo = summary.Ship_To__c;
							}
							
							if (summaryHeader != null && summaryShipTo != null){
								Address__c addr;
								for (Address__c a : customerAddresses){
									addr = a;
									if (summaryHeader.contains(a.Address_Line_1__c) && summaryHeader.contains(a.Address_Line_2__c) &&
										summaryHeader.contains(a.State_Providence__c) && summaryHeader.contains(a.City__c)){
										// save only first match
										if (billaddress != null){
											billaddress = a;
										}	
									}
									if (summaryShipTo.contains(a.Address_Line_1__c) && summaryShipTo.contains(a.Address_Line_2__c) &&
										summaryShipTo.contains(a.State_Providence__c) && summaryShipTo.contains(a.City__c)){
										// save only first match
										if (shipaddress != null){
											shipaddress = a;
										}	
									}
								}
							}
						}
					}
				}
				catch (exception ex){
					System.debug('Could not successfully acquire a valid address.');
				} // end DE522
			}
		try {
		user1 =[select alias from User where id=:ord.ownerId];
		}
		catch (exception e){
			user1 =[select alias from User where id=:ord.CreatedById];
		}
		
		allowances = [ select Allowance_Amount__c, Allowance_Code__c ,Allowance_Coupon__c , Allowance_Redemption_Code__c, 
						Spl_Allowance_Code_Descr__c, VW_Loyalty_Coupon_Code__c FROM Allowance__c WHERE order__c =:ord.id];
		if (allowances!=null){
			hasAllowances = true;
		}
		if (ord.pull_order__c||ord.Comments__c!=null || ord.Pull_Order_Reason_Multi__c != null){
			hasComments = true;
		}
		else {
			for (Order_Line_Items__c oli: olis){
				if (oli.comments__c!=null){
					hasComments=true;
					break;
				}
			}
		}
	}
	
	public static WS_soa_SendOrderService_v2.header_element settingHeader(WS_soa_SendOrderService_v2.billTo_element billToElement){
		
		WS_soa_SendOrderService_v2.header_element headerElement = new WS_soa_SendOrderService_v2.header_element();
		headerElement.recordType = 'H';
		headerElement.sequenceNumber = returnSequenceNumber(ord);
		headerElement.cardNumber = ord.Payment_Type__c=='Credit Card'? ord.Credit_Card_Token__c: '4444333322221111';
		headerElement.brand = setBrandString(ord,acct);
		headerElement.cardExpiry = setCardExpiry(ord);
		headerElement.lineNumber = setLineNumber();
		headerElement.customerNumber = '0000000000';
		// DE862 -- Replaced TIN4VU with spaces per Alan Shore, old code TIN4VU is PP only
		headerElement.catalogSourceCode = ord.Catalog_Source_Code__c!=null? ord.Catalog_Source_Code__c: (ord.Source_Code__c!=null? ord.Source_Code__c : '      ');//default source code for now
		headerElement.geography = 'US';
		headerElement.cardType = returnCcCode(ord);
		headerElement.csrAgentID = '15917'; //Map this to the Agent Id - CNX__Agent_ID__c on user record
		headerElement.ochID = validateOCHID();
		headerElement.billTo = billToElement;
		if (ord.Valid_Duplicate__c) {
			headerElement.headerElement1 = 'Y';
		}
		return headerElement;
	}
	
	public static WS_soa_SendOrderService_v2.shipToRecord_element settingShipTo(WS_soa_SendOrderService_v2.address2_element address2){
		WS_soa_SendOrderService_v2.shipToRecord_element shipToElement = new WS_soa_SendOrderService_v2.shipToRecord_element();
		shipToElement.recordType = 'S';
		shipToElement.sequenceNumber = returnSequenceNumber(ord);
		shipToElement.lineNumber = setLineNumber();
		shipToElement.address2 = address2;
		shipToElement.emailAddress = validateEmail();
		shipToElement.firstName = ord.Ship_to_First_Name__c!=null? validateFirstName(ord.Ship_to_First_Name__c):validateFirstName(acct.FirstName);
		shipToElement.lastName = ord.Ship_to_Last_Name__c!=null?  validateLastName(ord.Ship_to_Last_Name__c):validateLastName(acct.LastName);
		shipToElement.title = ord.Ship_to_Salutation__c;
		shipToElement.ochIdNumber = validateOCHID();
		
		shipToElement.salesForceCustomerNumber = acct.Customer_Number__c;//SFDC max = service max
		shipToElement.salesForceOrderNumber = ord.Name;// SFDC max < service max
		if(shipAddress.Country__c.length() <= 5){
			shipToElement.shipCountry = shipAddress.Country__c;
			}else {
			shipToElement.shipCountry = shipAddress.Country__c.substring(0,5);
			}
		shipToElement.authCodePaypal = validatePaypal();
		shipToElement.shippingHandling = formatCurrenciesDecimal(ord.Shipping_Total__c);
		shipToElement.shippingHandlingTax = formatCurrenciesDecimal(ord.Shipping_Tax__c);
		shipToElement.thirdPartyOrdernumber = ord.Third_Party_Order_Number__c;
		// DE887 -- If it is a phone/mail order DO NOT send what is on the order, just send the account email.
		// Otherswise, send the order's email.
		if (ord.Sales_Channel__c != 'Phone' || ord.Sales_Channel__c != 'Mail' && String.IsBlank(ord.Webstack_Order_Id__c)){
			shipToElement.emailAddress = acct.PersonEmail;
		} else {
			shipToElement.emailAddress = ord.Ship_To_Email_Address__c;
		}
		shipToElement.shipCountry=getCountryCodeValue(shipaddress.country_picklist__c) ;
		shipToElement.AddressLine4 = shipaddress.Address_Line_4__c!=null?shipaddress.Address_Line_4__c.toUpperCase() : null;
		return shipToElement;
	}
	
	public static WS_soa_SendOrderService_v2.billTo_element settingBillTo(WS_soa_SendOrderService_v2.address1_element address1){
		WS_soa_SendOrderService_v2.billTo_element billToElement = new WS_soa_SendOrderService_v2.billTo_element();
		billToElement.address1 = address1;
		billToElement.firstName = validateFirstName(acct.FirstName);
		billToElement.lastName = validateLastName(acct.LastName);
		billToElement.phoneNumber = setOrderPhone();
				system.debug('BT Element ~~~~' +billToElement);
		billToElement.foreignTelephone = ord.Foreign_Phone_Number__c;
				system.debug('BT Element ~~~~' +billToElement);
		system.debug('foreign phone~~~~'+ord.Foreign_Phone_Number__c);
		billToElement.shipmentMethod =returnShippingMethod(ord);
		billToElement.residentialOrCommercial = billToElement.shipmentMethod =='U' ?  (billAddress.Residential_Commercial__c!='C-Commercial'? 'R':'C') : ' ';
		billToElement.securedOrUnsecured = 'S';
		billToElement.cardHolderVerification = '1';
		billToElement.qasFlag = ' ';//always blank - temp for schema issues
		if(acct.VW_Passport_Number__c != '' && acct.VW_Passport_Number__c != null){
			billToElement.passPortNumber = acct.VW_Passport_Number__c; //SFDC max = service max
		}
		billToElement.birthday = String.valueOf(acct.PersonBirthdate);
		//billToElement.suspendComment = ord.Suspend_Reason__c; Not sure this is actually right PTN
		billToElement.giftOrder = ord.Gift_Order__c? 'Y':' ';
		billToElement.postCode = btIntl ?billaddress.Foreign_Postal_Code__c: null;
		billToElement.countryCode = btIntl ? getCountryCodeValue(billAddress.country_picklist__c): null;
		billToElement.zip4 = billAddress.Zip_Code_4__c;//SFDC max = service max
		billToElement.pullOrder = ord.pull_order__c? 'Y':'N';
		billToElement.userId = isPhoneOrder(ord)? user1.alias : 'WEB SITE';
		billToElement.AddressLine4 = billaddress.Address_Line_4__c!=null?billaddress.Address_Line_4__c.toUpperCase() : null;
			system.debug('BT Element ~~~~' +billToElement);
		//billToElement.transId = ord.Payment_Transaction_Reference_Number__c; 
		return billToElement;
	}
	
	public static WS_soa_SendOrderService_v2.address1_element settingAddress1(){
		WS_soa_SendOrderService_v2.address1_element address1 = new WS_soa_SendOrderService_v2.address1_element();
		address1.addressLine2 =billaddress.Address_Line_1__c!=null?billaddress.Address_Line_1__c.toUpperCase() : null;//reversed for AS400
		address1.addressLine1 =billaddress.Address_Line_2__c!=null?billaddress.Address_Line_2__c.toUpperCase() : null;//reversed for AS400
		address1.addressLine3 =billaddress.Address_Line_3__c!=null?billaddress.Address_Line_3__c.toUpperCase() : null;
		address1.addressLine4 =billaddress.Address_Line_4__c!=null?billaddress.Address_Line_4__c.toUpperCase() : null;
		address1.city =billaddress.City__c!=null?billaddress.City__c.toUpperCase() : null; 
		address1.state =btIntl? 'FO' :billaddress.State_Providence__c.toUpperCase();
		address1.zipcode =btIntl? '00000' : billaddress.Zip_Code__c;//need mapping for country code #
		address1.postCode= btIntl? billaddress.Foreign_Postal_Code__c : null;
		return address1;
	}
	
	public static WS_soa_SendOrderService_v2.address2_element settingAddress2( ){ 
		WS_soa_SendOrderService_v2.address2_element address2 = new WS_soa_SendOrderService_v2.address2_element();
		address2.addressLine2 =shipaddress.Address_Line_1__c!=null?shipaddress.Address_Line_1__c.toUpperCase() : null;//reversed for AS400
		address2.addressLine1 =shipaddress.Address_Line_2__c!=null?shipaddress.Address_Line_2__c.toUpperCase() : null;//reversed for AS400
		address2.addressLine3 =shipaddress.Address_Line_3__c!=null?shipaddress.Address_Line_3__c.toUpperCase() : null;
		address2.addressLine4 =shipaddress.Address_Line_4__c!=null?shipaddress.Address_Line_4__c.toUpperCase() : null;
		address2.city =shipaddress.City__c!=null?shipaddress.City__c.toUpperCase() : null; 
		address2.state =stIntl? 'FO' :shipaddress.State_Providence__c.toUpperCase();
		address2.zipcode =stIntl? '00000': shipaddress.Zip_Code__c;//need mapping for country code #
		address2.postCode= stIntl? shipaddress.Foreign_Postal_Code__c : null;
		return address2;
	}
	
	public static List<WS_soa_SendOrderService_v2.detailRecord_element> settingDetail(){
		List<WS_soa_SendOrderService_v2.detailRecord_element> detailElementArray= new List <WS_soa_SendOrderService_v2.detailRecord_element>();
		for(Order_Line_Items__c x : olis){
			WS_soa_SendOrderService_v2.detailRecord_element a = new WS_soa_SendOrderService_v2.detailRecord_element();
			a.recordType = 'D';
			a.sequenceNumber = returnSequenceNumber(ord);
			a.lineNumber =setLineNumber();
			a.itemNo = x.Product_Number__c.substring(2,6);
			a.skewNumber = x.Product_Number__c;
			a.quantity = (x.Original_Quantity__c!=null && x.Original_Quantity__c!=0) ? string.valueOf(x.Original_Quantity__c): '0';
			//Change how websiteprice is calculated - use Static_Unit_Price__c instead of Unit_Price__c
			a.websitePrice = isPhoneOrder(ord)? formatCurrenciesDecimal(x.Static_Unit_Price__c): formatCurrenciesDecimal(x.Website_Price__c);//always use website price need to evaluate for price overrides
			if (x.Price_Override__c!=0) a.overridePrice = formatCurrenciesDecimal(x.Price_Override__c); 
			a.vitaminWorldTax = '000000';
			
			if (isAmazonModel(ord)){  //only populate if order qualifies as amazon model
				//a.fullLineItemDiscountAmount = formatCurrencies(x.Discount__c);
				a.fullLineItemPrice = formatCurrencies(x.final_price__c);
				a.quantity =string.valueOf(x.Product_Quantity__c);//if amazon model this is the total quantity
				try{
					a.fullLineItemPriceTaxRate =string.valueOf((x.Tax__c/x.final_price__c).setScale(3));  //must use actual rate passed to us for non-amazon model TEMP until MINDTREE ISSUE RESOLVED
				}
				catch(exception e) {
					a.fullLineItemPriceTaxRate = '0.0'; // exception
				}
				
				integer[] inputIntArray;
				if(x.Item_Buy__c != 0 && x.Item_Buy__c!=null && x.Item_Receive__c != 0 && x.Item_Receive__c!=null) {
					inputIntArray = new Integer[]{integer.valueOf(x.Item_Buy__c),integer.valueOf(x.Item_Receive__c)};
				}
				else {
					inputIntArray = new Integer[]{integer.valueOf(x.Original_Quantity__c),integer.valueOf(x.Product_Quantity__c)};
				}
				 
				integer [] returnIntArray= setItemBuyReceive(inputIntArray);
				a.itemBuy = String.valueOf(returnIntArray[0]);
				a.itemReceive = String.valueOf(returnIntArray[1]);
				integer origQty = integer.valueOf(x.Original_Quantity__c);
				//use to calculate discount, best way to ensure accuracy
				//decimal trueQty = (decimal.valueOf(a.itemBuy) * decimal.valueOf(a.quantity)/decimal.valueOf(a.itemReceive)); PTN 0827
				//a.fullLineItemDiscountAmount=formatCurrencies(trueQty* decimal.valueOf(a.websitePrice)-decimal.valueOf(a.fullLineItemPrice));  PTN 0827
				// DE890 -- if a web order is edited by an agent the web price is 0.00 and this causes a huge offset of 0.00 - line price
				if (a.websitePrice == 0.00){
					a.webSitePrice = decimal.valueOf(a.fullLineItemPrice) / origQty;
				} 
				a.fullLineItemDiscountAmount = formatCurrencies(( origQty* a.websitePrice) - decimal.valueOf(a.fullLineItemPrice)); // PTN 0827
			}
			else {
				//tax for all others
				//a.fullLineItemPriceTaxAmount = formatCurrencies(x.Tax__c);
				decimal tempTaxRate =x.Tax_Rate__c;
				if (x.Tax_Rate__c !=null & x.Tax_Rate__c > 0){
					// changed to 4 places to enhance precision. 
					tempTaxRate = x.Tax_Rate__c.divide(100,4);  //INC698846
				}
				// changed to use substring instead
				string tempStr = string.valueOf(tempTaxRate);
				tempStr = tempStr.subString(1, tempStr.length());
				a.fullLineItemPriceTaxRate = tempStr; 
			}
			a.fullLineItemPriceTaxAmount = formatCurrencies(double.valueOf(x.Tax__c));
			a.taxcode = string.isnotblank(x.Tax_Code__c) ? x.Tax_Code__c : '';
			
			detailElementArray.add(a);
		}
		
		return detailElementArray;
	}
	
	public static List<WS_soa_SendOrderService_v2.allowanceChargeReocord_element> settingAllowanceCharge(){
		List<WS_soa_SendOrderService_v2.allowanceChargeReocord_element> allowanceElementArray = new  List <WS_soa_SendOrderService_v2.allowanceChargeReocord_element>();
		for(Allowance__c a : allowances){
			WS_soa_SendOrderService_v2.allowanceChargeReocord_element allowanceElement = new WS_soa_SendOrderService_v2.allowanceChargeReocord_element();
			allowanceElement.recordType='A';//always A
			allowanceElement.sequenceNumber  =returnSequenceNumber(ord);
			allowanceElement.lineNumber = setLineNumber();
			allowanceElement.allowanceCode = a.Allowance_Code__c;
			allowanceElement.allowanceAmount = formatCurrenciesDecimal(a.Allowance_Amount__c);
			if (a.VW_Loyalty_Coupon_Code__c != null) {
				allowanceElement.allowanceCouponNo = a.VW_Loyalty_Coupon_Code__c;
			} else {
				allowanceElement.allowanceCouponNo = a.Allowance_Coupon__c;
			}
			allowanceElement.allowanceCouponNo = a.Allowance_Coupon__c;
			allowanceElement.allowanceRedemptionCode = 'C';//always C until determine could be R too
			allowanceElement.specialAllowanceCodeDescription = a.Spl_Allowance_Code_Descr__c;//20 string
			allowanceElementArray.add(allowanceElement);
		}
		return allowanceElementArray;
	}
	
	public static List<WS_soa_SendOrderService_v2.batchCountRecord_element> settingBatchCount(){
		List<WS_soa_SendOrderService_v2.batchCountRecord_element> batchElementArray = new  List <WS_soa_SendOrderService_v2.batchCountRecord_element>();
		WS_soa_SendOrderService_v2.batchCountRecord_element b = new WS_soa_SendOrderService_v2.batchCountRecord_element();
		b.recordType = 'X';
		batchElementArray.add(b);
		return batchElementArray;
	}
	
	public static WS_soa_SendOrderService_v2.commentRecord_element initComment(string lineNum, string inputComment){
		WS_soa_SendOrderService_v2.commentRecord_element a = new WS_soa_SendOrderService_v2.commentRecord_element();
		a.recordType='C';//ALWAYS C
		a.commentType=' ';//initialize as blank
		a.sequenceNumber = returnSequenceNumber(ord);
		a.lineNumber =lineNum;
		a.comment = inputComment;
		return a;
	}
	
	public static List<WS_soa_SendOrderService_v2.commentRecord_element> settingComment(){
		List<WS_soa_SendOrderService_v2.commentRecord_element> commList = new List<WS_soa_SendOrderService_v2.commentRecord_element>();
		//if (ord.Pull_Order__c){
			if (ord.Pull_Order_Reason__c!=null){
				commList.add( initComment(setLineNumber(),ord.Pull_Order_Reason__c));
			}	
			/* JMK-PullOrder Changes
			if (ord.No_Invoice__c){
				commList.add( initComment(setLineNumber(),'Do not include invoice '));
			}
			if (ord.No_Substitutes__c){
				commList.add(initComment( setLineNumber(), 'NO SUBSTITUTES'));
			}
			if (ord.No_Peanuts__c){
				commList.add(initComment( setLineNumber(), 'NO PEANUTS'));
			}
			*/
			/*DE567
			if (ord.Ship_Complete__c){
				commList.add(initComment( setLineNumber() ,'SHIP COMPLETE THE ORDER'));
			}
			*/
			// JMK-PullOrder Changes
			// Gather the selected items from the Multiselect and the additional comments
			String strPullOrderOtherComments = ord.Pull_Order_Reason_Other__c;
			String strPullOrderMultiReasons = ord.Pull_Order_Reason_Multi__c;
			System.debug('pull order multi reason: ' + strPullOrderMultiReasons);
			if (strPullOrderMultiReasons != null){
				List<String> lStr = strPullOrderMultiReasons.split(';');
				for (String s : lStr){
					if (s != 'Other'){ // Don't insert Other since we'll have a comment.
						WS_soa_SendOrderService_V2.commentRecord_element c = initComment(setLineNumber(), s);
						c.commentType = 'P';
						commList.add(c);
					}
				}
			}
			if(strPullOrderOtherComments != null){
				integer curPos = 0;
				integer maxPos = 0;
				while (strPullOrderOtherComments.length() > maxPos){
					maxPos = strPullOrderOtherComments.length() < maxPos + 30 ? strPullOrderOtherCOmments.length() : maxPos + 30;
					WS_soa_SendOrderService_V2.commentRecord_element c = initComment(setLineNumber(), strPullOrderOtherComments.substring(curPos, maxPos));
					c.commentType = 'P';
					commList.add(c);
					curPos = maxPos;
				}
			}
			// JMK-PullOrder Changes end
			if (ord.Comments__c!=null){
				// before breaking the comment up, scrub out new lines
				if (ord.Comments__c.contains('\n')){
					ord.Comments__c = ord.Comments__c.remove('\n');
				}
				if (ord.Comments__c.contains('\r')){
					ord.Comments__c = ord.Comments__c.remove('\r');
				}
				integer currentPosition=0;
				integer maxPosition = 0;
				while (ord.Comments__c.length() > maxPosition){
					maxPosition = ord.Comments__c.length()<maxPosition+30? ord.Comments__c.length(): maxPosition+30;
					commList.add(initComment( setLineNumber() , ord.Comments__c.substring(currentPosition,maxPosition)));
					currentPosition = maxPosition; 
				}
			}
	//	}
		
		
		for(Order_Line_Items__c x : olis){
			if (x.Comments__c!=null){
				// before breaking the comment up, scrub out the new lines
				if (x.Comments__c.Contains('\n')){
					x.Comments__c.remove('\n');
				}
				if (x.Comments__c.Contains('\r')){
					x.Comments__c.remove('\r');
				}
				integer tempLineNum = integer.valueOf(x.Line_Number__c)+2;
				tempLineNum = (tempLineNum*10)+1;
				integer currentPosition = 0;
				integer maxPosition = 0;
				while (x.Comments__c.length() > maxPosition){
					maxPosition = x.Comments__c.length() < maxPosition + 30 ? x.Comments__c.length(): maxPosition + 30;
					commList.add(initComment( string.valueOf(tempLineNum++) , x.Comments__c.subString(currentPosition, maxPosition)));
					currentPosition = maxPosition;	
				}
			}
		}
		return commList;
	}
	
	public static WS_soa_SendOrderService_v2.miscellaneousChargeRecord_element settingMiscCharge(){
		if (ord.Misc_Charge_Amount__c!=0 && ord.Misc_Charge_Amount__c!=null){
			WS_soa_SendOrderService_v2.miscellaneousChargeRecord_element miscellaneousChargeElement = new WS_soa_SendOrderService_v2.miscellaneousChargeRecord_element();
			miscellaneousChargeElement.recordType = 'M';
			miscellaneousChargeElement.sequenceNumber = returnSequenceNumber(ord);
			miscellaneousChargeElement.lineNumber =setLineNumber();
			miscellaneousChargeElement.chargeCode = ord.Misc_Charge_Code__c;
			miscellaneousChargeElement.chargeAmount = formatCurrenciesDecimal(ord.Misc_Charge_Amount__c);
			return miscellaneousChargeElement;
		}
		else return null;
	}
	
	/* NOT USED THESE ARE UK ELEMENTS
	public static List<WS_soa_SendOrderService_v2.discountRecord_element> settingDiscount(){
		List<WS_soa_SendOrderService_v2.discountRecord_element> discountElementArray = new  List <WS_soa_SendOrderService_v2.discountRecord_element>();
		for(Order_Line_Items__c x : olis){
			WS_soa_SendOrderService_v2.discountRecord_element a = new WS_soa_SendOrderService_v2.discountRecord_element();
			a.sequenceNumber = ord.Sequence_Number__c;
			a.lineNumber = x.Line_Number__c;
			a.itemNumber = x.Product_Number__c.substring(2,6);
			a.quantity = String.valueOf(x.Product_Quantity__c);
			discountElementArray.add(a);
		}
		return discountElementArray;
	}
	
	public static List<WS_soa_SendOrderService_v2.extendedRecord_element> settingExtended(){
		List<WS_soa_SendOrderService_v2.extendedRecord_element> extendedList = new  List <WS_soa_SendOrderService_v2.extendedRecord_element>();
		for(Order_Line_Items__c x : olis){
			WS_soa_SendOrderService_v2.extendedRecord_element a = new WS_soa_SendOrderService_v2.extendedRecord_element();
			a.sequenceNumber = ord.Sequence_Number__c;
			a.lineNumber = x.Line_Number__c;
			a.itemNumber = x.Product_Number__c.substring(2,6);
			a.quantity = String.valueOf(x.Product_Quantity__c);
			a.discountSequenceNumber = '';
			a.recordType = '';
			a.detailLineLink = '';
			extendedList.add(a); 
		}
		
		return extendedList;
	}*/
	
	public static WS_soa_SendOrderService_v2.paymentRecord_element settingPayment(){
		WS_soa_SendOrderService_v2.paymentRecord_element paymentElement = new WS_soa_SendOrderService_v2.paymentRecord_element();
		paymentElement.recordType = 'P';
		paymentElement.sequenceNumber = returnSequenceNumber(ord);
		paymentElement.lineNumber = '11';//always 11
		paymentElement.profileID = ord.Payment_Profile_ID__c;
		paymentElement.transactionReferenceNumber=ord.Payment_Transaction_Reference_Number__c;
		paymentElement.transactionRefIndex = ord.Payment_Transaction_Reference_Index__c;
		paymentElement.authorizationAmount =  formatCurrencies(ord.Payment_Type__c=='Credit Card'? ord.authorization_amount__c: ord.Order_Total__c);
		paymentElement.bankResponseDateTime = string.valueOf(ord.Bank_Response_Date_Time__c);
		paymentElement.authCode = ord.Payment_Authorization_Code__c;
		system.debug(LoggingLevel.info, 'paymentElement~~~'+paymentElement);
		if(ord.Replacement_Order__c){
			return null;
		}else{
			return paymentElement;
		}
		
	}
	

}