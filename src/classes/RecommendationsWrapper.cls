/* RecommendationsWrapper 
*  Wrapper class for Recommendations on Customer page and Order wizard page.
*  2014-01-10:  Not checking for As400 number for new customers/ Pavan Jasthi
*/
public  class RecommendationsWrapper {
    public List <Item__c>   productList {get;set;}
    public Account              acct            {get;set;}
    public Item__c              product     {get;set;}
    public Id                           orderId         {get;set;}
    public string                   tenantId;
    public static string productSuffix;
    public string                   errorMessage    {get;set;}
    public StaticResource brandLogo {get; set;}
    public boolean              hasRecs             {get;set;}
    public RecommendationsWrapper(Id orderId){              
            Orders__c ord = [select Customer__c, id from Orders__c where Id =: orderId ];
            acct = [Select PersonEmail, AS_400_Customer_Number__c,RecordType.Name From Account where id=:ord.Customer__c ];
            tenantId=setTenantIdForAccount(acct);
            initWrapper(true);
    }
    
    public RecommendationsWrapper(Account account){
            hasRecs=false;
            acct = [Select PersonEmail, AS_400_Customer_Number__c,RecordType.DeveloperName, RecordType.name From Account where id=:account.id ];
            tenantId=setTenantIdForAccount(acct);
            this.brandLogo = setBrandLogoForAccount(acct);
            if(string.isBlank(tenantID))
                errorMessage = 'No Recommendation available for customer type: ' + acct.RecordType.Name; 
            else
            {
                initWrapper(true); 
            }
            
            if(productlist== null){
                      
                     // Show API error messages
                     errorMessage = string.isnotblank(errorMessage) ? errorMessage : 'No Recommendations available for this customer.';
                  
            }
            else {
                if (productList.isEmpty()) errorMessage = string.isnotblank(errorMessage) ? errorMessage : 'No Recommendations available for this customer.'; 
                else hasRecs=true;
            }
            
    }
    
    
    public RecommendationsWrapper(Item__c product){
        this.product =product;
         tenantID = NBTYUtils.getSuffixToBrandMappingMap().get(product.Product_Suffix__c).tenantId__c;
        initWrapper(false);
    }
    
    public static string setTenantIdForAccount (Account acct){
        string tenantId;
        string accRecordType = acct.RecordType.DeveloperName;
         system.debug('**** ' + accRecordType);
         Customer_Rec_Type_Brand_Mapping__c rtbm = NBTYUtils.getRecordTypeBrandMappingMap().get(acct.RecordType.DeveloperName);
         tenantID =  rtbm.tenantID__c;
         productSuffix = rtbm.Product_Suffix_c__c;
         return tenantId;
    }
    
    public static StaticResource setBrandLogoForAccount(Account acct){
        StaticResource sr;
        string accRecordType = acct.RecordType.DeveloperName;
        system.debug('**** ' + accRecordType);
        Customer_Rec_Type_Brand_Mapping__c rtbm = NBTYUtils.getRecordTypeBrandMappingMap().get(acct.RecordType.DeveloperName);
        try {
            sr =[ select id, name from StaticResource where name =:rtbm.brand_image__c];
        } 
        catch (exception e){
            system.debug('cannot find logo');
        }
        return sr;
    }
    
    
    public void initWrapper(boolean isU2P){
          try{
                productList = new List <Item__c>();
                List <Bundle__c> bundleList = NBTYWSUtil.getActiveBundles(productSuffix);
                if (!bundleList.isEmpty()){
                    for (Bundle__c b: bundleList){
                        productList.add(b.item__r);
                    }
                }
                if (tenantId!=null){
                    if (isU2P){
                        if(string.isNotBlank(acct.AS_400_Customer_Number__c)){
                            productList.addAll( NBTYWSUtil.getU2PAgileOneProductsByAccountID(acct.AS_400_Customer_Number__c,tenantID));
                        }
                    }
                    else {
                        productList.addAll( NBTYWSUtil.getP2PAgileOneProducts(product.id, tenantID));
                    }
                }
          }
            
          
            Catch(NBTYException e){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,e.getMessage()));
                errorMessage = e.getMessage();
            }
            Catch(Exception e){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Error in getting U2P recommendations.'));
                system.debug(e.getMessage());
            }
    }
}