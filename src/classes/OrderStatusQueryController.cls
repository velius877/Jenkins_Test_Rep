/*
	OrderStatusQueryController
	DESCRIPTION
	------------------------------------------------------------------
	Author		|	Date		|	Description
	------------------------------------------------------------------
	Gary Alfrey |	10/14/13	|	Created

*/

public class OrderStatusQueryController {
	
	private static final String BO = 'BO';
	private static final String ER = 'ER';
	private static final String VW = 'Vitamin_World_Customer';
	private static final String CNTY = 'UNITED STATES';
	public Orders__c ord {get;set;}
	public Order_Line_Item_Status_Detail__c olisd {get;set;}
	public List<Order_Line_Item_Status_Detail__c> ordStatusDetails {get;set;}
	public List<SelectOption> cancelReasonList {get;set;}
	public List<SelectOption> DispositionList {get;set;}
	public List<SelectOption> clearOptions {get;set;}
	public Boolean showResults {get;set;}
	public Boolean showError {get;set;}
	public Boolean showSnippet {get;set;}
	public Boolean noCallout {get;set;}
	public Boolean isStart {get;set;}
	public Boolean showAdminCancelSave {get;set;}
	public Boolean showPreWareHouseCancel {get;set;}
	public Boolean showPostWareHouseCancel {get;set;}
	public Boolean showBackOrderCancel {get;set;}
	public Boolean showCancelOrderBtn {get;set;}
	public Boolean showCancelOrderPanel {get;set;}
	public Boolean showCancelOrderDisposition {get;set;}
	public Boolean showTable {get;set;}
	public Boolean showClearButton {get;set;}
	public Boolean showClearCancel {get;set;}
	public Boolean cancelCloneNewTab {get;set;}
	public String selectedDisposition {get;set;}
	public String selectedCancelReason {get;set;}
	public String selectedClearOption {get;set;}
	public String newTabStr {get;set;}
	public String redirectStr {get;set;}
	public String trackingStr {get;set;}
	public OSQResponse rawResponse {get;set;}
	public faultWrapper fault {get;set;}
	private String status {get;set;}
	private String orderId {get;set;}
	private WS_OrderStatusQuery.OrderStatusQueryResponse_element response_Element {get;set;}
	private String ProgramID = '';
	private Boolean isDupe;
	
	public OrderStatusQueryController(ApexPages.StandardController controller) {
		orderId = controller.getId();
		system.debug('-------------------------------------OrderId: ' + orderId);
		ord = [SELECT Id, Last_Status_Update__c,Archived__c, Archive_summary__c, name, Sales_Channel__c, Order_Submitted__c, Order_Status__c, 
				Internal_Review_Reason__c, AS400_Cancellation_Details__c, Web_Order_ID__c, Webstack_Order_ID__c, Webstack_ID__c, Customer__r.RecordType.DeveloperName, Customer__r.VW_Passport_Number__c, 
				Customer__r.AS_400_Customer_Number__c, Bill_To_Address__r.Address_Line_1__c, Bill_To_Address__r.Address_Line_2__c, Bill_To_Address__r.Address_Line_3__c, 
				Bill_To_Address__r.Address_Line_4__c, Bill_To_Address__r.Country_Picklist__c, Bill_To_Address__r.State_Providence__c, Bill_To_Address__r.Country__c, 
				Bill_To_Address__r.City__c, Bill_To_Address__r.Foreign_Postal_Code__c, Bill_To_Address__r.Zip_Code__c, Valid_Duplicate__c FROM Orders__c WHERE Id = :orderId];
		showResults = false;
		showError = false;
		isStart=true;
		showTable = true;
		showClearButton = false;
		cancelCloneNewTab = false;
		//isDupe = false;
		setNewTabString();
	}
	
