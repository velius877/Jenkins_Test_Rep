/*
 * Author       : Pavan Jasti, Acumen
 * Class        : OrderAdjustmentController 
 * Date         : 02/04/2014
 * Description  : Test class for OrderAdjustmentController.cls
*/
@isTest
public  class OrderAdjustmentControllerTest{
    
    static Case testCase;
    static Order_Adjustment__c testOrderAdjustment;
    
    public static void setupTestData(){
        // reusing TestDataSetupUtil
        TestDataSetupUtil.SetupCoreData(5);
       
        testCase = new Case();
        RecordType rt = [SELECT Id, DeveloperName FROM RecordType WHERE developerName = 'Follow_Up' and sObjectType = 'case'];
        testCase.customer__c =TestDataSetupUtil.acct.id ;
        testCase.Related_Order__c = TestDataSetupUtil.order1.id;
        insert testCase;
        
        testOrderAdjustment = TestDataSetupUtil.setupOrderAdjustment(testCase.Id,TestDataSetupUtil.order1.Id,TestDataSetupUtil.acct.Id);
    }
    
    public static void createAdjustmentLineItems(string adjId,integer recCount)
    {
    	list<Order_Adjustment_Line_Item__c>  adjlineItemsList = new list<Order_Adjustment_Line_Item__c>();
    	for(integer i=0; i < recCount;i++)
    	{
	    	Order_Adjustment_Line_Item__c oali = new Order_Adjustment_Line_Item__c();
		 	oali.Item_Name__c = 'Test Item';
		 	oali.Quantity__c = 1;
		 	oali.Amount__c = 10.00;
		 	oali.SKU_Number__c = '111'+i;
		 	oali.Order_Adjustment__c = adjId;
		 	adjlineItemsList.add(oali);
    	} 
    	insert adjlineItemsList;
    } 
    
    testMethod static void testCreateNewAndExistingMiscAdjustment(){
        setupTestData();
        RecordType miscRecType = [SELECT Id FROM RecordType WHERE DeveloperName = 'Misc_Charge' AND sObjectType = 'Order_Adjustment__c' AND IsActive = true limit 1];

        Test.startTest();
	        Test.setCurrentPageReference(Page.OrderAdjustmentPage);
	        ApexPages.currentPage().getParameters().put('caseId',testCase.Id);
	        testOrderAdjustment.Id = null; //  //clearing Id of the adjustmnet to make it look like there is no Order adjustment. with help of case ID the order adjustment is created
	        ApexPages.StandardController sc = new ApexPages.StandardController(testOrderAdjustment);               
	        OrderAdjustmentController orderAdjController = new OrderAdjustmentController(sc);
	        // Testing all realted MISC charges related code
	        orderAdjController.orderAdj.Status__c = 'Draft' ;
	        orderAdjController.orderAdj.Refund_or_Misc_Amount__c = 25 ;
	        orderAdjController.orderAdj.RecordTypeId = miscRecType.Id ;
	        // getter methods
	        orderAdjController.getMiscChargeMethods();
	        orderAdjController.getMiscChargeStatus();
	        orderAdjController.renderComponents(); //SelectedRecType
	        orderAdjController.createOrderAdjustment(); //creates new order adjustment
	        // with different payment methods
	        orderAdjController.orderAdj.Payment_Method__c = 'Credit Card';
	        orderAdjController.orderAdj.Credit_Card_Number__c = '4112344112344113';
	        orderAdjController.orderAdj.Credit_Card_Type__c = 'Visa';
	        orderAdjController.orderAdj.Credit_Card_Expiration_Date__c = '201606';
	        orderAdjController.createOrderAdjustment();
	        orderAdjController.orderAdj.Payment_Method__c = 'Existing Card';
	        orderAdjController.createOrderAdjustment();
	        //with invalid card details and Token
	         orderAdjController.orderAdj.Payment_Method__c = 'Credit Card';
	        orderAdjController.orderAdj.Credit_Card_Number__c = '4112344112344113';
	        orderAdjController.orderAdj.Credit_Card_Type__c = 'Discover';
	        orderAdjController.orderAdj.Credit_Card_Expiration_Date__c = '201606';
	        orderAdjController.createOrderAdjustment();
	        orderAdjController.orderAdj.Payment_Method__c = 'Existing Card';
	        orderAdjController.createOrderAdjustment();
	        system.assert(orderAdjController.orderAdj.Id != null);
	        System.assertEquals(orderAdjController.orderAdj.Refund_or_Misc_Amount__c, 25);
	        system.debug('@@@testOrderAdjustment'+testOrderAdjustment);
	       
	        //testing Existing MISC order adjustment
	        testOrderAdjustment = TestDataSetupUtil.setupOrderAdjustment(testCase.Id,TestDataSetupUtil.order1.Id,TestDataSetupUtil.acct.Id);
	        ApexPages.StandardController sc1 = new ApexPages.StandardController(testOrderAdjustment);               
	        OrderAdjustmentController orderAdjController1 = new OrderAdjustmentController(sc1);
        Test.stopTest();
    }
    
    testMethod static void testExistingAdjustment(){
        setupTestData();
        RecordType refundRecType = [SELECT Id FROM RecordType WHERE DeveloperName = 'Refund' AND sObjectType = 'Order_Adjustment__c' AND IsActive = true limit 1];
        // Updating Order adjustment details to work withoout case and related order
        testOrderAdjustment.Related_Order_Payment_Type__c = 'Cash';
        testOrderAdjustment.Related_Order__c = null;
        testOrderAdjustment.Related_Case__c = null;
        update testOrderAdjustment;
        createAdjustmentLineItems(testOrderAdjustment.Id,5);
        Test.startTest();
	        Test.setCurrentPageReference(Page.OrderAdjustmentPage);
	        ApexPages.StandardController sc = new ApexPages.StandardController(testOrderAdjustment);               
	        OrderAdjustmentController orderAdjController = new OrderAdjustmentController(sc);
	        orderAdjController.orderAdj.RecordTypeId = refundRecType.Id ;
	        List<SelectOption> ops = orderAdjController.getRefundMethods();
	        
	        //updating existing order adjustmnet along with line items
	        orderAdjController.orderAdj.Refund_or_Misc_Amount__c = 25 ;
	        orderAdjController.orderAdj.Refund_Type__c = 'Partial Refund';
	        orderAdjController.orderAdj.Payment_Method__c = 'Cash';
	        list<Order_Adjustment_Line_Item__c> adjolis = orderAdjController.adjlineItemsList;
	        adjolis.get(0).isChecked__c = true;
	        orderAdjController.renderComponents();
	        orderAdjController.createOrderAdjustment();
	        
	        // Full refund
	        orderAdjController.orderAdj.Refund_Type__c = 'Full Refund';
	        orderAdjController.renderComponents();
	        orderAdjController.createOrderAdjustment();
	        //if full refund is successful, all the line items should have Related_Order_Adjustment__c lookup
	        for(Order_Adjustment_Line_Item__c oaoli :[select Id,isChecked__c from Order_Adjustment_Line_Item__c where Id = : testOrderAdjustment.id] )
	        {
	            system.assert(oaoli.isChecked__c);    
	        }
	    Test.stopTest();
    }
    

}