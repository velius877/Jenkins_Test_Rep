/*
	WS_OrderStatusQueryUtils
	DESCRIPTION
	------------------------------------------------------------------
	Author		|	Date		|	Description
	------------------------------------------------------------------
	Gary Alfrey |	10/21/13	|	Created

*/

public class WS_OrderStatusQueryUtils {
	
	public static Map<Id, String> suffixMap;
	
	public static WS_OrderStatusQuery.OrderStatusQueryResponse_element doCallout(Id orderId){
		try{
			system.debug('-------------------------------------------OrderId: ' + orderId);
			Orders__c ord = getOrders(orderId);
			WS_OrderStatusQuery.OrderStatusQueryResponse_element response_Element = getResponse(ord);
			system.debug('--------------------------------------Response_Element: ' + response_Element);
			return response_Element;
		}catch(Exception e){
			system.debug('------------------------------------------------------Exception: ' + e);
			logError(e);
			//here I should create a new fault response manually and return that - only way to display failed callouts
			WS_OrderStatusQuery.OrderStatusQueryResponse_element err = new WS_OrderStatusQuery.OrderStatusQueryResponse_element();
			WS_OrderStatusQuery.OrderStatusFault f = new WS_OrderStatusQuery.OrderStatusFault();
			f.FaultMessage = e.getMessage();
			f.FaultCode = e.getTypeName();
			err.OrderStatusFault = f;
			return err;
		}
	}

	public static Orders__c getOrders(Id orderId){
		Orders__c currOrder = [SELECT Id, Name, Webstack_Order_ID__c FROM Orders__c WHERE Id = :orderId];
		return currOrder;
	}  
	
	public static WS_OrderStatusQuery.OrderStatusQueryResponse_element getResponse(Orders__c ord){
		WS_OrderStatusQuery.OrderQueryPort statusQuery = new WS_OrderStatusQuery.OrderQueryPort();
		String padOrdNum = orderUtilities.zeroLPAD(ord.name, 10);
		// DE866 -- Adding padding for webstack order id; Peter R reports it's not searching bad one's correctly;
		// Mindtree stated it was because of the lack of padding.
		// DE885 -- send null when null not zeros
		String padWebNum = String.IsBlank(ord.Webstack_Order_ID__c) ? null : orderUtilities.zeroLPAD(ord.Webstack_Order_ID__c, 10);
		return statusQuery.OrderStatusQuery(padWebNum, padOrdNum);
	}
	
