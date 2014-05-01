public with sharing class Order_DetailsExtension {

	public boolean showInternalReviewBtn {get;set;}
	public boolean showCancelOrderBtn {get;set;}
	public boolean showEditBtn {get;set;} 
	public boolean showCloneBtn {get;set;}
	public boolean showAdminCancelBtn {get;set;}
	public boolean showBackOfficeEdit {get;set;}
	public boolean showReleaseOrder {get;set;}
	public boolean cancelSuccessful;
	public Boolean showFraudRelease {get;set;}
	public string OrderId {get;set;}
	public Orders__c orderSObj {get;set;}
	public string selectedCancelReason {get;set;}
	public List<SelectOption> cancelReasonList {get;set;}
	public string selectedReviewReason {get;set;}
	public List<SelectOption> reviewReasonList {get;set;}
	public boolean showCancelOrderPanel {get;set;}
	public boolean showInternalReviewPanel {get;set;}
	public boolean showAdminCancelSave {get;set;}
	public boolean showPreWareHouseCancel {get;set;}
	public boolean showPostWareHouseCancel {get;set;}
	public boolean showBackOrderCancel {get;set;}
	public OrderStatusQueryController statusQueryController {get;set;}
	private ApexPages.StandardController orderdetailController;
	
	private list<Order_Line_Item_Status_Detail__c> lststatus = new list<Order_Line_Item_Status_Detail__c>();

	
	public Order_DetailsExtension(ApexPages.StandardController stdController) {
		OrderId = stdController.getId();
		orderdetailController = stdController;
		statusQueryController = new OrderStatusQueryController(OrderId);
		orderSObj = (Orders__c) stdController.getRecord();
		orderSObj = [Select Id, Archived__c, Archive_summary__c, Potential_Fraud__c, Related_Bad_Address__c, Related_Bad_Email__c, OwnerId, name, Sales_Channel__c, 
						Order_Submitted__c, Order_Status__c, Order_Status_Code__c, Internal_Review_Reason__c, AS400_Cancellation_Details__c,Web_Order_ID__c, CreatedById, Customer__c, 
						Webstack_Id__c from Orders__c where id=:orderSObj.id];
		// DE880 -- incorporating the custom setting for editability.
		if (!String.IsBlank(orderSObj.Webstack_Id__c) && !WebStoresData__c.getValues(orderSObj.Webstack_Id__c).Is_Editable__c) { //orderSObj.Sales_Channel__c=='Amazon'){
		 	String sSalesChannel = WebStoresData__c.getValues(orderSObj.Webstack_Id__c).Sales_Channel__c;
		 	if (!String.IsBlank(sSalesChannel)){
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, sSalesChannel + ' orders may not be edited.'));
		 	} else {
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'Orders from this Sales Channel may not be edited.'));
		 	}
    	 }
    	 else if (orderSobj.order_submitted__c){
    	 	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'Submitted Orders cannot be edited.'));
    	 }
		string OrderId = ApexPages.currentPage().getParameters().get('Id');
		
		list<Order_Line_Item_Status_Detail__c> lststatustemp = new list<Order_Line_Item_Status_Detail__c>();
		lststatustemp = [Select Order_Status__c, Order_Status_Code__c, Current_Status_Code__c, Current_Sku__c, CreatedDate From Order_Line_Item_Status_Detail__c where Order__c =:OrderId Order by CreatedDate Desc];
		if (lststatustemp.size() > 0) {
			datetime crDate = lststatustemp[0].CreatedDate;	
			for (Order_Line_Item_Status_Detail__c templst :lststatustemp) {
				system.debug('~~~ Create DateTime:' + templst.CreatedDate);
				if (templst.CreatedDate < crDate) // Order status duplicate Scenerio.. get last run status
	 				break;
				lststatus.add(templst);
			}
		}
		resetBtns();
		cancelReasonList = new List <SelectOption>();
		cancelReasonList.add(new SelectOption ('None', '--- Select Reason ---'));
		for (Schema.PicklistEntry p : Schema.SObjectType.Orders__c.fields.getMap().get('Cancelled_Reason__c').getDescribe().getPicklistValues()) {
			cancelReasonList.add(new SelectOption(p.getLabel(), p.getValue()));
		}
		
		reviewReasonList = new List <SelectOption>();
		reviewReasonList.add(new SelectOption ('None', '--- Select Reason ---'));
		for (Schema.PicklistEntry p : Schema.SObjectType.Orders__c.fields.getMap().get('Internal_Review_Reason__c').getDescribe().getPicklistValues()) {
			reviewReasonList.add(new SelectOption(p.getLabel(), p.getValue()));
		}
		if (orderSObj.Potential_Fraud__c && checkUserProfile()) {
			showFraudRelease = true;
		} else {
			showFraudRelease = false;
		}
	}
	
	public void resetBtns() {
		showInternalReviewPanel = false;
		showCancelOrderPanel=false;
		boolean showCancel = orderUtilities.statusSetToCancel(OrderId);
		showCancelOrderBtn = showCancel; // Non submitted orders
		showPreWareHouseCancel = showCancel?false:OrderUtilities.statusSetToPreWareHouseCancel(lststatus);
		showPostWareHouseCancel = showCancel?false:OrderUtilities.statusSetToPostWareHouseCancel(lststatus);
		showBackOrderCancel = showCancel?false:OrderUtilities.statusSetToBackOrderCancel(lststatus);
		showInternalReviewBtn = orderUtilities.statusSetToInternalReview(OrderId); 
		if (orderSobj.Order_Status_Code__c == 'BO' || orderSobj.Order_Status_Code__c == 'ER') {
			showEditBtn = false;
			showCloneBtn = false;
		} else {
			showEditBtn = true;
			showCloneBtn = true;
		}
		showAdminCancelBtn = orderUtilities.checkProfile('System Administrator')||orderUtilities.checkProfile('Back-Office Team');
		showBackOfficeEdit = orderSobj.Order_Status__c!='Pending Submission' && (orderUtilities.checkProfile('System Administrator') || orderUtilities.checkProfile('Back-Office Team')); 
		if ((orderUtilities.checkProfile('System Administrator') || orderUtilities.checkProfile('Back-Office Team')) && !orderSobj.Order_Submitted__c && orderSobj.Order_Status__c == 'Internal Review') {
			showReleaseOrder = true;
		} else {
			showReleaseOrder = false;
		}
	}
	
	//reset Custom Actions Panel
	public void processCancel(){
		resetBtns();
		selectedReviewReason = 'None';
		selectedCancelReason = 'None';
	}
	
	public void processInternalReviewBtn(){
		showInternalReviewPanel = true;
		hideButtons();
	}
	
	public void processOrderCancelBtn_Admin(){
		processOrderCancelBtn();
		showAdminCancelSave=true;
	}
	
	public void processOrderPrewarehouseCancel(){
		boolean retCode = CancelOrderbyProgId('1');
	}
	
	public void processOrderPOSTwarehouseCancel(){
		boolean retCode = CancelOrderbyProgId('3');
	}
	
	public void processOrderBackOrderCancel(){
		boolean retCode = CancelOrderbyProgId('2');
	}
	
	public void processOrderCancelBtn(){
		showCancelOrderPanel = true;
		hideButtons();
	}
	
	public static Boolean checkUserProfile() {
		Id userId = UserInfo.getProfileId();
		String pName = [SELECT Name FROM Profile WHERE Id = :userId].Name;
		if (pName == 'System Administrator' || pName == 'Back-Office Team') {
			return true;
		} else {
			return false;
		}
	}
	
	public pageReference processBackOfficeEdit() {
		PageReference pageRef = new PageReference( '/'+OrderId + '/e?retURL=%2F' + OrderId+ '&override=1');
		pageRef.setRedirect(true);
		return pageRef;
	}
	
	public pageReference processReleaseOrder() {
		orderSObj.Order_Status__c='Pending Submission';
		update orderSObj;
		PageReference pageRef = new PageReference( '/'+OrderId );
		pageRef.setRedirect(true);
		return pageRef;
	}
	
	public pageReference releasePotentialFraud() {
		Set<Id> bcSet = new Set<Id>{orderSObj.Related_Bad_Address__c, orderSObj.Related_Bad_Email__c};
		List<Bad_Customer__c> bdCustList = [SELECT Id, isActive__c FROM Bad_Customer__c WHERE Id IN :bcSet];
		for (Bad_Customer__c bc : bdCustList) {
			bc.isActive__c = false;
		}
		update bdCustList;
		orderSObj.Order_Status__c='Pending Submission';
		orderSObj.Potential_Fraud__c = false;
		orderSObj.Related_Bad_Address__c = null;
		orderSObj.Related_Bad_Email__c = null;
		orderSObj.OwnerId = orderSObj.CreatedById;
		update orderSObj;
		Account acct = [SELECT Id, Possible_Fraud__c FROM Account WHERE Id = :orderSObj.Customer__c];
		acct.Possible_Fraud__c = false;
		update acct;
		PageReference pageRef = new PageReference( '/'+OrderId );
		pageRef.setRedirect(true);
		return pageRef;
	}
	
	public void hideButtons() {
		showEditBtn = false;
		showCloneBtn = false;
		showInternalReviewBtn = false;
		showCancelOrderBtn = false;
		showAdminCancelBtn = false;
		showBackOfficeEdit = false;
		showReleaseOrder = false;
	}
	
	public void saveCancelOrder() {
		if(selectedCancelReason == 'None') {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Please enter a order cancellation reason'));
		} else {
			resetBtns();
			cancelSuccessful=OrderUtilities.processOrderCancel(OrderId,selectedCancelReason);
		}
	}
	
	public void saveCancelOrder_Admin() {
		saveCancelOrder();
		if (!cancelSuccessful) {
			OrderUtilities.forceCancel(OrderId, selectedCancelReason);
		}
	}
	
	private boolean CancelOrderbyProgId(string ProgramId) {
		if(selectedCancelReason == 'None') {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Please enter a order cancellation reason'));
		}
		boolean retCode = false;
		try{
			WS_OrderLineItemCancellation.CancelOrderPort wsCancelOrder = new WS_OrderLineItemCancellation.CancelOrderPort();
			WS_OrderLineItemCancellation.OrderCancellationResponse_element cancelResponse = new WS_OrderLineItemCancellation.OrderCancellationResponse_element();
			system.debug('~~~~~~~~~~~~~~~ Entered here');
			string SFDCOrderNumber = string.isNotBlank(orderSObj.Web_Order_ID__c) ? orderSObj.Web_Order_ID__c : orderSObj.Name ;
			SFDCOrderNumber = orderutilities.zeroLPAD(SFDCOrderNumber, 10);
			cancelResponse = wsCancelOrder.CancelOrder(SFDCOrderNumber, SFDCOrderNumber, ProgramId, '', '', '', '' , selectedCancelReason,'' , '');
			//process response
			if (cancelResponse.Status != 'Success') {
				retCode = false;
				ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Error Cancelling order: ' + cancelResponse.StatusCode + '-'+ cancelResponse.StatusMessage ));
			} else {
				retCode = true;
			}
		} catch(exception e) {
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Error invoking cancellation web service'));
			system.debug('--------Error invoking cancellation Web Service' + e.getmessage());
			
		}
		return retcode;
	}
	
	
	public void saveInternalReview(){
		if (selectedReviewReason == 'None') {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Please enter a internal review reason'));
		} else {
			resetBtns();
			OrderUtilities.processInternalReview(OrderId, selectedReviewReason);
		}
	}
}