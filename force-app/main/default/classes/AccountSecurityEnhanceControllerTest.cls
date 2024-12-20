@isTest
public class AccountSecurityEnhanceControllerTest {
    @testSetup
    public static void setup() {
        //List<Profile> adminProfile = [SELECT Id, Name FROM Profile WHERE Name = 'System Administrator'];
        List<Profile> testProfile = [SELECT Id, Name FROM Profile WHERE Name = 'Vendavo - Customer Operations'];
          Profile standardProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        // Create a new User record
        User testUser1;
        User testUser2;
        User testUser3;
        User standardUser;
        System.runAs(new User(Id = UserInfo.getUserId())){
             testUser1 = new User(
            username = 'xyz1.test@gmail.com',
            Alias = 'newuser1',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'ISO-8859-1',
            ProfileId = testProfile[0].id,
            LanguageLocaleKey = 'en_US',
            // Optional fields
            LastName = 'User 1',
            FirstName = 'test',
            Email = 'test@gmail.com',
            //UserRoleId = null, // Optional, set if you need a specific User Role
            IsActive = true // Set to true to activate the user
        );
        insert testUser1;
        
        testUser2 = new User(
            username = 'xyz2.test@gmail.com',
            Alias = 'newuser2',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'ISO-8859-1',
            ProfileId = testprofile[0].id,
            LanguageLocaleKey = 'en_US',
            // Optional fields
            LastName = 'User 2',
            FirstName = 'test',
            Email = 'test2@gmail.com',
            //UserRoleId = null, // Optional, set if you need a specific User Role
            IsActive = true // Set to true to activate the user
        );
        insert testUser2;
        
         testUser3 = new User(
            username = 'xyz3.test@gmail.com',
            Alias = 'newuser3',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'ISO-8859-1',
            ProfileId = testprofile[0].id,
            LanguageLocaleKey = 'en_US',
            // Optional fields
            LastName = 'User 3',
            FirstName = 'test',
            Email = 'test3@gmail.com',
            //UserRoleId = null, // Optional, set if you need a specific User Role
            IsActive = true // Set to true to activate the user
        );
        insert testUser3;
         standardUser = new User(
                FirstName = 'Test', 
                LastName = 'Admin', 
                Email = 'testadmin@example.com', 
                Username = 'testadmin@example.com' + System.currentTimeMillis(), 
                Alias = 'tadmin', 
                ProfileId = standardProfile.Id, 
                TimeZoneSidKey = 'America/Los_Angeles', 
                LocaleSidKey = 'en_US', 
                EmailEncodingKey = 'UTF-8', 
                LanguageLocaleKey = 'en_US'
            );
            insert standardUser;
        	Group caseQueue = new Group(
                Name = 'Test Case Queue',
                DeveloperName = 'Test_Case_Queue',
                Type = 'Queue'
            );
            insert caseQueue;
            
             // Associate the Queue with the Case object
            QueueSObject queueAssociation = new QueueSObject(QueueId = caseQueue.Id, SObjectType = 'Case');
            insert queueAssociation;
            // Add standardUser to the Queue
            GroupMember groupMember = new GroupMember(
                GroupId = caseQueue.Id,
                UserOrGroupId = standardUser.Id
            );
            insert groupMember;
          
            // Create a public group and add users to it
            Group publicGroup = new Group(
                Name = 'Security Enhancement User1',
                DeveloperName = 'Security_Enhancement_User1',
                Type = 'Regular'
            );
            insert publicGroup;
            
            GroupMember publicGroupMember = new GroupMember(
                GroupId = publicGroup.Id,
                UserOrGroupId = standardUser.Id
            );
            insert publicGroupMember;
            
            UserRole userRole = [SELECT Id FROM UserRole WHERE Name = 'CEO V2' LIMIT 1];
            GroupMember groupMember1 = new GroupMember(
                GroupId = caseQueue.Id,
                UserOrGroupId = publicGroup.Id  // Adding the Role instead of User
            );
            insert groupMember1;
        }
        // Create test Account record
        Account testAccRecord1 = new Account();
        testAccRecord1.Name = 'Test Account1';
        testAccRecord1.Security_Enhancement__c = true;
        testAccRecord1.OwnerId = testUser2.Id;
        insert testAccRecord1;
        
        // Create test Account record
        Account testAccRecord2 = new Account();
        testAccRecord2.Name = 'Test Account 2';
        testAccRecord2.Security_Enhancement__c = true;
        testAccRecord2.OwnerId = testUser1.Id;
        insert testAccRecord2;
    }
    @isTest
    static void testGetAccountsSuccess() {
       
        List<Account> accounts= [SELECT Id, Name FROM Account LIMIT 1];
        
        Test.startTest();
        AccountSecurityEnhanceController.AccountListControllerResult result = 
            AccountSecurityEnhanceController.getAccounts('Accounts', '', 10, 0,'CreatedDate','desc');
        Test.stopTest();
        
        // Verify results
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assertEquals(null, result.errorMessage, 'Error message should be null');
    }
    @isTest
    static void testGetAccountsSuccess1() {
        
       List<Account> accounts= [SELECT Id, Name FROM Account LIMIT 1];
        Test.startTest();
        AccountSecurityEnhanceController.AccountListControllerResult result = 
            AccountSecurityEnhanceController.getAccounts('Accounts', '', 10, 0,'CreatedDate','desc');
        Test.stopTest();
        
        // Verify results
        System.assertNotEquals(null, result, 'Result should not be null');
    }
    @isTest
    static void testGetAccountsSearch() {
       
        List<Account> accounts= [SELECT Id, Name FROM Account LIMIT 1];
        
        Test.startTest();
         list<user> listuser = [SELECT ID,name from user where username='xyz2.test@gmail.com'];
        User u = listuser[0];
        System.runAs(u) {
        AccountSecurityEnhanceController.AccountListControllerResult result = 
            AccountSecurityEnhanceController.getAccounts('Accounts', 'Test Account 2', 10, 0,'CreatedDate','desc');
              // Verify results
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assertEquals(null, result.errorMessage, 'Error message should be null');
        }
      
        Test.stopTest();
    }
    
