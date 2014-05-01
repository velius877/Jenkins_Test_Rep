public with sharing class OrderLookup_Wrapper {
	public List<Wrapper_Line> wrapperLineList {get;set;}
	public OrderLookup_Wrapper() {
		
	}
	public boolean isHisOrder {get;set;}
	
	public orders__c orderRec {
		get {
			if(orderRec == null) orderRec = new orders__c();
				return orderRec;
		}
		set {orderRec = value;} 
	} 
	
	public ws_Soa_OrderHistoryService.orders hisOrder {
		get {
			if(hisOrder == null) {
				hisOrder = new ws_Soa_OrderHistoryService.orders();
				
			}
			return hisOrder;
		}
		set {hisOrder = value;}
	}
	
	public string orderDate {
		get {
			if(isHisOrder) 
				return hisOrder.orderHeader.purchaseDateFormat;
			else
				return string.valueof(orderRec.Order_Date__c.month()) + '-' + string.valueof(orderRec.Order_Date__c.day()) + '-' + string.valueof(orderRec.Order_Date__c.year()).substring(2, 4);	
		}
	}
	
	public decimal orderAmount {
		get {
			if(isHisOrder) 
				return decimal.valueof(hisOrder.orderHeader.totalNetPurchaseAmount);
			else if(!isHisOrder && orderRec.Payment_Type__c == 'Credit Card' )
				return orderRec.Authorization_Amount__c;	
			else
				return orderRec.Order_Total__c;	
		}
		
	}
	//used to Display AS400 number for matching SF Orders
	public string SFOrderNo {get;set;}
	public string WebOrderNo {get;set;}
	
	public class wrapper_line {
		public ws_Soa_OrderHistoryService.lineItem lineItem {get;set;}
		public string sfStatus {get;set;}
		public wrapper_line(ws_Soa_OrderHistoryService.lineItem li, OrderStatusMap__c osm){
			lineItem=li;
			if (osm!=null) sfStatus = osm.SFDC_Order_Status__c;
		}
	}
	
}