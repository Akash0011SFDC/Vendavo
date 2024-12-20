@isTest
public class MonthlyCaseReportSchedulerTest {
    @testSetup
    public static void setupTestData() {
        // Create a test user with an exempt profile if available
      Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator' LIMIT 1];
      User testUser = new User(
          Alias = 'testuser',
          Email = 'testuser28@example.com',
          EmailEncodingKey = 'UTF-8',
          LastName = 'Testing',
          LanguageLocaleKey = 'en_US',
          LocaleSidKey = 'en_US',
          ProfileId = p.Id,
          TimeZoneSidKey = 'America/Los_Angeles',
          UserName = 'testuser28@example.com'
      );
      insert testUser;

      System.runAs(testUser) {
         // Setup test data
         Account account1 = new Account(Name = 'Test Account 1');
         Account account2 = new Account(Name = 'Test Account 2');
         insert account1;
         insert account2;

         Contact contactRec1 = new Contact(LastName='Test Contact 1', Email='test@contact1.com', AccountId=account1.Id);
         Contact contactRec2 = new Contact(LastName='Test Contact 2', Email='test@contact2.com', AccountId=account2.Id);
         insert new List<Contact>{contactRec1, contactRec2};

         // Create cases for account1 for two months ago and previous month
         List<Case> caseList = new List<Case>{
             new Case(AccountId = account1.Id, ContactId = contactRec1.Id, Status = 'New', 
                      Project__c= 'Vendavo internal customer', Product_Module__c= 'CPQ',
                      Subject='Test Comment', Description='Test Description', 
                      Resolution_Type__c = 'Login Request', CreatedDate = Date.today().addMonths(-2).addDays(1),
                      Support_Resolved_Date__c = System.today(), ClosedDate = System.today().addDays(1)),
             
             new Case(AccountId = account1.Id, ContactId = contactRec1.Id, Status = 'New', 
                      Project__c= 'Vendavo internal customer', Product_Module__c= 'CPQ',
                      Subject='Test Comment', Description='Test Description', 
                      Resolution_Type__c = 'Login Request', CreatedDate = Date.today().addMonths(-2).addDays(2),
                      Support_Resolved_Date__c = System.today(), ClosedDate = System.today().addDays(1)),
             
             new Case(AccountId = account1.Id, ContactId = contactRec1.Id, Status = 'New', 
                      Project__c= 'Vendavo internal customer', Product_Module__c= 'CPQ',
                      Subject='Test Comment', Description='Test Description', 
                      Resolution_Type__c = 'Login Request', CreatedDate = Date.today().addMonths(-1).addDays(1),
                      Support_Resolved_Date__c = System.today(), ClosedDate = System.today().addDays(1)),
                 
             new Case(AccountId = account1.Id, ContactId = contactRec1.Id, Status = 'New', 
                      Project__c= 'Vendavo internal customer', Product_Module__c= 'CPQ',
                      Subject='Test Comment', Description='Test Description', 
                      Resolution_Type__c = 'Login Request', CreatedDate = Date.today().addMonths(-1).addDays(1),
                      Support_Resolved_Date__c = System.today(), ClosedDate = System.today().addDays(1)),
                 
             new Case(AccountId = account1.Id, ContactId = contactRec1.Id, Status = 'New', 
                      Project__c= 'Vendavo internal customer', Product_Module__c= 'CPQ',
                      Subject='Test Comment', Description='Test Description', 
                      Resolution_Type__c = 'Login Request', CreatedDate = Date.today().addMonths(-1).addDays(1),
                      Support_Resolved_Date__c = System.today(), ClosedDate = System.today().addDays(1)),
             
             
             new Case(AccountId = account2.Id, ContactId = contactRec2.Id, Status = 'New', 
                      Project__c= 'Vendavo internal customer', Product_Module__c= 'CPQ',
                      Subject='Test Comment', Description='Test Description', 
                      Resolution_Type__c = 'Login Request', CreatedDate = Date.today().addMonths(-1).addDays(2),
                      Support_Resolved_Date__c = System.today(), ClosedDate = System.today().addDays(1)),
             
             new Case(AccountId = account2.Id, ContactId = contactRec2.Id, Status = 'New', 
                      Project__c= 'Vendavo internal customer', Product_Module__c= 'CPQ',
                      Subject='Test Comment', Description='Test Description', 
                      Resolution_Type__c = 'Login Request', CreatedDate = Date.today().addMonths(-1).addDays(3),
                      Support_Resolved_Date__c = System.today(), ClosedDate = System.today().addDays(1)),
                 
             new Case(AccountId = account2.Id, ContactId = contactRec2.Id, Status = 'New', 
                      Project__c= 'Vendavo internal customer', Product_Module__c= 'CPQ',
                      Subject='Test Comment', Description='Test Description', 
                      Resolution_Type__c = 'Login Request', CreatedDate = Date.today().addMonths(-2).addDays(3),
                      Support_Resolved_Date__c = System.today(), ClosedDate = System.today().addDays(1))
         };
         insert caseList;    
       }
  }
        
    @isTest
    public static void EmailSchedulerTest() {
        Test.startTest();
        String src = '0 0 0 * * ?';
        MonthlyCaseReportScheduler sc = new MonthlyCaseReportScheduler();
        String jobId = System.schedule('process scheduler', src, sc);
        Test.stopTest();
    }        
}