/********************************************************************************
 ********************************************************************************	
 *	Class			: OrdersToFulfillmentBatch
 *	Author			: Acumen Solutions: Latha Davuluri
 *	Version History	: 
 *	Creation		 : 05/29/13
 *	Description		: Batch process to send successfully validated orders to fulfillment system.
 *						
 ********************************************************************************
 ********************************************************************************/
global class OrdersToFulfillmentBatch implements Database.Batchable<sobject>,Database.AllowsCallouts {
	global String Query;
	global String orderStatus = 'Pending Submission';
	global Datetime ordersPickupTime;
	global boolean bCatchup = false;
	global Datetime minOrderPickupTime;
	global Datetime maxOrderPickupTime;
	global Set <String> orderNumbers;
	global Integer noOfMins = 60;
	//constructor
	global ordersToFulfillmentBatch(integer nMins, string oStatus) {
		noOfMins=nMins;
		orderStatus=oStatus;
	}
	
	global	ordersToFulfillmentBatch(integer iMinHours, integer iMaxHours, string oStatus) {
		bCatchup =true;
		minOrderPickupTime = system.now().addHours(-iMinHours);
		maxOrderPickupTime = system.now().addHours(-iMaxHours);
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		
		Datetime oPickUpTime;
		Date 		oPickUpDate = system.today();
		String q;
		if (noOfMins==null) noOfMins=60;
	
		if (noOfMins != null) {
		 oPickUpTime = datetime.now().addMinutes(-noOfMins);
		}
		
		q =	'SELECT Id, Order_Status__c, Order_Submitted__c FROM Orders__c WHERE'; 
		if (!bCatchUp) {
			q+= ' ( (Order_Date__c <	:oPickUpTime AND Future_Order__c = false )' ; 
			q+=' OR (Future_Order__c = TRUE AND Future_Order_Date__c <=:oPickUpDate) )';
		} else {
			if (minOrderPickupTime!=null && maxOrderPickupTime !=null) {
				q+= ' ((Order_Date__c >	:minOrderPickupTime AND Future_Order__c = false )' ; 
				q+= ' AND ( Order_Date__c <	:maxOrderPickupTime AND Future_Order__c = false ))' ; 
			}
		}
		if (orderStatus != '' && orderStatus != null) {
			q = q + 'AND Order_Status__c= :orderStatus ';
		}
		if (orderNumbers!=null) {
				q+= ' AND NAME IN:orderNumbers ';
		}
		if (!bCatchUp) q = q + 'order by order_date__c LIMIT 400';
		
		Query = q; 
		system.debug(Query);
		return Database.getQueryLocator(Query);
	}

	global void execute(Database.BatchableContext BC, sobject[] scope) {
		List<Orders__c> ordList = new List<Orders__c>();
		for(Sobject s : scope) {
			Orders__c o = (Orders__c)s;
			//if(o.Order_Fulfillment_Status__c == 'Success'){
			set <string> responseString;
			try {
				responseString = soa_WebservicesClientUtil.submitOrderBySendOrderService2(o.id);
				system.debug(responseString);
			} catch (exception e) {
					responseString = new Set <String> {'Failure :'+e.getMessage()};
			}
			if (responseString!=null) {
				//	for (String rString: responseString){
					if (responseString.contains('200')) {
						o.Order_Status__c = 'Submitted';
						o.Order_Submitted__c = true;
						o.AS_400_Submission_Details__c=null;
						AvalaraTaxCalc.CalculateTax_OrderSubmission(o.id);
						//right here is where i make the callout to redeem coupons.
						try {
							WS_SOA_LoyaltyServicesUtils.redeemVWCoupon(o.Id);
						} catch (exception e) {
							
						}
					} else {
						o.Order_Status__c = 'Submission Failed';
						o.AS_400_Submission_Details__c='';
						for (string rs: responseString){
							o.AS_400_Submission_Details__c += rs+'<br/>';	
						}
					}
					ordList.add(o);
				}
	//		}
		}
		try {
			update ordList;
		} catch(Exception e) {
			System.debug('Error updating the orders in OrdersToFulfillmentBatch : '+e.getMessage());
		}
		
	}

	global void finish(Database.BatchableContext BC) {
		BatchUtilities.batchEmailSuccess(BC, 'OrdersToFulfillmentBatch');
	}
	
}