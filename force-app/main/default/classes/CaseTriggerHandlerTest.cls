@isTest
public class CaseTriggerHandlerTest {
    @testSetup 
    public static void testData(){
        
        Account accountRecord = new Account();
        accountRecord.name = 'New Account';
        accountRecord.BillingCountry = 'United States';
        accountRecord.BillingState = 'CA';
        INSERT accountRecord;
        
        Set<String> daysOfWeek = new Set<String>{'Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'};
            
            List<Business_Hours__c> businessHoursList = new List<Business_Hours__c>();
        for(String dayOfWeek :daysOfWeek ){
            Business_Hours__c businessHours = new Business_Hours__c();
            businessHours.Account__c = accountRecord.Id;
            businessHours.Day__c = dayOfWeek;
            businessHours.Start_Time__c = Time.newInstance(8, 0, 0, 0);
            businessHours.End_Time__c = Time.newInstance(17, 0, 0, 0);
            businessHours.Time_Zone__c = 'CST';
            businessHoursList.add(businessHours);
        }
        if(!businessHoursList.isEmpty()){
            INSERT businessHoursList;
        }
        
        Holiday__c holiday = new Holiday__c();
        holiday.Account__c = accountRecord.Id;
        holiday.Date__c = System.today().addDays(-1);
        holiday.IsRecurrence__c = true;
        INSERT holiday;
       
        
        Case caseRec = new Case();
        caseRec.Origin='Email';
        caseRec.Status='New';
        caseRec.Type='Technical Support';
        caseRec.subject = 'test';
        caseRec.AccountId = accountRecord.Id;
        INSERT caseRec;
        
        Case_Status_Change_Tracker__c statusTracker = [SELECT Id,Case_Change_Start_Date__c FROM Case_Status_Change_Tracker__c LIMIT 1];
        statusTracker.Case_Change_Start_Date__c = statusTracker.Case_Change_Start_Date__c.addHours(-2);
        UPDATE statusTracker;
        
    }
    
    @isTest
    static void testAfterInsert() {
        List<Case> caseList = new List<Case>();
        Account accountRecord = [SELECT Id From Account LIMIT 1];
        
        for(Integer i=0; i<= 100; i++){
            Case caseRec = new Case();
            caseRec.Origin='Email';
            caseRec.Status='New'+i;
            caseRec.Type='Technical Support';
            caseRec.subject = 'test'+i;
            caseRec.AccountId = accountRecord.Id;
            caseList.add(caseRec);
        }
        
        
        Test.startTest();
        
        INSERT caseList;
        
        Test.stopTest();
    }
    
    
    @isTest
    static void testAfterUpdate() {
        List<Case> caseList = new List<Case>();
        
        for(Case caseRec:  [SELECT ID FROM Case]){
            caseRec.status= 'In Progress';
            caseList.add(caseRec);
        }
        
        Test.startTest();
        
        UPDATE caseList;
        
        Test.stopTest();
    }
    
}