	public OrderStatusQueryController(Id OrdId) {
		orderId =ordId;
		system.debug('-------------------------------------OrderId: ' + orderId);
		ord = [SELECT Id, Last_Status_Update__c,Archived__c, Archive_summary__c, name, Sales_Channel__c, Order_Submitted__c, Order_Status__c, 
				Internal_Review_Reason__c, AS400_Cancellation_Details__c, Web_Order_ID__c, Webstack_Order_ID__c, Webstack_ID__c, Customer__r.RecordType.DeveloperName, Customer__r.VW_Passport_Number__c, 
				Customer__r.AS_400_Customer_Number__c, Bill_To_Address__r.Address_Line_1__c, Bill_To_Address__r.Address_Line_2__c, Bill_To_Address__r.Address_Line_3__c, 
				Bill_To_Address__r.Address_Line_4__c, Bill_To_Address__r.Country_Picklist__c, Bill_To_Address__r.State_Providence__c, Bill_To_Address__r.Country__c, 
				Bill_To_Address__r.City__c, Bill_To_Address__r.Foreign_Postal_Code__c, Bill_To_Address__r.Zip_Code__c, Valid_Duplicate__c FROM Orders__c WHERE Id = :orderId];
		
		cancelReasonList = new List <SelectOption>();
		cancelReasonList.add(new SelectOption ('None', '--- Select Reason ---'));
		for (Schema.PicklistEntry p : Schema.SObjectType.Orders__c.fields.getMap().get('Cancelled_Reason__c').getDescribe().getPicklistValues()) {
			cancelReasonList.add(new SelectOption(p.getLabel(), p.getValue()));
		}
		
		showSnippet = (ord.Order_Submitted__c /*&& ord.Order_Status__c != 'Shipped/Complete'*/) ? true :false;
		showResults = false;
		showError = false;
		isStart=true;
		showTable = true;
		showClearButton = false;
		showClearCancel = false;
		cancelCloneNewTab = false;
		//isDupe = false;
		setNewTabString();
	}
	
