/* OrderWizard_Wrapper 
*  Wrapper class for Order wizard.
*  2014-01-10:  Made selectedpaymentType default to Credit Card or to Existing Card/ Pavan Jasthi
*/
	
public class OrderWizard_Wrapper {

	public Address__c shippingAddress {get;set;}
	public Address__c billingAddress {get;set;}
	public Orders__c newOrder {get;set;}
	public List<Order_Line_Items__c> selectedOrderLineItems {get; set;}
	public List<SelectOption> shippingAddressList {get;set;}
	public List<SelectOption> billingAddressList {get;set;}
	public Map<Id, Address__c> CustomerAddressesMap {get; set;} 
	public List<SelectOption> methodList {get;set;}
	public List<SelectOption> ccTypeList {get;set;}
	public List<SelectOption> paymentTypeList {get;set;}
	public List<SelectOption> AddressTypeList {get;set;}
	public List<SelectOption> categoryList {get;set;}
	public List<SelectOption> ShippingCountryList {get;set;}
	public List<SelectOption> BillingCountryList {get;set;}
	public List<SelectOption> catalogCodeList {get;set;}
	public string selectedShippingAddress {get;set;}
	public string selectedBillingAddress {get;set;}
	public string selectedccExpiry {get;set;}
	public string selectedccType {get;set;}
	public string selectedpaymentType {get;set;}
	public string selectedAddressType {get;set;}
	public String selectedCategory {get; set;}
	public String selectedPromotions {get; set;}
	public String selectedCatalog {get;set;}
	public Boolean CreateOrderSelected {get;set;}
	public Boolean CheckoutSelected {get;set;}   
	public Boolean UseShipAsBill {get; set;}
	public String ProductSearchString {get; set;}
	public String QuickEntryString {get; set;}
	public String PromotionsString {get; set;}
	public String couponCode {get;set;}
	public String sourceCode {get;set;}
	public Integer TotalLineItems {get; set;}
	public Decimal PreTaxTotal {get; set;}
	public Decimal Discount {get; set;}
	public Decimal couponDiscount = 0.00;
	public Decimal ShippingDiscount {get; set;}
	public Decimal SubTotal {get; set;}
	public Decimal ShippingCharges {get; set;} 
	public Decimal Tax {get; set;}
	public Decimal Total {get; set;}
	public WS_webstack_PromotionObjects_v2.ApplyPromotionResponse promoResponse {get;set;}
	public WS_soa_AuthorizePaymentService.PaymentInfo paymentInfo {get;set;} 
	public WS_soa_AuthorizePaymentService.PaymentResponse paymentResponse {get;set;}
	public WS_soa_AuthorizePaymentService.PaymentReversalResponse reversalResponse {get;set;}
	//LD:START:- CreditsApplied....
	public decimal CustomerCreditAvailable {get;set;}
	public boolean CreditApplied {get; set;}
	public decimal TotalCreditApplied{get;set;}
	public boolean isPaymentProfile{get;set;}
	public boolean bRenderExistingCC{get;set;}
	public string paymentProfileid{get;set;}
	public List<PaymentProfile> lstPaymentTokens {get; set;}
	//LD:- CreditsApplied
	public decimal OldCreditApplied{get; set;}
	// DE574 free shipping with weborders is undoing if it's expired when editing the order.
	public boolean hadFreeShipping {get;set;}
	public decimal freeShippingValue {get; set;}
 
// Flag failed callout to Avalara
public boolean AvalaraCalloutFailed;

	public OrderWizard_Wrapper(Orders__c orderObj){
		/*Called when editing or cloning all orders*/
		System.debug('------------------------------Entering Order Wizard Wrapper');
		newOrder = orderObj;
		isPaymentProfile = false;
		if(orderObj.customer__r.Payment_Profile_Id__c != null)
		{
			isPaymentProfile = true;
			paymentProfileid = orderObj.customer__r.Payment_Profile_Id__c;
		}
	
		initWrapper();
		processAddresses(orderObj.customer__c);
		selectedBillingAddress=orderObj.Bill_To_Address__c==null?billingAddress.id:orderObj.Bill_To_Address__c;
		selectedShippingAddress=orderObj.Ship_To_Address__c==null?shippingAddress.id:orderObj.Ship_To_Address__c;
		//selectedpaymentType = orderObj.payment_type__c ;
		if(selectedpaymentType == null)
			selectedpaymentType =  orderObj.payment_type__c == null ? 'Credit Card' : orderObj.payment_type__c ;
		queryOrderLines();
		
	}
/*
	public OrderWizard_Wrapper(Account customer)
	{	  
		initWrapper();
		processAddresses(customer.id);
				
		newOrder = new Orders__c(Customer__c =customer.id, No_Peanuts__c=customer.No_Peanuts__c,No_Substitutes__c=!customer.Substitutes__c, No_Invoice__c=customer.No_Invoices__c, ship_complete__c = customer.Ship_Complete__c );
		selectedOrderLineItems = new List<Order_Line_Items__c>();   
					
	}   */ 
	
