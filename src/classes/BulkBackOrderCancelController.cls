public with sharing class BulkBackOrderCancelController {
public string ProductSKU{get;set;}
//public string ProductSKUPrefix{get;set;}
Public string EffectiveDate{get;set;}
public string ProductPreFix {get ; set ;}
public List<SelectOption> ProductPrefixList {get;set;}
 public BulkBackOrderCancelController(ApexPages.StandardController stdController){
            ProductSKU = '';
            ProductPreFix = '';
            ProductPrefixList = new List<SelectOption>();
            ProductPrefixList.add(new SelectOption('None', '--Select One--'));
            ProductPrefixList.add(new SelectOption('0021', 'Perfectly Pure'));
            ProductPrefixList.add(new SelectOption('0011', 'Puritan\'s Pride'));
            ProductPrefixList.add(new SelectOption('0070', 'Vitamin World'));
            
    }
 
 

public void doCancel()
{
if(isInValidInput())
return;

try{
    	WS_OrderLineItemCancellation.CancelOrderPort wsCancelOrder = new WS_OrderLineItemCancellation.CancelOrderPort();
    	WS_OrderLineItemCancellation.OrderCancellationResponse_element cancelResponse = new WS_OrderLineItemCancellation.OrderCancellationResponse_element();
    	string SFDCOrderNumber = '';
    	
    	  	cancelResponse = wsCancelOrder.CancelOrder(SFDCOrderNumber, SFDCOrderNumber, '4', EffectiveDate, ProductSKU, ProductPreFix, '', '' , '','');
    	  	 
    	//process response
    	if(cancelResponse.Status != 'Success')
    	{
    	ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Error Cancelling order: ' + cancelResponse.StatusCode + '-'+ cancelResponse.StatusMessage ));
    	return;	
    	}
    	else
    	{
    	//Update orderlineitem status
    	ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'Successfully initiated process of Bulk Order Cancellation'));
    	
    	}
    }
    catch(exception e)
    {
    	ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Error invoking cancellation web service'));
    	system.debug('--------Error invoking cancellation Web Service' + e.getmessage());
    	
    }
	
}

private boolean isInValidInput()
{
boolean retVal = false;
if(ProductPreFix == 'None')
{
	ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, '<h3>Please Select Product Type.</h3>'));
	retVal = true;
	return retVal;
}

ProductSKU = orderutilities.zeroLPAD(ProductSKU,6);

List<Item__c> listItem = new List<Item__C>();
listItem = [Select Id From Item__c where Product_Number__c = :ProductSKU and Product_Suffix__c = :ProductPreFix];
if(listItem.size()== 0)
{
	ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, '<h3>Invalid SKU.</h3>'));
	retVal = true;
}
Date dttoday = Date.today();
try{
	date dtEffective = date.parse(EffectiveDate);
	if(dtEffective > dttoday)
	{
	ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, '<h3>Selected date should not be a future date.</h3>'));
	retVal = true;
	}
	
}
catch(exception e)
{
	ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, '<h3>Invalid Effective date.</h3>'));
	retVal = true;
}
return retVal;	
}


}