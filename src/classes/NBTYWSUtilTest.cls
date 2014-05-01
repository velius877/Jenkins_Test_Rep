@isTest
 global class NBTYWSUtilTest {
 	public static void setupData(){
	StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
	mock.setStaticResource('jsonProduct');
	mock.setStatusCode(200);
	mock.setHeader('Content-Type', 'application/octet-stream');
	// Set the mock callout mode
	Test.setMock(HttpCalloutMock.class, mock);
	// Call the method that performs the callout
	
	for(integer i=0; i< 12; i++)
	{
		Item__C tempItem = new Item__C();
		tempItem.Name = string.valueof(i) + 'TestItem';
		tempItem.Product_Number__c = string.valueof(i);
		tempItem.Product_Suffix__c = '0011';
		insert tempItem;
		
		
	}
 	}
 	
	static testMethod void testU2PAccount() {
		testDataSetupUtil.processWsIntData();	
		setupData();
		ProductRank.NBTYproduct alist = new ProductRank.NBTYproduct();
		Test.startTest();
		List<Item__C> productList = new List<Item__c>(); 
		productList = NBTYWSUtil.getU2PAgileOneProductsByAccountID('123','24');
		// Verify response received contains values returned by
		// the mock response.
		/*System.assertEquals(10, productList.size()); 
		System.assertEquals('1', productList[0].Product_Number__c);
		System.assertEquals('2', productList[1].Product_Number__c);
		System.assertEquals('3', productList[2].Product_Number__c);
		System.assertNotEquals('5', productList[3].Product_Number__c); // Test for sorted result*/
		
		productList = NBTYWSUtil.getP2PAgileOneProducts('0011-0011','24');
		// Verify response received contains values returned by
		// the mock response.
		/*System.assertEquals(10, productList.size());
		System.assertEquals('1', productList[0].Product_Number__c);
		System.assertEquals('2', productList[1].Product_Number__c);
		System.assertEquals('3', productList[2].Product_Number__c);
		System.assertNotEquals('5', productList[3].Product_Number__c); // Test for sorted result  */
		Test.stoptest();
		}
		
				
	static testMethod void testAvaTaxAccount() {
		testDataSetupUtil.SetupCoreData(3);
		testDataSetupUtil.acct.payment_profile_id__c = null;
		update testDataSetupUtil.acct;
		StaticResourceCalloutMock mock2 = new StaticResourceCalloutMock();
		mock2.setStaticResource('AvalaraTax');
		mock2.setStatusCode(200);
		mock2.setHeader('Content-Type', 'text/xml');
		// Set the mock callout mode
			Test.setMock(HttpCalloutMock.class, mock2);
		// Call the method that performs the callout 
		
		TaxSvc.GetTaxResult tGetTaxResult = new TaxSvc.GetTaxResult();
		TaxSvc.AuditMessage tam = new TaxSvc.AuditMessage();
		Taxsvc.TaxAddress tadd = new Taxsvc.TaxAddress();
		Taxsvc.ArrayofMessage taa = new Taxsvc.ArrayOfMessage();
		Taxsvc.TaxOverride tao = new Taxsvc.TaxOverride();
		Taxsvc.ArrayOfTaxDetail ta1 = new Taxsvc.ArrayOfTaxDetail();
		Taxsvc.ArrayOfTaxAddress ta2 = new Taxsvc.ArrayOfTaxAddress();
		Taxsvc.TaxDetail td = new Taxsvc.TaxDetail();
		Taxsvc.Message tm = new Taxsvc.Message();
		Taxsvc.TaxLine tl = new Taxsvc.TaxLine();
		Taxsvc.ArrayOfTaxLine tat1 = new Taxsvc.ArrayOfTaxLine();
		Taxsvc.ArrayOfGetTaxResult tagt1 = new Taxsvc.ArrayOfGetTaxResult();
		Test.startTest();
	 
		system.debug('XX' +  testDataSetupUtil.order1);
		system.debug('XXY'+ [select country__c from Address__c where id =: testDataSetupUtil.order1.ship_to_address__c]);
		ApexPages.currentPage().getParameters().put('Id', testDataSetupUtil.order1.id);
  		ApexPages.StandardController sc = new ApexPages.StandardController(testDataSetupUtil.order1);
      	OrderWizard_NewOrder orderController = new OrderWizard_NewOrder(sc);
      	orderController.wrap = AvalaraTaxCalc.CalculateTax(orderController.wrap, false);
		Test.stoptest();
	
	}
	
	static testMethod void testBackupTax(){
		testDataSetupUtil.SetupCoreData(3);
		testDataSetupUtil.acct.payment_profile_id__c = null;
		update testDataSetupUtil.acct;
		testDataSetupUtil.addressList[0].zip_code__c = '22102';
		testDataSetupUtil.addressList[0].Address_Type__c = 'Billing;Shipping';
		testDataSetupUtil.addressList[0].State_Providence__c = 'IL';
		update testDataSetupUtil.addressList[0];
		Tax_Backup__c tb = new Tax_Backup__c(ZipCode__c='22102', taxRate__c=.5);
		insert tb;
		ws_integration__c ws = ws_integration__c.getValues('AvaTaxEndPoint');
		ws.value__c='junk';
		update ws;
		testDataSetupUtil.itemList[0].Taxable_Item__c=true;
		update testDataSetupUtil.itemList[0];
		testDataSetupUtil.order1.ship_to_address__c=testDataSetupUtil.addressList[0].id;
		update testDataSetupUtil.order1;
		test.startTest();
		ApexPages.currentPage().getParameters().put('Id', testDataSetupUtil.order1.id);
  		ApexPages.StandardController sc = new ApexPages.StandardController(testDataSetupUtil.order1);
      	OrderWizard_NewOrder orderController = new OrderWizard_NewOrder(sc);
		orderController.wrap = AvalaraTaxCalc.CalculateTax(orderController.wrap, false);
		test.stopTest();
		system.assert(orderController.wrap.tax>0);
		
	}
}