	public void queryOrderLines(){
		selectedOrderLineItems = new List<Order_Line_Items__c>();   
		for (Order_Line_Items__c oli:   [SELECT Id,SKU_Number__c, Name,Tax_Code__c, Comments__c, Substituted_Item__c, Product_Name__r.Product_Number__c, Product_Name__c,Product_Name__r.Product_Image_URL__c ,Product_Name__r.Available_Inventory__c,Product_Name__r.Sale_Offer__c , Product_Name__r.Name, Product_Quantity__c, Original_Quantity__c, Product_Number__c, Price_Override__c, Override_Reason__c, Unit_Price__c, Final_Price__c, Tax__c  FROM Order_Line_Items__c WHERE order__c=:newOrder.id ORDER BY CreatedDate desc]){
			selectedOrderLineItems.add(oli);
		}
	}
	
	public void initWrapper(){
		// Set Boolean variables to false
		OldCreditApplied = 0.00;
		CustomerCreditAvailable = 0.00;
		CreateOrderSelected = false;	
		CheckoutSelected = false;   
		UseShipAsBill = false;  
		CreditApplied = false;
		hadFreeShipping = false;
		AvalaraCalloutFailed = false;
		ShippingDiscount=newOrder.Discount__c;
		
		selectedccExpiry = string.isblank(neworder.Credit_Card_Expiration_Date__c)?'':neworder.Credit_Card_Expiration_Date__c;
		System.debug('discount on order: ' + newOrder.Discount__c);
		List<Allowance__c> allowances = [SELECT Allowance_Amount__c, Order__c, Allowance_Code__c from Allowance__c where Order__c =: newOrder.Id];
		// DE574 -- Allowances have not yet been deleted
		Decimal amountOfAllowances = 0.00;
		Decimal amountOfFreeShipping = 0.00;
		freeShippingValue = 0;
		if (allowances != null) {
			for (Allowance__c a : allowances) {
				amountOfAllowances += a.Allowance_Amount__c;
				if (a.Allowance_Code__c == '69') {
					amountOfFreeShipping = a.Allowance_Amount__c;
					hadFreeShipping = true;
					freeShippingValue += a.Allowance_Amount__c;
				}
			}
		}
		System.debug('amountOfAllowances: ' + amountOfAllowances);
		System.debug('amountOfFreeShipping: ' + amountOfFreeShipping);
		// End DE574 
		
		System.debug('maches code: ' + Pattern.matches('^[ABCEGHJKLMNPRSTVXY]{1}\\d{1}[A-Z]{1} *\\d{1}[A-Z]{1}\\d{1}$','A0A 0A0'));
		Discount = 0;
		Tax = newOrder.tax__c;
		TotalCreditApplied = 0.00;
		System.debug('----------------------------------->>>> ' + newOrder);
		if (newOrder.Credit_Amount_Applied__c != null && newOrder.Credit_Amount_Applied__c != 0.00) {
			OldCreditApplied = newOrder.Credit_Amount_Applied__c;
			CustomerCreditAvailable += newOrder.Credit_Amount_Applied__c;
		} else{
			OldCreditApplied = 0.00;
		}
		sourceCode=newOrder.source_code__c;
		selectedCatalog= newOrder.catalog_source_code__c==null? 'Current' : newOrder.catalog_source_code__c;
		if (newOrder.Promotions__c !=null) couponCode = newOrder.Promotions__r.name;

		catalogCodeList = new List <SelectOption>();
		catalogCodeList.add(new SelectOption('Current', 'Current'));
		for (Promotion__c p: [select name from promotion__c where promo_type__c ='SourceCode']){
			catalogCodeList.add(new SelectOption(p.name,p.name));
		}
		
		
		methodList = new List <SelectOption>();
		
		for (Schema.PicklistEntry p : Schema.SObjectType.Orders__c.fields.getMap().get('Shipping_Method__c').getDescribe().getPicklistValues()) {
			methodList.add(new SelectOption(p.getLabel(), p.getValue()));
		}
		
		ccTypeList = new List <SelectOption>();
		//ccTypeList.add(new SelectOption ('Sample CC Type', 'Sample CC Type'));	
		for (Schema.PicklistEntry p : Schema.SObjectType.Orders__c.fields.getMap().get('Credit_Card_Type__c').getDescribe().getPicklistValues()) {
			ccTypeList.add(new SelectOption(p.getLabel(), p.getValue()));
		}
		
		paymentTypeList = new List <SelectOption>();
		//ccTypeList.add(new SelectOption ('Sample CC Type', 'Sample CC Type'));	
		if (newOrder.Credit_Card_Token__c!=null) {
			paymentTypeList.add(new SelectOption('Existing Card', 'Previously Authorized Card'));
			bRenderExistingCC = false;
			selectedpaymentType = 'Existing Card';  // When Checkout page loads, this picklist will be loaded with this value
			
		}
		
		for (Schema.PicklistEntry p : Schema.SObjectType.Orders__c.fields.getMap().get('Payment_Type__c').getDescribe().getPicklistValues()) {
			paymentTypeList.add(new SelectOption(p.getLabel(), p.getValue()));
		}
		if(isPaymentProfile && newOrder.Credit_Card_Token__c==null && AuthDownTimeUtils.checkDownTimeStatus()) //New orders only with no token
		{
			try{
			// Pull all credit cards for the user
				WS_SOA_Payment_Services.BasicHttpBinding_ITwoWayAsyncQSPort getAllCards = new WS_SOA_Payment_Services.BasicHttpBinding_ITwoWayAsyncQSPort();
				WS_SOA_Payment_DS_V2.SFSearchPaymentProfileByProfileIDResponse_element response_x = getAllCards.SFSearchPaymentProfileByProfileID(paymentProfileid);
				lstPaymentTokens = new list<PaymentProfile>();
				system.debug('~~~' + paymentProfileid);
				if(response_x.Tokens != null)
				{
					// only show if there are any existing tokens
					paymentTypeList.add(new SelectOption('Stored Cards', 'Stored Cards'));
					lstPaymentTokens = WS_soa_AuthorizePaymentService.getAllPaymentProfieList(response_x.tokens);
					selectedpaymentType = 'Stored Cards'; // When Checkout page loads, this picklist will be loaded with this value
				}
				system.debug('~~~ Total Size' + lstPaymentTokens.size());
				if(lstPaymentTokens.size() > 0)bRenderExistingCC = true;
			}catch(exception e){
				
			}
		}
		
		
		categoryList = new List <SelectOption>();
		categoryList.add(new SelectOption ('Sample Category', 'Sample Category'));  
		
		BillingCountryList = new List <SelectOption>();
		for (Schema.PicklistEntry p : Schema.SObjectType.Address__c.fields.getMap().get('Country_Picklist__c').getDescribe().getPicklistValues())
		{
			BillingCountryList.add(new SelectOption(p.getLabel(), p.getValue()));
		}
		
		
		ShippingCountryList = new List<SelectOption>();
		ShippingCountryList.add(new SelectOption ('UNITED STATES', 'UNITED STATES'));   
		
		List<SelectOption> TempCountryList = new List<SelectOption>();
		
		for(Country_Code_Mapping__c CCM : Country_Code_Mapping__c.getAll().values())
		{
			if(!CCM.Name.containsOnly('0123456789') && CCM.Shipping_Allowed__c && CCM.Name != 'UNITED STATES')
			{
				TempCountryList.add(new SelectOption(CCM.Name, CCM.Name));
			}		  
		}   
		TempCountryList.sort(); 
		
		ShippingCountryList.addALL(TempCountryList);			
	}
	
