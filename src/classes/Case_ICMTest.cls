@isTest
public class Case_ICMTest {
	public static Case c;
	
	public static void setupData()
	{
		c = new Case(customer__c =TestDataSetupUtil.acct.id );
		string selectedRecordType = 'Product_Complaint';
			RecordType rt = [SELECT Id, DeveloperName FROM RecordType WHERE developerName = :selectedRecordType];
		c.RecordTypeId = rt.id;
		CaseTriggerHelper.isFromChild=true;
		c.Category__c = 'Class I Packaging;';
		c.CT_Category__c = 'Class I;';
		c.Subcategory__c = 'Class I Packaging|Broken desiccant;';
		c.CT_Subcategory__c = 'Class I;';
		insert c;
		CaseTriggerHelper.isFromChild=false;
		
		CaseCategoryMapping__c caseMapping1 = new CaseCategoryMapping__c();
		caseMapping1.Name = '1';
		caseMapping1.Complaint_Type__c = 'Class II Illness';
		caseMapping1.Category__c = 'Illness';
		caseMapping1.Subcategory__c = 'Eye Disorders';
		insert caseMapping1;
		
		CaseCategoryMapping__c caseMapping2 = new CaseCategoryMapping__c();
		caseMapping2.Name = '2';
		caseMapping2.Complaint_Type__c = 'Class I';
		caseMapping2.Category__c = 'Class I Packaging';
		caseMapping2.Subcategory__c = 'Broken desiccant';
		insert caseMapping2;
		
		CaseCategoryMapping__c caseMapping3 = new CaseCategoryMapping__c();
		caseMapping3.Name = '3';
		caseMapping3.Complaint_Type__c = 'Class II Non-Illness';
		caseMapping3.Category__c = 'Choking';
		caseMapping3.Subcategory__c = 'Choking';
		insert caseMapping3;
		
		Adverse_Event_Review__c anAdverseEventReview = new Adverse_Event_Review__c();
		anAdverseEventReview.AER_Related_Case__c = c.Id;
		insert anAdverseEventReview;
		
		Nutrition_Review__c aNutritionReview = new Nutrition_Review__c();
		aNutritionReview.NR_Associated_Case__c = c.Id;
		insert aNutritionReview;
		
		Affected_Item__c anAffectedItem = new Affected_Item__c();
		anAffectedItem.Item__c = testDataSetupUtil.itemList[0].id;
		anAffectedItem.Case__c = c.Id;
		insert anAffectedItem;
		
		Other_Medications_OTC__c anOTC = new Other_Medications_OTC__c();
		anOTC.OTC_Related_Case__c = c.Id;
		insert anOTC; 
	}
	
