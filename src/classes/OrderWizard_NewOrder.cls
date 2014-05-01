/*
	OrderWizard_NewOrder
	Backend controller for order wizard from building order to checkout.
	------------------------------------------------------------------
	Author		|	Date		|	Description
	------------------------------------------------------------------
	??????		|	5/14/13	    |	Created
	2014-01-21:  Not checking for As400 number for new customers/ Pavan Jasthi
	Gary Alfrey |	1/10/14		|	Adding Downtime Utils
	Gary Alfrey |	1/19/14		|	Adding VW customer coupons
*/

global with sharing class OrderWizard_NewOrder {
	private static final String UN_EXPIRED = '68';
	private static final String EXPIRED = '61';
	public OrderWizard_Wrapper wrap {get;set;}
	public Account Customer {get;set;}
	public RecommendationsWrapper recWrap {get;set;}
	public List<OLIWrapper> OLIWrapperList {get;set;}
	public String errorMessage {get;set;}
	public Boolean isProduct {get;set;}
	public Boolean showSaveShipAddrBtn {get;set;}
	public Boolean showSaveBillAddrBtn {get;set;}
	public Boolean bRecommendation;
	public Boolean bRenderCCfields {get;set;}
	public Boolean bRenderCashFields {get;set;}
	public Boolean bRenderCheckFields {get;set;}
	public Boolean bRenderTokenFields {get;set;}
	public Boolean bRenderExistingCC{get;set;}
	public Boolean bOrderSubmitted {get;set;}
	public Boolean bReleaseOrder {get;set;}
	public Boolean bProductChange {get;set;}
	public Boolean bShowCheckout {get;set;}
	public Boolean bNoPullOrderReason {get; set;}
	public Boolean isAuthReversal {get;set;}
	public Boolean bShowChoiceForSubtitute {get;set;}
	public Boolean bSubstituteSelected {get;set;}
	public Boolean bQuantityChanged {get;set;}
	public Boolean HasErrorMessages;
	public String PullOrderErrorMessage {get;set;}
	public decimal CustomerCredits {get;set;}
	public string newCreditAmt {get;set;}
	public Map <Id, Profile> profileMap {get;set;}
	public boolean isCSR {get;set;}
	public Orders__c stdContOrder {get;set;}
	public Item__c ItemSelected {get;set;}
	public Credit__c tempCredit {get;set;}
	public Integer OLIQuantity;
	public List<String> MessagesList = new List<String>();
	public boolean MsgFromException;
	public boolean bShowPullReasonList {get;set;}
	public string SelectedTokenToDelete {get;set;}
	// JMK-PullOrder Change
	public boolean bPullReasonOther {get;set;}
	/*******************************GA: 62658064 Start Block************************************************************/
	public Boolean isVWCust {get;set;}
	public Boolean hasCoupons {get;set;}
	public String loyaltyMsg {get;set;}
	public List<ws_Soa_Loyalty_RetrieveInfo.couponDetail> coupons {get;set;}
	public List<SelectOption> loyaltySelectOp {get;set;}
	public String selectedLoyalty {get;set;}
	private decimal previousAmount;
	private decimal negativeTotal;
	private List<Allowance__c> allowanceList;
	/*******************************GA: 62658064 End Block************************************************************/
	
	public OrderWizard_NewOrder(ApexPages.StandardController stdController) {
		//String OrderId = stdController.getId();
		stdContOrder = (Orders__c)stdController.getRecord();
		system.debug('--------------------------------stdContOrder: ' + stdContOrder);
		/*******************************GA: 62658064 Start Block************************************************************/
		allowanceList = new List<Allowance__c>();
		previousAmount = 0;
		hasCoupons = false;
		negativeTotal = 0.00;
		/*******************************GA: 62658064 End Block************************************************************/
		showSaveShipAddrBtn = false; 
		showSaveBillAddrBtn = false;
		bRenderCCfields=false;
		bRenderCashFields=false;
		bRenderCheckFields=false;
		bOrderSubmitted = false;
		bProductChange=false;
		bNoPullOrderReason = false;
		bShowChoiceForSubtitute = false;
		bSubstituteSelected = false;
		bQuantityChanged = false;
		PullOrderErrorMessage = '';
		HasErrorMessages = false;
		MsgFromException = false;
		isProduct =false;
		bShowPullReasonList = false;
		bPullReasonOther = false;
		tempCredit = new Credit__c();
		tempCredit.Credit_Amount__c = 0.00;
		string OrderId = ApexPages.currentPage().getParameters().get('Id');
		string CustId = ApexPages.currentPage().getParameters().get('CustId');
		string ProdId = ApexPages.currentPage().getParameters().get('prodId');
		boolean isClone = ApexPages.currentPage().getParameters().get('clone')!=null;
		isAuthReversal = ApexPages.currentPage().getParameters().get('reverse')!=null;
		system.debug('--------------------------------isClone: ' + isClone);
		system.debug('--------------------------------ProdID: ' + ProdId);
		system.debug('--------------------------------OrderId: ' + OrderId);
		system.debug('--------------------------------CustId: ' + CustId);
		if (OrderId!=null) {
			Orders__c orderObj = AuthDownTimeUtils.queryOrder(orderId);
			system.debug('--------------------------------orderObj: ' + orderObj);
			Customer = [SELECT Id, Name, PersonEmail, Substitutes__c, Customer_Notes__c, No_Peanuts__c, No_Invoices__c, No_Catalogs__c,AS_400_Customer_Number__c,RecordType.Name, RecordType.DeveloperName, Customer_Credit_Available__c, CurrencyIsoCode,Payment_Profile_Id__c, VW_Passport_Number__c, IsPersonAccount FROM Account WHERE Id =:orderObj.customer__c];
			wrap = new OrderWizard_Wrapper(orderObj);
			System.debug('>>>>>>>>>>>>>>>>>>>>>: ' + wrap);
			isVWCust = checkCustomerBrand();
			setCSRFlag();
			processSelectedShipAddr();
			processSelectedBillAddr();
			//initialize credits
			CustomerCredits = Customer.Customer_Credit_Available__c;
			wrap.CustomerCreditAvailable = CustomerCredits;
			wrap.newOrder.Pull_Order__c = false;
			resetOliWrapperList();			
			if (orderObj.Credit_Card_Token__c!=null) wrap.selectedccType='Credit Card';
		}
		if (customer.AS_400_Customer_Number__c!=null) {
			if (string.isNotBlank(Customer.AS_400_Customer_Number__c)) {
				recWrap = new RecommendationsWrapper(Customer);
				// DE869 --  null ref issue with PfP & AS400 cust number on recommentation list
				if (recWrap.productList != null && !recWrap.productList.isEmpty())
				isProduct=true;
			}
		}
		// updates the recommendations based on the customer record type
		recWrap = new RecommendationsWrapper(Customer);
		if (recWrap.productList!=null){
			if (!recWrap.productList.isEmpty()) isProduct=true;
		}
		
		if (prodId!=null) {
			if (String.isNotBlank(ProdId)) {
				// CreateOrder();
				searchedRecordId = ProdId;
				bRecommendation = true;
			//  ProcessAddItem();
			}
		} 
		// JMK-PullOrder Change
		// If reasons are saved, repopulate and set the pull order flag on and finally 
		// use PullOrderCheck() to update UI.
		populatePullOrderMulti();
		
	}
	
	public void resetOliWrapperList() {
		wrap.queryOrderLines();
		OLIWrapperList = new List<OLIWrapper>();
		system.debug('size oli~~~~~'+wrap.selectedOrderLineItems.size());
		if (!wrap.selectedOrderLineItems.isEmpty()) {
			for (Order_Line_Items__c oli: wrap.selectedOrderLineItems){
				system.debug('oli~~~~~'+oli);
				OLIWrapperList.add(new OLIWrapper(oli));
				bProductChange=true;
			}
		}
	}
	
	public void init() {
		if (searchedRecordId!=null) {
			ProcessAddItem();
		}
		ApplyPromotion();
		// DE528
		wrap.UndoAppliedCredit();
		if (wrap.CustomerCreditAvailable != null && wrap.CustomerCreditAvailable != 0.00) {
			CustomerCredits = wrap.CustomerCreditAvailable;
		}
	}
	
	public void populatePullOrderMulti() {
		Account a = [SELECT No_Advertisements__c, Invoice_on_Outside_of_Box__c, Special_Shipping_Traffic__c, Ship_Complete__c, NO_Invoices__c, No_Peanuts__c, NO_Catalogs__c FROM Account where id =:wrap.newOrder.Customer__c];
		String s = wrap.newOrder.Pull_Order_Reason_Multi__c;
		// DE644 -- adding check for Invoice_on_Outside_of_Box__c
		if (s == null&&(a.No_Invoices__c||a.No_Peanuts__c||a.No_Catalogs__c||a.no_advertisements__c||a.special_shipping_traffic__c
			|| a.Invoice_on_Outside_of_Box__c)) {
			s = '';
			if (a.No_Invoices__c && !s.contains('No Invoice')) {
				s += '; No Invoice';
			}
			if (a.No_Peanuts__c && !s.contains('No Peanuts')) {
				s += '; No Peanuts';
			}
			if (a.No_Catalogs__c && !s.contains('No Catalog')) {
				s += '; No Catalog';
			}
			if (a.No_Advertisements__c && !s.contains('No Advertisments')) {
				s += '; No Advertisements';
			}
			if (a.Special_Shipping_Traffic__c && !s.contains('Special Shipping Traffic')) {
				s += '; Special Shipping Traffic';
			}
			if (a.Invoice_on_Outside_of_Box__c && !s.contains('Invoice on Outside of Box')) {
				s += '; Invoice on Outside of Box';
			}
			// is new
			if (a.Ship_Complete__c && ApexPages.currentPage().getParameters().get('CustId')!=null) {
				wrap.newOrder.Ship_Complete__c = true;
			}
			if (s!=null) {
				if ((s != null && s != '') && (wrap.newOrder.Pull_Order_Reason_Multi__c == null || wrap.newOrder.Pull_Order_Reason_Multi__c == '')) {
					wrap.newOrder.Pull_Order_Reason_Multi__c = s.substring(1, s.length());
				} else {
					wrap.newOrder.Pull_Order_Reason_Multi__c += s;
				}
			}
		}
		if (wrap.newOrder.Pull_Order_Reason_Multi__c != null) {
			wrap.newOrder.Pull_Order__c = true;
			PullOrderCheck();
		}
	}
	
	public void reverseAuth() {
		if (isAuthReversal) {
			wrap.reversalResponse=OrderUtilities.processAuthReversal(wrap.newOrder, false);
			system.debug('reversalResponse~~~'+wrap.reversalResponse);
			if (wrap.reversalResponse.Status.equalsIgnoreCase('APPROVED')) {
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Authorization Reversal Attempt Successful'));
			} else {
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'Authorization Reversal Attempt Not Successful:  '+wrap.reversalResponse.ErrorMessage));
			}
		}
	}
	
	public void setCSRFlag() {
		profileMap = new Map <Id, Profile>();
		for (Profile p: [select id, name from Profile where name!=null]) {
			profileMap.put(p.id,p);
		}
		isCSR=false;
		if (profileMap.get(userInfo.getProfileId()).name=='CSR') {
			isCSR=true;
		}
	}
	
	public void SourceCodeChange() {
		bProductChange=true;
		ApplyPromotion();
	}
	
	public void recalcShipping() {
		SourceCodeChange();
	}
	
	public void queryCouponPromo() {
		if (wrap.CouponCode!=null) {
			try {
				Promotion__c promo =[select id, name, offers__c from Promotion__c where name=:wrap.couponCode limit 1];
				wrap.newOrder.Promotions__r=promo;
				wrap.newOrder.promotions__c=promo.id;//DE492
			} catch (exception e) {}
		}
	}
	
	public void ApplyPromotion() {
		// DE574 -- initial change detection failed; using sourceCode compare
		String prevPromo = wrap.sourceCode;
		try {
			queryCouponPromo();
			if (wrap.selectedCatalog=='Current') {
				wrap.newOrder.catalog_source_code__c=null;
			} else {
				wrap.newOrder.catalog_source_code__c=wrap.selectedCatalog;
			}
			if (bProductChange) {
				wrap.PreTaxTotal=0;
				wrap.SubTotal=0;
				wrap.Discount=0;
				wrap.ShippingDiscount=0;
				wrap.ShippingCharges = 0;
				wrap.Total = 0;
				
				if (!MsgFromException) {
					MessagesList.clear();
				}
				
				if (!OLIWrapperList.isEmpty()) {
					Map <Integer, Order_Line_Items__c> oliSkuMap = new Map<Integer,Order_Line_Items__c>();
					Map <Integer, Order_Line_Items__c> PromotionalItems = new Map <Integer, Order_Line_Items__c>();
					Map <Integer, oliWrapper> oliSkuWrapMap = new Map<Integer,oliWrapper>();
			
					for (oliWrapper oliwrap: OLIWrapperList) {
						Order_Line_Items__c oli = oliWrap.OrdrLineItem;
						oliSkuMap.put(integer.valueOf(oli.product_number__c),oli);  
						oliSkuWrapMap.put(integer.valueOf(oli.product_number__c),oliwrap);				  
					}
					
					wrap.promoResponse = NBTYWSUtil.ProcessPromotions(wrap); 
					
					// DE574 -- see if the promo changes first
					boolean promoChanged = false;
					
					if (wrap.couponCode != null && wrap.newOrder.Promotions__r != null) {
						promoChanged = prevPromo != wrap.newOrder.Promotions__r.name;
					}
					
					System.debug('--------------------couponCode: ' + wrap.couponCode);
					System.debug('--------------------promotions__c: ' + wrap.newOrder.Promotions__r);
					
					wrap.ShippingDiscount = 0;
					wrap.Discount = 0;
					
					// DE574
					// If promo didn't change and it had free shipping, check for if it still has it or not
					// if not, then put on.
					if (!promoChanged && wrap.hadFreeShipping) {
						boolean add = true;
						for (WS_webstack_PromotionObjects_v2.Allowance i : wrap.promoResponse.Data.Allowances) {
							if (i.AllowanceCode == 69) {
								add = false;
								break;
							}
						}
						// If the promo allowance records list is empty AND the add was false, we couldn't eval
						if (wrap.promoResponse.Data.Allowances.size() == 0 && !add) {
							add = wrap.hadFreeShipping;
						}
						if (add) {
							WS_webstack_PromotionObjects_v2.Allowance a = new WS_webstack_PromotionObjects_v2.Allowance();
							a.AllowanceCode = 69;
							a.Amount = wrap.freeShippingValue;
						
							wrap.promoResponse.Data.Allowances.add(a);
						}
					}
					
					system.debug('wrap.promoResponse..........:'+ wrap.promoResponse);
					
					if (!wrap.promoResponse.IsSuccessful && wrap.promoResponse.StatusMessage != null) {
						MessagesList.add(wrap.promoResponse.StatusMessage); 
					}
					
					if (wrap.promoResponse.StatusMessage != null && wrap.promoResponse.StatusMessage.contains('Removed')) {
						Set<Integer> ProductsSet = new Set<Integer>();
						ProductsSet.addAll( oliSkuMap.keySet());
						MsgFromException = true;
						MessagesList.add(wrap.promoResponse.StatusMessage + '. In order to re-add this item, please set the shipping method to UPS and return to the cart page.');  
						if (wrap.promoResponse.data !=null && wrap.promoResponse.data.items != null &&   !wrap.promoResponse.data.items.isEmpty()) {
							for (WS_webstack_PromotionObjects_v2.ResponseItem item: wrap.promoResponse.data.items) {
								ProductsSet.remove(Integer.valueOf(item.ItemNumber));
							}
						}
						
						if (!ProductsSet.isEmpty()) {
							for (Integer i : ProductsSet) {
								ApexPages.currentPage().getParameters().put('RecOLItemId', oliSkuMap.get(i).Id);
								removeItem();
							}
						}
					}
					
					if (wrap.promoResponse.data !=null && wrap.promoResponse.data.items != null &&   !wrap.promoResponse.data.items.isEmpty()) {
						for (WS_webstack_PromotionObjects_v2.ResponseItem item: wrap.promoResponse.data.items) {
							Order_Line_Items__c oli = oliSkuMap.get(integer.valueOf(item.itemNumber));
							
							if (oli == null) {
								oli = new Order_Line_Items__c();
								oli.Order__c = wrap.newOrder.Id;
								PromotionalItems.put(integer.valueOf(item.itemNumber), oli);
							}
							oli.Original_Quantity__c = item.Quantity != null ? item.Quantity : 0 ;
							oli.Product_Quantity__c = item.Quantity != null ? item.Quantity : 0 ;
							try {
								oli.static_unit_price__c = oli.Original_Quantity__c ==0||item.SubTotal==0 ? null : item.SubTotal/ oli.Original_Quantity__c ;
							} catch (exception e) {
								system.debug('cannot calc static unit price');
							}
							if (oliSkuWrapMap.containsKey(Integer.valueOf(item.itemNumber)) && !oliSkuWrapMap.get(Integer.valueOf(item.itemNumber)).onlyOneItem) {
								oli.Product_Quantity__c += item.FreeQuantity !=null ? item.FreeQuantity : 0 ;
							}
							
							if (item.SubTotal != null){
								oli.Final_Price__c = item.SubTotal.setScale(2);
								wrap.SubTotal += oli.Final_Price__c;	
							}
							
							if (item.discount != null){
								oli.Discount__c = item.discount.setScale(2, System.RoundingMode.DOWN);
								oli.Final_Price__c = item.SubTotal.setScale(2)- oli.Discount__c;	
								wrap.Discount+=item.discount.setScale(2, System.RoundingMode.DOWN);
							}
						}
						
						if (wrap.promoResponse.data !=null && wrap.promoResponse.data.Allowances != null &&  !wrap.promoResponse.data.Allowances.isEmpty()) {
							boolean hadFreeShipping = false;
							for (WS_webstack_PromotionObjects_v2.Allowance allowance : wrap.promoResponse.data.allowances) {
								if (allowance.AllowanceCode == 69) {
									hadFreeShipping = true;
									wrap.ShippingDiscount += allowance.Amount.setScale(2, System.RoundingMode.DOWN);
								} else {
									wrap.discount += allowance.Amount.setScale(2, System.RoundingMode.DOWN);
								}
							}
						}
						
						System.debug('Shipping Discount: ' + wrap.freeShippingValue);
						wrap.Discount = wrap.Discount != null ? wrap.Discount.setScale(2) : 0;
						wrap.ShippingDiscount = wrap.ShippingDiscount != null ? wrap.ShippingDiscount.setScale(2) : 0;
						System.debug('Shipping Discount: ' + wrap.ShippingDiscount);
						system.debug(LoggingLevel.info, 'Discount~~~'+wrap.Discount );
						
						if (wrap.promoResponse.data !=null) {
							wrap.ShippingCharges	= wrap.promoResponse.data.shipping != null ? wrap.promoResponse.data.shipping.setScale(2) : 0;
							wrap.newOrder.Shipping_Method__c	= wrap.promoResponse.data.ShippingMethod;
							wrap.SubTotal = wrap.promoResponse.data.subTotal != null ? wrap.promoResponse.data.subTotal.setScale(2) : 0;
							wrap.PreTaxTotal = (wrap.SubTotal + wrap.ShippingCharges - wrap.Discount - wrap.ShippingDiscount).setScale(2);
							wrap.newOrder.Source_Code__c = wrap.promoResponse.data.SourceCode;
							wrap.newOrder.Weight__c = wrap.promoResponse.data.Weight; // added to save weight from promo response.
							wrap.newOrder.Replacement_Order__c = wrap.promoResponse.data.IsReplacementOrder==null?false: wrap.promoResponse.data.IsReplacementOrder; // added to save Replacement Order flag.
							if (wrap.newOrder.Replacement_Order__c) {
								wrap.newOrder.Shipment_Value__c= wrap.promoResponse.data.shipmentValue; 
								wrap.newOrder.Comments__c='';
								wrap.newOrder.Comments__c+=' Replacement value = $'+wrap.newOrder.Shipment_Value__c.setScale(2);
							} else {
								wrap.newOrder.Shipment_Value__c= wrap.promoResponse.data.shipmentValue;
								wrap.newOrder.Comments__c='';
							}
						}
						update wrap.newOrder;
					}
					
					if (!PromotionalItems.isEmpty()) {
						Set<String> ProductNumberSet = new Set<String>();
						
						for (Integer ItemNumber : PromotionalItems.keySet()) {
							String ProdNumAsString = String.valueOf(ItemNumber);
							ProdNumAsString = ProdNumAsString.leftPad(6);
							ProdNumAsString = ProdNumAsString.replace(' ','0');
							ProductNumberSet.add(ProdNumAsString);
						}
						
						for (Item__c prod : [SELECT Id, Name, Product_Number__c FROM Item__c WHERE Product_Number__c IN :ProductNumberSet]) {
							Order_Line_Items__c oli = PromotionalItems.get(Integer.valueOf(prod.Product_Number__c));
							
							if (oli != null) {
								oli.Product_Name__c = prod.Id;
							}
							
						}
						
						insert PromotionalItems.values();
						
						for (Order_Line_Items__c oli: [SELECT Id, Just_One_Item__c, Offer_Code__c, SKU_Number__c, Comments__c, Substituted_Item__c, Product_Name__r.Product_Number__c, Product_Name__c,Product_Name__r.Product_Image_URL__c ,Product_Name__r.Available_Inventory__c,Product_Name__r.Sale_Offer__c , Product_Name__r.Name, Product_Quantity__c, Original_Quantity__c, Product_Number__c, Price_Override__c, Override_Reason__c, Unit_Price__c, Final_Price__c, Tax__c FROM Order_Line_Items__c WHERE Id IN :PromotionalItems.values() ORDER BY CreatedDate]) {
							OLIWrapperList.add(new OLIWrapper(oli));
						}
						
					}
					
					List<Allowance__c> AllowanceList = [SELECT Id FROM Allowance__c WHERE Order__c = :wrap.newOrder.Id];
					
					delete AllowanceList;
					AllowanceList.clear();
					
					if (wrap.promoResponse.data !=null && wrap.promoResponse.data.Allowances != null &&  !wrap.promoResponse.data.Allowances.isEmpty()) {
						if (AllowanceList == null) {
							AllowanceList = new List<Allowance__c>();
						}
						
						for (WS_webstack_PromotionObjects_v2.Allowance allowRec : wrap.promoResponse.data.Allowances) {
							Allowance__c NewAllowanceRec = new Allowance__c();
							NewAllowanceRec.Order__c = wrap.newOrder.Id;
							NewAllowanceRec.Allowance_Code__c = string.valueOf(allowRec.AllowanceCode);
							NewAllowanceRec.Allowance_Amount__c = allowRec.Amount;
							AllowanceList.add(NewAllowanceRec);			  
						}
						
						/*if(AllowanceList != null && AllowanceList.size() > 0)
						{
							// If we had free shipping but not now and some other promo also applies; add it back in
							System.debug('Had free shipping? ' + wrap.hadFreeShipping);
							if (wrap.hadFreeShipping){
								boolean hasFreeShippingInList = false;
								// see if free shipping was still valid
								for (Allowance__c allowance: AllowanceList){
									if (allowance.Allowance_Code__c == '69')
										hasFreeShippingInList = true;
								}
								// if free shipping is no longer valid, put it back in
								if (!hasFreeShippingInList){
									Allowance__c a = new Allowance__c();
									a.Order__c = wrap.newOrder.Id;
									a.Allowance_Amount__c = wrap.freeShippingValue;
									a.Allowance_Code__c = '69';
									AllowanceList.add(a); // insert the free shipping back in
								}
							}
							insert AllowanceList;
						}
					}else{
						System.debug('Had free shipping? ' + wrap.hadFreeShipping);
						if (wrap.hadFreeShipping){
							boolean hasFreeShippingInList = false;
							// see if free shipping was still valid
							for (Allowance__c allowance: AllowanceList){
								if (allowance.Allowance_Code__c == '69')
									hasFreeShippingInList = true;
					}
							// if free shipping is no longer valid, put it back in
							if (!hasFreeShippingInList){
								Allowance__c a = new Allowance__c();
								a.Order__c = wrap.newOrder.Id;
								a.Allowance_Amount__c = wrap.freeShippingValue;
								a.Allowance_Code__c = '69';
								if (AllowanceList == null)
									AllowanceList = new List<Allowance__c>();
								AllowanceList.add(a); // insert the free shipping back in
								insert AllowanceList;
				}
						}*/
						
					}
					
					insert AllowanceList;
					
					wrap.PreTaxTotal = (wrap.SubTotal + wrap.ShippingCharges - wrap.Discount - wrap.ShippingDiscount).setScale(2);
				}
				bProductChange = false;
			}
		} catch(Exception ex) {
		//  ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
		}
	}
	
	public void backToAddressEdit() {
		wrap.CreateOrderSelected = false;
		wrap.CheckoutSelected=false;
	}
	
	public void checkoutFromAddress() {
		createOrderPassThrough(false);
		//AuthDownTimeUtils.queryOrder(wrap.newOrder.id);
		checkout();
	}
	
	public void createOrderPassThrough(boolean isNew) {
		if (wrap.selectedShippingAddress != '-- Add New Address --' && (wrap.selectedBillingAddress != '-- Add New Address --' || wrap.UseShipAsBill)) {
		try {
			system.debug('-----------------------------------------------Check Shipping: ' + wrap.selectedShippingAddress);
			system.debug('-----------------------------------------------Check Shipping: ' + wrap.selectedBillingAddress);
			
			if (wrap.UseShipAsBill) {
				wrap.newOrder.Ship_To_Address__c =  wrap.shippingAddress.Id;
				wrap.newOrder.Bill_To_Address__c =  wrap.shippingAddress.Id;
				
			} else {
				wrap.newOrder.Ship_To_Address__c =  wrap.shippingAddress.Id;
				wrap.newOrder.Bill_To_Address__c =  wrap.billingAddress.Id;
			}
				wrap.newOrder.No_Substitutes__c = Customer.Substitutes__c;
			wrap.newOrder.No_Invoice__c = Customer.No_Invoices__c;
			wrap.newOrder.No_Peanuts__c = Customer.No_Peanuts__c;
			wrap.newOrder.No_Catalogs__c = Customer.No_Catalogs__c;
			// wrap.newOrder.Comments__c = Customer.Customer_Notes__c;
			if (isNew) updateTotalItems();
			//reset if any credits applied in this new Order process - EditOrder mode
			if (wrap.CreditApplied) {
				wrap.Total =	0.00;
				wrap.TotalCreditApplied = 0.00;
				wrap.CustomerCreditAvailable = CustomerCredits;
				wrap.CreditApplied = false;
			}
			if (isNew) upsert wrap.newOrder;
			
			wrap.CreateOrderSelected = true;
			wrap.CheckoutSelected=false;
			if (wrap.newOrder.Catalog_Source_Code__c == '') {
				wrap.newOrder.Catalog_Source_Code__c = 'No Source code selected';
			}
		} catch(Exception ex) {
			wrap.CreateOrderSelected = false;
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
		} 
		} else {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select Shipping/Billing Address and save New Addresses to continue to next step.'));
		}
	}
		
	public void CreateOrder() {
			createOrderPassThrough(true);
	}
	
	/*******************************GA: 62658064 Start Block************************************************************/
	public Boolean checkCustomerBrand() {
		if (customer.RecordType.DeveloperName == 'Vitamin_World_Customer') {
			return true;
		} else {
			return false;
		}
	}
	
	public ws_Soa_Loyalty_RetrieveInfo.retrieveInfoResponse getLoyaltyResponse(String customerNum, String loyalty) {
		return WS_SOA_LoyaltyServicesUtils.retrieveInfoCallout(customerNum, loyalty);
	}
	
	public void addLoyaltyToDiscount() {
		
		system.debug('--------------------------------------------------------------------------addLoyaltyToDiscount: ' + selectedLoyalty);
		system.debug('--------------------------------------------------------------------------previousAmount: ' + previousAmount);
		if (previousAmount > 0.00) {
			wrap.couponDiscount = wrap.couponDiscount - previousAmount;
			system.debug('--------------------------------------------------------------------------negativeTotal 1: ' + negativeTotal);
			system.debug('--------------------------------------------------------------------------Total 1: ' + wrap.Total);
			wrap.Discount = wrap.Discount - previousAmount;
			wrap.Total += previousAmount;
		}
		
		if (selectedLoyalty != null && selectedLoyalty != 'SelectOne') {
			Set<String> codes = new Set<String>();
			for (ws_Soa_Loyalty_RetrieveInfo.couponDetail cd : coupons) {
				if (cd.code == selectedLoyalty && !codes.contains(cd.code)) {
					codes.add(cd.code);
					system.debug('------------------------------------------------------cd: ' + cd.code);
					system.debug('------------------------------------------------------selectedLoyalty: ' + selectedLoyalty);
					system.debug('--------------------------------------------------------------------------Original Discount Amount: ' + wrap.Discount);
					wrap.couponDiscount = decimal.valueOf(cd.amount);// + wrap.couponDiscount
					wrap.Total = wrap.Total - wrap.couponDiscount;
					negativeTotal = 0.00;
					system.debug('--------------------------------------------------------------------------negativeTotal 2: ' + negativeTotal);
					system.debug('--------------------------------------------------------------------------New Discount Amount: ' + wrap.Discount);
					previousAmount = decimal.valueOf(cd.amount);
					wrap.Discount = wrap.Discount + decimal.valueOf(cd.amount);
				}
			}
		} else {
			previousAmount = 0.00;
		}
		wrap.newOrder.Discount__c = wrap.Discount;
		wrap.newOrder.Order_Total__c = wrap.Total;
		update wrap.newOrder;
	}
	
	public List<SelectOption> getLoyaltySelectList() {
		List<ws_Soa_Loyalty_RetrieveInfo.couponDetail> cp1 = new List<ws_Soa_Loyalty_RetrieveInfo.couponDetail>();
		List<ws_Soa_Loyalty_RetrieveInfo.couponDetail> cp2 = new List<ws_Soa_Loyalty_RetrieveInfo.couponDetail>();
		for (ws_Soa_Loyalty_RetrieveInfo.couponDetail cd1 : coupons) {
			system.debug('---------------------------------------Wrap.Total: ' + wrap.Total);
			system.debug('---------------------------------------cd1.amount: ' + cd1.amount);
			system.debug('---------------------------------------cd1.status: ' + cd1.status);
			if (cd1.status == 'E' &&  decimal.valueOf(cd1.amount) <= wrap.Total) {
				cp1.add(cd1);
			}
			if ((cd1.status == 'A' || string.isBlank(cd1.status)) &&  decimal.valueOf(cd1.amount) <= wrap.Total) {
				cp2.add(cd1);
			}
		}
		loyaltySelectOp = new List<SelectOption>();
		loyaltySelectOp.add(new SelectOption('SelectOne', 'Select One'));
		for (ws_Soa_Loyalty_RetrieveInfo.couponDetail cd2 : cp1) {
			loyaltySelectOp.add(new SelectOption(cd2.code, cd2.code + ' - ' + cd2.amount + ' - ' + cd2.status));
		}
		for (ws_Soa_Loyalty_RetrieveInfo.couponDetail cd3 : cp2) {
			loyaltySelectOp.add(new SelectOption(cd3.code, cd3.code + ' - ' + cd3.amount + ' - ' + cd3.status));
		}
		if (loyaltySelectOp.size() > 0) {
			return loyaltySelectOp;
		} else {
			loyaltyMsg = 'No coupons available at this time';
			hasCoupons = false;
			return null;
		}
		
	}
	
	/*******************************GA: 62658064 End Block************************************************************/
	
	public void Checkout() {
		try {
			resetPaymentFields();
			if (OLIWrapperList.size() > 0) {
				// Runs into DML-Callout-DML Exception
				/*
				List<Order_Line_Items__c> OLItems = new List<Order_Line_Items__c>();
				
				for (OLIWrapper oWrap : OLIWrapperList) {
					OLItems.add(oWrap.OrdrLineItem);
				}
				
				update  OLItems;
				*/
				calculateTax();
				for (OLIWrapper oWrap : OLIWrapperList) {
					if (!(Integer.valueOf(oWrap.OrdrLineItem.Original_Quantity__c) > 0)) {
						ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Quantity should not be 0'));
						wrap.CreateOrderSelected = true;
						wrap.CheckoutSelected = false;
						break;
					} else if (oWrap.priceOverrideItem && (oWrap.OrdrLineItem.Override_Reason__c == null || oWrap.OrdrLineItem.Override_Reason__c == '')) {
						ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select an override reason'));
						wrap.CreateOrderSelected = true;
						wrap.CheckoutSelected = false;
						break;
					} else {
						wrap.CreateOrderSelected = false;
						wrap.CheckoutSelected = true;
					}
				}
				wrap.newOrder.tax__c=wrap.tax;
				wrap.newOrder.discount__c = wrap.Discount.setScale(2) + wrap.ShippingDiscount.setScale(2);
				wrap.newOrder.Order_Sub_Total__c=wrap.SubTotal ;
				wrap.newOrder.Order_Total__c= wrap.PreTaxTotal + wrap.Tax;
				wrap.newOrder.Shipping_Total__c=wrap.ShippingCharges;
				wrap.Total = wrap.newOrder.Order_Total__c;
				/*******************************GA: 62658064 Start Block************************************************************/
				if (isVWCust) {
					coupons = new List<ws_Soa_Loyalty_RetrieveInfo.couponDetail>();
					ws_Soa_Loyalty_RetrieveInfo.retrieveInfoResponse resp = getLoyaltyResponse(Customer.AS_400_Customer_Number__c, Customer.VW_Passport_Number__c);
					system.debug('-------------------------------------------Response: ' + resp);
					if (resp.retrieveInfoSuccessResponse != null) {
						if (resp.retrieveInfoSuccessResponse.coupons != null && resp.retrieveInfoSuccessResponse.coupons.size() > 0 && !wrap.newOrder.Replacement_Order__c) {
							for (ws_Soa_Loyalty_RetrieveInfo.couponDetail cp : resp.retrieveInfoSuccessResponse.coupons) {
								system.debug('-------------------------------------------cp: ' + cp);
								if (cp.status != 'R') {
									coupons.add(cp);
									system.debug('-------------------------------------------Coupons: ' + coupons);
								}
							}
							if (coupons.size() > 0) {
								
								getLoyaltySelectList();
								hasCoupons = true;
							} else {
								loyaltyMsg = 'No coupons available at this time';
							}
						} else {
							loyaltyMsg = 'No coupons available at this time';
						}
					} else {
						loyaltyMsg = 'Failed to retrieve loyalty rewards';
					}
				}
				/*******************************GA: 62658064 End Block************************************************************/
				upsert wrap.newOrder;
				upsert wrap.selectedOrderLineItems;//DO NOT REMOVE ENSURES TAX IS SAVED
				wrap.paymentInfo = new WS_soa_AuthorizePaymentService.PaymentInfo(wrap);//initialize the payment info object to match this orders
			} else {
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Atleast 1 Order line item should be added before checkout'));
				wrap.CreateOrderSelected = true;
				wrap.CheckoutSelected = false;
			}
			resetPaymentFields();
			
			if(wrap.Total <> null && wrap.Total == 0.00)
			{
				wrap.selectedpaymentType = 'Cash';
				resetPaymentFields();
			}
		} catch (Exception ex) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
		}
	}
	
	public void calcTaxOnShipMethodChange() {
		resetPaymentFields();
		calculateTax();
		wrap.newOrder.tax__c=wrap.tax;
		wrap.newOrder.discount__c = wrap.Discount.setScale(2) + wrap.ShippingDiscount.setScale(2);
		wrap.newOrder.Order_Sub_Total__c=wrap.SubTotal ;
		wrap.newOrder.Order_Total__c= wrap.PreTaxTotal + wrap.Tax;
		wrap.newOrder.Shipping_Total__c=wrap.ShippingCharges;
		wrap.Total =  wrap.newOrder.Order_Total__c;
		upsert wrap.newOrder;
		upsert wrap.selectedOrderLineItems;//DO NOT REMOVE ENSURES TAX IS SAVED
		wrap.paymentInfo = new WS_soa_AuthorizePaymentService.PaymentInfo(wrap);//initialize the payment info object to match this orders
	}
	
	public void authorizePayment() {
		wrap.newOrder=AuthDownTimeUtils.queryOrder(wrap.newOrder.id);
		wrap.paymentInfo.amount = wrap.newOrder.Order_Total__c.setScale(2);
		//system.debug('amount~~~'+wrap.paymentInfo.amount);
		//wrap.paymentInfo.amount = wrap.paymentInfo.amount.divide(1,2); 
		
		string existingToken = '';
		//if(string.isBlank(existingToken))existingToken = '';
		if (wrap.selectedpaymentType=='Existing Card') {
			existingToken = wrap.newOrder.Credit_Card_Token__c;
			wrap.newOrder.Replay_Existing_CC__c = true;
		}
		if (wrap.selectedpaymentType=='Stored Cards') {
			existingToken = ApexPages.currentPage().getParameters().get('radiotokenName');
			wrap.newOrder.Replay_Existing_CC__c = true;
		} else {
			wrap.newOrder.Replay_Existing_CC__c = false;
		}
		
		//GA: Start if statement for downtime
		if (AuthDownTimeUtils.checkDownTimeStatus()) {//if true returned means system is up and normal, false we are in down time process
			//place all the below login in here
			CreditCardValidator ccv = new CreditCardValidator();
			List <String> ccValidationErrors= new List <String>();
			if (wrap.selectedpaymentType=='Credit Card') ccValidationErrors = ccv.isValid(wrap.selectedccType, wrap.paymentInfo.creditCardNumber, wrap.paymentInfo.expiryYYYYMM);
			if (!ccValidationErrors.isEmpty()) {
				for (String s:ccValidationErrors ) {
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, s));
				}
			} else {
				//yyyymm validation
				try {
					wrap.paymentInfo.creditCardType=wrap.selectedccType;
					string tempCreditCardType = '';
					string tempCreditCardExpiry = '';
					if (wrap.selectedpaymentType=='Existing Card'||wrap.selectedpaymentType=='Stored Cards'){
						string YYYYMM = '';	 
						if(string.isblank(existingToken)){
							ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select one of the existing credit card.'));
							return;
						}else{
							if (wrap.selectedpaymentType=='Stored Cards'){
								
								for (OrderWizard_Wrapper.PaymentProfile temp :wrap.lstPaymentTokens) {
									if (temp.TokenId == existingToken) {
										YYYYMM = temp.creditcardExpiry;
										break;
									}
								}
								if(!CreditCardValidator.isValidExpiry(YYYYMM)){
									ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Credit Card is expired; Please delete it from the Customer.'));
									return;
								}
							}
						}
						
						wrap.paymentResponse = soa_WebservicesClientUtil.payfromExistingCard(wrap.newOrder.id,existingToken);
						
						//Get credit card and expiry date as these are required for AS400
						if (wrap.lstPaymentTokens != null) { // New order stored CC's
							for (OrderWizard_Wrapper.PaymentProfile otp :wrap.lstPaymentTokens) {
								if (otp.TokenId == existingToken) {
									wrap.newOrder.Credit_Card_Expiration_Date__c = otp.creditcardExpiry;
									wrap.newOrder.Credit_Card_Type__c = otp.creditcardType;
									break;
								}
							}
						}
					} else {
						// New Card
						if (wrap.paymentInfo.state == null && wrap.paymentInfo.countryCode != 'US' && wrap.paymentInfo.countryCode != 'CA') {
							wrap.paymentInfo.state = 'FO';
						}
						wrap.newOrder.Credit_Card_Expiration_Date__c = wrap.paymentInfo.expiryYYYYMM; 
						wrap.newOrder.Credit_Card_Type__c = wrap.selectedccType;
						wrap.paymentResponse = soa_WebservicesClientUtil.ProcessPaymentForNewCard(wrap.paymentInfo,wrap.isPaymentProfile);
					}
					
					if (wrap.paymentResponse.TokenNumber!=null) {
						wrap.newOrder.ownerId=userInfo.getUserId();//US468
						// 060982013 RB changes for Payment information
						system.debug('~~~~~ Expiration date of existing card' + wrap.paymentInfo.expiryYYYYMM);
						wrap.newOrder.Payment_Authorization_Code__c = wrap.paymentResponse.AuthorizationCode;
						wrap.newOrder.Credit_Card_Token__c = wrap.paymentResponse.TokenNumber;
						wrap.newOrder.Payment_Profile_ID__c = wrap.paymentResponse.PaymentProfileID;
						wrap.newOrder.Payment_Transaction_Reference_Number__c = wrap.paymentResponse.TransactionReferenceNumber;
						wrap.newOrder.Payment_Transaction_Reference_Index__c = wrap.paymentResponse.TransactionReferenceIndex;
						wrap.newOrder.Bank_Response_Date_Time__c = wrap.paymentResponse.BankResponseDateTime;
						wrap.newOrder.Authorization_Amount__c = wrap.paymentInfo.amount;
						wrap.newOrder.Order_Total__c= wrap.paymentInfo.amount;
						
						wrap.paymentInfo.creditCardNumber = null;
						if(!wrap.isPaymentProfile){
							Account newCustomer = [SELECT Id, Payment_Profile_Id__c,RecordType.Name,RecordType.DeveloperName FROM Account WHERE Id =:wrap.newOrder.customer__c];
							system.debug('~~~~ Customer Fetched~~' + newCustomer);
							system.debug('~~~~ Profile ID To be Updated' + wrap.paymentResponse.PaymentProfileID);
							
							newCustomer.Payment_Profile_Id__c = wrap.paymentResponse.PaymentProfileID;
							update newCustomer;
						}
						update wrap.newOrder;
						
						submitOrder();
						bRenderTokenFields=true;
						wrap.bRenderExistingCC=false;
						bRenderCCfields=false;
						ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Payment successfully authorized;'));
					} else {
						ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Payment not successfully authorized; please try again.'));
					}
				} catch (exception e){
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
				}
			}
		} else {//GA: start logic for Downtime
			//Here do my setting of the payment fields for down time
			AuthDownTimeUtils.setOrderReAuth(wrap,existingToken);
			bRenderTokenFields=true;
			wrap.bRenderExistingCC=false;
			bRenderCCfields=false;
			bOrderSubmitted=true;
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Payment Authentication is in Downtime mode, Order has been queued for authorization.'));
		}
		
	}
	
	public void createCredit() {
		system.debug('@@@@@ new credit amount'+ tempCredit);
		
		if (tempCredit.Credit_Amount__c != null) {
			credit__c newCredit = new Credit__c();
			newCredit.Account__c = Customer.Id;
			newCredit.Credit_Amount__c = tempCredit.Credit_Amount__c; 
			newCredit.Credit_Notes__c = 'Ad Hoc credit created for Order#'+ wrap.newOrder.Name;
			newCredit.Credit_Reason__c = tempCredit.Credit_Reason__c;
			// updating the variables to make sure calculation go right
			CustomerCredits = CustomerCredits + newCredit.Credit_Amount__c;
			wrap.CustomerCreditAvailable = CustomerCredits;
			insert newCredit;
		}
		
	}
	public void ApplyCredits() {
		if (wrap.CreditApplied) { 
			if (CustomerCredits != 0.00) {
				wrap.CustomerCreditAvailable = CustomerCredits;
				if (CustomerCredits > wrap.newOrder.Order_Total__c) {
					wrap.CustomerCreditAvailable = wrap.CustomerCreditAvailable - wrap.newOrder.Order_Total__c;
					wrap.TotalCreditApplied = 0 - wrap.newOrder.Order_Total__c; //display credits applied in -ve
				} else {
					 wrap.TotalCreditApplied = 0 - wrap.CustomerCreditAvailable; //display credits applied in -ve
					 wrap.CustomerCreditAvailable = 0.00;
				}
				
				wrap.newOrder.Order_Total__c = wrap.newOrder.Order_Total__c + wrap.TotalCreditApplied; 
				wrap.Total = wrap.newOrder.Order_Total__c;
			}
		} else {
			if (wrap.TotalCreditApplied != 0.00) {
				// DE581
				wrap.newOrder.Order_Total__c = wrap.Total + (wrap.TotalCreditApplied * -1);
				wrap.Total =	wrap.newOrder.Order_Total__c;
				wrap.TotalCreditApplied = 0.00;
				wrap.CustomerCreditAvailable = CustomerCredits;
			}
		}
		//Making default to cash when Order total is zero
		if(wrap.Total <> null && wrap.Total == 0.00)
		{
			wrap.selectedpaymentType = 'Cash';
			resetPaymentFields();
		}
		update wrap.newOrder;
	}
	
		
	public void submitOrder(){
		apexPages.getMessages().clear();
		wrap.newOrder.payment_type__c = wrap.selectedpaymentType;
		/*Start logic for cash validations*/
		if (wrap.selectedpaymentType=='Cash' && wrap.Total != 0.00){
			if (wrap.newOrder.payment_value__c==null){
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Cash Value is required for Cash Orders'));
			}
			if (wrap.newOrder.Batch_Number__c==null||wrap.newOrder.Batch_Number__c==''){
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Batch Number is required for Cash Orders'));
			}
			if (wrap.newOrder.Batch_Sequence_Number__c==null||wrap.newOrder.Batch_Sequence_Number__c==''){
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Batch Sequence Number is required for Cash Orders'));
			}
		} else if (wrap.selectedpaymentType=='Check') {
			if (wrap.newOrder.payment_value__c==null) {
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Check Value is required for Check Orders'));
			}
			if (wrap.newOrder.Batch_Number__c==null||wrap.newOrder.Batch_Number__c=='') {
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Batch Number is required for Check Orders'));
			}
			if (wrap.newOrder.Batch_Sequence_Number__c==null||wrap.newOrder.Batch_Sequence_Number__c=='') {
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Batch Sequence Number is required for Cash Orders'));
			}
			if (wrap.newOrder.Check_Number__c==null||wrap.newOrder.Check_Number__c=='') {
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Check Number is required for Check Orders'));
			}
		} else if (wrap.selectedpaymentType=='Existing Card'||wrap.selectedpaymentType=='Stored Cards') wrap.newOrder.Payment_Type__c='Credit Card';
		if (!apexPages.hasMessages()) {//only allow continue if there are no validation issues
			disableShipMethod = true;
			string checkStatus = [select order_status__c from Orders__c where id=:wrap.newOrder.id].order_status__c;
			
			
			if (wrap.newOrder.payment_type__c=='Credit Card') {
				if (!isCSR||checkStatus!='Internal Review') {
						wrap.newOrder.order_Status__c='Pending Submission';
					wrap.newOrder.Order_Date__c = system.now();
				}
			} else {
				wrap.newOrder.Payment_Authorization_Code__c = null;
				wrap.newOrder.Credit_Card_Token__c = null;
				wrap.newOrder.Payment_Profile_ID__c = null;
				wrap.newOrder.Payment_Transaction_Reference_Number__c = null;
				wrap.newOrder.Payment_Transaction_Reference_Index__c = null;
				wrap.newOrder.Bank_Response_Date_Time__c	=null;
				wrap.newOrder.Credit_Card_Expiration_Date__c = null;
				wrap.newOrder.Credit_Card_Type__c=null;
				wrap.newOrder.Authorization_Amount__c = null;
				// DE577 -- bypass when replace/replacement/credit and the value is 0.00
				if (isCSR && wrap.newOrder.Sales_Channel__c != 'Brand Website' && !(wrap.newOrder.Order_Total__c == 0 || wrap.newOrder.Replacement_Order__c)){
					wrap.newOrder.order_status__c ='Awaiting Physical Payment';
				} else {
						wrap.newOrder.order_Status__c='Pending Submission';
					wrap.newOrder.Order_Date__c = system.now();
				}
			}
			/*******************************GA: 62658064 Start Block************************************************************/
			if (isVWCust) {
				if (selectedLoyalty != null && selectedLoyalty != 'SelectOne') {
					Allowance__c vwCoupon = new Allowance__c();
					vwCoupon.VW_Loyalty_Coupon_Code__c = selectedLoyalty;
					vwCoupon.Allowance_Coupon__c = selectedLoyalty;
					for (ws_Soa_Loyalty_RetrieveInfo.couponDetail cd : coupons) {
						if (cd.code == selectedLoyalty) {
							vwCoupon.Allowance_Amount__c = decimal.valueOf(cd.amount);
							if (cd.status == 'E') {
								vwCoupon.Allowance_Code__c = EXPIRED;
							} else if (cd.status == 'A') {
								vwCoupon.Allowance_Code__c = UN_EXPIRED;
							}
							
							vwCoupon.Order__c = wrap.newOrder.Id;
							system.debug('--------------------------------------------------------------------------Total Discount Amount' + wrap.Discount);
						}
					}
					insert vwCoupon;
				}
			}
			/*******************************GA: 62658064 End Block************************************************************/
			//LD Apply Credit changes in Order
			if(wrap.CreditApplied){
				wrap.newOrder.Credit_Applied__c = wrap.CreditApplied;
				wrap.newOrder.Credit_Amount_Applied__c = wrap.TotalCreditApplied;
				
				//create credit record
				Credit__c custCredit = new Credit__c();
				custCredit.Account__c = Customer.Id;
				custCredit.Credit_Amount__c = wrap.TotalCreditApplied;
				custCredit.Credit_Notes__c = 'This a negative credit which was applied to Order #'+wrap.newOrder.Name;
				
				try {
					insert custCredit;
				} catch(exception e) {
					system.debug('Error inserting credit record' + e.getMessage()); 
				}
				
				// Create Allowance Record
				Allowance__c NewAllowanceRec = new Allowance__c();
				NewAllowanceRec.Order__c = wrap.newOrder.Id;
				NewAllowanceRec.Allowance_Code__c = EXPIRED;
				NewAllowanceRec.Allowance_Amount__c = wrap.TotalCreditApplied * (-1);
				
				try {
					insert NewAllowanceRec; 
				} catch(exception e) {
					system.debug('Error Inserting Allowance Record' + e.getMessage());
				}
			}
			try {
				if (wrap.newOrder.Replacement_Order__c) {
					try {
						if (wrap.newOrder.Shipment_Value__c <= 200.00) {
							wrap.newOrder.order_Status__c = 'Pending Submission'; 
							update wrap.newOrder;
						} else {
							system.debug('-------------------------------------------Over 200.00 replacement');
							// Create an approval request for the order
							Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
							system.debug('-------------------------------------------Approval req1-1: ' + req1);
							req1.setComments('Submitting request for approval from Order Wizard.');
							system.debug('-------------------------------------------Approval req1-2: ' + req1);
							req1.setObjectId( wrap.newOrder.id);
							system.debug('-------------------------------------------Approval req1-3: ' + req1);
							// Submit the approval request for the account
							Approval.ProcessResult result = Approval.process(req1);
							system.debug('-------------------------------------------Approval result: ' + result);
							wrap.newOrder.order_Status__c='Awaiting Approval';
							bOrderSubmitted = true;
						}
					} catch (exception e) {
						system.debug('-------------------------------------------Approval Exception: ');
						wrap.newOrder.order_Status__c='Pending Submission';
						system.debug('Tried to submit for approval, no applicable process');
						//bOrderSubmitted = true;
					}
					wrap.newOrder.Order_Date__c = system.now();
				} else {
					update wrap.newOrder;
				}
				bOrderSubmitted = true;
			} catch (exception e) {
				bOrderSubmitted=false;
			}
		}
	}
	
	public boolean disableShipMethod { get; set; }
	public void processSelectedShipMethod() {
		disableShipMethod = false;
		
		// DE298, DE375, DE392
		if (wrap.shippingAddress.Country_Picklist__c == 'UNITED STATES') {
			for (SelectOption	so : wrap.MethodList) {
				if(so.getValue() == 'International') {
					so.setDisabled(true);
				}
			}
			wrap.newOrder.Shipping_Method__c = 'UPS';
			disableShipMethod = false;		  
		} else {
			for (SelectOption	so : wrap.MethodList) {
				if(so.getValue() == 'International') {
					so.setDisabled(false);
				}
			}
			wrap.newOrder.Shipping_Method__c = 'International';//DE298
			disableShipMethod = true;
		}
		
		if (wrap.shippingAddress.International_address__c) {
			wrap.newOrder.Shipping_Method__c = 'International';//DE298
			disableShipMethod = true;
		}
		
		if (wrap.shippingAddress.Address_Line_1__c != null) {
			string shipAddr = wrap.shippingAddress.Address_Line_1__c;
			shipAddr = shipAddr.replace('.', '');
			shipAddr = shipAddr.replace(' ', '');
			
			if (shipAddr.containsIgnoreCase('pobox')) {
				wrap.newOrder.Shipping_Method__c = 'USPS';
				disableShipMethod = true;
			}
		}
	}
	
	//US361:-START Address Validation   ---- LD	 
	public boolean validAddress(Address__c validateAddr){
		// Write Address validation logic here
		boolean validAddr = false;
		if (Test.isRunningTest()) {
			validAddr = true;
		} else {
			if (validateAddr.Country_Picklist__c=='CANADA') {
				validateAddr.Country__c='CA';
			}
			validateAddr = AddressValidator.validateAddress(validateAddr);
			
			if (validateAddr.Validated__c) {
				validAddr = true;
			} else {
				wrap.CreateOrderSelected = false;
				wrap.CheckoutSelected = false;
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Warning, 'You entered an invalid address. Please check the validation failed reason and re-try. Validation Error Reason : '+ validateAddr.Validation_Error_Reason__c));
			}
		}
		return validAddr;
	}
	

	public void clearShipAddress() {
		wrap.selectedShippingAddress = '-- Add New Address --';
		wrap.shippingAddress = new Address__c(); 
		wrap.UseShipAsBill = false;
		wrap.newOrder.Shipping_Method__c ='';
		showSaveShipAddrBtn = true;
		disableShipMethod = false;
	}
	
	public void clearBillAddress() {
		wrap.selectedBillingAddress = '-- Add New Address --';
		wrap.billingAddress = new Address__c(); 
		wrap.UseShipAsBill = false;
		showSaveBillAddrBtn = true;
	}
	
	public static boolean AddressValidationPass(Address__c adr) {
		if (adr.City__c == '' || adr.City__c == null) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'The City cannot be blank'));
			return false;
		}
		if (AddressTriggerHelper.isUSAddress(adr.Country_Picklist__c)) {
			if ((adr.State_Providence__c == '' || adr.State_Providence__c == null)) {
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'The State/Providence cannot be blank'));
				return false;
			}
			if (adr.Zip_Code__c == '' || adr.Zip_Code__c == null) {
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'The Zip/Postal Code cannot be blank'));
				return false;
			}
		} else {
			if (adr.Foreign_Postal_Code__c == '' || adr.Foreign_Postal_Code__c == null) {
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'The Foreign Postal Code cannot be blank'));
				return false;
			}
		}
		
		return true;
	}
	
	public void createShipAddress() {
		//Address Validations
		if (AddressValidationPass(wrap.shippingAddress)) {
			showSaveShipAddrBtn = false;
			try {
				/*
				if(wrap.shippingAddress.Country_Picklist__c != null && wrap.shippingAddress.Country_Picklist__c != 'UNITED STATES')
				{
					wrap.shippingAddress.Foreign_Postal_Code__c = wrap.shippingAddress.Zip_Code__c;
				}*/
				if (wrap.selectedShippingAddress != '-- Add New Address --' ) { //MODE = EDIT Address
					//wrap.CustomerAddressesMap.remove(wrap.shippingAddress.Id);	  
					update wrap.shippingAddress;
					wrap.CustomerAddressesMap.put(wrap.shippingAddress.Id,wrap.shippingAddress);	
					wrap.selectedShippingAddress = wrap.shippingAddress.Id;
					wrap.shippingAddressList.clear();
					wrap.shippingAddressList.add(new SelectOption ('-- Add New Address --', '-- Add New Address --'));
					for (Id KeyValue : wrap.CustomerAddressesMap.keySet()) {
						if (wrap.CustomerAddressesMap.get(KeyValue).Address_Type__c.contains('Shipping')) {
							wrap.shippingAddressList.add(new SelectOption (KeyValue , wrap.FormatAddress(wrap.CustomerAddressesMap.get(KeyValue))));	
						}
					}
				
					if (wrap.UseShipAsBill) {
						wrap.shippingAddress.Address_Type__c = 'Billing;Shipping';
						update wrap.shippingAddress;
						wrap.billingAddress = wrap.shippingAddress;
						wrap.CustomerAddressesMap.put(wrap.billingAddress.Id,wrap.billingAddress);
						wrap.selectedBillingAddress = wrap.billingAddress.Id;
						wrap.billingAddressList.clear();
						wrap.billingAddressList.add(new SelectOption ('-- Add New Address --', '-- Add New Address --'));
						for (Id KeyValue : wrap.CustomerAddressesMap.keySet()) {
							if (wrap.CustomerAddressesMap.get(KeyValue).Address_Type__c.contains('Billing')) {
								wrap.billingAddressList.add(new SelectOption (KeyValue , wrap.FormatAddress(wrap.CustomerAddressesMap.get(KeyValue)))); 
							}
						}
					}
				} else { //MODE = CREATE ADDRESS
					if (wrap.shippingAddress.Id == null) {
					if (wrap.UseShipAsBill) {
						 wrap.shippingAddress.Address_Type__c = 'Billing;Shipping';
					} else {
						 wrap.shippingAddress.Address_Type__c = 'Shipping';
					}
					wrap.shippingAddress.Customer__c = Customer.Id;
					if (wrap.shippingAddress.Validation_Override__c) {
						insert wrap.shippingAddress;
					} else {
						if (wrap.shippingAddress.Country_Picklist__c == null) {
							wrap.shippingAddress.Country_Picklist__c = 'UNITED STATES';
						}
						if (AddressTriggerHelper.isUSAddress(wrap.shippingAddress.Country_Picklist__c)) {
							if(validAddress(wrap.shippingAddress)) insert wrap.shippingAddress;
						}
						else insert wrap.shippingAddress;
						}
					}
					
					if (wrap.shippingAddress.Id != null && wrap.selectedShippingAddress == '-- Add New Address --') {
						try {
							Address__c addr = [Select Id From Address__c Where Id = :wrap.shippingAddress.Id];
							if (addr != null){
								wrap.CustomerAddressesMap.put(wrap.shippingAddress.Id,wrap.shippingAddress);
								wrap.selectedShippingAddress = wrap.shippingAddress.Id;
								wrap.shippingAddressList.add(new SelectOption (wrap.shippingAddress.Id , wrap.FormatAddress(wrap.shippingAddress)));
								if(wrap.UseShipAsBill){
									processBillSameAsShip();
									wrap.billingAddress = wrap.shippingAddress;
									wrap.CustomerAddressesMap.put(wrap.billingAddress.Id,wrap.billingAddress);
									wrap.selectedBillingAddress = wrap.billingAddress.Id;
									wrap.billingAddressList.add(new SelectOption (wrap.billingAddress.Id , wrap.FormatAddress(wrap.billingAddress)));
								}
							}
						} catch(Exception ex) {
							if (wrap.UseShipAsBill) {
								processBillSameAsShip();
							}
							ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Warning, 'You entered a duplicate Address. Please select the address from the existing Shipping addresses list or please enter a differnt address.'));
							showSaveShipAddrBtn = true;
						}
					}
				}
				
				if (wrap.shippingAddress.Id != null) {
						wrap.shippingAddress=[SELECT Id, Address_Line_1__c, Address_Line_2__c, Address_Line_3__c, Address_Line_4__c, Address_Type__c, City__c, Country__c, State_Providence__c, Residential_Commercial__c,
											 Zip_Code__c, Primary_Ship_to_Address__c, Primary_Bill_To_Address__c, Validated__c, Validation_Error_Reason__c, Validation_Override__c, Country_Picklist__c, Foreign_Postal_Code__c, International_Address__c
											 FROM Address__c 
											 WHERE ID =: wrap.shippingAddress.id];
				}
			} catch(Exception ex) {
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
			}
		}
		processSelectedShipMethod();
	}
	
	public void createBillAddress(){
		//Address Validations
		if (AddressValidationPass(wrap.billingAddress)) {
		try {
			/*
			if(wrap.billingAddress.Country_Picklist__c != null && wrap.billingAddress.Country_Picklist__c != 'UNITED STATES')
				{
					wrap.billingAddress.Foreign_Postal_Code__c = wrap.billingAddress.Zip_Code__c;
				}
			*/
		if (!wrap.UseShipAsBill) {
			if (wrap.selectedbillingAddress != '-- Add New Address --' ) { //MODE = EDIT Address
				wrap.CustomerAddressesMap.remove(wrap.billingAddress.Id);
				update wrap.billingAddress;
				wrap.CustomerAddressesMap.put(wrap.billingAddress.Id,wrap.billingAddress);
				wrap.selectedBillingAddress = wrap.billingAddress.Id;
				wrap.billingAddressList.add(new SelectOption (wrap.billingAddress.Id , wrap.FormatAddress(wrap.billingAddress)));
			} else { //MODE = CREATE ADDRESS
					if (wrap.billingAddress.Id == null) {
						wrap.billingAddress.Address_Type__c = 'Billing';
						wrap.billingAddress.Customer__c = Customer.Id;
						if (wrap.billingAddress.Validation_Override__c) {
							insert wrap.billingAddress;
						}
						else{
						if (wrap.billingAddress.Country_Picklist__c == null) wrap.billingAddress.Country_Picklist__c = 'UNITED STATES';
						if(AddressTriggerHelper.isUSAddress(wrap.billingAddress.Country_Picklist__c)){
							if(validAddress(wrap.billingAddress)) insert wrap.billingAddress;
						}
						else insert wrap.billingAddress;
						} 
					}
					if(wrap.billingAddress.Id != null && wrap.selectedBillingAddress == '-- Add New Address --'){
						try{
						Address__c addr = [Select Id From Address__c Where Id = :wrap.billingAddress.Id];
						if (addr != null){
							wrap.CustomerAddressesMap.put(wrap.billingAddress.Id,wrap.billingAddress);
							wrap.selectedBillingAddress = wrap.billingAddress.Id;
							wrap.billingAddressList.add(new SelectOption (wrap.billingAddress.Id , wrap.FormatAddress(wrap.billingAddress)));
						 }
						}
						catch(Exception ex){
						ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Warning, 'You entered a duplicate Address. Please select the address from the existing Billing addresses list or please enter a differnt address.'));
						}
					}
				}
			} else {
				if(!wrap.shippingAddress.Address_Type__c.contains('Billing')){
					wrap.shippingAddress.Address_Type__c = 'Billing;Shipping';
					update wrap.shippingAddress;
					wrap.CustomerAddressesMap.put(wrap.shippingAddress.Id,wrap.shippingAddress);
					wrap.selectedBillingAddress = wrap.shippingAddress.Id;				  
				}
			}
			
			wrap.shippingAddressList.clear();
			wrap.shippingAddressList.add(new SelectOption ('-- Add New Address --', '-- Add New Address --'));
			for (Id KeyValue : wrap.CustomerAddressesMap.keySet()) {
				if (wrap.CustomerAddressesMap.get(KeyValue).Address_Type__c.contains('Shipping')) {
					wrap.shippingAddressList.add(new SelectOption (KeyValue , wrap.FormatAddress(wrap.CustomerAddressesMap.get(KeyValue))));
				}
			}
			
			wrap.billingAddressList.clear();
			wrap.billingAddressList.add(new SelectOption ('-- Add New Address --', '-- Add New Address --'));
			for (Id KeyValue : wrap.CustomerAddressesMap.keySet()) {
				if (wrap.CustomerAddressesMap.get(KeyValue).Address_Type__c.contains('Billing')) {
					wrap.billingAddressList.add(new SelectOption (KeyValue , wrap.FormatAddress(wrap.CustomerAddressesMap.get(KeyValue)))); 
				}
			}
		} catch(Exception ex) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
		}
		showSaveBillAddrBtn = false;
		}
	}
	
	//US361:-END	Address Validation  ---- LD
		
	public void processSelectedShipAddr() {
		if (wrap.selectedShippingAddress != '-- Add New Address --' ) {
			wrap.shippingAddress = wrap.CustomerAddressesMap.get(wrap.selectedShippingAddress);
			if (wrap.selectedShippingAddress == wrap.selectedBillingAddress) {
				wrap.UseShipAsBill = true;
			} else {
				wrap.UseShipAsBill = false;
			}
			processSelectedShipMethod(); //reset Shipping method for the selected address
		} else {
			wrap.shippingAddress = new Address__c();
			wrap.UseShipAsBill = false;
			wrap.newOrder.Shipping_Method__c = '';
		}
		if (wrap.selectedShippingAddress!= null) { 
			if(wrap.UseShipAsBill) {
				//wrap.billingAddress = wrap.shippingAddress;
				processBillSameAsShip();
			}
		} else{
			wrap.shippingAddress = new Address__c();
			wrap.UseShipAsBill = false;
			wrap.newOrder.Shipping_Method__c = '';
		}
		processSelectedShipMethod();
	}
	
	public void saveOrder() {
		try {
			wrap.newOrder.payment_type__c = wrap.selectedpaymentType;
			upsert wrap.newOrder;
			List <Order_Line_Items__c> oliList = new List <Order_Line_Items__c>();
			for (OLIWrapper w: oliWrapperList) {
				oliList.add(w.OrdrLineItem);
			}
			upsert oliList;
		} catch(exception e) {
			// ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select an override reason'));
		}
	}
	
	public void cancelOrder() {
		//delete wrap.newOrder;
	}
	
	public void showSaveBillAddr() {
		showSaveBillAddrBtn = true;
	}
	
	public void showSaveShipAddr(){ 
		showSaveShipAddrBtn = true;
		if (wrap.selectedShippingAddress != '-- Add New Address --' && wrap.selectedBillingAddress == wrap.selectedShippingAddress) {
			wrap.UseShipAsBill = true;
			wrap.billingAddress = wrap.shippingAddress;
			wrap.selectedBillingAddress = wrap.billingAddress.Id;
		}
		if (wrap.UseShipAsBill) {
			processBillSameAsShip();
		}
	}
	
	public void processBillSameAsShip() {
		if (wrap.UseShipAsBill) {
				if (wrap.selectedShippingAddress != '-- Add New Address --' && wrap.shippingAddress.id != null) {
				if (!showSaveShipAddrBtn) {
					wrap.billingAddress = wrap.shippingAddress;
					wrap.selectedBillingAddress = wrap.billingAddress.Id;
					if (!wrap.billingAddress.Address_Type__c.contains('Billing')) {
						showSaveBillAddrBtn = true;
					}	
				} else {//LD 6/18 - START
					wrap.billingAddress = new Address__c();
					wrap.selectedBillingAddress = '-- Add New Address --';
					// wrap.billingAddress = wrap.shippingAddress; //this line seems to overwrite the shipping address with one saved in DB.
					billSameAsShip(wrap.shippingAddress,wrap.billingAddress);
				}
				//LD 6/18 - END
			} else {
				billSameAsShip(wrap.shippingAddress,wrap.billingAddress);
			}
		}
	}
	
	public void billSameAsShip(Address__c shipAddr, Address__c billAddr) {
		billAddr.Address_Line_1__c = shipAddr.Address_Line_1__c;
		billAddr.Address_Line_2__c = shipAddr.Address_Line_2__c;
		billAddr.Address_Line_3__c = shipAddr.Address_Line_3__c;
		billAddr.Address_Line_4__c = shipAddr.Address_Line_4__c;
		billAddr.City__c = shipAddr.City__c;
		billAddr.State_Providence__c = shipAddr.State_Providence__c;
		billAddr.Zip_Code__c = shipAddr.Zip_Code__c;
		billAddr.Foreign_Postal_Code__c = shipAddr.Foreign_Postal_Code__c;
		billAddr.Country_Picklist__c = shipAddr.Country_Picklist__c;
	}	
	
	public void processSelectedBillAddr() {
		if (wrap.selectedBillingAddress != null && wrap.selectedBillingAddress != '-- Add New Address --' ) {
				wrap.billingAddress = wrap.CustomerAddressesMap.get(wrap.selectedBillingAddress);
		} else {
			wrap.billingAddress = new Address__c();
		}
		
		if (wrap.billingAddress.Id == null || (wrap.billingAddress.Id != null && wrap.billingAddress.Id != wrap.shippingAddress.Id)) {
				wrap.UseShipAsBill = false;
		} else if (wrap.billingAddress.Id != null && wrap.billingAddress.Id == wrap.shippingAddress.Id) {
			wrap.UseShipAsBill = true;
		}
	}
	
	public void ProcessUpdateQuantity() {
		searchedRecordId = ApexPages.currentPage().getParameters().get('RecOLIProduct');
		system.debug('searchedRecordId~~~~'+searchedRecordId);
		OLIQuantity = ApexPages.currentPage().getParameters().get('RecOLIQuantity') != null ? Integer.valueOf(ApexPages.currentPage().getParameters().get('RecOLIQuantity')) : 0;
		bQuantityChanged = true;
			
		ProcessSelectedItem();
	}
	
	public void ProcessSelectedItem() {
		system.debug('searchedRecordId~~~~'+searchedRecordId);
		ItemSelected = [SELECT Id, Name, Description__c, Product_Image_URL__c, Sale_Offer__c,   Product_Number__c, Sale_Price__c, Available_Inventory__c, Inventory_Status__c, CurrencyIsoCode, Substitute_Item__c, Substitute_Item__r.Name, Substitute_Item_Number__c, Substitute_Item__r.Available_Inventory__c FROM Item__c WHERE Id =:searchedRecordId ];
		
		Integer verificationQuantity = OLIQuantity != null ? OLIQuantity : 0 ;
		
		if (Integer.valueOf(ItemSelected.Available_Inventory__c) > verificationQuantity) {
			bShowChoiceForSubtitute = false;
		} else {
			bShowChoiceForSubtitute = true;
		}
	}
	
	public void AddSubstituteToOrder() {
		bRecommendation = false;
		bSubstituteSelected = true;
		
		if (String.isNotBlank(ApexPages.currentPage().getParameters().get('SelProdId')))
			searchedRecordId = ApexPages.currentPage().getParameters().get('SelProdId');
		
		if(bQuantityChanged) {
			for (OLIWrapper oWrap : OLIWrapperList) {
				if (oWrap.OrdrLineItem.Product_Name__c == searchedRecordId) {
					ApexPages.currentPage().getParameters().put('RecOLItemId', oWrap.OrdrLineItem.Id);
					break;
				}
			}
			removeItem();
		}
		
		searchedRecordId = ItemSelected.Substitute_Item__c; 
		ProcessAddItem();
	}
	
	public void AddItemToOrder() {
		bRecommendation = false;
		ProcessAddItem();
	}
	 
	public void ProcessAddItem() {
		// Reset the bShowChoiceForSubtitute = false;
		bShowChoiceForSubtitute = false;
		MessagesList.clear();
		MsgFromException = false;
		if(String.isNotBlank(ApexPages.currentPage().getParameters().get('SelProdId')))
				searchedRecordId = ApexPages.currentPage().getParameters().get('SelProdId');
				
		/* If its the first product added to cart and customer doesnt have any recommendations get p2p*/
			boolean bBundle = false; // only true if it was a recommendation and there is an active bundle on it
			Item__c item = [select product_suffix__c,Restrictions__c, id from Item__c where id=:searchedRecordId];
				if (!isProduct){ //only reset products list if there aren't already recs
					recWrap = new RecommendationsWrapper(item);
					if (!recWrap.productList.isEmpty()) isProduct=true;
				}
				
				if (bRecommendation){//only need to check if its a bundle if recommendation was also true
					bBundle =[select count() from bundle__c where active__c =true and start_date__c<=:system.today() and end_date__c >=:system.today() and Item__c=:item.id]>0? true:false;
				}
				
			Set<Id> AlreadySelectedItemsId = new Set<Id>();
			OLIWrapper tempOLIRec;
			for (Order_Line_Items__c OLI : [Select Product_Name__c , Sku_number__c FROM Order_Line_Items__c WHERE Order__c = :wrap.newOrder.Id ]) {
				AlreadySelectedItemsId.add(OLI.Product_Name__c);
			}
			
			if (!AlreadySelectedItemsId.isEmpty() && AlreadySelectedItemsId.contains(searchedRecordId)) {
				for (OLIWrapper oWrap : OLIWrapperList) {
					if(oWrap.OrdrLineItem.Product_Name__c == searchedRecordId) {
						tempOLIRec =	oWrap;
						break;
					}
				}
				if (bQuantityChanged) {
					tempOLIRec.OrdrLineItem.Original_Quantity__c = OLIQuantity;
					bQuantityChanged = false;
				} else {
					tempOLIRec.OrdrLineItem.Original_Quantity__c += 1;
				}
				
				if (bBundle) tempOLIRec.OrdrLineItem.Bundle_Recommendation__c=true;
				if (bRecommendation) tempOLIRec.OrdrLineItem.Product_Recommendation__c=true;
				if (bSubstituteSelected) {
					tempOLIRec.OrdrLineItem.Comments__c = 'Original item requested =' + ItemSelected.Product_Number__c ;
					tempOLIRec.OrdrLineItem.Substituted_Item__c = ItemSelected.Id;
				}
			//  ApplySaleOffer(tempOLIRec);
				try {
					upsert  tempOLIRec.OrdrLineItem;
					bProductChange=true;
					bSubstituteSelected = false;
				} catch (exception e) {
				//  ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
					if (ApexPages.hasMessages()) {
						for (ApexPages.Message msg : ApexPages.getMessages()) {
							MessagesList.add(msg.getSummary()); 
							MsgFromException = true;
						}
					}
					bProductChange=false;
				}
			} else {
				Item__c selectedItem = [SELECT Id, Name, Description__c, Product_Image_URL__c, Sale_Offer__c,   Product_Number__c, Sale_Price__c, Available_Inventory__c, CurrencyIsoCode,(SELECT Substitute_Item_Number__c,Substitute_Item__c,Substitute_Multiplier__c FROM Items__r) FROM Item__c WHERE Id =:searchedRecordId ];
				tempOLIRec = new OLIWrapper(wrap.newOrder, selectedItem);
				if (bQuantityChanged) {
					tempOLIRec.OrdrLineItem.Original_Quantity__c = OLIQuantity;
					bQuantityChanged = false;
				} else {
					tempOLIRec.OrdrLineItem.Original_Quantity__c = 1;
				}
				if (bBundle) tempOLIRec.OrdrLineItem.Bundle_Recommendation__c=true;
				if (bRecommendation) tempOLIRec.OrdrLineItem.Product_Recommendation__c=true;
				if (bSubstituteSelected) {
					tempOLIRec.OrdrLineItem.Comments__c = 'Original item requested =' + ItemSelected.Product_Number__c ;
					tempOLIRec.OrdrLineItem.Substituted_Item__c = ItemSelected.Id;
				}
			//  ApplySaleOffer(tempOLIRec);
				try {
					upsert tempOLIRec.OrdrLineItem;
					bProductChange=true;
					bSubstituteSelected = false;
				} catch (exception e) {
					//ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
					bProductChange=false;
					
					if (ApexPages.hasMessages()) {
						for (ApexPages.Message msg : ApexPages.getMessages()) {
							MessagesList.add(msg.getSummary()); 
							MsgFromException = true;
						}
					}
					return;//need to kick out so don't execute the SOQL below
				}
				// The latest should be on the top of the list	   
				tempOLIRec.OrdrLineItem = [SELECT Id, Just_One_Item__c, Offer_Code__c, Sku_Number__c, Tax_Code__c, Substituted_Item__c, Comments__c ,Product_Name__r.Product_Number__c, Product_Name__c,Product_Name__r.Product_Image_URL__c ,Product_Name__r.Available_Inventory__c,Product_Name__r.Sale_Offer__c , Product_Name__r.Name, Product_Quantity__c, Original_Quantity__c, Product_Number__c, Price_Override__c, Override_Reason__c, Unit_Price__c, Final_Price__c, Tax__c FROM Order_Line_Items__c WHERE Id = :tempOLIRec.OrdrLineItem.Id];
				List <OLIWrapper> tempWrapList = new List <OLIWrapper>();
				tempWrapList.addAll(OLIWrapperList);
				OLIWrapperList.clear();
				OLIWrapperList.add(tempOLIRec); 
				OLIWrapperList.addAll(tempWrapList);
				AddToSelectedOrderLineItemsList(OLIWrapperList);  
				/*
				for (integer k=oliWrapperList.size()-1; k>=0; k--){
					tempWrapList.add(OLIWrapperList[k]);
				}
				OLIWrapperList = tempWrapList;//reverse order
				*/
			}
	}
	
	public void AddToSelectedOrderLineItemsList(List<OLIWrapper> OliWrapList)
	{
		wrap.selectedOrderLineItems.clear();
		for(OLIWrapper oli : OliWrapList)
		{
			wrap.selectedOrderLineItems.add(oli.ordrLineItem);
		}
	}
	
	public void ApplySaleOffer(OLIWrapper OLIRec) 
	{
		if(!OLIRec.onlyOneItem && !OLIRec.priceOverrideItem && OLIRec.ProductSaleOffer != null && OLIRec.ProductSaleOffer != '')
		{
			if(OLIRec.ProductSaleOffer == '5 for 2')
			{
				Integer remainder = math.mod(Integer.valueOf(OLIRec.OrdrLineItem.Original_Quantity__c), 2);
				Integer Multiplier = Integer.valueOf(OLIRec.OrdrLineItem.Original_Quantity__c / 2);
				
				Sale_Offer_Settings__c SOSRec1 = Sale_Offer_Settings__c.getInstance(OLIRec.ProductSaleOffer);   
				OLIRec.OrdrLineItem.Original_Quantity__c = Integer.valueOf(OLIRec.OrdrLineItem.Original_Quantity__c) - remainder;
				OLIRec.FreeQuantity = Multiplier * Integer.valueOf(SOSRec1.Free_Quantity__c) ;
				
				if(remainder != 0)
				{
					Sale_Offer_Settings__c SOSRec2 = Sale_Offer_Settings__c.getInstance('2 for 1');
					OLIRec.FreeQuantity += Integer.valueOf(SOSRec2.Free_Quantity__c) ;
					OLIRec.OrdrLineItem.Original_Quantity__c += remainder;
				}
			}
			else if(OLIRec.ProductSaleOffer != 'Buy 1 Get 1 50% OFF' && OLIRec.ProductSaleOffer != 'Buy 1 Get 1 for a penny'&&OLIRec.ProductSaleOffer!='% OFF')
			{
				Sale_Offer_Settings__c SOSRec = Sale_Offer_Settings__c.getInstance(OLIRec.ProductSaleOffer);
				OLIRec.FreeQuantity = Integer.valueOf(OLIRec.OrdrLineItem.Original_Quantity__c) * Integer.valueOf(SOSRec.Free_Quantity__c) ;
			}
		}
		OLIRec.OrdrLineItem.Product_Quantity__c = OLIRec.OrdrLineItem.Original_Quantity__c  + Decimal.valueOf(OLIRec.FreeQuantity);
	}
	
	public void removeItem() {
		Id RecOLItemId = ApexPages.currentPage().getParameters().get('RecOLItemId');
		Integer IndexOfItemToRemove;
		Integer i = 0;
		
		for (OLIWrapper oWrap : OLIWrapperList) {
			if (oWrap.OrdrLineItem.Id == RecOLItemId) {
				IndexOfItemToRemove = i;
			}
			i++;
		}
		
		if(IndexOfItemToRemove != null) {
			OLIWrapper oWrapToDelete = OLIWrapperList.get(IndexOfItemToRemove);	 
			OLIWrapperList.remove(IndexOfItemToRemove);	 
			try {
				delete oWrapToDelete.OrdrLineItem;
			}catch(Exception e){
				system.debug(String.valueOf('OrderWizard_NewOrder.removeItem() exception: '+e.getMessage()));
			}
		}
		AddToSelectedOrderLineItemsList(OLIWrapperList);
	}
	
	public void OnlyOneItem() {
		Id RecOLItemId = ApexPages.currentPage().getParameters().get('RecOLItemOneQuantity');
		Integer IndexOfItemToSetQuantity;
		Integer i = 0;
		
		for (OLIWrapper oWrap : OLIWrapperList) {
			if(oWrap.OrdrLineItem.Id == RecOLItemId && oWrap.onlyOneItem == true) {
				IndexOfItemToSetQuantity = i;
			}
			i++;
		}
		
		OLIWrapper oWrapToUpdate = null;
		if (IndexOfItemToSetQuantity != null) {
			oWrapToUpdate = OLIWrapperList.get(IndexOfItemToSetQuantity);
			oWrapToUpdate.OrdrLineItem.Original_Quantity__c = 1;	 
			oWrapToUpdate.FreeQuantity = 0; 
			oWrapToUpdate.OrdrLineItem.Final_Price__c = oWrapToUpdate.OrdrLineItem.Original_Quantity__c * oWrapToUpdate.OrdrLineItem.Unit_Price__c ;
			
			// DE858 -- Bogo Penny causing issues again.
			if (oWrapToUpdate.onlyOneItem) {
				oWrapToUpdate.OrdrLineItem.Just_One_Item__c = true;
				oWrapToUpdate.OrdrLineItem.Offer_Code__c = WS_Integration__c.getValues('OfferCode') != null ? WS_Integration__c.getValues('OfferCode').value__c : '';
			}
			
			if (IndexOfItemToSetQuantity != null) {
				oWrapToUpdate = OLIWrapperList.get(IndexOfItemToSetQuantity);
				oWrapToUpdate.OrdrLineItem.Original_Quantity__c = 1;	 
				oWrapToUpdate.FreeQuantity = 0; 
				oWrapToUpdate.OrdrLineItem.Final_Price__c = oWrapToUpdate.OrdrLineItem.Original_Quantity__c * oWrapToUpdate.OrdrLineItem.Unit_Price__c ;
				
				// DE858 -- Bogo Penny causing issues again.
				if (oWrapToUpdate.onlyOneItem) {
						oWrapToUpdate.OrdrLineItem.Just_One_Item__c = true;
					try {
						oWrapToUpdate.OrdrLineItem.Offer_Code__c = WS_Integration__c.getValues('OfferCode').value__c;
					}
					catch (exception e){
						system.debug('Missing OfferCode custom setting, skipping');
					}
				} else {
					oWrapToUpdate.OrdrLineItem.Just_One_Item__c = false;
					oWrapToUpdate.OrdrLineItem.Offer_Code__c = null;
				}
				update oWrapToUpdate.OrdrLineItem;
			}
		}
	}
	
	public void ResetPriceOverride() {
		Id RecOLItemId = ApexPages.currentPage().getParameters().get('RecOLItemId');
		Integer IndexOfItemToOverride;
		Integer i = 0;
		
		for (OLIWrapper oWrap : OLIWrapperList) {
			if (oWrap.OrdrLineItem.Id == RecOLItemId) {
				IndexOfItemToOverride = i;
			}
			i++;
		}
		
		OLIWrapper oWrapToOverride = OLIWrapperList.get(IndexOfItemToOverride);
		
		if (!oWrapToOverride.priceOverrideItem) {
			oWrapToOverride.OrdrLineItem.Price_Override__c = 0;
			oWrapToOverride.OrdrLineItem.Override_Reason__c = null;
			updateTotalItems();
		}
	}
	
	public void updateTotalItems() {
		wrap.TotalLineItems = 0;
		List<Order_Line_Items__c> OLItems = new List<Order_Line_Items__c>();
		
		Id RecOLItemId = ApexPages.currentPage().getParameters().get('RecOLItemOneQuantity');
		
		/*
		for (OLIWrapper oWrap : OLIWrapperList) {
			
			if (oWrap.OrdrLineItem.Original_Quantity__c != null) {
				if (oWrap.priceOverrideItem && (oWrap.OrdrLineItem.Override_Reason__c == null || oWrap.OrdrLineItem.Override_Reason__c == '')) {
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select an override reason'));
					wrap.CreateOrderSelected = true;
					wrap.CheckoutSelected = false;
					break;
				}
				
				if (oWrap.priceOverrideItem && oWrap.OrdrLineItem.Price_Override__c != null && oWrap.OrdrLineItem.Price_Override__c > 0 && oWrap.OrdrLineItem.Price_Override__c < oWrap.OrdrLineItem.Unit_Price__c) {
					oWrap.OrdrLineItem.Final_Price__c = Integer.valueOf(oWrap.OrdrLineItem.Original_Quantity__c) * oWrap.OrdrLineItem.Price_Override__c;
				} else {
					oWrap.OrdrLineItem.Final_Price__c = Integer.valueOf(oWrap.OrdrLineItem.Original_Quantity__c) * oWrap.OrdrLineItem.Unit_Price__c;
				}
			}
		} 
		*/
		try {
			for (OLIWrapper oWrap : OLIWrapperList) {
				if(oWrap.OrdrLineItem.Id == RecOLItemId && oWrap.onlyOneItem == true && oWrap.OrdrLineItem.Original_Quantity__c > 1) {
					oWrap.onlyOneItem = false;
				}
			}
			
			bProductChange=true;
			applyPromotion(); 
			 
			for(OLIWrapper oWrap : OLIWrapperList){	 
				wrap.TotalLineItems += oWrap.OrdrLineItem.Product_Quantity__c != null ? Integer.valueOf(oWrap.OrdrLineItem.Product_Quantity__c) : 0;
				if(oWrap.priceOverrideItem && (oWrap.OrdrLineItem.Override_Reason__c == '' || oWrap.OrdrLineItem.Override_Reason__c == null) ){
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'All Price override require a reason. Please select an override reason.'));
				} else { OLItems.add(oWrap.OrdrLineItem); }
			}
			
			if(OLItems.size() > 0)
				update  OLItems;
			
			for (String str : MessagesList) {
				if (MsgFromException) {
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, str));
				} else {
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, str));
				}
			}
			
			MsgFromException = false;
			
		} catch(Exception ex) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
		}
	}
	public void DeleteToken(){
		string deltoken = ApexPages.CurrentPage().getParameters().get('deltokenid');
		//ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Cannot Delete..' + deltoken));
		boolean retValue = soa_WebservicesClientUtil.WS_DeletePaymentProfile(wrap.newOrder.id,deltoken);
		List<OrderWizard_Wrapper.PaymentProfile> lstPaymentTokenTemp =  new List<OrderWizard_Wrapper.PaymentProfile>();
		if(retValue)
		{
			for(OrderWizard_Wrapper.PaymentProfile temp :wrap.lstPaymentTokens)
			if(temp.TokenId == deltoken)
				system.debug('~~~-----Deleted Token' + deltoken);
			else
				lstPaymentTokenTemp.add(temp);
		}
		wrap.lstPaymentTokens = lstPaymentTokenTemp;
		// Refresh lstpayment list
		
	}
	
	public void UpdateToken( ){
		string updatetoken = ApexPages.CurrentPage().getParameters().get('deltokenid');
		//ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Cannot Delete..' + deltoken));
		boolean retValue = false;
		try {
			retValue = soa_WebservicesClientUtil.UpdatePaymentProfile(wrap.paymentInfo,updatetoken);
		} catch(exception e) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error updating information. Please contact System Administrator'));
			system.debug('error message' + e.getMessage());
			return;
		}
		List<OrderWizard_Wrapper.PaymentProfile> lstPaymentTokenTemp =  new List<OrderWizard_Wrapper.PaymentProfile>();
		if (retValue) {
			for (OrderWizard_Wrapper.PaymentProfile temp :wrap.lstPaymentTokens) {
				if (temp.TokenId == updatetoken) {
				// Update address
				string details = '<table>'; 
				details += '<tr><td>Name on Card:</td><td>' + temp.name + '</td></tr>';
				details += '<tr><td>Card Type:</td><td>' + temp.creditcardType + '</td></tr>';
				details += '<tr><td>Expiration Date:</td><td>' + temp.creditcardExpiry + '</td></tr>';
				details += '<tr><td>Last 4 Digits:</td><td>' + temp.TokenId.right(4) + '</td></tr>';
				temp.Addressline1 = wrap.paymentInfo.addressLine1==null?'':wrap.paymentInfo.addressLine1;
				temp.Addressline2 = wrap.paymentInfo.addressLine2==null?'':' '+wrap.paymentInfo.addressLine2;
				temp.city = wrap.paymentInfo.city==null?'':wrap.paymentInfo.city;
				temp.state = wrap.paymentInfo.city==null?'':wrap.paymentInfo.city;
				temp.zip = wrap.paymentInfo.zipCode==null?'':wrap.paymentInfo.zipCode;
				details += '<tr><td>Address:</td><td>' + temp.Addressline1 +	'</td></tr>';
				details += '<tr><td></td><td>' + temp.city + ' ' + temp.state + ' ' + temp.zip +	'</td></tr>';
				
				details += '</table>';
				string tempdetails = details.remove('#');
				
				temp.details = tempdetails;
				}
			lstPaymentTokenTemp.add(temp);
			}
		}
		wrap.lstPaymentTokens = lstPaymentTokenTemp;
		// Refresh lstpayment list
	}
	public void calculateTax() {
		if (AddressTriggerHelper.isUSAddress(wrap.shippingAddress.Country_Picklist__c)) {
			// Avalara Callout Enhancement
			wrap=AvalaraTaxCalc.CalculateTax(wrap,false);
			if (wrap.AvalaraCalloutFailed) {
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'Avalara Tax Service Callout was unsuccessful. Tax information may be incorrect.'));
				Error_Log__c el = new Error_Log__c();
				el.Error_Message__c = 'Avalara Tax Service Callout was unsuccessful. Tax information may be incorrect.';
				insert el;
			}
		//	wrap.queryOrderLines();
			system.debug('oliWrapperListSize~~~~'+OLIWrapperList.size());
			for (OLIWrapper oliWrapper: OLIWrapperList) {
				system.debug('oliWrapper~~~~'+oliWrapper);
				for (Order_Line_Items__c oli: wrap.selectedOrderLineItems) {
					system.debug('oli~~~~~'+oli);
					
					if (oli.Id==oliWrapper.OrdrLineItem.Id) {
						oliWrapper.OrdrLineItem.tax__c = oli.tax__c;
						system.debug('oliWrapper.OrdrLineItem~~~~'+oliWrapper.OrdrLineItem);
					}
				}
			}
		//  OLIWrapperList = wrap.selectedOrderLineItems.
		} else {
			wrap.Tax=0;
		}
		
		if(wrap.CheckoutSelected) {
			for(String str : MessagesList) {
				if(MsgFromException) {
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, str));
				} else {
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, str));
				}
			}
			MsgFromException = false;
		}
	}
	
	public void PullOrderCheck() {
		bShowPullReasonList = wrap.newOrder.Pull_Order__c;
		bNoPullOrderReason = false; 
		
		scrubBadCharacters();
		/*if(wrap.newOrder.Pull_Order__c == true || wrap.newOrder.Gift_Order__c == true || wrap.newOrder.No_Invoice__c == true || 
			wrap.newOrder.No_Peanuts__c == true || wrap.newOrder.No_Substitutes__c == true || wrap.newOrder.Rush_Order__c == true || wrap.newOrder.No_Catalogs__c == true )
		{
			wrap.newOrder.Pull_Order__c = true; 
		}*/
		/* DE886 -- moved next commented block to new function
		// INC699065 -- Newline caused sub-tab to be blank
		// Unknown why, as I can't understand, but a new line is making sub-tab blank; nothing in logs/online
		if (wrap.newOrder.Comments__c != null && wrap.newOrder.Comments__c.contains('\n')){
			wrap.newOrder.Comments__c = wrap.newOrder.Comments__c.replace('\n', ' ');
		}
		
		// DE672 / INC704282 -- Newline caused sub-tab to be blank and has issues with getting to the 400.
		if (wrap.newOrder.Pull_Order_Reason_Other__c != null && wrap.newOrder.Pull_Order_Reason_Other__c.contains('\n')){
			wrap.newOrder.Pull_Order_Reason_Other__c = wrap.newOrder.Pull_Order_Reason_Other__c.replace('\n', ' '); 
		} */
		
		// INC700636 - Cleaned up the if clauses; correctly flags error 
		if(wrap.newOrder.Pull_Order__c == true && String.isBlank(wrap.newOrder.Comments__c) && !wrap.newOrder.Gift_Order__c && 
		   !wrap.newOrder.Ship_Complete__c && String.isBlank(wrap.newOrder.Pull_Order_Reason_Multi__c))
		{
			bNoPullOrderReason = true;			
			PullOrderErrorMessage = 'Please select a Pull order reason or enter the reason in notes';
		}
		
		if (wrap.newOrder.Comments__c != null && wrap.newOrder.Comments__c != ''){
			bNoPullOrderReason = false;
			PullOrderErrorMessage = null;
		}
		
		// JMK-PullOrder Change; reaction to notes in note field.
		if (wrap.newOrder.Comments__c != null && wrap.newOrder.Comments__c != ''){
			bNoPullOrderReason = false;
			PullOrderErrorMessage = null;
		}
		 
		// JMK-PullOrder Change
		if (wrap.newOrder.Pull_Order_Reason_Multi__c != null){
			bNoPullOrderReason = false;
			List<String> strs = wrap.newOrder.Pull_Order_Reason_Multi__c.split(';');
			for (string s: strs){
				if (s == 'Other'){
					bPullReasonOther = wrap.newOrder.Pull_Order__c; // changed from true to this; if check is cleared will hide text box
					break;
				}else{
					bPullReasonOther = false;
				}				
			}
		} else {
			bPullReasonOther = false;
		}
		
		if (bPullReasonOther == true && (wrap.newOrder.Pull_Order_Reason_Other__c == null || wrap.newOrder.Pull_Order_Reason_Other__c == '')){
			PullOrderErrorMessage = 'Please provide a reason in the OTHER REASON NOTES or select other reasons';
			bNoPullOrderReason = true;
		}
		
		// DE853 / INC713268 -- pull order other reason needs to be cleared
		if (wrap.newOrder.Pull_Order__c == false){
			wrap.newOrder.Pull_Order_Reason_Multi__c = null;
			wrap.newOrder.Pull_Order_Reason_Other__c = null;
		}
		if (!bPullReasonOther){
			wrap.newOrder.Pull_Order_Reason_Other__c = null;
		}
	}
	
	public void editShippingBilling() {
		wrap.CreateOrderSelected = false;
		wrap.CheckoutSelected = false;
	}
	
	public void AddSelectedProduct() {
		if(!wrap.CreateOrderSelected && !wrap.CheckoutSelected)
		{
			CreateOrder();
		}
	//  searchedRecordId = ApexPages.currentPage().getParameters().get('SelProdId');
		bRecommendation = true;
		ProcessAddItem();
	}
	
	public void resetPaymentFields() {
		bRenderCCfields = (wrap.selectedpaymentType=='Credit Card');
		bRenderTokenFields = wrap.selectedpaymentType=='Existing Card';
		bRenderCashFields = (wrap.selectedpaymentType=='Cash'||wrap.selectedpaymentType=='Wire Transfer'||wrap.selectedpaymentType=='Gift Certificate'||wrap.selectedpaymentType=='Money Order'||wrap.selectedpaymentType==''||wrap.selectedpaymentType==null);
		bRenderCheckFields = (wrap.selectedPaymentType=='Check');
		wrap.bRenderExistingCC= wrap.selectedpaymentType=='Stored Cards';
		system.debug('wrap.selectedpaymentType'+wrap.selectedpaymentType);
		system.debug('wrap.bRenderExistingCC'+wrap.bRenderExistingCC);
		system.debug('wrap.lstPaymentTokens~~'+wrap.lstPaymentTokens);
	}
	
	public boolean getHasErrorMessages() {
		HasErrorMessages = ApexPages.hasMessages(ApexPages.Severity.ERROR); 
		return HasErrorMessages;
	}
	
	/*
	@Description: Auto complete and search funtionalty for Items object.
	*/

	/*Global variables*/
	global String searchedRecordId {get; set;}
	global static list<ResultSet> searchedRecord {get;set;}
	@RemoteAction
	global static ResultSet[] getRecords(String searchText, String OrderId) {
		//sObject List
		searchedRecord = new list<ResultSet>();
		String ProdSuffix;
		Orders__c orderObj = [select id, Customer__r.Associate_Customer__c, customer__r.recordType.developername from Orders__c where id =:orderId];
		Customer_Rec_Type_Brand_Mapping__c CRTBM = Customer_Rec_Type_Brand_Mapping__c.getInstance(orderObj.customer__r.recordType.developerName);
		system.debug(CRTBM);
		if (CRTBM != null) {
			ProdSuffix = CRTBM.Product_Suffix_c__c;
		}
		
		Set<Id> AlreadySelectedItemsId = new Set<Id>();
		
		for (Order_Line_Items__c OLI : [Select Product_Name__c , sku_number__c FROM Order_Line_Items__c WHERE Order__c = :OrderId ]) {
			AlreadySelectedItemsId.add(OLI.Product_Name__c);
		}	   
		//SOSL Text should be more then one character
		boolean bIntOnly = false;
		if (searchText.length() >0) {
			if (searchText.containsOnly('0123456789')) {
				searchText = '%'+searchText ;
				bIntOnly=true;
			} else {
				searchText = '\"' + searchText + '\"';
			}
			
			
			//SOSL operation to retrive records of the Items object
			List<List<SObject>> searchList;
			List <Item__c>		  itemResultList;
			if (ProdSuffix != null && ProdSuffix != '') {
				if (bIntOnly) {
					system.debug('searchText~~~'+searchText);
					itemResultList =[SELECT Id, Name, Product_Size_Amount__c, Available_Inventory__c, Description__c, Product_Image_URL__c, Product_Number__c, Sale_Price__c, Associate_Sale_Price__c, CurrencyIsoCode FROM Item__c WHERE Id NOT IN :AlreadySelectedItemsId AND Product_Suffix__c = :ProdSuffix AND Is_Active__c =true and inventory_status__c not in ('OutOfStock') and product_number__c like :searchText];
				} else {
					searchList = [FIND :searchText IN ALL FIELDS RETURNING Item__c(Id, Name, Product_Size_Amount__c, Available_Inventory__c, Description__c, Product_Image_URL__c, Product_Number__c, Sale_Price__c, Associate_Sale_Price__c, CurrencyIsoCode WHERE Id NOT IN :AlreadySelectedItemsId AND Product_Suffix__c = :ProdSuffix and inventory_status__c not in ('OutOfStock') AND Is_Active__c =true) LIMIT 10];					  
				}
			} else {
				if (bIntOnly) {
					itemResultList =[SELECT Id, Name, Product_Size_Amount__c, Available_Inventory__c, Description__c, Product_Image_URL__c, Product_Number__c, Sale_Price__c, Associate_Sale_Price__c, CurrencyIsoCode FROM Item__c WHERE Id NOT IN :AlreadySelectedItemsId AND Product_Suffix__c = :ProdSuffix AND Is_Active__c =true and inventory_status__c not in ('OutOfStock') and product_number__c like :searchText];
				} else {
					searchList = [FIND :searchText IN ALL FIELDS RETURNING Item__c(Id, Name, Product_Size_Amount__c, Available_Inventory__c, Description__c, Product_Image_URL__c, Product_Number__c, Sale_Price__c, Associate_Sale_Price__c, CurrencyIsoCode WHERE Id NOT IN :AlreadySelectedItemsId and inventory_status__c not in ('OutOfStock') AND Is_Active__c =true) LIMIT 10];		  
				}
			}
			
			if (bIntOnly) {
				for (Item__c i: itemResultList) {
						searchedRecord.add(new orderWizard_NewOrder.ResultSet(i, orderObj.Customer__r.Associate_Customer__c));
					}
			} else {
			
				//Adding diffrent object's records in sobject list
				for (List<SObject> o:searchList) {
					for (SObject s:o) {
						Item__c i = (Item__c)s;
						searchedRecord.add(new orderWizard_NewOrder.ResultSet(i, orderObj.Customer__r.Associate_Customer__c));
					}
				}
			}
		}
		return searchedRecord;
	}
	/*getGlobalDescribed*/
	private static list<Schema.SObjectType> gd{
		get {
			if (gd == null) {
				gd = Schema.getGlobalDescribe().values();
			}
			return gd ;
		} set;
	}
		
	/*Record Wrapper*/
	global class ResultSet {
		public String Id {get;set;} 
		public String Name{get;set;}
		public String Description {get;set;}
		public String sObjectName {get;set;}
		public Item__c OrderLineItem {get; set;}
		public String SalePrice {get; set;}
		
		public ResultSet(Item__c s, Boolean Associate) {
			this.Id = s.Id;
			this.Name = s.get('Name')+'';
			this.Description = s.get('Description__c')+'';
			this.OrderLineItem = (Item__c)s;
			this.sObjectName = getsObjectNameById(Id);  
			this.SalePrice = String.valueOf(Associate == true ? this.OrderLineItem.Associate_Sale_Price__c : this.OrderLineItem.Sale_Price__c);
		}
		
		/*To get object Name by Id*/
		private String getsObjectNameById(String sObjectId) {
			if (sObjectId != null && sObjectId.trim() != '') {
				for (Schema.SObjectType objectInstance : orderWizard_NewOrder.gd) {
					if (objectInstance.getDescribe().getKeyPrefix() == sObjectId.subString(0,3)) {
						return objectInstance.getDescribe().getLabel();
					}
				}
			}
			return null;
		}
	}
		
	global static list<PromoResultSet> PromoSearchResults {get;set;}
	
	@RemoteAction
	global static PromoResultSet[] getPromotionRecords(boolean bCoupon, String searchText, string orderId) {
		String ProdSuffix='11';
		Orders__c orderObj = [select id, customer__r.recordType.developerName from Orders__c where id =:orderId];
		Customer_Rec_Type_Brand_Mapping__c CRTBM = Customer_Rec_Type_Brand_Mapping__c.getInstance(orderObj.customer__r.recordType.developerName);
		if (CRTBM!=null) {
			if (CRTBM.Product_Suffix_c__c!=null) {
				ProdSuffix=string.valueOf(CRTBM.Product_Suffix_c__c);//no need to trim zeros any more
			}
		}
		//sObject List
		PromoSearchResults = new list<PromoResultSet>(); 
		
		//SOSL Text should be more then one character
		if (searchText.length() >0) {
			searchText = '%' + searchText + '%';
			//SOSL operation to retrive records of the Promotions object
			string searchType = bCoupon? 'Coupon': 'SourceCode';
			system.debug(searchType);
			system.debug(prodSuffix); 
			system.debug(searchText); 
			List<SObject> searchList = [SELECT Id, Name, Start_Date__c, End_Date__c, Offers__c, Active__c FROM Promotion__c WHERE Name LIKE :searchText AND suffix__c=:prodSuffix AND Promo_TYPE__c=:searchType AND Active__c=true LIMIT 5];
			//Adding diffrent object's records in sobject list
			
			for (SObject s:searchList) {
				PromoSearchResults.add(new orderWizard_NewOrder.PromoResultSet(s));
			}
			
		}
		return PromoSearchResults;
	}
	
	/*Record Wrapper*/
	global class PromoResultSet {
		public String Id {get;set;} 
		public String Name {get;set;}
		public String Description {get;set;}
		public boolean isActive {get;set;}
			
		public PromoResultSet(sObject s) {
			this.Id = s.Id;
			this.Name = s.get('Name')+'';
			if (s.get('Offers__c')!=null) this.Description = s.get('Offers__c')+'';
			else this.Description = '';
			
			if (s.get('Active__c') == true) {
				this.isActive =true;
			} else {
				this.isActive=false;
			}
		}
		
		/*To get object Name by Id*/
		private String getsObjectNameById(String sObjectId) {
			if (sObjectId != null && sObjectId.trim() != '') {
				for (Schema.SObjectType objectInstance : orderWizard_NewOrder.gd) {
					if (objectInstance.getDescribe().getKeyPrefix() == sObjectId.subString(0,3)) {
						return objectInstance.getDescribe().getLabel();
					}
				}
			}
			return null;
		}
	}
	
	/*
	Wrapper class for Order Line Item
	*/
	public class OLIWrapper {
		public String ProductName {get; set;}
		public String ProductImageURL {get; set;}
		public Integer ProductAvaliability {get; set;}
		public Order_Line_Items__c OrdrLineItem {get; set;}
		public List<OLIFeaturesWrapper> Features {get; set;}
		public boolean onlyOneItem {get; set;}
		public String ProductSaleOffer {get; set;}
		public Integer FreeQuantity {get; set;}
		public boolean priceOverrideItem {get; set;}
		public String ProductNumber {get; set;}
		
		public OLIWrapper(Orders__c newOrder, Item__c Product) {
			this.OrdrLineItem = new Order_Line_Items__c();
			this.ProductName = Product.Name;
			this.ProductImageURL = Product.Product_Image_URL__c;
			this.ProductAvaliability = Product.Available_Inventory__c != null ? Integer.valueOf(Product.Available_Inventory__c) : 0;
			this.ProductSaleOffer = Product.Sale_Offer__c; 
			this.OrdrLineItem.Product_Name__c = Product.Id;
			this.OrdrLineItem.Order__c = newOrder.Id;
			this.Features = new List<OLIFeaturesWrapper>();
			OLIFeaturesWrapper FeaturesRec = new OLIFeaturesWrapper();
			this.Features.add(FeaturesRec);
			this.onlyOneItem = false;
			this.FreeQuantity = 0;
			this.priceOverrideItem = false;
			this.ProductNumber = Product.Product_Number__c;
		}
		
		public OLIWrapper(Order_Line_Items__c oli) {
			this.OrdrLineItem=oli;
			this.ProductName = oli.product_name__r.name;
			this.ProductImageURL = oli.product_name__r.Product_Image_URL__c;
			this.ProductAvaliability = oli.product_name__r.Available_Inventory__c != null ? Integer.valueOf(oli.product_name__r.Available_Inventory__c) : 0;
			this.ProductSaleOffer = oli.product_name__r.Sale_Offer__c; 
			this.Features = new List<OLIFeaturesWrapper>();
			OLIFeaturesWrapper FeaturesRec = new OLIFeaturesWrapper();
			this.Features.add(FeaturesRec);
			this.onlyOneItem = false;
			this.FreeQuantity = 0;
			this.priceOverrideItem = false;
			this.ProductNumber = oli.product_name__r.Product_Number__c;
		}
	}
	
	public class OLIFeaturesWrapper {
		public boolean removeItem {get; set;}
		
		public OLIFeaturesWrapper() {
				this.removeItem = false;
		}
	}
	
	public List<SelectOption> getPullOrderReasons() {
		List<SelectOption> items = new List<SelectOption>();
		Schema.DescribeFieldResult fieldResult = Orders__c.Pull_Order_Reason__c.getDescribe();
		
		List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
		
		for (Schema.PicklistEntry i : ple) {
			items.add(new SelectOption(i.getLabel(), i.getValue()));
		}
		
		return items;
	}
	
	public String NotifyCHecked() {
		String style = '';
		
		if (wrap.newOrder.No_Substitutes__c || wrap.newOrder.Gift_Order__c || wrap.newOrder.Future_Order__c) {
			style = 'Color: RED;';
		}
		return style;
	}
	
	// DE886 -- refactored the bad character scrubbing
	private void scrubBadCharacters(){
		// INC699065 -- Newline caused sub-tab to be blank
		if (wrap.newOrder.Comments__c != null){
			wrap.newOrder.Comments__c = wrap.newOrder.Comments__c.replace('\n', ' ');
			// DE886 -- scrub double-quote
			wrap.newOrder.Comments__c = wrap.newOrder.Comments__c.replace('"', '');
		}
		
		if (wrap.newOrder.Pull_Order_Reason_Other__c != null) {
			// DE672 / INC704282 -- Newline caused sub-tab to be blank and has issues with getting to the 400.
			wrap.newOrder.Pull_Order_Reason_Other__c = wrap.newOrder.Pull_Order_Reason_Other__c.replace('\n', ' ');
			// DE886 -- scrub double-quote
			wrap.newOrder.Pull_Order_Reason_Other__c = wrap.newOrder.Pull_Order_Reason_Other__c.replace('"', '');
		}
	}
}