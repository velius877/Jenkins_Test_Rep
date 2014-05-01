public with sharing class OrderUtilities {
	public static Map <Id, Profile> profileMap {get;set;}
	public static set <String> csrNonCancellableOrderSet = new Set <String>{'Cancelled','Shipped/Complete' };
	public static set <String> nonCsrNonCancellableOrderSet = new Set <String>{'Cancelled'};
	public static set <string> profilesForPostWarehouse = new Set <String>{'Back-Office Team','System Administrator','Call Center Management'};
	


         
    public static string userProfile(String pId){
        Profile usrProfile = [Select name from Profile where Id=:pId limit 1];
    	return usrProfile.name;
    } 
    
  	public static void getProfileMap(){
  		if (ProfileMap==null){
  			profileMap = new Map <Id, Profile>();
			for (Profile p: [select id, name from Profile where name!=null]){
				profileMap.put(p.id,p);
			}
  		}
  	}
  	
  	public static boolean isUserForPostWarehouseCancel()
  	{
  		getProfileMap();
		return profilesForPostWarehouse.contains(profileMap.get(userInfo.getProfileId()).name);
		
		
  	}
  	public static string zeroLPAD(string inputString, integer padLength )
    {
    	if(string.isblank(inputString))
    		inputString = '';
    	integer toPAd = padLength - inputstring.length();
    	string retString = inputString;
    	if(toPAd < 1)
    		return inputString;
    	else
    	{
    		for(integer i = 0; i < toPAd; i++)
    		{
    			retString = '0' + retString;
    		}
    	}
    	
    	return retString;
    		
    		
    	
    	
    }
    
     public static boolean checkProfile(string profName){
		getProfileMap();
		boolean isProf=false;
		if (profileMap.get(userInfo.getProfileId()).name==profName){
			isProf=true;
		}
		return isProf;
    }
    
    public static boolean isUserForMailOrder()
    {
    	list<PermissionSetAssignment> tempperm = [Select PermissionSet.Name, AssigneeId From PermissionSetAssignment where PermissionSet.Name = 'mail_order' and AssigneeId = :UserInfo.getUserId()];
    	if(tempperm.size() > 0)
    		return true;
    	else
    		return false;
    }
    
  
	public static boolean statusSetToInternalReview(string OrderId)//True, when OrderStatus is not 'Open/Internal Review/Ship Complete'
    {     	 
    	boolean changePossible = false;
       	Orders__c o = [Select Id, Order_Submitted__c, Order_Status__c, Internal_Review_Reason__c  from Orders__c where id =:OrderId];
    	if(o != null){
    		if (o.Order_Status__c == 'Open'){
    			changePossible = true;
       		}
    	}
    	return changePossible;
     }
     
     /*For the program ORD180( Pre Warehouse) Program ID 1
		The header status MUST be either �P � or �PB�
		The detail status MUST be
		'PB' 'VX' 'VC' 'VF' 'VG' 'VW'
		 
		For the program ORD265 (Back order) Program ID 2
		The detail status MUST be
		�PB� �KB� SB�
		 
		For the program ORDCNLR(Post Warehouse) Program ID 3
		The detail status MUST be
		�PA�
		 
		For the program ATMBOCNL(Mass Cancel) Program ID 4
		The detail status MUST be
		�PB� 'VX' 'VC' 'VF' 'VG' 'VW' */
     
     public static boolean statusSetToBackOrderCancel(list<Order_Line_Item_Status_Detail__c> lststatus)
     {
     	boolean toRender = false;
     	if(lststatus.size() < 1)
     		return false;
     	// only KB, PB and SB for all line item statuses in an order
     	for(Order_Line_Item_Status_Detail__c templst :lststatus)
     	{
     		if(((templst.Current_Status_Code__c == 'KB') ||  (templst.Current_Status_Code__c == 'PB') || (templst.Current_Status_Code__c == 'SB')))
     		{
     			toRender = true;
     			break;
     		}
     		
     	}
     	
     	return toRender;
     	
     }
     
     public static boolean statusSetToPreWareHouseCancel(list<Order_Line_Item_Status_Detail__c> lststatus)
     {
     	boolean toRender = true;
     	if(lststatus.size() < 1)
     		return  false;
     	// only KB, PB and SB for all line item statuses in an order
     	// avoid duplicates
     	
     	
     	for(Order_Line_Item_Status_Detail__c templst :lststatus)
     	{
     		     		
     		if(!((templst.Current_Status_Code__c == 'PB') ||  (templst.Current_Status_Code__c == 'VX') || (templst.Current_Status_Code__c == 'VC') || (templst.Current_Status_Code__c == 'VF') || (templst.Current_Status_Code__c == 'VG') || (templst.Current_Status_Code__c == 'VW')))
     		{
     			toRender = false;
     			break;
     		}
     		
     		if(!((templst.Order_Status_Code__c == 'P') ||  (templst.Order_Status_Code__c == 'PB') ))
     		{
     			toRender = false;
     			break;
     		}
     		
     	}
     	
     	return toRender;
     	
     }
     
      public static boolean statusSetToPostWareHouseCancel(list<Order_Line_Item_Status_Detail__c> lststatus)
     {
     	boolean toRender = true;
     	if(lststatus.size() < 1)
     		return false;
     	// �PA�
     	for(Order_Line_Item_Status_Detail__c templst :lststatus)
     	{
     		if(!(templst.Current_Status_Code__c == 'PA'))
     		{
     			toRender = false;
     			break;
     		}
     		
     	}
     	
     	return toRender;
     	
     }
     
    public static boolean statusSetToCancel(string OrderId)//True, when OrderStatus is not 'Open/Internal Review/Ship Complete'
    {     	 
    	// Release 2.0 only non submitted orders can be cancelled.
    	// Submitted orders can be pre warehouse cancelled, post warehouse cancelled or backorder cancelled
    	Orders__c o = [Select Id, Order_Submitted__c, Order_Status__c, Internal_Review_Reason__c  from Orders__c where id =:OrderId];
    	return (!o.Order_Submitted__c && o.order_status__c != 'Cancelled');
    	/*
    	
    	boolean changePossible = false;
    	string userProfileName = userProfile(userInfo.getProfileId());
       	Orders__c o = [Select Id, Order_Submitted__c, Order_Status__c, Internal_Review_Reason__c  from Orders__c where id =:OrderId];
	   	if(o != null){
	       if (checkProfile('CSR')){
	       		if (o.Order_Submitted__c) return false;
	       		else return !csrNonCancellableOrderSet.contains(o.order_status__c);
	       	}
	       	else {
	       		return !nonCsrNonCancellableOrderSet.contains(o.order_status__c);
	       	}
	     }
	   	return changePossible;*/
     } 
   
    public static void processInternalReview(string OrderId, string reviewReason){
		try{
			//string OrderId = ApexPages.currentPage().getParameters().get('Id');
			Orders__c o = [Select Id, Order_Submitted__c, Order_Status__c, Internal_Review_Reason__c  from Orders__c where id =:OrderId];
			if(!o.Order_Submitted__c){
			    o.Order_Status__c = 'Internal Review';
			    o.Internal_Review_Reason__c = reviewReason;
			}
			update o;
		}
		catch(NBTYException ex){
             ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,ex.getMessage()));
        }
	}
	
	public static string isOrderValidForSubmit(Id orderId)
	{
		string errorMSG = '';
		
		Orders__C oOrder = [Select Tax__c, Paypal_Authorization_Code__c, Payment_Type__c, Payment_Transaction_Reference_Number__c, Payment_Transaction_Reference_Index__c, Payment_Profile_ID__c, Payment_Authorization_Code__c, Order_Total__c, Misc_Charge_Amount__c, Credit_Card_Token__c, Bank_Response_Date_Time__c, Authorization_Amount__c, Bill_To_Address__r.Zip_Code__c From Orders__c where id =:OrderId];
		system.debug(oOrder.Payment_Type__c);
		if(oOrder.Payment_Type__c == 'Credit Card')
		{
			 if(string.isblank(oOrder.Payment_Authorization_Code__c))
			 	errorMSG +=  '\n Payment Authorization code is blank';
			 if(string.isblank(oOrder.Payment_Profile_ID__c))
			 	errorMSG +=  '\n Payment Profile Id is blank';
			 if(string.isblank(oOrder.Credit_Card_Token__c))
			 	errorMSG +=  '\n Credit Card Token# is blank';
			 if(string.isblank(oOrder.Payment_Transaction_Reference_Number__c))
			 	errorMSG +=  '\n Payment Transaction Reference Number is blank';
			 if(string.isblank(oOrder.Payment_Transaction_Reference_Index__c))
			 	errorMSG +=  '\n Payment Transaction Reference Index is blank';
			 if(oOrder.Authorization_Amount__c == NULL)
			 	errorMSG +=  '\n Authorization amount is blank';
			 else if(oOrder.Authorization_Amount__c < 0.00)
			    errorMSG +=  '\n Invalid Authorization Amount';
			 if(string.isblank(oOrder.Bank_Response_Date_Time__c))
			 	errorMSG += '\n Bank Authorization TimeStamp is blank';
			 else
			 	{
			 		//2013-05-16T07:00:25
			 		string[] bankdate = oOrder.Bank_Response_Date_Time__c.split('T');
			 		if(bankdate.size() != 2)
			 			errorMSG = '\n Invalid date timestamp';
			 		else
			 		    {
			 		    	string datetimepart = oOrder.Bank_Response_Date_Time__c.replace('T',' ');
			 		    	try{
			 		    		Datetime testDAte = datetime.valueOf(datetimepart);
			 		    	}
			 		    	catch(exception e){
			 		    		errorMSG += '\n Invalid date timestamp ' + oOrder.Bank_Response_Date_Time__c;
			 		    	}
			 		    }
			 		
			 		
			 	}
			 	
			 if(string.isblank(oOrder.Payment_Authorization_Code__c))
			 	errorMSG += '\n Payment Authorization code is blank';
			 if(string.isblank(oOrder.Bill_To_Address__r.Zip_Code__c = '00000'))
			 	errorMSG +=  '\n Invalid Billing Zip Code - 00000';
			 else
			 system.debug('** Zip Code' + oOrder.Bill_To_Address__r.Zip_Code__c );
			 	
			 	
		}
		 
		 
		return errorMSG;
	}
	
	public static WS_soa_AuthorizePaymentService.PaymentReversalResponse processAuthReversal(Orders__c o, boolean bCancellation){
		boolean bSuccess = false;
		string 		PaymentReversalStatus;
		string 		PageMessage;
		WS_soa_AuthorizePaymentService.PaymentReversalResponse reversalResponse;
		try {
			reversalResponse = soa_WebservicesClientUtil.orderPaymentReversal(o.Id);
			bSuccess = true;
		}
		catch (exception e) {
			bSuccess= false;
			reversalResponse = new WS_soa_AuthorizePaymentService.PaymentReversalResponse();
			reversalResponse.ErrorMessage=e.getMessage();
			reversalResponse.Message='An Error Occurred, Please contact your administrator.';
		}
		if (!bCancellation){
			o.Payment_Authorization_Code__c=null; 
			o.Payment_Transaction_Reference_Index__c=null;
			o.Payment_Transaction_Reference_Number__c=null;
			o.Authorization_Amount__c=null;
			o.Bank_Response_Date_Time__c=null;
			o.Sales_Channel__c='Phone';
			o.Order_Status__c='Open';
			update o;
		}
		 return reversalResponse;
	}
	
	public static void forceCancel(string OrderId, string cancelReason){
		 WS_soa_AuthorizePaymentService.PaymentReversalResponse reversalResponse;
		boolean reversePayment = true;
		 Orders__c o = [Select Id, Payment_Transaction_Reference_Number__c, Order_Submitted__c,Payment_Type__c,Reversal_Status__c, Order_Status__c, Internal_Review_Reason__c, AS400_Cancellation_Details__c  from Orders__c where id =:OrderId];
		 o.Order_Status__c = 'Cancelled';
		 o.Cancelled_Reason__c = cancelReason;
		 if(o.Order_Status__c == 'Partially Shipped') // Cannot reverse partial shipped orders
		     {
		     	reversePayment = false;
		     	o.Reversal_Status__c = 'Cannot Reverse Authorization- Order is Partially Shipped.';
		     	 ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, o.Reversal_Status__c));
		     }
		 
		  if(reversePayment)
		     {
		     	try{
		     		if(o.Payment_Transaction_Reference_Number__c!=null)
		     		{
		     		 system.debug('%%%%' + ' - inside Order reversal');
		     		 reversalResponse = OrderUtilities.processAuthReversal(o,true);
		     		 if(!reversalResponse.Status.equalsIgnoreCase('APPROVED')){
		     		 	o.Order_Status__c = 'Cancelled'; //Error condition	
		     		 	o.Reversal_Status__c = reversalResponse.ErrorMessage;
		     		 	ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Payment Authorization not successfully reversed: '+reversalResponse.ErrorMessage));
		     			}
		     			else // DE 755
		     			{
		     			o.Order_Status__c = 'Cancelled'; //Error condition	
		     		 	o.Reversal_Status__c = 'APPROVED';
		     			}
		     		}
		     		
		     	}
		     	catch(exception e)
		     	{
		     		//Error	
		     	}
		     }
		     update o;  
		// DE605 -- If cancelSuccessful then return the customer's credit. Otherwise, ignore.
         if (reversePayment){
         	UndoAppliedCredit(orderId);
	}
	}
	

	
	 
	public static boolean processOrderCancel(string OrderId, string cancelReason){
		string CancelStatus;
		WS_soa_AuthorizePaymentService.PaymentReversalResponse reversalResponse;
		boolean reversePayment = false;
		boolean cancelSuccessful = false;
		ApexPages.getMessages().clear();
		try{
        	//string OrderId = ApexPages.currentPage().getParameters().get('Id');
     	    Orders__c o = [Select Id, Payment_Transaction_Reference_Number__c, Order_Submitted__c,Payment_Type__c,Reversal_Status__c, Order_Status__c, Internal_Review_Reason__c, AS400_Cancellation_Details__c  from Orders__c where id =:OrderId];
	    	if(o.Order_Submitted__c){
	    	   if(Test.isRunningTest()){
	    	   	  CancelStatus = 'Order Cancelled';
	    	    }
	    	    else{
	    	       CancelStatus = soa_WebservicesClientUtil.cancelOrderbyCancelOrder_US_v1(OrderId,cancelReason);
	    	    }
		       if(CancelStatus == 'Order Cancelled'){
			      o.Order_Status__c = 'Cancelled';
		          o.Cancelled_Reason__c = cancelReason;
		          o.AS400_Cancellation_Details__c = 'Cancellation in AS400 Successful';
		          cancelSuccessful=true;
		          ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM, o.AS400_Cancellation_Details__c));
		          reversePayment = true;
		        }
		        else{
		      	    o.AS400_Cancellation_Details__c = 'Cancellation in AS400 Unsuccessful. '+CancelStatus;
		      	     ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, o.AS400_Cancellation_Details__c));
		        }
		     }
		     else{
		         o.Order_Status__c = 'Cancelled';
		         o.Cancelled_Reason__c = cancelReason;
		         o.AS400_Cancellation_Details__c = 'Cancelled in Salesforce before Submission to AS400';
		          ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM, o.AS400_Cancellation_Details__c));
		         cancelSuccessful=true;
		         reversePayment = true;
		     } 
		     
		     if(o.Order_Status__c == 'Partially Shipped') // Cannot reverse partial shipped orders
		     {
		     	reversePayment = false;
		     	o.Reversal_Status__c = 'Cannot Reverse Authorization- Order is Partially Shipped.';
		     	 ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, o.Reversal_Status__c));
		     }
		     
		     if(string.isnotblank(o.Reversal_Status__c))
		     {
		     	if(o.Reversal_Status__c.equalsignorecase('APPROVED'))
		     		reversePayment = false;
		     		ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM, 'Payment Authorization Successfully Reversed'));
		     }
		     
		     system.debug('%%% - reversePayment/Cancel Status ' + reversePayment + '$$' + CancelStatus );
		     
		     if(reversePayment)
		     {
		     	try{
		     		if(o.Payment_Transaction_Reference_Number__c!=null)
		     		{
		     		 system.debug('%%%%' + ' - inside Order reversal');
		     		 reversalResponse = OrderUtilities.processAuthReversal(o,true);
		     		 if(!reversalResponse.Status.equalsIgnoreCase('APPROVED')){
		     		 	o.Order_Status__c = 'Cancelled'; //Error condition	
		     		 	o.Reversal_Status__c = reversalResponse.ErrorMessage;
		     		 	ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Payment Authorization not successfully reversed: '+reversalResponse.ErrorMessage));
		     			}
		     			else // DE 755
		     			{
		     			o.Order_Status__c = 'Cancelled'; //Error condition	
		     		 	o.Reversal_Status__c = 'APPROVED';
		     			}
		     		}
		     		
		     	}
		     	catch(exception e)
		     	{
		     		//Error	
		     	}
		     }
		     update o;  
		     
	    }
	    catch(NBTYException ex){
             ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,ex.getMessage()));
        }
        catch(Exception e){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Cancellation Attempt Failed, please contact your administrator'));
                system.debug(e.getMessage());
         }
         // DE605 -- If cancelSuccessful then return the customer's credit. Otherwise, ignore.
         if (cancelSuccessful){
         	UndoAppliedCredit(orderId);
         }
		return 	    	   	  cancelSuccessful;
	}

	// DE605 Restores Customer Credit.
	public static void UndoAppliedCredit(string Id){
		System.debug('UndoAppliedCredit: order id: ' + Id);
		Orders__c o = [Select Credit_Amount_Applied__c, Customer__c from Orders__c where Id =: Id];
		if (o.Credit_Amount_Applied__c != null){
			
			Credit__c c = new Credit__c();
			c.Account__c = o.Customer__c;
			c.Credit_Amount__c = o.Credit_Amount_Applied__c * -1;
			c.Credit_Notes__c = 'Refunding credit due to order cancellation. Refunded amount of ' + c.Credit_Amount__c + '.';
		
			try {
				insert c;
			}catch (Exception e){
				System.debug('Error inserting credit. ' + e.getMessage());
			}
		}
	}
	
	public static string standardToMiltaryTime(string ti)
	{
		string ipTime = (ti.replaceAll('\\s','')).toUpperCase();
		string opTime = '';
		try 
		{
			if(ipTime.contains('AM'))
			{
				if(ipTime.contains('12'))
					return '0';
				opTime = ipTime.replace('AM', '');
				return opTime;
			}
			if(ipTime.contains('PM'))
			{
				ipTime = ipTime.replace('PM', '');
				if(ipTime.contains('12'))
					return '12';
				string hours = ipTime.contains(':') ? ipTime.split(':')[0] : ipTime;
				string minutes = ipTime.contains(':') ? ':'+ipTime.split(':')[1] : '';
				hours = string.valueof(integer.valueof(hours) + 12)	;
				opTime = hours + minutes;
				return opTime;
			}
			
			return opTime;
		} catch(exception ex) {
			system.debug('Error occured '+ ex.getmessage());
			return null;
		}
	}
	
	// DE880
	// Returns false for those that cannot be edited, true otherwise.
	public static boolean CanEditSalesChannel(String wsid){
		return String.IsBlank(wsid) ? true : WebStoresData__c.getValues(wsid).Is_Editable__c;
	}	
}