	public void processAddresses(Id CustomerId)
	{
		shippingAddress = new Address__c();
		billingAddress = new Address__c();
		CustomerAddressesMap = new Map<Id, Address__c>();
		
		AddressTypeList = new List <SelectOption>();
		AddressTypeList.add(new SelectOption ('Residential', 'Residential'));   
		AddressTypeList.add(new SelectOption ('Commercial', 'Commercial'));
		
		billingAddressList = new List <SelectOption>();
		billingAddressList.add(new SelectOption ('-- Add New Address --', '-- Add New Address --'));
		
		shippingAddressList = new List <SelectOption>();
		shippingAddressList.add(new SelectOption ('-- Add New Address --', '-- Add New Address --'));
		
		for(Address__c AddrRec : [SELECT Id, Address_Line_1__c, Address_Line_2__c, Address_Line_3__c, Address_Line_4__c, Address_Type__c, City__c, Country__c, State_Providence__c, Residential_Commercial__c,Foreign_Country_Code__c,
										 Zip_Code__c, Primary_Ship_to_Address__c, Primary_Bill_To_Address__c, Validated__c, Validation_Error_Reason__c, Validation_Override__c, Country_Picklist__c, Foreign_Postal_Code__c, International_Address__c
										 FROM Address__c 
										 WHERE Customer__c = :CustomerId])
		{
			if(AddrRec.Primary_Ship_to_Address__c && AddrRec.Primary_Bill_To_Address__c)
			{
				shippingAddress = billingAddress = AddrRec;		  
				selectedShippingAddress = selectedBillingAddress = AddrRec.Id;	
				UseShipAsBill = true;	  
			}
			else if(AddrRec.Primary_Ship_to_Address__c)
			{
				shippingAddress = AddrRec;
				selectedShippingAddress = AddrRec.Id;
			}
			else if(AddrRec.Primary_Bill_To_Address__c)
			{
				billingAddress = AddrRec;
				selectedBillingAddress = AddrRec.Id;
			}
			
			
			
			String FormattedAddress = FormatAddress(AddrRec);
			
			if(AddrRec.Address_Type__c != null && AddrRec.Address_Type__c != '')
			{
				if(AddrRec.Address_Type__c.contains('Billing'))
				{
					billingAddressList.add(new SelectOption (AddrRec.Id , FormattedAddress));
				}
				
				if(AddrRec.Address_Type__c.contains('Shipping'))
				{
					shippingAddressList.add(new SelectOption (AddrRec.Id , FormattedAddress));
				}   
			}			  
			CustomerAddressesMap.put(AddrRec.Id, AddrRec);
		}	  
	}
	
