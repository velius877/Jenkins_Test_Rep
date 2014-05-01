public with sharing class AvalaraTaxCalc {
		
	private static taxSvc.Security setupSecurity(){
		TaxSvc.TaxSvcSoap taxSvc = new TaxSvc.TaxSvcSoap(WS_Integration__c.getValues('AvaTaxEndPoint').value__C);
		taxSvc.Security = new TaxSvc.Security();
		taxSvc.Security.UsernameToken.Username = WS_Integration__c.getValues('AvaTaxUserID').value__C;
		taxSvc.Security.UsernameToken.Password = WS_Integration__c.getValues('AvaTaxPassword').value__C;
		system.debug( '~~~security'+taxSvc.Security);
		return taxSvc.Security ;
	}
			
	public static OrderWizard_Wrapper applyBackupTax(OrderWizard_Wrapper wrap){
		string backupTaxKey; 
		Map <Id, Item__c>   itemMap = new Map <Id, Item__c>();
		Set <Id>						itemSet = new Set <Id>();
	
		for (Order_Line_Items__c oli: wrap.selectedOrderLineItems){
			itemSet.add(oli.product_name__c);
		}
	
		for (Item__c item: [select id, Taxable_Item__c from Item__c where id in:itemSet]){
			itemMap.put(item.id, item);
		}
	
		if (wrap.newOrder.ship_to_address__r.Country__c=='CA'){
			backupTaxKey=wrap.newOrder.ship_to_address__r.zip_code__c.substring(0,1);
		} else {
			backupTaxKey=wrap.newOrder.ship_to_address__r.zip_code__c;
		}
		
		try {
			decimal taxRate =[select taxrate__c from Tax_Backup__c where zipCode__c=:backupTaxKey limit 1].taxRate__c;
			decimal totalTax = 0;
			for (Order_Line_Items__c oli: wrap.selectedOrderLineItems){
				boolean isTaxable = itemMap.get(oli.product_name__c).Taxable_Item__c;
				if (!isTaxable) oli.Tax__c=0;
				else {
					oli.Tax__c=oli.Unit_Price__c*taxRate.setScale(2);
					oli.Final_Price__c=oli.Tax__c+oli.Unit_Price__c;
					totalTax+=oli.Tax__c;
				}
			}
			wrap.tax = totalTax;
		} catch (exception e){
			wrap.tax = 0;
		}
		return wrap; 
	}

	@future
	public static void CalculateTax_OrderSubmission_Future(Id OrderId){
		CalculateTax_OrderSubmission(orderId);
	}

	public static void CalculateTax_OrderSubmission(Id OrderId){
					Orders__c orderObj = [SELECT 	customer__r.Payment_Profile_Id__c,	Tax__c,Discount__c,Catalog_Source_Code__c , Source_Code__c, Ship_To_Address__r.Zip_Code__c,Ship_To_Address__r.Zip_Code_4__c, Ship_To_Address__r.Foreign_Postal_Code__c,
												Ship_To_Address__r.Country__c, Ship_To_Address__r.City__c, Ship_To_Address__r.Address_Line_3__c, Shipping_Total__c, 
											   Ship_To_Address__r.Address_Line_2__c, Ship_To_Address__r.Address_Line_1__c,Ship_To_Address__r.State_Providence__c,
											   customer__r.personEmail, Order_Total__c, payment_type__c, Pull_Order__c, No_Invoice__c, No_Peanuts__c, No_Catalogs__c,  No_Substitutes__c, Ship_Complete__c, customer__r.recordType.developerName, customer__r.name, Customer__r.Associate_Customer__c, customer__r.Associate_ID__c, promotions__r.name, promotions__r.offers__c, id,name, Order_Status__c, Sales_Channel__c, Shipping_Method__c , customer__c, Bill_To_Address__c , Ship_to_address__c, Credit_Amount_Applied__c, Credit_Applied__c, Credit_Reasons__c, Credit_Card_Token__c 
														,  Ship_To_Last_Name__c, Ship_To_First_Name__c ,Comments__c,Credit_Card_Expiration_Date__c
														FROM Orders__c WHERE id =:OrderId];
				
				system.debug('--------------------------------orderObj: ' + orderObj);
				OrderWizard_Wrapper wrap = new OrderWizard_Wrapper(orderObj);
				wrap.ShippingCharges = orderObj.Shipping_Total__c;
				wrap = CalculateTax(wrap,true);
				
	}

	public static boolean checkTaxableState (Customer_Rec_Type_Brand_Mapping__c crtbm, string checkState){
		if (crtbm==null||checkState==null){
			return false;
		}
		else {
			if (crtbm.taxable_states__c==null){
				return false;
			}
			else {
				try {
					Set <String> taxStateSplit = new Set <String>();
					List<String> taxStateList = crtbm.taxable_states__c.split(';');
					for (string s: taxStateList){
						taxStateSplit.add(s);
					}
					if (taxStateSplit.contains(checkState)){
						return true;
					}
					else return false;
				}
				catch(exception e){
					return false;
				}
			}
		}
	}
	
	public static OrderWizard_Wrapper CalculateTax(OrderWizard_Wrapper wrap, boolean bCommit){
		id orderId = wrap.newOrder.id;
		TaxSvc.TaxSvcSoap taxSvc = new TaxSvc.TaxSvcSoap(WS_Integration__c.getValues('AvaTaxEndPoint').value__C);
		taxSvc.Security = setupSecurity();
		taxSvc.Profile = new TaxSvc.Profile(); //'GetTaxDemo,1,0';
		taxSvc.Profile.Client = WS_Integration__c.getValues('AvaTaxClientProfile').value__C;
		wrap.Tax=0;
		Customer_Rec_Type_Brand_Mapping__c crtbm =NBTYUtils.getRecordTypeBrandMappingMap().get(wrap.newOrder.Customer__r.RecordType.DeveloperName);
	   
		if (wrap.newOrder.Ship_To_Address__r.Country__c==null){
			wrap.newOrder.Ship_To_Address__r=[select  	Country__c, City__c, Address_Line_3__c,  Zip_Code__c,Zip_Code_4__c,Foreign_Postal_Code__c,
										   										Address_Line_2__c, Address_Line_1__c,State_Providence__c From Address__c where id=:wrap.newOrder.Ship_To_Address__c];
		} 
		boolean bTaxableState = checkTaxableState(crtbm,wrap.newOrder.ship_to_address__r.State_Providence__c)||wrap.newOrder.Ship_To_Address__r.Country__c=='CA';
		system.debug(loggingLevel.info, '**Taxable ?** '+bTaxableState);
		/*		
		// Get Order Details.
		List<Orders__c> lstOrderSummary = [Select Customer__r.RecordType.DeveloperName, Name, Ship_To_Address__r.Zip_Code__c,Ship_To_Address__r.Zip_Code_4__c, 
										   Ship_To_Address__r.Country__c, Ship_To_Address__r.City__c, Ship_To_Address__r.Address_Line_3__c, Shipping_Total__c, Shipping_Method__c,
										   Ship_To_Address__r.Address_Line_2__c, Ship_To_Address__r.Address_Line_1__c,Ship_To_Address__r.State_Providence__c,
										   (Select Unit_Price__c, Product_Name__c, Product_Quantity__c,Tax__c,Product_number__c, Product_ID__c,Name, Line_Number__c,Final_Price__c,Tax_Code__c From Order_Line_Items__r)  
											From Orders__c where Id =:OrderID ];
											

		
		// Chec!lstOrderSummary.isEmpty()
		Orders__c wrap.newOrder = new Orders__C();
		
		if(!lstOrderSummary.isEmpty())
			wrap.newOrder = lstOrderSummary[0];
		else
			throw new NBTYException('Invalid Order ID');*/
		
		system.debug('XXX ' + wrap.newOrder.Ship_To_Address__r.Country__c);   
		if (AddressTriggerHelper.isUSAddress( wrap.newOrder.Ship_To_Address__r.Country__c)&&bTaxableState){						 
			TaxSvc.GetTaxRequest gtreq = new TaxSvc.GetTaxRequest();
			gtreq.Lines = new TaxSvc.ArrayOfLine();
			integer totalItems = 0;
			Orders__c orderObj = new Orders__c(id=wrap.newOrder.id);
			for(Order_Line_Items__c ol :wrap.selectedOrderLineItems) {
				totalItems++;   
			}
			 
			system.debug('$$$ Total Items ' + string.valueof(totalItems));
			gtreq.Lines.Line = new TaxSvc.Line[totalItems];
			integer indexLine = 0;
			Map<string,Order_Line_Items__C> mapLineOrder = new Map<string,Order_Line_Items__C>();
			integer lineNumber = 1;
			integer shippingLineNumber;
			
			for(Order_Line_Items__c ol :wrap.selectedOrderLineItems)
			{
				system.debug('line~~~~~'+ol);
				gtreq.Lines.Line[indexLine] = new TaxSvc.Line();
				gtreq.Lines.Line[indexLine].No = string.valueof(lineNumber);
				system.debug('$$$ Line number: ' + string.valueof(lineNumber));
				gtreq.Lines.Line[indexLine].ItemCode = ol.Product_number__c;
				gtreq.Lines.Line[indexLine].Description = ol.Name;
				gtreq.Lines.Line[indexLine].TaxCode = ol.Tax_Code__c;
				gtreq.Lines.Line[indexLine].Amount = ol.Final_Price__c;
				gtreq.Lines.Line[indexLine].Qty = ol.Product_Quantity__c;
				mapLineOrder.put(string.valueof(lineNumber),ol);
				lineNumber++;
				indexLine++;
			}
			
			if (wrap.ShippingCharges!=null&&wrap.ShippingCharges!=0){
				TaxSvc.Line ShippingLine = new TaxSvc.Line();
				ShippingLine.No = string.valueof(lineNumber);
				system.debug('$$$ Line number: ' + string.valueof(lineNumber));
				ShippingLine.ItemCode = 'SHIPPING';
				ShippingLine.Description = wrap.newOrder.Shipping_Method__c;
				ShippingLine.TaxCode = 'FR020100';
				if (wrap.ShippingDiscount==null) wrap.ShippingDiscount=0;
				ShippingLine.Amount = wrap.ShippingCharges-wrap.ShippingDiscount;
				ShippingLine.Qty = 1;
				gtreq.Lines.Line.add(shippingLine);
				shippingLineNumber=lineNumber;
			}
				
			// doc code AKA invoce number will be the Order number
			gtreq.DocCode = wrap.newOrder.Name;
			// SalesOrder, SalesInvoice, ReturnOrder, ReturnInvoice, PurchaseOrder, PurchaseInvoice
			gtreq.DocType = 'SalesInvoice';
			gtreq.CustomerCode = 'NBTY';
			//Todo Change Code based logic
			gtreq.CompanyCode = NBTYUtils.getRecordTypeBrandMappingMap().get(wrap.newOrder.Customer__r.RecordType.DeveloperName).Company_Code__c;
			system.debug('companyCode~~~~'+gtreq.companyCode);
			// Document (default), Line, Tax
			gtreq.DetailLevel = 'Tax';
			
			//Base Address 0-2 Address 1,2,3 3 City  4 State 5 Zip 
			List<String> baseAddress = WS_Integration__c.getValues('AvalaraTaxOrgAddress').value__C.split(':');
			
			TaxSvc.BaseAddress orgAddr = new taxSvc.BaseAddress();
			orgAddr.AddressCode = 'Origin';
			orgAddr.Line1 = baseAddress[0];
			orgAddr.Line2 =  baseAddress[1];
			orgAddr.Line3 = baseAddress[2];
			orgAddr.City = baseAddress[3];
			orgAddr.Region = baseAddress[4];
			orgAddr.PostalCode = baseAddress[5];
			
			TaxSvc.BaseAddress dstAddr = new TaxSvc.BaseAddress();
			dstAddr.AddressCode = 'Destination';
		
			dstAddr.Line1 = wrap.newOrder.Ship_To_Address__r.Address_Line_1__c;
			dstAddr.Line2 = wrap.newOrder.Ship_To_Address__r.Address_Line_2__c;
			dstAddr.Line3 = wrap.newOrder.Ship_To_Address__r.Address_Line_3__c;
			dstAddr.City = wrap.newOrder.Ship_To_Address__r.City__c;
			dstAddr.Region = wrap.newOrder.Ship_To_Address__r.State_Providence__c;
			dstAddr.PostalCode = wrap.newOrder.Ship_To_Address__r.Zip_Code__c !=null? wrap.newOrder.Ship_To_Address__r.Zip_Code__c : wrap.newOrder.Ship_To_Address__r.Foreign_Postal_Code__c;
		   
			gtreq.Addresses = new TaxSvc.ArrayOfBaseAddress();
			gtreq.Addresses.BaseAddress = new TaxSvc.BaseAddress[2];
			
			gtreq.Addresses.BaseAddress[0] = orgAddr;
			gtreq.Addresses.BaseAddress[1] = dstAddr;
			gtreq.OriginCode = orgAddr.AddressCode;
			gtreq.DestinationCode = dstAddr.AddressCode;
			gtreq.DocDate = Date.Today();
			gtreq.Commit_x=bCommit;
			TaxSvc.GetTaxResult gtres = null;
			String SampleResult = '';
			
			try {
				gtres = taxSvc.GetTax(gtreq);
				SYSTEM.DEBUG(LOGGINGLEVEL.INFO, gtres);
				system.debug(LoggingLevel.info, gtres.TaxLines.TaxLine[0]);
				
				if(gtres.ResultCode == 'Success') {
					 SampleResult = 'GetTax Succeeded - Total Tax: ' + gtres.TotalTax;
					 wrap.Tax = gtres.TotalTax;
					 system.debug('totalTax~~~~'+wrap.tax);
					 taxSvc.ArrayOfTaxLine calTaxLines = new taxSvc.ArrayOfTaxLine();
					 calTaxLines = gtres.TaxLines;
					 TaxSvc.TaxLine[] resTaxLine = calTaxLines.TaxLine;
					 system.debug('$$$ - Total returned Tax Lines ' + resTaxLine.size());
					 List <Order_Line_Items__c> tempOliList = new List <Order_Line_Items__c>();
					 for(TaxSvc.TaxLine lineTax :resTaxLine) {
						system.debug('$$$ linetax ' + lineTax.TaxCalculated);
						system.debug('$$$ TaxCode ' + lineTax.TaxCode);
						system.debug('$$$ TaxNo ' + lineTax.No);
						if (mapLineOrder.get(lineTax.No)!=null){
							Order_Line_Items__c tempLineItem = mapLineOrder.get(lineTax.No);
							tempLineItem.Tax__c = lineTax.TaxCalculated;
							system.debug(tempLineItem.tax__c+'tax~~~~');
							system.debug(tempLineItem+'tempLineItem~~~~');
							tempOliList.add(tempLineItem);
						}

						if (integer.ValueOf(lineTax.No)==shippingLineNumber){
							system.debug('lineTax.TaxCalculated~~~'+lineTax.TaxCalculated);
							wrap.newOrder.Shipping_Tax__c=lineTax.TaxCalculated;
						}
					 }
					 
					 // Update Order Line Item
					
					 wrap.selectedOrderLineItems= tempOliList	;
					 wrap.newOrder.Tax__c = wrap.tax;
					//update OrderObj;
					system.debug(LoggingLevel.info, SampleResult);
					wrap.AvalaraCalloutFailed = false;
					wrap.newOrder.AvalaraCalloutFailure__c = false;
				}
				else {
					SampleResult = 'GetTax Returned Other Than Success: ' + gtres.ResultCode + ' : ' + gtres.Messages.Message[0].Name + ' : ' + gtres.Messages.Message[0].Summary;
					wrap.AvalaraCalloutFailed = true;
					wrap.newOrder.AvalaraCalloutFailure__c = true;
				}
				return wrap;
			} catch(Exception ex)	{
				system.debug(ex.getmessage());
				if (ex.getMessage().contains('TestMethod')) {
					//throw new NBTYException('Error Calculating Tax.');
					wrap =  applyBackupTax(wrap);
				}
				wrap.AvalaraCalloutFailed = true;
				wrap.newOrder.AvalaraCalloutFailure__c = true;
				return wrap;
			}	 
		}
		else {
			return wrap;
		}
	} 
}