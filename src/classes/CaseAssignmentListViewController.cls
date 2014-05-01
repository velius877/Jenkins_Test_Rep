public class CaseAssignmentListViewController {
	public List<Case> cseList {get;set;}
	private Id userId;
	public Boolean showTable {get;set;}
	public String msg {get;set;}
	public List<Case_Wrapper> cseWrap {get;set;}
	
	public CaseAssignmentListViewController(){
		init();
	}
	
	public void init(){
		//get user Id
		userId = userInfo.getUserId();
		//Get list of new cases assigned to user
		cseList = [SELECT Id, CaseNumber, AccountId, Customer__c, Subject, Status, Origin, Brand__c, CreatedDate, Web_Form_Subject__c, 
					Rejected__c, Rejected_Reason__c 
					FROM Case WHERE OwnerId = :userId AND Status = 'New' AND SFDC_Case_Assignment__c = true ORDER BY CreatedDate ASC];
		//Determine if there are any cases present: yes=display table, no=display message
		if(cseList.size() > 0){
			showTable = true;
			cseWrap = new List<Case_Wrapper>();
			cseWrap = buildWrapper(cseList);
		}else{
			showTable = false;
			msg = 'You have no assigned cases.';
		}
	}
	
	public void refreshList(){
		init();
	}
	
	public void markAsSpam(){
		List<Case> cses = new List<Case>();
		for(Case_Wrapper cw: cseWrap){
			if(cw.isSpam == true){
				cw.cs.Rejected__c = true;
				cw.cs.Rejected_Reason__c = 'Spam';
				cw.cs.Status = 'Closed';
				cses.add(cw.cs);
			}
		}
		update cses;
		init();
	}
	
	public List<Case_Wrapper> buildWrapper(list<Case> cases){
		List<Case_Wrapper> cseWrapList = new List<Case_Wrapper>();
		for(Case cse : cases){
			cseWrapList.add(new Case_Wrapper(cse));
		}
		return cseWrapList;
	}
	
	public class Case_Wrapper {
		public Boolean isSpam {get;set;}
		public Case cs {get;set;}
		
		public Case_Wrapper(Case c){
			isSpam = false;
			cs = c;
		}
	}
}