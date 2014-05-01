public with sharing class ws_Soa_LotNumberQueryUtils {
	
	public static ws_Soa_LotNumberQuery.LotNumberQueryRequest_element initRequest( Case_ICM.AffectedItem ai)
	{
		ws_Soa_LotNumberQuery.LotNumberQueryRequest_element lnRequest = new ws_Soa_LotNumberQuery.LotNumberQueryRequest_element();
	
		Item__c selectedProduct;
		try {
			selectedProduct = [select product_suffix__c, product_number__c, id from Item__c where id =:ai.prdDetail.Item__c];
		}
		
		catch (exception e){
		/*		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select a valid product.'));
				return null;*/
		}
		lnRequest.LotNumber = ai.prdDetail.NBTY_Lot__c;
		lnRequest.LotNumberSequence = ai.prdDetail.Lot_Number_Sequence__c;
		if (selectedProduct!=null){
			if (selectedProduct.Product_Suffix__c!=null){
				lnRequest.ProductSuffix =  selectedProduct.Product_Suffix__c;
			} 
			lnRequest.SKU =  selectedProduct.Product_Number__c.startsWith('0')? selectedProduct.Product_Number__c.replaceFirst('^0+(?!$)', '') :selectedProduct.Product_Number__c;//remove leading zeros
		}
		system.debug('+++++++++++ ' + lnRequest.LotNumber); 
		system.debug('+++++++++++ ' + lnRequest.LotNumberSequence);
		system.debug('+++++++++++ ' + lnRequest.ProductSuffix);
		system.debug('+++++++++++ ' + lnRequest.SKU);
		//system.debug('+++++++++++ ' + lnRequest.SKU);
		return lnRequest;
	}
	
	public static Affected_Item__c parseResponse (Affected_Item__c prdDetail, ws_Soa_LotNumberQuery.LotNumberQueryResponse_element lnResponse){
		if(lnResponse.LotNumberQuerySuccess != null)
		{
			prdDetail.NBTY_Lot__c = lnResponse.LotNumberQuerySuccess.lotNumber;
			prdDetail.Lot_Number_Sequence__c = lnResponse.LotNumberQuerySuccess.lotNumberSequence;
			prdDetail.Product_Suffix__c = lnResponse.LotNumberQuerySuccess.productSuffix;
			prdDetail.sku__c = lnResponse.LotNumberQuerySuccess.sku;
			prdDetail.Packaging_Site__c = lnResponse.LotNumberQuerySuccess.pkgSiteDescription;
			prdDetail.Manufacturing_Site__c = lnResponse.LotNumberQuerySuccess.mfgSiteDescription;
			prdDetail.Vendor_Lot__c = lnResponse.LotNumberQuerySuccess.vendorLotNumber;
			prdDetail.Formula_Revision__c = lnResponse.LotNumberQuerySuccess.formulaRevision;
			prdDetail.Bulk_Number__c = lnResponse.LotNumberQuerySuccess.AS400BulkNumber;
			prdDetail.Bulk_Description__c = lnResponse.LotNumberQuerySuccess.bulkDescription;
			prdDetail.oracle_bulk_number__c = lnResponse.LotNumberQuerySuccess.OracleBulkNumber;
			prdDetail.oracle_product_number__c =  lnResponse.LotNumberQuerySuccess.OracleProductNumber;
			prdDetail.Expiration_Date__c = lnResponse.LotNumberQuerySuccess.ExpirationDate; 
			prdDetail.Label_Revision_Code__c = lnResponse.LotNumberQuerySuccess.LabelRevision;
			prdDetail.Label_Number__c = lnResponse.LotNumberQuerySuccess.LabelNumber;
			
		}
		return prdDetail;
	}

}