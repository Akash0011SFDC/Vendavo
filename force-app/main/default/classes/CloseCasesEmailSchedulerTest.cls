@isTest
public class CloseCasesEmailSchedulerTest {
    @testSetup
    public static void setupTestData() {
        List<Account> accounts = new List<Account>();
        List<Contact> contacts = new List<Contact>();
        List<Case> cases = new List<Case>();
        
        for (Integer i = 0; i < 20; i++) {
            Account acRecord = new Account(
                Name = 'Test Account ' + i,
                Site = 'Test Site ' + i,
                Type = 'Prospect',
                Industry = 'Agriculture & Forestry'
            );
            accounts.add(acRecord);
        }
        insert accounts;
        
        for (Integer i = 0; i < 20; i++) {
            Contact conRecord = new Contact(
                FirstName = 'Testing',
                LastName = 'Demo ' + i,
                AccountId = accounts[i].Id
            );
            contacts.add(conRecord);
        }
        insert contacts;

        for (Integer i = 0; i < 20; i++) {
            Case csRecord = new Case(
                AccountId = accounts[i].Id,
                ContactId = contacts[i].Id,
                Project__c = 'Airbus',
                Type = 'Incident',
                Origin = 'Web',
                Status = 'New',
                Priority = 'P3 Medium',
                Subject = 'Test Case ' + i,
                Description = 'Test',
                Business_Impact__c = 'Test',
                Product_Module__c = 'CPQ'
            );
            cases.add(csRecord);
        }
        insert cases;
    }

    @isTest
    public static void EmailSchedulerTest() {
        List<Case> caseList = [SELECT Id, AccountId FROM Case LIMIT 20];
        for (Case caseRecord : caseList) {
            caseRecord.Status = 'Closed';
            caseRecord.Sub_Status__c = 'Closed - No Response';
            caseRecord.Support_Resolved_Date__c = DateTime.now();
            caseRecord.simplesurvey__Survey_Sent__c = DateTime.now();
            caseRecord.Resolution_Type__c = 'Login Request';
        }
        update caseList;

        Test.startTest();
        String src = '0 0 0 * * ?';
        CloseCasesEmailScheduler sc = new CloseCasesEmailScheduler();
        String jobId = System.schedule('process scheduler', src, sc);
        Test.stopTest();

        List<Case> caseRecords = [SELECT Id, AccountId, ContactId, Project__c, Status, Sub_Status__c FROM Case WHERE Status = 'Closed' AND Sub_Status__c = 'Closed - No Response'];
        System.assertEquals(20, caseRecords.size());
    }
}