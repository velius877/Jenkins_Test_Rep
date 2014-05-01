/*
	AuthDownTimeUtils
	DESCRIPTION
	------------------------------------------------------------------
	Author		|	Date		|	Description
	------------------------------------------------------------------
	Your Name   |	??/??/???	|	Created

*/

public class AuthDownTimeUtils {
	
	//Call this method to set the order for reauthorization
	public static void setOrderReAuth(OrderWizard_Wrapper wrap, String existingToken){
		wrap.newOrder.Re_Authorize__c = true;
		wrap.newOrder.Order_Status__c = 'Awaiting Authorization';
		wrap.newOrder.OwnerId = setOrderOwner('Orders - Awaiting Payment Authorization');
		if(!wrap.newOrder.Replay_Existing_CC__c){//if false this is a new card
			wrap.newOrder.Credit_Card_Expiration_Date__c = wrap.paymentInfo.expiryYYYYMM; 
			wrap.newOrder.Credit_Card_Type__c = wrap.selectedccType;
			wrap.newOrder.Credit_Card_Number__c = wrap.paymentInfo.creditCardNumber;
			wrap.newOrder.Card_Holder_Name__c = wrap.paymentInfo.nameOnCard;
			wrap.newOrder.Payment_Type__c = wrap.selectedpaymentType;
			update wrap.newOrder;
		}else{//else this is an existing card
			wrap.newOrder.Credit_Card_Type__c = wrap.selectedccType;
			wrap.newOrder.Payment_Type__c = wrap.selectedpaymentType;
			wrap.newOrder.Credit_Card_Token__c = existingToken;
			update wrap.newOrder;
		}
	}
	
	public static Id setOrderOwner(String owner){
		//sets the owner id during downtime to a queue which will hold all orders awaiting payment authorization.
		QueueSobject qs = [SELECT Id, QueueId, Queue.Name, Queue.DeveloperName FROM QueueSobject WHERE Queue.Name = :owner LIMIT 1];
		return qs.QueueId;
	}
	
	//Method pulled from Order Wizard @ln192
	public static Orders__c queryOrder(Id orderId){
		// DE640 -- added Future Order flag/date fields along with gift order
		Orders__c orderObj = [SELECT 	customer__r.Payment_Profile_Id__c,	Tax__c,Discount__c,Catalog_Source_Code__c , Source_Code__c, Ship_To_Address__r.Zip_Code__c,
								Ship_To_Address__r.Zip_Code_4__c, Ship_To_Address__r.Foreign_Postal_Code__c,Ship_To_Address__r.Country__c, Ship_To_Address__r.City__c, 
								Ship_To_Address__r.Address_Line_3__c,Shipping_Total__c,Future_Order__c,Future_Order_Date__c,Gift_Order__c,Ship_To_Address__r.Address_Line_2__c,
								Ship_To_Address__r.Address_Line_1__c,Ship_To_Address__r.State_Providence__c,customer__r.personEmail, Order_Total__c,payment_type__c,Pull_Order__c, 
								No_Invoice__c, No_Peanuts__c, No_Catalogs__c,	No_Substitutes__c, Ship_Complete__c, customer__r.recordType.developerName,customer__r.name,
								Customer__r.Associate_Customer__c, customer__r.Associate_ID__c,promotions__r.name,promotions__r.offers__c,id,name,Order_Status__c,Sales_Channel__c, 
								Shipping_Method__c,customer__c,Bill_To_Address__c ,Ship_to_address__c,Credit_Amount_Applied__c,Credit_Applied__c,Credit_Reasons__c,
								Credit_Card_Expiration_Date__c,Credit_Card_Token__c,Pull_Order_Reason_Multi__c	,Pull_Order_Reason_Other__c,Ship_To_Last_Name__c,
								Ship_To_First_Name__c , Batch_Number__c, Batch_Sequence_Number__c, Comments__c, Replay_Existing_CC__c, Re_Authorize__c, Credit_Card_Number__c,
								Card_Holder_Name__c FROM Orders__c WHERE id =:OrderId];
		return orderObj;
	}
	
	public static Boolean checkDownTimeStatus(){
		WS_Integration__c authService = WS_Integration__c.getValues('AuthServiceAvailable');
		if(authService != null){
			system.debug('--------------------------------------------authService: ' + authService);
			return Boolean.valueOf(authService.Value__c);
		}else{
			return true;
		}
		
	}
	
	@future
	public static void checkScheduleStatus(){
		List<CronTrigger> ct = [SELECT Id, State, StartTime, OwnerId, NextFireTime, CreatedDate, CronExpression, CronJobDetailId, 
								CronJobDetail.Name, CronJobDetail.JobType FROM CronTrigger];
		for(CronTrigger x :ct){
			system.debug('--------------------------------------------CT: ' + x);
			if(x.State == 'DELETED'){
				system.abortJob(x.Id);
			}
		}
	}
	
	public static void checkScheduleStatus2(){
		List<CronTrigger> ct = [SELECT Id, State, StartTime, OwnerId, NextFireTime, CreatedDate, CronExpression, CronJobDetailId, 
								CronJobDetail.Name, CronJobDetail.JobType FROM CronTrigger];
		for(CronTrigger x :ct){
			system.debug('--------------------------------------------CT: ' + x);
			if(x.State == 'DELETED'){
				system.abortJob(x.Id);
			}
		}
	}
	
	
}