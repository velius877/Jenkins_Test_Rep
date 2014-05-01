/* Order_EditOverride.cls
*  2014-01-30:  Added more fields to orderObj soql query/ Pavan Jasthi
*/
public   class Order_EditOverride {
	private ApexPages.StandardController ctrl;
	public	Orders__c orderObj {get;set;}
	// DE864 -- Allowing Pending Submission orders to be edited
	public static set <String> csrEditableOrderSet = new Set <String>{'Open','Pending Submission','Awaiting Authorization', 'Rejected'};
	public static set <String> nonCsrEditableOrderSet = new Set <String>{'Open','Internal Review','Awaiting Physical Payment','Pending Submission','Awaiting Authorization', 'Rejected','Awaiting Approval'};
	public static set <String> nonEditableSalesChannelSet   = new Set <String> {'Amazon'};
	public static set <String> csrWipeOrderSet = new Set <String>{'Pending Submission'};
	public static set <String> nonCsrWipeOrderSet = new Set <String>{'Pending Submission','Submission Failed'};
	public static boolean canReverseAuth;
	public	boolean isClone ;
	public	boolean isNew ;
	public boolean isMail;
	public boolean isEditOverride;
	public string ProdId;
	public String redirectStr {get;set;}
	public string orderName {get;set;}
	private boolean canUseMailOrderWizard {get; set;}
	public Map<Id, Profile> profileMap {get; set;}
	//public Boolean noTabClose {get;set;}
	
	public Order_EditOverride(ApexPages.StandardController stdController){
		//noTabClose = false;
		redirectStr = '';
		isClone = ApexPages.currentPage().getParameters().get('clone')!=null;
		isMail = ApexPages.currentPage().getParameters().get('mo')!=null;
		isNew = ApexPages.currentPage().getParameters().get('CustId')!=null;
		isEditOverride = ApexPages.currentPage().getParameters().get('override')!=null;
		ProdId = ApexPages.currentPage().getParameters().get('prodId');
		ctrl = stdController;
		Orders__c temporder  = (Orders__c) ctrl.getRecord();
		if (!isNew) {
			// DE643 -- Added fields for pull order items to query for cloning to copy correctly.
			orderObj = [Select Ship_To_Address__c, Bill_To_Address__c, Payment_Profile_Id__c, Credit_Card_Expiration_Date__c, Credit_Card_Token__c ,Credit_card_type__c, Id, Name, Customer__c, Order_Status__c, Sales_Channel__c, Payment_Type__c, Archive_Summary__c, webstack_id__c, pull_order__c, pull_order_reason_multi__c, gift_order__c, future_order__c, ship_complete__c, pull_order_reason_other__c, future_order_date__c,Ship_to_First_Name__c,Ship_to_Last_Name__c,Source_Code__c, Promotions__c From Orders__c where Id =: temporder.Id ];
			orderName = orderObj.name;
			canReverseAuth=orderObj.Payment_Type__c=='Credit Card';
			if(orderObj.Sales_Channel__c == 'Mail')
				isMail = true;
		}
		

	}
	public Orders__c createOrder(Id custId){
		Account customer = [select id, no_peanuts__c, Substitutes__c, No_Catalogs__c, No_Invoices__c, Ship_Complete__c from Account where id =:custId];
		Orders__c newOrder = new Orders__c(Customer__c =customer.id, Pull_Order__c = (customer.No_Catalogs__c ||  customer.No_Peanuts__c || !customer.Substitutes__c || customer.No_Invoices__c || customer.Ship_Complete__c) , No_Catalogs__c = customer.No_Catalogs__c, No_Peanuts__c=customer.No_Peanuts__c,No_Substitutes__c=!customer.Substitutes__c, No_Invoice__c=customer.No_Invoices__c, ship_complete__c = customer.Ship_Complete__c );
		system.debug('*****ismail ' + isMail);
		if(isMail)
			newOrder.Sales_Channel__c = 'Mail';
		insert newOrder;
		orderName =[select name from orders__c where id=:newOrder.id].name;
		return newOrder;
	}
	
	public static boolean  isEditOverride(Orders__c orderObj){
		if ( OrderUtilities.checkProfile('System Administrator')||OrderUtilities.checkProfile('Back-Office Team')){ 
			//return !nonEditableSalesChannelSet.contains(orderObj.sales_channel__c); //check is configured set contains status; return true/false
			// DE880 -- use new function
			return OrderUtilities.CanEditSalesChannel(orderObj.Webstack_Id__c);
		}
		else {
			return false;
		}
	}
	
	public static boolean  isEditableOrder(Orders__c orderObj){
		// DE880 -- use new function to block editing where needed
		if (OrderUtilities.checkProfile('CSR')){ 
			return csrEditableOrderSet.contains(orderObj.order_status__c)&&OrderUtilities.CanEditSalesChannel(orderObj.Webstack_Id__c);//!nonEditableSalesChannelSet.contains(orderObj.sales_channel__c); //check is configured set contains status; return true/false
		}
		else {
			return nonCsrEditableOrderSet.contains(orderObj.order_status__c)&&OrderUtilities.CanEditSalesChannel(orderObj.Webstack_Id__c);//!nonEditableSalesChannelSet.contains(orderObj.sales_channel__c);
		}
	}
	
