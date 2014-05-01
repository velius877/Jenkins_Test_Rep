/********************************************************************************
 ********************************************************************************    
 *  Class            : BatchUtilities
 *  Author           : Acumen Solutions: Latha Davuluri
 *  Version History  : 
 *  Creation         : 06/12/13
 *  Description      : Class that has utility methods for NBTY Batch jobs
 *                      
 ********************************************************************************/

global class BatchUtilities {
  
 	public static void batchEmailSuccess(Database.BatchableContext apexJob, string apexJobName){
		string messageBody;
		string messageSubject;
		messageSubject = 'Apex Batch Job '+ apexJobName + ' is Complete';
		AsyncApexJob a = [Select Id, Status, NumberOfErrors, JobItemsProcessed,
									TotalJobItems, CreatedBy.Email
									from AsyncApexJob where Id =:apexJob.getJobId()];
		if (a.NumberOfErrors>0){ 
			messageBody ='<html><body><h2>The batch apex job '+ apexJobName +' processed successfully.</h2><br/><br/>';
			messageBody = messageBody + 'No of Errors:- '+ a.NumberOfErrors +'<br/>';
			messageBody = messageBody + 'Job Items Processed:- '+ a.JobItemsProcessed + '<br/>';
			messageBody = messageBody + 'Total Job Items:- '+ a.TotalJobItems + '<br/></body></html>';
				  
			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
			String[] toAddresses = new String[] {a.CreatedBy.Email};
			mail.setToAddresses(toAddresses);
			mail.setSubject(messageSubject);
			mail.setHtmlBody(messageBody);
			try{
			   Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});	 // Send an email to the Apex job's submitter notifying of job completion.
			}
			catch(Exception e){
				System.debug('**NBTY Exception:- Error sending the email : '+e.getMessage());
			}
		}
	}
	
	/*
	 * DE664
	 * Given a status and number of days of age, generates a string for a query for 
	 * a batch to use to purge Orders__c records. 
	 *
	 * Param: numberOfDaysOld: Takes integer of number of days old as negative.
	 * Param: orderStatusToPurge: Allows setting of the order status to purge.
	 * Param: nameOfFinalDate: Name of the variable that will store the date.
	 * Param: nameOfFinalStatus: Name of the variable that stores the Order Status.
	 */
	public static string makePurgeByAgeQuery(String orderStatusToPurge, String nameOfFinalDate, String nameOfFinalStatus){
     	String q;
     	
     	String status = orderStatusToPurge == null ? ':' + nameOfFinalStatus : '\'' + orderStatusToPurge + '\'';
     	
		q =  'SELECT Id FROM Orders__c WHERE Order_Date__c <=  :' + nameOfFinalDate + ' ' ;
		if (status != '' && status != null){
	    	q = q + 'AND Order_Status__c ='+  status;
		}
	
  		System.debug('Query~~~' + q);
  		return q;
     	
     	/*String q;
     	
     	String status = orderStatusToPurge == null ? ':' + nameOfFinalStatus : '\'' + orderStatusToPurge + '\'';
     	
		q =  'SELECT Id FROM Orders__c WHERE Order_Date__c <=  :' + nameOfFinalDate + ' ' ;
		if (status != '' && status != null){
	    	q = q + 'AND Order_Status__c ='+  status;
		}
	
  		System.debug('Query~~~' + q);
  		return q;*/
	}
}