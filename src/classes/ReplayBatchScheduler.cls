/* 
	ReplayBatchScheduler
	DESCRIPTION
	------------------------------------------------------------------
	Author		|	Date		|	Description
	------------------------------------------------------------------
	Your Name   |	??/??/???	|	Created

*/


global class ReplayBatchScheduler implements Schedulable{
	
	global void execute(SchedulableContext s){
		ReplayBatch rb = new ReplayBatch();
		database.executebatch(rb,1);
	}
	
	//Setup the scheduled jobs: "ReplayBatchScheduler.setupSchedule();" 
	public static void setupSchedule(String sch){
		System.debug('sch==>' + sch);
		ReplayBatchScheduler s = new ReplayBatchScheduler();
		if(!Test.isRunningTest()){
			System.schedule('Schedule Replay Authorization Batch' ,sch,s);
		}
	}
}