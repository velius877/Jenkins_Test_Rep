/************************************* MODIFICATION LOG ********************************************************************************
*
* DESCRIPTION : OrderSummaryTriggerTest is a test class for OrderSummaryTrigger
*
*---------------------------------------------------------------------------------------------------------------------------------------
* DEVELOPER						DATE				  REASON
*---------------------------------------------------------------------------------------------------------------------------------------
* Shivkant Vadlamani			04/15/2013			- Origininal Version
*
*													 
*/

@isTest
global class OrderSummaryTriggerTest 
{
	static testMethod void testOrderSummaryTrigger()
	{
		testDataSetupUtil.SetupCoreData(2);
		OrderSummaryTriggerHelperTest.setupInboundOrderMapping();
		OrderSummaryTriggerHelperTest.setupWebStoresData();
		Order_Summary__c OSRec = OrderSummaryTriggerHelperTest.setupOrderSummary();
		
		
		Orders__c OrdGenerated = [SELECT Id, Webstack_Order_ID__c, Customer__c, (Select Id From Order_Line_Items__r), Bill_To_Address__c, Ship_To_Address__c FROM Orders__c WHERE Webstack_Order_ID__c = :OSRec.Webstack_Order_ID__c];

		List<Address__c> AddressList = [SELECT City__c, Zip_Code__c FROM Address__c WHERE Id = :OrdGenerated.Bill_To_Address__c OR Id = :OrdGenerated.Ship_To_Address__c ];
		
		System.assert( OrdGenerated.Id != null , 'This is a valid Order record');
		System.assert(OrdGenerated.Order_Line_Items__r.size() == 2, 'There should be 2 Order line items');				
		System.assert( OrdGenerated.Bill_To_Address__c != null , 'This is NOT a valid Billing Address');
		System.assert( OrdGenerated.Ship_To_Address__c != null , 'This is NOT a valid Shipping Address');	
		
		if(AddressList[0].Id == OrdGenerated.Bill_To_Address__c)
		{
			System.assert( AddressList[0].City__c == 'RAPPERSWIL' , 'This is NOT the correct City of Billing Address');	
		}
		
		if(AddressList[0].Id == OrdGenerated.Ship_To_Address__c)
		{
			System.assert( AddressList[0].City__c == 'NORTH PORT' , 'This is NOT the correct City of Shipping Address');	
		}
	}
}