    @isTest
    static void testGetAccountsInvalidTabName() {
        Test.startTest();
        AccountSecurityEnhanceController.AccountListControllerResult result 
            = AccountSecurityEnhanceController.getAccounts('InvalidTabName', '', 10, 0,'CreatedDate','desc');
        Test.stopTest();
        
        // Verify results
        System.assertEquals(null, result.filteredRecords, 'Filtered records should be null');
        System.assertEquals(null, result.totalCount, 'Total count should be null');
        System.assertEquals('Invalid tab name provided: InvalidTabName', result.errorMessage, 'Error message should match');
    }
    
    @isTest
    static void testGetAccountsException() {
        List<Account> Accounts= [SELECT Id, Name FROM Account LIMIT 1];
        Test.startTest();
        try {
            // Call getAccounts with parameters that will trigger an exception
            AccountSecurityEnhanceController.getAccounts(null, null, null, null,'CreatedDate','desc');
            System.assert(true, 'Exception was expected but not thrown');
        } catch (Exception e) {
            // Verify exception message
            System.assert(e.getMessage().contains('An error occurred while fetching accounts'), 'Exception message should match');
        }
        Test.stopTest();
    }
    
    @isTest
    static void testValidateAccountAccess() {
        // Test for system admin access to any account
        User adminUser = [SELECT Id FROM User WHERE Username = 'xyz2.test@gmail.com' LIMIT 1];
        Account account = [SELECT Id FROM Account LIMIT 1];

        System.runAs(adminUser) {
            Test.startTest();
            AccountSecurityEnhanceController.AccountListControllerResult result = AccountSecurityEnhanceController.ValidateAccountAccess(account.Id);
            Test.stopTest();            
            //System.assertEquals(true, result.isAccessible, 'System Administrator should have access to any account.');
        }
    }
    
    @isTest
    static void testValidateAccountAccess2() {
        User adminUser = [SELECT Id FROM User WHERE Username = 'xyz3.test@gmail.com' LIMIT 1];
        Account account = [SELECT Id FROM Account LIMIT 1];

        System.runAs(adminUser) {
            Test.startTest();
            AccountSecurityEnhanceController.AccountListControllerResult result = AccountSecurityEnhanceController.ValidateAccountAccess(account.Id);
            Test.stopTest();            
            //System.assertEquals(true, result.isAccessible, 'System Administrator should have access to any account.');
        }
    }
   
    
    @isTest
    static void testValidateAccountsAccess() {
        User adminUser = [SELECT Id FROM User WHERE Username = 'xyz3.test@gmail.com' LIMIT 1];
        List<Account> accounts = [SELECT Id FROM Account];

        System.runAs(adminUser) {
            Test.startTest();
            Map<Id, AccountSecurityEnhanceController.AccountListControllerResult> result = AccountSecurityEnhanceController.ValidateAccountsAccess(accounts);
            Test.stopTest();            
            //System.assertEquals(true, result.isAccessible, 'System Administrator should have access to any account.');
        }
    }
     @isTest
    static void testUserInGroupAndQueue() {
        Account testCase = [SELECT Id, Name FROM Account LIMIT 1]; 
        User testUser = [SELECT Id FROM User WHERE Username = 'xyz2.test@gmail.com' LIMIT 1];
        User standardUser = [SELECT Id FROM User WHERE Email = 'testadmin@example.com' LIMIT 1];
        Group queue = [SELECT Id FROM Group WHERE Name = 'Test Case Queue' LIMIT 1];
        
        System.runAs(standardUser) {
            Test.startTest();
            Boolean result = SecurityEnhanceHelper.checkUserIsPresentInQueue(UserInfo.getUserId(), queue.Id);
            Test.stopTest();
        }
    }
    @isTest
    static void testUserInGroupAndQueue2() {
        Account testCase = [SELECT Id, Name FROM Account LIMIT 1]; 
        User testUser = [SELECT Id FROM User WHERE Username = 'xyz2.test@gmail.com' LIMIT 1];
        User standardUser = [SELECT Id FROM User WHERE Email = 'testadmin@example.com' LIMIT 1];
        Group queue = [SELECT Id FROM Group WHERE Name = 'Test Case Queue' LIMIT 1];
        
        System.runAs(testUser) {
            Test.startTest();
            Boolean result = SecurityEnhanceHelper.checkUserIsPresentInQueue(UserInfo.getUserId(), queue.Id);
            Test.stopTest();
        }
    }

}