public with sharing class OrderLineItemArchiveSnippet {
	
	public Orders__c orderSObj {get;set;}
	public List <Order_Line_Items__c> oliList {get;set;}
	public string testString ;


	public OrderLineItemArchiveSnippet(ApexPages.StandardController stdController){
		oliList = new List <Order_Line_Items__c>();
		testString = '1,0011001480,1,1,UPS,4.99#2,0011001480,1,1,UPS,4.99#3,0011001480,1,1,UPS,4.99#4,0011001480,1,1,UPS,4.99';
		system.debug(testString);
      	orderSObj  = (Orders__c) stdController.getRecord();
      	orderSObj =[ select id, Archive_Summary__c, order_Status__c,archived__c from Orders__c where Id =:orderSObj.id];
      	if (orderSObj.Archive_Summary__c!=null){
      		orderSObj.Archived__c=true;
      	 oliList = OrderLineItemArchiveUtilities.restoreOlisFromArchive(orderSObj);
      	}
	 SYSTEM.DEBUG(oliList);
	}

	

	
}