	public void init() {
		isStart=false;
		if (showSnippet) {
			response_Element = new WS_OrderStatusQuery.OrderStatusQueryResponse_element();
			response_Element = WS_OrderStatusQueryUtils.doCallout(orderId);
			
			clearOptions = new List<SelectOption>();
			clearOptions.add(new SelectOption ('None', '--- Select Option ---'));
			clearOptions.add(new SelectOption ('Resubmit', 'Resubmit'));
			clearOptions.add(new SelectOption ('Cancel', 'Cancel'));
			if (ord.Webstack_ID__c != '18' && ord.Webstack_ID__c != '45' && ord.Webstack_ID__c != '47') {
				clearOptions.add(new SelectOption ('CancelClone', 'Cancel & Clone'));
			}
			if (ord.Customer__r.RecordType.DeveloperName == VW) {
				clearOptions.add(new SelectOption ('BadBill', 'Update Billing Info & Resubmit'));
			}
			
			if (response_Element.OrderStatusSuccess != null) {
				buildWrapper(response_Element.OrderStatusSuccess);
				system.debug('---------------------------------------------------------Success');
				ordStatusDetails = WS_OrderStatusQueryUtils.processSuccess(response_Element.OrderStatusSuccess);
				if (ordStatusDetails != null) {
					Set<String> olisdIds = new Set<String>();
					for (Order_Line_Item_Status_Detail__c a : ordStatusDetails) {
						olisdIds.add(a.Id);
						if ((a.Order_Status_Code__c == BO || a.Order_Status_Code__c == ER) && checkUserProfile()) {
							showClearButton = true;
						}
						if (a.Order_Status_Description__c == 'DUPLICATE CUSTOMER ORDER') {
							isDupe = true;
						} else {
							isDupe = false;
						}
					}
					OrderStatusQueryUtils.processUpdates(olisdIds);
					olisd = ordStatusDetails[0];
					if (ordStatusDetails.size() < 2 && ordStatusDetails[0].Order_Line_Item__c == null) {
						showTable = false;
					}
					showResults = true;
					showError = false;
					//setPageMessages('SUCCESS!');
					/*****************Code moved here**************************
					cancelReasonList = new List <SelectOption>();
					cancelReasonList.add(new SelectOption ('None', '--- Select Reason ---'));
					for (Schema.PicklistEntry p : Schema.SObjectType.Orders__c.fields.getMap().get('Cancelled_Reason__c').getDescribe().getPicklistValues())
					{
						cancelReasonList.add(new SelectOption(p.getLabel(), p.getValue()));
					}
					***************************END**************************/
					ShowCancelOrderButtons();
					
				} else {
					showResults = false;
					showError = false;
					setPageMessages('Status Updates Not Available.');
				}
				
			} else if (response_Element.OrderStatusFault != null) {
				system.debug('---------------------------------------------------------Failure');
				showError = true;
				showResults = false;
				WS_OrderStatusQuery.OrderStatusSuccess oss = new WS_OrderStatusQuery.OrderStatusSuccess();
				oss.OrderStatus = response_Element.OrderStatusFault.FaultCode;
				oss.OrderStatusDetail = response_Element.OrderStatusFault.FaultMessage;
				oss.SFOrderNumber = ord.Name;
				List<WS_OrderStatusQuery.LineItem> aList = null;
				WS_OrderStatusQuery.LineItemList lineItemList = new WS_OrderStatusQuery.LineItemList();
				lineItemList.LineItem = aList;
				oss.LineItemList = lineItemList;
				List<Order_Line_Item_Status_Detail__c> xp = WS_OrderStatusQueryUtils.processSuccess(oss);
				system.debug('---------------------------------------------------------xp: ' + xp);
				if (xp != null) {
					Set<String> olisdIds = new Set<String>();
					for(Order_Line_Item_Status_Detail__c a : xp){
						olisdIds.add(a.Id);
					}
					OrderStatusQueryUtils.processUpdates(olisdIds);
				}
				fault = new faultWrapper(response_Element.OrderStatusFault);
				system.debug('---------------------------------------------------------fault: ' + fault);
			}
		} else {// Order not submiited
			showCancelOrderBtn = ord.order_status__C != 'Cancelled';
			showCancelOrderPanel = false;
			
		}
	}
	
	public class faultWrapper {
		public String code {get;set;}
		public String msg {get;set;}
		public faultWrapper(WS_OrderStatusQuery.OrderStatusFault f) {
			code = f.FaultCode;
			msg = f.FaultMessage;
		}
	}
	
	public void buildWrapper(WS_OrderStatusQuery.OrderStatusSuccess resp) {
		rawResponse = new OSQResponse(resp);
	}
	
	public class OSQResponse {
		public String SFOrderNumber {get;set;} 
		public OSQResponse(WS_OrderStatusQuery.OrderStatusSuccess resp) {
			SFOrderNumber = resp.SFOrderNumber;
		}
	}
	
	public void processOrderPrewarehouseCancel() {
		if (!showCancelOrderPanel) {
			showCancelOrderPanel = true;
			ProgramID = '1';
			showPreWareHouseCancel = false;
			return;
		}
		/*boolean retCode = CancelOrderbyProgId('1');
		if(retCode)
		{
		//resetButtons(showPreWareHouseCancel);
		showPreWareHouseCancel = false;
		showCancelOrderPanel = false;
		}*/
	}
	
	public void processOrderPOSTwarehouseCancel() {
		if (!showCancelOrderPanel) {
			showCancelOrderPanel = true;
			showPostWareHouseCancel = false;
			showCancelOrderDisposition = true;
			ProgramID = '3';
			return;
		}
		/*if(selectedDisposition == 'None'){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Please select disposition.'));
   
		}
		else{
		boolean retCode = CancelOrderbyProgId('3');
			if (retCode) {
				//resetButtons(showPostWareHouseCancel);
				showPostWareHouseCancel = false;
				showCancelOrderPanel = false;
				
			}
		} */
	}
	
