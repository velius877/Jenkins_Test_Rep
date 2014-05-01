public with sharing class CaseRedirect {
	
	public Case c {get;set;}
	
	public CaseRedirect(ApexPages.StandardController controller)
	{
		c = (Case)controller.getRecord();
	}
	
	public PageReference init()
	{
		List<Case> caseComplaintType = [SELECT Complaint_Type__c FROM Case WHERE Id = :c.Id LIMIT 1];
		
		if(caseComplaintType[0].Complaint_Type__c == 'Inquiry' || caseComplaintType[0].Complaint_Type__c == 'Class I' || caseComplaintType[0].Complaint_Type__c == 'Class II Non-Illness')
		{
			PageReference noAERorNR = new PageReference('/apex/Case_No_AER_NR?id=' + c.Id);
			noAERorNR.setRedirect(true);
			return noAERorNR;
		}
		else
		{
			PageReference standardPage = new PageReference('/'+c.id + '?nooverride=1');
			standardPage.setRedirect(true);
			return standardPage;
		}
		return null;
	}

}