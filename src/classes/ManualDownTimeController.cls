/*
	ManualDownTimeController
	DESCRIPTION
	------------------------------------------------------------------
	Author		|	Date		|	Description
	------------------------------------------------------------------
	Your Name   |	??/??/???	|	Created

*/

public class ManualDownTimeController {
	
	public String uName {get;private set;}
	public String sysStatus {get;set;}
	public String awaitingAuth {get;private set;}
	public String ccDeclined {get;private set;}
	public String subFailed {get;private set;}
	public String authFailed {get; private set;}
	public String noSchedDownTime {get;set;}
	public String noSchedReplay {get;set;}
	public Boolean schedNewBatch {get;set;}
	public Boolean schedNewDownTime {get;set;}
	public Boolean showDownTimeTable {get;set;}
	public Boolean showReplayTable {get;set;}
	public Boolean upOrDown {get;set;}
	public List<CronTrigger> downTimeJobs {get;set;}
	public List<CronTrigger> replayBatches {get;set;}
	public DateTime replayStart {get;set;}
	public DateTime downTimeStart {get;set;}
	public DateTime downTimeEnd {get;set;}
	private String msg;
	
	public ManualDownTimeController(){
		uName = UserInfo.getName();
		awaitingAuth = '0';
		ccDeclined = '0';
		authFailed = '0';
		schedNewBatch = false;
		schedNewDownTime = false;
		showDownTimeTable = true;
		showReplayTable = true;
		init();
		getRecordCounts();
		getDownTimes();
		getReplayBatches();
	}
	
	public void init(){
		if(AuthDownTimeUtils.checkDownTimeStatus()){
			sysStatus = 'System Active';
		}else{
			sysStatus = 'System Down';
		}
	}
	
	public void refresh() {
		init();
		getRecordCounts();
		getDownTimes();
		getReplayBatches();
	}
	
	public void getRecordCounts(){
		awaitingAuth = String.valueOf([SELECT Count() FROM Orders__c WHERE Order_Status__c = 'Awaiting Authorization']);
		ccDeclined = String.valueOf([SELECT Count() FROM Orders__c WHERE Order_Status__c = 'Payment Declined']);
		subFailed = String.valueOf([SELECT Count() FROM Orders__c WHERE Order_Status__c = 'Pending Submission']);
		authFailed = String.valueOf([SELECT Count() FROM Orders__c WHERE Order_Status__c = 'Payment Authorization Failed']);
	}
	
	public void getDownTimes(){
		Set<String> jobNames = new Set<String> {'Schedule Down Time', 'Schedule Up Time'};
		downTimeJobs = queryCronTrigger(jobNames);
		if(downTimeJobs == null || downTimeJobs.size() == 0){
			showDownTimeTable = false;
			noSchedDownTime = 'There are no scheduled activities.';
		}else{
			showDownTimeTable = true;
		}
	}
	
	public void getReplayBatches(){
		Set<String> jobNames = new Set<String> {'Schedule Replay Authorization Batch'};
		replayBatches = queryCronTrigger(jobNames);
		if(replayBatches == null || replayBatches.size() == 0){
			showReplayTable = false;
			noSchedReplay = 'There are no scheduled activities.';
		}else{
			showReplayTable = true;
		}
	}
	
	public static List<CronTrigger> queryCronTrigger(Set<String> jobNames){
		List<CronTrigger> ct = [SELECT Id, State, StartTime, OwnerId, NextFireTime, CreatedDate, CronExpression, CronJobDetailId, 
								CronJobDetail.Name, CronJobDetail.JobType FROM CronTrigger WHERE CronJobDetail.Name IN :jobNames];
		return ct;
	}
	
	public void setDownTime(){
		schedNewDownTime = true;
		schedNewBatch = false;
		getDownTimes();
	}
	
	public void setReplay(){
		schedNewDownTime = false;
		schedNewBatch = true;
		getReplayBatches();
	}
	
	public void doCancel(){
		schedNewBatch = false;
		schedNewDownTime = false;
		getDownTimes();
		getReplayBatches();
	}
	
	public void changeStatus(){
		setSystemStatus();
		init();
	}
	
