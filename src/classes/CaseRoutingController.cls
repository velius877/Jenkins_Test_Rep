public class CaseRoutingController {
	
	public String selectedQueue {get;set;}
	public String selectedQuantity {get;set;}
	private Id userId;
	public String redirectStr {get;set;}
	public List<Case> cseList {get;set;}
	public String userName {get;set;}
	private String msg;
	
	public CaseRoutingController(){
		userId = userInfo.getUserId();
		userName = userInfo.getName();
		//redirectStr = '/apex/CaseAssignmentListView';
	}
	
	public List<SelectOption> getQueueSelect(){
		//Get a list of groups the user belongs to
		List<GroupMember> usersGroups = [SELECT Id, GroupId, Group.Name FROM GroupMember WHERE UserOrGroupId = :userId AND Group.Type != 'Queue'];
		Set<String> groupIds = new Set<String>();
		for(GroupMember c : usersGroups){
			system.debug('---------------------------------------------------------------userGroups: ' + c.Id + ' ' + c.Group.Name);
			groupIds.add(c.GroupId);
		}
		groupIds.add(userId);
		//Use groups to find queues a users group belongs to
		List<GroupMember> gmList = [SELECT Id, GroupId, Group.Name FROM GroupMember WHERE UserOrGroupId IN :groupIds AND Group.Type = 'Queue'];
		Set<String> gmSet = new Set<String>();
		Set<String> gmNameSet = new Set<String>();
		for(GroupMember x : gmList){
			gmSet.add(x.GroupId);
			gmNameSet.add(x.Group.Name);
			system.debug('---------------------------------------------------------------userGroups: ' + x.GroupId);
		}
		//Create a select list from available queues
		List<Case_Assignment_Rule__c> carList = [SELECT Id, Queue_Name__c, Assignment_Rule__c FROM Case_Assignment_Rule__c 
													WHERE Queue_Name__c IN :gmNameSet];
		Set<String> qNameSet = new Set<String>();
		List<SelectOption> queueOptions = new List<SelectOption>();
		for(Case_Assignment_Rule__c car : carList){
			if(!qNameSet.contains(car.Assignment_Rule__c)){
				qNameSet.add(car.Assignment_Rule__c);
				queueOptions.add(new SelectOption(car.Assignment_Rule__c, car.Assignment_Rule__c));
			}
		}
		
		return queueOptions;
	}
	
	public List<SelectOption> getCaseQuantitySelect(){
		List<SelectOption> caseQuantity = new List<SelectOption>();
		caseQuantity.add(new SelectOption('1','1'));
		caseQuantity.add(new SelectOption('3','3'));
		caseQuantity.add(new SelectOption('5','5'));
		caseQuantity.add(new SelectOption('7','7'));
		caseQuantity.add(new SelectOption('10','10'));
		return caseQuantity;
	}
	
	public void assignCases(){
		List<Case_Assignment_Rule__c> carList = Case_Assignment_Rule__c.getAll().values();
		Set<String> qSet = new Set<String>();
		for(Case_Assignment_Rule__c car : carList){
			if(car.Assignment_Rule__c == selectedQueue){
				qSet.add(car.Queue_Name__c);
			}
		}
		//Query Cases where the owner = the selected queue
		//cases assigned FIFO
		cseList = new List<Case>();
		if(selectedQueue != null && selectedQuantity != null){
			Integer i = Integer.valueOf(selectedQuantity);
			cseList = [SELECT Id, OwnerId FROM Case WHERE Owner.Name IN :qSet AND Status = 'New' ORDER BY CreatedDate ASC LIMIT :i];
			for(Case cse : cseList){
				cse.OwnerId = userId;
				cse.SFDC_CA_Time__c = datetime.now();
				cse.SFDC_Case_Assignment__c = true;
			}
			
			update cseList;
			
			List<Case> cseList2 = [SELECT Id, CaseNumber, AccountId, Customer__c, Subject, Status, Origin, Brand__c, CreatedDate 
					FROM Case WHERE OwnerId = :userId AND Status = 'New' AND SFDC_Case_Assignment__c = true ORDER BY CreatedDate ASC];
					
			if(i == 1 && cseList.size() > 0 && cseList2.size() == 1){
				redirectStr = '/' + cseList[0].Id;
				setPageMessage(msg = 'Success. ' + string.valueOf(cseList.size()) + ' cases assigned.');
			}else if(i > 1 && cseList.size() > 0 && cseList2.size() > 1){
				redirectStr = '/apex/CaseAssignmentListView';
				setPageMessage(msg = 'Success. ' + string.valueOf(cseList.size()) + ' cases assigned.');
			}else if(i == 1 && cseList.size() > 0 && cseList2.size() >= 1){
				redirectStr = '/apex/CaseAssignmentListView';
				setPageMessage(msg = 'Success. ' + string.valueOf(cseList.size()) + ' cases assigned.');
			}else{
				redirectStr = '/apex/CaseAssignmentListView';
				setPageMessage(msg = 'There are no available cases in assignment rule ' + selectedQueue);
			}
		}else {
			//user didn't select something
		}
	}
	
	public static void setPageMessage(String msg){
		ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO, msg);
		ApexPages.addMessage(myMsg);
	}
	
}