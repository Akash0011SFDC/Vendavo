@isTest
public class MonthlyCaseMetricsBatchTest {
   @isTest
   static void testMonthlyCaseMetricsBatch() {
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

         // Execute the batch
         MonthlyCaseMetricsBatch batchJob = new MonthlyCaseMetricsBatch();
         Test.startTest();
         Database.executeBatch(batchJob);
         Test.stopTest();

          /*
         // Verify that the batch correctly calculated the case count for each month
         System.assertEquals(2, batchJob.twoMonthsAgoOpenCasesByAccount.get(account1.Id), 'Account 1 should have 2 cases from two months ago.');
         System.assertEquals(3, batchJob.previousMonthOpenCasesByAccount.get(account1.Id), 'Account 1 should have 3 cases from the previous month.');
         System.assertEquals(0, batchJob.twoMonthsAgoOpenCasesByAccount.get(account2.Id), 'Account 2 should have 0 cases from two months ago.');
         System.assertEquals(2, batchJob.previousMonthOpenCasesByAccount.get(account2.Id), 'Account 2 should have 2 cases from the previous month.');

         // Calculate and assert the expected percentage increase
         Decimal expectedIncreaseAccount1 = ((3 - 2) / 2.0) * 100; // Account 1: increase from 2 to 3 cases
         Decimal actualIncreaseAccount1 = batchJob.percentageIncreaseByAccount.get(account1.Id);
         System.assertEquals(expectedIncreaseAccount1, actualIncreaseAccount1, 'Account 1 should have the calculated percentage increase.');

         Decimal expectedIncreaseAccount2 = 100; // Account 2: increase from 0 to 2 cases (100% increase as there's no cases two months ago)
         Decimal actualIncreaseAccount2 = batchJob.percentageIncreaseByAccount.get(account2.Id);
         System.assertEquals(expectedIncreaseAccount2, actualIncreaseAccount2, 'Account 2 should have a 100% increase.');
*/
      }
   }
}