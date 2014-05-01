public with sharing class OrderLineItemArchiveUtilities {
	
	public static string lineBreakChar = ',';
	public static string fieldBreakChar='#';

	public static void archiveLineItems(Set <Id> orderIds){
		Map <Id, List <Order_Line_Items__c> > orderByLineItemsMap = new Map <Id, List <Order_Line_Items__c> >();
		List <Order_Line_Items__c> olisToDelete = new List <Order_Line_Items__c>();
		for (Order_Line_Items__c oli: [select Shipment_Tracking_Number__c, Order__c, Item_Status__c,Shipped_Date__c,Product_Name__r.Product_Number__c, Original_Quantity__c, Product_Quantity__c,Product_Name__r.External_Key__c,Final_Price__c,shipper__c	,Quantity_Shipped__c from Order_Line_Items__c where order__c in :orderIds]){
			if (orderByLineItemsMap.get(oli.order__c)==null){
				orderByLineItemsMap.put(oli.order__c,new List <Order_Line_Items__c>{oli});
			}
			else {
				orderByLineItemsMap.get(oli.order__c).add(oli);
			}
		}
		List <Orders__c> orderList = new List <Orders__c>();
		for (Id orderId: orderByLineItemsMap.keySet()){
			Orders__c tempOrder = new Orders__c(id=orderId);
			tempOrder = processArchiveSummaryOnOrder(tempOrder, orderByLineItemsMap.get(orderId));
			orderList.add(tempOrder);
			olisToDelete.addAll(orderByLineItemsMap.get(orderId));
		}
		boolean bFailure = false;
		Savepoint sp = Database.setSavepoint();
		try{
			update orderList;	
		}
		catch (exception e){
			bFailure=true;
			Database.rollback(sp);
		}
		if (!bFailure){
			try{
				delete [select id from Order_Line_Item_Status_Detail__c where order__c in:orderIds];
			}
			catch (exception e){
				bFailure=true;
				Database.rollback(sp);
			}
		}
		if (!bFailure){
			try{
				OrderLineItemTriggerHelper.isDeleteAllowed=true;
				delete olisToDelete;	
			}
			catch (exception e){
				bFailure=true;
				Database.rollback(sp);
			}
		}

	}
	
	public static Orders__c processArchiveSummaryOnOrder(Orders__c inputOrder, List <Order_Line_Items__c> olis){
		string archiveString = '';
		integer k=0;
		for (Order_Line_Items__c tempOli: olis){
			archiveString+=tempOli.Final_Price__c+fieldBreakChar;//ItemPrice
			archiveString+=(tempOli.Original_Quantity__c==null?0:tempOli.Original_Quantity__c)+fieldBreakChar;//QtyOrdered
			archiveString+=(tempOli.Product_Quantity__c==null?0:tempOli.Product_Quantity__c)+fieldBreakChar;
			archiveString+=tempOli.Product_Name__r.Product_number__c+fieldBreakChar;//SKU num
			archiveString+=tempOli.Shipped_Date__c==null?SYSTEM.TODAY()+fieldBreakChar:tempOli.Shipped_Date__c+fieldBreakChar;//Shipped Date
			archiveString+=tempOli.Item_Status__c==null?fieldBreakChar:tempOli.Item_Status__c+fieldBreakChar;//status
			archiveString+=fieldBreakChar;//bought
			archiveString+=fieldBreakChar;//received	
			archiveString+=tempOli.Shipment_Tracking_Number__c==null?fieldBreakChar:tempOli.Shipment_Tracking_Number__c+fieldBreakChar;//tracking number
			k++;
			if (k<olis.size()) archiveString+=lineBreakChar;
		}
		inputOrder.Archive_Summary__c=archiveString;
		return inputOrder;
	}


	public static List <Order_Line_Items__c> restoreOlisFromArchive(Orders__c ordersObj){
		
		system.debug('summary~~~~'+ordersObj.Archive_Summary__c);
		List <Order_Line_Items__c> oliList = new List <Order_Line_Items__c>();
		try {
		string[] lineArray = ordersObj.Archive_Summary__c.split(lineBreakChar);
	  Set <String> ItemKeySet = new Set <String>();
	  Map <String, Item__c> itemMap = new Map <String, Item__c>();
	  Orders__c orderObjDetailed = [select Customer__r.RecordType.DeveloperName from Orders__c where id =:ordersObj.id];
	  String brandSuffix = NBTYUtils.getRecordTypeBrandMappingMap().get(orderObjDetailed.Customer__r.RecordType.DeveloperName).Product_Suffix_c__c;
	   for (String line: lineArray){
	  	string [] valuesArray = line.split(fieldBreakChar);
	  		   	system.debug(valuesArray);
		ItemKeySet.add(valuesArray[3]);
	  }
	  for (Item__c i: [select id, name, Product_Image_URL__c,product_suffix__c, product_number__c, Product_Image__c from Item__c where product_number__c in :ItemKeySet]){
	  	itemMap.put(i.product_suffix__c+'-'+i.product_number__c, i);
	  }
	  integer j=0;
	  for (String line: lineArray){
	  	j++;
	  	
	  	Order_Line_Items__c tempOli = new Order_Line_Items__c(Order__c=ordersObj.id);
	  	string [] valuesArray = line.split(fieldBreakChar);
	  	if (itemMap.get(brandSuffix+'-'+valuesArray[3])!=null){
		  	tempOli.Final_Price__c=decimal.valueOf(valuesArray[0]);
			tempOli.Line_Number__c = string.valueOf(j);
			system.debug(brandSuffix+'-'+valuesArray[3]);
			tempOli.Product_Name__r = itemMap.get(brandSuffix+'-'+valuesArray[3]);
			tempOli.Product_Name__c = itemMap.get(brandSuffix+'-'+valuesArray[3]).id;
			tempOli.Product_Quantity__c=integer.valueOf(valuesArray[1]);
			tempOli.Quantity_Shipped__c=integer.valueOf(valuesArray[2]);
			tempOli.Product_Name__r.Product_Number__c=itemMap.get(brandSuffix+'-'+valuesArray[3]).product_number__c;
			tempOli.Product_Name__r.Name=itemMap.get(brandSuffix+'-'+valuesArray[3]).Name;
			SYSTEM.DEBUG(tempOli);
			system.debug('valuesArray~~'+valuesArray);
			tempOli.Shipped_Date__c = valuesArray[4]!='NULL'?date.valueOf(valuesArray[4]):null;
			if (valuesArray.size()>8) tempOli.Shipment_Tracking_Number__c= valuesArray[8]!=NULL? valuesArray[7]:null;
			//	tempOli.shipper__c=valuesArray[4];
			SYSTEM.DEBUG(tempOli);
			oliList.add(tempOli);
			SYSTEM.DEBUG(OLIlIST);
	  	}
	  }
		}
		catch (exception e){
			
		}
	  return oliList; 
	}
}