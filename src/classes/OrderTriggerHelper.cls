public  class OrderTriggerHelper {
	public static boolean isDeleteAllowed = false;
	public static boolean UpdateLineItemReason = true;
	public static boolean skipUpdateTrigger = false;
	public static final String zipStr = 'zip';
	public static final String addrStr = 'address';
	public static final String emailStr = 'email';
	
	public static void isBeforeInsert(List <Orders__c> orderList){
		OrderTriggerHelper.updatePromotionsLookup(orderList, null);
		OrderTriggerHelper.setCustomerEmailAndBrand(orderList);
		OrderTriggerHelper.setSalesChannelAndPayment(orderList);
		OrderTriggerHelper.setPhoneNumberOnOrder(orderList);
		OrderTriggerHelper.checkKeyboardTranslation(orderList);
		//OrderTriggerHelper.setDefaultShippingMethod(orderList);
	}
	
	public static void isAfterInsert(List <Orders__c> orderList){
		OrderTriggerHelper.aggregateBatchObject(orderList, null);
		if (!badCustOff()) {
			OrderTriggerHelper.checkBadCust(orderList);
		}
	}
	
	public static void isBeforeUpdate(List <Orders__c> orderList, Map <Id, Orders__c> oldMap){
		if(!skipUpdateTrigger){
			OrderTriggerHelper.preventInternalReviewOverwrite(orderList, oldMap);
			OrderTriggerHelper.setOrderStatus(orderList);
			OrderTriggerHelper.checkUpdateForInternalReview(orderList, oldMap);
			// OrderTriggerHelper.updatePromotionsLookup(orderList, oldMap);
			OrderTriggerHelper.checkReturns(orderList);
			OrderTriggerHelper.checkForSubmissionFailedOrders(orderList, oldMap);
			OrderTriggerHelper.setAddressRtDetailFields(orderList, oldMap);
			OrderTriggerHelper.setSequenceNumber(orderList, oldMap);
			//OrderTriggerHelper.setSalesChannelAndPayment(orderList);
		}
	}
	
	public static void isAfterUpdate(List <Orders__c> orderList, Map <Id, Orders__c> oldMap){
		if (!skipUpdateTrigger) {
			OrderTriggerHelper.aggregateBatchObject(orderList, oldMap);
			OrderTriggerHelper.checkAvalaraSubmit(orderList, oldMap);
			if (UpdateLineItemReason) {
				UpdateLineItemReason = false;
				UpdateCancellationComment(orderList, oldMap);
			}
			if (!badCustOff()) {
				OrderTriggerHelper.checkBadCust(orderList);
			}
			OrderTriggerHelper.unRedeemVWCoupon(orderList);
		}
		
	}
	
	public static Boolean badCustOff(){
		return Boolean.valueOf(WS_Integration__c.getValues('BadCustOff').value__c);
	}
	
	public static void UpdateCancellationComment(List <Orders__c> orderList, Map <Id, Orders__c> oldMap)
	{
		List<id> lstOrderswithComments = new list<id>();
		system.debug('-------------------UpdateLineItemReason:' + UpdateLineItemReason);
		system.debug('--------------Inside Order Cancellation Reason Update');
		list<Order_Line_Items__c> lstorderlineitem = new list<Order_Line_Items__c>();
		for(Orders__C ord :orderList)
		{
			if(string.isNotblank(ord.Cancelled_Reason__c)) // Orders Cancelled
				lstOrderswithComments.add(ord.id);
		}
		
		lstorderlineitem = [Select Id, Cancel_Reason__c, Order__r.Order_Submitted__c,Order__r.Cancelled_Reason__c From Order_Line_Items__c where Order__c in :lstOrderswithComments];
		
		for(Order_Line_Items__c l :lstorderlineitem) 
		{
			
			if(string.isblank(l.Cancel_Reason__c))
			{
			l.Cancel_Reason__c = l.Order__r.Cancelled_Reason__c;
			
			if(!l.Order__r.Order_Submitted__c)
			{
				l.Item_Status__c = 'Item Cancelled';
				l.Item_Status_Code__c = 'RC';
			}
			}
			
		}
		system.debug('--------------Total line items for update:' + lstorderlineitem.size());
		update lstorderlineitem;
	}
	
	public static void checkKeyboardTranslation(List<Orders__c> orderList ){
		Set <Id> AddressIds = new Set <Id>();
		Map <Id, Address__c> addressMap = new Map <Id, Address__c>();
		for (Orders__c ord: orderList){
			if (ord.Sales_Channel__c!='Phone'){
				AddressIds.add(ord.bill_to_address__c);
				//get bill to addresses
			}
		}
		if (!AddressIds.isEmpty()){
			for (Address__c addr: [select id, foreign_country_code__c 
									from Address__c 
									where id in:AddressIds
									and International_Address__c =true]){
				addressMap.put(addr.id,addr);
						//query addresses and add to address map
			}
		}
		if (!addressMap.isEmpty()){
			for (Orders__c ord: orderList){
				if (Country_code_mapping__c.getValues(addressMap.get(ord.bill_to_Address__c).Foreign_Country_Code__c).keyboard_translation__c){  //check that country code mapping - keyboard translation is true
					ord.Order_Status__c= 'Internal Review';//set internal review
					ord.Internal_Review_Reason__c = 'There COULD be a problem with keyboard translation';//set internal review reason; there could be a keyboard tranlation issue
				}
			}
		}
	}
	
	public static void aggregateBatchObject(List <Orders__c> orderList, Map <Id, Orders__c> oldMap){
		Set <String> batchesToAggregate = new Set <String>();
		Map <String, Id> ordBatchMap = new Map <String, Id>();
		Set <String> validBatchNumSet = new Set <String>();
		for (Orders__c ord: orderList){
			// DE877 -- Bypass aggregationforumlation for replacement
			if (ord.Batch_Number__c!=null && !ord.Replacement_Order__c && oldMap==null){
				batchesToAggregate.add(ord.Batch_Number__c);
			} 
			// DE877 -- Bypass aggregationformulation for replacement
			else if (!ord.Replacement_Order__c && oldMap!=null){
				if (ord.Batch_Number__c!=oldMap.get(ord.id).batch_number__c){
					if (ord.batch_number__c!=null){
						 batchesToAggregate.add(ord.Batch_Number__c);
					}
					if (oldMap.get(ord.id).batch_number__c!=null){
						batchesToAggregate.add(oldMap.get(ord.id).batch_number__c);
					}
				}
			}
		}
		if (!batchesToAggregate.isEmpty()){
			List <Batch__c> batchList = new List <Batch__c>();
			AggregateResult[] groupedResults = [SELECT  Batch_Number__c,Sum(Order_Total__c),Sum(Payment_Value__c),Count(Id),Min (CreatedDate)
	  											FROM Orders__c
	  											WHERE Batch_Number__c in :batchesToAggregate
	  											GROUP BY Batch_Number__c];
			for (AggregateResult ar : groupedResults)  {
				
				Batch__c newBatch = new Batch__c();
				newBatch.Aggregate_Value__c=(decimal)ar.get('expr0');
				newBatch.Batch_Number__c=(string)ar.get('Batch_Number__c');
				Datetime dt = (Datetime)ar.get('expr3');
				newBatch.Date__c=date.valueOf(dt);
				newBatch.Number_Orders__c=(integer)ar.get('expr2');
				batchList.add(newBatch);
				validBatchNumSet.add(newBatch.batch_number__c);
				system.debug(newBatch);
			}
			for (Batch__c b: [select id, batch_number__c from Batch__c WHERE Batch_Number__c in :batchesToAggregate]){
				ordBatchMap.put(b.Batch_Number__c,b.id);
			}
				
			if (!batchList.isEmpty()){
				upsert  batchList Batch_Number__c;
			}
			if (oldMap!=null){
				Set <String> batchNums = new Set <String>(); 
				for (orders__c ord: oldMap.values()){
					if (ordBatchMap.get(ord.batch_number__c)!=null&&!validBatchNumSet.contains(ord.batch_number__c)){
						batchNums.add(ord.batch_number__c);
					}
				}
				if (!batchNums.isEmpty()){
					delete [select id from Batch__c where batch_number__c in :batchNums];
				}
			}
		}
	}
	
	public static void preventInternalReviewOverwrite(List <Orders__c> orderList, Map<Id, Orders__c> oldMap){
		for (Orders__c ord: orderList){
			// DE577 -- Allow CSRs to put replacement / credit orders into pending submission 
			// while still blocking them from moving any order out of Internal Review
			/* Not needed per new replacement approval workflow PTN 2/28/2014
			if (ord.Batch_Number__c != null){
				if ((ord.Replacement_Order__c || ord.Order_Total__c == 0) && OrderUtilities.checkProfile('CSR')){
					ord.Order_Status__c = 'Pending Submission';
					return;
				}
			}	*/
			// DE883 -- Issue where cancelled orders that would have gone to IR still do.
			if (ord.Order_Status__c!=oldMap.get(ord.id).order_Status__c && oldMap.get(ord.id).Order_Status__c=='Internal Review'
			 && OrderUtilities.checkProfile('CSR') && ord.Order_Status__c != 'Cancelled'){
				ord.Order_Status__c = 'Internal Review';
			}
		}
	}
	
	public static void setPhoneNumberOnOrder(List <Orders__c> orderList){
		for (Orders__c ord: orderList){
			if (ord.Phone_Number__c!=null){
				if (ord.Phone_Number__c=='0000000000'){
					ord.phone_number__c=null;
				}else {
					ord.Phone_number__c = AccountTriggerHelper.formatTelephone(ord.phone_number__c);
				}
			}
		}
	}
	
	
	public static void setAddressRtDetailFields(List <Orders__c> orderList, Map <Id, Orders__c> oldMap){
		Set <Id> custIds = new Set <Id>();
		Set <Id> addressIds = new Set <Id>();
		Map <Id, Address__c> addressMap = new Map <Id, Address__c>();
		Map <Id, Account> accountMap = new Map <Id, Account>();
		for (Orders__c ord: orderList){
			if (ord.order_Status__c =='Pending Submission' && oldMap.get(ord.id).order_status__c!='Pending Submission'){
				addressIds.add(ord.ship_to_address__c);
				addressIds.add(ord.bill_to_address__c);
				custIds.add(ord.customer__c);
				ord.ownerId=userInfo.getUserId();
			}
		}
		if (!addressIds.isEmpty()){
			for (Address__c add: [Select id, Country_Picklist__c,State_Providence__c,a.Zip_Code__c, a.Zip_Code_4__c, a.Foreign_Postal_Code__c, 
									a.Country__c, a.City__c, a.Address_Line_4__c, a.Address_Line_3__c, a.Address_Line_2__c, a.Address_Line_1__c 
									From Address__c a where id in: addressIds ]){
				addressMap.put(add.id, add);
			}
			for (Account a: [select id, PersonEmail from Account where id in :custIds]){
				accountMap.put(a.id, a);
			}
			for (Orders__c ord: orderList){
				if (addressMap.keySet().contains(ord.ship_to_address__c)){
					ord.Ship_To_Address_Details__c=formatAddressData(addressMap.get(ord.ship_to_address__c));
				}
				if (addressMap.keySet().contains(ord.bill_to_address__c)){
					ord.bill_to_address_details__c=formatAddressData(addressMap.get(ord.bill_to_address__c));
				}
				if (accountMap.keySet().contains(ord.customer__c)){
					ord.Ship_to_Email_Address__c=accountMap.get(ord.customer__c).personemail;
				}
				
			}
		}
	}
	
	public static string formatAddressData (Address__c add){
		string addressString = add.Address_Line_1__c;
		if (add.Address_Line_2__c!=null)  addressString+='<br/>'+add.Address_Line_2__c;
		if (add.Address_Line_3__c!=null)  addressString+='<br/>'+add.Address_Line_3__c;
		if (add.Address_Line_4__c!=null)  addressString+='<br/>'+add.Address_Line_4__c;
		if (add.country__c=='US'||add.country__c=='CA'){
			addressString+='<br/>'+add.city__c+', ';
			addressString+=add.State_Providence__c+' ';
			addressString+=add.Zip_Code__c;
			if (add.Zip_Code_4__c!=null) addressString+='-'+add.Zip_Code_4__c;
		}
		else {
			if (add.Foreign_Postal_Code__c!=null) addressString+=add.Foreign_Postal_Code__c+' ';
			if (add.city__c!=null) addressString+='<br/>'+ add.city__c;
			if (add.State_Providence__c!=null) addressString+=', '+ add.State_Providence__c;
			addressString+=+'<br/>'+add.Country_Picklist__c;
		}
		return addressString;
	}
	
	public static void setOrderStatus(List <Orders__c> orderList){
		for (Orders__c o: orderList){
			OrderStatusMap__c osm = OrderStatusMap__c.getInstance(o.Order_Status__c);
			if (osm!=null){
				o.Order_Status__c =osm.SFDC_Order_Status__c;
			}
		}
	}
	public static void setDefaultShippingMethod (List <Orders__c> orderList){
		Map<String,Order_Picklist_Map__c> OPM = Order_Picklist_Map__c.getAll();
	
		if(OPM != null)
		{
			for(Orders__c NewOrder :orderList)
			{
				String PickListVal = '';
				
				if(NewOrder.Shipping_Method__c != null && NewOrder.Shipping_Method__c != '')
				{
					PickListVal = OPM.get(NewOrder.Shipping_Method__c).Value__c;
				}
				
				if(PickListVal != null && PickListVal != '')
				{
					NewOrder.put('Shipping_Method__c', PickListVal);
				}
			}
		}
	}
	public static void checkUpdateForInternalReview(List <Orders__c> orderList, Map <Id, Orders__c> oldMap){
		String profile = OrderUtilities.userProfile(UserInfo.getProfileId());
		Set <Id> statusChangeIds = new Set <Id>();
		Map <Id, Account> accountMap = new Map <Id, Account>();
		for (Orders__c o: orderList){
			if (o.Order_Status__c!=oldMap.get(o.id).Order_Status__c&&o.Order_Status__c=='Pending Submission'){
				statusChangeIds.add(o.customer__c);
			}
		}
		if (!statusChangeIds.isEmpty()){
			for (Account a: [select id, possible_fraud__c from Account where id in:statusChangeIds]){
				accountMap.put(a.id, a);
			}
			for (Orders__c o: orderList){
				if(profile == 'CSR'){
					if (o.Order_Status__c!=oldMap.get(o.id).Order_Status__c&&o.Order_Status__c=='Pending Submission'){
						if (accountMap.get(o.customer__c).possible_fraud__c){
							o.Order_Status__c = 'Internal Review';
							o.Internal_Review_Reason__c = 'Possible Fraud';
						}
					}
				}
			}
		}
	}
	public static void updatePromotionsLookup(List <Orders__c> orderList, Map <Id, Orders__c> oldMap){
		/* This grabs any changed promotions/new promotions and links them to the salesforce promotions object*/
		Set <String> promotionsStrings = new Set <String>();
		Map <String, Promotion__c> promoMap = new Map <String, Promotion__c>();
		for (Orders__c o: orderList) {
			if (oldMap==null){
				if (o.Catalog_Source_Code__c!=null) promotionsStrings.add(o.Catalog_Source_Code__c);
			} else {
				if (o.Catalog_Source_Code__c!=oldMap.get(o.Id).Catalog_Source_Code__c) {
					if (o.Catalog_Source_Code__c==null) {
						o.Promotions__c=null;
					} else {
						promotionsStrings.add(o.Catalog_Source_Code__c);
					}
				}
			}
		}
		if (!promotionsStrings.isEmpty()) {
			for (Promotion__c p: [select id, name from Promotion__c where name in :promotionsStrings]){
				promoMap.put(p.name, p);
			}
			for (Orders__c o: orderList) {
				if (promoMap.get(o.Catalog_Source_Code__c)!=null){
					o.Promotions__c=promoMap.get(o.Catalog_Source_Code__c).id;
				}
			}
		}
	}
	
	public static void setCustomerEmailAndBrand(List <Orders__c> orderList) {
		Set <Id> CustomerIds = new Set <Id>();
		Map <Id, Account> accountMap = new Map <Id, Account>();
		
		for (Orders__c o: orderList) {
			o.Order_Date__c = System.now();
			CustomerIds.add(o.customer__c);
		}
		
		if (!CustomerIds.isEmpty()) {
			for (Account a: [SELECT Id, PersonEmail, RecordType.Name FROM Account WHERE Id IN :CustomerIds]) {
				accountMap.put(a.id, a);
			}
		}
		
		if (!accountMap.isEmpty()) {
			for (Orders__c o: orderList) {
				if (accountMap.containsKey(o.customer__c)) {
					o.Order_Confirm_Email__c = accountMap.get(o.customer__c).PersonEmail;
					o.Order_Confirm_Brand__c = accountMap.get(o.customer__c).RecordType.Name;
				}
			}
		}
	}
	
	public static void setSalesChannelAndPayment(List <Orders__c> orderList) {
		// Removing the following block and cooridinating code and moving to custom setting fields in Web Stores Data
		/*
		Map<String, String> salesChanMap = new Map<String,String>();
		salesChanMap.put('Z','Amazon');
		salesChanMap.put('K','Rakuten');
		salesChanMap.put('N','Amazon JP');
		salesChanMap.put('H','Yahoo JP');
		salesChanMap.put('T','Tmall Global');
		salesChanMap.put('V','Brand Website');
		salesChanMap.put('M','Brand Website');
		salesChanMap.put('A','Brand Website');
		salesChanMap.put('D','Brand Website');
		salesChanMap.put('J','Brand Website');
		salesChanMap.put('Y','Brand Website');
		salesChanMap.put('P','Brand Website');
		*/

		for (Orders__c o: orderList) {
			// DE880 -- get sales channel string from custom setting
			String sSalesChannel = String.IsBlank(o.Webstack_Id__c)? null : WebStoresData__c.getValues(o.Webstack_Id__c).Sales_Channel__c;
			//Adding Jason's changes for new web stores because NBTY is making this a headache.
			if (o.Third_Party_Order_Number__c != null) {
				system.debug('--------------------------Inside third party if statement: ' + o.Credit_Card_Type__c);
				if (o.Webstack_ID__c == '1') {
					o.Sales_Channel__c = 'OrderGroove';
				} else {
					o.Sales_Channel__c = sSalesChannel; // DE880 -- removed: salesChanMap.get(o.Credit_Card_Type__c);
				}
				/*if (o.Credit_Card_Type__c == 'Z') {
					o.Sales_Channel__c = 'Amazon';
				} else if (o.Credit_Card_Type__c == 'K') {
					o.Sales_Channel__c = 'Rakuten';
				} else if (o.Webstack_ID__c =='1') {
					o.Sales_Channel__c='OrderGroove';
				} else if (o.Credit_Card_Type__c == 'N') {
					o.Sales_Channel__c = 'Amazon JP';
				} else if (o.Credit_Card_Type__c == 'H') {
					o.Sales_Channel__c = 'Yahoo JP';
				} else if (o.Credit_Card_Type__c == 'T') {
					o.Sales_Channel__c = 'Tmall Global';
				}*/
			} else if (o.Webstack_Order_ID__c == null || o.Webstack_Order_ID__c == '') {
				system.debug('--------------------------Inside null Webstack if statement: ' + o.Credit_Card_Type__c);
				o.Sales_Channel__c = string.isblank(o.Sales_Channel__c)?'Phone':o.Sales_Channel__c;
			} else /*if (o.Sales_Channel__c == null || o.Sales_Channel__c == '')*/ {
				system.debug('--------------------------Inside else statement: ' + o.Credit_Card_Type__c);
				o.Sales_Channel__c = 'Brand Website';
			}
			
			Map<String, Credit_Card_Type_Mapping__c> ccTMap = new Map<String, Credit_Card_Type_Mapping__c>();
			if (o.Credit_Card_Type__c != null) {
				if (o.Credit_Card_Type__c.length() > 1) {
					cctMap = NBTYUtils.getCCTypeMappings('Name');
					Credit_Card_Type_Mapping__c cctm1 = ccTMap.get(o.Credit_Card_Type__c);
					if (cctm1 != null) {
						o.Payment_Type__c = cctm1.Payment_Method__c;
					} else {
						o.addError(o.Credit_Card_Type__c + ' is not a valid credit card type.');
					}
				} else {
					cctMap = NBTYUtils.getCCTypeMappings('Web');
					Credit_Card_Type_Mapping__c cctm2 = ccTMap.get(o.Credit_Card_Type__c);
					if (cctm2 != null) {
						o.Payment_Type__c = cctm2.Payment_Method__c;
					} else {
						o.addError(o.Credit_Card_Type__c + ' is not a valid web credit card type.');
					}
				}
			}
			
			/*if (Credit_Card_Type_Mapping__c.getAll().keySet().contains(o.credit_card_Type__c)) {
				o.Payment_Type__c = 'Credit Card';
			} else if (o.Credit_Card_Type__c == 'Y') {
				o.Payment_Type__c = 'Paypal';
			}*/
			
			if (o.Credit_Card_Type__c == 'P') {
				o.Order_Status__c = 'Internal Review';
				o.Internal_Review_Reason__c = 'Missing payment information';
			}
			if (o.Credit_Card_Type__c !=null) {
				Map<String, Credit_Card_Type_Mapping__c> ccTypeMap = new Map<String, Credit_Card_Type_Mapping__c>();
				system.debug('-------------------------Credit_Card_Type__c: ' + o.Credit_Card_Type__c);
				if (o.Credit_Card_Type__c.length() > 1) {
					ccTypeMap = NBTYUtils.getCCTypeMappings('Name');
					system.debug('----------------------------------------ccTypeMap1: ' + ccTypeMap);
					Credit_Card_Type_Mapping__c cctm = ccTypeMap.get(o.Credit_Card_Type__c);
					system.debug('----------------------------------------cctm1: ' + cctm);
					if (cctm != null) {
						o.Credit_Card_Type__c = cctm.Name;
					}
					//o.Credit_Card_Type__c = NBTYUtils.getCCTypeMappings('Name').get(o.Credit_Card_Type__c).Name;
				} else {
					ccTypeMap = NBTYUtils.getCCTypeMappings('Web');
					system.debug('----------------------------------------ccTypeMap2: ' + ccTypeMap);
					Credit_Card_Type_Mapping__c cctm = ccTypeMap.get(o.Credit_Card_Type__c);
					system.debug('----------------------------------------cctm2: ' + cctm);
					if (cctm != null) {
						o.Credit_Card_Type__c = cctm.Name;
					}
					//o.Credit_Card_Type__c = NBTYUtils.getCCTypeMappings('Web').get(o.Credit_Card_Type__c).Name;
				}
			}
		}
	}
	
	public static void setSequenceNumber(List <Orders__c> orderList, Map <Id, Orders__c> oldMap){
		for (Orders__c o: orderList){
			if (o.Order_Status__c=='Pending Submission'&&oldMap.get(o.id).Order_Status__c!='Pending Submission'){
				if (o.Sequence_Number__c==null){
					string orderNumber =o.name;
					if (orderNumber.length()==8) orderNumber='00'+orderNumber;
					else if (orderNumber.length()==9) orderNumber='0'+orderNumber;
					o.Sequence_Number__c=orderNumber;
				}
			}
		}
	}
	
	public static void checkAvalaraSubmit(List <Orders__c> orderList, Map <Id, Orders__c> oldMap){
		for (Orders__c o: orderList){
			if (o.Order_Status__c!=oldMap.get(o.id).Order_Status__c && o.Order_Status__c=='Submitted'&& !system.isBatch() && !system.isFuture()){	
				AvalaraTaxCalc.CalculateTax_OrderSubmission_Future(o.id);
			}
		}
	}
	
	
	public static void ValidateBeforeDelete(List<Orders__c> triggerOld){
		for(Orders__c ord : triggerOld){
			if(ord.Order_Submitted__c&&!isDeleteAllowed){
				ord.addError('Order has been submitted to AS400 and cannot be deleted.');
			}
		}
	}
	
	public static void checkReturns(List <Orders__c> orderList){
		for(Orders__c o : orderList){
			if(o.Return__c && o.Return_Reason__c == null){ 
				o.addError('When "Return?" is checked there must be a Return Reason and Return Credit Type be entered.');
			}
			if ((o.Return_Refund_Type__c == null || o.Return_Refund_Type__c == '') && o.Return__c ) {
				o.addError('When "Return?" is checked there must be a Return Reason and Return Credit Type be entered.');
			}
			
		}
	}
	
	public static void checkForSubmissionFailedOrders(List <Orders__c> orderList, Map <Id, Orders__c> oldMap){
		Set<Id> orderIds = new Set <Id>();
		Map <Id, Orders__c> orderMap = new Map <Id, Orders__c>();
		Map <String, Group> oQueueMap = new Map <String, Group>();
		
		for(Orders__c o:orderList ){
			//R3 US 64838316
			if (o.Order_Status__c!=oldMap.get(o.id).Order_Status__c && o.Order_Status__c=='Waiting on Full Payment'){
				orderIds.add(o.Id);
			}
			//END R3 US 64838316
			else if (o.Order_Status__c!=oldMap.get(o.id).Order_Status__c && o.Order_Status__c=='Submission Failed'){
				orderIds.add(o.Id);
			}
			else if (o.Order_Status__c!=oldMap.get(o.id).Order_Status__c && o.Order_Status__c=='Internal Review'){
				orderIds.add(o.Id);
			}
			if (o.Order_Id__c=='Submitted' && oldMap.get(o.id).order_status__c =='Submitted'){
				o.OwnerId=userInfo.getUserId();
			}
		}
		if (!orderIds.isEmpty()) {
			for (Orders__c o: [select id, customer__r.recordType.developerName FROM Orders__c Where id in: orderIds]){
				orderMap.put(o.id, o);
			}
			
			string groupType = 'Queue';
			for(Group g: [Select Id, Name From Group Where Type = :groupType]){
				oQueueMap.put(g.Name,g);
			}
			
			for(Orders__c o: orderList){
				if (orderIds.contains(o.id)){
					string queueName;
					if (o.Order_Status__c!=oldMap.get(o.id).Order_Status__c && o.Order_Status__c=='Submission Failed'){	
						queueName = 'Admin - Bad Orders';
					}
					//R3 US 64838316
					else if (o.Order_Status__c!=oldMap.get(o.id).Order_Status__c && o.Order_Status__c=='Waiting on Full Payment'){	
						queueName = 'Awaiting Physical Payment';
					}
					//END R3 US 64838316
					else{
						string rtname = orderMap.get(o.id).customer__r.recordType.developername;
						queueName = NBTYUtils.getRecordTypeBrandMappingMap().get(rtname).back_office_queue__c;
  					}
					if ( oQueueMap.get(queueName)!=null){
						o.OwnerId = oQueueMap.get(queueName).Id; 
					}
				}
			}
		}
	}
	
	public static void checkBadCust(List <Orders__c> triggerNew) {
		Set<Id> ordIdSet = new Set<Id>();
		for (Orders__c o1 : triggerNew) {
			ordIdSet.add(o1.Id);
		}
		List<Orders__c> ordList = reQueryOrder(ordIdSet);
		Set<String> zipSet = new Set<String>();
		Set<String> addrSet = new Set<String>();
		Set<String> emailSet = new Set<String>();
		for (Orders__c o2 : ordList) {
			if (o2.Bill_To_Address__r.Zip_Code__c != null) {
				zipSet.add(o2.Bill_To_Address__r.Zip_Code__c);
			}
			if (o2.Bill_To_Address__r.Foreign_Postal_Code__c != null) {
				zipSet.add(o2.Bill_To_Address__r.Foreign_Postal_Code__c);
			}
			if (o2.Bill_To_Address__r.Address_Line_1__c != null) {
				addrSet.add(o2.Bill_To_Address__r.Address_Line_1__c);
			}
			if (o2.Ship_To_Address__r.Zip_Code__c != null) {
				zipSet.add(o2.Ship_To_Address__r.Zip_Code__c);
			}
			if (o2.Ship_To_Address__r.Foreign_Postal_Code__c != null) {
				zipSet.add(o2.Ship_To_Address__r.Foreign_Postal_Code__c);
			}
			if (o2.Ship_To_Address__r.Address_Line_1__c != null) {
				addrSet.add(o2.Ship_To_Address__r.Address_Line_1__c);
			}
			if (o2.Customer__r.PersonEmail != null) {
				emailSet.add(o2.Customer__r.PersonEmail);
			}
			if (o2.customer__r.Alternate_Email__c != null) {
				emailSet.add(o2.Customer__r.Alternate_Email__c);
			}
		}
		
		List<Bad_Customer__c> badCustList = getBadCustRecords(zipSet,addrSet,emailSet);
		Set<String> bcZip;
		Set<String> bcAddr;
		Set<String> bcEmail;
		if (badCustList != null && badCustList.size() > 0) {
			bcZip = splitBadCust(badCustList, zipStr);
			bcAddr = splitBadCust(badCustList, addrStr);
			bcEmail = splitBadCust(badCustList, emailStr);
			Map<String, Id> bcMap = mapBC(badCustList);
			compareToBadCust(ordList, bcZip, bcAddr, bcEmail, bcMap);
		}
		
		
	}
	
	public static void compareToBadCust(List <Orders__c> ordList, Set<String> zip, Set<String> addr, Set<String> email, Map<String,Id> bcMap) {
		List<Orders__c> badOrders = new List<Orders__c>();
		for (Orders__c ord : ordList) {
			Boolean isBad = false;
			Boolean isBadAddr = false;
			Boolean isBadBillAddrUS = false;
			Boolean isBadBillAddrFO = false;
			Boolean isBadShipAddrUS = false;
			Boolean isBadShipAddrFO = false;
			Boolean isBadEmail = false;
			if ((zip.contains(ord.Bill_To_Address__r.Zip_Code__c) && addr.contains(ord.Bill_To_Address__r.Address_Line_1__c))) {
				isBad = true;
				isBadBillAddrUS = true;
				isBadAddr = true;
			} else if ((zip.contains(ord.Ship_To_Address__r.Zip_Code__c) && addr.contains(ord.Ship_To_Address__r.Address_Line_1__c))) {
				isBad = true;
				isBadShipAddrUS = true;
				isBadAddr = true;
			}
			if ((zip.contains(ord.Bill_To_Address__r.Foreign_Postal_Code__c) && addr.contains(ord.Bill_To_Address__r.Address_Line_1__c))) {
				isBad = true;
				isBadBillAddrFO = true;
				isBadAddr = true;
			} else if ((zip.contains(ord.Ship_To_Address__r.Foreign_Postal_Code__c) && addr.contains(ord.Ship_To_Address__r.Address_Line_1__c))) {
				isBad = true;
				isBadShipAddrFO = true;
				isBadAddr = true;
			}
			
			
			if (email.contains(ord.Customer__r.PersonEmail) || email.contains(ord.Customer__r.Alternate_Email__c)) {
				isBad = true;
				isBadEmail = true;
			}
			if (isBad && ord.Order_Status__c != 'Cancelled') {
				ord.Potential_Fraud__c = true;
				ord.Order_Status__c = 'Possible Fraud';
				// TODO: Change owner to appropriate queue
				if (isBadAddr) {
					String mapGetStr = '';
					if (isBadBillAddrUS) {
						mapGetStr = ord.Bill_To_Address__r.Address_Line_1__c + '-' + ord.Bill_To_Address__r.Zip_Code__c;
					} else if (isBadShipAddrUS) {
						mapGetStr = ord.Ship_To_Address__r.Address_Line_1__c + '-' + ord.Ship_To_Address__r.Zip_Code__c;
					} else if (isBadBillAddrFO) {
						mapGetStr = ord.Bill_To_Address__r.Address_Line_1__c + '-' + ord.Bill_To_Address__r.Foreign_Postal_Code__c;
					} else if (isBadShipAddrFO) {
						mapGetStr = ord.Ship_To_Address__r.Address_Line_1__c + '-' + ord.Ship_To_Address__r.Foreign_Postal_Code__c;
					}
					Id bcId1 = bcMap.get(mapGetStr);
					if (bcId1 != null) {
						ord.Related_Bad_Address__c = bcId1;
					}
				}
				
				if (isBadEmail) {
					Id bcId2 = bcMap.get(ord.Customer__r.PersonEmail);
					if (bcId2 == null) {//then its the alternate email that is bad
						bcId2 = bcMap.get(ord.Customer__r.Alternate_Email__c);
					}
					ord.Related_Bad_Email__c = bcId2;
				}
				badOrders.add(ord);
			}
		}
		
		Set<Id> acctIds = new Set<Id>();
		for (Orders__c bOrd : badOrders) {
			acctIds.add(bOrd.Customer__c);
		}
		List<Account> bAccts = getAccounts(acctIds);
		for (Account a : bAccts) {
			a.Possible_Fraud__c = true;
		}
		skipUpdateTrigger = true;
		update badOrders;
		update bAccts;
		skipUpdateTrigger = false;
	}
	
	public static Map<String, Id> mapBC(List<Bad_Customer__c> bcList) {
		Map<String, Id> bcMap = new Map<String, Id>();
		for (Bad_Customer__c bc : bcList) {
			bcMap.put(bc.Bad_Address__c + '-' + bc.Bad_Zip__c, bc.Id);
			bcMap.put(bc.Bad_Email__c, bc.Id);
		}
		return bcMap;
	}
	
	public static List<Account> getAccounts(Set<Id> acctIds) {
		List<Account> customers = [SELECT Id, Possible_Fraud__c FROM Account WHERE Id IN :acctIds];
		return customers;
	}
	
	public static Set<String> splitBadCust(List<Bad_Customer__c> bcList, String dataType) {
		Set<String> dataSet = new Set<String>();
		for (Bad_Customer__c bc : bcList) {
			if (dataType == zipStr) {
				dataSet.add(bc.Bad_Zip__c);
			} else if (dataType == addrStr) {
				dataSet.add(bc.Bad_Address__c);
			} else if (dataType == emailStr) {
				dataSet.add(bc.Bad_Email__c);
			}
		}
		return dataSet;
	}
	
	public static List<Orders__c> reQueryOrder(Set<Id> ordIdSet) {
		List<Orders__c> ordersList = [SELECT Id, Name, Bill_To_Address__r.Zip_Code__c, Bill_To_Address__r.Foreign_Postal_Code__c, Bill_To_Address__r.Address_Line_1__c, Order_Status__c, 
										Ship_To_Address__r.Zip_Code__c, Ship_To_Address__r.Foreign_Postal_Code__c, Ship_To_Address__r.Address_Line_1__c, 
										Customer__r.PersonEmail, Customer__r.Alternate_Email__c 
										FROM Orders__c WHERE Id IN :ordIdSet];
		return ordersList;
	}
	
	public static List<Bad_Customer__c> getBadCustRecords(Set<String> zip, Set<String> addr, Set<String> email) {
		List<Bad_Customer__c> badCList = [SELECT Id, Bad_Email__c, Bad_Address__c, Bad_Zip__c, isActive__c FROM Bad_Customer__c 
											WHERE ((Bad_Address__c IN :addr AND Bad_Zip__c IN :zip) OR Bad_Email__c IN :email) AND isActive__c = true];
		return badCList;
	}
	
	public static void unRedeemVWCoupon(List<Orders__c> triggerNew) {
		Set<Id> ordIds = new Set<Id>();
		for (Orders__c o1 : triggerNew) {
			ordIds.add(o1.Id);
		}
		
		List<Allowance__c> allowList = [SELECT Id, Allowance_Code__c, VW_Loyalty_Coupon_Code__c, Order__c, Redeemed__c FROM Allowance__c 
										WHERE Order__c IN :ordIds];
		Map<Id, List<Allowance__c>> ordAllowMap = orderAllowanceMap(triggerNew, allowList);
		Set<Id> allowanceIds = new Set<Id>();
		Set<Id> orderIds = new Set<Id>();
		for (Orders__c ord : triggerNew) {
			system.debug('-------------------------------first for loop');
			if (ord.Order_Status__c == 'Cancelled') {
				system.debug('-------------------------------first if');
				List<Allowance__c> allowance = ordAllowMap.get(ord.Id);
				if (allowance != null) {
					system.debug('-------------------------------Second If');
					for (Allowance__c a2 : allowance) {
						system.debug('-------------------------------Second for loop');
						if (String.isNotBlank(a2.VW_Loyalty_Coupon_Code__c) && a2.Redeemed__c) {
							system.debug('-------------------------------third if');
							allowanceIds.add(a2.Id);
							orderIds.add(ord.Id);
						}
					}
				}
			}
		}
		system.debug('-------------------------------About to call future method');
		if (allowanceIds.size() > 0) {
			system.debug('-------------------------------call future method');
			WS_SOA_LoyaltyServicesUtils.futureUnRedeem(orderIds, allowanceIds);
		}
	}
	
	public static Map<Id, List<Allowance__c>> orderAllowanceMap(List<Orders__c> ordList, List<Allowance__c> aList) {
		Map<Id, List<Allowance__c>> ordAllowMap = new Map<Id, List<Allowance__c>>();
		for (Orders__c o2 : ordList) {
			List<Allowance__c> mapList = new List<Allowance__c>();
			for (Allowance__c a1 : aList) {
				if (a1.Order__c == o2.Id) {
					mapList.add(a1);
				}
			}
			if (mapList.size() > 0) {
				ordAllowMap.put(o2.Id, mapList);
			}
		}
		return ordAllowMap;
	}
	
}