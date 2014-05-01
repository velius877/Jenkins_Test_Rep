@isTest
private class CaseRouting_Test {
	
	public static Case_Assignment_Rule__c car;
	public static List<Case> cseList;
		
	
	public static void setupTestData(){
		//Create Assignment Rules
		car = new Case_Assignment_Rule__c();
		car.Name = 'CAR-0001';
		car.Queue_Name__c = 'E Support Backlog';
		car.Assignment_Rule__c = 'Test Rule 1';
		insert car;
		
		//Create Cases
		RecordType recType = [SELECT Id, Name, DeveloperName FROM RecordType WHERE DeveloperName = 'Pre_Case' LIMIT 1];
		cseList = new List<Case>();
		Case cse1 = new Case();
		cse1.RecordTypeId = recType.Id;
		cse1.Status = 'New';
		cse1.Brand__c = 'Vitamin World';
		cse1.Origin = 'Web to Case';
		cseList.add(cse1);
		
		Case cse2 = new Case();
		cse2.RecordTypeId = recType.Id;
		cse2.Status = 'New';
		cse2.Brand__c = 'Vitamin World';
		cse2.Origin = 'Web to Case';
		cseList.add(cse2);
		insert cseList;
		
	}

	static testMethod void testCaseRoutingController() {
		setuptestData();
		test.startTest();
		CaseRoutingController crc = new CaseRoutingController();
		crc.getQueueSelect();
		crc.getCaseQuantitySelect();
		crc.selectedQuantity = '2';
		crc.selectedQueue = 'E Support Backlog';
		crc.assignCases();
		CaseAssignmentListViewController calvc = new CaseAssignmentListViewController();
		calvc.refreshList();
		calvc.cseWrap = new List<CaseAssignmentListViewController.Case_Wrapper>();
		calvc.cseWrap = calvc.buildWrapper(cseList);
		calvc.cseWrap[0].isSpam = true;
		calvc.markAsSpam();
		test.stopTest();
	}
	
	static testMethod void testCaseAssignmentListViewcontroller(){
		CaseAssignmentListViewController calvc = new CaseAssignmentListViewController();
		calvc.refreshList();
	}
	
}