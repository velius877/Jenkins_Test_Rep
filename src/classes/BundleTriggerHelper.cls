public  class BundleTriggerHelper {
	public static void validateMaxActiveBundles(List <Bundle__c> newList, Map<Id, Bundle__c> oldMap){
		integer currentBundleCount = NBTYWSUtil.getActiveBundles('-1').size();
		integer MAX_BUNDLE_COUNT = Integer.valueOf(Configuration_Setting__c.getValues('Active_Bundle_Limit').value__c);
		String 	  validationErrorMessage ='There are already'+ MAX_BUNDLE_COUNT+'active bundles; please deactivate at least 1 bundle before additional activation.';
		for (Bundle__c b: newList){ 
			if (oldMap==null){
				if (b.Active__c && b.End_Date__c >=system.today()){
					if (currentBundleCount==MAX_BUNDLE_COUNT) b.addError (validationErrorMessage);
					else currentBundleCount++; 
				}
			} 
			else{
				if (!oldMap.get(b.id).active__c&&b.Active__c && b.End_Date__c >=system.today()){
					if (currentBundleCount==MAX_BUNDLE_COUNT) b.addError (validationErrorMessage);
					else currentBundleCount++;
				}
			} 
		}
	} 
}