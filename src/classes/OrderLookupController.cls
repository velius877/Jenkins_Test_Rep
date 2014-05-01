/* 
 *  Class		   : OrderLookupController 
 *  Author		  : Pavan Jasthi - Acumen Solutions
 *  Creation		 : 03/21/2014
 *  Description	 : Controller for Order lookup component.
 *					  
*/
public with sharing class OrderLookupController {
	
	public list<OrderLookup_Wrapper> submittedOrderWrapList {get;set;}
	public list<OrderLookup_Wrapper> nonSubmittedOrderWrapList {get;set;}
	public boolean hasErrors {get;set;}
	public case caseRec {get;set;} 
	public boolean submitOrdersCalled {get;set;}  
	public boolean nonSubmittedOrdersCalled {get;set;} 
	public OrderLookupController lookupController { get { return this; } private set; }
	public string redirectUrl {get;set;}
	public Map<String, OrderStatusMap__c> osmMap {get;set;}
	public string orderNumber {get;set;}
	public boolean submittedOrdersMode {get;set;}
	
	public integer ordersCount {get;set;}
	public Integer pagingFactor ;
	public integer currentPage {get;set;}
	public integer startIndex {get;set;} 
	public integer endIndex {get;set;}
	public integer currentSetSize;
	public integer minSeq = 1;
	public integer maxSeq = 10;
	set<string> nonSubmitStatuses = new Set <String> {'ER', 'BO'};
	
	public string accountId {get;set;}
	public boolean fromAccountPanel {get;set;}
	public Account acct {get;set;}
	public boolean bHistoryByEmail {get;set;}
	public boolean bSearchBySku {get;set;}
	public string inputSku {get;set;}
	
	//Booleans added to maintain MVC
	public Boolean showNextButton {get;set;}
	public Boolean showPrevButton {get;set;}
	
	public boolean bCreateMiscCharge {get;set;}
	
	public OrderLookupController(boolean bAcctPanel){
		fromAccountPanel = bAcctPanel;
		init();
	}
	
	public OrderLookupController()
	{
		init();
	}
	
	public void init(){
		fromAccountPanel=false;
		bCreateMiscCharge=false;
		string caseId = ApexPages.currentPage().getParameters().get('caseId');
		accountId = ApexPages.currentPage().getParameters().get('Id');
		if(caseId != null) {
			caseRec = [select Id, Related_Order__c,Related_Order_Number__c,Customer__c,Customer__r.AS_400_Customer_Number__c,Customer__r.Name,customer__r.RecordType.DeveloperName from case where Id=:caseId];
			acct = [select id, PersonEmail ,RecordType.DeveloperName, as_400_customer_number__c from Account where id =:caseRec.customer__c];
			accountId=caseRec.customer__c;
		} else {
			acct = [select id, PersonEmail, RecordType.DeveloperName, as_400_customer_number__c from Account where id =:accountId];
		}
		if (acct.AS_400_Customer_Number__c!=null) {
			bHistoryByEmail=false;
		}
		else bHistoryByEmail=true;
		hasErrors = false;
		submitOrdersCalled = false;
		bSearchBySku=false;
		nonSubmittedOrdersCalled = false;
		submittedOrdersMode = true;
		showNextButton = false;
		showPrevButton = false;
		//Paginatin related
		pagingFactor = (maxSeq - minSeq) + 1;
		currentPage = 0;
		updateOstatusMapping();
	//	getSubmittedOrders();
	}
	
	public string getQueryFields() {
		string queryFields = '';
		queryFields =	'select Id,Name,Order_Submitted__c,Order_Status__c,Order_Date__c,Order_Total__c,Payment_Type__c,Authorization_Amount__c,Customer__r.Name,Source_Code__c,Credit_Card_Type__c,Paypal_Authorization_Code__c,Credit_Card_Token__c, Credit_Card_Expiration_Date__c' ; 
		queryFields +=  ' ,Ship_to_First_Name__c,Ship_to_Last_Name__c,Ship_To_Address__r.Address_Line_1__c,Ship_To_Address__r.Address_Line_2__c,Ship_To_Address__r.City__c,Ship_To_Address__r.State_Providence__c,Ship_To_Address__r.Zip_Code__c';
		queryFields +=  ' ,Webstack_Order_Id__c,Bill_To_Address__r.Address_Line_1__c,Bill_To_Address__r.Address_Line_2__c,Bill_To_Address__r.City__c,Bill_To_Address__r.State_Providence__c,Bill_To_Address__r.Zip_Code__c';
		queryFields +=  ' ,Allowance_Discount__c, Payment_Value__c, Shipping_Total__c, Order_Sub_Total__c';
		queryFields +=  ' ,(select Id,Quantity_Shipped__c,Original_Quantity__c,Final_Price__c,Shipment_Tracking_Number__c,Shipper__c,Item_Status__c,Product_Name__r.name,SKU_Number__c from Order_Line_Items__r) ';
		
		return queryFields;
	}
	
	public void getNonSubmittedOrders() {
		if (caseRec!=null) {
			nonSubmittedOrderWrapList = new list<OrderLookup_Wrapper>();
			nonSubmittedOrdersCalled = true;
			for(orders__c ord : database.query(getQueryFields() + ' from Orders__c where Customer__c = :accountId AND (Order_Submitted__c = false OR Order_Status_Code__c =:nonSubmitStatuses) ORDER BY CreatedDate DESC ')) {
				OrderLookup_Wrapper ordWrap = new OrderLookup_Wrapper();
				ordWrap.orderRec = ord;
				ordWrap.isHisOrder = false;
				nonSubmittedOrderWrapList.add(ordWrap);
			}
		}
	}
	
	public void searchHistoryByEmail(){
		currentPage=0;
		resetSequences();
		 bHistoryByEmail=true;
		 getSubmittedOrders();
	}
	
	public void clearHistoryByEmail(){
		 bHistoryByEmail=false;
		 getSubmittedOrders();
	}
	
	public void searchBySku(){
		currentPage=0;
		resetSequences();
		 bSearchBySku = true;
		 getSubmittedOrders();
	}
	
	public void removeBySku(){
		 bSearchBySku = false;
		 getSubmittedOrders();
	}
	

	
	public void getSubmittedOrders() {
	
		submittedOrderWrapList = new list<OrderLookup_Wrapper>();
		submitOrdersCalled = true;
		string key = '';
		Map<string,OrderLookup_Wrapper> filterOrderWrapMap = new Map<string,OrderLookup_Wrapper>();
		
		for(orders__c ord : database.query(getQueryFields() + ' from Orders__c where Customer__c = :accountId AND Order_Submitted__c = true ')) {
			key = ord.Name;
			key = key.replaceall('^0*', '');
			system.debug('@@@@ SF order Key'+key);
			OrderLookup_Wrapper ordWrap = new OrderLookup_Wrapper();
			ordWrap.orderRec = ord;
			ordWrap.isHisOrder = false;
			
			filterOrderWrapMap.put(key,ordWrap); // Used as reference for Orderhistory webservice orders 
		}
		ws_Soa_OrderHistoryService.retrieveOrdersHistoryResponse ohResp;
		if (acct.AS_400_Customer_Number__c!=null&&!bHistoryByEmail) {//first query by AS400 customer number
			 ohResp = WS_OrderHistoryUtils.doCallout(acct.as_400_customer_number__c, null, bSearchBySku? inputSku : null, String.valueOf(minSeq), String.valueOf(maxSeq)) ;
		} else if (bHistoryByEmail&&acct.PersonEmail!=null) { //if no number, query by email
			 ohResp = WS_OrderHistoryUtils.doCallout(null, acct.PersonEmail, bSearchBySku? inputSku : null  , String.valueOf(minSeq), String.valueOf(maxSeq)) ;
		}
		else {
			ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Blank AS400 Customner Number & Email; no method to query history');
			ApexPages.addMessage(msg);
		}
		if (ohResp!=null){
			if (ohResp.retrieveOrdersHistorySuccess == 'Success') {
				//currentSetSize = ohResp.orders != null ?  ohResp.orders.size() : 0;
				if (ohResp.orders != null) {
					currentSetSize = ohResp.orders.size();
				}
				//ordersCount = Integer.valueOf(ohResp.totalOrderCount);
				if (ohResp.totalOrderCount != null) {
					ordersCount = Integer.valueOf(ohResp.totalOrderCount);
				} else {
					ordersCount = 0;
				}
				doPagination();
				setShowNext();
				setShowPrev();
				updateSFItemDetails(ohResp.orders);
				for (ws_Soa_OrderHistoryService.orders hOrd : ohResp.orders) {
					if (hOrd.orderHeader!=null) {
						key = hOrd.orderHeader.sFOrderNumber;
						key = key != null ? key.replaceall('^0*', '') : '';
						system.debug('@@@@ Hist order Key'+key);
						OrderLookup_Wrapper ordWrap = new OrderLookup_Wrapper();
						ordWrap.hisOrder = hOrd;
						ordWrap.isHisOrder = true;
						ordWrap.SFOrderNo = hOrd.orderHeader.sFOrderNumber;
						ordWrap.WebOrderNo = hOrd.orderHeader.webOrderNumber;
						ordWrap.wrapperLineList = new List <OrderLookup_Wrapper.Wrapper_Line>();
						if (ordWrap.hisOrder.lineItems!=null){
							for (ws_Soa_OrderHistoryService.lineItem li: ordWrap.hisOrder.lineItems.lineItem){
								ordWrap.wrapperLineList.add(new OrderLookup_Wrapper.Wrapper_Line(li, osmMap.get(li.purchaseStatus)));
							}
						}
						//along with AS400 order also storing SF Order for matching AS400 order and used when creating Order adjustment in converToOrderAdjustment() method
						if (filterOrderWrapMap.containskey(key)) {
							ordWrap.orderRec = filterOrderWrapMap.get(key).orderRec;
						}
						submittedOrderWrapList.add(ordWrap);
					}
				}
			} else if (ohResp.retrieveOrdersHistoryFailure != null) {
				ws_Soa_OrderHistoryService.retrieveOrdersHistoryFailure failure = ohResp.retrieveOrdersHistoryFailure;
				if (failure.statusMessage != null || failure.statusCode != null) {
					apexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Message:'+ failure.statusMessage + ' Code:'+failure.statusCode);
					ApexPages.addMessage(msg);
					return;
				}
			}
		}
		
	}
	
	public void setShowNext() {
		//if(lookupController.endIndex < lookupController.ordersCount,true,false)
		if (ordersCount != null && endIndex != null) {
			if (endIndex < ordersCount) {
				showNextButton = true;
			} else{
				showNextButton = false;
			}
		}
	}
	
	public void setShowPrev() {
		//if(lookupController.currentPage > 0,true,false)
		if (currentPage > 0) {
			showPrevButton = true;
		} else {
			showPrevButton = false;
		}
	}
	
	public void resetSequences(){
		// Next sequence calculation 
		minSeq = (currentPage * pagingFactor) + 1;
		maxSeq = (currentPage * pagingFactor) + pagingFactor;
	}
	
	//minSeq and maxSeq are used to call the order History webservice
	public void next() {
		currentPage ++ ;
		// Next sequence calculation 
		resetSequences();
		getSubmittedOrders();
	}
	 
	public void previous() {
		currentPage --;
		// Previous sequence calculation 
		resetSequences();
		getSubmittedOrders();
		
	}
	// Start Index and endIndex used to show the record range on VF page
	public void doPagination() {
		startIndex = (currentPage * pagingFactor) + 1;
		endIndex = (currentPage * pagingFactor) + currentSetSize;
		system.debug('@@@@@startIndex :'+ startIndex + 'endIndex:'+endIndex + 'minSeq'+ minSeq + 'maxSeq:'+ maxSeq);
		
	}
	
	public void updateSFItemDetails(list<ws_Soa_OrderHistoryService.orders> hisOrders) {
		map<string,Item__c> skuItemMap = new map<string,Item__c>();
		set<string> skus = new set<string>();
		
		Customer_Rec_Type_Brand_Mapping__c brandMap = Customer_Rec_Type_Brand_Mapping__c.getAll().get(acct.RecordType.DeveloperName);
		system.debug('@@@@ check Brand map'+brandMap);
		string suffix = brandMap.Product_Suffix_c__c;
		if(suffix == null || suffix == '' ) {
			ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Message: Brand suffix is missing in custom settings');
			ApexPages.addMessage(msg);
			return;
		}
		
		for(ws_Soa_OrderHistoryService.orders ord : hisOrders) {// all orders of the response
			if (ord.lineItems!=null){
				system.debug(ord.lineItems); 
				system.debug(ord.lineItems.lineItem.size());
				for (ws_Soa_OrderHistoryService.lineItem li :ord.lineItems.lineItem ) {// individual line items of each order
					if (li.enterSku != null) {
						skus.add(li.enterSku);
					}   
				}
			}
		}
		
		for (item__c item : [select Id,Product_Number__c,Name from Item__c where Product_Number__c IN:skus AND product_suffix__c = : suffix limit 1000]) {
			skuItemMap.put(item.Product_Number__c,item);
		}
		
		//updating items names this time	
		for (ws_Soa_OrderHistoryService.orders ord : hisOrders) {// all orders of the response
			if (ord.lineItems!=null) {
				for (ws_Soa_OrderHistoryService.lineItem li :ord.lineItems.lineItem ) {// individual line items of each order
					if (skuItemMap.containsKey(li.enterSku)) {
						li.itemName = skuItemMap.get(li.enterSku).Name;
						li.itemSfId = skuItemMap.get(li.enterSku).Id; 
					}
				}
			}
		}
		system.debug('@@@@@'+skuItemMap);
	}
	
	public void switchTabs() {
		system.debug('@@@@ submittedOrdersMode'+submittedOrdersMode);
		if (!submittedOrdersMode && !nonSubmittedOrdersCalled) {
			getNonSubmittedOrders();
		}
		if (submittedOrdersMode && !submitOrdersCalled) {
			getSubmittedOrders();
		}
	}
	
	public void attachToCase() {
		try {
			if (!submittedOrdersMode) {
				for (OrderLookup_Wrapper ow : nonSubmittedOrderWrapList ) {
					if (!ow.isHisOrder && ow.orderRec.Name == orderNumber) {
						caseRec.Related_Order__c = ow.orderRec.Id;
						caseRec.Related_Order_Number__c = ow.orderRec.Name;
						break;
					}
				}
				update caseRec;
				redirectUrl = '/'+caseRec.Id;
			} else {//For submittedOrders mode checking both SF Orders and AS400 orders
				for (OrderLookup_Wrapper ow : submittedOrderWrapList ) {
					if (ow.isHisOrder && ow.hisOrder.orderHeader.as400PurchaseNumber == orderNumber) {
						caseRec.Related_Order_Number__c = (ow.hisOrder.orderHeader.sfOrderNumber == null || ow.hisOrder.orderHeader.sfOrderNumber == '') ? ow.hisOrder.orderHeader.as400PurchaseNumber : ow.hisOrder.orderHeader.sfOrderNumber;
						caseRec.Related_Order__c =  ow.orderRec!=null? ow.orderRec.id : null;
						break;
					}
				}
				update caseRec;
				redirectUrl = '/'+caseRec.Id;
			}
		} catch(exception ex) {
			ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Internal Error: '+ ex.getmessage());
			ApexPages.addMessage(msg);
			redirectUrl = '';
			return ;
		}
	}
	
	public pageReference createMiscCharge(){
		bCreateMiscCharge = true;
		return converToOrderAdjustment();
	}
	
	public pagereference converToOrderAdjustment() {
		Savepoint sp = Database.setSavepoint();
		try {
			attachToCase();
			order_Adjustment__c odj;
			for(OrderLookup_Wrapper ow : submittedOrderWrapList ) {
				if(ow.isHisOrder && ow.hisOrder.orderHeader.as400PurchaseNumber == orderNumber) {
					odj = createOrderAdjustment(ow);
					break;
				}
			}
			PageReference ref = new PageReference('/apex/OrderAdjustmentPage?Id='+ odj.Id);
			ref.setRedirect(true);
			return ref;
			
		} catch(exception ex) {
			ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Order Adjustment cannot be created: '+ ex.getmessage());
			ApexPages.addMessage(msg);
			Database.rollback(sp);
			redirectUrl = '';
			return null;
		}
	}
	// this will be called from non-order hsitory orders
	public pagereference redirectToAdjustmentPage() {
		try {
			for(OrderLookup_Wrapper ow : nonSubmittedOrderWrapList ) {
				if(!ow.isHisOrder && ow.orderRec.Name == orderNumber) {
					caseRec.Related_Order__c = ow.orderRec.Id;
					break;
				}
			}
			update caseRec;
			pageReference ref = new PageReference('/apex/OrderAdjustmentPage?caseId='+ caseRec.Id);
			ref.setRedirect(true);
			return ref;
			
		} catch(exception ex) {
			ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Operation failed: '+ ex.getmessage());
			ApexPages.addMessage(msg);
			redirectUrl = '';
			return null;
		}
	}
	
	public Order_Adjustment__c createOrderAdjustment(OrderLookup_Wrapper ow) {
		Order_Adjustment__c orderAdj = new Order_Adjustment__c();
		if(ow.hisOrder != null) {
			RecordType recType;
			if (!bCreateMiscCharge) {
				recType = [SELECT Id, Name FROM RecordType WHERE sObjectType = 'Order_Adjustment__c' AND DeveloperName = 'Refund'];
				orderAdj.Refund_Type__c = 'Full Refund';
			} else {
				recType = [SELECT Id, Name FROM RecordType WHERE sObjectType = 'Order_Adjustment__c' AND DeveloperName = 'Misc_Charge'];
				
			}
			orderAdj.AS400_Order_Number__c = ow.hisOrder.orderHeader.as400PurchaseNumber;
			orderAdj.Customer__c = caseRec.Customer__c;
			orderAdj.Related_Case__c = caseRec.Id;
			orderAdj.RecordTypeId = recType.Id;
			orderAdj.Origin__c = 'From Order History';
			orderAdj.Status__c = 'Draft';
			orderAdj.Customer__c = caseRec.customer__c;
			orderAdj.Salesforce_Order_Number__c = ow.hisOrder.orderHeader.sFOrderNumber;
			orderAdj.Web_Order_Number__c =  ow.hisOrder.orderHeader.webOrderNumber;
			
			//first Checking for matching SF order
			if(ow.orderRec.Id != null) {
				orderAdj.Payment_Method__c = ow.orderRec.Payment_Type__c;
				orderAdj.Related_Order_Payment_Type__c = ow.orderRec.Payment_Type__c;
				orderAdj.Related_Order_Paypal_Transaction_ID__c = ow.orderRec.Paypal_Authorization_Code__c;
				orderAdj.Credit_Card_Type__c = ow.orderRec.Credit_Card_Type__c;
				orderAdj.Related_Order__c = ow.orderRec.Id;
				orderAdj.Credit_Card_Token__c = ow.orderRec.Credit_Card_Token__c;
				orderAdj.Credit_Card_Expiration_Date__c = ow.orderRec.Credit_Card_Expiration_Date__c;
				orderAdj.Related_Order_Discount_Amount__c = ow.orderRec.Allowance_Discount__c;
				orderAdj.Related_Order_Payment_Amount__c = ow.orderRec.Payment_Value__c;
				orderAdj.Related_Order_Shipping_Amount__c = ow.orderRec.Shipping_Total__c;
				orderAdj.Related_Order_SubTotal__c = ow.orderRec.Order_Sub_Total__c;
				
			}
			
			if (ow.hisOrder!=null)
			{  //history order is ultimately the better source of truth
				orderAdj.Related_Order_Amount__c = ow.hisOrder.orderHeader.totalNetPurchaseAmount != null ? decimal.valueof(ow.hisOrder.orderHeader.totalNetPurchaseAmount) : 0.00;
				orderAdj.Related_Order_Tax_Amount__c = ow.hisOrder.orderHeader.taxAmount != null ? decimal.valueof(ow.hisOrder.orderHeader.taxAmount) : 0.00;
				orderAdj.Related_Order_Discount_Amount__c = ow.hisOrder.orderHeader.allowanceAmount != null ? decimal.valueof(ow.hisOrder.orderHeader.allowanceAmount) : 0.00;
				orderAdj.Related_Order_Payment_Amount__c = ow.hisOrder.orderHeader.amountRemitted != null ? decimal.valueof(ow.hisOrder.orderHeader.amountRemitted) : 0.00;
				orderAdj.Related_Order_Shipping_Amount__c = ow.hisOrder.orderHeader.freightAmount != null ? decimal.valueof(ow.hisOrder.orderHeader.freightAmount) : 0.00;
				orderAdj.Related_Order_SubTotal__c = orderAdj.Related_Order_Amount__c - orderAdj.Related_Order_Discount_Amount__c -orderAdj.Related_Order_Shipping_Amount__c;
				orderAdj.Payment_Method__c = (ow.hisOrder.orderHeader.creditCardType == null || ow.hisOrder.orderHeader.creditCardType == '') ? 'Cash' : nbtyutils.getCCTypeMappings('AS400').get(ow.hisOrder.orderHeader.creditCardType).Payment_Method__c;
				orderAdj.Related_Order_Payment_Type__c = orderAdj.Payment_Method__c;
					orderAdj.Credit_Card_Expiration_Date__c = ow.hisOrder.orderHeader.creditCardExpiryDate;
				if ( ow.hisOrder.payments!=null){
					if ( ow.hisOrder.payments.payment!=null){
						orderAdj.Credit_Card_Token__c = ow.hisOrder.payments.payment[0].tokenNumber;
					}
				}
				if(ow.hisOrder.orderHeader.creditCardType!=null && ow.hisOrder.orderHeader.creditCardType != '') {
					system.debug('@@@ow.hisOrder.orderHeader.creditCardType'+ow.hisOrder.orderHeader.creditCardType);
					orderAdj.Credit_Card_Type__c = nbtyutils.getCCTypeMappings('AS400').get(ow.hisOrder.orderHeader.creditCardType).Name;
				}
			
			}
			upsert orderAdj ;
			createAdjustmentLineItems(ow,orderAdj);
			system.debug('@@@Created adjustment'+orderAdj);
			if (orderAdj.Payment_Method__c == 'Credit Card' && !bCreateMiscCharge) {
				OrderAdjustment_CreditRefundDetails.OrderAdjustmentId = orderAdj.Id;
				List <Credit_Refund_Detail__c> crdList  = OrderAdjustment_CreditRefundDetails.populateCrdList(ow.hisOrder);
				if(crdList != null)
					upsert crdList Unique_Key__c;
			}
		}
		return orderAdj;
	}
	
	public void createAdjustmentLineItems(OrderLookup_Wrapper ow,Order_Adjustment__c oa) {
		list<Order_Adjustment_Line_Item__c> oaLineItems = new list<Order_Adjustment_Line_Item__c>();
		if (ow.hisOrder != null) {
			integer i =0;
			Order_Adjustment__c tempOA = [select Id,name from Order_Adjustment__c where Id= :oa.Id limit 1] ;
			for (ws_Soa_OrderHistoryService.lineItem li :ow.hisOrder.lineitems.lineItem) {
				
				Order_Adjustment_Line_Item__c oaLi = new Order_Adjustment_Line_Item__c();
				oaLi.Name = tempOA.Name + '-' + i++;
				oaLi.SKU_Number__c = li.enterSku;
				oaLi.Item_Name__c = li.ItemName;
				oaLi.Order_Adjustment__c =  oa.Id;
				oaLi.Amount__c = li.salesPrice <> null ? decimal.valueof(li.salesPrice.replaceall('^0*', '')) : 0.00;
				oaLi.Quantity__c = li.originalQuantityOrdered <> null ? integer.valueof(li.originalQuantityOrdered.replaceall('^0*', '')) : 0;
				oaLi.isChecked__c = true;
				oaLi.line_number__c = li.purchaseLineNumber;
				oaLi.external_key__c = oa.AS400_Order_Number__c+'-'+li.purchaseLineNumber;
				oaLineItems.add(oaLi);
			}
		}
		if (!oaLineItems.isempty())
			upsert(oaLineItems); 
	}
	
	public void updateOstatusMapping() {
		List<OrderStatusMap__c> osmList = OrderStatusMap__c.getall().values();
		osmMap = new Map<String, OrderStatusMap__c>();
		for(OrderStatusMap__c osm : osmList){
			osmMap.put(osm.Name, osm);
		}
	}
	
}