/********************************************************************************
 ********************************************************************************	
 *  Class			: CaseReadOnlyBatchProcess
 *  Author		  : Acumen Solutions: Mitch Malleo
 *  Modified		: 09/11/13
 *  Description	 : Controller for the ICM page
 *					
 ********************************************************************************
 ********************************************************************************/

global with sharing class Case_ICM {
	
	public Boolean isClassI {get;set;}
	public Boolean isClassIINon {get;set;}
	public Boolean isClassII {get;set;}
	public Boolean isClassIII {get;set;}
	public Boolean isMedia {get;set;}
	public Boolean noneSelect {get;set;}
	public Boolean isWebCase {get;set;}
	public Boolean isEmailCase {get;set;}
	public String comment {get;set;}
	public Boolean sameAsReporter {get;set;}
	private String accountId;
	public Case newCase {get;set;}
	public List<String> categories {get;set;}
	public List<CaseCategoryMapping__c> categories2 {get;set;}
	public List<CaseCategoryMapping__c> categoriesQuery {get;set;}
	public String categorySearch {get;set;}
	public String subcategorySearch {get;set;}
	public List<AffectedItem> affectedItemsList {get;set;}
	public List<OTCTable> OTCTableList {get;set;}
	public List<Other_Medications_OTC__c> OTCTableQuery {get;set;}
	public List<Affected_Item__c> affectedItemsQuery {get;set;}
	public List<Adverse_Event_Review__c> adverseEventReviews {get;set;}
	public List<Nutrition_Review__c> nutritionReviews {get;set;}
	public Adverse_Event_Review__c adverseEventReview {get;set;}
	public Nutrition_Review__c nutritionReview {get;set;}
	public ws_Soa_LotNumberQuery.LotNumberQueryRequest_element lnRequest {get;set;}
	public ws_Soa_LotNumberQuery.LotNumberQueryResponse_element lnResponse {get;set;}
	public string selectedCategoryString {get;set;}
	public List<String> selectedSubcategoryList {get;set;}
	public List<String> selectedSubcategoryListComplaintType {get;set;}
	public List<String> selectedCategoryList {get;set;}
	public List<String> selectedCategoryListComplaintType {get;set;}
	public List<Other_Medications_OTC__c> OTCTableSave {get;set;}
	public CaseComment comm;

	public Case c {get;set;}
	public Case categoryQuery {get;set;}
	
	public Case_ICM(ApexPages.StandardController controller) {
		c = (Case)controller.getRecord();
		system.debug('------------------------------------------------------record type: ' + c.RecordTypeId);
		c.RecordTypeId = ApexPages.currentPage().getParameters().get('RecordType');
		String cId = ApexPages.currentPage().getParameters().get('id');
		lnRequest = new  ws_Soa_LotNumberQuery.LotNumberQueryRequest_element();
		OTCTableList = new List<OTCTable>();
		OTCTableQuery = new List<Other_Medications_OTC__c>();
		affectedItemsQuery = new List<Affected_Item__c>();
		affectedItemsList = new List<AffectedItem>();
		selectedCategoryList = new List<String>();
		selectedSubcategoryList = new List<String>();
		selectedCategoryListComplaintType = new List<String>();
		selectedSubcategoryListComplaintType = new List<String>();
		adverseEventReviews = new List <Adverse_Event_Review__c>();
		nutritionReviews = new List <Nutrition_Review__c>();
		comm = new CaseComment();
		accountId = ApexPages.currentPage().getParameters().get('AccountId');
		system.debug('1-1-1-1-1' + c.Id);
			if(c.Id != null){
			queryAffectedItems();
			queryOTCTable();
			
			if(c.Origin == 'Web to Case')
			{
				isWebCase = true;
			}
			
			if(c.Origin == 'Email to Case')
			{
				isEmailCase = true;
			}				
				
				adverseEventReviews = [SELECT Id, Name, AER_Related_Case__c, Synced_With_PQM__c, AER_Status__c, Assesment__c, AER_Comments__c, Prosar_Case__c, Medwatch__c 
					FROM Adverse_Event_Review__c WHERE AER_Related_Case__c = :c.Id LIMIT 1];
				nutritionReviews = [SELECT Id, Synced_With_PQM__c, NR_Associated_Case__c, NR_Number__c, NR_Status__c, NR_Comments__c, NR_Reviewer__c, NR_Summary__c  
					FROM Nutrition_Review__c WHERE NR_Associated_Case__c = :c.Id LIMIT 1];
				
				system.debug('----------------------------' + cId);
					
				categoryQuery = [SELECT CT_Category__c, Same_As_Reporter__c, CT_Subcategory__c, Category__c, Subcategory__c FROM Case WHERE Id =: c.Id];
				
				sameAsReporter = categoryQuery.Same_As_Reporter__c;
				
				if(categoryQuery.Category__c != null)
				{
					List<String> categorySplit = categoryQuery.Category__c.split(';');
					List<String> categoryComplaintTypeSplit = categoryQuery.CT_Category__c.split(';');
					for(String aString : categorySplit)
					{
						selectedCategoryList.add(aString);
						
					}	
					
					for(String aString : categoryComplaintTypeSplit)
					{
						selectedCategoryListComplaintType.add(aString);
						
					}
							
				}
				
				if(categoryQuery.Subcategory__c != null)
				{
					List<String> subcategorySplit = categoryQuery.Subcategory__c.split(';');
					List<String> subcategoryComplaintTypeSplit = categoryQuery.CT_Subcategory__c.split(';');
					for(String aString : subcategorySplit)
					{
						selectedSubcategoryList.add(aString);
					}	
					
					for(String aString : subcategoryComplaintTypeSplit)
					{
						selectedSubcategoryListComplaintType.add(aString);
					}				
				}
			}
		categoriesQuery = CaseCategoryMapping__c.getAll().values();
		
		if(adverseEventReviews.size() == 0)
		{
			Adverse_Event_Review__c newEventReview = new Adverse_Event_Review__c();
			newEventReview.AER_Related_Case__c = c.Id;
			adverseEventReviews = new List<Adverse_Event_Review__c>();
			adverseEventReviews.add(newEventReview);
		}
		
		if(nutritionReviews.size() == 0)
		{
			Nutrition_Review__c newNutritionReview = new Nutrition_Review__c();
			newNutritionReview.NR_Associated_Case__c = c.Id;
			nutritionReviews = new List<Nutrition_Review__c>();
			nutritionReviews.add(newNutritionReview);
		}
		
					
		if(c.Complaint_Type__c == 'Class I')
		{
			isClassI = true;
		}
		else if (c.Complaint_Type__c == 'Class II Non-Illness')
		{
			isClassIINon = true;
		}
		else if (c.Complaint_Type__c == 'Class II Illness')
		{
			isClassII = true;
		}
		else if (c.Complaint_Type__c == 'Class III')
		{
			isClassIII = true;
		}
		else if (c.Complaint_Type__c == 'Inquiry')
		{
			isMedia = true;
		}
	}
	
	public void setupCase(){
		RecordType pInformation = [SELECT Id FROM RecordType WHERE DeveloperName = 'Product_Complaint'];
			
			system.debug('--------------------------------AccountId1: ' + accountId);
			system.debug('--------------------------------AccountId1: ' + ApexPages.currentPage().getParameters().get('AccountId'));
			if (accountId != null && accountId != ''){
				accountId = String.escapeSingleQuotes(accountId);
				Account acct = [SELECT Id, RecordTypeId, Phone, FirstName, LastName, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, 
								RecordType.Name, RecordType.DeveloperName, PersonEmail, PersonHomePhone FROM Account WHERE Id = :accountId];
				c.Reporter_Name_del__c = acct.FirstName + ' ' + acct.LastName;
				c.Reporter_Street__c = acct.BillingStreet;
				c.Reporter_City__c = acct.BillingCity;
				c.Reporter_State_Picklist__c = acct.BillingState;
				c.Reporter_Zip_Code__c = acct.BillingPostalCode;
				c.Reporter_Country__c = acct.BillingCountry;
				c.Reporter_Email__c = acct.PersonEmail;
				c.Reporter_Phone__c = acct.Phone;
				c.Customer__c = acct.Id;
				system.debug('--------------------------------TEST STOP 1');
				Country_Code_Mapping__c ccm = NBTYUtils.getcountryCodeToCCMMap().get(c.Reporter_Country__c);
				if (ccm!=null) {
					Country_Code_Mapping__c ccm2 = Country_Code_Mapping__c.getValues(ccm.Name__c);
					if (ccm2!=null){
						c.PQM_Consumer_Country__c = ccm2.PQM_Country__c;
					}
				}
				system.debug('--------------------------------TEST STOP 2: ' + acct.RecordType.Name);
				//Customer_Rec_Type_Brand_Mapping__c rtbm = NBTYUtils.getRecordTypeBrandMappingMap().get(pInformation.Id);
				c.Brand__c = acct.RecordType.Name;
				c.RecordTypeId = pInformation.Id;
				c.AccountId = accountId;
				c.Origin = 'Phone';
				insert c;
				system.debug('-------------------------------------------------------------------c: ' + c);
			}
	}
	
	public void queryOTCTable()
	{
		OTCTableList = new List<OTCTable>();
		OTCTableQuery = [SELECT Date_Used__c, Dosage__c, Indication__c, Synced_With_PQM__c,  
			Name__c FROM Other_Medications_OTC__c WHERE OTC_Related_Case__c = :c.Id];
		reIntOTCTableList();
	}
	
	public void reIntOTCTableList(){
		
		if (OTCTableList.isEmpty()){
			if(OTCTableQuery.size() == 0)
			{
				//Other_Medications_OTC__c newItem = new Other_Medications_OTC__c();
				//OTCTableList.add(new OTCTable(newItem,OTCTableList.size(), 'No'));
			} 
			else
			{
				for(Other_Medications_OTC__c anOTCTable : OTCTableQuery)
				{
					OTCTableList.add(new OTCTable(anOTCTable, OTCTableList.size(), anOTCTable.Synced_With_PQM__c));
				}
			}
		}
		else {
			integer k=0;
			for(OTCTable anOTCTable : OTCTableList)
				{
					anOTCTable.index=k;
					k++;
				}
		}
	}
	
	public void queryAffectedItems(){
		affectedItemsList = new List<AffectedItem>();
		affectedItemsQuery = [SELECT Item_Number__c, Label_Number__c, Vendor_Lot__c, Synced_With_PQM__c, Formula_Revision__c, Expiration_Date__c, Manufacturing_Site__c, Packaging_Site__c, 
			Oracle_Product_Number__c, Oracle_Bulk_Number__c, Item__c, NBTY_Lot__c , Lot_Number_Sequence__c , Bulk_Number__c , Bulk_Description__c , Label_Revision_Code__c	FROM Affected_Item__c WHERE Case__c = :c.Id];
		reIntAffectedItemsList();
	}
		
	public void reIntAffectedItemsList(){
		
		if (affectedItemsList.isEmpty()){
			if(affectedItemsQuery.size() == 0)
			{
				//Affected_Item__c newItem = new Affected_Item__c();
				//affectedItemsList.add(new AffectedItem(newItem,affectedItemsList.size(), 'No'));
			} 
			else
			{
				for(Affected_Item__c anAffectedItem : affectedItemsQuery)
				{
					affectedItemsList.add(new AffectedItem(anAffectedItem, affectedItemsList.size(), anAffectedItem.Synced_With_PQM__c));
				}
			}
		}
		else {
			integer k=0;
			for(AffectedItem anAffectedItem : affectedItemsList)
				{
					anAffectedItem.index=k;
					k++;
				}
		}
	}
	
	public String compileSelectedCategory()
	{
		String selectedCategory = ApexPages.currentPage().getParameters().get('category');
		
		CaseCategoryMapping__c correspondingComplaintType = [SELECT Complaint_Type__c FROM CaseCategoryMapping__c WHERE Category__c = :selectedCategory LIMIT 1];
		
		for(String aString : selectedCategoryList)
		{
			if(aString == selectedCategory)
			{
				return null;
			}
		}
		selectedCategoryList.add(selectedCategory);
		selectedCategoryListComplaintType.add(correspondingComplaintType.Complaint_Type__c);
		return null;
	}
	
	public void removeCategory()
	{
		String passedCategory = ApexPages.currentPage().getParameters().get('removeCategory');
		
		integer i = 0;
		integer indexRemoved = 0;
		boolean indexNotFound = true;
		for(String aString : selectedCategoryList)
		{
			if(aString == passedCategory)
			{
				indexRemoved = i;
				indexNotFound = false;
			}
			
			if(indexNotFound)
			{
				i++;
			}
		}
		
		selectedCategoryList.remove(i);
		selectedCategoryListComplaintType.remove(i);
	}
	
	public String compileSelectedSubcategory()
	{
		String selectedSubcategory = ApexPages.currentPage().getParameters().get('subcategory');
		String complaintType = ApexPages.currentPage().getParameters().get('complaintType');
		
		system.debug('---------- function called');
		system.debug('---------- function called ' + complaintType);
		List<CaseCategoryMapping__c> validCategories = [SELECT Category__c, Subcategory__c FROM CaseCategoryMapping__c WHERE Complaint_Type__c = :getCorrectComplaintTypes(complaintType)];
		List<CaseCategoryMapping__c> validComplaintType = [SELECT Complaint_Type__c FROM CaseCategoryMapping__c WHERE Subcategory__c = :selectedSubcategory  LIMIT 1];
		
		for(String aString : selectedSubcategoryList)
		{
			for(CaseCategoryMapping__c aCategory : validCategories)
			{
				if(aString == aCategory.Category__c + '|' + selectedSubcategory)
				{
					return null;
				}
			}
		}
		
		system.debug('-----------Valid Categories : ' + validCategories);
		for(CaseCategoryMapping__c aCategory : validCategories)
		{
			system.debug('--------------- 1');
			for(String aSelectedCategory : selectedCategoryList)
			{
				system.debug('--------------- 2');
				if(aCategory.Category__c == aSelectedCategory)
				{
					system.debug('--------------- 3');
					for(CaseCategoryMapping__c aSubcategory : validCategories)
					{
						system.debug('--------------- ' + aSubcategory.Subcategory__c + '-+-+-+' + selectedSubcategory);
						if(aSubcategory.Subcategory__c == selectedSubcategory)
						{
							system.debug('--------------- 5');
							if(aSubcategory.Category__c == aCategory.Category__c)
							{
								system.debug('--------------- 6');
								selectedSubcategoryList.add(aCategory.Category__c + '|' + selectedSubcategory);
								selectedSubcategoryListComplaintType.add(validComplaintType[0].Complaint_Type__c);
								return null;
							}
						}
					}
				}
			}
			
		}
		
		return null;
	}
	
	public void removeSubcategory()
	{
		String passedCategory = ApexPages.currentPage().getParameters().get('removeSubcategory');
		
		integer i = 0;
		integer indexRemoved = 0;
		boolean indexNotFound = true;
		for(String aString : selectedSubcategoryList)
		{
			if(aString == passedCategory)
			{
				indexRemoved = i;
				indexNotFound = false;
			}
			
			if(indexNotFound)
			{
				i++;
			}
		}
		
		if(!indexNotFound)
		{
			selectedSubcategoryList.remove(i);
			selectedSubcategoryListComplaintType.remove(i);
		}
	}
	
	public List<String> getCorrectComplaintTypes(String complaintType)
	{
		List<String> cascadingComplaintTypes = new List<String>();
		
		if(complaintType == 'Inquiry')
		{
			cascadingComplaintTypes.add(complaintType);
		}
		else if (complaintType == 'Class I')
		{
			cascadingComplaintTypes.add('Inquiry');
			cascadingComplaintTypes.add(complaintType);
		}
		else if (complaintType == 'Class II Non-Illness')
		{
			cascadingComplaintTypes.add('Inquiry');
			cascadingComplaintTypes.add('Class I');
			cascadingComplaintTypes.add(complaintType);
		}
		else if (complaintType == 'Class II Illness')
		{
			cascadingComplaintTypes.add('Inquiry');
			cascadingComplaintTypes.add('Class I');
			cascadingComplaintTypes.add('Class II Non-Illness');
			cascadingComplaintTypes.add(complaintType);
		}
		else if (complaintType == 'Class III')
		{
			cascadingComplaintTypes.add('Inquiry');
			cascadingComplaintTypes.add('Class I');
			cascadingComplaintTypes.add('Class II Non-Illness');
			cascadingComplaintTypes.add('Class II Illness');
			cascadingComplaintTypes.add(complaintType);
		}
		
		return cascadingComplaintTypes;
	}
	
	@RemoteAction
	global static Set<String> getCategories(String complaintType)
	{
		List<String> cascadingComplaintTypes = new List<String>();
		
		if(complaintType == 'Inquiry')
		{
			cascadingComplaintTypes.add(complaintType);
		}
		else if (complaintType == 'Class I')
		{
			cascadingComplaintTypes.add('Inquiry');
			cascadingComplaintTypes.add(complaintType);
		}
		else if (complaintType == 'Class II Non-Illness')
		{
			cascadingComplaintTypes.add('Inquiry');
			cascadingComplaintTypes.add('Class I');
			cascadingComplaintTypes.add(complaintType);
		}
		else if (complaintType == 'Class II Illness')
		{
			cascadingComplaintTypes.add('Inquiry');
			cascadingComplaintTypes.add('Class I');
			cascadingComplaintTypes.add('Class II Non-Illness');
			cascadingComplaintTypes.add(complaintType);
		}
		else if (complaintType == 'Class III')
		{
			cascadingComplaintTypes.add('Inquiry');
			cascadingComplaintTypes.add('Class I');
			cascadingComplaintTypes.add('Class II Non-Illness');
			cascadingComplaintTypes.add('Class II Illness');
			cascadingComplaintTypes.add(complaintType);
		}
		
		List<CaseCategoryMapping__c> categoryQuery = [SELECT Category__c FROM CaseCategoryMapping__c WHERE Complaint_Type__c IN :cascadingComplaintTypes];
		
		Set<String> validCategories = new Set<String>();
		for(CaseCategoryMapping__c aCategory : categoryQuery)
		{
			validCategories.add(aCategory.Category__c);
		}
		
		return validCategories;
	}
	
	@RemoteAction
	global static Set<String> getSubcategories(List<String> currentCategories)
	{
		system.debug('--------------' + currentCategories);
		
		List<CaseCategoryMapping__c> subcategoryQuery = [SELECT Subcategory__c FROM CaseCategoryMapping__c WHERE Category__c IN :currentCategories];
		Set<String> validSubcategories = new Set<String>();
		for(CaseCategoryMapping__c aCategory : subcategoryQuery)
		{
			validSubcategories.add(aCategory.Subcategory__c);
		}
		
		return validsubCategories;
	}
	
	public void getAbove()
	{
		system.debug('---------------------------------------------------Made it to getAbove()');
		if(sameAsReporter)
		{
			system.debug('---------------------------------------------------Made it to getAbove() ----- TRUE');
			c.Consumer_Name__c = c.Reporter_Name_del__c;
			c.Consumer_Street__c = c.Reporter_Street__c;
			c.Consumer_Apt__c = c.Reporter_Apt__c;
			c.Consumer_City__c = c.Reporter_City__c;
			c.Consumer_State_Picklist__c = c.Reporter_State_Picklist__c;
			c.Consumer_Zip_Code__c = c.Reporter_Zip_Code__c;
            c.PQM_Consumer_Country__c = c.PQM_Reporter_Country__c;
			c.Consumer_Phone__c = c.Reporter_Phone__c;
			c.Consumer_Email__c = c.Reporter_Email__c;
			c.Same_as_Reporter__c = true;
		} 
		else if(!sameAsReporter)
		{
			system.debug('---------------------------------------------------Made it to getAbove() ----- FALSE');
			c.Consumer_Name__c = '';
			c.Consumer_Street__c = '';
			c.Consumer_Apt__c = '';
			c.Consumer_City__c = '';
			c.Consumer_State_Picklist__c = '';
			c.Consumer_Zip_Code__c = '';
			c.Consumer_Country__c = '';
			c.Consumer_Phone__c = '';
			c.Consumer_Email__c = '';
			c.Same_as_Reporter__c = false; 
		}
	}
	
/*    public void getBelow(){
		system.debug('---------------------------------------------------Made it to getAbove()');
		if(sameAsReporter)
		{
			system.debug('---------------------------------------------------Made it to getAbove() ----- TRUE');
			c.Reporter_Name_del__c = c.Consumer_Name__c;
			c.Reporter_Street__c = c.Consumer_Street__c;
			c.Reporter_Apt__c = c.Consumer_Apt__c;
			c.Reporter_City__c = c.Consumer_City__c;
			c.Reporter_State_Picklist__c = c.Consumer_State_Picklist__c;
			c.Reporter_Zip_Code__c = c.Consumer_Zip_Code__c;
            c.PQM_Reporter_Country__c = c.PQM_Consumer_Country__c;
			c.Reporter_Phone__c = c.Consumer_Phone__c;
			c.Reporter_Email__c = c.Consumer_Email__c;
			c.Same_as_Reporter__c = true;
		} 
		else if(!sameAsReporter)
		{
			system.debug('---------------------------------------------------Made it to getAbove() ----- FALSE');
			c.Reporter_Name_del__c = '';
			c.Reporter_Street__c = '';
			c.Reporter_Apt__c = '';
			c.Reporter_City__c = '';
			c.Reporter_State_Picklist__c = '';
			c.Reporter_Zip_Code__c = '';
			c.Reporter_Country__c = '';
			c.Reporter_Phone__c = '';
			c.Reporter_Email__c = '';
			c.Same_as_Reporter__c = false; 
		}
    }*/
	
	public void setPageMessagesError(List<String> msgs)
	{
		for(String msg : msgs)
		{
			ApexPages.Message pageMsg = new ApexPages.Message(ApexPages.Severity.ERROR, msg);
			ApexPages.AddMessage(pageMsg);
		}
	}
	
	public PageReference saveICM(){
		
		List<Affected_Item__c> updatingAffectedItems = new List<Affected_Item__c>();
		
		boolean doesCategoryHaveValidSubcatgegory = true;
		
		if(selectedCategoryList == null)
		{
			c.Complaint_Type__c.addError('Each product complaint must have a category and subcategory selected');
			return null;
		}
		List<String> errs = new List<String>();
		if(c.Brand__c == null || c.Intake_Department__c == null || c.Complaint_Type__c == null || selectedCategoryList.size() == 0 || selectedCategoryList.size() != 0)
		{
			if(c.Brand__c == null)
			{
				errs.add('Required Field: Brand must have a seleced value');
			}
			
			if(c.Intake_Department__c == null)
			{
				errs.add('Required Field: Intake Department must have a selected value');
			}
			
			if(c.Complaint_Type__c == null)
			{
				errs.add('Required Field: Complaint Type must have a selected value');
			}
			
			if(selectedCategoryList.size() == 0)
			{
				errs.add('Required Field: Must select at least one category');
			}
			
			for(String aCategory : selectedCategoryList)
			{
				doesCategoryHaveValidSubcatgegory = false;
				system.debug('------------' + selectedSubcategoryList.size());
				if(selectedSubcategoryList.size() != 0)
				{
					for(String aSubcategory : selectedSubcategoryList)
					{
						List<String> subcategorySplit = aSubcategory.split('\\|');
						for(String aPartialSubcategory : subcategorySplit)
						{
							system.debug('----------' + aPartialSubcategory);
							if(aPartialSubcategory == aCategory)
							{
								doesCategoryHaveValidSubcatgegory = true;
							}
					 	}
					}
				}
					
				if(doesCategoryHaveValidSubcatgegory == false)
				{
					errs.add('The category ' + aCategory + ' does not have a valid subcategory.');		  
				}
			}
			
			if(errs.size() > 0)
			{
				setPageMessagesError(errs);
				return null;
			}
		}
		
		c.Category__c=null;
		c.Subcategory__c=null;
		c.CT_Category__c = null;
		c.CT_Subcategory__c = null;
		for (string s: selectedCategoryList){
			if (c.Category__c == null){
				c.Category__c= s + ';';
			}
			else {
				c.Category__c = c.Category__c + s + ';';
			}
		}
		
		for (string s: selectedCategoryListComplaintType){
			if (c.CT_Category__c == null){
				c.CT_Category__c= s + ';';
			}
			else {
				c.CT_Category__c = c.CT_Category__c + s + ';';
			}
		}
		
		for (string s: selectedSubcategoryList){
			if (c.Subcategory__c== null){
				c.Subcategory__c= s + ';';
			}
			else {
				c.Subcategory__c = c.Subcategory__c + s + ';';
			}
		}
		
		for (string s: selectedSubcategoryListComplaintType){
			if (c.CT_Subcategory__c== null){
				c.CT_Subcategory__c= s + ';';
			}
			else {
				c.CT_Subcategory__c = c.CT_Subcategory__c + s + ';';
			}
		}
		RecordType pInformation = [SELECT Id FROM RecordType WHERE DeveloperName = 'Product_Complaint'];
		c.RecordTypeId = pInformation.id;
		upsert c;
		
		  for(AffectedItem anItem : affectedItemsList)
		{
			anItem.prdDetail.Case__c = c.Id;
			updatingAffectedItems.add(anItem.prdDetail);
		}
		
		upsert updatingAffectedItems;
		
		if(c.Complaint_Type__c == 'Class III')
		{
			for(Nutrition_Review__c aReview : nutritionReviews)
			{
				if(aReview.NR_Associated_Case__c != c.Id)
				{
					aReview.NR_Associated_Case__c = c.Id;
				}
			}
			upsert nutritionReviews;
		}
		
		
		if(c.Complaint_Type__c == 'Class II Illness' && c.International_Complaint__c == false)
		{
			for (Adverse_Event_Review__c aer: adverseEventReviews )
			{
				if(aer.AER_Related_Case__c == null)
				{
					aer.AER_Related_Case__c = c.id;
				}
			}
			
			for(Nutrition_Review__c aReview : nutritionReviews)
			{
				if(aReview.NR_Associated_Case__c == null)
				{
					aReview.NR_Associated_Case__c = c.Id;
				}
			}
			
			upsert adverseEventReviews;
			upsert nutritionReviews;				
		}
		
		for(String aCategory : selectedCategoryList)
		{
			if(c.Complaint_Type__c == 'Class II Non-Illness' && c.International_Complaint__c == false && aCategory == 'Choking')
			{
				for (Adverse_Event_Review__c aer: adverseEventReviews )
				{
					if(aer.AER_Related_Case__c == null)
					{
						aer.AER_Related_Case__c = c.id;
					}
				}
				
				upsert adverseEventReviews; 
			}
		}
		
		OTCTableSave = new List<Other_Medications_OTC__c>();
		
		for(OTCTable anOTCTable : OTCTableList)
		{
			anOTCTable.thisOTC.OTC_Related_Case__c = c.Id;
			OTCTableSave.add(anOTCTable.thisOTC);
		}

		upsert OTCTableSave;

		if(!affectedItemsList.isEmpty())
		{
			List<Case_Lot_NumberDetail__c> temp = new List<Case_Lot_NumberDetail__c>();
			for(AffectedItem ptmp: affectedItemsList )
			{
				//ptmp.prdDetail.Inquiry__c = c.id;
				//temp.add(ptmp.prdDetail);
			}
			insert temp;
		}
		
        if(Comment.Length() > 0)
        {
           
            comm.commentBody = Comment;
            comm.ParentId = c.Id;
            upsert comm;
        }
		PageReference ref = new PageReference('/' + c.Id);
		ref.setRedirect(true);
		return ref;	 
	} 
	
	public void lotDetail()
	{

		Integer affectedItemIndex = Integer.valueOf(ApexPages.currentPage().getParameters().get('affectedItemIndex'));
		AffectedItem  ai = affectedItemsList[affectedItemIndex];
		ws_Soa_LotNumberQuery.LotNumberQueryRequest_element lnRequest = ws_Soa_LotNumberQueryUtils.initRequest(ai);
		
		
		ws_Soa_LotNumberQuery.LotNumberQueryBindingQSPort lnService = new ws_Soa_LotNumberQuery.LotNumberQueryBindingQSPort();
		lnResponse = lnService.LotNumberQuery(lnRequest.LotNumber, lnRequest.LotNumberSequence, lnRequest.ProductSuffix, lnRequest.SKU);
		
		ai.prdDetail=ws_Soa_LotNumberQueryUtils.parseResponse(ai.prdDetail, lnResponse);
		 if(lnResponse.LotNumberQueryFault != null)
		{
			ai.prdDetail.NBTY_Lot__c.addError(lnResponse.LotNumberQueryFault.FaultMessage);
		}
		
	}
	
	public void addOTC()
	{
		Other_Medications_OTC__c newItem = new Other_Medications_OTC__c();
		OTCTableList.add(new OTCTable(newItem,OTCTableList.size(), 'No'));
	}
	
	public void removeOTC()
	{
		Integer RecOTCTableId = Integer.valueOf(ApexPages.currentPage().getParameters().get('RecOTCTableId'));
		system.debug('RecOTCTableId~~~'+RecOTCTableId);
		OTCTableList.remove(RecOTCTableId);
		system.debug('OTCTableList.size~~~'+OTCTableList.size());
		reIntOTCTableList();
	}
	
	public void addRecord()
	{
		Affected_Item__c newItem = new Affected_Item__c();
		affectedItemsList.add(new AffectedItem(newItem,affectedItemsList.size(), 'No'));
	}
	
	public void removeRecord()
	{
		Integer RecAffectedItemId = Integer.valueOf(ApexPages.currentPage().getParameters().get('RecAffectedItemId'));
		system.debug('RecAffectedItemId~~~'+RecAffectedItemId);
		affectedItemsList.remove(RecAffectedItemId);
		system.debug('affectedItemsList.size~~~'+affectedItemsList.size());
		reIntAffectedItemsList();
	}
	
	public PageReference displayPage()
	{
		List<String> validComplaintTypes = getCorrectComplaintTypes(c.Complaint_Type__c);
		List<Integer> categoryIndexToRemove = new List<Integer>();
		List<Integer> subcategoryIndexToRemove = new List<Integer>();
		
		integer i = 0;  
		for(String aComplaintType : selectedCategoryListComplaintType)
		{
			boolean isValid = false;
			for(String aValidComplaintType : validComplaintTypes)
			{
				if(aValidComplaintType == aComplaintType)
				{
					isValid = true;
				}
				
			}
				
			if(!isValid)
			{
				categoryIndexToRemove.add(i);
			}
			i++;
		}
		
		for(Integer iIndex : categoryIndexToRemove)
		{
			selectedCategoryList.remove(iIndex);
			selectedCategoryListComplaintType.remove(iIndex);
		}
		
		i = 0;
		for(String aComplaintType : selectedSubcategoryListComplaintType)
		{
			boolean isValid = false;
			for(String aValidComplaintType : validComplaintTypes)
			{
				if(aValidComplaintType == aComplaintType)
				{
					isValid = true;
				}
				
			}
			
			if(!isValid)
			{
				subcategoryIndexToRemove.add(i);
			}
			i++;
		}
		
		for(Integer iIndex : subcategoryIndexToRemove)
		{
			selectedSubcategoryList.remove(iIndex);
			selectedSubcategoryListComplaintType.remove(iIndex);
		}
		
		if(c.Complaint_Type__c == 'Class I'){
			isClassI = true; 
			isClassIINon = false;
			isClassII = false;
			isClassIII = false;
			isMedia = false;
			noneSelect = false;
		
		}
		else if( c.Complaint_Type__c == 'Class II Non-Illness')
		{
			isClassI = false; 
			isClassIINon = true;
			isClassII = false;
			isClassIII = false;
			isMedia = false;
			noneSelect = false;
		
		}
		else if(c.Complaint_Type__c == 'Class II Illness')
		{			
			isClassI = false; 
			isClassIINon = false;
			isClassII = true;
			isClassIII = false;
			isMedia = false;
			noneSelect = false;
		
		}
		else if( c.Complaint_Type__c == 'Class III')
		{
			isClassI = false; 
			isClassIINon = false;
			isClassII = false;
			isClassIII = true;
			isMedia = false;
			noneSelect = false;
		
		}
		else if( c.Complaint_Type__c == 'Inquiry')
		{
			isClassI = false; 
			isClassIINon = false;
			isClassII = false;
			isClassIII = false;
			isMedia = true;
			noneSelect = false;
		
		}
		else
		{
			isClassI = false; 
			isClassIINon = false;
			isClassII = false;
			isClassIII = false;
			isMedia = false;
			noneSelect = true;
		}
		
		if(c.Origin == 'Web to Case')
		{
			isWebCase = true;
		}
		else
		{
			isWebCase = false;
		}
		
		return null;
	}
	
	public class AffectedItem 
	{
		
		public Boolean isSelected{get;set;}
		public Item__c product{get;set;}
		public Affected_Item__c prdDetail{get;set;}
		public integer index {get;set;}
		public boolean syncedWithPQM {get;set;}
		
		public AffectedItem(Affected_Item__c anAffectedItem, integer iIndex, String isSynced)
		{
			index = iIndex;
			isSelected = false;
			prdDetail = anAffectedItem;
			
			if(isSynced == 'Yes')
			{
				syncedWithPQM = true;
			}
			else
			{
				syncedWithPQM = false;
			}
		}
	}
	
	public class OTCTable
	{
		public Boolean isSelected{get;set;}
		public Other_Medications_OTC__c thisOTC{get;set;}
		public integer index {get;set;}
		public boolean syncedWithPQM {get;set;}
		
		public OTCTable(Other_Medications_OTC__c newOTC, integer iIndex, String isSynced)
		{
			index = iIndex;
			isSelected = false;
			thisOTC = newOTC;
			
			if(isSynced == 'Yes')
			{
				syncedWithPQM = true;
			}
			else
			{
				syncedWithPQM = false;
			}
			
		}
	}

}