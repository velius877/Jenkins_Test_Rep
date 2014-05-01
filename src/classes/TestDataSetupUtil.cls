/* 
	TestDataSetupUtil
	Provide Methods for setting up basic repeatable data for test classes.
	------------------------------------------------------------------
	Author		  |   Date		|   Description
	------------------------------------------------------------------
	Gary Alfrey	 |   4/15/2013   |   Initial Creation
	Caleb Poitevien |   7/15/2013   |   Removal of Order data setupq

*/

public class TestDataSetupUtil {

/*~~~~~~~~~~~~~~~~~~~~~~~START STATIC VARIABLES ~~~~~~~~~~~~~~~~~~~~~~~~~~*/	

	public static Account acct;
	public static Account vwAcct;
	public static List<Item__c> itemList;
	public static List<Address__c> addressList;
	public static List<Account> accountList; 
	public static Orders__c order1;
	public static List<Order_Line_Items__c> oliList;
	public static Promotion__c promo;
	public static Order_Adjustment__c oa;
	public static List<WS_Integration__c> wsInts;
	public static List<Credit_Card_Type_Mapping__c> cctmList;
	//public static Order_Summary__c OSRec;
	
	//Prevent recursive calls
	private static boolean hasRun = false;
	public static boolean hasBeenRun(){ return hasRun;  }
	public static void setRun(){	hasRun = true;  }
	
/*~~~~~~~~~~~~~~~~~~~~~~~END STATIC VARIABLES ~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/


/********************START OF MAIN METHODS ****************************/	
	public static void SetupCoreData(integer numItems){
		//system.debug('START OF MAIN METHODS');
		processCrtBrandMapping();
		processCcMapping();
		acct = setupAccount();
		vwAcct = setupVWAcct();
		addressList=setupAddresses();
		createBadCustCS();
		itemList = setupItems(numItems);
		order1 = setupOrder();
		oliList = setupOli(numItems);
		processWsIntData();
		promo = setupPromo();
		//OSRec = setupOrderSummary();
		createCCTM();
	}
	
	public static void createCCTM() {
		Credit_Card_Type_Mapping__c cctm1 = new Credit_Card_Type_Mapping__c();
		cctm1.Name = 'American Express';
		cctm1.AS400_Value__c = 'AE';
		cctm1.Gateway_Value__c = '4';
		cctm1.Web_Value__c = 'A';
		Credit_Card_Type_Mapping__c cctm2 = new Credit_Card_Type_Mapping__c();
		cctm2.Name = 'Discover';
		cctm2.AS400_Value__c = 'DS';
		cctm2.Gateway_Value__c = '3';
		cctm2.Web_Value__c = 'D';
		Credit_Card_Type_Mapping__c cctm3 = new Credit_Card_Type_Mapping__c();
		cctm3.Name = 'MasterCard';
		cctm3.AS400_Value__c = 'MC';
		cctm3.Gateway_Value__c = '2';
		cctm3.Web_Value__c = 'M';
		Credit_Card_Type_Mapping__c cctm4 = new Credit_Card_Type_Mapping__c();
		cctm4.Name = 'Visa';
		cctm4.AS400_Value__c = 'VI';
		cctm4.Gateway_Value__c = '1';
		cctm4.Web_Value__c = 'V';
		Credit_Card_Type_Mapping__c cctm5 = new Credit_Card_Type_Mapping__c();
		cctm5.Name = 'JCB';
		cctm5.AS400_Value__c = 'JB';
		cctm5.Gateway_Value__c = '5';
		cctm5.Web_Value__c = 'J';
		cctmList = new List<Credit_Card_Type_Mapping__c>();
		cctmList.add(cctm1);
		cctmList.add(cctm2);
		cctmList.add(cctm3);
		cctmList.add(cctm4);
		cctmList.add(cctm5);
		insert cctmList;
	}
	
	public static void createBadCustCS() {
		WS_Integration__c bc = new WS_Integration__c();
		bc.Name = 'BadCustOff';
		bc.Value__c = 'false';
		insert bc;
	}
	
