/*
	OrderAdjustmentsScheduler 
	DESCRIPTION
	Scheduling Order Adjusustment batch job.
	------------------------------------------------------------------
	Author			|		Date		|	Description
	------------------------------------------------------------------
	Pavan Jasthi	|	2/28/2014		|	Created

*/

global class OrderAdjustmentsScheduler implements Schedulable {
	public Boolean nightly;
	
	public OrderAdjustmentsScheduler(Boolean isNightlyError){
		if (!isNightlyError) {
			nightly = false;
		} else {
			nightly = true;
		}
	}
	
	global void execute(SchedulableContext sc){
		if (BatchJobHelper.canThisBatchRunForClass('OrderAdjustmentstBatch')) {
			if (nightly) {
				OrderAdjustmentstBatch odj = new OrderAdjustmentstBatch(true);
				id dbid = database.executeBatch(odj,1);
			} else {
				OrderAdjustmentstBatch odj = new OrderAdjustmentstBatch(false);
				id dbid = database.executeBatch(odj,1);
			}
		}
	}
	
	//Setup the scheduled jobs by entering "OrderAdjustmentsScheduler.setupNightlyErrorSchedule();"
	//in the system log window 
	public static void setupNightlyErrorSchedule(){
		String sch = '0 0 6 * * ?';
		System.debug('sch==>' + sch);
		OrderAdjustmentsScheduler s = new OrderAdjustmentsScheduler(true);
		if (!Test.isRunningTest()) {
			System.schedule('Order Adjustment Batch: Order Not In As400',sch,s);
		}
	}
	
	//Seconds Minutes Hours Day_of_month Month Day_of_week optional_year
	public static void setupSchedule() {
		String sch = '';
		List<Order_Adjustment_Batch_Settings__c> oasList = Order_Adjustment_Batch_Settings__c.getAll().values();
		for (Order_Adjustment_Batch_Settings__c oas : oasList) {
			if (oas.IsActive__c && oas.Start_time__c != null && oas.End_Time__c != null) {
				string startMtime = OrderUtilities.standardToMiltaryTime(oas.Start_time__c) ;
				string endMtime =  OrderUtilities.standardToMiltaryTime(oas.End_Time__c) ;
				string dayOfWeek = oas.On_Weekends__c ? 'SAT-SUN' : 'MON-FRI' ;
				sch = '0 '+ '0 '+ startMtime +'-'+ endMtime + ' ? * '+ dayOfWeek;
				system.debug('@@@@ sch'+ sch);
				OrderAdjustmentsScheduler s = new OrderAdjustmentsScheduler(false);
				if (!Test.isRunningTest()) {
					System.schedule('Order Adjustment Batch run',sch,s);
				}
			}
		}
	}
}
	/*
	public static void setupWeekdaysSchedule(){
		String sch = '';
		List<Order_Adjustment_Batch_Settings__c> oasList = Order_Adjustment_Batch_Settings__c.getAll().values();
		for(Order_Adjustment_Batch_Settings__c oas : oasList){
			if(oas.IsActive__c)
			if(oas.On_Weekdays__c && oas.Start_time__c <> null && oas.End_Time__c <> null) {
				sch = '0 '+ '0 '+ oas.Start_time__c +'-'+ oas.End_Time__c + ' * * MON-FRI';
				return;
			}
		}
		
		System.debug('sch==>' + sch);
		OrderAdjustmentsScheduler s = new OrderAdjustmentsScheduler();
		System.schedule('Order Adjustment Batch run',sch,s);
		
	}
	
	//Seconds Minutes Hours Day_of_month Month Day_of_week optional_year
	public static void setupWeekEndsSchedule(){
		String sch = '';
		List<Order_Adjustment_Batch_Settings__c> oasList = Order_Adjustment_Batch_Settings__c.getAll().values();
		for(Order_Adjustment_Batch_Settings__c oas : oasList){
			if(oas.On_Weekends__c && oas.Start_time__c <> null && oas.End_Time__c <> null) {
				sch = '0 '+ '0 '+ oas.Start_time__c +'-'+ oas.End_Time__c + ' * * SAT-SUN';
				return;
			}
		}
		
		System.debug('sch==>' + sch);
		OrderAdjustmentsScheduler s = new OrderAdjustmentsScheduler();
		System.schedule('Order Adjustment Batch run',sch,s);
		
	}
	*/