	public static void setupFollowUpCase()
	{
		c = new Case(customer__c =TestDataSetupUtil.acct.id );
		string selectedRecordType = 'Follow_Up';
			RecordType rt = [SELECT Id, DeveloperName FROM RecordType WHERE developerName = :selectedRecordType];
		c.RecordTypeId = rt.id;
		insert c;
	}
/*	
	public static void initCatch()
	{
		c = new Case(customer__c =TestDataSetupUtil.acct.id );
		string selectedRecordType = 'Follow_Up';
			RecordType rt = [SELECT Id, DeveloperName FROM RecordType WHERE developerName = :selectedRecordType];
		c.RecordTypeId = rt.id;
	}
	
	public static void initCatchElse()
	{
		c = new Case(customer__c =TestDataSetupUtil.acct.id );
		string selectedRecordType = 'Product_Complaint';
			RecordType rt = [SELECT Id, DeveloperName FROM RecordType WHERE developerName = :selectedRecordType];
		c.RecordTypeId = rt.id;
	}
	
	static testMethod void testInitCatch()
	{
		TestDataSetupUtil.SetupCoreData(2);
		initCatch();
		ApexPages.StandardController controller = new ApexPages.StandardController(c);
		PageReference pageRef = Page.Case_ICM;
		Test.setCurrentPage(pageRef);
		 	test.startTest();
		Case_ICM icmController = new Case_ICM(controller);
		test.stopTest();
	}
	
	static testMethod void testInitElse()
	{
		TestDataSetupUtil.SetupCoreData(2);
		initCatchElse();
		ApexPages.StandardController controller = new ApexPages.StandardController(c);
		PageReference pageRef = Page.Case_ICM;
		Test.setCurrentPage(pageRef);
		 	test.startTest();
		Case_ICM icmController = new Case_ICM(controller);
		test.stopTest();
	}
*/
		static testMethod void testICMController() 
		{
	
		TestDataSetupUtil.SetupCoreData(2);
		setupData();
		ApexPages.StandardController controller = new ApexPages.StandardController(c);
		PageReference pageRef = Page.Case_ICM;
		Test.setCurrentPage(pageRef);
		test.startTest();
		Case_ICM icmController = new Case_ICM(controller);
		
			icmController.c.Complaint_Type__c = 'Inquiry';
		icmController.displayPage();
		icmController.getCorrectComplaintTypes(icmController.c.Complaint_Type__c);
		Case_ICM.getCategories(icmController.c.Complaint_Type__c);
		
		icmController.c.Complaint_Type__c = 'Class I';
		icmController.displayPage();
		icmController.getCorrectComplaintTypes(icmController.c.Complaint_Type__c);
		Case_ICM.getCategories(icmController.c.Complaint_Type__c);
		
		icmController.c.Complaint_Type__c = 'Class II Non-Illness';
		icmController.displayPage();
		icmController.getCorrectComplaintTypes(icmController.c.Complaint_Type__c);
		Case_ICM.getCategories(icmController.c.Complaint_Type__c);
		
		icmController.c.Complaint_Type__c = 'Class II Illness';
		icmController.displayPage();
		icmController.getCorrectComplaintTypes(icmController.c.Complaint_Type__c);
		Case_ICM.getCategories(icmController.c.Complaint_Type__c);
		
		icmController.c.Complaint_Type__c = 'Class III';
		icmController.displayPage();
		icmController.getCorrectComplaintTypes(icmController.c.Complaint_Type__c);
		Case_ICM.getCategories(icmController.c.Complaint_Type__c);
		
		ApexPages.currentPage().getParameters().put('category' , 'Illness');
		icmcontroller.compileSelectedCategory();
		
		Case_ICM.getSubcategories(icmController.selectedCategoryList);
		
		ApexPages.currentPage().getParameters().put('subcategory' , 'Eye Disorders');
		ApexPages.currentPage().getParameters().put('complaintType' , 'Class II Illness');
		icmController.compileSelectedSubcategory();
			
		icmController.c.Same_as_Reporter__c = true;
		icmController.getAbove();
		icmController.c.Same_as_Reporter__c = false;
		icmController.getAbove();
		
		icmController.saveICM();
		
		ApexPages.currentPage().getParameters().put('removeSubcategory' , 'Eye Disorders');
		icmController.removeSubcategory();
		
		ApexPages.currentPage().getParameters().put('removeCategory' , 'Illness');
		icmController.removeCategory();
		
		test.stopTest();
		}
	
	static testMethod void testLotNumberquery(){
		Test.setMock(WebServiceMock.class, new MockResponse_LotNumberQuery());
		TestDataSetupUtil.SetupCoreData(2);
		setupData();
		ApexPages.StandardController controller = new ApexPages.StandardController(c);
		PageReference pageRef = Page.Case_ICM;
		Test.setCurrentPage(pageRef);
		test.startTest();
		Case_ICM icmController = new Case_ICM(controller);
		icmController.affectedItemsList[0].prdDetail.item__c = testDataSetupUtil.itemList[0].id;
		icmController.affectedItemsList[0].prdDetail.NBTY_Lot__c = '12345';
		icmController.affectedItemsList[0].prdDetail.Lot_Number_Sequence__c = '12345';
		ApexPages.currentPage().getParameters().put('affectedItemIndex','0');
		icmController.lotDetail();
		system.assert(icmController.affectedItemsList[0].prdDetail.oracle_bulk_number__c!=null);
		test.stopTest();
	}
}