	public void ProcessAllOrderCancelSave(){
		
		if(selectedCancelReason == 'None') {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Please select order cancellation reason'));
			return;
		}
		
		if (ProgramID == '3') {
			if (selectedDisposition == 'None') {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Please select disposition.'));
			return;}
		}
		
		boolean retCode = CancelOrderbyProgId(ProgramID);
		if (retCode) {
			showCancelOrderPanel = false;
		}
	}
	
	public void ProcessAllOrderCancelCancel() {
		showCancelOrderPanel = false;
		IF(ProgramID == '3')showPostWareHouseCancel = true;
		IF(ProgramID == '2')showPreWareHouseCancel = true;
		
		
	}
	
	public void processOrderBackOrderCancel() {
		if (!showCancelOrderPanel) {
			showCancelOrderPanel = true;
			return;
		}
		boolean retCode = CancelOrderbyProgId('2');
		if (retCode)
			resetButtons(showBackOrderCancel);
	}
	
	public void processOrderCancelBtn() {
		if (!showCancelOrderPanel) {
			showCancelOrderPanel = true;
			return;
		}
		if (selectedCancelReason == 'None') {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Please enter a order cancellation reason'));
		} else {
			boolean cancelSuccessful=OrderUtilities.processOrderCancel(OrderId,selectedCancelReason);
			if (cancelSuccessful) {
				resetButtons(showCancelOrderBtn);
				showCancelOrderPanel = false;
			}
		}	
	}
	
