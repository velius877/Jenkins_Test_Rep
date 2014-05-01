@isTest
private class OrderLineItemArchiveTest {

             
                
        static testMethod void testArchiveSummary(){
         	testDataSetupUtil.SetupCoreData(2);
         	//OrderLineItemArchiveUtilities.archiveLineItems(new Set <Id>{testDataSetupUtil.order1.id});
         	
         	testDataSetupUtil.order1.Order_Status__c = 'Shipped/Complete';
         	update testDataSetupUtil.order1;
         	OrderLineItemArchiveUtilities.archiveLineItems(new Set <Id>{testDataSetupUtil.order1.id});
         	system.assertEquals(0, [select count() from Order_Line_Items__c where order__c =:testDataSetupUtil.order1.id ]);
         	PageReference pref = Page.OrderLineItemArchiveSnippet;
        	Test.setCurrentPage(pref);
        	test.startTest();
        	ApexPages.StandardController con = new ApexPages.StandardController(testDataSetupUtil.order1);
            OrderLineItemArchiveSnippet controller = new OrderLineItemArchiveSnippet(con);
        	
        	
        	test.stopTest();
        	system.assert(controller.oliList[0].final_price__c==10.00);
         }
}