	public void scheduleSysDownTime(){
		if(downTimeStart != null && downTimeEnd != null){
			if(DateTime.now() < downTimeStart && DateTime.now() < downTimeEnd){//This is a valid future date
				downTimeSched();
				upTimeSched();
				getDownTimes();
				getRecordCounts();
				
			}else{
				setPageWarningMessage(msg = 'You must enter a future date and time.');
			}
		} else {
			setPageWarningMessage(msg = 'You must set a valid start and end date and time.');
		}
	}
	
	public void downTimeSched() {
		String cronStr = splitForCron(downTimeStart);
		ScheduleDownTime.setupSchedule(cronStr, 'Schedule Down Time');
	}
	
	public void upTimeSched() {
		String cronStr2 = splitForCron(downTimeEnd);
		ScheduleDownTime.setupSchedule(cronStr2, 'Schedule Up Time');
	}
	
	public static DateTime findStartEnd(String jobName){
		Set<String> jobNames = new Set<String> {jobName};
		List<CronTrigger> jobsToCompare = queryCronTrigger(jobNames);
		if (jobsToCompare.size() == 1){
			return jobsToCompare[0].NextFireTime;
		} else {
			return null;
		}
		
	}
	
	public void scheduleReplay() {
		if (replayStart != null) {
			if (DateTime.now() < replayStart) {//This is a valid future date
				Datetime start = findStartEnd('Schedule Down Time');
				Datetime end1 = findStartEnd('Schedule up Time');
				if (start != null && end1 != null) {
					if (replayStart >= start && replayStart <= end1) {
						setPageWarningMessage('Unable to schedule replay batch during scheduled downtime.');
					}
				} else if (start == null && end1 != null) {
					if (replayStart <= end1) {
						setPageWarningMessage('Unable to schedule replay batch during scheduled downtime.');
					}
				} else {
					String cronStr = splitForCron(replayStart);
					ReplayBatchScheduler.setupSchedule(cronStr);
					getReplayBatches();
					getRecordCounts();
					setPageInfoMessage(msg = 'Replay batch has been successfully scheduled');
				}
			} else {
				setPageWarningMessage(msg = 'You must enter a future date and time.');
			}
		} else {
			setPageWarningMessage(msg = 'You must set a valid date and time.');
		}
	}
	
	public static String splitForCron(DateTime dt){
		system.debug('----------------------------------dt (GMT format): ' + dt);
		String minute = String.valueOf(dt.minute());
		system.debug('----------------------------------minute: ' + minute);
		String hour = String.valueOf(dt.hour());
		system.debug('----------------------------------hour: ' + hour);
		String day = String.valueOf(dt.day());
		system.debug('----------------------------------day: ' + day);
		String month = String.valueOf(dt.month());
		system.debug('----------------------------------month: ' + month);
		String year = String.valueOf(dt.year());
		system.debug('----------------------------------year: ' + year);
		String cronString = '0 ' + minute + ' ' + hour + ' ' + day + ' ' + month + ' ? ' + year;
		system.debug('----------------------------------cronString: ' + cronString);
		return cronString;
	}
	
	public void setPageWarningMessage(String msg){
		ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.WARNING, msg);
		ApexPages.addMessage(myMsg);
	}
	
	public void setPageInfoMessage(String msg){
		ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO, msg);
		ApexPages.addMessage(myMsg);
	}
	
	public static void setSystemStatus(){
		WS_Integration__c authS = WS_Integration__c.getValues('AuthServiceAvailable');
		system.debug('--------------------------------------------authS' + authS);
		if(authS.value__c == 'True'){
			authS.value__c = 'False';
		}else{
			authS.Value__c = 'True';
		}
		update authS;
	}
	
	public void startReplay() {
		if (AuthDownTimeUtils.checkDownTimeStatus()) {
			ReplayBatch rb = new ReplayBatch();
			database.executebatch(rb,1);
			setPageInfoMessage('Replay Batch has been started.');
		} else {
			setPageWarningMessage('Unable to start Replay Batch due to payment authentication in downtime mode.');
		}
		
	}
	
	
	
	
	
}