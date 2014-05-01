public with sharing class WS_soa_AuthorizePaymentService {

	public static string getCreditCardTypeId(string creditCardType) {
		return NBTYUtils.getCCTypeMappings('Name').get(creditCardType).gateway_value__c;
	}
	
	public static string getCreditCardNameFromId(string cardId) {
		return NBTYUtils.getCCTypeMappings('Gateway').get(string.valueOf(cardId)).name;
	}
	
	public static list<OrderWizard_Wrapper.PaymentProfile> getAllPaymentProfieList(list<WS_SOA_Payment_DS_V2.Tokens_element> ResponseTokens) {
		list<OrderWizard_Wrapper.PaymentProfile> lstPaymentTokens = new list<OrderWizard_Wrapper.PaymentProfile>();
		if(ResponseTokens != null) {
			integer i=1;
			for(WS_SOA_Payment_DS_V2.Tokens_element te : ResponseTokens) {
				OrderWizard_Wrapper.PaymentProfile temp = new OrderWizard_Wrapper.PaymentProfile();
				temp.TokenId = te.TokenNumber;
				temp.cardSerial = 'Card' + string.valueof(i++);
				system.debug('~~ Token~~' + temp.TokenId);
				temp.name = te.NameOnTheCreditCard;
				temp.creditcardExpiry = te.CreditCardExpiryDate;
				temp.creditcardType = WS_soa_AuthorizePaymentService.getCreditCardNameFromId(string.valueof(te.CreditCardTypeID));
				WS_SOA_Payment_DS_V2.SRSAddressInfo_element tempAddress = new WS_SOA_Payment_DS_V2.SRSAddressInfo_element();
				tempAddress = te.AddressInfo;
				string details = '<table>'; 
				details += '<tr><td>Name on Card:</td><td>' + temp.name + '</td></tr>';
				details += '<tr><td>Card Type:</td><td>' + temp.creditcardType + '</td></tr>';
				details += '<tr><td>Expiration Date:</td><td>' + temp.creditcardExpiry + '</td></tr>';
				details += '<tr><td>Last 4 Digits:</td><td>' + temp.TokenId.right(4) + '</td></tr>';
				if(tempAddress != null) {
					temp.Addressline1 = tempaddress.Address1==null?'':tempaddress.Address1;
					temp.Addressline2 = tempaddress.Address2==null?'':' '+tempaddress.Address2;
					temp.city =  tempaddress.City==null?'':tempaddress.City;
					temp.state = tempaddress.State==null?'':tempaddress.State;
					temp.zip = tempaddress.ZipCode==null?'':tempaddress.ZipCode;
					system.debug('tempaddress.Address1' + tempaddress.Address1);
					temp.Address = temp.Addressline1 + ' ' + temp.Addressline2 + ' ' + temp.city + ' ' + temp.state + ' ' + temp.zip;
					details += '<tr><td>Address:</td><td>' + temp.Addressline1 +  '</td></tr>';
					details += '<tr><td></td><td>' + temp.city + ' ' + temp.state + ' ' + temp.zip +  '</td></tr>';
				} else {
					//details += '<tr><td>Address:</td><td>Not Available</td></tr>';
				}
				details += '</table>';
				string tempdetails = details.remove('#');
				temp.details = tempdetails;
				lstPaymentTokens.add(temp);
			}
		}
		return lstPaymentTokens;
	}
	
	public with sharing class PaymentInfo {
	
		public string orderId;
		public double amount;
		public string creditCardNumber {get;set;}
		public string expiryYYYYMM {get;set;}
		public string creditCardType {get;set;}
		public string nameOnCard {get;set;}
		public string addressLine1;
		public string addressLine2;
		public string city;
		public string state;
		public string zipCode;
		public string countryCode;
		public string merchantKey;
		public string paymentProfileID;
		
		public PaymentInfo() {
			orderId = '123456';
			amount = 0.00;
			creditCardNumber = '4112344112344113';
			expiryYYYYMM = '201606';
			nameOnCard = 'Fred Flinstone';
			addressLine1 = '123 Main St';
			addressLine2 = '';
			city = 'Vienna';
			state = 'VA';
			zipCode = '22102';
			countryCode = 'US';
			creditCardType = '1'; 
			merchantKey = 'DRMKEY1014';
			paymentProfileID = '';
		}
		
		public PaymentInfo(OrderWizard_Wrapper orderWrap) {
			//orderId=orderWrap.newOrder.name;
			orderId=orderWrap.newOrder.name;
			//nameOnCard=orderWrap.newOrder.customer__r.name;
			nameOnCard= orderWrap.newOrder.customer__r.name;
			amount=orderWrap.Total.setScale(2);
			addressLine1=orderWrap.billingAddress.address_line_1__c;
			addressLine2=orderWrap.billingAddress.address_line_2__c!=null?orderWrap.billingAddress.address_line_2__c:'';
			city=orderWrap.billingAddress.City__c;
			state=orderWrap.billingAddress.State_Providence__c;
			zipCode=orderWrap.billingAddress.Zip_Code__c;
			expiryYYYYMM=orderWrap.selectedccExpiry;
			countryCode=orderWrap.billingAddress.Country__c;
			paymentProfileID=orderWrap.paymentProfileid==null?'':orderWrap.paymentProfileid;
			// Fix for invalid country code issue
			if (string.isblank(countryCode) || countryCode.equalsIgnoreCase('null')) {
				Address__c billingAdd = [Select Country__c from Address__c where id =:orderWrap.billingAddress.id limit 1];
			
				countryCode = billingAdd.Country__c;
			}
			//creditCardType=getCreditCardTypeId(orderWrap.selectedccType);
			merchantKey =NBTYUtils.getRecordTypeBrandMappingMap().get( orderWrap.newOrder.customer__r.recordType.developerName).merchant_key__c;
		}
	}
	
	public with sharing class PaymentResponse {
		
		public String TokenNumber;
		public String PaymentProfileID;
		public String TransactionReferenceNumber;
		public String TransactionReferenceIndex;
		public String BankResponseDateTime;
		public String AuthorizationCode;
		public String StatusCode;
		public String StatusMessage;
		public String StatusType;
		
		public PaymentResponse() {
			TokenNumber = '';
			PaymentProfileID = '';
			TransactionReferenceNumber = '';
			TransactionReferenceIndex = '';
			BankResponseDateTime = '';
			AuthorizationCode = '';
			StatusCode = '';
			StatusMessage = '';
			Statustype = '';
		}
	}
	
	public class PaymentReversalResponse {
		public string ErrorMessage;
		public string Message;
		public string Status;
		
		public PaymentReversalResponse() {
			
		}
	}
	
	public static string authorizePayment (string xmlString) {
		
		HttpRequest req = new HttpRequest();
		string paymentEndPoint = WS_Integration__c.getValues('SOAEndpoint').value__C + WS_Integration__c.getValues('PaymentEndPoint').value__C;
		system.debug('*****' + paymentEndPoint);
		req.setEndpoint(paymentEndPoint);
		//req.setEndpoint('http://requestb.in/1go7kk41');
		req.setHeader('Content-Type', 'text/xml;charset=UTF-8');
		req.setHeader('Accept-Encoding','gzip,deflate'); 
		req.setHeader('SOAPAction','\"SFPreAuthorizeNewCreditCard\"');
		req.setTimeout(120000);
		req.setBody(xmlString);
		req.setMethod('POST');
		Http httpreq = new Http();
		HTTPResponse res = new HTTPResponse();
		
		try {
			SYSTEM.DEBUG('REQ'+REQ.getBody());
			res = httpreq.send(req);
		} catch(Exception e) {
			system.debug(e.getMessage());
			throw new NBTYException('Error processing payment.\n Please contact System Administrator.');
		}
		
		system.debug(res.toString());
		Integer responseCode = res.getStatusCode();
		String ResponseString = '';
		system.debug(responseCode);
		if (responseCode < 300) {// Success
			ResponseString = res.getBody();
			system.debug(ResponseString);
		} else {
			// Fix for timeout error friendly message.
			system.debug(ResponseString);
			string strErrorMessage = '[' + string.valueof(responseCode) + '] ' ;
			if(responseCode == 408) {
				strErrorMessage += 'Delay in processing payment.\n Please try again.';
			} else {
				strErrorMessage += 'Error processing payment.\n Please contact System Administrator.';
			}
			throw new NBTYException(strErrorMessage);
		}
		return responseString;
	}
}