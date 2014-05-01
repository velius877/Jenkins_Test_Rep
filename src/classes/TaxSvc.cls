////////////////////////////////////////////////////////////////////////////////
//   Copyright 2012 Avalara, Inc.
//
//   Licensed under the Apache License, Version 2.0 (the "License");
//   you may not use this file except in compliance with the License.
//   You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//   Unless required by applicable law or agreed to in writing, software
//   distributed under the License is distributed on an "AS IS" BASIS,
//   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//   See the License for the specific language governing permissions and
//   limitations under the License.
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
// TaxSvc is not instantiated directly, and is really in effect more 
// of a namespace than a class.
////////////////////////////////////////////////////////////////////////////////
public with sharing class TaxSvc {
// unit tests just instantiate an instance of every class
// in order to satisfy SF's code coverage requirement - no comment
    /*static testmethod void TaxUnitTests()
    {
        TaxSvc m_tTaxSvc = new TaxSvc();
        AuditMessage m_tAuditMessage = new AuditMessage();
        CommitTaxResult m_tCommitTaxResult = new CommitTaxResult();
        TaxSvcSoap m_tTaxSvcSoap = new TaxSvcSoap('https://bogus.url.net');
        IsAuthorized_element m_tIsAuthorized_element = new IsAuthorized_element();
        TaxAddress m_tTaxAddress = new TaxAddress();
        ArrayOfMessage m_tArrayOfMessage = new ArrayOfMessage();
        ArrayOfLine m_tArrayOfLine = new ArrayOfLine();
        ApplyPaymentResponse_element m_tApplyPaymentResponse_element = new ApplyPaymentResponse_element();
        GetTaxHistoryResult m_tGetTaxHistoryResult = new GetTaxHistoryResult();
        ArrayOfBaseAddress m_tArrayOfBaseAddress = new ArrayOfBaseAddress();
        PostTax_element m_tPostTax_element = new PostTax_element();
        PostTaxRequest m_tPostTaxRequest = new PostTaxRequest();
        AdjustTaxRequest m_tAdjustTaxRequest = new AdjustTaxRequest();
        ArrayOfTaxLine m_tArrayOfTaxLine = new ArrayOfTaxLine();
        ApplyPaymentRequest m_tApplyPaymentRequest = new ApplyPaymentRequest();
        PingResult m_tPingResult = new PingResult();
        IsAuthorizedResult m_tIsAuthorizedResult = new IsAuthorizedResult();
        IsAuthorizedResponse_element m_tIsAuthorizedResponse_element = new IsAuthorizedResponse_element();
        CommitTaxRequest m_tCommitTaxRequest = new CommitTaxRequest();
        TaxOverride m_tTaxOverride = new TaxOverride();
        Profile m_tProfile = new Profile();
        ReconcileTaxHistoryRequest m_tReconcileTaxHistoryRequest = new ReconcileTaxHistoryRequest();
        ApplyPaymentResult m_tApplyPaymentResult = new ApplyPaymentResult();
        BaseAddress m_tBaseAddress = new BaseAddress();
        ArrayOfTaxDetail m_tArrayOfTaxDetail = new ArrayOfTaxDetail();
        Security m_tSecurity = new Security();
        GetTaxHistoryResponse_element m_tGetTaxHistoryResponse_element = new GetTaxHistoryResponse_element();
        GetTax_element m_tGetTax_element = new GetTax_element();
        UsernameToken_element m_tUsernameToken_element = new UsernameToken_element();
        AdjustTaxResult m_tAdjustTaxResult = new AdjustTaxResult();
        GetTaxResult m_tGetTaxResult = new GetTaxResult();
        CommitTax_element m_tCommitTax_element = new CommitTax_element();
        ReconcileTaxHistoryResult m_tReconcileTaxHistoryResult = new ReconcileTaxHistoryResult();
        AdjustTax_element m_tAdjustTax_element = new AdjustTax_element();
        AdjustTaxResponse_element m_tAdjustTaxResponse_element = new AdjustTaxResponse_element();
        Ping_element m_tPing_element = new Ping_element();
        GetTaxHistory_element m_tGetTaxHistory_element = new GetTaxHistory_element();
        ArrayOfTaxAddress m_tArrayOfTaxAddress = new ArrayOfTaxAddress();
        PostTaxResponse_element m_tPostTaxResponse_element = new PostTaxResponse_element();
        GetTaxRequest m_tGetTaxRequest = new GetTaxRequest();
        CancelTax_element m_tCancelTax_element = new CancelTax_element();
        CommitTaxResponse_element m_tCommitTaxResponse_element = new CommitTaxResponse_element();
        PostTaxResult m_tPostTaxResult = new PostTaxResult();
        ReconcileTaxHistoryResponse_element m_tReconcileTaxHistoryResponse_element = new ReconcileTaxHistoryResponse_element();
        CancelTaxResult m_tCancelTaxResult = new CancelTaxResult();
        TaxDetail m_tTaxDetail = new TaxDetail();
        Message m_tMessage = new Message();
        PingResponse_element m_tPingResponse_element = new PingResponse_element();
        GetTaxHistoryRequest m_tGetTaxHistoryRequest = new GetTaxHistoryRequest();
        ApplyPayment_element m_tApplyPayment_element = new ApplyPayment_element();
        CancelTaxRequest m_tCancelTaxRequest = new CancelTaxRequest();
        ReconcileTaxHistory_element m_tReconcileTaxHistory_element = new ReconcileTaxHistory_element();
        GetTaxResponse_element m_tGetTaxResponse_element = new GetTaxResponse_element();
        CancelTaxResponse_element m_tCancelTaxResponse_element = new CancelTaxResponse_element();
        TaxLine m_tTaxLine = new TaxLine();
        ArrayOfGetTaxResult m_tArrayOfGetTaxResult = new ArrayOfGetTaxResult();
        Line m_tLine = new Line();
    } */

////////////////////////////////////////////////////////////////////////////////
// TaxSvcSoap is the mother class.  All APIs of the TaxSvc "namespace"
// are methods of TaxSvcSoap.
////////////////////////////////////////////////////////////////////////////////
    public with sharing class TaxSvcSoap {
        public String endpoint_x = 'https://development.avalara.net/Tax/TaxSvc.asmx/altsec';
        public Map<String,String> inputHttpHeaders_x;
        public Map<String,String> outputHttpHeaders_x;
        public String clientCertName_x;
        public String clientCert_x;
        public String clientCertPasswd_x;
        public Integer timeout_x {get; set;}
        public TaxSvc.AuditMessage AuditMessage;
        public TaxSvc.Profile Profile;
        public TaxSvc.Security Security;
        private String AuditMessage_hns = 'AuditMessage=http://avatax.avalara.com/services';
        private String Profile_hns = 'Profile=http://avatax.avalara.com/services';
        private String Security_hns = 'Security=http://avatax.avalara.com/services';
        private String[] ns_map_type_info = new String[]{'http://avatax.avalara.com/services', 'TaxSvc'};
        public TaxSvcSoap(String SvcURL)
        {
            endpoint_x = SvcURL + '/tax/taxsvc.asmx/altsec';
            Profile = new TaxSvc.Profile();
            Security = new TaxSvc.Security();
        }
        
        
        
       
        
        public TaxSvc.GetTaxResult GetTax(TaxSvc.GetTaxRequest GetTaxRequest) {
            TaxSvc.GetTax_element request_x = new TaxSvc.GetTax_element();
            TaxSvc.GetTaxResponse_element response_x;
            request_x.GetTaxRequest = GetTaxRequest;
            Map<String, TaxSvc.GetTaxResponse_element> response_map_x = new Map<String, TaxSvc.GetTaxResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              'http://avatax.avalara.com/services/GetTax',
              'http://avatax.avalara.com/services',
              'GetTax',
              'http://avatax.avalara.com/services',
              'GetTaxResponse',
              'TaxSvc.GetTaxResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            system.debug('$$$$ Response' + response_x);
            return response_x.GetTaxResult;
        }
        
       
    }

////////////////////////////////////////////////////////////////////////////////
// API call Request Classes - instantiations passed as arguments to API calls
////////////////////////////////////////////////////////////////////////////////
    public with sharing class GetTaxRequest {
        public String CompanyCode;
        public String DocType = 'SalesOrder';
        public String DocCode;
        public Date DocDate = Date.Today();
        public String SalespersonCode;
        public String CustomerCode;
        public String CustomerUsageType;
        public Decimal Discount = 0.0;
        public String PurchaseOrderNo;
        public String ExemptionNo;
        public String OriginCode;
        public String DestinationCode;
        public TaxSvc.ArrayOfBaseAddress Addresses;
        public TaxSvc.ArrayOfLine Lines;
        public String DetailLevel = 'Document';
        public String ReferenceCode;
        public String LocationCode;
        public Boolean Commit_x = false;
        public String BatchCode;
        public TaxSvc.TaxOverride TaxOverride;
        public String CurrencyCode;
        public String ServiceMode = 'Automatic';
        public Date PaymentDate = Date.Today();
        public Decimal ExchangeRate = 1.0;
        public Date ExchangeRateEffDate = Date.Today();
        public Integer HashCode;
        private String[] HashCode_type_info = new String[]{'HashCode','http://www.w3.org/2001/XMLSchema','int','1','1','false'};
        private String[] CompanyCode_type_info = new String[]{'CompanyCode','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] DocType_type_info = new String[]{'DocType','http://avatax.avalara.com/services','DocumentType','1','1','false'};
        private String[] DocCode_type_info = new String[]{'DocCode','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] DocDate_type_info = new String[]{'DocDate','http://www.w3.org/2001/XMLSchema','date','1','1','false'};
        private String[] SalespersonCode_type_info = new String[]{'SalespersonCode','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] CustomerCode_type_info = new String[]{'CustomerCode','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] CustomerUsageType_type_info = new String[]{'CustomerUsageType','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] Discount_type_info = new String[]{'Discount','http://www.w3.org/2001/XMLSchema','decimal','1','1','false'};
        private String[] PurchaseOrderNo_type_info = new String[]{'PurchaseOrderNo','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] ExemptionNo_type_info = new String[]{'ExemptionNo','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] OriginCode_type_info = new String[]{'OriginCode','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] DestinationCode_type_info = new String[]{'DestinationCode','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] Addresses_type_info = new String[]{'Addresses','http://avatax.avalara.com/services','ArrayOfBaseAddress','0','1','false'};
        private String[] Lines_type_info = new String[]{'Lines','http://avatax.avalara.com/services','ArrayOfLine','0','1','false'};
        private String[] DetailLevel_type_info = new String[]{'DetailLevel','http://avatax.avalara.com/services','DetailLevel','1','1','false'};
        private String[] ReferenceCode_type_info = new String[]{'ReferenceCode','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] LocationCode_type_info = new String[]{'LocationCode','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] Commit_x_type_info = new String[]{'Commit','http://www.w3.org/2001/XMLSchema','boolean','1','1','false'};
        private String[] BatchCode_type_info = new String[]{'BatchCode','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] TaxOverride_type_info = new String[]{'TaxOverride','http://avatax.avalara.com/services','TaxOverride','0','1','false'};
        private String[] CurrencyCode_type_info = new String[]{'CurrencyCode','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] ServiceMode_type_info = new String[]{'ServiceMode','http://avatax.avalara.com/services','ServiceMode','1','1','false'};
        private String[] PaymentDate_type_info = new String[]{'PaymentDate','http://www.w3.org/2001/XMLSchema','date','1','1','false'};
        private String[] ExchangeRate_type_info = new String[]{'ExchangeRate','http://www.w3.org/2001/XMLSchema','decimal','1','1','false'};
        private String[] ExchangeRateEffDate_type_info = new String[]{'ExchangeRateEffDate','http://www.w3.org/2001/XMLSchema','date','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://avatax.avalara.com/services','true','false'};
        private String[] field_order_type_info = new String[]{'CompanyCode','DocType','DocCode','DocDate','SalespersonCode','CustomerCode','CustomerUsageType','Discount','PurchaseOrderNo','ExemptionNo','OriginCode','DestinationCode','Addresses','Lines','DetailLevel','ReferenceCode','LocationCode','Commit_x','BatchCode','TaxOverride','CurrencyCode','ServiceMode','PaymentDate','ExchangeRate','ExchangeRateEffDate'};
    }
   
////////////////////////////////////////////////////////////////////////////////
// API call Result Classes - API calls return instantiations of these
////////////////////////////////////////////////////////////////////////////////
 public with sharing class GetTaxResult {
        public String DocId;
        public String TransactionId;
        public String ResultCode;
        public TaxSvc.ArrayOfMessage Messages;
        public String DocType = 'SalesOrder';
        public String DocCode;
        public Date DocDate = Date.Today();
        public String DocStatus = 'Temporary';
        public Boolean Reconciled = false;
        public DateTime Timestamp = DateTime.Now();
        public Decimal TotalAmount = 0.0;
        public Decimal TotalDiscount = 0.0;
        public Decimal TotalExemption = 0.0;
        public Decimal TotalTaxable = 0.0;
        public Decimal TotalTax = 0.0;
        public Decimal TotalTaxCalculated = 0.0;
        public Integer HashCode;
        public TaxSvc.ArrayOfTaxLine TaxLines;
        public TaxSvc.ArrayOfTaxAddress TaxAddresses;
        public Boolean Locked = false;
        public Integer AdjustmentReason = 0;
        public String AdjustmentDescription;
        public Integer Version = 0;
        public Date TaxDate = Date.Today();
        public TaxSvc.ArrayOfTaxDetail TaxSummary;
        public Boolean VolatileTaxRates = false;
        private String[] DocId_type_info = new String[]{'DocId','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] TransactionId_type_info = new String[]{'TransactionId','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] ResultCode_type_info = new String[]{'ResultCode','http://avatax.avalara.com/services','SeverityLevel','1','1','false'};
        private String[] Messages_type_info = new String[]{'Messages','http://avatax.avalara.com/services','ArrayOfMessage','0','1','false'};
        private String[] DocType_type_info = new String[]{'DocType','http://avatax.avalara.com/services','DocumentType','1','1','false'};
        private String[] DocCode_type_info = new String[]{'DocCode','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] DocDate_type_info = new String[]{'DocDate','http://www.w3.org/2001/XMLSchema','date','1','1','false'};
        private String[] DocStatus_type_info = new String[]{'DocStatus','http://avatax.avalara.com/services','DocStatus','1','1','false'};
        private String[] Reconciled_type_info = new String[]{'Reconciled','http://www.w3.org/2001/XMLSchema','boolean','1','1','false'};
        private String[] Timestamp_type_info = new String[]{'Timestamp','http://www.w3.org/2001/XMLSchema','dateTime','1','1','false'};
        private String[] TotalAmount_type_info = new String[]{'TotalAmount','http://www.w3.org/2001/XMLSchema','decimal','1','1','false'};
        private String[] TotalDiscount_type_info = new String[]{'TotalDiscount','http://www.w3.org/2001/XMLSchema','decimal','1','1','false'};
        private String[] TotalExemption_type_info = new String[]{'TotalExemption','http://www.w3.org/2001/XMLSchema','decimal','1','1','false'};
        private String[] TotalTaxable_type_info = new String[]{'TotalTaxable','http://www.w3.org/2001/XMLSchema','decimal','1','1','false'};
        private String[] TotalTax_type_info = new String[]{'TotalTax','http://www.w3.org/2001/XMLSchema','decimal','1','1','false'};
        private String[] TotalTaxCalculated_type_info = new String[]{'TotalTaxCalculated','http://www.w3.org/2001/XMLSchema','decimal','1','1','false'};
        private String[] HashCode_type_info = new String[]{'HashCode','http://www.w3.org/2001/XMLSchema','int','1','1','false'};
        private String[] TaxLines_type_info = new String[]{'TaxLines','http://avatax.avalara.com/services','ArrayOfTaxLine','0','1','false'};
        private String[] TaxAddresses_type_info = new String[]{'TaxAddresses','http://avatax.avalara.com/services','ArrayOfTaxAddress','0','1','false'};
        private String[] Locked_type_info = new String[]{'Locked','http://www.w3.org/2001/XMLSchema','boolean','1','1','false'};
        private String[] AdjustmentReason_type_info = new String[]{'AdjustmentReason','http://www.w3.org/2001/XMLSchema','int','1','1','false'};
        private String[] AdjustmentDescription_type_info = new String[]{'AdjustmentDescription','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] Version_type_info = new String[]{'Version','http://www.w3.org/2001/XMLSchema','int','1','1','false'};
        private String[] TaxDate_type_info = new String[]{'TaxDate','http://www.w3.org/2001/XMLSchema','date','1','1','false'};
        private String[] TaxSummary_type_info = new String[]{'TaxSummary','http://avatax.avalara.com/services','ArrayOfTaxDetail','0','1','false'};
        private String[] VolatileTaxRates_type_info = new String[]{'VolatileTaxRates','http://www.w3.org/2001/XMLSchema','boolean','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://avatax.avalara.com/services','true','false'};
        private String[] field_order_type_info = new String[]{'TransactionId','ResultCode','Messages','DocType','DocCode','DocDate','DocStatus','Reconciled','Timestamp','TotalAmount','TotalDiscount','TotalExemption','TotalTaxable','TotalTax','TotalTaxCalculated','TaxLines','TaxAddresses','Locked','AdjustmentReason','AdjustmentDescription','Version','TaxDate','TaxSummary'};
    }

////////////////////////////////////////////////////////////////////////////////
// Secondary Data Structures - all directly instantiable.  Most are referenced
// as embedded members of a request or result object
////////////////////////////////////////////////////////////////////////////////

    public with sharing class AuditMessage {
        public String Message;
        private String[] Message_type_info = new String[]{'Message','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://avatax.avalara.com/services','true','false'};
        private String[] field_order_type_info = new String[]{'Message'};
    }

    public with sharing class TaxAddress {
        public String Address;
        public String AddressCode;
        public Integer BoundaryLevel = 0;
        public String City;
        public String Country;
        public String PostalCode;
        public String Region;
        public Integer TaxRegionId = 0;
        public String JurisCode;
        public String Latitude;
        public String Longitude;
        public String ValidateStatus;
        public String GeocodeType;
        public String DistanceToBoundary;
        private String[] Address_type_info = new String[]{'Address','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] AddressCode_type_info = new String[]{'AddressCode','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] BoundaryLevel_type_info = new String[]{'BoundaryLevel','http://www.w3.org/2001/XMLSchema','int','1','1','false'};
        private String[] City_type_info = new String[]{'City','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] Country_type_info = new String[]{'Country','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] PostalCode_type_info = new String[]{'PostalCode','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] Region_type_info = new String[]{'Region','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] TaxRegionId_type_info = new String[]{'TaxRegionId','http://www.w3.org/2001/XMLSchema','int','1','1','false'};
        private String[] JurisCode_type_info = new String[]{'JurisCode','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] Latitude_type_info = new String[]{'Latitude','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] Longitude_type_info = new String[]{'Longitude','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] ValidateStatus_type_info = new String[]{'ValidateStatus','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] GeocodeType_type_info = new String[]{'GeocodeType','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] DistanceToBoundary_type_info = new String[]{'DistanceToBoundary','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://avatax.avalara.com/services','true','false'};
        private String[] field_order_type_info = new String[]{'Address','AddressCode','BoundaryLevel','City','Country','PostalCode','Region','TaxRegionId','JurisCode'};
    }

    public with sharing class ArrayOfMessage {
        public TaxSvc.Message[] Message;
        private String[] Message_type_info = new String[]{'Message','http://avatax.avalara.com/services','Message','0','-1','true'};
        private String[] apex_schema_type_info = new String[]{'http://avatax.avalara.com/services','true','false'};
        private String[] field_order_type_info = new String[]{'Message'};
    }

    public with sharing class ArrayOfLine {
        public TaxSvc.Line[] Line;
        private String[] Line_type_info = new String[]{'Line','http://avatax.avalara.com/services','Line','0','-1','true'};
        private String[] apex_schema_type_info = new String[]{'http://avatax.avalara.com/services','true','false'};
        private String[] field_order_type_info = new String[]{'Line'};
    }

    public with sharing class ArrayOfBaseAddress {
        public TaxSvc.BaseAddress[] BaseAddress;
        private String[] BaseAddress_type_info = new String[]{'BaseAddress','http://avatax.avalara.com/services','BaseAddress','0','-1','true'};
        private String[] apex_schema_type_info = new String[]{'http://avatax.avalara.com/services','true','false'};
        private String[] field_order_type_info = new String[]{'BaseAddress'};
    }

    public with sharing class ArrayOfTaxLine {
        public TaxSvc.TaxLine[] TaxLine;
        private String[] TaxLine_type_info = new String[]{'TaxLine','http://avatax.avalara.com/services','TaxLine','0','-1','true'};
        private String[] apex_schema_type_info = new String[]{'http://avatax.avalara.com/services','true','false'};
        private String[] field_order_type_info = new String[]{'TaxLine'};
    }

    public with sharing class TaxOverride {
        public String TaxOverrideType = 'None';
        public Decimal TaxAmount = 0.0;
        public Date TaxDate = Date.Today();
        public String Reason;
        private String[] TaxOverrideType_type_info = new String[]{'TaxOverrideType','http://avatax.avalara.com/services','TaxOverrideType','1','1','false'};
        private String[] TaxAmount_type_info = new String[]{'TaxAmount','http://www.w3.org/2001/XMLSchema','decimal','1','1','false'};
        private String[] TaxDate_type_info = new String[]{'TaxDate','http://www.w3.org/2001/XMLSchema','date','1','1','false'};
        private String[] Reason_type_info = new String[]{'Reason','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://avatax.avalara.com/services','true','false'};
        private String[] field_order_type_info = new String[]{'TaxOverrideType','TaxAmount','TaxDate','Reason'};
    }

    public with sharing class Profile {
        public String Name = 'Apex2AvalaraSDK.11.2.1.0';
        public String Client;
        public String Adapter = 'Apex2AvalaraSDK.11.2.1.0';
        public String Machine = 'SFCloud';
        private String[] Name_type_info = new String[]{'Name','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] Client_type_info = new String[]{'Client','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] Adapter_type_info = new String[]{'Adapter','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] Machine_type_info = new String[]{'Machine','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://avatax.avalara.com/services','true','false'};
        private String[] field_order_type_info = new String[]{'Name','Client','Adapter','Machine'};
    }

    public with sharing class BaseAddress {
        public String AddressCode;
        public String Line1;
        public String Line2;
        public String Line3;
        public String City;
        public String Region;
        public String PostalCode;
        public String Country;
        public Integer TaxRegionId = 0;
        public String Latitude;
        public String Longitude;
        private String[] AddressCode_type_info = new String[]{'AddressCode','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] Line1_type_info = new String[]{'Line1','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] Line2_type_info = new String[]{'Line2','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] Line3_type_info = new String[]{'Line3','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] City_type_info = new String[]{'City','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] Region_type_info = new String[]{'Region','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] PostalCode_type_info = new String[]{'PostalCode','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] Country_type_info = new String[]{'Country','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] TaxRegionId_type_info = new String[]{'TaxRegionId','http://www.w3.org/2001/XMLSchema','int','1','1','false'};
        private String[] Latitude_type_info = new String[]{'Latitude','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] Longitude_type_info = new String[]{'Longitude','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://avatax.avalara.com/services','true','false'};
        private String[] field_order_type_info = new String[]{'AddressCode','Line1','Line2','Line3','City','Region','PostalCode','Country','TaxRegionId'};
    }

    public with sharing class ArrayOfTaxDetail{
        public TaxSvc.TaxDetail[] TaxDetail;
        private String[] TaxDetail_type_info = new String[]{'TaxDetail','http://avatax.avalara.com/services','TaxDetail','0','-1','true'};
        private String[] apex_schema_type_info = new String[]{'http://avatax.avalara.com/services','true','false'};
        private String[] field_order_type_info = new String[]{'TaxDetail'};
    }

    public with sharing class Security {
        public UsernameToken_element UsernameToken = new UsernameToken_element();
        private String[] UsernameToken_type_info = new String[]{'UsernameToken','http://avatax.avalara.com/services','UsernameToken_element','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://avatax.avalara.com/services','true','false'};
        private String[] field_order_type_info = new String[]{'UsernameToken'};
    }

    public with sharing class ArrayOfTaxAddress {
        public TaxSvc.TaxAddress[] TaxAddress;
        private String[] TaxAddress_type_info = new String[]{'TaxAddress','http://avatax.avalara.com/services','TaxAddress','0','-1','true'};
        private String[] apex_schema_type_info = new String[]{'http://avatax.avalara.com/services','true','false'};
        private String[] field_order_type_info = new String[]{'TaxAddress'};
    }
    
    private class UsernameToken_element {
        public String Username;
        public String Password;
        private String[] Username_type_info = new String[]{'Username','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] Password_type_info = new String[]{'Password','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://avatax.avalara.com/services','true','false'};
        private String[] field_order_type_info = new String[]{'Username','Password'};
    }

    public with sharing class TaxDetail {
        public String Country;
        public String Region;
        public String JurisType = 'Composite';
        public String JurisCode;
        public String TaxType = 'Sales';
        public Decimal Base = 0.0;
        public Decimal Taxable = 0.0;
        public Decimal Rate = 0.0;
        public Decimal Tax = 0.0;
        public Decimal TaxCalculated = 0.0;
        public Decimal NonTaxable = 0.0;
        public Decimal Exemption = 0.0;
        public String JurisName;
        public String TaxName;
        public Integer TaxAuthorityType = 0;
        public String TaxGroup;
        public String RateType;
        public String StateAssignedNo;
        private String[] Country_type_info = new String[]{'Country','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] Region_type_info = new String[]{'Region','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] JurisType_type_info = new String[]{'JurisType','http://avatax.avalara.com/services','JurisdictionType','1','1','false'};
        private String[] JurisCode_type_info = new String[]{'JurisCode','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] TaxType_type_info = new String[]{'TaxType','http://avatax.avalara.com/services','TaxType','1','1','false'};
        private String[] Base_type_info = new String[]{'Base','http://www.w3.org/2001/XMLSchema','decimal','1','1','false'};
        private String[] Taxable_type_info = new String[]{'Taxable','http://www.w3.org/2001/XMLSchema','decimal','1','1','false'};
        private String[] Rate_type_info = new String[]{'Rate','http://www.w3.org/2001/XMLSchema','decimal','1','1','false'};
        private String[] Tax_type_info = new String[]{'Tax','http://www.w3.org/2001/XMLSchema','decimal','1','1','false'};
        private String[] TaxCalculated_type_info = new String[]{'TaxCalculated','http://www.w3.org/2001/XMLSchema','decimal','1','1','false'};
        private String[] NonTaxable_type_info = new String[]{'NonTaxable','http://www.w3.org/2001/XMLSchema','decimal','1','1','false'};
        private String[] Exemption_type_info = new String[]{'Exemption','http://www.w3.org/2001/XMLSchema','decimal','1','1','false'};
        private String[] JurisName_type_info = new String[]{'JurisName','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] TaxName_type_info = new String[]{'TaxName','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] TaxAuthorityType_type_info = new String[]{'TaxAuthorityType','http://www.w3.org/2001/XMLSchema','int','1','1','false'};
        private String[] TaxGroup_type_info = new String[]{'TaxGroup','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] RateType_type_info = new String[]{'RateType','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] StateAssignedNo_type_info = new String[]{'StateAssignedNo','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://avatax.avalara.com/services','true','false'};
        private String[] field_order_type_info = new String[]{'Country','Region','JurisType','JurisCode','TaxType','Base','Taxable','Rate','Tax','TaxCalculated','NonTaxable','Exemption','JurisName','TaxName','TaxAuthorityType','TaxGroup','RateType','StateAssignedNo'};
    }

    public with sharing class Message {
        public String Summary;
        public String Details;
        public String HelpLink;
        public String RefersTo;
        public String Severity = 'Error';
        public String Source;
        public String Name;
        private String[] Summary_type_info = new String[]{'Summary','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] Details_type_info = new String[]{'Details','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] HelpLink_type_info = new String[]{'HelpLink','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] RefersTo_type_info = new String[]{'RefersTo','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] Severity_type_info = new String[]{'Severity','http://avatax.avalara.com/services','SeverityLevel','1','1','false'};
        private String[] Source_type_info = new String[]{'Source','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] Name_att_info = new String[]{'Name'};
        private String[] apex_schema_type_info = new String[]{'http://avatax.avalara.com/services','true','false'};
        private String[] field_order_type_info = new String[]{'Summary','Details','HelpLink','RefersTo','Severity','Source'};
     }

     public with sharing class TaxLine {
        public String No;
        public String TaxCode;
        public Boolean Taxability = false;
        public String BoundaryLevel = 'Zip5';
        public Decimal Exemption = 0.0;
        public Decimal Discount = 0.0;
        public Decimal Taxable = 0.0;
        public Decimal Rate = 0.0;
        public Decimal Tax = 0.0;
        public Decimal TaxCalculated = 0.0;
        public TaxSvc.ArrayOfTaxDetail TaxDetails;
        public Integer ExemptCertId = 0;
        public Date TaxDate = Date.Today();
        public Date ReportingDate = Date.Today();
        public String AccountingMethod = 'Accrual';
        public Boolean TaxIncluded;
        private String[] No_type_info = new String[]{'No','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] TaxCode_type_info = new String[]{'TaxCode','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] Taxability_type_info = new String[]{'Taxability','http://www.w3.org/2001/XMLSchema','boolean','1','1','false'};
        private String[] BoundaryLevel_type_info = new String[]{'BoundaryLevel','http://avatax.avalara.com/services','BoundaryLevel','1','1','false'};
        private String[] Exemption_type_info = new String[]{'Exemption','http://www.w3.org/2001/XMLSchema','decimal','1','1','false'};
        private String[] Discount_type_info = new String[]{'Discount','http://www.w3.org/2001/XMLSchema','decimal','1','1','false'};
        private String[] Taxable_type_info = new String[]{'Taxable','http://www.w3.org/2001/XMLSchema','decimal','1','1','false'};
        private String[] Rate_type_info = new String[]{'Rate','http://www.w3.org/2001/XMLSchema','decimal','1','1','false'};
        private String[] Tax_type_info = new String[]{'Tax','http://www.w3.org/2001/XMLSchema','decimal','1','1','false'};
        private String[] TaxCalculated_type_info = new String[]{'TaxCalculated','http://www.w3.org/2001/XMLSchema','decimal','1','1','false'};
        private String[] TaxDetails_type_info = new String[]{'TaxDetails','http://avatax.avalara.com/services','ArrayOfTaxDetail','0','1','false'};
        private String[] ExemptCertId_type_info = new String[]{'ExemptCertId','http://www.w3.org/2001/XMLSchema','int','1','1','false'};
        private String[] TaxDate_type_info = new String[]{'TaxDate','http://www.w3.org/2001/XMLSchema','date','1','1','false'};
        private String[] ReportingDate_type_info = new String[]{'ReportingDate','http://www.w3.org/2001/XMLSchema','date','1','1','false'};
        private String[] AccountingMethod_type_info = new String[]{'AccountingMethod','http://avatax.avalara.com/services','AccountingMethod','1','1','false'};
        private String[] TaxIncluded_type_info = new String[]{'TaxIncluded','http://www.w3.org/2001/XMLSchema','boolean','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://avatax.avalara.com/services','true','false'};
        private String[] field_order_type_info = new String[]{'No','TaxCode','Taxability','BoundaryLevel','Exemption','Discount','Taxable','Rate','Tax','TaxCalculated','TaxDetails','ExemptCertId','TaxDate','ReportingDate','AccountingMethod','TaxIncluded'};
    }

    public with sharing class ArrayOfGetTaxResult {
        public TaxSvc.GetTaxResult[] GetTaxResult;
        private String[] GetTaxResult_type_info = new String[]{'GetTaxResult','http://avatax.avalara.com/services','GetTaxResult','0','-1','true'};
        private String[] apex_schema_type_info = new String[]{'http://avatax.avalara.com/services','true','false'};
        private String[] field_order_type_info = new String[]{'GetTaxResult'};
    }

    public with sharing class Line {
        public String No;
        public String OriginCode;
        public String DestinationCode;
        public String ItemCode;
        public String TaxCode;
        public Decimal Qty = 1.0;
        public Decimal Amount = 0.0;
        public Boolean Discounted = false;
        public String RevAcct;
        public String Ref1;
        public String Ref2;
        public String ExemptionNo;
        public String CustomerUsageType;
        public String Description;
        public TaxSvc.TaxOverride TaxOverride;
        public Boolean TaxIncluded;
        private String[] No_type_info = new String[]{'No','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] OriginCode_type_info = new String[]{'OriginCode','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] DestinationCode_type_info = new String[]{'DestinationCode','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] ItemCode_type_info = new String[]{'ItemCode','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] TaxCode_type_info = new String[]{'TaxCode','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] Qty_type_info = new String[]{'Qty','http://www.w3.org/2001/XMLSchema','decimal','1','1','false'};
        private String[] Amount_type_info = new String[]{'Amount','http://www.w3.org/2001/XMLSchema','decimal','1','1','false'};
        private String[] Discounted_type_info = new String[]{'Discounted','http://www.w3.org/2001/XMLSchema','boolean','1','1','false'};
        private String[] RevAcct_type_info = new String[]{'RevAcct','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] Ref1_type_info = new String[]{'Ref1','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] Ref2_type_info = new String[]{'Ref2','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] ExemptionNo_type_info = new String[]{'ExemptionNo','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] CustomerUsageType_type_info = new String[]{'CustomerUsageType','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] Description_type_info = new String[]{'Description','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] TaxOverride_type_info = new String[]{'TaxOverride','http://avatax.avalara.com/services','TaxOverride','0','1','false'};
        private String[] TaxIncluded_type_info = new String[]{'TaxIncluded','http://www.w3.org/2001/XMLSchema','boolean','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://avatax.avalara.com/services','true','false'};
        private String[] field_order_type_info = new String[]{'No','OriginCode','DestinationCode','ItemCode','TaxCode','Qty','Amount','Discounted','RevAcct','Ref1','Ref2','ExemptionNo','CustomerUsageType','Description','TaxOverride','TaxIncluded'};
    }

////////////////////////////////////////////////////////////////////////////////
// helper classes - visible to other classes within TaxSvc, 
// but not to the end user
////////////////////////////////////////////////////////////////////////////////
    
    private class GetTax_element {
        public TaxSvc.GetTaxRequest GetTaxRequest;
        private String[] GetTaxRequest_type_info = new String[]{'GetTaxRequest','http://avatax.avalara.com/services','GetTaxRequest','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://avatax.avalara.com/services','true','false'};
        private String[] field_order_type_info = new String[]{'GetTaxRequest'};
    }

    private class GetTaxResponse_element {
        public TaxSvc.GetTaxResult GetTaxResult;
        private String[] GetTaxResult_type_info = new String[]{'GetTaxResult','http://avatax.avalara.com/services','GetTaxResult','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://avatax.avalara.com/services','true','false'};
        private String[] field_order_type_info = new String[]{'GetTaxResult'};
    }
    
}