	public static List<Address__c> setupAddresses() {
		addressList = new List<Address__c>();
		for (Account ac: accountList) {
			addressList.add(AccountSyncAddresses_Helper.generateAddressRecord(ac, ac.ShippingStreet != null, ac.BillingStreet != null, true ));
		}
		system.debug(addressList);
		addressList[0].country_picklist__c = 'UNITED STATES';
		addressList[0].Primary_Ship_to_Address__c = true;
		addressList[0].Address_Type__c = 'Shipping';
		
		addressList[1].country_picklist__c = 'JAPAN';
		addressList[1].Primary_Bill_To_Address__c = true;
		addressList[1].Address_Type__c = 'Billing';
		insert addressList;
		return addressList;
	}
	
	public static void processCrtBrandMapping(){
			
			StaticResource wsIntVals = [Select  s.Name, s.Id, s.Body From StaticResource s where s.Name = 'custRecTypeBrandMapping'];
		Map<String, Customer_Rec_Type_Brand_Mapping__c> wsMap = new Map <String, Customer_Rec_Type_Brand_Mapping__c>();
		
		blob tempA = wsIntVals.Body;
		String messageString = tempA.toString();
		String[] filelinesMessages = messageString.split('\n');
		List<Customer_Rec_Type_Brand_Mapping__c> defaultCRTBMapping = new List<Customer_Rec_Type_Brand_Mapping__c>();
		for (Integer i=1;i<filelinesMessages.size();i++) {
			Customer_Rec_Type_Brand_Mapping__c temp = new Customer_Rec_Type_Brand_Mapping__c();
			String[] inputvalues = filelinesMessages[i].split(',');
			temp.NAME = inputvalues[0];
			temp.PRODUCT_SUFFIX_C__C = inputvalues[1];
			temp.COMPANY_CODE__C = inputvalues[2];
			temp.MERCHANT_KEY__C = inputvalues[3];
			temp.PICKLIST_BRAND__C = inputvalues[4];
			temp.RECORDTYPENAME__C = inputvalues[5];
			temp.SERVER_PREFIX__C = inputvalues[6];
			temp.STATIC_IMAGE_URL__C = inputvalues[7];
			temp.TENANTID__C = inputvalues[8];
			temp.US_ONLY__C = BOOLEAN.VALUEOF(inputvalues[9]);
			temp.WS_ID__C = inputvalues[10]; 
			temp.BRAND_IMAGE__C = inputvalues[11];
			temp.BACK_OFFICE_QUEUE__C = inputvalues[12];
			temp.Taxable_States__c='NY;NC;ND;IL';
			defaultCRTBMapping.add(temp);
		}
		if (!defaultCRTBMapping.isEmpty()) {
			insert defaultCRTBMapping;
		}
	}
	
	public static void processCcMapping(){
		StaticResource wsIntVals = [Select  s.Name, s.Id, s.Body From StaticResource s where s.Name = 'countryCodeMapping'];
		Map<String, Country_Code_Mapping__c> wsMap = new Map <String, Country_Code_Mapping__c>();
		
		blob tempA = wsIntVals.Body;
		String messageString = tempA.toString();
		String[] filelinesMessages = messageString.split('\n');
		List<Country_Code_Mapping__c> defaultCCMapping = new List<Country_Code_Mapping__c>();
		for (Integer i=1;i<filelinesMessages.size();i++){
			Country_Code_Mapping__c temp = new Country_Code_Mapping__c();
			String[] inputvalues = filelinesMessages[i].split(',');
			temp.Name = inputvalues[0];
			temp.abbreviation__c=inputvalues[1];
			temp.Name__c=inputvalues[2];
			temp.Restriction_Text__c=inputValues[3];
			temp.Code__c =inputvalues[4];
			temp.Shipping_Allowed__c = Boolean.valueOf(inputvalues[5]);
			system.debug('temp~~~'+temp);
			defaultCCMapping.add(temp);
		}
		if (!defaultCCMapping.isEmpty()){
			insert defaultCCMapping;
		}
	}
	
	
	public static void processWsIntData(){
		
		StaticResource wsIntVals = [Select  s.Name, s.Id, s.Body From StaticResource s where s.Name = 'wsIntegration'];
		
		Map<String, WS_Integration__c> wsMap = new Map <String, WS_Integration__c>();
		
		blob tempA = wsIntVals.Body;
		String messageString = tempA.toString();
		
		
		String[] filelinesMessages = messageString.split('\n');
		List<WS_Integration__c> defaultWsInt = new List<WS_Integration__c>();
		for (Integer i=0;i<filelinesMessages.size();i++){
			WS_Integration__c temp = new WS_Integration__c();
			String[] inputvalues = filelinesMessages[i].split(',');
			temp.Name = inputvalues[0];
			temp.Value__c =inputvalues[1];
			
			defaultWsInt.add(temp);
		}
		
		if (!defaultWsInt.isEmpty()){
			try {
				insert defaultWsInt;
			} catch(Exception ex) {
				
			}
		}
	}
	
