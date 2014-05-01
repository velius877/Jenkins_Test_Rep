/* 
	CaseUpdates_ComplexTypes
	Complex types for Case update web service
	------------------------------------------------------------------
	Author			|	Date		|	Description
	------------------------------------------------------------------
	Mitch Malleo  	|	8/12/2013	|	Created
*/

global class CaseUpdates_ComplexTypes {

	global class serviceResponse 
	{
		webservice FailureResponse errorMessage;
		webservice SuccessResponse successMessage;
	}
	
	global class FailureResponse 
	{
		webservice string message;
	}
	
	global class SuccessResponse 
	{
		webservice string message;
	}
	
	global class CaseUpdate
	{
		webservice string caseNumber;
		webservice string closedReason;
		webservice string closedComments;
		webservice string investigationSummary;
		webservice string standardResponse;
		webservice string status;
		webservice string userDefined01;
		webservice string userDefined02;
		webservice string userDefined03;
		webservice string userDefined04;
		webservice string userDefined05;
		webservice string userDefined06;
		webservice string userDefined07;
		webservice string userDefined08;
		webservice string userDefined09;
		webservice string userDefined10;
	}
	
}