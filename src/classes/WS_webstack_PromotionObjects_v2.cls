public with sharing class WS_webstack_PromotionObjects_v2 {

	public class ApplyPromotionRequest {
		// WebStoreId: mandatory - 1 = PP, 49 = Associates, 5 = VW
		public integer WebStoreId { get; set; }
	
		// SourceCode: OBSOLETE, replaced with CatalogSourceCode and CouponCode
		public string SourceCode { get; set; }
	
		// CatalogSourceCode: optional, leave null or blank to apply current site wide promotion
		// Should be included only for promotions that are catalog-only (and not supported on the web)
		public string CatalogSourceCode { get; set; }
	
		// CouponCode: optional, coupon to apply
		// Leave null or blank to apply no promotion on top of the catalog
		// Should be included for promotions that are both catalog and web or web-only
		public string CouponCode { get; set; }
	
		// AllowExpiredSourceCode: optional, default to false
		public boolean AllowExpiredSourceCode { get; set; }
	
		// Email: optional, customer email (used for some coupons that have a limit per customer)
		public string Email { get; set; }
	
		// ShippingMethod: optional, default = UPS, possible values = UPS, USPS, TwoDay, NextDay, International
		public string ShippingMethod { get; set; }
	
		// Shipping: optional, leave null unless shipping rate is overridden and should not be changed
		public decimal Shipping { get; set; } 
	
	
		// ShipToCountry: optional, 2-letter ISO country code, default = "US"
		public string ShipToCountry { get; set; }
	
		// ShipToPostalCode: mandatory if ShipToCountry = "US" and ShippingMethod = TwoDay or NextDay
		public string ShipToPostalCode { get; set; }
		
		// Items: list of line items
		public List<RequestItem> Items { get; set; }
		
		// AssociateId field required for web store Id 49
		public integer AssociateId { get; set; }
		
		// Salesforce Order Name
		public string OrderId { get; set; }	
		public ApplyPromotionRequest(OrderWizard_Wrapper orderWrap){
			orderWrap.shippingAddress = [SELECT Id, Address_Line_1__c, Address_Line_2__c, Address_Line_3__c, Address_Line_4__c, Address_Type__c, City__c, Country__c, State_Providence__c, Residential_Commercial__c,
													 Zip_Code__c, Foreign_Country_Code__c, Primary_Ship_to_Address__c, Primary_Bill_To_Address__c, Validated__c, Validation_Error_Reason__c, Validation_Override__c, Country_Picklist__c, Foreign_Postal_Code__c, International_Address__c
													 FROM Address__c 
													 WHERE ID =: orderWrap.shippingAddress.id];
			// DE786 -- Link Employee pricing store id
			Account a =[select recordTypeID, Associate_ID__c, Associate_Customer__c from Account where id =:orderWrap.newOrder.customer__c];
			RecordType rt = [select developerName from RecordType where id=: a.recordTypeId];
			// DE786 -- Link Employee pricing store id
			boolean isAssociate = (a.Associate_ID__c != null || a.Associate_Customer__c);
			// DE786 -- Link Employee pricing store id
			WebStoreId= isAssociate ? 49 : Integer.valueOf(NBTYUtils.getRecordTypeBrandMappingMap().get( rt.developerName).ws_id__c);
			AssociateId = WebStoreId == 49 ? Integer.valueOf(orderWrap.newOrder.customer__r.Associate_ID__c) : null;				
			OrderId = orderWrap.newOrder.Name;
			CatalogSourceCode= orderWrap.sourceCode;
			CouponCode = orderWrap.couponCode;
			AllowExpiredSourceCode=true;
			Email=orderWrap.newOrder.customer__r.personEmail;
			ShippingMethod = orderWrap.newOrder.Shipping_Method__c;
			ShipToCountry=orderWrap.shippingAddress.Foreign_Country_Code__c;
			if (orderWrap.shippingAddress.Foreign_Country_Code__c==null) {
				addressTriggerHelper.setCountryCode(orderWrap.shippingAddress);
			}
			ShipToPostalCode= ShipToCountry =='00000'? orderWrap.shippingAddress.Zip_Code__c : orderWrap.shippingAddress.Foreign_Postal_Code__c;
			Items = new List <RequestItem>();
			system.debug(orderWrap.selectedOrderLineItems);
			for (Order_Line_Items__c i: orderWrap.selectedOrderLineItems){
				Items.add(new RequestItem(i));
			}
		}
	}
	
	// Line Item object
	public class RequestItem {
		// ItemNumber
		public integer ItemNumber { get; set; }
		// Quantity: does not include free quantity
		public integer Quantity { get; set; }
		// Price: optional, leave null unless price is overridden and should not be changed
		public decimal Price { get; set; }
		// OfferCode: optional, leave null unless offer is overridden and should not be changed
		// 1FOR1 (1:1), 2FOR1 (5:2), 2FOR1ONLY (2:1), 3FOR1 (3:1)
		public string OfferCode { get; set; }
		
		public RequestItem(Order_Line_Items__c oli) {
			system.debug(oli);
			ItemNumber=oli.sku_number__c !=null? Integer.valueOf(oli.SKU_Number__c): Integer.valueOf(oli.Product_Name__r.product_number__c);
			Quantity = Integer.valueOf(oli.Original_Quantity__c);
			system.debug('Orignial Quantity***' + oli.Original_Quantity__c);
			Price = oli.Price_Override__c!=null ?oli.Price_Override__c: null;
		}
	}
	
	public class ApplyPromotionResponse {
		// IsSuccessful: should always be true, except if an the order could not be properly understood,
		// in which case an InvalidData status gets returned with appropriate status message
		public boolean IsSuccessful { get; set; }
		// Status: Success
		// InvalidData
		// InvalidSourceCode, ExpiredSourceCode,
		// MinimumOrderAmountNotReached, MaximumNumberOfCouponsPerCustomerExceeded,
		// DiscountedItemMaximumQuantityExceeded, MinimumNumberOfItemsInCartNotReached,
		// AssociateFreeShippingAllowanceExceeded, AssociateOrderTotalAllowanceExceeded
		// Other
		public string Status { get; set; }
		// StatusMessage
		public string StatusMessage { get; set; }
		// Data: response
		public ApplyPromotionResponseData Data { get; set; }
	}
	
	public class ApplyPromotionResponseData {
		// SourceCode: source code to apply to the order and send to AS/400 in Catalog Source Code field in Header record
		// If no coupon was applied or coupon was invalid, this is either the catalog source code if supplied or the current catalog source code otherwise
		// If coupon was successfully applied, this is the coupon source code
		public string SourceCode { get; set; }
		// Note that Order Total = SubTotal + Shipping + Tax (not supplied) - Sum(Allowances) - Sum(Item Discount)
		// SubTotal: order subtotal, not including promotions, tax or shipping = Sum(Item Subtotal)
		public decimal SubTotal { get; set; }
		// Shipping: this is the total shipping amount, not counting any shipping promotion. For ex. $4.95 for PP standard shipping
		public decimal Shipping { get; set; }
		// ShipmentValue   is what the order would cost with the default source code applied.
		public decimal ShipmentValue { get; set; }
		// Allowances: order-level allowances
		// Includes:
		// - Shipping allowance (type 69) - for example $4.95 for free shipping on PP
		// - Order-level discount allowance (type 61) - for example $10 off
		public List<Allowance> Allowances { get; set; }
		// GiftMessage: some gift items may be added to order - this is a descriptive message to be displayed in the order
		// for example, "Free Cod Liver Oil no. 1153"
		public string GiftMessage { get; set; }
		public string ShippingMethod { get; set; }
		// Items: line items
		public List<ResponseItem> Items { get; set; }
		// Item object
		// Weight object
		public decimal Weight { get; set; }
		// isReplacement Object
		public boolean IsReplacementOrder { get; set; }
	}
	public class ResponseItem {
		// ItemNumber
		public integer ItemNumber { get; set; }
		// Quantity: should be the same as quantity sent in the request, except when a limit per order is reached
		// For example, associates (web store 49) can order a maximum of 4 of the same item per order
		public integer Quantity { get; set; }
		// FreeQuantity: should be the same as free quantity as calculated from the price file, except when a particular coupon changes the offer
		// For example coupon SS4V1 (89 cents coupon) changes free quantity to 0
		public integer FreeQuantity { get; set; }
		// Line Item Total = SubTotal - Discount
		// SubTotal: line item total price
		// This reflects the sale price, but does not include any discount applied by the site wide promotion or coupon
		// Should equal Quantity * Price per item in most cases, except in the case of VW BOGO Penny and VW BOGO 50
		public decimal SubTotal { get; set; }
		// Discount: line-item discount applied by the site wide promotion or coupon, for example 10% off PP item
		public decimal Discount { get; set; }
	}
	
	// Allowance object
	public class Allowance {
		// AllowanceCode: 61 = credit coupon, 69 = free shipping coupon
		public integer AllowanceCode { get; set; }
		// Amount
		public decimal Amount { get; set; }
	}
	
	public static ApplyPromotionResponse parseResponse(string JsonString ){
		JSONParser parser = JSON.createParser(JSONString);
		ApplyPromotionResponse resp = (ApplyPromotionResponse) system.json.deserialize(JsonString, ApplyPromotionResponse.class);
		system.debug(resp);
		return resp;
	} 
}