	public static Account setupAccount(){
		RecordType recType = [SELECT Id FROM RecordType WHERE DeveloperName = 'Puritans_Pride_Customer' AND sObjectType = 'Account' AND IsActive = true];
		accountList = new List<Account>();
		Account acct1 = new Account();
		acct1.RecordTypeId = recType.Id; 
		acct1.Salutation = 'Mr.';
		acct1.FirstName = 'Jane';
		acct1.LastName = 'Doe';
		acct1.AS_400_Customer_Number__c = '12345';
		acct1.PersonEmail = 'jDoe@test.com';
		acct1.ShippingStreet = '1660 Inter Dr';
		acct1.ShippingCity  = 'McLean';
		acct1.ShippingState  = 'VA'; 
		acct1.ShippingCountry = 'USA';
		acct1.ShippingPostalCode	= '22102';
		acct1.Payment_Profile_Id__c = 'testPaymentProfile';
		accountList.add( acct1 );
		
		Account acct2 = new Account();
		acct2.RecordTypeId = recType.Id; 
		acct2.Salutation = 'Mr.';
		acct2.FirstName = 'Jane';
		acct2.LastName = 'Doe';
		acct2.AS_400_Customer_Number__c = '12345';
		acct2.PersonEmail = 'jDoe@test.com';
		acct2.BillingStreet = '2823 Nishi N';
		acct2.BillingCity   = 'Tokyo'; 
		acct2.BillingState   = '';
		acct2.BillingCountry	= 'JP';
		acct2.Payment_Profile_Id__c = 'testPaymentProfile';
		accountList.add( acct2 );
		
		upsert accountList;
		return acct1;
	}
	
	public static Account setupVWAcct(){
		RecordType recType = [SELECT Id FROM RecordType WHERE DeveloperName = 'Vitamin_World_Customer' AND sObjectType = 'Account' AND IsActive = true AND IsPersonType = true];
		Account acct1 = new Account();
		acct1.RecordTypeId = recType.Id; 
		acct1.Salutation = 'Mr.';
		acct1.FirstName = 'John';
		acct1.LastName = 'Doe';
		acct1.AS_400_Customer_Number__c = '987654321';
		acct1.PersonEmail = 'jDoe@test.com';
		acct1.Phone = '4195715968';
		acct1.Payment_Profile_Id__c = 'testpaymentprofile';
		acct1.ShippingStreet = '1660 Inter Dr';
		acct1.ShippingCity  = 'McLean';
		acct1.ShippingState  = 'VA'; 
		acct1.ShippingCountry = 'USA';
		acct1.ShippingPostalCode	= '22102';
		//TODO: add addressing fields SEE<setupAccount()>
		insert acct1;
		accountList.add(acct1);
		return acct1;
	}
	
