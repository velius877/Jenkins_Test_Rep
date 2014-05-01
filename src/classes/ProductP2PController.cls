public with sharing class ProductP2PController {
private ApexPages.StandardController ctrl;
  public Item__C Item {get;set;}
  public boolean isProduct {get;set;}
  public List <Item__c> productList {get;set;}
  public ProductP2PController(ApexPages.StandardController stdController){
      ctrl = stdController;
      Item__C tempitem  = (Item__C) ctrl.getRecord();
      list<Item__C> listtempItem = new list<Item__C>();
      listtempItem = [Select Product_Number__c,Product_Suffix__c From Item__C where Id =: tempitem.Id]; 
      
      if(listtempItem.size() > 0)
            Item = listtempItem[0];
       
       
      //Todo Include source too.
      list<Item__c> U2PProducts = new list<Item__c>();
      isProduct = false;
  }
  public PageReference ShowP2PProducts(){
     
   
   try{
            //Construct Product number and Source ID construct
            string tenantID = NBTYUtils.getSuffixToBrandMappingMap().get(Item.Product_Suffix__c).tenantId__c;

            if(string.isNotBlank(Item.Product_Number__c))
            	productList = NBTYWSUtil.getP2PAgileOneProducts(Item.Product_Number__c + '-' + Item.Product_Suffix__c,tenantID);
            
            
            if(productList.size() > 0)
            	isProduct = True;

            }
            Catch(NBTYException e){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,e.getMessage()));
            }
            Catch(Exception e){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Error in getting P2P recommendations.'));
                system.debug(e.getMessage());
            }

  return null; 
  }
  
    static testMethod void ProductP2PController(){
  	        PageReference pref = Page.ProductP2P;
        	Test.setCurrentPage(pref);
        	TestDataSetupUtil.SetupCoreData(1);
        	            NBTYWSUtilTest.setupData();  
            Item__c i= [select id, product_number__c, Product_Suffix__c from Item__C limit 1];
            i.product_number__c=i.product_suffix__c='0011';
            update i;
            /*
        	account a = [select id, AS_400_Customer_Number__c from Account limit 1];
        	a.AS_400_Customer_Number__c='123';*/
        	Test.startTest();
          	ApexPages.StandardController con = new ApexPages.StandardController(i);
           	ProductP2PController controller = new ProductP2PController(con);
           	controller.ShowP2PProducts();
           	Test.stopTest();
           system.assert(!controller.productList.isEmpty());
  }
 
}