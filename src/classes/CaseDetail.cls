public with sharing class CaseDetail {
	
	public Case c {get;set;}
	public boolean renderAER {get;set;}
	public boolean renderNR {get;set;}
	public List<CaseComment> cc {get;set;}
	public Boolean renderCC {get;set;}
	// DE874 moved CaseHistories to here.
	public List<SomeObjectHistory> CaseHistories {get;set;}
	private String cId;
	
	//Protected Members
	private static final DescribeSObjectResult oSomeObjectSchema = Schema.SObjectType.Case;
	private static final Map<string, Schema.SObjectField> mapFields = oSomeObjectSchema.fields.getMap();
	
	//Properties
	public Id caseId {get;set;}
	public integer PageSize {get;set;}
	public boolean AllowShowMore {get;set;}
	
	// DE874 -- comment out
	/*public List<SomeObjectHistory> CaseHistories {
		get { return getSomeObjectHistory(caseId); }
	}*/
	
	public CaseDetail(ApexPages.StandardController controller){
		PageSize = 5;   
		AllowShowMore = true;
		c = (Case)controller.getRecord();
		cId = controller.getId();
		getAllCaseComments(cId);
		// DE874 initialize CaseHistories.
		CaseHistories = getSomeObjectHistory(cId);
	}
	
	public void getAllCaseComments(Id cId){
		cc = [SELECT CommentBody, CreatedBy.Name, CreatedDate FROM CaseComment WHERE ParentId = :cId ORDER BY CreatedDate DESC LIMIT 10];
		if(cc.size() > 0){
			renderCC = true;
		}else{
			renderCC = false;
		}
	}
	
	public PageReference newComment(){
		PageReference pr = new PageReference('/00a/e?parent_id=' + cId + '&retURL=%2F' + cId);
		pr.setRedirect(true);
		return pr;
	}
	
	//Public Methods
	public void showMore() {
		PageSize += 5;
	}
   
	public List<SomeObjectHistory> getSomeObjectHistory(Id caseId) {
		List<SomeObjectHistory> listSomeObjectHistory = new List<SomeObjectHistory>();
		
		if (caseId != null) {
			DateTime dLastCreatedDate = null;
			
			integer limitPlusOne = PageSize + 1;
			
			List<CaseHistory> listEntityHistory = [SELECT Id, IsDeleted, caseId, CreatedById, CreatedBy.Name, CreatedDate, Field, OldValue, NewValue FROM CaseHistory WHERE caseId = :caseId ORDER BY CreatedDate DESC, Id DESC LIMIT :limitPlusOne];
			AllowShowMore = (listEntityHistory.size() == limitPlusOne);
			for (String fieldName : mapFields.keySet()){
            	System.debug('~~~~~~~~~~~: ' + fieldName);
        	}
			for (CaseHistory oHistory : listEntityHistory) {
				SomeObjectHistory oSomeObjectHistory = new SomeObjectHistory(oHistory);
				System.debug('~~~~~~~~~~~ oHistory.Field: ' + oHistory.Field);
				
				if (oHistory.Field.equalsIgnoreCase('owner')){ //DE874
					oSomeObjectHistory.FieldLabel = 'Owner';
				}
				
				if (mapFields.containsKey(oHistory.Field)) {
					oSomeObjectHistory.FieldLabel = mapFields.get(oHistory.Field).getDescribe().Label;
				}
									
				if (dLastCreatedDate == oHistory.CreatedDate) {
					oSomeObjectHistory.ShowDateAndUser = false;
				}
				else {
					oSomeObjectHistory.ShowDateAndUser = true;
				}
				
				if (oHistory.NewValue != null && oHistory.OldValue != null) {//DE874 -- skip extra entries that start 00
					if (((String)oHistory.NewValue).startsWith('00') || ((String)oHistory.OldValue).startsWith('00')){
						continue;
					}
				}
				
				listSomeObjectHistory.add(oSomeObjectHistory);
				dLastCreatedDate = oHistory.CreatedDate;
				
				if (listSomeObjectHistory.size() == PageSize) break;
			}
			System.debug('~~~~~~~~~~~ listSomeObjectHistory: ' + listSomeObjectHistory);
		}
		
		return listSomeObjectHistory;
	}
	
	//Internal Classes
 
	/**
	 * Data structure representing a SomeObject History record for display
	 */
	public class SomeObjectHistory {
		//Properties
		public boolean ShowDateAndUser {get;set;}
		public string FieldLabel {get;set;}
		public CaseHistory History {get; private set;}
		
		public string ActionFormat {
			get { return getActionFormat(); }
		}
		
		public SomeObjectHistory(CaseHistory oHistory) {
			History = oHistory;
		}
		
		//Constructors
		public SomeObjectHistory() {
			showDateAndUser = true;
		}
		
		//Private Methods
		private string getActionFormat() {
			string sActionFormat = '';
			
			if (History != null) {
				sActionFormat = 'Record {0}.';
				
				if (History.newValue != null && History.oldValue == null) {
					sActionFormat = 'Changed <strong>{1}</strong> to <strong>{3}</strong>.';	
				}
				else if (History.newValue != null && History.oldValue != null) {
					sActionFormat = 'Changed <strong>{1}</strong> from {2} to <strong>{3}</strong>.';   
				}
				else if (History.Field != null && History.Field.equalsIgnoreCase('created')) {
					sActionFormat = 'Created.';
				}
			}
			
			return sActionFormat;
		}
	}

	public CaseDetail()
	{
		PageSize = 5;   
		AllowShowMore = true;
	}
	
	

	public void init()
	{
		List<Case> categoryQuery = [SELECT Complaint_Type__c, Category__c FROM Case WHERE Id = :c.Id LIMIT 1];
		List<String> categorySplit = new List<String>();
		
		if(categoryQuery[0].Category__c != null)
		{
			categorySplit = categoryQuery[0].Category__c.split(';');
		}
		
		if(categoryQuery[0].Complaint_Type__c == 'Inquiry' || categoryQuery[0].Complaint_Type__c == 'Class I')
		{
			renderAER = false;
			renderNR = false;
		}
		else if(categoryQuery[0].Complaint_Type__c == 'Class II Non-Illness')
		{
			for(String aCategory : categorySplit)
			{
				if(aCategory == 'Choking')
				{
					renderAER = true;
					renderNR = false;
				}
			}
		}
		else
		{
			renderAER = true;
			renderNR = true;
		}
	}
}