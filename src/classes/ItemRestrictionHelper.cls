public with sharing class ItemRestrictionHelper {

	public static void setItemOnRestriction(List <Item_Restriction__c> irList){
		Set <String> itemKeys = new Set <String>();
		Map <String, Item__c> itemMap = new Map <String, Item__c>();
		for(Item_Restriction__c ir:irList){
			if (ir.Item__c==null){
				string iKey = ir.suffix__c+ir.item_number__c;
				itemKeys.add(iKey);
			}
		}
		if (!itemKeys.isEmpty()){
			for (Item__c i: [select external_key__c, id from Item__c where external_key__c in:itemKeys]){
				itemMap.put(i.external_key__c, i);
			}
			for(Item_Restriction__c ir:irList){
				string iKey = ir.suffix__c+ir.item_number__c;
				ir.Item__c=itemMap.get(iKey).id;
			}
		}
	}
}