/********************************************************************************
 ********************************************************************************    
 *  Class            : OrdersToFulfillmentBatchSchedule
 *  Author           : Acumen Solutions: Latha Davuluri
 *  Version History  : 
 *  Creation         : 05/29/13
 *  Description      : Scheduler class to schedule OrdersToFulfillmentBatch process.
 *                      
 ********************************************************************************
 ********************************************************************************/

global class OrdersToFulfillmentBatchSchedule implements Schedulable{
	global static integer noOfMins;
	global static string orderStatus;
	
    global void execute(SchedulableContext sc)
    {   
    	if (noOfMins==null) noOfMins=60;
    	if (orderStatus==null) orderStatus='Pending Submission';
    	OrdersToFulfillmentBatch ofb = new OrdersToFulfillmentBatch(noOfMins,orderStatus);
    	if(BatchJobHelper.canThisBatchRunForClass('OrdersToFulfillmentBatch'))
			{
			ID myBatchJobID = database.executebatch(ofb,1); 
			}
    	 
        
    }

    public static testMethod void OrdersToFulfillmentBatchScheduleTest()
    {
        Test.startTest();
        OrdersToFulfillmentBatchSchedule s8 = new OrdersToFulfillmentBatchSchedule();
        string sch = '0 0 * * 1-12 ? *';
        system.schedule('Order to Fulfillment system Batch Job', sch, s8);
        Test.stopTest();
    }

    public static testMethod void OrdersToFulfilmentBatchTest()
    {
        Test.startTest();
        OrdersToFulfillmentBatch ofb = new OrdersToFulfillmentBatch(60,'Pending Submission');
        ID myBatchJobID = database.executebatch(ofb);
        Test.stopTest();
             
       Datetime ordersPickupTime = Datetime.now().addMinutes(1); 
       Integer i = [SELECT COUNT() FROM Orders__c Where Order_Status__c='Pending Submission' AND lastModifiedDate < :ordersPickupTime];
       System.assertEquals(i, 0);
    }
    
    public static testMethod void OrdersToFulfilmentBatchTest_CatchUp()
    {
    	testDataSetupUtil.SetupCoreData(2);
    	testDataSetupUtil.order1.Order_Status__c='Pending Submission';
    	testDataSetupUtil.order1.Order_Date__c = system.now().addHours(-6);
        Test.startTest();
        OrdersToFulfillmentBatch ofb = new OrdersToFulfillmentBatch(4,8,'Pending Submission');
        ID myBatchJobID = database.executebatch(ofb);
        Test.stopTest();

       Integer i = [SELECT COUNT() FROM Orders__c Where Order_Status__c='Pending Submission'];
       System.assertEquals(i, 0);
    }
}