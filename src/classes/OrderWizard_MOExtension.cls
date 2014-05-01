global  class OrderWizard_MOExtension {

	public List<Payment_Detail__c> checkList {get;set;}	
	public Boolean showChecks {get;set;}
	public String aTmp {get;set;}
	public string OrderSubTotal{get;set;}
	public string ShippingTotal{get;set;} 
	public OrderWizard_NewOrder orderWizard {get;set;}
	public Case newCase {get;set;}
	public Credit__c newCredit  {get;set;}
	public boolean showCashPayment {get;set;}
	public decimal ordTotal {get;set;}
	public decimal ordDelta {get;set;}
	public string 		ordDeltaCss {get;set;}
	public List <OLIWrapper_Mail> oliWrapperList_Mail {get;set;}
	public List <OLIWrapper_Mail> oliWrapperList_Final {get;set;}
	public integer iRowSize {get;set;}
	public boolean bValidated {get;set;}
	public boolean bTaxCalcd {get;set;}
	public boolean bOrderSubmitted {get;set;}
	public boolean bHasItems {get;set;}
	// DE833 -- To hide the edit addresses button; just to mimic on error behavior of other wizard.
	public boolean bHasError {get;set;}
	private final decimal UNDERPAYMENT_THRESHOLD =5; 

	public OrderWizard_MOExtension(ApexPages.StandardController stdController){
		bValidated = false;
		bTaxCalcd = false;
		bHasItems = false;
		ordDelta = 0;
		iRowSize=25;
		orderWizard = new OrderWizard_NewOrder(stdController);
		if (orderWizard.wrap.newOrder.Payment_Type__c==null) orderWizard.wrap.selectedpaymentType='Check';
		orderWizard.resetPaymentFields();
		orderWizard.wrap.newOrder.Sales_Channel__c='Mail';
		Orders__c tempOrder = [select batch_sequence_number__c, batch_number__c from Orders__c where id =:orderWizard.wrap.newOrder.id];
		orderWizard.wrap.newOrder.batch_sequence_number__c=tempOrder.batch_sequence_number__c;
		orderWizard.wrap.newOrder.batch_number__c=tempOrder.batch_number__c;
		queryPayments();
		if (checkList.isEmpty()) addChecks(); 
		oliWrapperList_Mail = new List <OLIWrapper_Mail>();
	  	if(  !orderWizard.OLIWrapperList.isEmpty()){
	  		bHasItems=true;
			for (OrderWizard_NewOrder.OLIWrapper oliw: orderWizard.OLIWrapperList){
				oliWrapperList_Mail.add(new oliWrapper_Mail(oliw));
			}
		}
		moreRows();
	}
	
	public void queryPayments(){
		checkList = new List<Payment_Detail__c>();
		for (Payment_Detail__c pd: [select id, amount__c, reference_number__c from Payment_Detail__c where order__c=:orderWizard.wrap.newOrder.id]){
			checkList.add(pd);
		}
	}
	
	public void createOrder(){
		if (bHasItems){
			validateMailOrder();
		}
		
		orderWizard.wrap.CreateOrderSelected = true;
		orderWizard.wrap.CheckoutSelected=false;
		boolean isInValidAddress = false;
		if(orderWizard.wrap.billingAddress.id == null){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select Billing Address.'));
			isInValidAddress = true;
		}
		if(orderWizard.wrap.shippingAddress.id == null){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select Shipping Address.'));
			isInValidAddress = true;
		}
		if(isInValidAddress){
			orderWizard.wrap.CreateOrderSelected = false;	
			orderWizard.wrap.CheckoutSelected = false;
			return;
		}
		orderWizard.wrap.newOrder.Bill_To_Address__c = orderWizard.wrap.billingAddress.id;
		orderWizard.wrap.newOrder.Ship_To_Address__c = orderWizard.wrap.shippingAddress.id;
		
	}

	
	public void savePayments(){
		for (Payment_Detail__c pd: checkList){
				if (pd.amount__c==null){
					pd.amount__c.addError('Amount Cannot be Blank');
					return;
				}
				pd.Sequence__c=orderWizard.wrap.newOrder.Batch_Number__c;
				pd.batch__c = orderWizard.wrap.newOrder.Batch_Sequence_Number__c;
			}
		upsert checkList;
	}
	
	
	public void saveOrder(){
		try{
			orderWizard.wrap.newOrder.payment_type__c = orderWizard.wrap.selectedpaymentType;
			
			upsert orderWizard.wrap.newOrder;
			List <Order_Line_Items__c> oliList = new List <Order_Line_Items__c>();
			for (OLIWrapper_Mail w: oliWrapperList_Mail){
				if (w.oliWrap.ordrLineItem.product_name__c!=null){
					oliList.add(w.oliWrap.OrdrLineItem);
				}
			}
			upsert oliList;
			savePayments();
			
		}
		catch(exception e){
			// ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select an override reason'));
		}
	}
	
	public void init(){
		ApplyPromotion_Mail();
	}
	
	public void createCase(){
		RecordType RecType = [Select Id From RecordType  Where SobjectType = 'Case' and DeveloperName = 'Follow_Up'];
		Case c = new Case( Related_Order__c =orderWizard.wrap.newORder.id, AccountId = orderWizard.wrap.newOrder.Customer__c, Origin = 'Mail Order', Case_Reason__c = 'Mail Order Exceptions', RecordType = RecType);
		try{
			insert c;
		   newCase = [select id, casenumber from Case where id =:c.id];
		}catch(Exception ex){
		
		}
	}
	
	public void createCredit(){
		Credit__c cred = new Credit__c(Account__c=orderWizard.wrap.newOrder.Customer__c, Reimbursement_Method__c='Customer Credit');
		if (ordDelta<0) {
			cred.Credit_Notes__c='Overpayment for Order '+orderWizard.wrap.newOrder.name;
			cred.Credit_Amount__c=-ordDelta;
		} 
		else {
			cred.Credit_Notes__c='Underpayment for Order '+orderWizard.wrap.newOrder.name;
			cred.Credit_Amount__c=ordDelta;
		}
		insert cred;
		newCredit = [select id, name from Credit__c where id =:cred.id];
	}
  
	public void ResetPriceOverride(){
		/*String RecOLItemId = ApexPages.currentPage().getParameters().get('indexKey');
		Integer IndexOfItemToOverride;
		Integer i = 0;
		
		for(OLIWrapper oWrap : OLIWrapperList){						  
			if(oWrap.indexKey == RecOLItemId){
				IndexOfItemToOverride = i;															  
			}
			i++;
		}
		
		OLIWrapper oWrapToOverride = OLIWrapperList.get(IndexOfItemToOverride);
			
		if(!oWrapToOverride.priceOverrideItem){
			oWrapToOverride.OrdrLineItem.Price_Override__c = 0;
			oWrapToOverride.OrdrLineItem.Override_Reason__c = null;
			updateTotalItems();
		}*/
	}
	
	public void chgPaymentType(){
		if(showCashPayment){ showCashPayment = false; }
		else{ showCashPayment = true;}
	} 
	
	public PageReference customerCredit(){ return null; }
	
	
	public void moreRows(){
		for(Integer i = 0; i < iRowSize; i++){ 
			oliWrapperList_Mail.add(new oliWrapper_Mail(new OrderWizard_NewOrder.OLIWrapper( new Order_Line_Items__c(order__c =orderWizard.wrap.newOrder.id))));
		}
	}
	

	public void addChecks(){
		checkList.add(new Payment_Detail__c(Order__c =orderWizard.wrap.newOrder.id, account__c=orderWizard.wrap.newOrder.customer__c ));
		//return null;
	}
	
	
	public void removeItem(){
		validateMailOrder();
		String RecOLItemId = ApexPages.currentPage().getParameters().get('indexKey');
		system.debug('~~~~ Index Key to be deleted~~' + RecOLItemId );
		Integer IndexOfItemToRemove;
		Integer i = 0;
		
		for(OLIWrapper_Mail oWrap : OLIWrapperList_Mail){						   
			system.debug('owrap.indexKey~~~'+owrap.indexKey);
			system.debug('RecOLItemId~~~'+RecOLItemId);
			if(oWrap.indexKey == RecOLItemId)
			{
				IndexOfItemToRemove = i;																
			}
			i++;
		}
		
		if(IndexOfItemToRemove != null){
			OLIWrapper_Mail owmTemp = OLIWrapperList_Mail[IndexOfItemToRemove];
			if (owmTemp.oliWrap.ordrlineItem.id!=null){
				// DE832 -- display not updating on the fly; could not accpet it updates with validation
				if(owmTemp.oliWrap.OrdrLineItem.Product_Quantity__c != null && orderWizard.wrap.TotalLineItems != null){
					system.debug('-------------------------------------------------------totalLineItems: ' + orderWizard.wrap.TotalLineItems);
					system.debug('-------------------------------------------------------product quantity: ' + owmTemp.oliWrap.OrdrLineItem.Product_Quantity__c);
					orderWizard.wrap.TotalLineItems -= Integer.valueOf(owmTemp.oliWrap.OrdrLineItem.Product_Quantity__c);
				}else{
					orderWizard.wrap.TotalLineItems = 0;
				}
				delete owmTemp.oliWrap.ordrlineItem;
			}
			OLIWrapperList_Mail.remove(IndexOfItemToRemove);
			try{
				
			}catch(Exception e){
					system.debug(String.valueOf('OrderWizard_NewOrder.removeItem() exception: '+e.getMessage()));
			}
		}
		System.debug('------------------------------: oliwrapperlist_mail: ' + OLIWrapperList_Mail.size());
		orderWizard.wrap.selectedOrderLineItems.clear();
		for(OLIWrapper_Mail oli : OLIWrapperList_Mail){
			orderWizard.wrap.selectedOrderLineItems.add(oli.oliWrap.ordrLineItem);
		}
		bValidated=false;
		bTaxCalcd = false;
		validateMailOrder();
	}

	public void ApplyPromotion_Mail(){
		try{
			orderWizard.queryCouponPromo();
			if (orderWizard.wrap.selectedCatalog=='Current'){
				orderWizard.wrap.newOrder.catalog_source_code__c=null;
			}
			else {
				orderWizard.wrap.newOrder.catalog_source_code__c=orderWizard.wrap.selectedCatalog;
			}
			//RB Changes
			orderWizard.bProductChange = true;
			
			if (orderWizard.bProductChange){
				system.debug('** Inside Promotion** ');
				orderWizard.wrap.PreTaxTotal=0;
				orderWizard.wrap.SubTotal=0;
				orderWizard.wrap.Discount=0;
				orderWizard.wrap.ShippingDiscount=0;
				orderWizard.wrap.ShippingCharges = 0;
				orderWizard.wrap.Total = 0;
				
				if(!orderWizard.MsgFromException){
					orderWizard.MessagesList.clear();
				}
				
				if (!OLIWrapperList_Mail.isEmpty()){
					system.debug('** Inside Promotion wrapper** ');
					Map <Integer, Order_Line_Items__c> oliSkuMap = new Map<Integer,Order_Line_Items__c>();
					Map <Integer, Order_Line_Items__c> PromotionalItems = new Map <Integer, Order_Line_Items__c>();
					Map <Integer, oliWrapper_Mail> oliSkuWrapMap = new Map<Integer,oliWrapper_Mail>();
		
					for (oliWrapper_Mail oliWrap: OLIWrapperList_Mail){
						Order_Line_Items__c oli = oliWrap.oliWrap.OrdrLineItem;
						if(string.isnotblank(oli.SKU_Number__c)){
						system.debug('** - SKU NUMBER' + oli.SKU_Number__c);
						oliSkuMap.put(integer.valueOf(oli.SKU_Number__c),oli);  
						oliSkuWrapMap.put(integer.valueOf(oli.SKU_Number__c),oliwrap);
						orderWizard.oliWrapperList.add(oliWrap.oliWrap);
						}
					}
					
					orderWizard.wrap.promoResponse = NBTYWSUtil.ProcessPromotions(orderWizard.wrap); 
					
					system.debug('orderWizard.wrap.promoResponse..........:'+ orderWizard.wrap.promoResponse);
					
					if(!orderWizard.wrap.promoResponse.IsSuccessful && orderWizard.wrap.promoResponse.StatusMessage != null){
						orderWizard.MessagesList.add(orderWizard.wrap.promoResponse.StatusMessage); 
					}
					
					if(orderWizard.wrap.promoResponse.StatusMessage != null && orderWizard.wrap.promoResponse.StatusMessage.contains('Removed')){
						Set<Integer> ProductsSet = new Set<Integer>();
						ProductsSet.addAll( oliSkuMap.keySet());
						orderWizard.MsgFromException = true;
						orderWizard.MessagesList.add(orderWizard.wrap.promoResponse.StatusMessage + '. In order to re-add this item, please set the shipping method to UPS and return to the cart page.');  
						if(orderWizard.wrap.promoResponse.data !=null && orderWizard.wrap.promoResponse.data.items != null &&  !orderWizard.wrap.promoResponse.data.items.isEmpty()){
							for (WS_webstack_PromotionObjects_v2.ResponseItem item: orderWizard.wrap.promoResponse.data.items){
								ProductsSet.remove(Integer.valueOf(item.ItemNumber));
							}
						}
						
						if(!ProductsSet.isEmpty()){
							/*for(Integer i : ProductsSet){
								ApexPages.currentPage().getParameters().put('RecOLItemId', oliSkuMap.get(i).Id);						
								orderWizard.removeItem();
							}*/
							
							system.debug('***Total in Wrapper' + oliWrapperList_Mail.size());
							for(Integer i : ProductsSet){
								for(OLIWrapper_Mail owp :oliWrapperList_Mail){
									
									if(integer.valueof(owp.oliWrap.OrdrLineItem.SKU_Number__c) == i){
										owp.rowCss = 'error';
										owp.errorMessage = 'Promotion Service - Invalid Item';
									}
								}
							}
						}
					}
					
					if(orderWizard.wrap.promoResponse.data !=null && orderWizard.wrap.promoResponse.data.items != null &&  !orderWizard.wrap.promoResponse.data.items.isEmpty()){
						for (WS_webstack_PromotionObjects_v2.ResponseItem item: orderWizard.wrap.promoResponse.data.items){
							
							Order_Line_Items__c oli = oliSkuMap.get(integer.valueOf(item.itemNumber));
							system.debug('**** - Inside oli update ' +  oliSkuMap.get(integer.valueOf(item.itemNumber))) ;						  
							if(oli == null){
								oli = new Order_Line_Items__c();
								oli.Order__c = orderWizard.wrap.newOrder.Id;
								PromotionalItems.put(integer.valueOf(item.itemNumber), oli);															
							}
							oli.Original_Quantity__c = item.Quantity != null ? item.Quantity : 0 ;
							oli.Product_Quantity__c = item.Quantity != null ? item.Quantity : 0 ;
							try {
								oli.static_unit_price__c = oli.Original_Quantity__c ==0||item.SubTotal==0 ? null : item.SubTotal/ oli.Original_Quantity__c ;
							}
							catch (exception e){system.debug('cannot calc static unit price');}
							
							if(oliSkuWrapMap.containsKey(Integer.valueOf(item.itemNumber)) && !oliSkuWrapMap.get(Integer.valueOf(item.itemNumber)).oliWrap.onlyOneItem){
								oli.Product_Quantity__c += item.FreeQuantity !=null ? item.FreeQuantity : 0 ;   
							}
							
							if(item.SubTotal != null){
								oli.Final_Price__c = item.SubTotal.setScale(2);
								orderWizard.wrap.SubTotal += oli.Final_Price__c;
							}
							
							if(item.discount != null){
								oli.Discount__c = item.discount.setScale(2, System.RoundingMode.DOWN);
								oli.Final_Price__c = item.SubTotal.setScale(2)- oli.Discount__c;
								orderWizard.wrap.Discount+=item.discount.setScale(2, System.RoundingMode.DOWN);
							}
						}
						
						if(orderWizard.wrap.promoResponse.data !=null && orderWizard.wrap.promoResponse.data.Allowances != null &&  !orderWizard.wrap.promoResponse.data.Allowances.isEmpty()){
							for (WS_webstack_PromotionObjects_v2.Allowance allowance : orderWizard.wrap.promoResponse.data.allowances){
								if(allowance.AllowanceCode == 69){
									orderWizard.wrap.ShippingDiscount += allowance.Amount.setScale(2, System.RoundingMode.DOWN);
								}
								else{
									orderWizard.wrap.discount += allowance.Amount.setScale(2, System.RoundingMode.DOWN);
								}
							}
						}
						
						orderWizard.wrap.Discount = orderWizard.wrap.Discount != null ? orderWizard.wrap.Discount.setScale(2) : 0;
						orderWizard.wrap.ShippingDiscount = orderWizard.wrap.ShippingDiscount != null ? orderWizard.wrap.ShippingDiscount.setScale(2) : 0;
						system.debug(LoggingLevel.info, 'Discount~~~'+orderWizard.wrap.Discount );
						
						if(orderWizard.wrap.promoResponse.data !=null){
							orderWizard.wrap.ShippingCharges	= orderWizard.wrap.promoResponse.data.shipping != null ? orderWizard.wrap.promoResponse.data.shipping.setScale(2) : 0;
							orderWizard.wrap.newOrder.Shipping_Method__c  = orderWizard.wrap.promoResponse.data.ShippingMethod;					 
							orderWizard.wrap.SubTotal		   = orderWizard.wrap.promoResponse.data.subTotal != null ? orderWizard.wrap.promoResponse.data.subTotal.setScale(2) : 0;
							orderWizard.wrap.PreTaxTotal		= (orderWizard.wrap.SubTotal + orderWizard.wrap.ShippingCharges - orderWizard.wrap.Discount - orderWizard.wrap.ShippingDiscount).setScale(2);
							orderWizard.wrap.newOrder.Source_Code__c = orderWizard.wrap.promoResponse.data.SourceCode;
							
						}
						system.debug('~~~ Total line Items:' + orderWizard.wrap.selectedOrderLineItems.size());		 
						system.debug('~~~~orderWizard.wrap~~~' + orderWizard.wrap.neworder);
						upsert orderWizard.wrap.selectedOrderLineItems;
						system.debug('*** shipping ' + orderWizard.wrap.ShippingCharges);
						orderWizard.wrap.neworder.Shipping_Total__c = orderWizard.wrap.ShippingCharges;
						orderWizard.wrap.neworder.Order_Sub_Total__c = orderWizard.wrap.SubTotal;
						orderWizard.wrap.neworder.Order_Total__c = orderWizard.wrap.PreTaxTotal;
						update orderWizard.wrap.newOrder;
					}
					
					if(!PromotionalItems.isEmpty()){
						Set<String> ProductNumberSet = new Set<String>();
						
						for(Integer ItemNumber : PromotionalItems.keySet()){
							String ProdNumAsString = String.valueOf(ItemNumber);
							ProdNumAsString = ProdNumAsString.leftPad(6);
							ProdNumAsString = ProdNumAsString.replace(' ','0');
							ProductNumberSet.add(ProdNumAsString);
						}
						
						for(Item__c prod : [SELECT Id, Name, Product_Number__c FROM Item__c WHERE Product_Number__c IN :ProductNumberSet]){
							Order_Line_Items__c oli = PromotionalItems.get(Integer.valueOf(prod.Product_Number__c));
							
							if(oli != null)
							{
								oli.Product_Name__c = prod.Id;
							}
							
						}
						
						insert PromotionalItems.values();
						
						for(Order_Line_Items__c oli: [SELECT Id, Comments__c, Substituted_Item__c, Product_Name__r.Product_Number__c, Product_Name__c,Product_Name__r.Product_Image_URL__c ,Product_Name__r.Available_Inventory__c,Product_Name__r.Sale_Offer__c , Product_Name__r.Name, Product_Quantity__c, Original_Quantity__c, Product_Number__c, Price_Override__c, Override_Reason__c, Unit_Price__c, Final_Price__c, Tax__c  FROM Order_Line_Items__c WHERE Id IN :PromotionalItems.values()]){
							orderWizard.OLIWrapperList.add(new OrderWizard_NewOrder.OLIWrapper(oli));
						}
						
					}
					
					List<Allowance__c> AllowanceList = [SELECT Id FROM Allowance__c WHERE Order__c = :orderWizard.wrap.newOrder.Id];
					
					delete AllowanceList;
					AllowanceList.clear();
					
					if(orderWizard.wrap.promoResponse.data !=null && orderWizard.wrap.promoResponse.data.Allowances != null &&  !orderWizard.wrap.promoResponse.data.Allowances.isEmpty()){
						if(AllowanceList == null)			  {
							AllowanceList = new List<Allowance__c>();
						}
						
						for(WS_webstack_PromotionObjects_v2.Allowance allowRec : orderWizard.wrap.promoResponse.data.Allowances){
							Allowance__c NewAllowanceRec = new Allowance__c();
							NewAllowanceRec.Order__c = orderWizard.wrap.newOrder.Id;
							NewAllowanceRec.Allowance_Code__c = string.valueOf(allowRec.AllowanceCode);
							NewAllowanceRec.Allowance_Amount__c = allowRec.Amount;
							AllowanceList.add(NewAllowanceRec);
						}
						
						if(AllowanceList != null && AllowanceList.size() > 0){
							insert AllowanceList;
						}
					}
				}
				orderWizard.bProductChange = false;
				orderWizard.wrap.TotalLineItems=0;
				for(OLIWrapper_Mail oWrap : OLIWrapperList_Mail){
					orderWizard.wrap.TotalLineItems += oWrap.oliWrap.OrdrLineItem.Product_Quantity__c != null ? Integer.valueOf(oWrap.oliWrap.OrdrLineItem.Product_Quantity__c) : 0;			
				}
			}
		}
		catch(Exception ex){
			//ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
		}
	}
	
	
	
	
	public void calculateTax(){
		orderWizard.calcTaxOnShipMethodChange();
		if (orderWizard.wrap.selectedpaymentType!='Credit Card') 	runPaymentTotal();
		else ordTotal = orderWizard.wrap.newOrder.Order_Total__c;
		calcDelta();
		orderWizard.wrap.newOrder.Tax__c=orderWizard.wrap.newOrder.Tax__c.setScale(2);
		ordTotal=ordTotal.setScale(2);
		orderWizard.wrap.Tax=orderWizard.wrap.Tax.setScale(2);
		bTaxCalcd=true;
	}
	
	public void calcDelta(){
		applyCredit();
		ordDelta = orderWizard.wrap.newOrder.Order_Total__c+orderWizard.wrap.TotalCreditApplied -ordTotal;
		if (ordDelta > 0) ordDeltaCss = 'red';
		else if (ordDelta <0 ) ordDeltaCss = 'green';
		else ordDeltaCss ='black';
	}
	
	public void applyCredit(){
		decimal tempDelta =  orderWizard.wrap.newOrder.Order_Total__c-ordTotal;//If they owe, this is positive
		if (orderWizard.wrap.CreditApplied) {//credit applied cb on the page visible after calc tax
			if(orderWizard.CustomerCredits != 0.00 && tempDelta>0){ //customer has credits & they are light on this order
				orderWizard.wrap.CustomerCreditAvailable = orderWizard.CustomerCredits; //set the credit available to what customer has
				if (orderWizard.CustomerCredits > tempDelta){  // if the credit avail is greater than the difference
					orderWizard.wrap.CustomerCreditAvailable = orderWizard.wrap.CustomerCreditAvailable - tempDelta; //deduct the credit needed
					orderWizard.wrap.TotalCreditApplied = -tempDelta; //need to debit
				}else{
					orderWizard.wrap.TotalCreditApplied = -orderWizard.wrap.CustomerCreditAvailable; //just take all of it
					orderWizard.wrap.CustomerCreditAvailable = 0.00;
				}
			}
		}else{
			if(orderWizard.wrap.TotalCreditApplied != 0.00){
				orderWizard.wrap.Total =  orderWizard.wrap.newOrder.Order_Total__c;
				orderWizard.wrap.TotalCreditApplied = 0.00;
				orderWizard.wrap.CustomerCreditAvailable = orderWizard.CustomerCredits;
			}
		}
	}
	
	public void authorizePayment(){
		boolean bError = false;
		orderWizard.authorizePayment();
		for (ApexPages.Message msg: ApexPages.getMessages()){
			system.debug('msg~~~~'+msg);
			if (msg.getSummary()!=null){
				if (!msg.getSummary().contains('success')) bError=true;
			}
		}
		if (!bError){
			submitOrder();
		}
	}
	
	public void submitOrder(){
		if (!orderWizard.bNoPullOrderReason){
			List <Order_Line_Items__c> oliList = new List <Order_Line_Items__c>();
			orderWizard.wrap.newOrder.Payment_Value__c=0;
			for (Payment_Detail__c chk: checkList){
				
				if (chk.Amount__c!=null){
					orderWizard.wrap.newOrder.Payment_Value__c+=chk.Amount__c;
					orderWizard.wrap.newOrder.Check_Number__c=chk.reference_number__c;
				}
				
			}
			// DE825 -- Added checks against Credit, Replace, Replacement to allow 0.00 orders to go through for those
			// three types.
			if (orderWizard.wrap.selectedpaymentType!='Credit Card'&&orderWizard.wrap.selectedpaymentType!='Existing Card'){
				/*if ((orderWizard.wrap.newOrder.Batch_Number__c.equalsIgnoreCase('CREDIT') ||
					orderWizard.wrap.newOrder.Batch_Number__c.equalsIgnoreCase('REPLACE') ||
					orderWizard.wrap.newOrder.Batch_Number__c.equalsIgnoreCase('REPLACEMENT')) &&
					orderWizard.wrap.newOrder.Payment_Value__c == 0){
					// do nothing; just move on.	
				} else {*/
					if((orderWizard.wrap.newOrder.Payment_Value__c == null || orderWizard.wrap.newOrder.Payment_Value__c == 0) && orderWizard.wrap.selectedpaymentType != 'Cash'){
						ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Payment Amount is required'));
					}
					if ((orderWizard.wrap.newOrder.Check_Number__c == null || orderWizard.wrap.newOrder.Check_Number__c == '') && orderWizard.wrap.selectedpaymentType != 'Cash'){
						ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Payment Ref/Number is required'));
					}
					if (orderWizard.wrap.newOrder.Batch_Number__c == null || orderWizard.wrap.newOrder.Batch_Number__c == ''){
						ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Batch Number is required'));
					}
					if (orderWizard.wrap.newOrder.Batch_Sequence_Number__c == null || orderWizard.wrap.newOrder.Batch_Sequence_Number__c == ''){
						ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Batch Sequence Number is required'));
					}else if (!orderWizard.wrap.newOrder.Batch_Sequence_Number__c.isNumeric()){
						ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Batch Sequence Number must be numeric'));
					}else if (integer.valueOf(orderWizard.wrap.newOrder.Batch_Sequence_Number__c) > 50){
						ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Batch Sequence Number must be less than 50'));
					}
				//}
			}
			
			if (apexpages.getMessages().isEmpty()){
				ApexPages.getMessages().clear();
				orderWizard.submitOrder();				
			}
			if (apexpages.getMessages().isEmpty()){
				createOrderAdjustmentUponSubmission();
				orderWizard.bOrderSubmitted=true; 
				bOrderSubmitted=true;
				orderWizard.wrap.CreateOrderSelected=false;
				orderWizard.wrap.CheckoutSelected=true;
				oliWrapperList_Final=new List <OLIWrapper_Mail>();
				for (OLIWrapper_Mail oliwM: oliWrapperList_Mail){
					if (oliwM.oliWrap.OrdrLineItem.product_Name__c!=null){
						oliWrapperList_Final.add(oliwM);
						oliList.add(oliwM.oliWrap.OrdrLineItem);
					}
				}
				update oliList;
				Orders__c tempOrder = [select order_status__c from Orders__c where id =:orderWizard.wrap.newOrder.id];
				orderWizard.wrap.newOrder.order_status__c=tempOrder.Order_Status__c;
			}
		}
	}
	public void createOrderAdjustmentUponSubmission(){
		//User story 64838316
		if (ordDelta > 0){
			if (ordDelta >  UNDERPAYMENT_THRESHOLD){
				orderWizard.wrap.newOrder.Order_Status__c='Waiting on Full Payment';
				orderWizard.wrap.newOrder.Comments__c=null;
				// and assign it to a new order queue.
			}
			else {
				orderWizard.wrap.newOrder.Comments__c='Please remit payment of $'+ordDelta+' for underpayment';
			}
			update orderWizard.wrap.newOrder;
			//Create Order Adjustment Record
			Order_Adjustment__c oa;
			try { //check to see if this is an edit scenario, ie already has  an order adjustment created
				oa=[select id, Refund_or_Misc_Amount__c, Status__c, Credit_Card_Type__c, Payment_Method__c from Order_Adjustment__c where related_order__c =:orderWizard.wrap.newOrder.id limit 1];
			}
			catch (exception e){ //If not created yet
				RecordType rt = [select id from RecordType where sObjectType='Order_Adjustment__c' and developerName ='Misc_Charge' LIMIT 1];
				oa = new Order_Adjustment__c();
				oa.RecordTypeId=rt.id;
				oa.Customer__c=orderWizard.Customer.id;
				oa.Related_Order__c=orderWizard.wrap.newOrder.id;
			}
			oa.Payment_Method__c=orderWizard.wrap.selectedpaymentType;
			oa.CurrencyIsoCode=orderWizard.wrap.newOrder.CurrencyIsoCode;
			oa.Refund_or_Misc_Amount__c=ordDelta;
			//oa.Misc_Charge_Status__c='Waiting for Payment';
			oa.Status__c='Waiting for Payment';
			oa.Credit_Card_Type__c	=NULL;
			upsert oa;
		}	
		
	}
	
	
	public void PullOrderCheckMO(){
		orderWizard.PullOrderCheck();
		bHasError = !String.isBlank(orderWizard.PullOrderErrorMessage);
		if (bHasError){
			bValidated = false;
		}
	}
	
	public void validateMailOrder(){
		ApexPages.getMessages().clear();	
		system.debug('CouponCode~~~'+orderWizard.wrap.couponCode);
		orderWizard.queryCouponPromo();
		bTaxCalcd = false;
		boolean isError = false;
		List <Order_Line_Items__c> oliList = new List <Order_Line_Items__c>();
		Map<string,oliWrapper_Mail> mapSKUWrapper = new Map<string,oliWrapper_Mail>();
		for (oliWrapper_Mail w: oliWrapperList_Mail){
		system.debug('w~~~~'+w);
		system.debug('w.oliWrap.OrdrLineItem~~~~'+w.oliWrap.OrdrLineItem);
		w.errorMessage = '';
		w.rowCss = '';
		if(string.isnotblank(w.oliWrap.OrdrLineItem.SKU_Number__c))
		{
				w.oliWrap.OrdrLineItem.SKU_Number__c = orderutilities.zeroLPAD(w.oliWrap.OrdrLineItem.SKU_Number__c, 6);
				//w.OrdrLineItem.Product_Quantity__c = 200;
				w.isErrorRow = true; 
				if(!mapSKUWrapper.containskey(w.oliWrap.OrdrLineItem.SKU_Number__c))
					mapSKUWrapper.put(w.oliWrap.OrdrLineItem.SKU_Number__c,W);
				else
					{
						w.errorMessage = 'Duplicate Item';
						w.rowCss = 'error';
						isError = true;
					}
				system.debug('*** SKU*** ' + w.oliWrap.OrdrLineItem.SKU_Number__c);
			}
		}
			
		List<Item__c> listItem = new List<Item__C>();	  
		String ProdSuffix;
		Orders__c orderObj = [select id, Customer__r.Associate_Customer__c, customer__r.recordType.DeveloperName from Orders__c where id =:orderWizard.wrap.newOrder.id];
		Customer_Rec_Type_Brand_Mapping__c CRTBM = Customer_Rec_Type_Brand_Mapping__c.getInstance(orderObj.customer__r.recordType.developerName);

		if(CRTBM != null)
		{
			ProdSuffix = CRTBM.Product_Suffix_c__c;
		}
			
		listItem = [Select TaxCode__c, Sale_Price__c, Product_Number__c, Name, Available_Inventory__c,inventory_status__c,Backorder__c ,unit_price__c
							From Item__c where Product_Number__c in :mapSKUWrapper.keySet()
							and Product_Suffix__c = :ProdSuffix
							AND  Is_Active__c =true];
		List<Order_Line_Items__c> lstPromoOLI = new List<Order_Line_Items__c>();
		Integer lineitemID = 0;
		for(Item__C i :listItem)
		{
			if(mapSKUWrapper.containsKey(i.Product_Number__c))
			{
				OLIWrapper_Mail temp = mapSKUWrapper.get(i.Product_Number__c);
				temp.websitePrice = i.Sale_Price__c;
				temp.oliWrap.ProductName = i.Name;
				temp.rowCss = '';
				temp.errorMessage = '';
				temp.isErrorRow = false; // Other validation errors here
				if(i.inventory_status__c == 'OutOfStock' )
					{
						temp.errorMessage = 'Out of Stock';
						temp.rowCss = 'error';
						isError = true;
					}
				
				if(i.inventory_status__c == 'Backorder' )
					{
						temp.errorMessage = 'Item is Back Ordered';
						temp.rowCss = 'warning'; // Put other valid CSS for warning....
					}
				if(string.valueof(temp.oliWrap.OrdrLineItem.Original_Quantity__c).IsNumeric())
				{
					if(temp.oliWrap.OrdrLineItem.Original_Quantity__c < 1)
						{
							temp.errorMessage = 'Not a valid quantity';
							temp.rowCss = 'error';
							isError = true;
						}
				}
				else
				{
					temp.errorMessage = 'Quantity should be numeric';
					temp.rowCss = 'error';
					isError = true;
					
				}
				//temp.oliWrap.OrdrLineItem.Name = string.valueof(orderWizard.wrap.neworder.name) + string.valueof(lineitemID++);
				temp.oliWrap.OrdrLineItem.Product_Name__c = i.id;
				if (temp.oliWrap.onlyOneItem){
					temp.oliWrap.OrdrLineItem.Original_Quantity__c = 1;	
					temp.oliWrap.FreeQuantity = 0; 
					temp.oliWrap.OrdrLineItem.Final_Price__c = temp.oliWrap.OrdrLineItem.Original_Quantity__c * i.Unit_Price__c ;
				}
				lstPromoOLI.add(temp.oliWrap.OrdrLineItem);
			}
			
		}	
		system.debug('-****- Size of Promo Line ' + lstPromoOLI.size());
		list<OLIWrapper_Mail> lstOliWrapper = mapSKUWrapper.values();
		
		for(OLIWrapper_Mail oliw :lstOliWrapper)
		{
			if(oliw.isErrorRow)
			{
				oliw.errorMessage = string.isblank(oliw.errorMessage)?'Invalid SKU':oliw.errorMessage ; // CSS formatting here for the row
				oliw.rowCss = 'error';
				isError = true;
			}	 
		}
		
		bValidated = !isError;
		// DE833 -- To hide the edit addresses button; just to mimic on error behavior of other wizard.
		bHasError = isError;
		if(isError) return;

		orderWizard.wrap.selectedOrderLineItems = lstPromoOLI;
		// DE830 -- clearing the description 
		if (orderWizard.wrap.newOrder.promotions__r.Offers__c != null){
			orderWizard.wrap.newOrder.promotions__r.Offers__c = null;
		}
		// No error allow promotions now.
		applyPromotion_Mail();
		// DE830 -- If promo was invalid display some sort of error
		if (!String.isBlank(orderWizard.wrap.couponCode) && !String.isBlank(orderWizard.wrap.newOrder.Source_Code__c)){
			if(orderWizard.wrap.newOrder.Source_Code__c != orderWizard.wrap.couponCode){
				isError = true;
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Invalid coupon code entered. Please double check it is entered correctly and try again.'));
			}
		}
		// DE830 -- if all the prior things passed, but the code is invalid; toss error
		if (isError){
			bValidated = !isError;
			bHasError = isError;
			return;
		}
		orderWizard.resetOliWrapperList();
		bValidated = true;
	}
	
	public void runPaymentTotal(){
		ordTotal = 0;
		for(Payment_Detail__c c: checkList){
			if(c.Amount__c > 0 || c.Amount__c != null){
				ordTotal += c.Amount__c;
			}
		}
	}
	
	public class oliWrapper_Mail{
		public boolean clearRow {get; set;}
		public string errorMessage {get; set;}
		public double websitePrice {get;set;}
		public boolean isErrorRow {get;set;}
		public string rowCss {get;set;}
		public string indexKey {get;set;}
		public OrderWizard_NewOrder.OLIWrapper oliWrap {get;set;}
		
		public oliWrapper_Mail(OrderWizard_NewOrder.OLIWrapper oliw){
			this.indexKey = randStr(4);
			this.clearRow = false;
			this.oliWrap = oliw;
		}
	}
	
	public static String randStr(Integer len) {
		String strSet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';
		String randomString = '';
		for (Integer i = 0; i < len; i++) {
			Integer rPos = (Integer)(Math.floor(Math.random() * strSet.length()));
			randomString += strSet.substring(rPos,rPos+1);
		}
		return randomString;
	}
	
	global static list<PromoResultSet> PromoSearchResults {get;set;}	
	
		global class PromoResultSet
	{
		public String Id {get;set;} 
		public String Name{get;set;}
		public String Description {get;set;}	
		public boolean isActive			 {get;set;}
			
		public PromoResultSet(sObject s)
		{
			this.Id = s.Id;
			this.Name = s.get('Name')+'';
			if (s.get('Offers__c')!=null) this.Description = s.get('Offers__c')+''; 
			else this.Description = '';
			
			if(s.get('Active__c') == true)
			{
				this.isActive =true;
			}  
			else
			{
				this.isActive=false;
			}
		}
	}
	
	@RemoteAction
	global static PromoResultSet[] getPromotionRecords(boolean bCoupon, String searchText, string orderId){
		String ProdSuffix='11';
		Orders__c orderObj = [select id, customer__r.recordType.developername from Orders__c where id =:orderId];
		Customer_Rec_Type_Brand_Mapping__c CRTBM = Customer_Rec_Type_Brand_Mapping__c.getInstance(orderObj.customer__r.recordType.developerName);
		if (CRTBM!=null){
			if (CRTBM.Product_Suffix_c__c!=null){
				ProdSuffix=string.valueOf(CRTBM.Product_Suffix_c__c);//no need to trim zeros any more
			}
		}
		//sObject List
		PromoSearchResults = new list<PromoResultSet>(); 
		
		//SOSL Text should be more then one character
		if(searchText.length() >0){
			searchText = '%' + searchText + '%';
			//SOSL operation to retrive records of the Promotions object
			string searchType = bCoupon? 'Coupon': 'SourceCode';
			system.debug(searchType);
			system.debug(prodSuffix);
			system.debug(searchText);
			List<SObject> searchList = [SELECT Id, Name, Start_Date__c, End_Date__c, Offers__c, Active__c FROM Promotion__c WHERE Name LIKE :searchText AND  suffix__c=:prodSuffix AND Promo_TYPE__c=:searchType AND Active__c=true LIMIT 5];
			//Adding diffrent object's records in sobject list
			
			for(SObject s:searchList){
				PromoSearchResults.add(new PromoResultSet(s));
			}
			
		}
		return PromoSearchResults;
	}
	
}