/* 
	OrderStatusQueryUtils
	DESCRIPTION
	------------------------------------------------------------------
	Author		|	Date		|	Description
	------------------------------------------------------------------
	Gary Alfrey |	10/21/13	|	Created

*/

public without sharing class OrderStatusQueryUtils {
	
	
	//Static Helper method for rolling-up status updates
	@future 
	public static void processUpdates(Set<String> idList){
		try{
			orderTriggerHelper.skipUpdateTrigger = true;
			List<Order_Line_Item_Status_Detail__c>olisdList = [SELECT Tracking_Number__c, Time_Stamp__c, Shipper__c, Previous_Status__c, 
									Previous_Status_Code__c, Order_Status_Description__c, Previous_Sku__c, Previous_Quantity__c, 
									Previous_Item__c, Order__c, Order_Status__c, Order_Status_Code__c, Order_Line_Item__c, Name, 
									IsLineSplit__c, Id, Free_Item__c, Disposition_Number__c, Current_Status__c,  
									Current_Status_Code__c, Current_Sku__c, Current_Quantity__c, Current_Item__c, Credit_Rejected__c 
									FROM Order_Line_Item_Status_Detail__c WHERE Id IN: idList];
			
			if(olisdList.size() > 0){
				processItemSubtitution(olisdList);
			}
		}catch(exception e){
			
		}
	}
	
	public static void processItemSubtitution(List<Order_Line_Item_Status_Detail__c> subList){
		/***************************DATA SETUP****************************/
		Set<String> prodNums = getProdNums(subList);
		Map<String, Item__c> itemMap = getItemMapping(prodNums);
		Set<Id> oliIdSet = getOliIds(subList);
		Map<Id, List<Order_Line_Item_Status_Detail__c>> statusMap = getStatusDetailsMap(subList);
		List<Order_Line_Items__c> oliList = getOliList(oliIdSet);
		/***************************END DATA SETUP************************/
		
		List<Order_Line_Items__c> oliUpdateList = new List<Order_Line_Items__c>();
		Set<Order_Line_Items__c> oliUpdateSet = new Set<Order_Line_Items__c>();
		Map<Id, Order_Line_Items__c> oliUpdateMap = new Map<Id, Order_Line_Items__c>();
		for(Order_Line_Items__c oli : oliList){
			List<Order_Line_Item_Status_Detail__c> olisdList = statusMap.get(oli.Id);
			system.debug('-----------------------------------------------------------------------------oli: ' + oli);
			
			if(olisdList.Size() > 0){
				for(Order_Line_Item_Status_Detail__c olisd : olisdList){
					//Check to see if there has been a sku change
					if(olisd.Previous_Sku__c != null && olisd.Previous_Sku__c != '' && olisd.Previous_Sku__c != olisd.Current_Sku__c){
						//Get new item from Item Map
						Item__c item = itemMap.get(olisd.Current_Sku__c);
						if(item != null){
							oli.Substituted_Item__c = item.id;
							//oli.Product_Name__c = item.Id;
							oli.Update_Quantity__c = olisd.Current_Quantity__c;
						//	oli.Product_Quantity__c = olisd.Current_Quantity__c;
							//oliUpdateList.add(oli);
							//oliUpdateSet.add(oli);
							oliUpdateMap.put(oli.Id, oli);
						}
					}
				}
			}
		}
		if(!oliUpdateMap.isEmpty()){
			//oliUpdateList.addAll(oliUpdateSet);
			system.debug('-----------------------------------------------------------------------------oliUpdateMap: ' + oliUpdateMap);
			//update oliUpdateList;
			Database.SaveResult[] SR =  Database.update(oliUpdateMap.values(), false);//not all or none
			//log errors
		}
		processNormalUpdates(subList);
		
	}
	
	public static void processNormalUpdates(List<Order_Line_Item_Status_Detail__c> normList){
		/***************************DATA SETUP****************************/
		Set<String> prodNums = getProdNums(normList);
		Set<Id> oliIdSet = getOliIds(normList);
		List<Order_Line_Items__c> oliList = getOliList(oliIdSet);
		Map<Id, List<Order_Line_Item_Status_Detail__c>> olisdMap = getOlisdMapping(normList);
		List<Orders__c> ordList = getOrders(normList);
		Map<String, OrderStatusMap__c> osmMap = getOsmMapping();
		/***************************END DATA SETUP************************/
		
		for(Order_Line_Items__c sync1 : oliList){
			List<Order_Line_Item_Status_Detail__c> syncList = olisdMap.get(sync1.Id);
			OrderStatusMap__c osm4 = osmMap.get(sync1.Item_Status_Code__c);
			if(syncList != null){
				for(Order_Line_Item_Status_Detail__c o5 : syncList){
					OrderStatusMap__c osm5 = osmMap.get(o5.Current_Status_Code__c);
					if(osm5 != null){
						if((osm4 == null) || (osm5.Value__c >= osm4.Value__c)){
							sync1.Credit_Rejected__c = o5.Credit_Rejected__c;
							sync1.Item_Status_Code__c = o5.Current_Status_Code__c;
							if(sync1.Item_Status__c != 'CANCELLED'){
								sync1.Item_Status__c = o5.Current_Status__c;
							}
							if(sync1.Item_Status__c != 'CANCELLED'){
								sync1.Item_Status_Description__c = osm5.AS400_Status_Description__c;
							}
							if(sync1.Item_Status__c == 'CANCELLED' && (sync1.Cancel_Reason__c == null || sync1.Cancel_Reason__c == '')){
								sync1.Cancel_Reason__c = osm5.AS400_Status_Description__c;
							}
							sync1.Shipper__c = o5.Shipper__c;
							sync1.Shipment_Tracking_Number__c = o5.Tracking_Number__c;
							if(o5.Current_Status_Code__c == 'SC'){
								sync1.Quantity_Shipped__c = o5.Current_Quantity__c;
							}
						}//else the old value is higher than the new value so leave it alone.Item_Status_Description__cItem_Status__c
					}
				}
			}
		}
		
		for(Orders__c sync2 : ordList){
			List<Order_Line_Item_Status_Detail__c> syncList = olisdMap.get(sync2.Id);
			system.debug('----------------------------------------------syncList: ' + syncList);
			
			if(syncList != null){
				for(Order_Line_Item_Status_Detail__c o5 : syncList){
					system.debug('-------------------------------------------------------------Order_Line_Item_Status_Detail__c o5: ' + o5);
					OrderStatusMap__c osm5 = osmMap.get(o5.Order_Status_Code__c);
					if(osm5 != null){
						system.debug('-------------------------------------------------------------osm5: ' + osm5);
						system.debug('-------------------------------------------------------------Previous Order_Status__c: ' + sync2.Order_Status__c);
						if(sync2.Order_Status__c != 'Cancelled' && sync2.Order_Status__c != 'Pending Submission' && sync2.Order_Status__c != 'Submission Failed'){
							sync2.Order_Status__c = osm5.SFDC_Order_Status__c;
							system.debug('-------------------------------------------------------------New Order_Status__c: ' + sync2.Order_Status__c);
						}
						sync2.Order_Status_Code__c = o5.Order_Status_Code__c;
						sync2.Order_Status_Description__c = o5.Order_Status_Description__c;
						sync2.Credit_Rejected__c = o5.Credit_Rejected__c;
						if (sync2.Order_Status_Code__c == 'ER' || sync2.Order_Status_Code__c == 'BO') {
							if (sync2.International_Address__c == 'Yes') {
								if (sync2.Customer__r.RecordType.DeveloperName == 'Puritans_Pride_Customer') {
									sync2.OwnerId = getErrorQueues('Errors_Puritans_Pride_International');
								} else if (sync2.Customer__r.RecordType.DeveloperName == 'Perfectly_Pure_Customer') {
									sync2.OwnerId = getErrorQueues('Errors_Perfectly_Pure_International');
								} else if (sync2.Customer__r.RecordType.DeveloperName == 'Vitamin_World_Customer') {
									sync2.OwnerId = getErrorQueues('Errors_Vitamin_World_International');
								}
							} else {
								if (sync2.Customer__r.RecordType.DeveloperName == 'Puritans_Pride_Customer') {
									sync2.OwnerId = getErrorQueues('Errors_Puritans_Pride_Domestic');
								} else if (sync2.Customer__r.RecordType.DeveloperName == 'Perfectly_Pure_Customer') {
									sync2.OwnerId = getErrorQueues('Errors_Perfectly_Pure_Domestic');
								} else if (sync2.Customer__r.RecordType.DeveloperName == 'Vitamin_World_Customer') {
									sync2.OwnerId = getErrorQueues('Errors_Vitamin_World_Domestic');
								}
							}
						}
						
						if(osm5.SFDC_Order_Status__c == 'Cancelled'){
							sync2.AS400_Cancellation_Details__c = osm5.AS400_Status_Description__c;
							if(sync2.Cancelled_Reason__c == null || sync2.Cancelled_Reason__c == ''){
								sync2.Cancelled_Reason__c = osm5.AS400_Status_Description__c;
							}
						}
					}
				}
			}
		}
		
		system.debug('-------------------------------------------------------------oliList: ' + oliList);
		system.debug('-------------------------------------------------------------ordList: ' + ordList);
		Database.SaveResult[] SR =  Database.update( oliList, false);//not all or none
		Database.SaveResult[] SR2 =  Database.update( ordList, false);//not all or none
		system.debug('-------------------------------------------SAVE RESULT oli: ' + SR);
		system.debug('-------------------------------------------SAVE RESULT ord: ' + SR2);
		
		deleteProcessedOlisd(normList);
	}
	
	public static Id getErrorQueues(String queueName) {
		List<QueueSobject> q = [SELECT Id, QueueId, Queue.DeveloperName FROM QueueSobject WHERE Queue.DeveloperName = :queueName LIMIT 1];
		if (q.size() == 1){
			return q[0].QueueId;
		} else {
			return userInfo.getUserId();
		}
	}
	
	public static void deleteProcessedOlisd(List<Order_Line_Item_Status_Detail__c> olisdList){
		//Delete processed status detail records
		system.debug('-------------------------------------------------DELETE: ' + olisdList);
		Database.DeleteResult[] SR3 =  Database.delete( olisdList, false);//not all or none
		system.debug('-------------------------------------------DELETE RESULT: ' + SR3);
	}
	
	public static Map<String, OrderStatusMap__c> getOsmMapping(){
		// Map status values
		List<OrderStatusMap__c> osmList = OrderStatusMap__c.getall().values();
		system.debug('-----------------------------------------------------------------------------osmList: ' + osmList);
		Map<String, OrderStatusMap__c> osmMap = new Map<String, OrderStatusMap__c>();
		for(OrderStatusMap__c osm : osmList){
			osmMap.put(osm.Name, osm);
		}
		return osmMap;
	}
	
	public static List<Orders__c> getOrders(List<Order_Line_Item_Status_Detail__c> olisdList){
		Set<String> orderIds = new Set<String>();
		for(Order_Line_Item_Status_Detail__c sd : olisdList){
			orderIds.add(sd.Order__c);
		}
		List<Orders__c> ordList = [SELECT Id, Order_Status__c, Cancelled_Reason__c, Order_Status_Description__c, Order_Status_Code__c, International_Address__c, 
									Customer__r.RecordType.DeveloperName FROM Orders__c WHERE Id IN: orderIds];
		return ordList;
	}
	
	public static Map<Id, List<Order_Line_Item_Status_Detail__c>> getOlisdMapping(List<Order_Line_Item_Status_Detail__c> olisdList){
		Map<Id, List<Order_Line_Item_Status_Detail__c>> olisdMap = new Map<Id, List<Order_Line_Item_Status_Detail__c>>();
		for(Order_Line_Item_Status_Detail__c s1 : olisdList){
			List<Order_Line_Item_Status_Detail__c> mapOliList = new List<Order_Line_Item_Status_Detail__c>();
			List<Order_Line_Item_Status_Detail__c> MapOrdList = new List<Order_Line_Item_Status_Detail__c>();
			for(Order_Line_Item_Status_Detail__c s2 : olisdList){
				if(s2.Order_Line_Item__c == s1.Order_Line_Item__c){
					mapOliList.add(s2);
				}
				if(s2.Order__c == s1.Order__c){
					mapOrdList.add(s2);
				}
			}
			if(mapOliList != null){
				system.debug('----------------------------------------------mapOliList: ' + mapOliList);
				olisdMap.put(s1.Order_Line_Item__c, mapOliList);
			}
			if(mapOrdList != null){
				system.debug('----------------------------------------------mapOrdList: ' + mapOrdList);
				olisdMap.put(s1.Order__c, mapOrdList);
				system.debug('----------------------------------------------olisdMap: ' + olisdMap);
			}
		}
		return olisdMap;
	}
	
	public static List<Order_Line_Items__c> getOliList(Set<Id> oliIdSet){
		List<Order_Line_Items__c> oliList = [SELECT Id,Substituted_Item__c, Product_Name__c, Update_Quantity__c, Product_Quantity__c, 
						Item_Status_Code__c, Item_Status__c, Item_Status_Description__c, Product_Number__c, Order__c, 
						Quantity_Shipped__c, Shipment_Tracking_Number__c, Shipper__c, Cancel_Reason__c  
						FROM Order_Line_Items__c WHERE Id IN :oliIdSet];
		system.debug('-----------------------------------------------------------------------------oliList: ' + oliList);
		return oliList;
	}
	
	public static Map<Id, List<Order_Line_Item_Status_Detail__c>> getStatusDetailsMap(List<Order_Line_Item_Status_Detail__c> olisdList){
		Map<Id, List<Order_Line_Item_Status_Detail__c>> statusMap = new Map<Id, List<Order_Line_Item_Status_Detail__c>>();
		for(Order_Line_Item_Status_Detail__c a : olisdList){
			List<Order_Line_Item_Status_Detail__c> statusList = new List<Order_Line_Item_Status_Detail__c>();
			for(Order_Line_Item_Status_Detail__c b : olisdList){
				if(b.Order_Line_Item__c == a.Order_Line_item__c){
					statusList.add(b);
				}
			}
			statusMap.put(a.Order_Line_Item__c, statusList);
		}
		return statusMap;
	}
	
	public static Set<Id> getOliIds(List<Order_Line_Item_Status_Detail__c> olisdList){
		Set<Id> oliIdSet = new Set<Id>();
		for(Order_Line_Item_Status_Detail__c a1 : olisdList){
			oliIdSet.add(a1.Order_Line_Item__c);
		}
		return oliIdSet;
	}
	
	public static Map<String, Item__c> getItemMapping(Set<String> prodNums){
		List<Item__c> itemList ;
		if (prodNums != null){
			 itemList = [SELECT Id, Product_Number__c, Product_Suffix__c FROM Item__c WHERE Product_Number__c IN: prodNums];
		}
		system.debug('-----------------------------------------------------------------------------itemList: ' + itemList);
		Map<String, Item__c> itemMap = new Map<String, Item__c>();
		if(itemList != null){
			for(Item__c it : itemList){
				itemMap.put(it.Product_Number__c, it);
			}
		}
		return itemMap;
	}
	
	public static Set<String> getProdNums(List<Order_Line_Item_Status_Detail__c> olisdList){
		Set<String> prodNums = new Set<String>();
		for(Order_Line_Item_Status_Detail__c pn : olisdList){
			prodNums.add(pn.Current_Sku__c);
			prodNums.add(pn.Previous_Sku__c);
		}
		return prodNums;
	}
	
}