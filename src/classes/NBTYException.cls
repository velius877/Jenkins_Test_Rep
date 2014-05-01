/********************************************************************************
 ********************************************************************************    
 *	Class            : NBTYException
 *	Author		     : Acumen Solutions: Rahul Badal
 *	Version History  : 1.0
 *	Creation         : 04/11/13
 *	Description      : Generic Exception class to create log of all errors.
 *						
 ********************************************************************************
 ********************************************************************************/
public class NBTYException extends Exception{

	public void NBTYException(String message)
	{	
	    Error_Log__c errLog = new Error_Log__c();
	    errLog.Error_Line_Number__c = this.getLineNumber();
	    errLog.Error_Message__c = this.getMessage();
	 //   errLog.Error_Stack_Trace__c = e.getStackTraceString();
	 //   errLog.Error_Type__c = e.getTypeName();    
	    
	    Insert errLog;    
	}
	
	static testMethod void NBTYException_Test(){
		NBTYException e = new NBTYException();
		e.NBTYException('Error!!!');
	}
}