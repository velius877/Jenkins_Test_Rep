public with sharing class CaseClone {
	
	public Case c {get;set;}
	public Case cloneCase {get;set;}
	public Adverse_Event_Review__c cloneEventReview;
	public List<Adverse_Event_Review__c> eventReview;
	public Nutrition_Review__c cloneNutritionReview;
	public List<Nutrition_Review__c> nutritionReview;
	public Affected_Item__c cloneAffectedItem;
	public List<Affected_Item__c> affectedItems;
	public List<Affected_Item__c> cloneAffectedItemsList;
	
	public CaseClone(ApexPages.StandardController controller) 
	{
		String cId = controller.getId();
		system.debug('---------------' + cId);
		c = [Select Reporter__c, Reporter_Zip_Code__c, Reporter_Street__c, Reporter_State_Picklist__c, 
			Reporter_Relationship_to_Consumer__c, Reporter_Phone__c, Reporter_Name_del__c, Reporter_Email__c, Reporter_Country__c, Reporter_City__c, Reporter_Apt__c, 
			Consumer__c, Consumer_Zip_Code__c, Consumer_Street__c, Consumer_State_Picklist__c, Consumer_Species__c, Consumer_Satisfied__c, Consumer_Sample_Requested__c, Consumer_Sample_Location__c, Consumer_Response_Required__c, 
			Consumer_Phone__c, Consumer_Name__c, Consumer_Email__c, Consumer_Country__c, Consumer_City__c, Consumer_Apt__c, Category__c, Subcategory__c, RecordTypeId, 
			RecordType.DeveloperName, Complaint_Type__c, CT_Category__c, CT_Subcategory__c  From Case c WHERE Id = :cId];
			
		system.debug('---------------' + c);
	}

	public PageReference init()
	{
		cloneCase = c.clone(false, true, false, false);
		insert cloneCase;
		
		/*eventReview = [SELECT AER_Comments__c, AER_Related_Case__c, AER_Status__c, Assesment__c, Medwatch__c, Prosar_Case__c, Reviewer__c 
			FROM Adverse_Event_Review__c WHERE AER_Related_Case__c =: c.Id LIMIT 1];
			
		if(eventReview.size() == 0){
			eventReview = new List<Adverse_Event_Review__c>();
		}else{
			for(Adverse_Event_Review__c aReview : eventReview){
				cloneEventReview = aReview.clone(false, true, false, false);
			}	
			cloneEventReview.AER_Related_Case__c = cloneCase.Id;
			insert cloneEventReview;		
		}	
		
		nutritionReview = [SELECT NR_Associated_Case__c, NR_Comments__c, NR_Number__c, NR_Reviewer__c, NR_Status__c, NR_Summary__c 
			FROM Nutrition_Review__c WHERE NR_Associated_Case__c =: c.Id LIMIT 1];
		
		if(nutritionReview.size() == 0){
			nutritionReview = new List<Nutrition_Review__c>();
		}else{
			for(Nutrition_Review__c aReview : nutritionReview){
				cloneNutritionReview = aReview.clone(false, true, false, false);
			}
			cloneNutritionReview.NR_Associated_Case__c = cloneCase.Id;
			insert cloneNutritionReview;			
		}
		
		
		affectedItems = [SELECT Brand__c, Case__c, Expiration_Date__c, Formula_Revision__c, Item_Number__c, Label_Revision_Code__c, Manufacturing_Site__c, NBTY_Lot__c,
			Oracle_Bulk_Number__c, Oracle_Product_Number__c, Packaging_Site__c, Vendor_Lot__c FROM Affected_Item__c WHERE Case__c =: c.Id];
		
		if(affectedItems.size() == 0){
			affectedItems = new List<Affected_Item__c>();
		}else{
			for(Affected_Item__c anAffectedItem : affectedItems){
				cloneAffectedItem = anAffectedItem.clone(false, true, false, false);
				cloneAffectedItem.Case__c = cloneCase.Id;
				cloneAffectedItemsList.add(cloneAffectedItem);
			}
			insert cloneAffectedItemsList;			
		}*/

		string redirectStr;
		if(c.RecordType.DeveloperName == 'Product_Complaint'){
			redirectStr = '/apex/Case_ICM?retURL=%2F' + cloneCase.Id + '&id=' + cloneCase.Id;
		}else{
			redirectStr = '/'+cloneCase.id + '/e?retURL=%2F' + cloneCase.id + '&nooverride=1';
		}
		PageReference pageRef = new PageReference(redirectStr);
		pageRef.setRedirect(true);
		return pageRef;
	}
}