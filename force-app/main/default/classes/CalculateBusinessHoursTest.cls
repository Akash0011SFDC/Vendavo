@isTest
public class CalculateBusinessHoursTest {
	@testSetup 
    public static void testData(){        
        Account accountRecord = new Account();
        accountRecord.name = 'Test Account';
        INSERT accountRecord;
        
        Set<String> daysOfWeek = new Set<String>{'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'};
            
        List<Business_Hours__c> businessHoursList = new List<Business_Hours__c>();
        for(String dayOfWeek :daysOfWeek ){
            Business_Hours__c businessHours = new Business_Hours__c();
            businessHours.Account__c = accountRecord.Id;
            businessHours.Day__c = dayOfWeek;
            businessHours.Start_Time__c = Time.newInstance(1, 45, 0, 0);
            businessHours.End_Time__c = Time.newInstance(2, 15, 0, 0);
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
        caseRec.Origin='Web';
        caseRec.Status='New';
        caseRec.Type = 'Incident';
        caseRec.Type='Support Case';
        caseRec.subject = 'test';
        caseRec.Description = 'test';
        caseRec.Product_Module__c = 'CPQ';
        caseRec.AccountId = accountRecord.Id;        
        INSERT caseRec;        
    }
    
    @isTest
    static void testUpdateInitialAssignmentTime() {
        Account testAccount = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1];
        Case testCase = [SELECT Id FROM Case WHERE AccountId = :testAccount.Id LIMIT 1];

        CalculateBusinessHours.FlowInput input = new CalculateBusinessHours.FlowInput();
        input.accountId = testAccount.Id;
        input.caseId = testCase.Id;
        input.startDateTime = DateTime.newInstance(Date.today().toStartOfMonth(), Time.newInstance(9, 0, 0, 0));
        input.endDateTime = DateTime.newInstance(Date.today().toStartOfMonth(), Time.newInstance(10, 0, 0, 0));
        input.flowName = 'Update Initial Assignment Time Flow';

        List<CalculateBusinessHours.FlowInput> inputs = new List<CalculateBusinessHours.FlowInput>{ input };

        Test.startTest();
        CalculateBusinessHours.updateInitialAssignmentTime(inputs);
        Test.stopTest();

        Case updatedCase = [SELECT Initial_Assignment_Time_in_Minutes__c FROM Case WHERE Id = :testCase.Id];
        System.assert(updatedCase.Initial_Assignment_Time_in_Minutes__c >= 0, 'Initial Assignment Time should be updated.');
        
        updatedCase.Initial_Assignment_Time__c = null;
        update updatedCase;
        
        System.assert(updatedCase.Initial_Assignment_Time_in_Minutes__c >= 0, 'After case update Initial Assignment Time should be updated.');
    }

    @isTest
    static void testUpdateInitialResponseTime() {
        Account testAccount = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1];
        Case testCase = [SELECT Id FROM Case WHERE AccountId = :testAccount.Id LIMIT 1];

        CalculateBusinessHours.FlowInput input = new CalculateBusinessHours.FlowInput();
        input.accountId = testAccount.Id;
        input.caseId = testCase.Id;
        input.startDateTime = DateTime.newInstance(Date.today().toStartOfMonth(), Time.newInstance(9, 0, 0, 0));
        input.endDateTime = DateTime.newInstance(Date.today().toStartOfMonth(), Time.newInstance(10, 0, 0, 0));
        input.flowName = 'Update Initial Response Time Flow';

        List<CalculateBusinessHours.FlowInput> inputs = new List<CalculateBusinessHours.FlowInput>{ input };

        Test.startTest();
        CalculateBusinessHours.updateInitialAssignmentTime(inputs);
        Test.stopTest();

        Case updatedCase = [SELECT Initial_Response_Time_in_Minutes__c FROM Case WHERE Id = :testCase.Id];
        System.assert(updatedCase.Initial_Response_Time_in_Minutes__c >= 0, 'Initial Response Time should be updated.');
    }
}