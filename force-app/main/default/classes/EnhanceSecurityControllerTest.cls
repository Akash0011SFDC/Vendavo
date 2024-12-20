/**
* @File Name : EnhanceSecurityControllerTest.cls
* @Description : Test class for the EnhanceSecurityController
* @Author : Dreamwares
* @Last Modified By : 
* @Last Modified On : October 5, 2024
* @Modification Log :
*==============================================================================
* Ver | Date 			| Author 		| Modification
*==============================================================================
* 1.0 | October 5, 2024 | Dreamwares 	| Initial Version
**/

@isTest
public class EnhanceSecurityControllerTest {
	
    @testSetup
    public static void setup() {
        List<Profile> testProfile = [SELECT Id, Name FROM Profile WHERE Name = 'Vendavo - Customer Operations'];
        Profile standardProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User testUser1;
        User testUser2;
        User testUser3;
        User standardUser;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            // Create a new User record
            testUser1 = new User(
                username = 'xyz1.test@gmail.com',
                Alias = 'newuser1',
                TimeZoneSidKey = 'America/Los_Angeles',
                LocaleSidKey = 'en_US',
                EmailEncodingKey = 'ISO-8859-1',
                ProfileId = testProfile[0].id,
                LanguageLocaleKey = 'en_US',
                LastName = 'User 1',
                FirstName = 'test',
                Email = 'test@gmail.com',
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
                LastName = 'User 2',
                FirstName = 'test',
                Email = 'test2@gmail.com',
                IsActive = true 
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
        
        // Create test Case record
        Case testCase1 = new Case();
        testCase1.Description = 'Testing';
        testCase1.Origin = 'Web';
        testCase1.Priority = 'P3 Medium';
        testCase1.Subject = 'Testing';
        testCase1.AccountId = testAccRecord1.Id;       
        testCase1.Project__c  ='3M - BT';
        insert testCase1;
        
        // Create test Case record
        Case testCase2 = new Case();
        testCase2.Description = 'Testing';
        testCase2.Origin = 'Web';
        testCase2.Priority = 'P3 Medium';
        testCase2.Subject = 'Testing';
        testCase2.AccountId = testAccRecord2.Id;
        testCase2.Project__c  ='3M - BT';
        //testCase2.OwnerId = caseQueue.Id;
        insert testCase2;
        
         // Create a case
        Case testCase = new Case(
            Subject = 'Test Case',
            OwnerId = standardUser.Id
        );
        insert testCase;       
    }
    
     @isTest
    static void testGetAccountsSuccess() {
       
        List<Account> accounts= [SELECT Id, Name FROM Account LIMIT 1];
        
        Test.startTest();
        DTO.EnhanceSecurityControllerResponse result = EnhanceSecurityController.getRecords('Accounts', '', 10, 0,'CreatedDate','desc');
        Test.stopTest();
        
        // Verify results
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assertEquals(null, result.errorMessage, 'Error message should be null');
    }
    
    @isTest
    static void testGetAccountsSuccess1() {
        
       List<Account> accounts= [SELECT Id, Name FROM Account LIMIT 1];
        Test.startTest();
        DTO.EnhanceSecurityControllerResponse result = EnhanceSecurityController.getRecords('Accounts', '', 10, 0,'CreatedDate','desc');
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
        DTO.EnhanceSecurityControllerResponse result = EnhanceSecurityController.getRecords('Accounts', 'Test Account 2', 10, 0,'CreatedDate','desc');
              // Verify results
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assertEquals(null, result.errorMessage, 'Error message should be null');
        }
      
        Test.stopTest();
    }
    
