@isTest
public class OrderLineItemTriggerHelperTest {
	
	static testMethod void testOliTrigger(){
		test.startTest();
		testDataSetupUtil.SetupCoreData(2);
		Order_Line_Items__c testOli = [select name, order__r.name, line_number__c from order_line_items__c where order__c=:testDataSetupUtil.order1.id and line_number__c='1' limit 1];
		system.debug('testOli~~~'+testOli);
		Order_Line_Items__c testOli2 = [select id, name, order__r.name, line_number__c from order_line_items__c where order__c=:testDataSetupUtil.order1.id and line_number__c='2' limit 1];
		system.assertEquals(testOli.name,testOli.order__r.name+'-1');
		delete testOli;
			 testOli2 = [select name, order__r.name, line_number__c from order_line_items__c where id=:testOli2.id limit 1];
		system.assertEquals(testOli2.line_number__c,'1');
		
		
	}
	
	static testMethod void testRestrictedItems(){
		testDataSetupUtil.SetupCoreData(2);
		
		Orders__c testOrd = [select id, ship_to_address__c from Orders__c where id =:testDataSetupUtil.order1.id];
		Order_Line_Items__c testOli = [select id, product_name__c from order_line_items__c where order__c=:testDataSetupUtil.order1.id and line_number__c='1' limit 1];
		Item_Restriction__c itemr = new Item_Restriction__c(item__c=testOli.product_name__c, Restriction_Text__c='This item cannot be shipped to Japan.');
		insert itemr;
		system.debug('itemr~~~~'+itemr);
		Address__c addr = new Address__c(id=testOrd.ship_to_address__c,Country__c='JP', Country_Picklist__c='JAPAN');
		update addr;
		Order_Line_Items__c oli = new Order_Line_Items__c(product_Name__c=testOli.product_name__c, order__c=testOrd.id);
		boolean bFailed = false;
		test.startTest();
		try {
			insert oli;
					system.debug('oli~~~~'+oli);
		}
		catch (exception e){
			bFailed = true;
		}
		test.stopTest();
		system.assert(bFailed);
	}
	
	static testMethod void testSetShipComplete(){
		TestDataSetupUtil.SetupCoreData(3);
		
		List<Order_Line_Items__c> oli = TestDataSetupUtil.oliList;
		List<Order_Line_Items__c> empty = new List<Order_Line_Items__c>();
		List<Orders__c> emptyOrders = new List<Orders__c>();
		List<Orders__c> orders = new List<Orders__c>();
		orders.add(TestDataSetupUtil.order1);
		Test.startTest();
		
		OrderLineItemTriggerHelper.setShipCompleteStatus(oli, emptyOrders);
		OrderLineItemTriggerHelper.setShipCompleteStatus(empty, orders);
		
		Test.stopTest();
	}
}