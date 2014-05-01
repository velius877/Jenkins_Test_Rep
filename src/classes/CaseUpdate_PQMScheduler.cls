global class CaseUpdate_PQMScheduler implements Schedulable{
	
	global Set <String> statusCodes ;
    global Set <String> caseNumbers;
	
	global void execute(SchedulableContext sc){
	
		Case_UpdatePQMBatch cupb = new Case_UpdatePQMBatch();
		if (statusCodes!=null) cupb.statusCodes = statusCodes;
		if (caseNumbers!=null) cupb.caseNumbers=caseNumbers;
		if(BatchJobHelper.canThisBatchRunForClass('Case_UpdatePQMBatch')){
        	ID myBatchJobID = database.executebatch(cupb,1);
		}
		
	}
	
	
	//Setup the scheduled jobs by entering "CaseUpdate_PQMScheduler.setupSchedule();"
    //in the system log window 
    public static void setupSchedule() {
        //Will run every 5 minutes  
        String scha = '0 ';
        String schb = ' * * * ?';
        Integer[] mins = new Integer[]{0,5,10,15,20,25,30,35,40,45,50,55};
        for(Integer min : mins){
            String sch = scha + min + schb;
            System.debug('sch==>' + sch);
            CaseUpdate_PQMScheduler s = new CaseUpdate_PQMScheduler();
            if(!Test.isRunningTest()){
                System.schedule('Case Create PQM Batch ' + min + ' minutes',sch,s);
            }  
        } 
    }
	
}