	public static boolean isWipeOrder(Orders__c orderObj){
		if (OrderUtilities.checkProfile('CSR')){
			return canReverseAuth&&csrWipeOrderSet.contains(orderObj.order_status__c)&&!nonEditableSalesChannelSet.contains(orderObj.sales_channel__c); //check is configured set contains status; return true/false
		}
		else {
			return canReverseAuth&&nonCsrWipeOrderSet.contains(orderObj.order_status__c)&&!nonEditableSalesChannelSet.contains(orderObj.sales_channel__c);
		}
	}
	
	public void redirect(){

		if (isNew){  //New order
			Orders__c newOrder =createOrder(ApexPages.currentPage().getParameters().get('CustId'));
			if (ProdId!=null){
				redirectStr = '/apex/OrderWizard?id='+newOrder.Id+'&prodId='+ProdId;
			}
			else if(isMail) //New Mail Order
			{
				redirectStr = '/apex/OrderWizardMailOrders?id='+newOrder.Id;

			}
			else {
				redirectStr = '/apex/OrderWizard?id='+newOrder.Id;
			}
		}
		else if (isClone){ //Clone order
			Orders__c newOrder =orderObj.clone(false,false,false,false);
			newOrder.order_status__c='Open';
			newOrder.sales_channel__c= isMail? 'Mail':'Phone';
			try {
			insert newOrder;
			}
			catch (exception e){
				if (e.getMessage().contains('USPS')){
					newOrder.Shipping_Method__c = 'USPS';
				}
				try {
					insert newOrder;
				}
				catch (exception et){
					  ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,et.getMessage()));
				}
			}
			// DE606 -- Cloned orders were not displaying new order number. this let's them.
			orderName = [select name from orders__c where id=:newOrder.id].name;
			
			List <Order_Line_Items__c> oliList =    [SELECT Id, Product_Name__c, Product_Quantity__c, Original_Quantity__c, Product_Number__c, Price_Override__c, Override_Reason__c, Unit_Price__c, Final_Price__c, Tax__c  
																				FROM 	Order_Line_Items__c 
																				WHERE 	order__c=:orderObj.id
																				AND		Product_name__r.is_active__c=true//possibility products may not be active anymore
																				];
			if (oliList.size() == 0){
				try {
					oliList = OrderLineItemArchiveUtilities.restoreOlisFromArchive(orderObj);
				}
				catch (exception e){
					system.debug('Cannot restore from archive');
				}
			}
			if (oliList!=null){
				oliList = oliList.deepClone(false, false, false);
				for (Order_Line_Items__c oli: oliList){
					oli.order__c = newOrder.id;
				}
				insert oliList;
			}
			// DE884 -- Was allowing CSR to use Mail Order through cloning only
			canUseMailOrderWizard = false;
			// Get current user Id
			String userId = [Select Id from User where Name =: userInfo.getName()].Id;
			// Get Mail Order Permission set Id
			PermissionSet ps = [Select Id from PermissionSet where Name = 'Mail_Order'];
			// See if this user is in the PermissionSetAssignment list
			List<PermissionSetAssignment> psa = [Select Id from PermissionSetAssignment where PermissionSetId =: ps.Id and AssigneeId =: userId];
			// if the list found 1 (or more?) they can edit			
			if (psa.size() > 0) {
				canUseMailOrderWizard = true;
			}
			// DE884 -- update to DE863 
			// DE863 -- Allow cloning of mail order to open in mail order wizard right away
			if (isMail && canUseMailOrderWizard){
				redirectStr = '/apex/OrderWizardMailOrders?Id=' + newOrder.Id;
			} else {
				redirectStr = '/apex/OrderWizard?id='+newOrder.Id;
			}
			orderObj = newOrder;
		}
		else if (isEditOverride) {
			if (isEditOverride(orderObj)){
				//notabClose = true;
				redirectStr = '/'+orderObj.id + '/e?retURL=%2F' + orderObj.id + '&nooverride=1';
			}
		} // Mail order change
		else if(isMail) //Edit
		{
			if(orderutilities.isUserForMailOrder())
				redirectStr = '/apex/OrderWizardMailOrders?Id='+orderObj.Id;
			 else // Error
				ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'User not authorized to edit Mail Order. \n Please contact System Admin.'));
			
		}
		else {//edit order to determine edit page to show
			if (isEditableOrder(orderObj)){
				redirectStr = '/apex/OrderWizard?Id='+orderObj.Id;
			}
			else if (isWipeOrder(orderObj)){ //reverse auth and wipe payment details for web order; set as phone order
				redirectStr = '/apex/OrderWizard?Id='+orderObj.Id+'&reverse=1';
			}
			else {
				redirectStr = '/apex/Order_Detail?id='+orderObj.id;
			}
		}
	//	PageReference pageRef = new PageReference( redirectStr);
	//	pageRef.setRedirect(true);
	//	return pageRef;
	}
}