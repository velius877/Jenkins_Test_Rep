@isTest
public class WS_webstack_PromotionObjects_v2_Test 
{
	testmethod static void testApplyPromotionRequest()
	{
		TestDataSetupUtil.SetupCoreData(1);
		
		Test.startTest();  
		
			OrderWizard_Wrapper OWWrap = new OrderWizard_Wrapper(TestDataSetupUtil.order1);
			WS_webstack_PromotionObjects_v2.ApplyPromotionRequest APReq1 = new WS_webstack_PromotionObjects_v2.ApplyPromotionRequest(OWWrap);			
			System.assert(APReq1.Items.size() == 1);
						
		Test.stopTest();
		
		
	}
	
	testmethod static void testApplyPromotionResponse()
	{
		TestDataSetupUtil.SetupCoreData(1);
		
		Test.startTest();  
		
			OrderWizard_Wrapper OWWrap = new OrderWizard_Wrapper(TestDataSetupUtil.order1);						
			WS_webstack_PromotionObjects_v2.ApplyPromotionResponse APRes = new WS_webstack_PromotionObjects_v2.ApplyPromotionResponse();			
			WS_webstack_PromotionObjects_v2.ResponseItem ResItem = new WS_webstack_PromotionObjects_v2.ResponseItem();
			WS_webstack_PromotionObjects_v2.Allowance ResAllowance = new WS_webstack_PromotionObjects_v2.Allowance();
			WS_webstack_PromotionObjects_v2.ApplyPromotionResponseData PromoResData = new WS_webstack_PromotionObjects_v2.ApplyPromotionResponseData();		
			
		Test.stopTest();
	}
}