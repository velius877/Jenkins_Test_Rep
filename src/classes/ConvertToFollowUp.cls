public with sharing class ConvertToFollowUp {
	
	public Case c {get;set;}
	public String cId;
	
	public ConvertToFollowUp(ApexPages.StandardController controller)
	{
		cId = controller.getId();
		
		Case c = [Select if_no_why_is_there_no_consumer_response__c, Where__c, When_was_the_product_taken__c, What_was_the_result_of_restarting__c, 
		What_was_the_result_of_discontinuing__c, What_was_product_taken_with__c, What_tests_were_performed__c, Were_lab_or_diagnostic_tests_performed__c, 
		Weight__c, Web_UPC__c, Web_Retailer_Name__c, Web_Product_Number__c, Web_Product_Name__c, Web_Product_Location__c, 
		Web_Lot_Code__c, Web_Job_Title__c, Web_Form_Subject__c, Web_Form_Subject_Formula__c, Web_Form_Last_Name__c, Web_Form_First_Name__c, 
		Web_Form_Email__c, Web_Form_Comments__c, Web_Contact_Type__c, Was_the_product_restarted__c, 
		Was_receipt_included__c, Was_product_taken_with_food_or_beverage__c, Unidentified_Product__c, Unidentified_Product_Description__c, 
		URL__c, Type, Treatment_for_Event__c, Total_Refund_Amount__c, Test_Results__c, Tech_Response__c, 
		//Tech_Questions__c, SystemModstamp, 
		SuppliedPhone, SuppliedName, SuppliedEmail, SuppliedCompany, Supervisor_Comments__c, Subject, Subcategory__c, Status, Standard_Response__c, 
		Sex__c, Serious_Adverse_Event_Status__c, Sent_to_PQM__c, Sent_to_PQM_Date__c, Send_to_Supervisor__c, Same_as_Reporter__c, 
		Route_of_Administration__c, Reviewer__c, Return__c, Return_Reason__c, Results_Key_Points__c, Results_Consumer_Satisfied__c, 
		Results_Consumer_SatisfiedExplanation__c, Response_To_Inquiry__c, Requested_Action__c, Reporter__c, Reporter_Zip_Code__c, 
		Reporter_Street__c, Reporter_State__c, Reporter_State_Picklist__c, Reporter_Relationship_to_Consumer__c, Reporter_Phone__c, 
		Reporter_Name_del__c, Reporter_Email__c, Reporter_Country__c, Reporter_City__c, Reporter_Apt__c, Related_Order__c, Rejected__c, 
		Rejected_Reason__c, Regulatory_Agency_Initiated__c, Refund_Notes__c, Reference_Numner__c, RecordTypeId, Receipt_or_SRP_Amount__c, 
		Reaction_Status__c, Product_Received_Date__c, Product_Quantity_Received__c, Product_Quantity_Received_Long__c, Product_Intended_For__c, 
		Product_Complaint_Refund_Type__c, Priority, Prepaid_Label_Sent__c, Prepaid_Label_Sent_Date__c, Prepaid_Label_Sent_By__c, Pregnant__c, 
		Point_of_Purchase__c, ParentId, PQM_Reporter_Country__c, PQM_Number__c, PQM_Consumer_Country__c, OwnerId, Outcome_of_treatment__c, 
		Other_medications_taken_at_same_time__c, Other_Medications_OTCs_Name__c, Other_Medications_OTCs_Indication__c, Other_Medications_OTCs_Dosage__c, 
		Other_Medications_OTCs_Dates_Used__c, Original_To__c, Original_From__c, Origin, Nutrition_Review_Summary__c, Medical_History__c, 
		 Known_Allergies_Picklist__c, Item__c, IsEscalated,  
		IsClosed, Investigation_for_Consumer_Response__c, Investigation_Summary__c, Investigation_Requested__c, International_Complaint__c, 
		Internal_Notes__c, Intake_Department__c, If_yes_what_was_the_result__c, If_no_what_is_the_reaction_status__c, If_no_explain__c, 
		Identification_Sent__c, Identification_Received__c, Id, ICM_Number__c, How_often__c, How_many__c,  
		How_Much_Ingested_or_Applied__c, Hospital_Address__c, Height__c, Has_the_reaction_subsided__c, HCP_Type__c, HCP_Phone__c, HCP_Full_Name__c, 
		HCP_Contact_Info__c, HCP_Address__c, Follow_Up_Refund_Type__c, Final_Approval_Reviewer__c, Final_Approval_Complete_Date__c, Escalated__c, 
		Did_consumer_visit_an_Emergency_Room__c, Did_consumer_visit_a_HCP_for_this_event__c, Did_a_Consumer_prompt_your_web_case__c, 
		Did_Consumer_Make_a_Demand__c, Did_Consumer_Discontinue_the_Product__c, Description, Date_Visited_HCP__c, Date_Started_Product__c, 
		Date_Reaction_Ended__c, Date_Reaction_Began__c, Date_Ended_Product__c, Customer_is_Reporter__c, Customer_is_Consumer__c, Customer__c, 
		Customer_Requested_Action__c, Current_Reaction_Status__c, CurrencyIsoCode, CreatedDate, CreatedById, Coupon_Quantity__c, Coupon_Amount__c, 
		Contact_Driver__c, Consumer__c, Consumer_Zip_Code__c, Consumer_Street__c, Consumer_Street_2__c, Consumer_State__c, Consumer_State_Picklist__c, 
		Consumer_Species__c, Consumer_Satisfied__c, Consumer_Sample_Requested__c, Consumer_Sample_Location__c, Consumer_Response_Required__c, 
		Consumer_Response_RequiredDetail__c, Consumer_Phone__c, Consumer_Number__c, Consumer_Name__c, Consumer_Email__c, Consumer_Country__c, 
		Consumer_City__c, Consumer_Apt__c, Completed_Date__c, Complaint_Type__c, Complaint_Resolution__c, Closing_Reason_Long__c, Closing_Comments__c, 
		ClosedDate, Cisco_Formula__c, Category__c, Case_Sub_Reason__c, Case_Resolution__c, Case_Reason__c, Case_Driver__c, Closing_Reason__c,
		Case_Description__c, CaseNumber, CT_Subcategory__c, CT_Category__c, CTI_Search__c, Brand__c, Birth_Date__c, Bayer_Complaint__c, 
		Allergy_Description__c, Agile_Status__c, Agile_Status_Description__c, Admitted_to_hospital_for_observation__c, AccountId, AER_Created__c 
		From Case Where Id = :cId LIMIT 1];
	}
	
	public PageReference init()
	{
		RecordType rt = [SELECT Id, Name FROM RecordType WHERE Name = :'Follow-Up'];
		Schema.DescribeSObjectResult caseDescribe = Case.SObjectType.getDescribe();
		
		string redirectStr = '/' + caseDescribe.getKeyPrefix() + '/e?retURL=%2F' + cId + '&RecordType='+ rt.Id + '&id=' + cId + '&nooverride=1';
		PageReference pageRef = new PageReference(redirectStr);
		pageRef.setRedirect(true);
		return pageRef;
	}

}