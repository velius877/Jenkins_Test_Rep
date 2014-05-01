public with sharing class ws_Soa_CaseCreateServiceUtils {
	
	public static Case c; 
	public static List<CaseComment> currentCaseComments = new List<CaseComment>();
	public static boolean bAdverseEventReviewCreated = false;
	public static boolean bHasAffectedItems = false;

	
		public static string mapOriginOfComplaint (){

/*		
		Bizzare Voice
Bulk Customer
E-mail
Fax
Inbound Phone Call
Letter
Live Chat
Outbound Phone Call
Puritan's Pride Website
Social Media
Vitamin World Store Report*/
		if (c.Origin=='Phone') return 'Inbound Phone Call';
		
		else return c.Origin;
		
	}
	 
	 
	public static ws_Soa_CaseCreateService_v2.ComplaintDataInput init(Id cId){
		c = [Select Unidentified_Product_Description__c, Unidentified_Product__c, if_no_why_is_there_no_consumer_response__c, Where__c, When_was_the_product_taken__c, What_was_the_result_of_restarting__c, 
			What_was_the_result_of_discontinuing__c, Case_Description__c, What_was_product_taken_with__c, What_tests_were_performed__c, Were_lab_or_diagnostic_tests_performed__c, 
			Weight__c, Web_Form_Subject__c, Web_Form_Subject_Formula__c, Web_Form_Last_Name__c, Web_Form_First_Name__c, Web_Form_Email__c,
			Web_Form_Comments__c, Was_the_product_restarted__c, Was_receipt_included__c, Was_product_taken_with_food_or_beverage__c, 
			URL__c, Type, Treatment_for_Event__c, Total_Refund_Amount__c, Test_Results__c, Tech_Response__c,
			// Tech_Questions__c, SystemModstamp, 
			SuppliedPhone, SuppliedName, SuppliedEmail, SuppliedCompany, Supervisor_Comments__c, Subject, Status, Sex__c, Serious_Adverse_Event_Status__c, 
			Send_to_Supervisor__c, Same_as_Reporter__c, Route_of_Administration__c, Return__c, Return_Reason__c, Results_Key_Points__c, 
			Results_Consumer_Satisfied__c, Results_Consumer_SatisfiedExplanation__c, Customer_Requested_Action__c, Reporter__c, Reporter_Zip_Code__c, 
			Reporter_Street__c, Reporter_State_Picklist__c, Reporter_Relationship_to_Consumer__c, Reporter_Phone__c, Reporter_Name_del__c, Reporter_Email__c, 
			PQM_Reporter_Country__c, Reporter_City__c, Reporter_Apt__c, Related_Order__c, Rejected__c, Rejected_Reason__c, Regulatory_Agency_Initiated__c, 
			Refund_Notes__c, Reference_Numner__c, RecordTypeId, Receipt_or_SRP_Amount__c, current_reaction_status__c, Product_Received_Date__c, 
			Product_Quantity_Received_Long__c, Product_Complaint_Refund_Type__c, Priority, Prepaid_Label_Sent__c, Prepaid_Label_Sent_Date__c, Prepaid_Label_Sent_By__c, 
			Pregnant__c, Point_of_Purchase__c, ParentId, PQM_Number__c, OwnerId, Outcome_of_treatment__c, Other_medications_taken_at_same_time__c, 
			Other_Medications_OTCs_Name__c, Other_Medications_OTCs_Indication__c, Other_Medications_OTCs_Dosage__c, Other_Medications_OTCs_Dates_Used__c, 
			Original_To__c, Original_From__c, Origin, Nutrition_Review_Summary__c, Medical_History__c, 
			LastModifiedDate, LastModifiedById, Known_Allergies_Picklist__c, Item__c, IsEscalated, IsDeleted, IsClosed, Investigation_for_Consumer_Response__c, 
			Investigation_Requested__c, International_Complaint__c, Intake_Department__c, If_yes_what_was_the_result__c, 
			If_no_what_is_the_reaction_status__c, If_no_explain__c, Identification_Sent__c, Identification_Received__c, Id, ICM_Number__c, How_often__c, 
			How_many__c, Hospital_Address__c, Height__c, Has_the_reaction_subsided__c, HCP_Type__c, HCP_Phone__c, HCP_Full_Name__c, HCP_Contact_Info__c, 
			HCP_Address__c, Follow_Up_Refund_Type__c, Final_Approval_Reviewer__c, Final_Approval_Complete_Date__c, Escalated__c, 
			Did_consumer_visit_an_Emergency_Room__c, Did_consumer_visit_a_HCP_for_this_event__c, Did_Consumer_Make_a_Demand__c, 
			Did_Consumer_Discontinue_the_Product__c, Description, Date_Visited_HCP__c, Date_Started_Product__c, Date_Reaction_Ended__c, 
			Date_Reaction_Began__c, Date_Ended_Product__c, Customer_is_Reporter__c, Customer_is_Consumer__c, Customer__c, CurrencyIsoCode, 
			CreatedDate, CreatedById, Coupon_Quantity__c, Coupon_Amount__c, Contact_Driver__c, Consumer__c, Consumer_Zip_Code__c, Consumer_Street__c,
			Consumer_Street_2__c, Consumer_State_Picklist__c, Consumer_Species__c, Consumer_Satisfied__c, Consumer_Sample_Requested__c, Consumer_Sample_Location__c, 
			Consumer_Response_Required__c, Consumer_Response_RequiredDetail__c, Consumer_Phone__c, Consumer_Number__c, Consumer_Name__c, Consumer_Email__c, 
			PQM_Consumer_Country__c, Consumer_City__c, Consumer_Apt__c, Completed_Date__c, Complaint_Type__c, Subcategory__c, Complaint_Resolution__c, 
			Category__c, Closing_Reason__c, Closing_Reason_Long__c, ClosedDate, Cisco_Formula__c, Case_Sub_Reason__c, Case_Resolution__c, 
			Case_Reason__c, Case_Driver__c, CaseNumber, CTI_Search__c, Brand__c, Birth_Date__c, Bayer_Complaint__c, Allergy_Description__c, 
			Admitted_to_hospital_for_observation__c, AccountId, AER_Created__c, How_Much_Ingested_or_Applied__c, Product_Intended_For__c From Case WHERE Id = :cId];
			
			return ComplaintDataMapping(c);
	}
	
	public static List<ws_Soa_CaseCreateService_v2.AERDataInput> AERDataMapping(){
		// DE873 -- Adding __r.Name look ups to query
		List<Adverse_Event_Review__c> currentAER = [SELECT Id, Reviewer__r.Name, Name, Assessment_List__c, AER_Related_Case__c, AER_Number__c,  AER_Comments__c, Reviewer__c, AER_Status__c, Prosar_Case__c, AER_Completed_Date__c, Due_Date__c, Medwatch__c FROM Adverse_Event_Review__c WHERE AER_Related_Case__c =: c.Id ];
		List<ws_Soa_CaseCreateService_v2.AERDataInput> sendingAERList = new List<ws_Soa_CaseCreateService_v2.AERDataInput>();
		for(Adverse_Event_Review__c aReview : currentAER){
			ws_Soa_CaseCreateService_v2.AERDataInput sendingAER = new ws_Soa_CaseCreateService_v2.AERDataInput();
			bAdverseEventReviewCreated = true;
			sendingAER.associatedAERNumber = aReview.Name;
			sendingAER.associatedCaseNumber = ws_Soa_CaseCreateServiceUtils.c.caseNumber;
			sendingAER.assessment = aReview.Assessment_List__c;
			sendingAER.comments = aReview.AER_Comments__c;
			sendingAER.completedDate = aReview.AER_Completed_Date__c;
			sendingAER.dueDate = aReview.Due_Date__c;
			sendingAER.medwatch = aReview.Medwatch__c;
			sendingAER.prosarCase = aReview.Prosar_Case__c;
			sendingAER.reviewer = aReview.Reviewer__r.Name; // DE873 use look up name
			sendingAER.status = aReview.AER_Status__c;
			sendingAERList.add(sendingAER);
		}	
		
		return sendingAERList;
	}
	
	public static ws_Soa_CaseCreateService_v2.ArrayOfNRDataInput NRDataMapping(){
		List<Nutrition_Review__c> currentNR = [SELECT Id,Name, NR_Reviewer__r.Name, NR_Associated_Case__c, NR_Number__c, NR_Comments__c, NR_Completed_Date__c, NR_Reviewer__c, NR_Status__c FROM Nutrition_Review__c WHERE NR_Associated_Case__c =: c.Id ];
		List<ws_Soa_CaseCreateService_v2.NRDataInput> NRList = new List<ws_Soa_CaseCreateService_v2.NRDataInput>();
		ws_Soa_CaseCreateService_v2.ArrayOfNRDataInput sendingNRArray = new ws_Soa_CaseCreateService_v2.ArrayOfNRDataInput();
		for(Nutrition_Review__c aReview : currentNR)
		{
			ws_Soa_CaseCreateService_v2.NRDataInput sendingNR = new ws_Soa_CaseCreateService_v2.NRDataInput();
			sendingNR.associatedCaseNumber = ws_Soa_CaseCreateServiceUtils.c.caseNumber;
			sendingNR.associatedNRNumber = aReview.Name;
			sendingNR.comments = aReview.NR_Comments__c;
			sendingNR.completedDate = aReview.NR_Completed_Date__c;
			sendingNR.reviewer = aReview.NR_Reviewer__r.Name; // DE873 use look up name
			sendingNR.status = aReview.NR_Status__c;
			NRList.add(sendingNR);
		}
		sendingNRArray.item=NRList;
		
		return sendingNRArray;
	}
	
	public static List<ws_Soa_CaseCreateService_v2.ComplaintAffectedItemDataInput> AffectedItemDataMapping(){
		List<Affected_Item__c> currentAI = [SELECT Id,item__c,item__r.oracle_mdm__c, Lot_Number_Sequence__c, Case__c, Item__r.Product_Number__c, Expiration_Date__c, Formula_Revision__c,Label_Revision_Code__c,  Manufacturing_Site__c,NBTY_Lot__c,Oracle_Bulk_Number__c, Oracle_Product_Number__c, Packaging_Site__c   FROM Affected_Item__c WHERE Case__c =: c.Id];
		List<ws_Soa_CaseCreateService_v2.ComplaintAffectedItemDataInput> sendingAIList = new List<ws_Soa_CaseCreateService_v2.ComplaintAffectedItemDataInput>();
		for(Affected_Item__c anItem : currentAI){
			if (anItem.item__c !=null||anItem.Oracle_Product_Number__c!=null||anItem.Oracle_Bulk_Number__c!=null){//DE 686 must have an product
				bHasAffectedItems=true;
				ws_Soa_CaseCreateService_v2.ComplaintAffectedItemDataInput sendingAI = new ws_Soa_CaseCreateService_v2.ComplaintAffectedItemDataInput();
				sendingAI.affectedItemNumber = NBTYUtils.drop_leading_zeros(anItem.Item__r.Product_Number__c);
				sendingAI.associatedCaseNumber =  ws_Soa_CaseCreateServiceUtils.c.caseNumber;
				sendingAI.expirationDate = anItem.Expiration_Date__c;
				sendingAI.formulaRevision = anItem.Formula_Revision__c;
				sendingAI.labelRevisionCode = anItem.Label_Revision_Code__c;
				sendingAI.manufacturingSite = anItem.Manufacturing_Site__c;
				if (anItem.NBTY_Lot__c!=null&&anItem.Lot_Number_Sequence__c!=null	)			sendingAI.nbtyLot =  anItem.NBTY_Lot__c+'-'+anItem.Lot_Number_Sequence__c;
				sendingAI.oracleBulkNumber = anItem.Oracle_Bulk_Number__c;
				sendingAI.oracleProductNumber = anItem.Oracle_Product_Number__c ==null? anItem.item__r.oracle_mdm__c : anItem.Oracle_Product_Number__c;
				sendingAI.packagingSite = anItem.Packaging_Site__c; 
				sendingAIList.add(sendingAI);
			}
		}
		
		return sendingAIList;
	}
	
	public static String ConvertBoolToString(Boolean boolConversion){
		if(boolConversion){
			return 'Yes';
		}else{
			return 'No';
		}
	}
	
	public static ws_Soa_CaseCreateService_v2.ComplaintDataInput ComplaintDataMapping(Case currentCase){ 
		currentCaseComments = [SELECT CommentBody FROM CaseComment WHERE ParentId = : c.Id];
		ws_Soa_CaseCreateService_v2.ComplaintDataInput sendingCase = new ws_Soa_CaseCreateService_v2.ComplaintDataInput();
		sendingCase.adverseEventReviews = new ws_Soa_CaseCreateService_v2.ArrayOfAERDataInput();
		sendingCase.adverseEventReviews.item = AERDataMapping();
		sendingCase.adverseEventReviewCreated = bAdverseEventReviewCreated? 'Yes': 'No';
		sendingCase.affectedItems  = new ws_Soa_CaseCreateService_v2.ArrayOfComplaintAffectedItemDataInput();
		sendingCase.affectedItems.item = AffectedItemDataMapping();
		if (currentCase.Unidentified_Product__c) bHasAffectedItems = true;
		if (!bHasAffectedItems){ 
			currentCase.Agile_Status__c = '-98';//missing affected items
			caseTriggerHelper.alreadyFired=true;
			update currentCase;
			system.debug(currentCase.Agile_Status__c);
		}else {
			sendingCase.afterDiscontinuingProductWasProductRestarted = currentCase.Was_the_product_restarted__c;
			sendingCase.allergyDescription = currentCase.Allergy_Description__c;
			sendingCase.anyKnownAllergies = currentCase.Known_Allergies_Picklist__c;
			sendingCase.associatedCaseNumber = currentCase.CaseNumber;
			sendingCase.bayerComplaint = convertBoolToString(currentCase.Bayer_Complaint__c);
			sendingCase.birthDate = String.valueOf(currentCase.Birth_Date__c);
			sendingCase.brand = currentCase.Brand__c;
			sendingCase.complaintCategory = new ws_Soa_CaseCreateService_v2.ArrayOf_xsd_string();
			sendingCase.complaintSubCategory = new ws_Soa_CaseCreateService_v2.ArrayOf_xsd_string();
			sendingCase.complaintCategory.item = new List <String>();
			sendingCase.complaintSubCategory.item = new List <String>();
			List<Case> listOfComplaintCategories = [SELECT CT_Category__c, CT_Subcategory__c, Category__c, Subcategory__c FROM Case WHERE Id =: c.Id];
			system.debug('---------------------------------------------------listOfComplaintCategories: ' + listOfComplaintCategories);
			string tempCategory;
			for(Case aCase : listOfComplaintCategories){ 
				if (aCase.Category__c!=null){
					integer i = 0;
					List<String> complaintTypeCategorySplit = new List<String>();
					
					//DEFECT: GA fix null reference issue - 11/19/2013
					/*for(Case aComplaintType : listOfComplaintCategories){
						complaintTypeCategorySplit = aComplaintType.CT_Category__c.split(';');
					}*/
					complaintTypeCategorySplit = aCase.CT_Category__c.split(';');
					//END Defect fix
				
					if (aCase.Category__c.contains(';')){
						for(String aCategory : aCase.Category__c.split(';')){
							sendingCase.complaintCategory.item.add(complaintTypeCategorySplit[i]+'|'+aCategory);
							i++;
						}
					}else {
						sendingCase.complaintCategory.item.add(complaintTypeCategorySplit[i]+'|'+aCase.Category__c);
					}
				}
				if (aCase.Subcategory__c!=null){
					integer i = 0;
					
					List<String> complaintTypeSubcategorySplit = new List<String>();
					
					//DEFECT: GA fix null reference issue - 11/19/2013
					/*for(Case aSubcategoryType : listOfComplaintCategories){
						complaintTypeSubcategorySplit = aSubcategoryType.CT_Subcategory__c.split(';');
					}*/
					complaintTypeSubcategorySplit = aCase.CT_Subcategory__c.split(';');
					//END Defect fix
					
					if (aCase.Subcategory__c.contains(';')){
						for(String aSubcategory : aCase.Subcategory__c.split(';')){
							sendingCase.complaintSubcategory.item.add(complaintTypeSubcategorySplit[i]+'|'+aSubcategory);
							i++;
						}	
					}else { 
						sendingCase.complaintSubcategory.item.add(complaintTypeSubcategorySplit[i]+'|'+aCase.Subcategory__c);
					}
				}
			}
			system.debug('sendingCase.complaintSubcategory~~~~'+sendingCase.complaintSubcategory);
			system.debug('sendingCase.complaintCategory~~~~'+sendingCase.complaintCategory);
			
			sendingCase.complaintType = currentCase.Complaint_Type__c;
			sendingCase.consumerApt = currentCase.Consumer_Apt__c;
			sendingCase.consumerCity = currentCase.Consumer_City__c;
			sendingCase.consumerCountry = currentCase.PQM_Consumer_Country__c;
			sendingCase.consumerEMail = currentCase.Consumer_Email__c;
			sendingCase.consumerName = currentCase.Consumer_Name__c;
			sendingCase.consumerNumber = currentCase.Consumer_Number__c;
			sendingCase.consumerPhone = currentCase.Consumer_Phone__c;
			sendingCase.consumerResponseRequired = currentCase.Consumer_Response_Required__c==null ? 'No' : currentCase.Consumer_Response_Required__c;
			sendingCase.consumerSameAsReporter = ConvertBoolToString(currentCase.Same_as_Reporter__c);
			sendingCase.consumerSampleLocation = currentCase.Consumer_Sample_Location__c;
			sendingCase.consumerSpecies = currentCase.Consumer_Species__c;
			sendingCase.consumerState = currentCase.Consumer_State_Picklist__c;
			sendingCase.consumerStreet = currentCase.Consumer_Street__c;
			sendingCase.consumerZipCode = currentCase.Consumer_Zip_Code__c;
			sendingCase.couponAmount = currentCase.Coupon_Amount__c;
			sendingCase.couponQuantity = currentCase.Coupon_Quantity__c;
			sendingCase.dateEndedProduct = currentCase.Date_Ended_Product__c;
			sendingCase.dateReactionBegan = currentCase.Date_Reaction_Began__c;
			sendingCase.dateReactionEnded = currentCase.Date_Reaction_Ended__c;
			sendingCase.dateStartedProduct = currentCase.Date_Started_Product__c;
			sendingCase.datesWentToHCP = currentCase.Date_Visited_HCP__c;
			sendingCase.description = currentCase.Case_Description__c;
			sendingCase.didConsumerDiscontinueProduct = currentCase.Did_Consumer_Discontinue_the_Product__c;
			sendingCase.didConsumerMakeDemand = sendingCase.didConsumerMakeDemand == null ? 'No' :  currentCase.Did_Consumer_Make_a_Demand__c;
			sendingCase.erAdmittedHospitalAddress = currentCase.Hospital_Address__c;
			sendingCase.erAdmittedToHospital = currentCase.Admitted_to_hospital_for_observation__c;
			sendingCase.escalated = currentCase.Escalated__c==null ? 'No' : currentCase.Escalated__c;
			sendingCase.finalApprovalCompleteDate = String.valueOf(currentCase.Final_Approval_Complete_Date__c);
			sendingCase.finalApprovalReviewer = currentCase.Final_Approval_Reviewer__c;
			sendingCase.hasReactionSubsidedAtTimeOfCall = currentCase.Has_the_reaction_subsided__c;
			sendingCase.hcpAddress = currentCase.HCP_Address__c;
			sendingCase.hcpContactInfo = currentCase.HCP_Contact_Info__c;
			sendingCase.hcpFullName = currentCase.HCP_Full_Name__c;
			sendingCase.hcpPhone = currentCase.HCP_Phone__c;
			sendingCase.hcpType = currentCase.HCP_Type__c;
			sendingCase.hcpWhere = currentCase.Where__c;
			sendingCase.height = currentCase.Height__c;
			sendingCase.howManyOfProductTaken = currentCase.How_many__c;
			sendingCase.howMuchIngestedOrApplied = currentCase.How_Much_Ingested_or_Applied__c;
			sendingCase.howOftenWasProductTaken = currentCase.How_often__c;
			sendingCase.indemnificationReceived = String.valueOf(currentCase.Identification_Received__c);
			sendingCase.indemnificationSent = String.valueOf(currentCase.Identification_Sent__c);
			sendingCase.intakeDepartment = currentCase.Intake_Department__c;
			sendingCase.internationalComplaint = ConvertBoolToString(currentCase.International_Complaint__c);
			sendingCase.investigationRequested = currentCase.Investigation_Requested__c;
			sendingCase.investigationSummaryforConsumerResponse = currentCase.Investigation_for_Consumer_Response__c;
			sendingCase.keyPointsOfResults = currentCase.Results_Key_Points__c;
			sendingCase.labTestResults = currentCase.Test_Results__c;
			sendingCase.labTestsPerformedForEvent = currentCase.What_tests_were_performed__c;
			sendingCase.medicalHistory = currentCase.Medical_History__c;
			
			for(CaseComment aComment : currentCaseComments){
				if (sendingCase.notes!=null){
					if(sendingCase.notes.length() < 4000){
						// DE875 -- adding field CommentBody also should be += not just = to perform cat
						sendingCase.notes += aComment.CommentBody + ';';
					}
				}else {
					// DE875 -- adding field CommentBody
					sendingCase.notes = aComment.CommentBody + ';';
				}
				 
			}
			sendingCase.nutritionReviewSummary = currentCase.Nutrition_Review_Summary__c;
			sendingCase.nutritionReviews = NRDataMapping();
			sendingCase.originofComplaint = mapOriginOfComplaint();
			sendingCase.otherMedsDatesUsed = currentCase.Other_Medications_OTCs_Dates_Used__c;
			sendingCase.otherMedsDosage = currentCase.Other_Medications_OTCs_Dosage__c;
			sendingCase.otherMedsIndication = currentCase.Other_Medications_OTCs_Indication__c;
			sendingCase.otherMedsName = currentCase.Other_Medications_OTCs_Name__c;
			sendingCase.outcomeofTreatment = currentCase.Outcome_of_treatment__c;
			sendingCase.pointOfPurchase = currentCase.Point_of_Purchase__c;
			sendingCase.pregnant = currentCase.Pregnant__c;
			sendingCase.prepaidLabelSentDate = String.valueOf(currentCase.Prepaid_Label_Sent_Date__c);
			sendingCase.productIntendedFor = currentCase.Product_Intended_For__c;
			sendingCase.productQuantityReceived = currentCase.Product_Quantity_Received_Long__c;
			sendingCase.productReceivedDate = String.valueOf(currentCase.Product_Received_Date__c);
			sendingCase.receiptorSRPAmount = currentCase.Receipt_or_SRP_Amount__c;
			sendingCase.referenceNumber = currentCase.Reference_Numner__c;
			sendingCase.refundNotes = currentCase.Refund_Notes__c;
			sendingCase.regulatoryAgencyInitiated = currentCase.Regulatory_Agency_Initiated__c;
			sendingCase.reporterApt = currentCase.Reporter_Apt__c;
			sendingCase.reporterCity = currentCase.Reporter_City__c;
			sendingCase.reporterCountry = currentCase.PQM_Reporter_Country__c;
			sendingCase.reporterEMail = currentCase.Reporter_Email__c;
			sendingCase.reporterName = currentCase.Reporter_Name_del__c;
			sendingCase.reporterPhone = currentCase.Reporter_Phone__c;
			sendingCase.reporterStreet = currentCase.Reporter_Street__c;
			sendingCase.reporterRelationtoConsumer = currentCase.Reporter_Relationship_to_Consumer__c;
			sendingCase.reporterState = currentCase.Reporter_State_Picklist__c;
			sendingCase.reporterZipCode = currentCase.Reporter_Zip_Code__c;
			sendingCase.requestedAction = currentCase.Customer_Requested_Action__c;
			sendingCase.resultOfProductDiscontinue = currentCase.If_yes_what_was_the_result__c;
			sendingCase.routeOfAdministration = currentCase.Route_of_Administration__c;
			sendingCase.seenByHCP = currentCase.Did_consumer_visit_a_HCP_for_this_event__c;
			sendingCase.seriousAdverseEventStatus = currentCase.Serious_Adverse_Event_Status__c;
			sendingCase.sex = currentCase.Sex__c;
			sendingCase.supervisorComments = currentCase.Supervisor_Comments__c;
		//	sendingCase.techQuestions = currentCase.Tech_Questions__c;
			sendingCase.techReponse = currentCase.Tech_Response__c;
			sendingCase.totalRefundAmount = String.valueOf(currentCase.Total_Refund_Amount__c);
			sendingCase.treatmentforEvent = currentCase.Treatment_for_Event__c;
			sendingCase.wasConsumerSampleRequested = currentCase.Consumer_Sample_Requested__c;
			sendingCase.wasConsumerSatisfied = currentCase.Consumer_Satisfied__c;
			sendingCase.wasConsumerSatisfiedWithResults = sendingCase.wasConsumerSatisfiedWithResults==null? 'No': currentCase.Results_Consumer_Satisfied__c;
			sendingCase.wasReceiptIncluded = currentCase.Was_receipt_included__c;
			sendingCase.weight = String.valueOf(currentCase.Weight__c);
			sendingCase.wentToEr = currentCase.Did_consumer_visit_an_Emergency_Room__c;
			sendingCase.wereAnyLabTestsPerformed = currentCase.Were_lab_or_diagnostic_tests_performed__c;
			sendingCase.whatIsTheStatusOfTheReaction = currentCase.current_reaction_status__c;
			sendingCase.whatWasResultOfStartingProductAgain = currentCase.What_was_the_result_of_restarting__c;
			sendingCase.whatWasTheProductTakenWith = currentCase.What_was_product_taken_with__c;
			sendingCase.whenWasTheProductTaken = currentCase.When_was_the_product_taken__c;
			sendingCase.whyConsumerNotSatisfiedWithResults = currentCase.Results_Consumer_SatisfiedExplanation__c;
			sendingCase.whyDoesntConsumerRequireResponse = currentCase.Consumer_Response_RequiredDetail__c;
			sendingCase.userDefined01 = ConvertBoolToString(currentCase.Unidentified_Product__c); //unidentified product 
			sendingCase.userDefined02 = currentCase.Unidentified_Product_Description__c;
		}
		
		return sendingCase;
	}
	
	public static void lockAllRelatedRecords(Id caseId){
		try {
			List<Affected_Item__c> caseAffectedItems = [SELECT Id, Synced_With_PQM__c FROM Affected_Item__c WHERE Case__c = :caseId];
			List<Other_Medications_OTC__c> caseOTCs = [SELECT Id, Synced_With_PQM__c FROM Other_Medications_OTC__c WHERE OTC_Related_Case__c = :caseId];
			List<Adverse_Event_Review__c> caseAERs = [SELECT Id, Synced_With_PQM__c FROM Adverse_Event_Review__c WHERE AER_Related_Case__c = :caseId];
			List<Nutrition_Review__c> caseNRs = [SELECT Id, Synced_With_PQM__c FROM Nutrition_Review__c WHERE NR_Associated_Case__c = :caseId];
			
			for(Affected_Item__c anItem : caseAffectedItems){
				anItem.Synced_With_PQM__c = 'Yes';
			}
			
			for(Other_Medications_OTC__c anOTC : caseOTCs){
				anOTC.Synced_With_PQM__c = 'Yes';
			}
			
			for(Adverse_Event_Review__c aReview : caseAERs){
				aReview.Synced_With_PQM__c = 'Yes';
			}
			
			for(Nutrition_Review__c aReview : caseNRs){
				aReview.Synced_With_PQM__c = 'Yes';
			}
			
			update caseAffectedItems;
			update caseOTCs;
			update caseAERs;
			update caseNRs;
		}catch (exception e){
			c.Agile_Status__c='-97';//issue updating related objects in Salesforce
			update c;
		}
	}
	
}