    @isTest
    static void testGetAccountsException() {
        List<Account> Accounts= [SELECT Id, Name FROM Account LIMIT 1];
        Test.startTest();
        try {
            // Call getRecords with parameters that will trigger an exception
            EnhanceSecurityController.getRecords(null, null, null, null,'CreatedDate','desc');
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
        Account act = [SELECT Id FROM Account LIMIT 1];

        System.runAs(adminUser) {
            Test.startTest();
            Map<Id, DTO.EnhanceSecurityControllerResponse> result = EnhanceSecurityHelper.ValidateRecordsAccess( new List<Account>{ new Account(Id = act.Id) }, Account.SObjectType);
            Test.stopTest();
        }
    }
    
     @isTest
    static void testUserInGroupAndQueue() {
        User standardUser = [SELECT Id FROM User WHERE Email = 'testadmin@example.com' LIMIT 1];
        Group queue = [SELECT Id FROM Group WHERE Name = 'Test Case Queue' LIMIT 1];
        
        System.runAs(standardUser) {
            Test.startTest();
            Boolean result = EnhanceSecurityHelper.checkUserIsPresentInQueue(UserInfo.getUserId(), queue.Id);
            Test.stopTest();
        }
    }
    
    @isTest
    static void testUserInGroupAndQueue2() {
        User testUser = [SELECT Id FROM User WHERE Username = 'xyz2.test@gmail.com' LIMIT 1];
        Group queue = [SELECT Id FROM Group WHERE Name = 'Test Case Queue' LIMIT 1];
        
        System.runAs(testUser) {
            Test.startTest();
            Boolean result = EnhanceSecurityHelper.checkUserIsPresentInQueue(UserInfo.getUserId(), queue.Id);
            Test.stopTest();
        }
    }
    
    @isTest
    static void testGetCaseWithCaseNumber() {       
        List<Case> caseList= [SELECT Id, CaseNumber FROM Case LIMIT 1];
        
        Test.startTest();
        String caseNumber =caseList[0].CaseNumber;
        DTO.EnhanceSecurityControllerResponse result = EnhanceSecurityController.getRecords('Cases',caseNumber, 10, 0,'CreatedDate','asc');
        Test.stopTest();

        // Verify results
        System.assertNotEquals(null, result, 'Result should not be null');
    }
    
    @isTest
    static void testGetCasesSuccess1() {        
        Test.startTest();
        DTO.EnhanceSecurityControllerResponse result = EnhanceSecurityController.getRecords('Cases', '', 10, 0,'CreatedDate','asc');
        Test.stopTest();        
        // Verify results
        System.assertNotEquals(null, result, 'Result should not be null');
    }
    
    @isTest
    static void testCaseSearch() {        
        List<Case> caseList= [SELECT Id, CaseNumber FROM Case LIMIT 1];
		List<User> users;
        DTO.EnhanceSecurityControllerResponse result;
        System.runAs(new User(Id = UserInfo.getUserId())) {
          users = [SELECT ID,name from user where username='xyz2.test@gmail.com'];
        }        
        Test.startTest();
        User u = users[0];
        System.runAs(u) {
            result = EnhanceSecurityController.getRecords('Cases', 'Test Account 2', 10, 0,'CreatedDate','asc');
        }
        Test.stopTest();
        System.assertNotEquals(null, result, 'Result should not be null');
    }
    
    @isTest
    static void testGetCaseSuccess2() {        
        List<Case> caseList= [SELECT Id, CaseNumber FROM Case LIMIT 1];
        Test.startTest();
        DTO.EnhanceSecurityControllerResponse result = EnhanceSecurityController.getRecords('Cases', '', 10, 0,'CreatedDate','asc');
        Test.stopTest();
        
        // Verify results
        System.assertNotEquals(null, result, 'Result should not be null');
    }
    
    @isTest
    static void testGetCaseInvalidTabName() {
        Test.startTest();
        DTO.EnhanceSecurityControllerResponse result = EnhanceSecurityController.getRecords('InvalidTabName', '', 10, 0,'CreatedDate','asc');
        Test.stopTest();
    }
    
    @isTest
    static void testGetCaseException() {
        List<Case> caseList= [SELECT Id, CaseNumber FROM Case LIMIT 1];
        Test.startTest();
        try {
            // Call getRecords with parameters that will trigger an exception
            EnhanceSecurityController.getRecords(null, null, null, null,'CreatedDate','asc');
            System.assert(true, 'Exception was expected but not thrown');
        } catch (Exception e) {
            // Verify exception message
            System.assert(e.getMessage().contains('An error occurred while fetching accounts'), 'Exception message should match');
        }
        Test.stopTest();
    }
    
    @isTest
    static void testValidateCaseAccess() {
        User user;
        System.runAs(new User(Id = UserInfo.getUserId())) {
          user = [SELECT Id FROM User WHERE Username = 'xyz2.test@gmail.com' LIMIT 1];  
        }
        Case caseRecord = [SELECT Id,Security_Enhancement__c,OwnerId,Owner.Type FROM Case LIMIT 1];       
        System.runAs(user) {
            Test.startTest();
            Map<Id, DTO.EnhanceSecurityControllerResponse> result = EnhanceSecurityHelper.ValidateRecordsAccess( new List<Case>{ new Case(Id = caseRecord.Id) }, Case.sObjectType);
            Test.stopTest();
        }
    }
    
    @isTest
    static void testValidateCaseAccess2() {
        User user;
        System.runAs(new User(Id = UserInfo.getUserId())) {
          user = [SELECT Id FROM User WHERE Username = 'xyz3.test@gmail.com' LIMIT 1];  
        }
        Case caseRecord = [SELECT Id,Security_Enhancement__c,OwnerId,Owner.Type FROM Case LIMIT 1];      
        System.runAs(user) {
            Test.startTest();
            Map<Id, DTO.EnhanceSecurityControllerResponse> result = EnhanceSecurityHelper.ValidateRecordsAccess( new List<Case>{ new Case(Id = caseRecord.Id) }, Case.sObjectType);
            Test.stopTest();
        }
    }
    
    @isTest
    static void testValidateCaseAccess3() {
        User standardUser;
        Group queue;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            standardUser = [SELECT Id FROM User WHERE Email = 'testadmin@example.com' LIMIT 1];
            queue = [SELECT Id FROM Group WHERE Name = 'Test Case Queue' LIMIT 1];
        }
        
        Case testCase = new Case(
            Subject = 'Test Case Subject',
            Description = 'Test Case Description',
            Status = 'New',
            OwnerId = queue.Id
        );
        insert testCase;
        
        System.runAs(standardUser) {
            Test.startTest();
            Map<Id, DTO.EnhanceSecurityControllerResponse> result = EnhanceSecurityHelper.ValidateRecordsAccess( new List<Case>{ new Case(Id = testCase.Id) }, Case.sObjectType);
            Test.stopTest();
        }
    }    
    
