@isTest
global class MockResponse_CaseCreateService  implements WebServiceMock {
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
		
		
			ws_Soa_caseCreateService_v2.ComplaintUpdateResult result = new ws_Soa_caseCreateService_v2.ComplaintUpdateResult ();
			result.result = 0;
			

			response.put('response_x', result);
				
		}
}