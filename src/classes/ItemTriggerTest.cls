@isTest
public with sharing class ItemTriggerTest {

	static testMethod void testItem(){
		TestDataSetupUtil.SetupCoreData(2);
		Item__c[] itemList = [select product_suffix__c, product_number__c, id from Item__c];
		system.assertEquals(2, itemlist.size());
		itemList[0].substitute_item_number__c = '009991';
		update itemList;
		system.assertEquals([select id from Item__c where product_number__c =:itemList[0].substitute_item_number__c].id, 
													[select substitute_item__c from Item__c where id =:itemList[0].id].substitute_item__c);
	} 
	
	static testMethod void testBackOrderUpdate(){
		TestDataSetupUtil.SetupCoreData(2);
		Item__c[] itemList = [select available_inventory__c, product_suffix__c, product_number__c, id from Item__c];
		itemList[0].Available_Inventory__c='-999';
		test.startTest();
		update itemList[0];
		test.stopTest();
		Item__c[] itemList2 = [select backorder__c, product_suffix__c, product_number__c, id from Item__c];
		system.assert(itemList2[0].backorder__c);
	}
}