	private boolean CancelOrderbyProgId(string ProgramId) {
		boolean retcode = false;
		try {
			// DE DE806 string SFDCOrderNumber = string.isNotBlank(ord.Web_Order_ID__c) ? ord.Web_Order_ID__c : ord.Name ;
			string SFDCOrderNumber = orderutilities.zeroLPAD(ord.Name, 10);
			WS_OrderLineItemCancellation.OrderCancellationResponse_element cancelResponse = new WS_OrderLineItemCancellation.OrderCancellationResponse_element();
			cancelResponse = soa_WebservicesClientUtil.CancelOrderbyProgId(ProgramId, SFDCOrderNumber, selectedCancelReason, selectedDisposition);
			//CancelOrder(String SFDCOrderNumber,String OrderNumber,String ProgramID,String Date_x,String SKU,String SKUPrefix,String Quantity,String Reason,String Alias,String DispositionNumber)
			//process response
			if (cancelResponse.Status != 'Success') {
				retCode = false;
				ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Error Cancelling order: ' + cancelResponse.StatusCode + '-'+ cancelResponse.StatusMessage ));
			} else {
				ord.Cancelled_Reason__c = selectedCancelReason;
				ord.Order_Status__c = 'Cancelled';
				update ord;
				ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, 'Order Successfully Cancelled'));
				retCode = true;
			}
		}
		catch (exception e) {
			retCode = false;
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Error invoking cancellation web service'));
			system.debug('--------Error invoking cancellation Web Service' + e.getmessage());
		}
		
		return retcode;
	}
	
	public void setPageMessages(String msg) {
		ApexPages.Message pageMsg = new ApexPages.Message(ApexPages.Severity.INFO, msg);
		ApexPages.AddMessage(pageMsg);
	}
	
	public void setPageMessagesError(String msg) {
		ApexPages.Message pageMsg = new ApexPages.Message(ApexPages.Severity.ERROR, msg);
		ApexPages.AddMessage(pageMsg);
	}
	
	private void resetButtons(boolean showButton) {
		showButton = false;
		
		//showCancelOrderPanel = showPreWareHouseCancel || showPostWareHouseCancel || showBackOrderCancel || showCancelOrderBtn;
		
	}
	
	private void ShowCancelOrderButtons() {
		//ordStatusDetails
		boolean showCancel = orderUtilities.statusSetToCancel(OrderId);
		boolean isUserCSR = orderUtilities.checkProfile('CSR');
		showCancelOrderBtn = showCancel; // Non submitted non cancelled orders
		system.debug('---- Show Cancel --' + showCancelOrderBtn);
		set<string> dispositionSet = new set<string>();
		list<string> dispositionTempList = new list<string>();
		
		system.debug('-----------------Order Status Detail' + ordStatusDetails);
		// If not submitted then no pre, post and back order cancellation.
		showPreWareHouseCancel= showCancel?false:OrderUtilities.statusSetToPreWareHouseCancel(ordStatusDetails);
		showPostWareHouseCancel= (showCancel || !orderUtilities.isUserForPostWarehouseCancel())?false:OrderUtilities.statusSetToPostWareHouseCancel(ordStatusDetails);
		// DE 797 dont show this button showBackOrderCancel= showCancel?false:OrderUtilities.statusSetToBackOrderCancel(ordStatusDetails);
		showBackOrderCancel = false; 
		showCancelOrderPanel = false;
		//showCancelOrderPanel = showPreWareHouseCancel || showPostWareHouseCancel || showBackOrderCancel;
		
		
		DispositionList = new List <SelectOption>();
		if(showPostWareHouseCancel){
			DispositionList.add(new SelectOption ('none','--Select Disposition--'));
			if(showResults){  // Some data in ordStatusDetails
				for(Order_Line_Item_Status_Detail__c ols :ordStatusDetails){
					dispositionSet.add(ols.Disposition_Number__c);
					//DispositionList.add(new SelectOption (ols.Disposition_Number__c,ols.Disposition_Number__c));
				}
				dispositionTempList.addall(dispositionSet);
				dispositionTempList.sort();
				for(string s :dispositionTempList)
					DispositionList.add(new SelectOption (s,s));
			}
		}
	}
	
	public void startClearService() {
		Boolean isBadBill = false;
		ws_Soa_Loyalty_UpdateBillingInfo.updateBillingInformationResponse resp = new ws_Soa_Loyalty_UpdateBillingInfo.updateBillingInformationResponse();
		if (selectedClearOption == 'Resubmit' || selectedClearOption == 'badBill') {
			try {
				WS_soa_ClearOrderService.ER_BO_Response_element response = new WS_soa_ClearOrderService.ER_BO_Response_element();
				response = soa_WebservicesClientUtil.ClearERBOByOrderNumber(orderutilities.zeroLPAD(WS_soa_SendOrderService_v2_Utils.returnSequenceNumber(ord), 10));//
				setPageMessages(response.statusMessage);
				if (response.status == 'Success') {
					system.debug('--------------------------------------------------isDupe: ' + isDupe);
					if (isDupe) {
						system.debug('--------------------------------------------------INSIDE Dupe Code: ');
						//if the order fails as a duplicate but is valid and the order is cleared, set flad for resubmit
						ord.Valid_Duplicate__c = true;
						update ord;
					}
					if (selectedClearOption == 'badBill') {
						isBadBill = true;
						resp = updateBillTo();
					}
					if (isBadBill) {
						if (resp.success == 'T') {
							setPageMessages('Billing Info Successfully Updated');
							setPageMessages('Order placed in pending submission');
							showClearButton = false;
							ord.Order_Status__c = 'Pending Submission';
							ord.Order_Submitted__c = false;
							update ord;
						} else if (resp.success == 'F') {
							setPageMessages(resp.detailMsg);
						}
					} else {
						setPageMessages('Order placed in pending submission');
						showClearButton = false;
						ord.Order_Status__c = 'Pending Submission';
						ord.Order_Submitted__c = false;
						update ord;
					}
					
				}//else do nothing
				
			} catch (exception e) {
				setPageMessagesError('An unknown error has occurred, please contact your System Administrator.');
			}
			
		} else if (selectedClearOption == 'Cancel') {
			showClearButton = false;
			showClearCancel = true;
			
			
		} else if (selectedClearOption == 'CancelClone') {
			showClearButton = false;
			showClearCancel = true;
			
			
		} else if (selectedClearOption == 'None') {
			setPageMessages('You must select a clear option');
		}
		
	}
	
	public ws_Soa_Loyalty_UpdateBillingInfo.updateBillingInformationResponse updateBillTo() {
		String state;
		String province;
		String zip;
		String addLine4;
		String country;
		system.debug('--------------------------------------------------ord.Bill_To_Address__r.Foreign_Postal_Code__c: ' + ord.Bill_To_Address__r.Foreign_Postal_Code__c);
		system.debug('--------------------------------------------------ord.Bill_To_Address__r.Zip_Code__c: ' + ord.Bill_To_Address__r.Zip_Code__c);
		system.debug('--------------------------------------------------ord.Bill_To_Address__r.Country_Picklist__c: ' + ord.Bill_To_Address__r.Country_Picklist__c);
		if (ord.Bill_To_Address__r.Country_Picklist__c == CNTY) {
			system.debug('---------------------------Inside US');
			country = 'US';
			state = ord.Bill_To_Address__r.State_Providence__c;
			zip = ord.Bill_To_Address__r.Zip_Code__c;
			system.debug('---------------------------ZIP: ' + zip);
		} else {
			system.debug('---------------------------Outside US');
			province = ord.Bill_To_Address__r.State_Providence__c;
			zip = ord.Bill_To_Address__r.Foreign_Postal_Code__c;
		}
		
		ws_Soa_Loyalty_UpdateBillingInfo.updateBillingInformationResponse response = new ws_Soa_Loyalty_UpdateBillingInfo.updateBillingInformationResponse();
		response = WS_SOA_LoyaltyServicesUtils.updateBillInfoCallout(ord.Customer__r.AS_400_Customer_Number__c, ord.Customer__r.VW_Passport_Number__c, ord.Bill_To_Address__r.Address_Line_1__c, 
							ord.Bill_To_Address__r.Address_Line_2__c, ord.Bill_To_Address__r.City__c, addLine4, ord.Bill_To_Address__r.Country__c, state, province, zip);
		return response;
	}
	
	public void finishClearService() {
		if (selectedClearOption == 'None') {
			setPageMessages('You must select a clear option');
		} else {
			try {
				WS_soa_ClearOrderService.ER_BO_Response_element response = new WS_soa_ClearOrderService.ER_BO_Response_element();
				//response = temp_Release3MockServices.mockERBOService(ord.Name);
				response = soa_WebservicesClientUtil.ClearERBOByOrderNumber(orderutilities.zeroLPAD(WS_soa_SendOrderService_v2_Utils.returnSequenceNumber(ord), 10));
				setPageMessages(response.statusMessage);
				
				if (response.status == 'Success') {
					showClearButton = false;
					showClearCancel = false;
					ord.Order_Status__c = 'Cancelled';
					ord.Cancelled_Reason__c = selectedCancelReason;
					ord.Order_Submitted__c = false;
					update ord;
					//Clone the order if cancelClone was chosen
					if (selectedClearOption == 'cancelClone') {
						cancelCloneNewTab = true;
					}
				} else {
					showClearButton = true;
					showClearCancel = false;
				}
				
			} catch (exception e) {
				setPageMessagesError('An unknown error has occurred, please contact your System Administrator.');
			}
			
		}
		
	}
	
	public void setNewTabString() {
		// /apex/Order_EditOverride?clone=1
		newTabStr = '/apex/Order_EditOverride?clone=1&id=' + ord.Id;
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
	
	public void setTrackingUrl() {
		system.debug('------------------------------------------------------inside Tracking Method: ' + redirectStr);
		//trackingStr = redirectStr;
	}
	
}