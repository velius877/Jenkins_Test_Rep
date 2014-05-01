/*
 * Author		: Pavan Jasti, Acumen
 * Class		: OrderAdjustmentController 
 * Date		 : 08/29/2013
 * Description  : Backend controller for OrderAdjustmentPage.
*/

public with sharing class OrderAdjustmentController {
	public static string ORDER_MISSING = 'There is no Order attached to this Case. Please attach an Order to this Case before creating an Order Adjustment.';
	public static string FULL_REFUND_NOT_POSSIBLE = 'Full Refund cannot be applied to this order, all Line Items should be selected';
	public static string PARTIAL_REFUND_NOT_POSSIBLE = 'At least one Line Item must be selected for a Partial Refund';
	public static string ORDER_ADJ_NOT_CREATED = 'The operation failed' ;
	public static string ORDER_NOT_SUBMITTED = 'The order is not submitted to create or edit Order adjustments.';
	public static string AMOUNT_ERROR = 'Amount cannot be blank or zero.';
	public static String AMOUNT_GREATER_ERROR = 'Amount cannot be greater than order total.';
	public static string PAYMENT_METHOD_MISSING = 'Payment method cannot be empty.';
	public static string CASE_MISSING = 'No Case found.';
	public static string ADJ_PROCESSED = 'Processed Order Adjustments May Not be Edited';
	
	public Order_Adjustment__c orderAdj {get;set;}
	public Account customer {get;set;}
	public Orders__c relatedOrder{get;set;}
	public boolean haserrors {get;set;}
	public string selectedAdjrecType{get;set;}
	public string caseId {get;set;}
	public Case contCase {get;set;}
	public boolean renderOrderAdjFrom {get;set;}
	public List<Order_Adjustment_Line_Item__c> adjlineItemsList {get;set;}

	public map<string,string> recordTypeMap {get;set;}
	public boolean showRefundFields{get;set;}
	public boolean showMiscFields{get;set;}
	public boolean showLineItems{get;set;}
	public boolean checked{get;set;}
	public boolean existingAdj{get;set;}
	public string tabName {get;set;}
	
	public OrderAdjustmentController(ApexPages.StandardController stdObj) {
		// Handles both Case Id and order adjustment Id when passed through URL.
		Id orderAdjId= stdObj.getId();
		string caseId;
		string orderId;
		orderAdj = new Order_Adjustment__c();
		contCase = new case();
		relatedOrder = new orders__c();
		existingAdj = false; // For new order adjusmtnet creation
		
		if (orderAdjId != null) {
			orderAdj = [SELECT Id,Name,Refund_Type__c, Status__c, Related_Order__c, Related_Case__c, Refund_or_Misc_Amount__c, Credit_Card_Token__c, 
						RecordTypeId, Return_Received_Date__c, Product_Return__c, Credit_Card_Type__c, Credit_Card_Number__c, Return_Received__c, 
						Credit_Card_Name__c,Credit_Card_Expiration_Date__c,Payment_Method__c,Related_Order_Tax_Amount__c, Related_Order__r.Sales_Channel__c, 
						Related_Order_Payment_Amount__c, Related_Order_SubTotal__c, Related_Order_Shipping_Amount__c, Related_Order_Discount_Amount__c, 
						Related_Order_Amount__c, Related_Order_Payment_Type__c, Salesforce_Order_Number__c, AS400_Order_Number__c, Related_Order__r.Payment_Type__c, 
						Web_Order_Number__c, Customer__c, Customer__r.name, (SELECT Id FROM Order_Adjustment_Line_Items__r)
						FROM Order_Adjustment__c WHERE Id= :orderAdjId limit 1] ;
			
			existingAdj = true;
			customer = [select Id,name from Account where Id=:orderAdj.Customer__c];
			// keeping upto date with SF order if it is not purged yet for the inital creation of Order adjustment.
			updateOrderDetails(orderAdj.Related_Order__c);
		} else {//if new order adjustment, then runs off based on case Id. Condition runs through New order adjustment button
			try {
				caseId = ApexPages.currentPage().getParameters().get('caseId');
				if(caseId == null || caseId == '') {
					caseId = ((Order_Adjustment__c)stdObj.getRecord()).Related_Case__c ;
				}
				contCase = [select Id,Related_Order__c, Customer__c from case where Id=: caseId limit 1];
				customer = [select Id,name from Account where Id=:contCase.Customer__c];
			} catch(exception ex) {
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, CASE_MISSING ));
				renderOrderAdjFrom = false;
				return;
			}
			if (String.isBlank(contCase.Related_Order__c)) {
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, ORDER_MISSING ));
				renderOrderAdjFrom = false;
				return;
			}
			existingAdj = false;
			updateOrderDetails(contCase.Related_Order__c);
		}
		
		if(orderAdj.Status__c == 'Processed') {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, ADJ_PROCESSED ));
		}
		//Validation before 
		recordTypeMap = new map<string,string>();
		adjlineItemsList = new List<Order_Adjustment_Line_Item__c>();
		selectedAdjrecType = '';
		haserrors = false;
		renderOrderAdjFrom = true;
		checked = true;
		renderComponents();
	}
	
	//Updates Order details to Order adjustment and for any updates no going back to Order(to overcome Purging process)
	public void updateOrderDetails(string ordId) {
		if (ordId != null) {
			//related order has references in VF page
			relatedOrder = [SELECT Id, Name, Order_Submitted__c, Payment_Type__c, Order_Sub_Total__c, Calculated_Discount__c, Calculated_Shipping__c, Payment_Value__c, Order_Total__c, 
							Tax__c,Calculated_Order_Total__c,Credit_Card_Token__c, 
							Customer__c, Payment_Transaction_Reference_Number__c, Paypal_Authorization_Code__c 
							FROM Orders__c WHERE Id=:ordId limit 1];
			
			orderAdj.Related_Order_Payment_Type__c = orderAdj.Related_Order_Payment_Type__c == null ? relatedOrder.Payment_Type__c : orderAdj.Related_Order_Payment_Type__c;
			orderAdj.Related_Order_Paypal_Transaction_ID__c = orderAdj.Related_Order_Paypal_Transaction_ID__c == null ? relatedOrder.Paypal_Authorization_Code__c : orderAdj.Related_Order_Paypal_Transaction_ID__c;
			orderAdj.Related_Order_Tax_Amount__c = orderAdj.Related_Order_Tax_Amount__c == null ? relatedOrder.Tax__c : orderAdj.Related_Order_Tax_Amount__c;
			orderAdj.Salesforce_Order_Number__c = orderAdj.Salesforce_Order_Number__c == null ? relatedOrder.name : orderAdj.Salesforce_Order_Number__c;
			orderAdj.Related_Order_Amount__c = orderAdj.Related_Order_Amount__c == null ? relatedOrder.Calculated_Order_Total__c : orderAdj.Related_Order_Amount__c;
			orderAdj.Related_Order_Transaction_Ref_Number__c = orderAdj.Related_Order_Transaction_Ref_Number__c == null ? relatedOrder.Payment_Transaction_Reference_Number__c : orderAdj.Related_Order_Transaction_Ref_Number__c;
			orderAdj.Related_Case__c = orderAdj.Related_Case__c == null ? contCase.Id : orderAdj.Related_Case__c;
			orderAdj.Related_Order__c = orderAdj.Related_Order__c == null ? relatedOrder.Id : orderAdj.Related_Order__c;
			orderAdj.Customer__c = orderAdj.Customer__c == null ? relatedOrder.Customer__c : orderAdj.Customer__c;
			orderAdj.Credit_Card_Token__c = orderAdj.Credit_Card_Token__c == null ? relatedOrder.Credit_Card_Token__c : orderAdj.Credit_Card_Token__c;
		}
		
	}
	
	public List<SelectOption> getAdjRecTypes() {
		List<SelectOption> options = new List<SelectOption>();
		recordTypeMap = new map<string,string>();
		options.add(new SelectOption('','None'));
		for (RecordType recType : [SELECT Id, Name, DeveloperName FROM RecordType WHERE sObjectType = 'Order_Adjustment__c' AND DeveloperName != 'Read_Only']) {
			options.add(new SelectOption(recType.Id,recType.DeveloperName));
			recordTypeMap.put(recType.Id,recType.DeveloperName);
		}
		system.debug('@@@@ Recordtypes'+options);
		return options;
	}
	
	public List<SelectOption> getRefundMethods() {
		List<SelectOption> options = new List<SelectOption>();
		map<string,Set <String>> dependentPicklistMap = new map<string,Set <String>> {'Credit Card' => new Set <String>{'Credit Card','Check','Customer Credit'},
																		 'Check'=> new Set <String>{'Check','Customer Credit'},
																		 'PayPal' => new Set <String>{'PayPal','Check','Customer Credit'},
																		 'Paypal' => new Set <String>{'PayPal','Check','Customer Credit'},
																		 'Cash'=> new Set <String>{'Check','Customer Credit'}};
		
		options.add(new SelectOption('','None'));
		
		if (dependentPicklistMap.containsKey(orderAdj.Related_Order_Payment_Type__c)) {
			for (string str : dependentPicklistMap.get(orderAdj.Related_Order_Payment_Type__c)) {
				
				options.add(new SelectOption(str,str));
			}
		} else {
			for (Schema.PicklistEntry p : Schema.SObjectType.Order_Adjustment__c.fields.getMap().get('Payment_Method__c').getDescribe().getPicklistValues()) {
				options.add(new SelectOption(p.getLabel(), p.getValue()));
			}
		}
		return options;
	}
	
	public List<SelectOption> getMiscChargeMethods() {
		List<SelectOption> options = new List<SelectOption>();
		set<string> pickListOptions = new Set<String>{'Credit Card','Existing Card','Check', 'Cash'};
		options.add(new SelectOption('','None'));
		for (string str : pickListOptions) {
			options.add(new SelectOption(str,str));
		}
		return options;
	}
	
	public List<SelectOption> getMiscChargeStatus() {
		List<SelectOption> options = new List<SelectOption>();
		map<string,Set <String>> picklistMap = new map<string,Set <String>> {'Cash' => new Set <String>{'Waiting for Payment','Customer Paid'},
																			 'Check'=> new Set <String>{'Waiting for Payment','Customer Paid'}};
		options.add(new SelectOption('','None'));
		
		if (picklistMap.containsKey(orderAdj.Related_Order_Payment_Type__c)) {
			for (string str : picklistMap.get(orderAdj.Related_Order_Payment_Type__c)) {
				options.add(new SelectOption(str,str));
			}
		}
		return options;
	}
	
	public List<Order_Adjustment_Line_Item__c> getAdjLineItems() {
		
		if (adjlineItemsList.isEmpty()) {
			adjlineItemsList = new List<Order_Adjustment_Line_Item__c>();
			haserrors = false;
			if (orderAdj.Order_Adjustment_Line_Items__r != null && orderAdj.Order_Adjustment_Line_Items__r.size() > 0) {
				adjlineItemsList = [SELECT Id, Order_Adjustment__c , Item_Name__c, Quantity__c, Amount__c, SKU_Number__c, IsChecked__c
										FROM Order_Adjustment_Line_Item__c 
										WHERE Order_Adjustment__c = :orderAdj.Id
										ORDER BY Item_Name__c DESC NULLS LAST];
			} else {// when Order adjustmnet gets created from case, loading line items of order instead of Order history line items
				if (relatedOrder.Id != null) {
					for(Order_Line_Items__c li : [SELECT Id, Name, Related_Order_Adjustment__c, Product_Name__r.Name, Product_Quantity__c, Final_Price__c, SKU_Number__c 
													FROM Order_Line_Items__c 
													WHERE Order__c = :relatedOrder.Id
													ORDER BY Product_Name__r.Name DESC NULLS LAST])
					{
						Order_Adjustment_Line_Item__c oali = new Order_Adjustment_Line_Item__c();
						oali.Item_Name__c = li.Product_Name__r.Name;
						oali.Quantity__c = li.Product_Quantity__c;
						oali.Amount__c = li.Final_Price__c;
						oali.SKU_Number__c = li.SKU_Number__c;
						oali.external_key__c = li.Name;
						adjlineItemsList.add(oali);
					}
				}
			}
		}
		checkUncheckItems();
		return adjlineItemsList;
	}
	
	public void checkUncheckItems() {
		for (Order_Adjustment_Line_Item__c li : adjlineItemsList) {
			if (selectedAdjrecType == 'Refund' && orderAdj.Refund_Type__c == 'Full Refund') {
				li.IsChecked__C = true;
			} else {
				li.isChecked__c = false;
			}
		}
	}
	
	public pageReference createOrderAdjustment() {
		try {
			hasErrors = false;
			if (orderAdj.Payment_Method__c == null || orderAdj.Payment_Method__c == '' ) {
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,  PAYMENT_METHOD_MISSING));
				hasErrors = true;
				return null;
			}
			//GA: Mail orders should allow refunds greater than the order total due to overpayment issues
			if (orderAdj.Refund_or_Misc_Amount__c == null || orderAdj.Refund_or_Misc_Amount__c <= 0) {
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, AMOUNT_ERROR));
				hasErrors = true;
				return null;
			}
			Set<String> mySet = new Set<String>{'Cash','Check','Money Order'};
			if (orderAdj.Refund_or_Misc_Amount__c > orderAdj.Related_Order_Amount__c) {
				if (orderAdj.Related_Order__r.Sales_Channel__c != 'Mail' && !mySet.contains(orderAdj.Related_Order__r.Payment_Type__c)) {
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, AMOUNT_GREATER_ERROR));
					hasErrors = true;
					return null;
				}
			}
			/*if ((orderAdj.Refund_or_Misc_Amount__c == null || orderAdj.Refund_or_Misc_Amount__c <= 0) || (orderAdj.Refund_or_Misc_Amount__c > orderAdj.Related_Order_Amount__c) ) {
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,  AMOUNT_ERROR));
				hasErrors = true;
				return null;
			}*/
			
			if (selectedAdjrecType == 'Refund') {
				if (relatedOrder.Id != null && !relatedOrder.Order_Submitted__c &&relatedOrder.Payment_Type__c!='Paypal' ) { 
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'The related order is not submitted yet. Cannot create order adjustment.'));
					hasErrors = true;
					return null;
				}
				//Validating Full and partial refund line items
				if (orderAdj.Refund_Type__c == 'Partial Refund') {// atleast one item should be selected to perfomr partial refund
					boolean isLineItemSelected = false;
					for (Order_Adjustment_Line_Item__c li : adjlineItemsList) {
						if (li.IsChecked__C) {
							isLineItemSelected = true;
							break;
						}
					}
					if(!isLineItemSelected) {
						ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, PARTIAL_REFUND_NOT_POSSIBLE ));
						hasErrors = true;
						return null;
					}
				}
				if (orderAdj.Refund_Type__c == 'Full Refund') {
					boolean allLineItemSelected = true;
					for (Order_Adjustment_Line_Item__c li : adjlineItemsList) {
						if (!li.IsChecked__C) {
							allLineItemSelected = false;
							break;
						}
					}
					if (!allLineItemSelected) {
						ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, FULL_REFUND_NOT_POSSIBLE ));	 
						hasErrors = true;
						return null;
					}
				}
			}
			
			//If Errored refund adjustments are edited they should flip to approved for further processing irrespsctive of amount
			if (orderAdj.Status__c == 'Error' || orderAdj.Status__c == 'Errored') {
				orderAdj.Status__c = 'Approved';
			}
			//validating  Misc charges and credit card details
			if (selectedAdjrecType == 'Misc_Charge') {
				if (orderAdj.Payment_Method__c == 'Credit Card') {
					CreditCardValidator ccv = new CreditCardValidator();
					List <String> ccValidationErrors= new List <String>();
					ccValidationErrors = ccv.isValid(orderAdj.Credit_Card_Type__c, orderAdj.Credit_Card_Number__c, orderAdj.Credit_Card_Expiration_Date__c);
					if (!ccValidationErrors.isEmpty()) {
						for (String s:ccValidationErrors ) {
							ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, s));
							hasErrors = true;
						}
						orderAdj.Status__c = 'Incomplete';
						return null;
					}
					orderAdj.Status__c = 'Waiting for Processing';
				} else if(orderAdj.Payment_Method__c == 'Existing Card') {
					if(string.isblank(orderAdj.Related_Order_Transaction_Ref_Number__c)){
						ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Token is missing on the Order.'));
						orderAdj.Status__c = 'Incomplete';
						hasErrors = true;
						return null;
					}
					
					orderAdj.Status__c = 'Waiting for Processing';
				} else if(orderAdj.Payment_Method__c == 'Cash' || orderAdj.Payment_Method__c == 'Check') {
					
				} else {}
			}
			
			//-------------------------------------------------------------------------------------------------------
			orderAdj.Status__c = orderAdj.Status__c == null ? 'Draft' : orderAdj.Status__c;
			upsert orderAdj;
			//---------------------Related and Parent records updates ---------------------------------
			if (orderAdj.Refund_Type__c == 'Full Refund' || orderAdj.Refund_Type__c == 'Partial Refund') {
				for (Order_Adjustment_Line_Item__c oali : adjlineItemsList) {
					if (oali.Order_Adjustment__c == null) {
						oali.Order_Adjustment__c = orderAdj.id;
					}
				}
				upsert adjlineItemsList;
			}
			
			/* PageReference orderAdjPage = new PageReference('/'+orderAdj.Id);
			orderAdjPage.setRedirect(true); */
			// Order Adjustment name to rename the subtab after getting saved.
			tabName = [select Id,Name from Order_Adjustment__c where Id=:orderAdj.Id].Name;
			PageReference ref = new PageReference('/' + orderAdj.Id);
			ref.setRedirect(true);
			return ref;
		
		} catch(exception ex) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, ORDER_ADJ_NOT_CREATED+' Error:'+ex.getmessage()));	 
			hasErrors = true;
			return null;
		}
	}
	
	public void renderComponents() {
		if (recordTypeMap.isEmpty()) {
			getAdjRecTypes();
		}
		if (recordTypeMap.containsKey(orderAdj.RecordTypeId)) {// get record type Developer name
			selectedAdjrecType  = recordTypeMap.get(orderAdj.RecordTypeId);
		} else {
			selectedAdjrecType = '';
		}
		system.debug('@@@ record type name@@@'+ selectedAdjrecType );
		if (selectedAdjrecType == '') {
			showRefundFields = false;
			showMiscFields = false;
			showLineItems = false;
			return;
		}
	
		if (selectedAdjrecType == 'Refund') {
			showRefundFields = true;
		} else {
			showRefundFields = false;
		}
		
		if (selectedAdjrecType == 'Misc_Charge') {
			showMiscFields = true;
			orderAdj.Refund_Type__c = null;
			orderAdj.Return_Received_Date__c = null;
			orderAdj.Product_Return__c = null;
			
		} else {
			showMiscFields = false;
		}
	
		if (selectedAdjrecType != 'Misc_Charge' && (orderAdj.Refund_Type__c == 'Partial Refund' || orderAdj.Refund_Type__c == 'Full Refund')) {
			showLineItems = true;
			getAdjLineItems();
		} else {
			showLineItems = false;
		}
	}
}