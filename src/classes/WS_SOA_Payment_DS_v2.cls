public with sharing class WS_SOA_Payment_DS_v2 {

  public class SFCreateProfileRequest_element {
		public String MerchantKey;
		public String IndustryType;
		public String LOBCustomerNumber;
		public Boolean SaveCCInfoOnBankLinkDown;
		public Boolean IsBankLinkDownReprocessing;
		public String PaymentProfileID;
		public CRQCreditCardInfo_element CreditCardInfo;
		private String[] MerchantKey_type_info = new String[]{'MerchantKey','http://NBTY.com/GI/PGWY/Schemas/PaymentProfile/2.6/SF/CRQ','MerchantKey_element','1','1','false'};
		private String[] IndustryType_type_info = new String[]{'IndustryType','http://NBTY.com/GI/PGWY/Schemas/PaymentProfile/2.6/SF/CRQ','IndustryType_element','1','1','false'};
		private String[] LOBCustomerNumber_type_info = new String[]{'LOBCustomerNumber','http://NBTY.com/GI/PGWY/Schemas/PaymentProfile/2.6/SF/CRQ','LOBCustomerNumber_element','0','1','false'};
		private String[] SaveCCInfoOnBankLinkDown_type_info = new String[]{'SaveCCInfoOnBankLinkDown','http://www.w3.org/2001/XMLSchema','boolean','1','1','false'};
		private String[] IsBankLinkDownReprocessing_type_info = new String[]{'IsBankLinkDownReprocessing','http://www.w3.org/2001/XMLSchema','boolean','1','1','false'};
		private String[] PaymentProfileID_type_info = new String[]{'PaymentProfileID','http://NBTY.com/GI/PGWY/Schemas/PaymentProfile/2.6/SF/CRQ','Guid','1','1','false'};
		private String[] CreditCardInfo_type_info = new String[]{'CreditCardInfo','http://NBTY.com/GI/PGWY/Schemas/PaymentProfile/2.6/SF/CRQ','CRQCreditCardInfo_element','1','1','false'};
		private String[] apex_schema_type_info = new String[]{'http://NBTY.com/GI/PGWY/Schemas/PaymentProfile/2.6/SF/CRQ','true','true'};
		private String[] field_order_type_info = new String[]{'MerchantKey','IndustryType','LOBCustomerNumber','SaveCCInfoOnBankLinkDown','IsBankLinkDownReprocessing','PaymentProfileID','CreditCardInfo'};
	}
	public class CRQAddressInfo_element {
		public String Address1;
		public String Address2;
		public String City;
		public String State;
		public String ZipCode;
		public String CountryCode;
		private String[] Address1_type_info = new String[]{'Address1','http://NBTY.com/GI/PGWY/Schemas/PaymentProfile/2.6/SF/CRQ','Address1_element','1','1','false'};
		private String[] Address2_type_info = new String[]{'Address2','http://NBTY.com/GI/PGWY/Schemas/PaymentProfile/2.6/SF/CRQ','Address2_element','0','1','false'};
		private String[] City_type_info = new String[]{'City','http://NBTY.com/GI/PGWY/Schemas/PaymentProfile/2.6/SF/CRQ','City_element','0','1','false'};
		private String[] State_type_info = new String[]{'State','http://NBTY.com/GI/PGWY/Schemas/PaymentProfile/2.6/SF/CRQ','State_element','0','1','false'};
		private String[] ZipCode_type_info = new String[]{'ZipCode','http://NBTY.com/GI/PGWY/Schemas/PaymentProfile/2.6/SF/CRQ','ZipCode_element','0','1','false'};
		private String[] CountryCode_type_info = new String[]{'CountryCode','http://NBTY.com/GI/PGWY/Schemas/PaymentProfile/2.6/SF/CRQ','CountryCode_element','0','1','false'};
		private String[] apex_schema_type_info = new String[]{'http://NBTY.com/GI/PGWY/Schemas/PaymentProfile/2.6/SF/CRQ','true','true'};
		private String[] field_order_type_info = new String[]{'Address1','Address2','City','State','ZipCode','CountryCode'};
	}
	public class CRQCreditCardInfo_element {
		public String CreditCardNumber;
		public String CreditCardExpiryDate;
		public Integer CreditCardTypeID;
		public String NameOnTheCreditCard;
		public String CreatePaymentProfileIndicator;
		public String TokenNumber;
		public CRQAddressInfo_element AddressInfo;
		private String[] CreditCardNumber_type_info = new String[]{'CreditCardNumber','http://NBTY.com/GI/PGWY/Schemas/PaymentProfile/2.6/SF/CRQ','CreditCardNumber_element','1','1','false'};
		private String[] CreditCardExpiryDate_type_info = new String[]{'CreditCardExpiryDate','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
		private String[] CreditCardTypeID_type_info = new String[]{'CreditCardTypeID','http://www.w3.org/2001/XMLSchema','int','1','1','false'};
		private String[] NameOnTheCreditCard_type_info = new String[]{'NameOnTheCreditCard','http://NBTY.com/GI/PGWY/Schemas/PaymentProfile/2.6/SF/CRQ','NameOnTheCreditCard_element','1','1','false'};
		private String[] CreatePaymentProfileIndicator_type_info = new String[]{'CreatePaymentProfileIndicator','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
		private String[] TokenNumber_type_info = new String[]{'TokenNumber','http://www.w3.org/2001/XMLSchema','string','1','1','false'};
		private String[] AddressInfo_type_info = new String[]{'AddressInfo','http://NBTY.com/GI/PGWY/Schemas/PaymentProfile/2.6/SF/CRQ','CRQAddressInfo_element','0','1','false'};
		private String[] apex_schema_type_info = new String[]{'http://NBTY.com/GI/PGWY/Schemas/PaymentProfile/2.6/SF/CRQ','true','true'};
		private String[] field_order_type_info = new String[]{'CreditCardNumber','CreditCardExpiryDate','CreditCardTypeID','NameOnTheCreditCard','CreatePaymentProfileIndicator','TokenNumber','AddressInfo'};
	}
	 public class SFCreateProfileResponseResult_element {
		public String Status;
		public String Message;
		public String ErrorMessage;
		private String[] Status_type_info = new String[]{'Status','http://www.w3.org/2001/XMLSchema','string','1','1','false'};
		private String[] Message_type_info = new String[]{'Message','http://www.w3.org/2001/XMLSchema','string','1','1','false'};
		private String[] ErrorMessage_type_info = new String[]{'ErrorMessage','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
		private String[] apex_schema_type_info = new String[]{'http://NBTY.com/GI/PGWY/Schemas/PaymentProfile/2.6/SF/CRS','true','true'};
		private String[] field_order_type_info = new String[]{'Status','Message','ErrorMessage'};
	}
	public class SFCreateProfileResponse_element {
		public String MerchantKey;
		public String LOBCustomerNumber;
		public String PaymentProfileID;
		public String TokenNumber;
		public SFCreateProfileResponseResult_element SFCreateProfileResponseResult;
		private String[] MerchantKey_type_info = new String[]{'MerchantKey','http://www.w3.org/2001/XMLSchema','string','1','1','false'};
		private String[] LOBCustomerNumber_type_info = new String[]{'LOBCustomerNumber','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
		private String[] PaymentProfileID_type_info = new String[]{'PaymentProfileID','http://NBTY.com/GI/PGWY/Schemas/PaymentProfile/2.6/SF/CRS','Guid','0','1','false'};
		private String[] TokenNumber_type_info = new String[]{'TokenNumber','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
		private String[] SFCreateProfileResponseResult_type_info = new String[]{'SFCreateProfileResponseResult','http://NBTY.com/GI/PGWY/Schemas/PaymentProfile/2.6/SF/CRS','SFCreateProfileResponseResult_element','1','1','false'};
		private String[] apex_schema_type_info = new String[]{'http://NBTY.com/GI/PGWY/Schemas/PaymentProfile/2.6/SF/CRS','true','true'};
		private String[] field_order_type_info = new String[]{'MerchantKey','LOBCustomerNumber','PaymentProfileID','TokenNumber','SFCreateProfileResponseResult'};
	}
	public class ERQFraudAnalysis_element {
		public String FraudScoreIndicator;
		public String RulesTrigger;
		public String KaptchaSessionID;
		public String WebsiteShortName;
		public String CashValueOfFencibleIterms;
		public String CustomerDOB;
		public String CustomerGender;
		public String CustomerDriverLicense;
		public String CustomerID;
		public String CustomerIDCreationTime;
		public String KTTVersionNumber;
		public String KTTDatalength;
		private String[] FraudScoreIndicator_type_info = new String[]{'FraudScoreIndicator','http://www.w3.org/2001/XMLSchema','string','1','1','false'};
		private String[] RulesTrigger_type_info = new String[]{'RulesTrigger','http://www.w3.org/2001/XMLSchema','string','1','1','false'};
		private String[] KaptchaSessionID_type_info = new String[]{'KaptchaSessionID','http://www.w3.org/2001/XMLSchema','string','1','1','false'};
		private String[] WebsiteShortName_type_info = new String[]{'WebsiteShortName','http://www.w3.org/2001/XMLSchema','string','1','1','false'};
		private String[] CashValueOfFencibleIterms_type_info = new String[]{'CashValueOfFencibleIterms','http://www.w3.org/2001/XMLSchema','string','1','1','false'};
		private String[] CustomerDOB_type_info = new String[]{'CustomerDOB','http://www.w3.org/2001/XMLSchema','string','1','1','false'};
		private String[] CustomerGender_type_info = new String[]{'CustomerGender','http://www.w3.org/2001/XMLSchema','string','1','1','false'};
		private String[] CustomerDriverLicense_type_info = new String[]{'CustomerDriverLicense','http://www.w3.org/2001/XMLSchema','string','1','1','false'};
		private String[] CustomerID_type_info = new String[]{'CustomerID','http://www.w3.org/2001/XMLSchema','string','1','1','false'};
		private String[] CustomerIDCreationTime_type_info = new String[]{'CustomerIDCreationTime','http://www.w3.org/2001/XMLSchema','string','1','1','false'};
		private String[] KTTVersionNumber_type_info = new String[]{'KTTVersionNumber','http://www.w3.org/2001/XMLSchema','string','1','1','false'};
		private String[] KTTDatalength_type_info = new String[]{'KTTDatalength','http://www.w3.org/2001/XMLSchema','string','1','1','false'};
		private String[] apex_schema_type_info = new String[]{'http://NBTY.com/GI/PGWY/SF/Schemas/Authorization/ERQ','true','true'};
		private String[] field_order_type_info = new String[]{'FraudScoreIndicator','RulesTrigger','KaptchaSessionID','WebsiteShortName','CashValueOfFencibleIterms','CustomerDOB','CustomerGender','CustomerDriverLicense','CustomerID','CustomerIDCreationTime','KTTVersionNumber','KTTDatalength'};
	}
	public class SFExistingCreditCardAuthorizationRequest_element {
		public String MerchantKey;
		public String IndustryType;
		public String PaymentProfileID;
		public String OrderID;
		public String Amount;
		public String PartialAuthIndicator;
		public Boolean IsBankLinkDownReprocessing;
		public ERQCreditCardInfo_element CreditCardInfo;
		public ERQFraudAnalysis_element FraudAnalysis;
		private String[] MerchantKey_type_info = new String[]{'MerchantKey','http://NBTY.com/GI/PGWY/SF/Schemas/Authorization/ERQ','MerchantKey_element','1','1','false'};
		private String[] IndustryType_type_info = new String[]{'IndustryType','http://NBTY.com/GI/PGWY/SF/Schemas/Authorization/ERQ','IndustryType_element','1','1','false'};
		private String[] PaymentProfileID_type_info = new String[]{'PaymentProfileID','http://NBTY.com/GI/PGWY/SF/Schemas/Authorization/ERQ','Guid','0','1','false'};
		private String[] OrderID_type_info = new String[]{'OrderID','http://NBTY.com/GI/PGWY/SF/Schemas/Authorization/ERQ','OrderID_element','1','1','false'};
		private String[] Amount_type_info = new String[]{'Amount','http://NBTY.com/GI/PGWY/SF/Schemas/Authorization/ERQ','Amount_element','1','1','false'};
		private String[] PartialAuthIndicator_type_info = new String[]{'PartialAuthIndicator','http://NBTY.com/GI/PGWY/SF/Schemas/Authorization/ERQ','PartialAuthIndicator_element','0','1','false'};
		private String[] IsBankLinkDownReprocessing_type_info = new String[]{'IsBankLinkDownReprocessing','http://www.w3.org/2001/XMLSchema','boolean','1','1','false'};
		private String[] CreditCardInfo_type_info = new String[]{'CreditCardInfo','http://NBTY.com/GI/PGWY/SF/Schemas/Authorization/ERQ','ERQCreditCardInfo_element','1','1','false'};
		private String[] FraudAnalysis_type_info = new String[]{'FraudAnalysis','http://NBTY.com/GI/PGWY/SF/Schemas/Authorization/ERQ','ERQFraudAnalysis_element','0','1','false'};
		private String[] apex_schema_type_info = new String[]{'http://NBTY.com/GI/PGWY/SF/Schemas/Authorization/ERQ','true','true'};
		private String[] field_order_type_info = new String[]{'MerchantKey','IndustryType','PaymentProfileID','OrderID','Amount','PartialAuthIndicator','IsBankLinkDownReprocessing','CreditCardInfo','FraudAnalysis'};
	}
	public class ERQCreditCardInfo_element {
		public String TokenNumber;
		private String[] TokenNumber_type_info = new String[]{'TokenNumber','http://www.w3.org/2001/XMLSchema','string','1','1','false'};
		private String[] apex_schema_type_info = new String[]{'http://NBTY.com/GI/PGWY/SF/Schemas/Authorization/ERQ','true','true'};
		private String[] field_order_type_info = new String[]{'TokenNumber'};
	}
	public class ERQFraudAnalysisResponse_element {
		public String FraudScoreIndicator;
		public String FraudStatusCode;
		public String RiskScore;
		public String KaptchaMatchFlag;
		public String RiskInquiryTransactionID;
		public String AutoDecisionResponse;
		private String[] FraudScoreIndicator_type_info = new String[]{'FraudScoreIndicator','http://www.w3.org/2001/XMLSchema','string','1','1','false'};
		private String[] FraudStatusCode_type_info = new String[]{'FraudStatusCode','http://www.w3.org/2001/XMLSchema','string','1','1','false'};
		private String[] RiskScore_type_info = new String[]{'RiskScore','http://www.w3.org/2001/XMLSchema','string','1','1','false'};
		private String[] KaptchaMatchFlag_type_info = new String[]{'KaptchaMatchFlag','http://www.w3.org/2001/XMLSchema','string','1','1','false'};
		private String[] RiskInquiryTransactionID_type_info = new String[]{'RiskInquiryTransactionID','http://www.w3.org/2001/XMLSchema','string','1','1','false'};
		private String[] AutoDecisionResponse_type_info = new String[]{'AutoDecisionResponse','http://www.w3.org/2001/XMLSchema','string','1','1','false'};
		private String[] apex_schema_type_info = new String[]{'http://NBTY.com/GI/PGWY/SF/Schemas/Authorization/ERS','true','true'};
		private String[] field_order_type_info = new String[]{'FraudScoreIndicator','FraudStatusCode','RiskScore','KaptchaMatchFlag','RiskInquiryTransactionID','AutoDecisionResponse'};
	}
	public class SFExistingCreditCardAuthorizationResponseResult_element {
		public String Status;
		public String Message;
		public String ErrorMessage;
		private String[] Status_type_info = new String[]{'Status','http://www.w3.org/2001/XMLSchema','string','1','1','false'};
		private String[] Message_type_info = new String[]{'Message','http://www.w3.org/2001/XMLSchema','string','1','1','false'};
		private String[] ErrorMessage_type_info = new String[]{'ErrorMessage','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
		private String[] apex_schema_type_info = new String[]{'http://NBTY.com/GI/PGWY/SF/Schemas/Authorization/ERS','true','true'};
		private String[] field_order_type_info = new String[]{'Status','Message','ErrorMessage'};
	}
	public class SFExistingCreditCardAuthorizationResponse_element {
		public String PaymentProfileID;
		public String TokenNumber;
		public String OrderID;
		public String TransactionReferenceNumber;
		public String TransactionReferenceIndex;
		public DateTime ResponseDateTime;
		public String AuthorizationCode;
		public SFExistingCreditCardAuthorizationResponseResult_element Result;
		public ERQFraudAnalysisResponse_element FraudAnalysisResponse;
		private String[] PaymentProfileID_type_info = new String[]{'PaymentProfileID','http://NBTY.com/GI/PGWY/SF/Schemas/Authorization/ERS','Guid','1','1','false'};
		private String[] TokenNumber_type_info = new String[]{'TokenNumber','http://www.w3.org/2001/XMLSchema','string','1','1','false'};
		private String[] OrderID_type_info = new String[]{'OrderID','http://www.w3.org/2001/XMLSchema','string','1','1','false'};
		private String[] TransactionReferenceNumber_type_info = new String[]{'TransactionReferenceNumber','http://www.w3.org/2001/XMLSchema','string','1','1','false'};
		private String[] TransactionReferenceIndex_type_info = new String[]{'TransactionReferenceIndex','http://www.w3.org/2001/XMLSchema','string','1','1','false'};
		private String[] ResponseDateTime_type_info = new String[]{'ResponseDateTime','http://www.w3.org/2001/XMLSchema','dateTime','1','1','false'};
		private String[] AuthorizationCode_type_info = new String[]{'AuthorizationCode','http://www.w3.org/2001/XMLSchema','string','1','1','false'};
		private String[] Result_type_info = new String[]{'Result','http://NBTY.com/GI/PGWY/SF/Schemas/Authorization/ERS','SFExistingCreditCardAuthorizationResponseResult_element','1','1','false'};
		private String[] FraudAnalysisResponse_type_info = new String[]{'FraudAnalysisResponse','http://NBTY.com/GI/PGWY/SF/Schemas/Authorization/ERS','ERQFraudAnalysisResponse_element','1','1','false'};
		private String[] apex_schema_type_info = new String[]{'http://NBTY.com/GI/PGWY/SF/Schemas/Authorization/ERS','true','true'};
		private String[] field_order_type_info = new String[]{'PaymentProfileID','TokenNumber','OrderID','TransactionReferenceNumber','TransactionReferenceIndex','ResponseDateTime','AuthorizationCode','Result','FraudAnalysisResponse'};
	}
	
	public class NRQFraudAnalysis_element {
		public String FraudScoreIndicator;
		public String RulesTrigger;
		public String KaptchaSessionID;
		public String WebsiteShortName;
		public String CashValueOfFencibleIterms;
		public String CustomerDOB;
		public String CustomerGender;
		public String CustomerDriverLicense;
		public String CustomerID;
		public String CustomerIDCreationTime;
		public String KTTVersionNumber;
		public String KTTDatalength;
		public String KTTDataString;
		public String BillingPhoneNumber;
		public String CustomerEmail;
		public String ShipPhoneNumber;
		public String ShipName;
		public String ShipAddress1;
		public String ShipAddress2;
		public String ShipCity;
		public String ShipState;
		public String ShipZipCode;
		public String ShipCountryCode;
		private String[] FraudScoreIndicator_type_info = new String[]{'FraudScoreIndicator','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
		private String[] RulesTrigger_type_info = new String[]{'RulesTrigger','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
		private String[] KaptchaSessionID_type_info = new String[]{'KaptchaSessionID','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
		private String[] WebsiteShortName_type_info = new String[]{'WebsiteShortName','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
		private String[] CashValueOfFencibleIterms_type_info = new String[]{'CashValueOfFencibleIterms','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
		private String[] CustomerDOB_type_info = new String[]{'CustomerDOB','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
		private String[] CustomerGender_type_info = new String[]{'CustomerGender','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
		private String[] CustomerDriverLicense_type_info = new String[]{'CustomerDriverLicense','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
		private String[] CustomerID_type_info = new String[]{'CustomerID','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
		private String[] CustomerIDCreationTime_type_info = new String[]{'CustomerIDCreationTime','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
		private String[] KTTVersionNumber_type_info = new String[]{'KTTVersionNumber','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
		private String[] KTTDatalength_type_info = new String[]{'KTTDatalength','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
		private String[] KTTDataString_type_info = new String[]{'KTTDataString','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
		private String[] BillingPhoneNumber_type_info = new String[]{'BillingPhoneNumber','http://www.w3.org/2001/XMLSchema','string','1','1','false'};
		private String[] CustomerEmail_type_info = new String[]{'CustomerEmail','http://www.w3.org/2001/XMLSchema','string','1','1','false'};
		private String[] ShipPhoneNumber_type_info = new String[]{'ShipPhoneNumber','http://www.w3.org/2001/XMLSchema','string','1','1','false'};
		private String[] ShipName_type_info = new String[]{'ShipName','http://www.w3.org/2001/XMLSchema','string','1','1','false'};
		private String[] ShipAddress1_type_info = new String[]{'ShipAddress1','http://NBTY.com/GI/PGWY/SF/Schemas/Authorization/NRQ','ShipAddress1_element','0','1','false'};
		private String[] ShipAddress2_type_info = new String[]{'ShipAddress2','http://NBTY.com/GI/PGWY/SF/Schemas/Authorization/NRQ','ShipAddress2_element','0','1','false'};
		private String[] ShipCity_type_info = new String[]{'ShipCity','http://NBTY.com/GI/PGWY/SF/Schemas/Authorization/NRQ','ShipCity_element','0','1','false'};
		private String[] ShipState_type_info = new String[]{'ShipState','http://NBTY.com/GI/PGWY/SF/Schemas/Authorization/NRQ','ShipState_element','0','1','false'};
		private String[] ShipZipCode_type_info = new String[]{'ShipZipCode','http://NBTY.com/GI/PGWY/SF/Schemas/Authorization/NRQ','ShipZipCode_element','1','1','false'};
		private String[] ShipCountryCode_type_info = new String[]{'ShipCountryCode','http://NBTY.com/GI/PGWY/SF/Schemas/Authorization/NRQ','ShipCountryCode_element','0','1','false'};
		private String[] apex_schema_type_info = new String[]{'http://NBTY.com/GI/PGWY/SF/Schemas/Authorization/NRQ','true','true'};
		private String[] field_order_type_info = new String[]{'FraudScoreIndicator','RulesTrigger','KaptchaSessionID','WebsiteShortName','CashValueOfFencibleIterms','CustomerDOB','CustomerGender','CustomerDriverLicense','CustomerID','CustomerIDCreationTime','KTTVersionNumber','KTTDatalength','KTTDataString','BillingPhoneNumber','CustomerEmail','ShipPhoneNumber','ShipName','ShipAddress1','ShipAddress2','ShipCity','ShipState','ShipZipCode','ShipCountryCode'};
	}
	public class SFNewCreditCardAuthorizationRequest_element {
		public String MerchantKey;
		public String LOBCustomerNumber;
		public String IndustryType;
		public String OrderID;
		public String Amount;
		public String PartialAuthIndicator;
		public String PaymentProfileID;
		public Boolean SaveCCInfoOnBankLinkDown;
		public NRQCreditCardInfo_element CreditCardInfo;
		public NRQFraudAnalysis_element FraudAnalysis;
		private String[] MerchantKey_type_info = new String[]{'MerchantKey','http://NBTY.com/GI/PGWY/SF/Schemas/Authorization/NRQ','MerchantKey_element','1','1','false'};
		private String[] LOBCustomerNumber_type_info = new String[]{'LOBCustomerNumber','http://NBTY.com/GI/PGWY/SF/Schemas/Authorization/NRQ','LOBCustomerNumber_element','0','1','false'};
		private String[] IndustryType_type_info = new String[]{'IndustryType','http://NBTY.com/GI/PGWY/SF/Schemas/Authorization/NRQ','IndustryType_element','1','1','false'};
		private String[] OrderID_type_info = new String[]{'OrderID','http://NBTY.com/GI/PGWY/SF/Schemas/Authorization/NRQ','OrderID_element','1','1','false'};
		private String[] Amount_type_info = new String[]{'Amount','http://NBTY.com/GI/PGWY/SF/Schemas/Authorization/NRQ','Amount_element','1','1','false'};
		private String[] PartialAuthIndicator_type_info = new String[]{'PartialAuthIndicator','http://NBTY.com/GI/PGWY/SF/Schemas/Authorization/NRQ','PartialAuthIndicator_element','0','1','false'};
		private String[] PaymentProfileID_type_info = new String[]{'PaymentProfileID','http://NBTY.com/GI/PGWY/SF/Schemas/Authorization/NRQ','Guid','0','1','false'};
		private String[] SaveCCInfoOnBankLinkDown_type_info = new String[]{'SaveCCInfoOnBankLinkDown','http://www.w3.org/2001/XMLSchema','boolean','1','1','false'};
		private String[] CreditCardInfo_type_info = new String[]{'CreditCardInfo','http://NBTY.com/GI/PGWY/SF/Schemas/Authorization/NRQ','NRQCreditCardInfo_element','1','1','false'};
		private String[] FraudAnalysis_type_info = new String[]{'FraudAnalysis','http://NBTY.com/GI/PGWY/SF/Schemas/Authorization/NRQ','NRQFraudAnalysis_element','0','1','false'};
		private String[] apex_schema_type_info = new String[]{'http://NBTY.com/GI/PGWY/SF/Schemas/Authorization/NRQ','true','true'};
		private String[] field_order_type_info = new String[]{'MerchantKey','LOBCustomerNumber','IndustryType','OrderID','Amount','PartialAuthIndicator','PaymentProfileID','SaveCCInfoOnBankLinkDown','CreditCardInfo','FraudAnalysis'};
	}
	public class NRQAddressInfo_element {
		public String Address1;
		public String Address2;
		public String City;
		public String State;
		public String ZipCode;
		public String CountryCode;
		private String[] Address1_type_info = new String[]{'Address1','http://NBTY.com/GI/PGWY/SF/Schemas/Authorization/NRQ','Address1_element','0','1','false'};
		private String[] Address2_type_info = new String[]{'Address2','http://NBTY.com/GI/PGWY/SF/Schemas/Authorization/NRQ','Address2_element','0','1','false'};
		private String[] City_type_info = new String[]{'City','http://NBTY.com/GI/PGWY/SF/Schemas/Authorization/NRQ','City_element','0','1','false'};
		private String[] State_type_info = new String[]{'State','http://NBTY.com/GI/PGWY/SF/Schemas/Authorization/NRQ','State_element','0','1','false'};
		private String[] ZipCode_type_info = new String[]{'ZipCode','http://NBTY.com/GI/PGWY/SF/Schemas/Authorization/NRQ','ZipCode_element','1','1','false'};
		private String[] CountryCode_type_info = new String[]{'CountryCode','http://NBTY.com/GI/PGWY/SF/Schemas/Authorization/NRQ','CountryCode_element','0','1','false'};
		private String[] apex_schema_type_info = new String[]{'http://NBTY.com/GI/PGWY/SF/Schemas/Authorization/NRQ','true','true'};
		private String[] field_order_type_info = new String[]{'Address1','Address2','City','State','ZipCode','CountryCode'};
	}
	public class NRQCreditCardInfo_element {
		public String CreditCardNumber;
		public String CreditCardExpiryDate;
		public String CreditCardTypeID;
		public String NameOnTheCreditCard;
		public String CCVerifyNumber;
		public String CreatePaymentProfileIndicator;
		public NRQAddressInfo_element AddressInfo;
		private String[] CreditCardNumber_type_info = new String[]{'CreditCardNumber','http://NBTY.com/GI/PGWY/SF/Schemas/Authorization/NRQ','CreditCardNumber_element','1','1','false'};
		private String[] CreditCardExpiryDate_type_info = new String[]{'CreditCardExpiryDate','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
		private String[] CreditCardTypeID_type_info = new String[]{'CreditCardTypeID','http://www.w3.org/2001/XMLSchema','string','1','1','false'};
		private String[] NameOnTheCreditCard_type_info = new String[]{'NameOnTheCreditCard','http://NBTY.com/GI/PGWY/SF/Schemas/Authorization/NRQ','NameOnTheCreditCard_element','1','1','false'};
		private String[] CCVerifyNumber_type_info = new String[]{'CCVerifyNumber','http://NBTY.com/GI/PGWY/SF/Schemas/Authorization/NRQ','CCVerifyNumber_element','0','1','false'};
		private String[] CreatePaymentProfileIndicator_type_info = new String[]{'CreatePaymentProfileIndicator','http://NBTY.com/GI/PGWY/SF/Schemas/Authorization/NRQ','CreatePaymentProfileIndicator_element','1','1','false'};
		private String[] AddressInfo_type_info = new String[]{'AddressInfo','http://NBTY.com/GI/PGWY/SF/Schemas/Authorization/NRQ','NRQAddressInfo_element','0','1','false'};
		private String[] apex_schema_type_info = new String[]{'http://NBTY.com/GI/PGWY/SF/Schemas/Authorization/NRQ','true','true'};
		private String[] field_order_type_info = new String[]{'CreditCardNumber','CreditCardExpiryDate','CreditCardTypeID','NameOnTheCreditCard','CCVerifyNumber','CreatePaymentProfileIndicator','AddressInfo'};
	}
	public class SFNewCreditCardAuthorizationResponseResult_element {
		public String Status;
		public String Message;
		public String ProfileProcessStatus;
		public String ProfileProcessStatusMessage;
		public String ErrorMessage;
		private String[] Status_type_info = new String[]{'Status','http://www.w3.org/2001/XMLSchema','string','1','1','false'};
		private String[] Message_type_info = new String[]{'Message','http://www.w3.org/2001/XMLSchema','string','1','1','false'};
		private String[] ProfileProcessStatus_type_info = new String[]{'ProfileProcessStatus','http://www.w3.org/2001/XMLSchema','string','0','1','true'};
		private String[] ProfileProcessStatusMessage_type_info = new String[]{'ProfileProcessStatusMessage','http://www.w3.org/2001/XMLSchema','string','0','1','true'};
		private String[] ErrorMessage_type_info = new String[]{'ErrorMessage','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
		private String[] apex_schema_type_info = new String[]{'http://NBTY.com/GI/PGWY/SF/Schemas/Authorization/NRS','true','true'};
		private String[] field_order_type_info = new String[]{'Status','Message','ProfileProcessStatus','ProfileProcessStatusMessage','ErrorMessage'};
	}
	public class NRSFraudAnalysisResponse_element {
		public String FraudScoreIndicator;
		public String FraudStatusCode;
		public String RiskScore;
		public String KaptchaMatchFlag;
		public String RiskInquiryTransactionID;
		public String AutoDecisionResponse;
		private String[] FraudScoreIndicator_type_info = new String[]{'FraudScoreIndicator','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
		private String[] FraudStatusCode_type_info = new String[]{'FraudStatusCode','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
		private String[] RiskScore_type_info = new String[]{'RiskScore','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
		private String[] KaptchaMatchFlag_type_info = new String[]{'KaptchaMatchFlag','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
		private String[] RiskInquiryTransactionID_type_info = new String[]{'RiskInquiryTransactionID','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
		private String[] AutoDecisionResponse_type_info = new String[]{'AutoDecisionResponse','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
		private String[] apex_schema_type_info = new String[]{'http://NBTY.com/GI/PGWY/SF/Schemas/Authorization/NRS','true','true'};
		private String[] field_order_type_info = new String[]{'FraudScoreIndicator','FraudStatusCode','RiskScore','KaptchaMatchFlag','RiskInquiryTransactionID','AutoDecisionResponse'};
	}
	public class SFNewCreditCardAuthorizationResponse_element {
		public String TokenNumber;
		public String PaymentProfileID;
		public String OrderID;
		public String TransactionReferenceNumber;
		public String TransactionReferenceIndex;
		public DateTime ResponseDateTime;
		public String AuthorizationCode;
		public SFNewCreditCardAuthorizationResponseResult_element SFNewCreditCardAuthorizationResponseResult;
		public NRSFraudAnalysisResponse_element NRSFraudAnalysisResponse;
		private String[] TokenNumber_type_info = new String[]{'TokenNumber','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
		private String[] PaymentProfileID_type_info = new String[]{'PaymentProfileID','http://NBTY.com/GI/PGWY/SF/Schemas/Authorization/NRS','Guid','0','1','false'};
		private String[] OrderID_type_info = new String[]{'OrderID','http://www.w3.org/2001/XMLSchema','string','1','1','false'};
		private String[] TransactionReferenceNumber_type_info = new String[]{'TransactionReferenceNumber','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
		private String[] TransactionReferenceIndex_type_info = new String[]{'TransactionReferenceIndex','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
		private String[] ResponseDateTime_type_info = new String[]{'ResponseDateTime','http://www.w3.org/2001/XMLSchema','dateTime','1','1','false'};
		private String[] AuthorizationCode_type_info = new String[]{'AuthorizationCode','http://www.w3.org/2001/XMLSchema','string','1','1','false'};
		private String[] SFNewCreditCardAuthorizationResponseResult_type_info = new String[]{'SFNewCreditCardAuthorizationResponseResult','http://NBTY.com/GI/PGWY/SF/Schemas/Authorization/NRS','SFNewCreditCardAuthorizationResponseResult_element','1','1','false'};
		private String[] NRSFraudAnalysisResponse_type_info = new String[]{'FraudAnalysisResponse','http://NBTY.com/GI/PGWY/SF/Schemas/Authorization/NRS','NRSFraudAnalysisResponse_element','0','1','false'};
		private String[] apex_schema_type_info = new String[]{'http://NBTY.com/GI/PGWY/SF/Schemas/Authorization/NRS','true','true'};
		private String[] field_order_type_info = new String[]{'TokenNumber','PaymentProfileID','OrderID','TransactionReferenceNumber','TransactionReferenceIndex','ResponseDateTime','AuthorizationCode','SFNewCreditCardAuthorizationResponseResult','FraudAnalysisResponse'};
	}
	public class SFReversalRequest_element {
		public String MerchantKey;
		public String IndustryType;
		public String TokenNumber;
		public String OrderID;
		public String AdjustedAmount;
		public String TransactionReferenceNumber;
		private String[] MerchantKey_type_info = new String[]{'MerchantKey','http://NBTY.com/GI/PGWY/SF/Schemas/Authorization/RVQ','MerchantKey_element','1','1','false'};
		private String[] IndustryType_type_info = new String[]{'IndustryType','http://NBTY.com/GI/PGWY/SF/Schemas/Authorization/RVQ','IndustryType_element','1','1','false'};
		private String[] TokenNumber_type_info = new String[]{'TokenNumber','http://www.w3.org/2001/XMLSchema','string','1','1','false'};
		private String[] OrderID_type_info = new String[]{'OrderID','http://NBTY.com/GI/PGWY/SF/Schemas/Authorization/RVQ','OrderID_element','1','1','false'};
		private String[] AdjustedAmount_type_info = new String[]{'AdjustedAmount','http://NBTY.com/GI/PGWY/SF/Schemas/Authorization/RVQ','AdjustedAmount_element','1','1','false'};
		private String[] TransactionReferenceNumber_type_info = new String[]{'TransactionReferenceNumber','http://www.w3.org/2001/XMLSchema','string','1','1','false'};
		private String[] apex_schema_type_info = new String[]{'http://NBTY.com/GI/PGWY/SF/Schemas/Authorization/RVQ','true','true'};
		private String[] field_order_type_info = new String[]{'MerchantKey','IndustryType','TokenNumber','OrderID','AdjustedAmount','TransactionReferenceNumber'};
	}
	
	 public class SFReversalResponseResult_element {
		public String Status;
		public String Message;
		public String ErrorMessage;
		private String[] Status_type_info = new String[]{'Status','http://www.w3.org/2001/XMLSchema','string','1','1','false'};
		private String[] Message_type_info = new String[]{'Message','http://www.w3.org/2001/XMLSchema','string','1','1','false'};
		private String[] ErrorMessage_type_info = new String[]{'ErrorMessage','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
		private String[] apex_schema_type_info = new String[]{'http://NBTY.com/GI/PGWY/SF/Schemas/Authorization/RVS','true','true'};
		private String[] field_order_type_info = new String[]{'Status','Message','ErrorMessage'};
	}
	public class SFReversalResponse_element {
		public String TokenNumber;
		public String OrderID;
		public String TransactionReferenceNumber;
		public String TransactionReferenceIndex;
		public DateTime ResponseDateTime;
		public String OutstandingAmount;
		public SFReversalResponseResult_element SFReversalResponseResult;
		private String[] TokenNumber_type_info = new String[]{'TokenNumber','http://www.w3.org/2001/XMLSchema','string','1','1','false'};
		private String[] OrderID_type_info = new String[]{'OrderID','http://www.w3.org/2001/XMLSchema','string','1','1','false'};
		private String[] TransactionReferenceNumber_type_info = new String[]{'TransactionReferenceNumber','http://www.w3.org/2001/XMLSchema','string','1','1','false'};
		private String[] TransactionReferenceIndex_type_info = new String[]{'TransactionReferenceIndex','http://www.w3.org/2001/XMLSchema','string','1','1','false'};
		private String[] ResponseDateTime_type_info = new String[]{'ResponseDateTime','http://www.w3.org/2001/XMLSchema','dateTime','1','1','false'};
		private String[] OutstandingAmount_type_info = new String[]{'OutstandingAmount','http://NBTY.com/GI/PGWY/SF/Schemas/Authorization/RVS','OutstandingAmount_element','1','1','false'};
		private String[] SFReversalResponseResult_type_info = new String[]{'SFReversalResponseResult','http://NBTY.com/GI/PGWY/SF/Schemas/Authorization/RVS','SFReversalResponseResult_element','1','1','false'};
		private String[] apex_schema_type_info = new String[]{'http://NBTY.com/GI/PGWY/SF/Schemas/Authorization/RVS','true','true'};
		private String[] field_order_type_info = new String[]{'TokenNumber','OrderID','TransactionReferenceNumber','TransactionReferenceIndex','ResponseDateTime','OutstandingAmount','SFReversalResponseResult'};
	}
	
	public class SFSearchPaymentProfileByProfileIDRequest_element {
		public String PaymentProfileID;
		private String[] PaymentProfileID_type_info = new String[]{'PaymentProfileID','http://NBTY.com/GI/PGWY/Schemas/PaymentProfile/2.6/SF/SRQ','Guid','1','1','false'};
		private String[] apex_schema_type_info = new String[]{'http://NBTY.com/GI/PGWY/Schemas/PaymentProfile/2.6/SF/SRQ','true','true'};
		private String[] field_order_type_info = new String[]{'PaymentProfileID'};
	}
	
	public class Tokens_element {
		public String NameOnTheCreditCard;
		public String TokenNumber;
		public Integer CreditCardTypeID;
		public String CreditCardExpiryDate;
		public SRSAddressInfo_element AddressInfo;
		private String[] NameOnTheCreditCard_type_info = new String[]{'NameOnTheCreditCard','http://www.w3.org/2001/XMLSchema','string','1','1','false'};
		private String[] TokenNumber_type_info = new String[]{'TokenNumber','http://www.w3.org/2001/XMLSchema','string','1','1','false'};
		private String[] CreditCardTypeID_type_info = new String[]{'CreditCardTypeID','http://www.w3.org/2001/XMLSchema','int','1','1','false'};
		private String[] CreditCardExpiryDate_type_info = new String[]{'CreditCardExpiryDate','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
		private String[] AddressInfo_type_info = new String[]{'AddressInfo','http://NBTY.com/GI/PGWY/Schemas/PaymentProfile/2.6/SF/SRS','AddressInfo_element','0','1','false'};
		private String[] apex_schema_type_info = new String[]{'http://NBTY.com/GI/PGWY/Schemas/PaymentProfile/2.6/SF/SRS','true','true'};
		private String[] field_order_type_info = new String[]{'NameOnTheCreditCard','TokenNumber','CreditCardTypeID','CreditCardExpiryDate','AddressInfo'};
	}
	public class SRSAddressInfo_element {
		public String Address1;
		public String Address2;
		public String City;
		public String State;
		public String ZipCode;
		public String CountryCode;
		private String[] Address1_type_info = new String[]{'Address1','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
		private String[] Address2_type_info = new String[]{'Address2','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
		private String[] City_type_info = new String[]{'City','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
		private String[] State_type_info = new String[]{'State','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
		private String[] ZipCode_type_info = new String[]{'ZipCode','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
		private String[] CountryCode_type_info = new String[]{'CountryCode','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
		private String[] apex_schema_type_info = new String[]{'http://NBTY.com/GI/PGWY/Schemas/PaymentProfile/2.6/SF/SRS','true','true'};
		private String[] field_order_type_info = new String[]{'Address1','Address2','City','State','ZipCode','CountryCode'};
	}
	public class SFSearchPaymentProfileByProfileIDResponse_element {
		public String MerchantKey;
		public String LOBCustomerNumber;
		public String PaymentProfileID;
		public Tokens_element[] Tokens;
		private String[] MerchantKey_type_info = new String[]{'MerchantKey','http://www.w3.org/2001/XMLSchema','string','1','1','false'};
		private String[] LOBCustomerNumber_type_info = new String[]{'LOBCustomerNumber','http://www.w3.org/2001/XMLSchema','string','1','1','false'};
		private String[] PaymentProfileID_type_info = new String[]{'PaymentProfileID','http://NBTY.com/GI/PGWY/Schemas/PaymentProfile/2.6/SF/SRS','Guid','1','1','false'};
		private String[] Tokens_type_info = new String[]{'Tokens','http://NBTY.com/GI/PGWY/Schemas/PaymentProfile/2.6/SF/SRS','Tokens_element','0','-1','false'};
		private String[] apex_schema_type_info = new String[]{'http://NBTY.com/GI/PGWY/Schemas/PaymentProfile/2.6/SF/SRS','true','true'};
		private String[] field_order_type_info = new String[]{'MerchantKey','LOBCustomerNumber','PaymentProfileID','Tokens'};
	}
	
	public class URQCreditCardInfo_element {
		public String TokenNumber;
		public String CreditCardNumber;
		public String CreditCardExpiryDate;
		public String CreditCardTypeID;
		public String NameOnTheCreditCard;
		public String CreatePaymentProfileIndicator;
		public URQAddressInfo_element AddressInfo;
		private String[] TokenNumber_type_info = new String[]{'TokenNumber','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
		private String[] CreditCardNumber_type_info = new String[]{'CreditCardNumber','http://NBTY.com/GI/PGWY/Schemas/PaymentProfile/2.6/SF/URQ','CreditCardNumber_element','0','1','false'};
		private String[] CreditCardExpiryDate_type_info = new String[]{'CreditCardExpiryDate','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
		private String[] CreditCardTypeID_type_info = new String[]{'CreditCardTypeID','http://www.w3.org/2001/XMLSchema','string','1','1','false'};
		private String[] NameOnTheCreditCard_type_info = new String[]{'NameOnTheCreditCard','http://NBTY.com/GI/PGWY/Schemas/PaymentProfile/2.6/SF/URQ','NameOnTheCreditCard_element','0','1','false'};
		private String[] CreatePaymentProfileIndicator_type_info = new String[]{'CreatePaymentProfileIndicator','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
		private String[] AddressInfo_type_info = new String[]{'AddressInfo','http://NBTY.com/GI/PGWY/Schemas/PaymentProfile/2.6/SF/URQ','URQAddressInfo_element','0','1','false'};
		private String[] apex_schema_type_info = new String[]{'http://NBTY.com/GI/PGWY/Schemas/PaymentProfile/2.6/SF/URQ','true','true'};
		private String[] field_order_type_info = new String[]{'TokenNumber','CreditCardNumber','CreditCardExpiryDate','CreditCardTypeID','NameOnTheCreditCard','CreatePaymentProfileIndicator','AddressInfo'};
	}
	public class SFUpdatePaymentProfileRequest_element {
		public String MerchantKey;
		public String IndustryType;
		public String PaymentProfileID;
		public Boolean SaveCCInfoOnBankLinkDown;
		public String ActionCode;
		public Boolean IsBankLinkDownReprocessing;
		public URQCreditCardInfo_element CreditCardInfo;
		private String[] MerchantKey_type_info = new String[]{'MerchantKey','http://NBTY.com/GI/PGWY/Schemas/PaymentProfile/2.6/SF/URQ','MerchantKey_element','1','1','false'};
		private String[] IndustryType_type_info = new String[]{'IndustryType','http://NBTY.com/GI/PGWY/Schemas/PaymentProfile/2.6/SF/URQ','IndustryType_element','1','1','false'};
		private String[] PaymentProfileID_type_info = new String[]{'PaymentProfileID','http://NBTY.com/GI/PGWY/Schemas/PaymentProfile/2.6/SF/URQ','Guid','1','1','false'};
		private String[] SaveCCInfoOnBankLinkDown_type_info = new String[]{'SaveCCInfoOnBankLinkDown','http://www.w3.org/2001/XMLSchema','boolean','1','1','false'};
		private String[] ActionCode_type_info = new String[]{'ActionCode','http://NBTY.com/GI/PGWY/Schemas/PaymentProfile/2.6/SF/URQ','ActionCode_element','1','1','false'};
		private String[] IsBankLinkDownReprocessing_type_info = new String[]{'IsBankLinkDownReprocessing','http://www.w3.org/2001/XMLSchema','boolean','1','1','false'};
		private String[] CreditCardInfo_type_info = new String[]{'CreditCardInfo','http://NBTY.com/GI/PGWY/Schemas/PaymentProfile/2.6/SF/URQ','URQCreditCardInfo_element','1','1','false'};
		private String[] apex_schema_type_info = new String[]{'http://NBTY.com/GI/PGWY/Schemas/PaymentProfile/2.6/SF/URQ','true','true'};
		private String[] field_order_type_info = new String[]{'MerchantKey','IndustryType','PaymentProfileID','SaveCCInfoOnBankLinkDown','ActionCode','IsBankLinkDownReprocessing','CreditCardInfo'};
	}
	public class URQAddressInfo_element {
		public String Address1;
		public String Address2;
		public String City;
		public String State;
		public String ZipCode;
		public String CountryCode;
		private String[] Address1_type_info = new String[]{'Address1','http://NBTY.com/GI/PGWY/Schemas/PaymentProfile/2.6/SF/URQ','Address1_element','0','1','false'};
		private String[] Address2_type_info = new String[]{'Address2','http://NBTY.com/GI/PGWY/Schemas/PaymentProfile/2.6/SF/URQ','Address2_element','0','1','false'};
		private String[] City_type_info = new String[]{'City','http://NBTY.com/GI/PGWY/Schemas/PaymentProfile/2.6/SF/URQ','City_element','0','1','false'};
		private String[] State_type_info = new String[]{'State','http://NBTY.com/GI/PGWY/Schemas/PaymentProfile/2.6/SF/URQ','State_element','0','1','false'};
		private String[] ZipCode_type_info = new String[]{'ZipCode','http://NBTY.com/GI/PGWY/Schemas/PaymentProfile/2.6/SF/URQ','ZipCode_element','0','1','false'};
		private String[] CountryCode_type_info = new String[]{'CountryCode','http://NBTY.com/GI/PGWY/Schemas/PaymentProfile/2.6/SF/URQ','CountryCode_element','0','1','false'};
		private String[] apex_schema_type_info = new String[]{'http://NBTY.com/GI/PGWY/Schemas/PaymentProfile/2.6/SF/URQ','true','true'};
		private String[] field_order_type_info = new String[]{'Address1','Address2','City','State','ZipCode','CountryCode'};
	}
	public class SFUpdatePaymentProfileResponse_element {
		public String MerchantKey;
		public String PaymentProfileID;
		public String TokenNumber;
		public SFUpdatePaymentProfileResponseResult_element SFUpdatePaymentProfileResponseResult;
		private String[] MerchantKey_type_info = new String[]{'MerchantKey','http://www.w3.org/2001/XMLSchema','string','1','1','false'};
		private String[] PaymentProfileID_type_info = new String[]{'PaymentProfileID','http://NBTY.com/GI/PGWY/Schemas/PaymentProfile/2.6/SF/URS','Guid','1','1','false'};
		private String[] TokenNumber_type_info = new String[]{'TokenNumber','http://www.w3.org/2001/XMLSchema','string','1','1','false'};
		private String[] SFUpdatePaymentProfileResponseResult_type_info = new String[]{'Result','http://NBTY.com/GI/PGWY/Schemas/PaymentProfile/2.6/SF/URS','SFUpdatePaymentProfileResponseResult_element','1','1','false'};
		private String[] apex_schema_type_info = new String[]{'http://NBTY.com/GI/PGWY/Schemas/PaymentProfile/2.6/SF/URS','true','true'};
		private String[] field_order_type_info = new String[]{'MerchantKey','PaymentProfileID','TokenNumber','SFUpdatePaymentProfileResponseResult'};
	}
	public class SFUpdatePaymentProfileResponseResult_element {
		public String Status;
		public String Message;
		public String ErrorMessage;
		private String[] Status_type_info = new String[]{'Status','http://www.w3.org/2001/XMLSchema','string','1','1','false'};
		private String[] Message_type_info = new String[]{'Message','http://www.w3.org/2001/XMLSchema','string','1','1','false'};
		private String[] ErrorMessage_type_info = new String[]{'ErrorMessage','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
		private String[] apex_schema_type_info = new String[]{'http://NBTY.com/GI/PGWY/Schemas/PaymentProfile/2.6/SF/URS','true','true'};
		private String[] field_order_type_info = new String[]{'Status','Message','ErrorMessage'};
	}


}