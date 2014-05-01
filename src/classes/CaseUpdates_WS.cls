/********************************************************************************
 ********************************************************************************    
 *  Class            : CaseUpdates_WS
 *  Author           : Acumen Solutions: Mitch Malleo
 *  Version History  : 
 *  Creation         : 09/04/13
 *  Description      : Case Update service that sets the status to 'closed' in salesforce
 *                      
 ********************************************************************************
 ********************************************************************************/

global class CaseUpdates_WS {
	
	webservice static CaseUpdates_ComplexTypes.serviceResponse UpdateCases(CaseUpdates_ComplexTypes.CaseUpdate caseUpdate)
	{
			
		return processCaseUpdate(caseUpdate);
	}
	
	public static CaseUpdates_ComplexTypes.serviceResponse processCaseUpdate(CaseUpdates_ComplexTypes.CaseUpdate caseToUpdate)
	{
		try
		{
			integer caseNumberInt = Integer.valueOf(caseToUpdate.caseNumber);
			List<Case> currentSalesforceCase = [SELECT Id, Status, CaseNumber, Investigation_Summary__c FROM Case WHERE CaseNumber = :caseToUpdate.caseNumber LIMIT 1];
										
			if(currentSalesforceCase.size() == 0)
			{
				return GenerateError('The case number ' + caseToUpdate.caseNumber + ' does not exist in salesforce');
			}
			
			// DE892 - INC765580
			// Christian Coleman
			// Added the 'Investigation Completed' status to catch updates from PQM in more than just closed statuses
			// before:
			// 		if(caseToUpdate.status == 'Closed')
			if(caseToUpdate.status == 'Closed' || caseToUpdate.status  == 'Investigation Completed')
			{
				currentSalesforceCase[0].Status = caseToUpdate.status;
				currentSalesforceCase[0].Investigation_Summary__c = caseToUpdate.investigationSummary;
				currentSalesforceCase[0].Closing_Comments__c = caseToUpdate.closedComments;
				currentSalesforceCase[0].Closing_Reason_Long__c = caseToUpdate.closedReason;
				currentSalesforceCase[0].Standard_Response__c = caseToUpdate.standardResponse;
				update currentSalesforceCase;
			}
			
			else
			{
				// before:
				//		return GenerateError('The case number ' + caseToUpdate.caseNumber + ' has a status that is not closed. Status must be closed to update case in salesforce.');
				return GenerateError('The case number ' + caseToUpdate.caseNumber + ' has an invalid status. Status must be Closed or Investigation Completed to update the case in Salesforce.');
			}
			
			return GenerateSuccess();
		} 
		
		catch(exception e) 
		{
			Error_Log__c err = new Error_Log__c();
			err.Error_Line_Number__c = e.getLineNumber();
			err.Error_Message__c = e.getMessage();
			err.Error_Stack_Trace__c = e.getStackTraceString();
			err.Error_Type__c = e.getTypeName();
			insert err;
			String str = e.getTypeName() + ' - ' + e.getLineNumber() +' - ' + e.getMessage();
			return GenerateError(str);
		}
	}
	
	public static CaseUpdates_ComplexTypes.serviceResponse GenerateSuccess()
	{
		CaseUpdates_ComplexTypes.serviceResponse resp = new CaseUpdates_ComplexTypes.serviceResponse();
		CaseUpdates_ComplexTypes.SuccessResponse s = new CaseUpdates_ComplexTypes.SuccessResponse();
		s.Message = 'Success';
		resp.successMessage = s;
		return resp;
	}
	
	public static CaseUpdates_ComplexTypes.serviceResponse GenerateError(String errorMessage)
	{
		CaseUpdates_ComplexTypes.serviceResponse resp = new CaseUpdates_ComplexTypes.serviceResponse();
		CaseUpdates_ComplexTypes.FailureResponse f = new CaseUpdates_ComplexTypes.FailureResponse();
		f.Message = errorMessage;
		resp.errorMessage = f;
		return resp;
	}
	
}