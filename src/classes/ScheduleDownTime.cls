/* 
	ScheduleDownTime
	DESCRIPTION
	------------------------------------------------------------------
	Author		|	Date		|	Description
	------------------------------------------------------------------
	Your Name   |	??/??/???	|	Created

*/

global class ScheduleDownTime implements Schedulable{
	
	
	global void execute(SchedulableContext s){
		ManualDownTimeController.setSystemStatus();
		AuthDownTimeUtils.checkScheduleStatus();
	}
	
	//Setup the scheduled jobs: "ScheduleDownTime.setupSchedule();" 
	public static void setupSchedule(String sch, String jobName){
		System.debug('sch==>' + sch);
		ScheduleDownTime s = new ScheduleDownTime();
		if(!Test.isRunningTest()){
			System.schedule(jobName,sch+' '+jobName,s);
		}
	}
	
}