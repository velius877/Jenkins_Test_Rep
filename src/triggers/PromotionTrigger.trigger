trigger PromotionTrigger on Promotion__c (before insert, before update) {
	if (!NBTYUtils.bTriggersOff){
		for (Promotion__c promo: trigger.new){
			if (promo.coupon_status__c=='Inactive') promo.active__c = false;
			else	promo.active__c=true;
		}
	}

}