	public static List<Item__c> setupItems(integer numItems){
		List<Item__c> items = new List<Item__c>();
		for (Integer i=0;i<numItems;i++) {
			Item__c item = new Item__c();
			Item__c item1 = new Item__c();
			item.Name = 'Test Product ' + string.valueOf(i);
			item.Available_Inventory__c='10';
			item.Brand_Name__c = 'Putitans Pride';
			item.Cube_Volume__c = '34.99';
			item.Is_Active__c = true;
			item.Product_Number__c = '00999' + string.valueOf(i);
			item.Product_Form__c = 'Capsules';
			item.Product_Size_Amount__c = '200';
			item.Product_Suffix__c = '0011';
			item.Rapid_Release__c = true;
			item.Sale_Price__c = 15.99 + i;
			item.UPC__c = '3216549870' + string.valueOf(i);
			item.Unit_Price__c = 15.99 + i;
			item.External_Key__c=item.Product_Suffix__c+item.Product_Number__c;
			items.add(item);
		}
		insert items;
		return items;
	}
	
	public static Orders__c setupOrder() {
		Orders__c orders = new Orders__c();
		orders.Customer__c = acct.Id;
		orders.Order_Date__c = date.today();
		orders.Order_Status__c = 'Open';
		orders.Sales_Channel__c = 'Phone';
		orders.Sequence_Number__c = '2166549802';
		orders.Webstack_Order_ID__c = '1234567890';
		orders.Ship_To_Address__c=addressList[0].id;
		orders.Bill_To_Address__c=addressList[0].id;
		orders.Authorization_Amount__c = 100.00;
		orders.Payment_Transaction_Reference_Number__c = '123456789';
		insert orders;
		return orders;
	}
	
	public static List<Order_Line_Items__c> setupOli(integer numItems){
		List<Order_Line_Items__c> olis = new List<Order_Line_Items__c>();
		for (Integer i=0;i<numItems;i++) {
			Order_Line_Items__c oli = new Order_Line_Items__c();
			oli.Product_Name__c = itemList[i].Id;
			oli.Order__c = order1.Id;
			oli.Product_Quantity__c = 10;
			oli.Line_Number__c=string.valueOf(i+1);
			oli.SKU_Number__c = itemList[i].Product_Number__c;
			oli.Final_Price__c=10.00;
			olis.add(oli);
		}
		insert olis;
		return olis;
	}
	

	public static Promotion__c setupPromo() {
		promo = new Promotion__c();
		promo.name ='blah';
		promo.Coupon_Status__c = 'Inactive';
		promo.Promo_TYPE__c='Coupon';
		promo.Start_Date__c = system.today().addDays(-3);
		promo.End_Date__c= system.today().addDays(-2);
		promo.Suffix__c='0011';
		
		insert promo;
		return promo;
	}
	
	public static String randStr(Integer len) {
		String strSet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
		String randomString = '';
		for (Integer i = 0; i < len; i++) {
			Integer rPos = (Integer)(Math.floor(Math.random() * strSet.length()));
			randomString += strSet.substring(rPos,rPos+1);
		}
		return randomString;
	}
	
	public static Order_Adjustment__c setupOrderAdjustment(string caseId, string orderId, string accId){
		Order_Adjustment__c orderAdj = new Order_Adjustment__c();
		RecordType recType = [SELECT Id FROM RecordType WHERE DeveloperName = 'Refund' AND sObjectType = 'Order_Adjustment__c' AND IsActive = true limit 1];
		orderAdj.RecordTypeId = recType.Id; // Default
		orderAdj.Status__c = 'Draft' ;
		orderAdj.refund_type__c='Full Refund';
		orderAdj.Related_Case__c = caseId;
		orderAdj.Related_Order__c = orderId;
		orderAdj.Refund_or_Misc_Amount__c = 0;
		orderAdj.Customer__c = accId;
		insert orderAdj ;
		return orderAdj ;
	}
	static testMethod void testTestDataSetupUtil(){
		testDataSetupUtil.SetupCoreData(2);
		String tmp = testDataSetupUtil.randStr(10);
		system.assertEquals(10, tmp.length());
		
	}
}