	public static List<Order_Line_Item_Status_Detail__c> processSuccess(WS_OrderStatusQuery.OrderStatusSuccess resp){
		try{
			//Parse response and create Status Detail records
			List<Order_Line_Item_Status_Detail__c> olisd = new List<Order_Line_Item_Status_Detail__c>();
			Datetime dt = Datetime.now();
			Orders__c ord = queryOrder(resp.SFOrderNumber);
			Map<String, OrderStatusMap__c> osmMap = getOsmMap();
			if (resp.LineItemList.LineItem != null) {
				Map<String, Item__c> itemMap = getItemMap(resp.LineItemList);
				system.debug('----------------------------------------------itemMap: ' + itemMap);
				Set<String> pNums = getProdNums(resp.LineItemList);
				Map<String, Order_Line_Items__c> prodNumToOliMap = getMapPNumsToOli(ord, pNums);
				
				for(WS_OrderStatusQuery.LineItem li : resp.LineItemList.LineItem){
					String x1 = padItemNumbers(li.OriginalSkuId);
					String x2 = padItemNumbers(li.NewSkuId);
					system.debug('----------------------------------------------Original Padded: ' + x1);
					system.debug('----------------------------------------------New Padded: ' + x2);
					Order_Line_Items__c oli = prodNumToOliMap.get(padItemNumbers(li.OriginalSkuId));
					system.debug('-----------------------------------------------------------------------oli: ' + oli);
					if(oli != null){
						system.debug('--------------------------------------------------------Existing Line Item');
						olisd.add(newOlisd(oli, ord, li, osmMap, dt, itemMap, resp));
					}else{//Logic for free items
						system.debug('--------------------------------------------------------Possible Free Item');
						string prodKey = NBTYUtils.getRecordTypeBrandMappingMap().get(ord.Customer__r.RecordType.DeveloperName).Product_Suffix_c__c + '-' + padItemNumbers(li.OriginalSkuId);
						system.debug('-------------------------------------------------ProdKey: ' + prodKey);
						Item__c item = itemMap.get(prodKey); //must get item by suffix
						if (item != null) {
							olisd.add(newOlisd(null, ord, li, osmMap, dt, itemMap, resp));
						}//else this item doesn't exist.
					}
				}
			} else {//this is probably a bad order or error screen response in header only
				system.debug('---------------------------------------------------------Error File / BO File');
				Order_Line_Item_Status_Detail__c sd = new Order_Line_Item_Status_Detail__c();
				sd.Time_Stamp__c = dt;
				sd.Order__c = ord.Id;
				sd.Order_Status_Code__c = resp.OrderStatus;
				sd.Order_Status_Description__c = resp.OrderStatusDetail;
				OrderStatusMap__c osm4 = osmMap.get(resp.OrderStatus);
				if (osm4 != null) {
					sd.Order_Status__c = osm4.SFDC_Order_Status__c;
				}
				olisd.add(sd);
			}
			
			system.debug('----------------------------------------------------------------------olisd: ' + olisd);
			if(olisd.size() > 0){
				insert olisd;
			}
			Set<Id> olisdIds = new Set<Id>();
			for(Order_Line_Item_Status_Detail__c q : olisd){
				olisdIds.add(q.Id);
			}
			List<Order_Line_Item_Status_Detail__c> ordStatusDetails = [SELECT Id, Order__r.Name, Order_Status__c, Order_Line_Item__r.Name, 
								Current_Sku__c, Current_Quantity__c, Order_Status_Description__c, 
								Order_Line_Item__r.Line_Number__c, Current_Status__c, Name, Current_Item__c, Previous_Item__c, Previous_Sku__c, 
								Disposition_Number__c, Free_Item__c, IsLineSplit__c, Credit_Rejected__c, Tracking_Number__c, Shipper__c, 
								Previous_Quantity__c, Current_Status_Code__c, Order_Status_Code__c, Tracking_Link__c 
								FROM Order_Line_Item_Status_Detail__c WHERE Id IN: olisdIds];
			return ordStatusDetails;
		}catch(Exception e){
			return null;
		}
	}
	
	public static List<Order_Line_Item_Status_Detail__c> getCurrentOlisds(Id orderId){
		return [SELECT Id, Name, Current_Quantity__c, Current_Status_Code__c, Current_Status__c, Credit_Rejected__c, Order_Status_Description__c, 
													Disposition_Number__c, Previous_Quantity__c, Shipper__c, Tracking_Number__c, Order__c, Order_Status_Code__c, 
													Order_Status__c, Order_Line_Item__c, Current_Sku__c, current_item__c, Previous_Sku__c, IsLineSplit__c 
													FROM Order_Line_Item_Status_Detail__c WHERE Order__c = :orderId];
	}
	
	public static String processFault(WS_OrderStatusQuery.OrderStatusFault resp){
		//Parse response and create error log
		String fault = resp.FaultCode + ': ' + resp.FaultMessage;
		return fault;
	}
	
