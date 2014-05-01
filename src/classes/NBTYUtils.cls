public with sharing class NBTYUtils {


	public static boolean bTriggersOff = triggersOff();
	public static Map<String, Customer_Rec_Type_Brand_Mapping__c> recordTypeBrandMappingMap;
	public static Map<String, Customer_Rec_Type_Brand_Mapping__c> suffixToBrandMappingMap ;
	public static Map<String, Customer_Rec_Type_Brand_Mapping__c> rtNameToBrandMappingMap ;
	public static Map<String, Country_Code_Mapping__c> countryCodeToCCMMap;
	public static Map<String, Credit_Card_Type_Mapping__c> ccNameToTypeMap;
	public static Map<String, Credit_Card_Type_Mapping__c> ccAS400ToTypeMap;
	public static Map<String, Credit_Card_Type_Mapping__c> ccWebToTypeMap;
	public static Map<String, Credit_Card_Type_Mapping__c> ccGatewayToTypeMap;
	
	public static boolean triggersOff() {
		try {
			return	boolean.valueof(WS_Integration__c.getValues('TriggersOff').value__C);
		} catch (exception e) {
			return false;
		}
	}
	
	public static Map<String, Credit_Card_Type_Mapping__c> getCCTypeMappings (string mappingType) {
		ccNameToTypeMap = Credit_Card_Type_Mapping__c.getAll();
		system.debug('mappingType~~~'+mappingType);
		if (mappingType=='Name') {
			return ccNameToTypeMap;
		} else if (mappingType=='AS400') {
			if (ccAS400ToTypeMap==null) {
				ccAS400ToTypeMap = new Map<String, Credit_Card_Type_Mapping__c>();
				for (Credit_Card_Type_Mapping__c cct: ccNameToTypeMap.values()) {
					ccAS400ToTypeMap.put(cct.as400_value__c, cct);
				}
			}
			return ccAS400ToTypeMap;
		} else if (mappingType=='Web') {
			if (ccWebToTypeMap==null) {
				ccWebToTypeMap = new Map<String, Credit_Card_Type_Mapping__c>();
				for (Credit_Card_Type_Mapping__c cct: ccNameToTypeMap.values()) {
					ccWebToTypeMap.put(cct.web_value__c, cct);
				}
			}
			system.debug(ccWebToTypeMap.values());
			return ccWebToTypeMap;
		} else if (mappingType=='Gateway') {
			if (ccGatewayToTypeMap==null) {
				ccGatewayToTypeMap = new Map<String, Credit_Card_Type_Mapping__c>();
				for (Credit_Card_Type_Mapping__c cct: ccNameToTypeMap.values()) {
					ccGatewayToTypeMap.put(cct.Gateway_Value__c, cct);
				}
			}
			return ccGatewayToTypeMap;
		}
		else return null;
	}
	
	
	public static Map<String, Customer_Rec_Type_Brand_Mapping__c> getRecordTypeBrandMappingMap() {
		if (recordTypeBrandMappingMap==null) {
			recordTypeBrandMappingMap = new Map  <String, Customer_Rec_Type_Brand_Mapping__c>();
	 		for (RecordType rt : [select Id,DeveloperName from RecordType where RecordType.SobjectType = 'Account' and   IsPersonType=true and RecordType.IsActive = True ]) {
				Customer_Rec_Type_Brand_Mapping__c rtbm = Customer_Rec_Type_Brand_Mapping__c.getInstance(rt.developerName);
				system.debug('rtbm~~~'+ rtbm);
				system.debug('developername~~~'+ rt.developername);
				recordTypeBrandMappingMap.put(rt.developername, rtbm);
			}
		}
		return recordTypeBrandMappingMap;
	}
	
	public static Map <String, Customer_Rec_Type_Brand_Mapping__c> getSuffixToBrandMappingMap() {
		if (suffixToBrandMappingMap==null) {
			suffixToBrandMappingMap = new Map<String, Customer_Rec_Type_Brand_Mapping__c>();
			
			for (Customer_Rec_Type_Brand_Mapping__c rtbm: Customer_Rec_Type_Brand_Mapping__c.getAll().values()) {
				suffixToBrandMappingMap.put(rtbm.Product_Suffix_c__c, rtbm);
			}
		}
		return suffixToBrandMappingMap;
	}
	
	public static Map <String, Customer_Rec_Type_Brand_Mapping__c> getRtNameToBrandMappingMap() {
		if (rtNameToBrandMappingMap==null) {
			rtNameToBrandMappingMap = new Map<String, Customer_Rec_Type_Brand_Mapping__c>();
			
			for (Customer_Rec_Type_Brand_Mapping__c rtbm: Customer_Rec_Type_Brand_Mapping__c.getAll().values()) {
				rtNameToBrandMappingMap.put(rtbm.RecordTypeName__c, rtbm);
			}
		}
		return rtNameToBrandMappingMap;
	}
	
	
	
	public static  	Map <String, Country_Code_Mapping__c> getcountryCodeToCCMMap() {
		if (countryCodeToCCMMap==null) {
			countryCodeToCCMMap = new Map<String, Country_Code_Mapping__c>();
			
			for (Country_Code_Mapping__c ccm: Country_Code_Mapping__c.getAll().values()) {
				countryCodeToCCMMap.put(ccm.abbreviation__c, ccm);
			}
		}
		return countryCodeToCCMMap;
	}
	
	//removes leading zeros from a passed string of numbers or returns NULL when not all numeric characters
	public static String drop_leading_zeros(String passedValue) {
		String return_string = null; //return string for passing back
		if (passedValue != null) { //if the passed value is not null
			return_string = passedValue.trim(); //trim the whitespace from the start and end of the value
			Pattern valid_characters = Pattern.compile('([0-9]+)'); //only numbers
			Matcher check_chars = valid_characters.matcher(return_string); //compare the string to the set of valid characters
			if (check_chars.matches()) { //if we have a somewhat valid number
				if (return_string.startsWith('0') && return_string.length() > 1) { //if the string begins with a 0 and the length is greater than 1
					boolean keepChecking = true; //create a boolean variable
					while (keepChecking) { //if boolean is true
						if (return_string.startsWith('0') && return_string.length() > 1) { //if the string begins with 0 and there is more than 1 character
							return_string = return_string.substring(1); //drop the first character
						} else { //either the string doesn't begin with 0 or the length is less than or equal to 1
							keepChecking = false; //stop the loop
						}
					}
				}
				if (return_string == '0') { //if the resulting string is now a single '0'
					return_string = null; //set the string to null
				}
			} else { //otherwise the value passed was not valid
				return_string = null; //set the string to null
			}
		}
		return return_string; //pass back a value
	}
	
	static testMethod void test_drop_leading_zeros() {
		System.assertEquals('11111', drop_leading_zeros('11111'));
		System.assertEquals('11111', drop_leading_zeros('00000011111'));
		System.assertEquals(null, drop_leading_zeros('abc'));
		System.assertEquals('99999', drop_leading_zeros(' 99999 '));
		System.assertEquals('999', drop_leading_zeros(' 00999 '));
		System.assertEquals(null, drop_leading_zeros('w'));
		System.assertEquals(null, drop_leading_zeros('00'));
		System.assertEquals(null, drop_leading_zeros('(303) 317-2235'));
		System.assertEquals(null, drop_leading_zeros('111 091'));
		System.assertEquals(null, drop_leading_zeros('  '));
		System.assertEquals(null, drop_leading_zeros(''));
		System.assertEquals(null, drop_leading_zeros(null));
	}
	
	
}