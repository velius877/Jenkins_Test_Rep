@isTest
global class MockResponse_LotNumberQuery implements WebServiceMock {
	  global void doInvoke(
           Object stub,
           Object request,
           Map<String, Object> response,
           String endpoint,
           String soapAction,
           String requestName,
           String responseNS,
           String responseName,
           String responseType) {
         
           ws_Soa_LotNumberQuery.LotNumberQueryResponse_element lnResponse = new ws_Soa_LotNumberQuery.LotNumberQueryResponse_element();
           ws_Soa_LotNumberQuery.LotNumberQuerySuccess LotNumberQuerySuccess = new ws_Soa_LotNumberQuery.LotNumberQuerySuccess ();

                   LotNumberQuerySuccess.LotNumber= '451451';
        LotNumberQuerySuccess.LotNumberSequence='01';
        LotNumberQuerySuccess.ProductSuffix='ANBN';
        LotNumberQuerySuccess.SKU='1660';
        LotNumberQuerySuccess.AS400BulkNumber='01660';
        LotNumberQuerySuccess.MfgSiteDescription='NBTY Manufacturing';
        LotNumberQuerySuccess.PkgSiteDescription='Packaging 123';
        LotNumberQuerySuccess.ExpirationDate='07/31/2016';
        LotNumberQuerySuccess.VendorLotNumber='123';
        LotNumberQuerySuccess.FormulaRevision='00';
        LotNumberQuerySuccess.LabelRevision='123';
        LotNumberQuerySuccess.LabelNumber='123';
        LotNumberQuerySuccess.BulkDescription='(H)FLUSH FREE NIACIN 500 MG CAPSULE)';
        LotNumberQuerySuccess.OracleProductNumber='100011932';
        LotNumberQuerySuccess.OracleBulkNumber='100016090';
           
           lnResponse.LotNumberQuerySuccess = LotNumberQuerySuccess;
           
               
    
    response.put('response_x', lnResponse);
                  
           }
	
}