	public String FormatAddress(Address__c AddrRec)
	{
		String FormattedAddress = (AddrRec.Address_Line_1__c != null && AddrRec.Address_Line_1__c != '' ) ? AddrRec.Address_Line_1__c : '' ;
		FormattedAddress += (AddrRec.Address_Line_2__c != null && AddrRec.Address_Line_2__c != '' ) ? AddrRec.Address_Line_2__c : '' ;
		FormattedAddress += (AddrRec.Address_Line_3__c != null && AddrRec.Address_Line_3__c != '' ) ? AddrRec.Address_Line_3__c : '' ;
		FormattedAddress += (AddrRec.Address_Line_4__c != null && AddrRec.Address_Line_4__c != '' ) ? AddrRec.Address_Line_4__c : '' ;
		FormattedAddress += (AddrRec.City__c != null && AddrRec.City__c != '') ? ', ' + AddrRec.City__c : '' ;
		FormattedAddress += (AddrRec.State_Providence__c != null && AddrRec.State_Providence__c != '') ? ', ' + AddrRec.State_Providence__c : '' ;
		FormattedAddress += (AddrRec.Country_Picklist__c != null && AddrRec.Country_Picklist__c != '') ? ', ' + AddrRec.Country_Picklist__c : '' ;
		
		if(String.isNotBlank(AddrRec.Country_Picklist__c) && AddrRec.Country_Picklist__c == 'UNITED STATES')		
			FormattedAddress += (AddrRec.Zip_Code__c != null && AddrRec.Zip_Code__c != '') ? ', ' + AddrRec.Zip_Code__c : '' ;	
		else
			FormattedAddress += (AddrRec.Foreign_Postal_Code__c != null && AddrRec.Foreign_Postal_Code__c != '') ? ', ' + AddrRec.Foreign_Postal_Code__c : '' ;
			
		return FormattedAddress;
	}
	 
	 // DE528
	 public void UndoAppliedCredit(){
		if (newOrder.Credit_Amount_Applied__c != null && newOrder.Credit_Amount_Applied__c != 0.00){
			// put the customer's credit back
			Credit__c undoCredit = new Credit__c();
			undoCredit.Account__c = newOrder.Customer__c;
			undoCredit.Credit_Amount__c = OldCreditApplied * -1; //newOrder.Credit_Amount_Applied__c * -1; // when removing credit it's negative
			newOrder.Credit_Amount_Applied__c = 0.00;
			undoCredit.Credit_Notes__c = 'This credit is used in refunding credit amount' + undoCredit.Credit_Amount__c + ' because we are editing the record and we are returning the value';
		
			try {
				insert undoCredit;
				CustomerCreditAvailable = OldCreditApplied * -1;
			} catch(Exception e) {
				System.debug('Error inserting credit in UndoAppliedCredit: ' + e.getMessage());
			}
		}
	}
	
	public string getCreditCardForType(integer cardId) {
		return NBTYUtils.getCCTypeMappings('Gateway').get(string.valueOf(cardId)).Name;
	}
	
	public class PaymentProfile{
		public string TokenId{get; set;}
		public string cardSerial{get; set;}
		public string name{get; set;}
		public string creditcardType{get; set;}
		public string creditcardExpiry{get; set;}
		public string Address{get; set;}
		public string Addressline1{get; set;}
		public string Addressline2{get; set;}
		public string city{get; set;}
		public string state{get; set;}
		public string zip{get; set;}
		public string details{get; set;}
		public PaymentProfile() {
			TokenId = '';
			name = '';
			creditcardType = '';
			creditcardExpiry = '';
			Address = '';
			Addressline1 = '';
			Addressline2 = '';
			city = '';
			state = '';
			zip = '';
			details = '';
			cardSerial = '';
			
		 }
	 }
}