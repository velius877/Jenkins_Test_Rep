/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
global class MockControllerCallout implements WebServiceMock { 
	global void doInvoke(Object stub, Object request,Map<String, Object> response,String endpoint,
    					String soapAction, String requestName,String responseNS,String responseName,
    					String responseType){
    	WS_SOA_Payment_DS_V2.SFSearchPaymentProfileByProfileIDResponse_element response_x = new WS_SOA_Payment_DS_V2.SFSearchPaymentProfileByProfileIDResponse_element();
    	response_x.Tokens = new List <WS_SOA_Payment_DS_V2.tokens_Element>();
    	WS_SOA_Payment_DS_V2.tokens_Element token = new WS_SOA_Payment_DS_V2.tokens_Element();
    	token.CreditCardExpiryDate='201302';
    	token.NameOnTheCreditCard='Apple';
    	token.CreditCardTypeID=1;
    	token.TokenNumber='1234-1234';
    	    	response_x.tokens.add(token);
    	response.put('response_x', response_x);
    }
}