/************************************* MODIFICATION LOG ********************************************************************************
*
* DESCRIPTION : OrderSummaryTriggerHelperTest is a test class for OrderSummaryTriggerHelper
*
*---------------------------------------------------------------------------------------------------------------------------------------
* DEVELOPER						DATE				  REASON
*---------------------------------------------------------------------------------------------------------------------------------------
* Shivkant Vadlamani			04/15/2013			- Origininal Version
*
*													 
*/

@isTest
	//public static Order_Summary__c OSRec;
global class OrderSummaryTriggerHelperTest 
{
	static testMethod void testOrderSummaryKeyboardTranslation(){
		testDataSetupUtil.SetupCoreData(2);
		country_code_mapping__c ccm = country_Code_mapping__c.getValues('00135');//thailand
		ccm.keyboard_translation__c= true;
		update ccm;
		setupInboundOrderMapping();
		setupWebStoresData();
		test.startTest();
		Order_Summary__c os =setupOrderSummary_KeyboardTranslation();
		test.stopTest();
		system.assertEquals('Internal Review', [select order_status__c from Orders__c where webstack_order_id__c = :os.Webstack_Order_ID__c].order_status__c);
	}
	static testMethod void testOrderSummaryTriggerHelper() {
		testDataSetupUtil.SetupCoreData(2);
		WS_Integration__c turnOffBadCust = new WS_Integration__c();
		turnOffBadCust.Name = 'BadCustOff';
		turnOffBadCust.Value__c = 'true';
		insert turnOffBadCust;
		setupInboundOrderMapping();
		setupWebStoresData();
		List<Order_Summary__c> NewOrderSummaryRecords = new List<Order_Summary__c>();
		NewOrderSummaryRecords.add(setupOrderSummary());
		OrderSummaryTriggerHelper.ProcessOrderSummaryAfterInsert(NewOrderSummaryRecords);	
		Orders__c OrdGenerated = [SELECT Id, Webstack_Order_ID__c, Customer__c, 
									(Select Id From Order_Line_Items__r), Bill_To_Address__c, Ship_To_Address__c 
									FROM Orders__c 
									WHERE Webstack_Order_ID__c = :NewOrderSummaryRecords[0].Webstack_Order_ID__c limit 1];
		List<Address__c> AddressList = [SELECT City__c, Zip_Code__c 
										FROM Address__c 
										WHERE Id = :OrdGenerated.Bill_To_Address__c 
										OR Id = :OrdGenerated.Ship_To_Address__c ];
		test.startTest();
		System.assert( OrdGenerated.Id != null , 'This is a valid Order record');
		System.assert(OrdGenerated.Order_Line_Items__r.size() == 2, 'There should be 2 Order line items');
		System.assert( OrdGenerated.Bill_To_Address__c != null , 'This is NOT a valid Billing Address');
		System.assert( OrdGenerated.Ship_To_Address__c != null , 'This is NOT a valid Shipping Address');
		
		if (AddressList[0].Id == OrdGenerated.Bill_To_Address__c) {
			System.assert( AddressList[0].City__c == 'RAPPERSWIL' , 'This is NOT the correct City of Billing Address');	
		}
		
		if (AddressList[0].Id == OrdGenerated.Ship_To_Address__c) {
			System.assert( AddressList[0].City__c == 'NORTH PORT' , 'This is NOT the correct City of Shipping Address');
		}
		setupOrderSummary_SameCust();
		test.stopTest();
	}

		public static Order_Summary__c setupOrderSummary() {
		
		system.debug('setupOrderSummary()');
		Order_Summary__c OSRec1 = new Order_Summary__c();
		OSRec1.Allowance_Charge__c = 'A004888888800040690000495';
		OSRec1.Comment__c = 'C004888888800040enjoy your gifts bro';
		OSRec1.Detail__c = 'D004888888800030547900002000119900000000000000009990|#|D004888888800040276700001000089900000000000000009991';
		OSRec1.Done__c = '';
		OSRec1.Header__c = 'H0048888888000100000000000TIPPMSB V+++++++++++++++++0513MRSANDREA      FUST           HERRENBERG                    39                            RAPPERSWIL             FO000000000000000ARYThis is the reason for suspe  WEB SITE  S00000000000000000000                          00132                              0041555340227';
		OSRec1.Misc_Charge__c = 'M004888888800050800003201';
		OSRec1.Payment__c = 'P00488888880001139a6e574-5613-4a9d-8c72-bc5a8f367412042225                                  515310DBF8682FA1801828F9131D46EE266E53C30                                       0000156932013-03-27T11:31:39';
		OSRec1.Ship_To__c = 'S004888888800020MRSBONITA      GOLDMAN                                      PO BOX 7042                   NORTH PORT             FL34290ALIVEINTHEVI@HOTMAIL.COM                          495004    00031Control Room 119001           2222yabcdefghijklmnopqrs';
		OSRec1.Webstack_ID__c = '1';
		OSRec1.Webstack_Order_ID__c = '48888888';
		insert OSRec1;
		system.debug('Order_Summary__c: '+ OSRec1);
		return OSRec1;
	}
	
	public static Order_Summary__c setupOrderSummary_SameCust() {
		system.debug('setupOrderSummary()');
		Order_Summary__c OSRec1 = new Order_Summary__c();
		OSRec1.Allowance_Charge__c = 'A004888888900040690000495';
		OSRec1.Comment__c = 'C004888888900040enjoy your gifts bro';
		OSRec1.Detail__c = 'D004888888900030547900002000119900000000000000009990|#|D004888888900040276700001000089900000000000000009991';
		OSRec1.Done__c = '';
		OSRec1.Header__c = 'H0048888889000100000000000TIPPMSB V+++++++++++++++++0513MRSANDREA      FUST           HERRENBERG                    39                            RAPPERSWIL             FO000000000000000ARYThis is the reason for suspe  WEB SITE  S00000000000000000000                          00132                              0041555340227';
		OSRec1.Misc_Charge__c = 'M004888888900050800003201';
		OSRec1.Payment__c = 'P00488888890001139a6e574-5613-4a9d-8c72-bc5a8f367412042225                                  515310DBF8682FA1801828F9131D46EE266E53C30                                       0000156932013-03-27T11:31:39';
		OSRec1.Ship_To__c = 'S004888888900020MRSBONITA      GOLDMAN                                      PO BOX 7042                   NORTH PORT             FL34290ALIVEINTHEVI@HOTMAIL.COM                          495004    00031Control Room 119001           2222yabcdefghijklmnopqrs';
		OSRec1.Webstack_ID__c = '1';
		OSRec1.Webstack_Order_ID__c = '48888889';
		insert OSRec1;
		system.debug('Order_Summary__c: '+ OSRec1);
		return OSRec1;
	}
	
	public static Order_Summary__c setupOrderSummary_KeyboardTranslation(){
		
		system.debug('setupOrderSummary()');
		Order_Summary__c OSRec1 = new Order_Summary__c();

		OSRec1.Detail__c = 'D006007060600030547900002000119900000000000000009990|#|D006007060600040276700001000089900000000000000009991';
		OSRec1.Done__c = '';
		OSRec1.Header__c = 'H0060070606000100000000000131520C V+++++++++++++++++0316MR OPAS        JINTAKAWEEWAT  1780 FLOOR 8 GUARDFIRE        THB BUILDING BANGNATRAD RD.   BANGKOK                FO000000000000000A N                              WEB SITE  S00000000000000000000                10260     00135                              6627467030          6627467031';
		OSRec1.Payment__c = 'P00600706060001139a6e574-5613-4a9d-8c72-bc5a8f367412042225                                  515310DBF8682FA1801828F9131D46EE266E53C30                                       0000156932013-03-27T11:31:39';
		OSRec1.Ship_To__c = 'S006007060600020MR OPAS        JINTAKAWEEWAT  1780 FLOOR 8 GUARDFIRE        THB BUILDING BANGNATRAD RD.   BANGKOK                FO00000Opas.jin@gmail.com                                10260     00135';
		OSRec1.Webstack_ID__c = '1';
		OSRec1.Webstack_Order_ID__c = '60070606';
		insert OSRec1;
		system.debug('Order_Summary__c: '+ OSRec1);
		return OSRec1;
	}
	
	
	public static void setupInboundOrderMapping(){
		system.debug('setupInboundOrderMapping()');
		
		StaticResource sibOmapping = [Select  s.Name, s.Id, s.Body From StaticResource s where s.Name = 'inboundOrdersMapping'];

		
		Map<String, Inbound_Order_Mapping__c> iomMap = new Map <String, Inbound_Order_Mapping__c>();

		blob tempA = sibOmapping.Body;
		String messageString = tempA.toString();
		system.debug(messageString);
		
		
		String[] filelinesMessages = messageString.split('\n');
		//split up the rows
		//clear the wrapper list
		List<Inbound_Order_Mapping__c> defaultioms = new List<Inbound_Order_Mapping__c>();
		for (Integer i=1;i<filelinesMessages.size();i++){
			Inbound_Order_Mapping__c temp = new Inbound_Order_Mapping__c();
			String[] inputvalues = filelinesMessages[i].split(',');
			//split the rows by commas and populated the fields
			temp.Name = inputvalues[0];

			temp.Data_Type__c=inputValues[1];
			temp.End_Position__c=decimal.valueOf(inputValues[2]);
			temp.object_name__c=inputValues[3];
			temp.record_type__c = inputValues[4];
			temp.start_position__c = decimal.valueOf(inputValues[5]);
			temp.field_name__c = inputValues[6];
			
			
			defaultioms.add(temp);
		}
		
		system.debug('Size of InboundOrderMappings :' + defaultioms.size());
		if (!defaultioms.isEmpty()){
			try{
				insert defaultioms;
			}catch(Exception ex){	system.debug(' defaultioms: exeption: ' + ex.getMessage());	}
		}
		system.debug('Query of defaultioms: '+ [select name from Inbound_Order_Mapping__c]);
	
	}
	public static void setupWebStoresData(){
		system.debug('setupWebStoresData()');
		
		StaticResource webStoresData = [Select  s.Name, s.Id, s.Body From StaticResource s where s.Name = 'webStoresSettings'];

		
		Map<String, WebStoresData__c> webStoresMap = new Map <String, WebStoresData__c>();

		blob tempA = webStoresData.Body;
		String messageString = tempA.toString();
		system.debug(messageString);
		
		
		String[] filelinesMessages = messageString.split('\n');
		//split up the rows
		//clear the wrapper list
		List<WebStoresData__c> defaultwsData = new List<WebStoresData__c>();
		for (Integer i=1;i<filelinesMessages.size();i++){
			WebStoresData__c temp = new WebStoresData__c();
			String[] inputvalues = filelinesMessages[i].split(',');
			//split the rows by commas and populated the fields
			temp.Name = inputvalues[0];

			temp.Currency_Code__c=inputValues[2];
			temp.Description__c=inputValues[3];
			temp.record_type_Name__c = inputValues[4];
			temp.Product_Suffix__c=inputValues[5];
			
			defaultwsData.add(temp);
		}
		
		system.debug('Size of defaultwsData :' + defaultwsData.size());
		if (!defaultwsData.isEmpty()){
			try{
				insert defaultwsData;
			}catch(Exception ex){	system.debug(' defaultwsData: exeption: ' + ex.getMessage());	}
		}
		system.debug('Query of defaultioms: '+ [select name from WebStoresData__c ]);
	
	}
}