	public static Order_Line_Item_Status_Detail__c newOlisd(Order_Line_Items__c oli, Orders__c ord, WS_OrderStatusQuery.LineItem lineItem, Map<String, OrderStatusMap__c> osmMap, Datetime dt, Map<String, Item__c> itemMap, WS_OrderStatusQuery.OrderStatusSuccess resp){
		system.debug('----------------------------------------------------------------------starting order line item status details');
		Order_Line_Item_Status_Detail__c sd = new Order_Line_Item_Status_Detail__c();
		sd.Time_Stamp__c = dt;
	
		if(lineItem.ShippingDetail.NewQuantity != null && lineItem.ShippingDetail.NewQuantity != ''){
			sd.Current_Quantity__c = Integer.valueOf(lineItem.ShippingDetail.NewQuantity);
		}else {
			sd.Current_Quantity__c = Integer.valueOf(lineItem.ShippingDetail.OriginalQuantity);
		}
		
		OrderStatusMap__c osm2 = osmMap.get(lineItem.NewItemStatus);
		OrderStatusMap__c osm4 = osmMap.get(resp.orderStatus);
		
		if(lineItem.NewItemStatus != null && lineItem.NewItemStatus != ''){
			sd.Current_Status_Code__c = lineItem.NewItemStatus;
			sd.Current_Status__c = osm2 != null? osm2.SFDC_Order_Line_Status__c :null;
		}
		
		if(lineItem.CreditReject == 'Y' || lineItem.CreditReject == 'YES'){
			sd.Credit_Rejected__c = true;
		}else {
			sd.Credit_Rejected__c = false;
		}
		sd.Disposition_Number__c = lineItem.DispositionNumber;
		sd.Previous_Quantity__c = Integer.valueOf(lineItem.ShippingDetail.OriginalQuantity);
		sd.Shipper__c = lineItem.ShippingDetail.Shipper;
		sd.Tracking_Number__c = lineItem.ShippingDetail.TrackingNumber;
		sd.Tracking_Link__c = trackingLinkURL(sd.Shipper__c, sd.Tracking_Number__c);
		sd.Order__c = ord.Id;
		sd.Order_Status_Code__c = resp.orderStatus;
		sd.Order_Status_Description__c = resp.OrderStatusDetail;
		if(osm4 != null){
			sd.Order_Status__c = osm4.SFDC_Order_Status__c;
		}
		
		if(oli != null){
			sd.Order_Line_Item__c = oli.Id;
		}else {
			sd.Free_Item__c = true;
		}
		
		if(lineItem.NewSkuId != null && lineItem.NewSkuId != ''){
			sd.Current_Sku__c = lineItem.NewSkuId;
		}else {
			sd.Current_Sku__c = lineItem.OriginalSkuId;
		}
		string suffix = NBTYUtils.getRecordTypeBrandMappingMap().get(ord.Customer__r.RecordType.DeveloperName).Product_Suffix_c__c;
		system.debug('----------------------------------------------------------------------suffix: ' + suffix);
		string currentProdKey = suffix + '-' + sd.Current_Sku__c;
		system.debug('----------------------------------------------------------------------currentProdKey: ' + currentProdKey);
		sd.current_item__c = itemMap.get(currentProdKey).id;
		system.debug('----------------------------------------------------------------------sd.current_item__c: ' + sd.current_item__c);
		
		if(lineItem.OriginalSkuId != null && lineItem.OriginalSkuId != ''){
			sd.Previous_Sku__c = lineItem.OriginalSkuId;
			string prevProdKey = NBTYUtils.getRecordTypeBrandMappingMap().get(ord.Customer__r.RecordType.DeveloperName).product_suffix_c__c + '-' + sd.Previous_Sku__c;
			sd.Previous_item__c = itemMap.get(prevProdKey).id;
		}
		if(lineItem.ShippingDetail.NewQuantity != null && lineItem.ShippingDetail.NewQuantity != '' && (lineItem.NewSkuId == null || lineItem.NewSkuId == '')){
			sd.IsLineSplit__c = true;
		}
		system.debug('----------------------------------------------------------------------sd: ' + sd);
		return sd;
	}
	
	public static String trackingLinkURL(String shipper, String trackingNum) {
		system.debug('-------------------------------------------------Shipper: ' + shipper);
		system.debug('-------------------------------------------------trackingNum: ' + trackingNum);
		String url = '';
		String baseURL = '';
		if (shipper != null && trackingNum != null) {
			if (shipper.contains('UPS')) {
				url = WS_Integration__c.getValues('UPS_Tracking').value__c + trackingNum;
			} else if (shipper.contains('Parcel Post') || shipper.contains('Fedex')) {
				url = WS_Integration__c.getValues('USPS_Fedex_Tracking').value__c + trackingNum;
			}
		}
		
		return url;
	}
	
	public static List<Order_Line_Item_Status_Detail__c> getCurrentOLISD(){
		return null;
	}
	
