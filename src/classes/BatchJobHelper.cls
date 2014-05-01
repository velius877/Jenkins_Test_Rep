public with sharing class BatchJobHelper {
private static final Set<String> ActiveBatchStatuses = new Set<String> { 'Queued', 'Preparing', 'Processing' };
	
	//Variable to hold a list of batch classes that are being processed
		
	private static List<AsyncApexJob> activeAsyncJobs = [Select id, Status, ApexClass.Name from AsyncApexJob where Status in : ActiveBatchStatuses and JobType != 'BatchApexWorker'];
	
	//Batch class names
	
	public static Boolean canThisBatchRunForClass(String BatchClassName)
	{
		Boolean retVar = false;
		for(AsyncApexJob AJ : activeAsyncJobs)
		{
			if(AJ.ApexClass.Name == BatchClassName)
			{
				retVar = true;
			}
		}
		return !retVar;
		
	}
	

}