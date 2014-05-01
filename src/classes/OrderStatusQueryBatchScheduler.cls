/* 
	OrderStatusQueryBatchScheduler
	DESCRIPTION
	------------------------------------------------------------------
	Author		|	Date		|	Description
	------------------------------------------------------------------
	Your Name   |	??/??/???	|	Created

*/


global class OrderStatusQueryBatchScheduler implements Schedulable{
	
	public String query;
	public Boolean nightly;
	
	public OrderStatusQueryBatchScheduler(Boolean isNightly){
		if (!isNightly) {
			nightly = false;
		} else {
			nightly = true;
		}
	}
	
	global void execute(SchedulableContext sc){
		if (nightly) {
			OrderStatusQueryBatch osqb = new OrderStatusQueryBatch(true);
			id dbid = database.executeBatch(osqb,1);
		} else {
			OrderStatusQueryBatch osqb = new OrderStatusQueryBatch(false);
			id dbid = database.executeBatch(osqb,1);
		}
		
	}
	
	//Setup the scheduled jobs by entering "OrderStatusQueryBatchScheduler.setupNightlySchedule();"
	//in the system log window 
	public static void setupNightlySchedule(){
		String sch = '0 0 2 * * ?';
		System.debug('sch==>' + sch);
		OrderStatusQueryBatchScheduler s = new OrderStatusQueryBatchScheduler(true);
		if(!Test.isRunningTest()){
			System.schedule('Order Status Query Nightly Batch',sch,s);
		}
	}
	
	//Setup the scheduled jobs by entering "OrderStatusQueryBatchScheduler.setupHourlySchedule();"
	//in the system log window 
	public static void setupHourlySchedule(){
		String sch = '0 0 * * * ?';
		System.debug('sch==>' + sch);
		OrderStatusQueryBatchScheduler s = new OrderStatusQueryBatchScheduler(false);
		if(!Test.isRunningTest()){
			System.schedule('Order Status Query Hourly Batch',sch,s);
		}
	}
}