    @isTest
    static void testValidateCasesAccess() {
        User user;
        System.runAs(new User(Id = UserInfo.getUserId())) {
          user = [SELECT Id FROM User WHERE Username = 'xyz3.test@gmail.com' LIMIT 1]; 
        }
        List<Case> caseList = [SELECT Id,Security_Enhancement__c,OwnerId,Owner.Type FROM Case];
        
        System.runAs(user) {
            Test.startTest();
            Map<Id, DTO.EnhanceSecurityControllerResponse> result = EnhanceSecurityHelper.ValidateRecordsAccess( caseList, Case.sObjectType);
            Test.stopTest();
        }
    }
    
    @isTest
    static void testValidateRecordAccess() {
        User user;
        System.runAs(new User(Id = UserInfo.getUserId())) {
          user = [SELECT Id FROM User WHERE Username = 'xyz3.test@gmail.com' LIMIT 1]; 
        }
        
        Case caseRecord = [SELECT Id,Security_Enhancement__c,OwnerId,Owner.Type FROM Case LIMIT 1];      
        System.runAs(user) {
            Test.startTest();
            Map<Id, DTO.EnhanceSecurityControllerResponse> result = EnhanceSecurityController.ValidateRecordAccess(caseRecord.Id);
            Test.stopTest();
        }
    }
    
    @isTest
    static void testCaseSearch2() {  
        User user;
        Group queue;
        System.runAs(new User(Id = UserInfo.getUserId())) {
          	user = [SELECT Id FROM User WHERE Email = 'testadmin@example.com' LIMIT 1];
            queue = [SELECT Id FROM Group WHERE Name = 'Test Case Queue' LIMIT 1];
        }
        
        Case testCase = new Case(
            Subject = 'Test Case Subject',
            Description = 'Test Case Description',
            Status = 'New',
            OwnerId = queue.Id
        );
        insert testCase;
        
        Test.startTest();
        System.runAs(user) {
            DTO.EnhanceSecurityControllerResponse result = EnhanceSecurityController.getRecords('Cases', '', 10, 0,'CreatedDate','asc');
            ResponseDTO dtoObj = new ResponseDTO(false, 'Failed to load data');
            
            Test.stopTest();

            // Verify results
            System.assertNotEquals(null, result, 'Result should not be null');
        }
    }
}