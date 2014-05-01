/********************************************************************************
 ********************************************************************************	
 *  Class			: NBTYWSUtil
 *  Author		   : Acumen Solutions: Rahul Badal
 *  Version History  : 1.0
 *  Creation		 : 03/22/13
 *  Description	  : utility Class to invoke Agileone Services
 *					  
 ********************************************************************************
 ********************************************************************************/
public with sharing class NBTYWSUtil {

	private static final Boolean isDebug = boolean.valueof(WS_Integration__c.getValues('DebugCall').value__C); 
	private static string tenantID;
	private static map<string,string> responseMap = new map<string,string>();
	
	private static string endPointHeader = WS_Integration__c.getValues('AgileOne End Point').value__C + '/1.0/tenant/' + WS_Integration__c.getValues('AgileOne Tenant ID').value__C +  '/';
	
	public static  List<Item__c> getU2PAgileOneProductsByAccountID(string accountID,string inTenantID) {
		tenantID = inTenantID;
		return processAgileOneResponse(accountID, 'Account');
	}
		
	public static  List<Item__c> getU2PAgileOneProductsByEmailID(string emailID) {
		return processAgileOneResponse(emailID, 'Email');
	}
	
	public static  List<Item__c> getP2PAgileOneProducts(string productID,string inTenantID) {
		tenantID = inTenantID;		 
		return processAgileOneResponse(productID, 'Product');
	}
	
	public static List<Bundle__c> getActiveBundles(string productSuffix) {
		Date dtToday = System.today();
		List<Bundle__c> activeBundles = new List<Bundle__c>();
		// Productsuffix = -1 to get all bundles irrespective of brands
		if (productSuffix == '-1') {
			activeBundles = [Select Name,Id, Item__r.Sale_Offer__c, Item__r.Sale_Price__c, Item__r.Product_Number__c, Item__r.Product_Image_URL__c, Item__r.Name, Item__r.Brand_Name__c, Item__r.Available_Inventory__c, Item__r.Description__c, End_Date__c,Bundle_Price__c, Brand__c, Active__c,Bundle_Selling_Points__c  From Bundle__c Where ((Start_Date__c <= :dtToday and End_Date__c >= :dtToday) And Active__C = True)];
		} else {
			activeBundles = [Select Name,Id, Item__r.Sale_Offer__c, Item__r.Sale_Price__c, Item__r.Product_Number__c, Item__r.Product_Image_URL__c, Item__r.Name, Item__r.Brand_Name__c, Item__r.Available_Inventory__c, Item__r.Description__c, End_Date__c,Bundle_Price__c, Brand__c, Active__c,Bundle_Selling_Points__c  From Bundle__c Where ((Start_Date__c <= :dtToday and End_Date__c >= :dtToday) And Active__C = True And Item__r.Product_Suffix__c =:productSuffix )];
		}
		return activeBundles;
	}
		
	private static List<Item__c> processAgileOneResponse(string paramValue, string paramType) {
		string endPoint = WS_Integration__c.getValues('AgileOne End Point').value__C;
		string U2PKey='customer';
		if (WS_Integration__c.getValues('AgileOne U2P Key')!=null) {
			U2PKey = WS_Integration__c.getValues('AgileOne U2P Key').value__c;
		}
		//https://api.agilone.com/1.0/tenant/ 
		
		if(!endPoint.right(1).equals('/')) {
			endpoint = endpoint + '/';
		}	
		if(paramType == 'Account') {
			endPoint = endPoint + tenantID + '/'+U2PKey+'/1/' + paramValue + '/recommendations/product';
		}
		if(paramType == 'Email') {
			endPoint = endPoint + tenantID + '/'+U2PKey+ '/recommendations/product';
		}
		if(paramType == 'Product') {
			endPoint = endPoint + tenantID + '/product/1/' + paramValue + '/recommendations/crosssell';
		}
		string JSONResponseString =  GetAgileOneResponse(endPoint);
		List<Item__c> lstProduct = new List<Item__c>();
		lstProduct = ParseAgileOneResponse(JSONResponseString);
		return lstProduct;
	}
		
	private static string GetAgileOneResponse(string endPoint) {
		// Submit request to Agileone
		HttpRequest req = new HttpRequest();
		req.setMethod('GET');
		req.setEndpoint(endPoint);
		String username = WS_Integration__c.getValues('AgileOne User ID').value__C;
		system.debug(username);
		String password = WS_Integration__c.getValues('AgileOne Password').value__C;
		system.debug(password);
		// Encode user id and Password.
		Blob headerValue = Blob.valueOf(username + ':' + password);
		String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
		system.debug(authorizationHeader);
		req.setHeader('Authorization', authorizationHeader);
		system.debug(  req.getHeader('Authorization'));
		Http httpreq = new Http();
		HTTPResponse res = new HTTPResponse();
		try{
			res = httpreq.send(req);
		} catch(Exception e) {
			system.debug(e.getMessage());
			throw new NBTYException('Error getting Agileone Product Recommendations.\n Please contact System Administrator.');
		}
		
		if(isDebug)
			system.debug(res.toString());
		
		Integer responseCode = res.getStatusCode();
		String JSONString = ''; 
		if(isDebug) {
			system.debug(responseCode);
		}
		if(responseCode < 300) {//success
			JSONString = res.getBody().replace('\n', '');
			if(isDebug) {
				system.debug(JSONString);
			}
		} else {
			throw new NBTYException('Error getting Agileone Product Recommendations.\n Please contact System Administrator.');
		}
		//string JSONString = '{"result":{"tenantId":"7","resultSet":{"resultSetitem":[{"rank":"8","product":{"id":"1/1026007","name":"Product 1026007","description":"An Amazing Product","imageUrl":"","productUrl":"","brand":"Garland","availability":"Yes","saleCondition":"New","price":"99.0000","salePrice":"99.0000","gtin":"617931185227","mpn":"AJVCJK3-OS"}},{"rank":"5","product":{"id":"1/1135606","name":"Product 1135606","description":"An Amazing Product","imageUrl":"","productUrl":"","brand":"Cranium","availability":"Yes","saleCondition":"New","price":"14.0000","salePrice":"14.0000","gtin":"713852531546","mpn":""}},{"rank":"2","product":{"id":"1/1230547","name":"Moosejaw Sea Captains Hat","description":"Sea Captains Hat S11 S11","imageUrl":"http://www.agilone.com/image/product/1230547","productUrl":"http://www.agilone.com/product/1230547","brand":"MJ Gifts","availability":"Yes","saleCondition":"New","price":"19.95","salePrice":"19.95","gtin":"","mpn":""}},{"rank":"3","product":{"id":"1/1433614","name":"Product 1433614","description":"An Amazing Product","imageUrl":"","productUrl":"","brand":"CTX","availability":"Yes","saleCondition":"New","price":"10.0000","salePrice":"10.0000","gtin":"","mpn":""}},{"rank":"4","product":{"id":"1/229969","name":"Moosejaw Flag","description":"MJ FLAG F05","imageUrl":"http://www.agilone.com/image/product/229969","productUrl":"http://www.agilone.com/product/229969","brand":"MJ Gifts","availability":"Yes","saleCondition":"New","price":"1","salePrice":"1","gtin":"","mpn":""}},{"rank":"9","product":{"id":"1/3750","name":"Carolina Bandanas (Dark)","description":"BANDANA DARK F03","imageUrl":"http://www.agilone.com/image/product/3750","productUrl":"http://www.agilone.com/product/3750","brand":"Peregrine","availability":"Yes","saleCondition":"New","price":"2.16","salePrice":"2.16","gtin":"70685000527","mpn":"D053CS"}},{"rank":"10","product":{"id":"1/656847","name":"Moosejaw .75L CamelBak Water Bottle BPA Free (Spring 2010)","description":"MJ CAMEL BITE.75 S10","imageUrl":"http://www.agilone.com/image/product/656847","productUrl":"http://www.agilone.com/product/656847","brand":"Moosejaw","availability":"Yes","saleCondition":"New","price":"14","salePrice":"14","gtin":"713852530495","mpn":""}},{"rank":"7","product":{"id":"1/843247","name":"Eagles Nest Slap Strap Pro","description":"Slap Strap Pro F09 F09","imageUrl":"http://www.agilone.com/image/product/843247","productUrl":"http://www.agilone.com/product/843247","brand":"Eagles Nest","availability":"Yes","saleCondition":"New","price":"24.95","salePrice":"24.95","gtin":"811201010183","mpn":"PROST001"}},{"rank":"6","product":{"id":"1/932830","name":"Product 932830","description":"An Amazing Product","imageUrl":"","productUrl":"","brand":"Cranium","availability":"Yes","saleCondition":"New","price":"14.0000","salePrice":"14.0000","gtin":"713852532604","mpn":""}},{"rank":"1","product":{"id":"1/998994","name":"Product 998994","description":"An Amazing Product","imageUrl":"","productUrl":"","brand":"Franklin","availability":"Yes","saleCondition":"New","price":"2.0000","salePrice":"2.0000","gtin":"","mpn":""}}]}}}';
		//JSONString = JSONString.replace('\n', '');
		return JSONString;
	}
	 
	private static List<Item__c>  ParseAgileOneResponse(string JSONString) {
		JSONParser parser = JSON.createParser(JSONString);
		list<String> LegacyProductID = new list<String>();
		list<Item__c> lstProducts = new list<Item__c>();
		string Rank = '';
		list<ProductRank> lstU2PProductRank = new list<ProductRank>();
		
		// DE879 Adustments to be more dynamic for AgilOne U2P
		ProductRank.NBTYproduct testResultItem1 = null;
		// Parse response. Skip till Product field and then serialize it.
		while (parser.nextToken() != null) {
			if ((parser.getCurrentToken() == JSONToken.FIELD_NAME)){
				ProductRank tempNBTYProductRank = new ProductRank();
				
				// Grab the next value in the parse and save the name and it's associate text.
				parser.nextValue();
				String fieldName = parser.getCurrentName();
				String fieldValue = parser.getText();
				if(isDebug) {
					system.debug('**** Field Name ** ' + fieldName);
					system.debug('*** Field Value  ** ' + fieldvalue);
				}
				
				// Store the rank value
				if(fieldname == 'rank') {
					Rank = fieldvalue;
				}
				
				// Store the product value parsing it into the class that represents it
				if(fieldname == 'product') {
					testResultItem1 = (ProductRank.NBTYproduct)parser.readValueAs(ProductRank.NBTYproduct.class);
					System.debug('~~~~~~ testResultItem1: ' + testResultItem1);
					System.debug('~~~~~~ Rank: ' + Rank);
				}
				 
				// DE879 -- if testResultItem1 is not null and the Rank
				// string is not blank or null then add new product rank 
				if (testResultItem1 != null && !String.IsBlank(Rank)) {
					tempNBTYProductRank.Rank = integer.valueOf(Rank);
					tempNBTYProductRank.recProduct = testResultItem1;
				 	
					lstU2PProductRank.add(tempNBTYProductRank);
				 	
					// reset testResultItem1 and Rank to null
					testResultItem1 = null;
					Rank = null;
				}
			}
		}
		//Sort with Rank
		lstU2PProductRank.Sort();
		Map<integer,string> rankProductMap = new Map<integer,string>();
		For(ProductRank p :lstU2PProductRank){
			LegacyProductID.add(formatProductId(p.recProduct.Id));
			rankProductMap.put(p.Rank,formatProductId(p.recProduct.Id));
		}
		string catalogId = '';
		
		if(lstU2PProductRank.size() > 0) {
			catalogId = formatCatalogId(lstU2PProductRank[0].recProduct.Id);
		}
		if(isDebug) {
			system.debug('** Total Products **' + lstU2PProductRank.size());
			system.debug('** Catalog ID **' + catalogId);
			for(ProductRank p :lstU2PProductRank){
				system.debug('***** ' + p.Rank);
				system.debug('***** ' + p.recProduct.Id);
			}
			for(string s :LegacyProductID) {
				system.debug('*****Formatted Legacy Id: ' + s);
			}
		}

		Map<String, Item__C> productMap = new Map<String, Item__C>(); 
		for(Item__C objCS : [Select id, Sale_Offer__c, Sale_Price__c, Product_Number__c, Product_Image_URL__c, Name, Brand_Name__c, Available_Inventory__c, Description__c  From Item__c  WHERE  Product_Number__c IN :LegacyProductID and Product_Suffix__c =:catalogId]) {
			productMap.put(objCS.Product_Number__c, objCS);
		}	
		for (Integer tempRank : rankProductMap.keySet()){
			lstProducts.add(productMap.get(rankProductMap.get(tempRank)));
		}
		return lstProducts;
	}
	
	public static HttpRequest setHttpReq(string endpoint) {
		HttpRequest req = new HttpRequest();
		req.setMethod('POST');
		req.setEndpoint(endpoint);
		req.setHeader('accept', 'application/json');
		req.setHeader('Content-Type', 'application/json');
		return req;
	}
	
	public static  WS_webstack_PromotionObjects_v2.ApplyPromotionResponse ProcessPromotions(orderWizard_wrapper wrap) {
		HttpRequest req = setHttpReq(WS_Integration__c.getValues('PromotionsEndPoint').value__c);
		WS_webstack_PromotionObjects_v2.ApplyPromotionRequest  promoReqObj = new WS_webstack_PromotionObjects_v2.ApplyPromotionRequest (wrap);
		String bodyJson = JSON.serialize(promoReqObj);
		req.setBody(bodyJson);
		system.debug(LoggingLevel.info,'body~~~'+bodyJson);
		Http httpreq = new Http();
		HTTPResponse res = new HTTPResponse();
		try {
			system.debug(LoggingLevel.info,req.getBody());
			res = httpreq.send(req);
		} catch(Exception e) {
			system.debug(e.getMessage());
			throw new NBTYException('Error getting promotions.\n Please contact System Administrator.');
		}
		
		Integer responseCode = res.getStatusCode();
		String JSONString = ''; 
		if(responseCode < 300) {// Success
			JSONString = res.getBody().replace('\n', '');
			 system.debug(JSONString);				
		} else {
			throw new NBTYException('Error getting Promotions Details.\n Please contact System Administrator.');
		}
		WS_webstack_PromotionObjects_v2.ApplyPromotionResponse PromotionResponse= WS_webstack_PromotionObjects_v2.parseResponse(JsonString);		   
		system.debug( PromotionResponse);
		return PromotionResponse;
	}
	
	private static string formatProductId(string ProductID) {
		//1/060803-0011 060803 is product 
		return ProductID.replace('1/','').substringBefore('-');
	}

	private static string formatCatalogId(string ProductID) {
		//1/060803-0011 0011 is brand
		return ProductID.replace('1/','').substringAfter('-');
	}
	
	public static Map<string,string> ParseXML(string XMLString) {
		DOM.Document doc = new DOM.Document();
		DOM.XMLNode root;
		try {
			doc.load(XMLString);
			root = doc.getRootElement();
			walkThrough(root);
		} catch (System.XMLException e) {  // invalid XML
			System.debug('----- Invalid XML-- ' + XMLString );
			throw new NBTYException('Invalid response from Payment Gateway. Please contact System Administrator');
		}
		return responseMap;
	}
	
	private static void walkThrough(DOM.XMLNode node) {
		String result = '\n';
		string resVal = '';
		string resKey = '';
		if (node.getNodeType() == DOM.XMLNodeType.ELEMENT) {
			resKey = node.getName();
			if (node.getText().trim() != '') {
				resVal = node.getText().trim();
				responseMap.put(resKey,resVal);
			}
			for (Dom.XMLNode child: node.getChildElements()) {
				walkThrough(child);
			}
		}
	}
}