	public static Map<String, Order_Line_Items__c> getMapPNumsToOli(Orders__c ord, Set<String> prodNums){
		List<Order_Line_Items__c> oliList = [SELECT Order__r.Customer__r.RecordType.DeveloperName, Id, Product_Number__c, Product_ID__c, Product_Quantity__c, 
											Quantity_Shipped__c, Shipper__c, Shipment_Tracking_Number__c, Shipped_Complete__c, Product_Name__c, Item_Status_Code__c, 
											Update_Quantity__c 
											FROM Order_Line_Items__c WHERE Order__c = :ord.Id AND Shipped_Complete__c != true 
											AND Product_Number__c IN: prodNums];
			
		Map<String, Order_Line_Items__c> prodNumToOliMap = new Map<String, Order_Line_Items__c>();
		for(Order_Line_Items__c oli1 : oliList){
			prodNumToOliMap.put(oli1.Product_Number__c, oli1);
		}
		return prodNumToOliMap;
	}
	
	public static Orders__c queryOrder(String ordNum){
		while (ordNum.startsWith('0')){
			ordNum = ordNum.removeStart('0');
		}
		Orders__c ord = [SELECT Id, Customer__r.RecordType.DeveloperName, Order_Status__c, Sequence_Number__c, Order_Status_Description__c, Order_Status_Code__c  
							FROM Orders__c WHERE Name = :ordNum];
		return ord;
	} 
	
	public static Map<String, OrderStatusMap__c> getOsmMap(){
		List<OrderStatusMap__c> osmList = OrderStatusMap__c.getall().values();
		system.debug('-------------------------------------------------------osmList: ' + osmList);
		Map<String, OrderStatusMap__c> osmMap1 = new Map<String, OrderStatusMap__c>();
		for(OrderStatusMap__c osm : osmList){
			osmMap1.put(osm.Name, osm);
		}
		return osmMap1;
	}
	
	public static Map<String, Item__c> getItemMap(WS_OrderStatusQuery.LineItemList lil){
		Set<String> prodNums = getProdNums(lil);
		system.debug('---------------------------------------------------------------------------------checking item numbers: ' + prodNums);
		
		List<Item__c> itemList = [SELECT Id, Product_Number__c, Product_Suffix__c 
		 							FROM Item__c WHERE Product_Number__c IN: prodNums];
		system.debug('---------------------------------------------------------------------------------itemList: ' + itemList);
		Map<String, Item__c> itemMap1 = new Map<String, Item__c>();
			
		if(itemList != null){
			for(Item__c c : itemList){
				string prodKey = c.product_suffix__c + '-' + c.product_number__c;
				itemMap1.put(prodKey, c);
			}
		}
		return itemMap1;
	}
	
	public static Set<String> getProdNums(WS_OrderStatusQuery.LineItemList lil){
		Set<String> prodNums1 = new Set<String>();
		for(WS_OrderStatusQuery.LineItem a : lil.LineItem){
			prodNums1.add(a.OriginalSkuId);
			prodNums1.add(a.NewSkuId);
		}
		Set<String> pNums = new Set<String>();
			for(String p : prodNums1){
				String itNum = padItemNumbers(p);
				pNums.add(itNum);
			}
		return pNums;
	}
	
	public static String padItemNumbers(String itemNum){
		String x = '';
		if(itemNum.length() == 1){
			x = '00000' + itemNum;
		}else if(itemNum.length() == 2){
			x = '0000' + itemNum;
		}else if(itemNum.length() == 3){
			x = '000' + itemNum;
		}else if(itemNum.length() == 4){
			itemNum = '00' + itemNum;
		}else if(itemNum.length() == 5){
			x = '0' + itemNum;
		}else if(itemNum.length() == 6){
			x = itemNum;
		}
		return x;		
	}
	
	public static String logError(Exception e){
		Error_Log__c err = new Error_Log__c();
		err.Error_Line_Number__c = e.getLineNumber();
		err.Error_Message__c = e.getMessage();
		err.Error_Stack_Trace__c = e.getStackTraceString();
		err.Error_Type__c = e.getTypeName();
		insert err;
		return err.Id;
	}
	
	
	
}