/************************************* MODIFICATION LOG ********************************************************************************
*
* DESCRIPTION : ItemTriggerHelper.cls has methods that govern behaviour of inserted and updated Item records
*
*---------------------------------------------------------------------------------------------------------------------------------------
* DEVELOPER                     DATE                  REASON
*---------------------------------------------------------------------------------------------------------------------------------------
* Peter Nebel			          04/12/2013          - Origininal Version
* Latha Davuluri                 05/09/2013           - Check hazmat__c based on the Item_Restrictions_Search__c words in Restrictions__c 
*                                                    
*/


public with sharing class ItemTriggerHelper {
	
	/*US42 - Mark Item to Backorder*/
	public static void updateBackorderStatus(List <Item__c> newList, Map<Id, Item__c> oldMap){
		for (Item__c i: newList){
			if (i.Available_Inventory__c!=null){
				if (oldMap==null){
					if (integer.valueOf(i.Available_Inventory__c)<0){
						i.backorder__c=true;
					}
				}
				else {
					if (i.Available_Inventory__c!=oldMap.get(i.id).Available_Inventory__c){
						if (integer.valueOf(i.Available_Inventory__c)<0){
							i.backorder__c=true;
						}
						else	i.backorder__c=false;
					}
				}
			}
		}
	}
	
	public static void ProcessSubstituteItemLinks(Map <Id, Item__c> newMap, Map<Id, Item__c> oldMap){
		List <Item__c> itemList = new List <Item__c>();
		Set <String> substituteItemSet = new Set <String> {};
		Map <String, Item__c> itemMap = new Map<String, Item__c>();
		for (Item__c i: newMap.values()){
			if (oldMap==null){
				if (i.Substitute_Item_Number__c!= null){
					substituteItemSet.add(i.Substitute_Item_Number__c);
				}
			}
			else {
				if (i.Substitute_Item_Number__c!=null&&i.Substitute_Item_Number__c!=oldMap.get(i.id).Substitute_Item_Number__c){
					substituteItemSet.add(i.Substitute_Item_Number__c);
				}
			}
		}
		if (!substituteItemSet.isEmpty()){
			for (Item__c i: [select id, Product_Suffix__c, product_number__c from Item__c where product_number__c in : substituteItemSet]){
				itemMap.put(i.product_suffix__c+'-'+i.product_number__c,i);
			}
			for (Item__c i: newMap.values()){
				Item__c  itemInstance = new Item__c(id=i.id);
				if (itemMap.get(i.Product_Suffix__c+'-'+i.Substitute_Item_Number__c)!=null){
					itemInstance.Substitute_Item__c = itemMap.get(i.Product_Suffix__c+'-'+i.Substitute_Item_Number__c).id;
					itemList.add(itemInstance);
				}
			}
			if (!itemList.isEmpty()){
				update itemList;
			}
		}
	}
	
	public static void SetupItemData (List <Item__c> newItems){
		boolean matchFound = false;	
		for (Item__c i: newItems) {
			if (NBTYUtils.getSuffixToBrandMappingMap().get(i.Product_Suffix__c)!=null) {
				i.Product_Image_URL__c = NBTYUtils.getSuffixToBrandMappingMap().get(i.Product_Suffix__c).Static_Image_URL__c+i.product_number__c+'.jpg';
				system.debug(i.Product_Image_URL__c);
				i.Product_URL__c=i.Product_Image_URL__c;
			}
			if (i.Available_Inventory__c=='NULL') i.Available_Inventory__c=null;
			if (i.Brand_ID__c=='NULL') i.Brand_ID__c=null;
			if (i.Brand_Name__c=='NULL') i.Brand_Name__c=null;
			if (i.Bulk_Number__c=='NULL') i.Bulk_Number__c=null;
			if (i.Cube_Volume__c=='NULL') i.Cube_Volume__c=null;
			if (i.Daily_Usage__c=='NULL') i.Daily_Usage__c=null;
			if (i.Description__c=='NULL') i.Description__c=null;
			if (i.Flavor__c=='NULL') i.Flavor__c=null;
			if (i.General_Product_Information__c=='NULL') i.General_Product_Information__c=null;
			if (i.Item_Type_ID__c=='NULL') i.Item_Type_ID__c=null;
			if (i.Keywords__c=='NULL') i.Keywords__c=null;
			if (i.Label_Info__c=='NULL') i.Label_Info__c=null;
			if (i.Product_Form__c=='NULL') i.Product_Form__c=null;				
			if (i.Product_Size_Amount__c=='NULL') i.Product_Size_Amount__c=null;
			if (i.Product_Size_Measure__c=='NULL') i.Product_Size_Measure__c=null;
			if (i.Sale_Offer__c=='NULL') i.Sale_Offer__c=null;
			if (i.Substitute_Item_Number__c=='NULL') i.Substitute_Item_Number__c=null;	
			if (i.Substitute_Multiplier__c=='NULL') i.Substitute_Multiplier__c=null;	
			if (i.Weight__c=='NULL') i.Weight__c=null;		
			//LD: set the hazmat value based on the search words in Restrictions field.
			if (i.Restrictions__c != null){
				for (Item_Restrictions_Search__c search_words : Item_Restrictions_Search__c.getAll().values()){
					if(i.Restrictions__c.containsIgnoreCase(search_words.value__c)){
						matchFound = true;	
					}
				}
				if (matchFound) i.Hazmat__c = true;
				else i.Hazmat__c = false; 
			}
		}
	}
	
}