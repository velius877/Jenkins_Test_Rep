public with sharing class OrderLineItemCancelController {
  
  public Order_Line_Items__c OrderlineItem            {get;set;}
  
  public string OrderId         {get;set;}
  public string orderName {get;set;}
  public boolean showCancelOrderBtn {get;set;}
  public boolean showCancelOrderReason {get;set;}
  public string selectedCancelReason {get;set;}
  public List<SelectOption> cancelReasonList {get;set;}
  public list<Order_Line_Items__c> lstOrderLineItem{get;set;}
  private static string PROGRAM_ID = '2';
  
  
            
 
  public  OrderLineItemCancelController(ApexPages.StandardController stdController)
      {        
         OrderId = stdController.getId();
         list<id> lstOrderLineItemid = new list<id>();
         OrderlineItem = [Select Name,Product_Number__c, Original_Quantity__c, Item_Status_Code__c,Item_Status__c, Order__r.Web_Order_ID__c,Order__r.Order_Status__c, Order__r.Name, Order__c, Item_Suffix__c,Product_Quantity__c From Order_Line_Items__c where Id =:OrderId];
      	 orderName = OrderlineItem.name;
      	 showCancelOrderBtn = false;
      	 showCancelOrderReason = false;
      	 if(renderCancel())
      	 {
      	 	showCancelOrderBtn = true;
      	 	cancelReasonList = new List <SelectOption>();
      	 	cancelReasonList.add(new SelectOption ('None', '--- Select Reason ---'));
    		for (Schema.PicklistEntry p : Schema.SObjectType.Orders__c.fields.getMap().get('Cancelled_Reason__c').getDescribe().getPicklistValues())
			{
				cancelReasonList.add(new SelectOption(p.getLabel(), p.getValue()));
			}
			      	 		
      	 }
      	 
    	
      }

public void showOrderCancelPanel()
{
	showCancelOrderReason = true;
	showCancelOrderBtn = false;
}

  public void processOrderCancelBtn(){
    
    if(selectedCancelReason == 'None')
    {
    	ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Please select reason for cancellation.'));    	 
    	return;                
    }
    
    try{
    	
    	WS_OrderLineItemCancellation.OrderCancellationResponse_element cancelResponse = new WS_OrderLineItemCancellation.OrderCancellationResponse_element();
    	// pass Salesforce order IDstring SFDCOrderNumber = string.isNotBlank(OrderlineItem.Order__r.Web_Order_ID__c) ? OrderlineItem.Order__r.Web_Order_ID__c : OrderlineItem.Order__r.Name ;
    	string SFDCOrderNumber = orderutilities.zeroLPAD(OrderlineItem.Order__r.Name, 10);
    	
    	cancelResponse = soa_WebservicesClientUtil.CancelOrderbyLineId(PROGRAM_ID,SFDCOrderNumber,OrderlineItem.Product_Number__c, OrderlineItem.Item_Suffix__c,string.valueof(OrderlineItem.Product_Quantity__c),selectedCancelReason);
    	//process response
    	if(cancelResponse.Status != 'Success')
    	{
    	ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Error Cancelling order: ' + cancelResponse.StatusCode + '-'+ cancelResponse.StatusMessage ));
    	
    	return;	
    	}
    	else
    	{
    	//Update orderlineitem status
    	ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, 'Line Item Cancelled successfully.'));
    	OrderlineItem.Item_Status__c = 'CANCELLED';
    	OrderlineItem.Cancel_Reason__c = selectedCancelReason;
    	showCancelOrderBtn = false;
    /*	WS_OrderStatusQuery.OrderStatusQueryResponse_element response_Element = new WS_OrderStatusQuery.OrderStatusQueryResponse_element();
		response_Element = WS_OrderStatusQueryUtils.doCallout(OrderlineItem.Order__c);
    	
    	//Get order status update for header level
    	
		string orderResponse = '';
		if(response_Element.OrderStatusSuccess != null){
		orderResponse = response_Element.OrderStatusSuccess.OrderStatusDetail;
		}
		else
		{
			orderResponse = 'Unknown';
		}
		OrderlineItem.Order__r.Order_Status__c = orderResponse; */
		update OrderlineItem;
		
		
    	}
    }
    catch(exception e)
    {
    	ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Error invoking cancellation web service'));
    	system.debug('--------Error invoking cancellation Web Service' + e.getmessage());
    	
    }
    
        
  }
  
  private boolean renderCancel()
  {
  	// Logic to validate if this line item can be cancelled.
  	boolean toRender = false;
  	string currentStatus = '';
  		try{
  			string CurrentItemStatus = OrderlineItem.Item_Status__c ;
  			if(CurrentItemStatus != 'CANCELLED')
  			{ 
  			currentStatus = OrderlineItem.Item_Status_Code__c;
  			toRender = OrderStatusMap__c.getValues(currentStatus).Line_Item_cancel__c;
  			system.debug('$$$ ' + toRender + ' ' + currentStatus);
  			} 
  			
  		}
  		catch(exception e)
  		{ 
  			// Cannot cancel 
  			system.debug('$$$: Cannot retrieve status code' +  currentStatus);
  		}
  		
  		
  	
  	
  	return toRender;
  }
  
     
      
      
}