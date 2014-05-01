/********************************************************************************
 ********************************************************************************    
 *  Class            : AddressValidationBatchProcessSchedule
 *  Author           : Acumen Solutions: Latha Davuluri
 *  Version History  : 
 *  Creation         : 04/29/13
 *  Description      : Scheduler class to complete address validation on Addresses whose Pending_Avalara_Response__c=true.
 *                      
 ********************************************************************************
 ********************************************************************************/

global class AddressValidationBatchProcessSchedule implements Schedulable{

    global void execute(SchedulableContext sc)
    {
        AddressValidationBatchProcess avp = new AddressValidationBatchProcess();
        ID myBatchJobID = database.executebatch(avp,10);
    }

    public static testMethod void AddressValidationBatchProcessScheduleTest()
    {
        Test.startTest();
        AddressValidationBatchProcessSchedule s8 = new AddressValidationBatchProcessSchedule();
        string sch = '0 0 * * 1-12 ? *';
        system.schedule('Address Validation Batch Job', sch, s8);
        Test.stopTest();
    }

    public static testMethod void AddressValidationBatchProcessTest()
    {
        Test.startTest();
        AddressValidationBatchProcess avp = new AddressValidationBatchProcess();
        ID myBatchJobID = database.executebatch(avp,5);
        Test.stopTest();
             
       Integer i = [SELECT COUNT() FROM Address__c Where Pending_Avalara_Response__c=true];
       System.assertEquals(i, 0);
    }
}