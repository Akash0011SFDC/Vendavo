/**
* @description       : A ApexTest class for EmailFromCustomerHandler Class.
* @author            : 
* @group             : 
* @last modified on  : 18-10-2024 
* @last modified by  : 
**/ 
@isTest
public class EmailFromCustomerHandlerTest {
    
    @testSetup
    public static void setup() {
        // Create test Account record
        Account accRecord = new Account();
        accRecord.Name = 'Test Account';
        accRecord.Site = 'Test Site';
        accRecord.Type = 'Competitor';
        accRecord.Industry = 'Agriculture & Forestry';
        insert accRecord;
        
        // Create test Contact record
        Contact conRecord = new Contact();
        conRecord.FirstName = 'Test';
        conRecord.LastName = 'Contact';
        conRecord.Email = 'test@gmail.com';
        conRecord.AccountId = accRecord.Id;
        insert conRecord;
        
        // Create test Case record
        Case testCase = new Case();
        testCase.Description = 'Testing';
        testCase.Origin = 'Web';
        testCase.Priority = 'P3 Medium';
        testCase.Subject = 'Testing';
        testCase.AccountId = accRecord.Id;
        testCase.ContactId = conRecord.Id;
        testCase.Project__c  ='3M - BT';
        insert testCase;
        
        List<Profile> testProfile = [SELECT Id, Name FROM Profile WHERE Name = 'System Administrator'];
        
        // Create a new User record
        User testUser = new User(
            username = 'xyz.test1998145@gmail.com',
            Alias = 'newuser',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'ISO-8859-1',
            ProfileId = testprofile[0].id,
            LanguageLocaleKey = 'en_US',
            // Optional fields
            LastName = 'User',
            FirstName = 'test',
            Email = 'test1998145@gmail.com',
            //UserRoleId = null, // Optional, set if you need a specific User Role
            IsActive = true // Set to true to activate the user
        );
        insert testUser;
        
        Group testGroup = new Group(Name='test group', Type='Queue');
        insert testGroup;
        
        System.runAs(new User(Id=UserInfo.getUserId()))
        {
            QueuesObject testQueue = new QueueSObject(QueueID = testGroup.id, SObjectType = 'Case');
            insert testQueue;
        }
        
        // Create DefaultCaseSettings__c record for testing default settings
        DefaultCaseSettings__c defaultSettings = new DefaultCaseSettings__c();
        defaultSettings.Default_Contact__c = conRecord.Id;
        defaultSettings.Default_Account__c = accRecord.Id;
        defaultSettings.Default_Email__c = 'default@example.com';
        defaultSettings.DefaultCaseSubject__c = 'testing';
        defaultSettings.Default_User__c = testUser.Id;
        defaultSettings.SupportTeamQueueId__c = testGroup.Id;
        insert defaultSettings;
    } 
    @isTest
    static void testHandleInboundEmailWithoutCaseNumber() {
        List<Case> caseList = [SELECT Id, CaseNumber FROM Case LIMIT 1];
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        email.plainTextBody = 'Hello, I have an issue with the product. Can you help?';
        String emailBody = email.plainTextBody;
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
        envelope.fromAddress = 'test@gmail.com';
        email.replyTo = 'test@gmail.com';
        email.toAddresses = new List<String>{'test12@gmail.com'};
            email.headers = (List<Messaging.InboundEmail.Header>) JSON.deserialize(
                '[{"value": "emailAdress","name": "X-SFDC-Original-RCPT"}, { "value": "OPP_REF", "name": "X-SFDC-EntityId" },{ "value": "' + caseList[0].ID + '", "name": "Case-Id" }]}',
                List<Messaging.InboundEmail.Header>.class
            );
        EmailFromCustomerHandler handler = new EmailFromCustomerHandler();
        Test.startTest();
        Messaging.InboundEmailResult result = handler.handleInboundEmail(email, new Messaging.InboundEnvelope());
        Test.stopTest();
        System.assert(result.success, 'The result should be successful.');
    }
    
    @isTest
    static void testHandleException() {
        List<Case> caseList = [SELECT Id, CaseNumber FROM Case LIMIT 1];
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        email.plainTextBody = 'Hello, I have an issue with the product. Can you help?';
        email.subject = 'Out of office';
        String emailBody = email.plainTextBody;
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
        envelope.fromAddress = 'test@gmail.com';
        email.replyTo = 'test@gmail.com';
        email.toAddresses = new List<String>{'test12@gmail.com'};
            EmailFromCustomerHandler handler = new EmailFromCustomerHandler();
        Test.startTest();
        Messaging.InboundEmailResult result = handler.handleInboundEmail(email, new Messaging.InboundEnvelope());
        Test.stopTest();
    }
    
    @isTest
    static void testHandleIgnoreOutofOfficeCaseCreation() {
        List<Case> caseList = [SELECT Id, CaseNumber FROM Case LIMIT 1];
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        email.plainTextBody = 'Hello, I have an issue with the product. Can you help?';
        String emailBody = email.plainTextBody;
        email.Subject = 'Out of Office';
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
        envelope.fromAddress = 'test@gmail.com';
        email.replyTo = 'test@gmail.com';
        email.toAddresses = new List<String>{'test12@gmail.com'};
            email.headers = (List<Messaging.InboundEmail.Header>) JSON.deserialize(
                '[{"value": "emailAdress","name": "X-SFDC-Original-RCPT"}, { "value": "OPP_REF", "name": "X-SFDC-EntityId" },{ "value": "' + caseList[0].ID + '", "name": "Case-Id" }]}',
                List<Messaging.InboundEmail.Header>.class
            );
        EmailFromCustomerHandler handler = new EmailFromCustomerHandler();
        Test.startTest();
        Messaging.InboundEmailResult result = handler.handleInboundEmail(email, new Messaging.InboundEnvelope());
        Test.stopTest();
        System.assert(result.success, 'The result should be successful.');
    }
    @isTest
    static void testHandleInboundEmailWithCaseNumber(){
        // Query a test case to use for the test
        List<Case> caseList = [SELECT Id, CaseNumber FROM Case LIMIT 1];
        // Create the inbound email with a text attachment
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        email.subject = 'Case ' + caseList[0].ID + ' - Issue with Product';
        email.replyTo = 'test@gmail.com';
        String formattedToken = EmailMessages.getFormattedThreadingToken( caseList[0].ID);
        email.plainTextBody = 'Hello, I have an issue with the product. Can you help?' +formattedToken;
        
        // Adding custom headers to the email
        email.headers = (List<Messaging.InboundEmail.Header>) JSON.deserialize(
            '[{"value": "emailAddress","name": "X-SFDC-Original-RCPT"}, { "value": "OPP_REF", "name": "X-SFDC-EntityId" },{ "value": "' + caseList[0].ID + '", "name": "Case-Id" }]',
            List<Messaging.InboundEmail.Header>.class
        );
        
        // Create text attachment
        Messaging.InboundEmail.TextAttachment textAttachment = new Messaging.InboundEmail.TextAttachment();
        textAttachment.fileName = 'testAttachment.txt';
        textAttachment.body = 'This is a test text attachment';
        email.textAttachments = new Messaging.InboundEmail.TextAttachment[] { textAttachment };
            
            Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
        envelope.fromAddress = 'test@gmail.com';
        
        EmailFromCustomerHandler handler = new EmailFromCustomerHandler();
        
        Test.StartTest();
        // Handle the inbound email
        Messaging.InboundEmailResult result = handler.handleInboundEmail(email, envelope);
        Test.StopTest();
        // Assert that the email processing succeeded
        System.assert(result.success, 'Email processing should succeed.');
    }    
    @isTest
    static void testHandleInboundEmailWithAttachments() {
      List<Case> caseList = [SELECT Id, CaseNumber FROM Case LIMIT 1];
        // Create the inbound email with a text attachment
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        email.subject = 'Case ' + caseList[0].ID + ' - Issue with Product';
        email.replyTo = 'test@gmail.com';
        String formattedToken = EmailMessages.getFormattedThreadingToken( caseList[0].ID);
        email.plainTextBody = 'Hello, I have an issue with the product. Can you help?' +formattedToken;
        
        // Adding custom headers to the email
        email.headers = (List<Messaging.InboundEmail.Header>) JSON.deserialize(
            '[{"value": "emailAddress","name": "X-SFDC-Original-RCPT"}, { "value": "OPP_REF", "name": "X-SFDC-EntityId" },{ "value": "' + caseList[0].ID + '", "name": "Case-Id" }]',
            List<Messaging.InboundEmail.Header>.class
        );
        
        // Create binary attachments
        Messaging.InboundEmail.BinaryAttachment binaryAttachment = new Messaging.InboundEmail.BinaryAttachment();
        binaryAttachment.fileName = 'testAttachment.pdf';
        binaryAttachment.body = Blob.valueOf('This is a test PDF attachment');
        email.binaryAttachments = new Messaging.InboundEmail.BinaryAttachment[] { binaryAttachment };
            
            Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
        envelope.fromAddress = 'customer@example.com';
        
        Test.startTest();
        EmailFromCustomerHandler handler = new EmailFromCustomerHandler();
        Messaging.InboundEmailResult result = handler.handleInboundEmail(email, envelope);
        Test.stopTest();
        System.assert(result.success, 'Email processing should succeed.');
    }
    @isTest
    static void testHandleCreateCaseElse(){
        // Query a test case to use for the test
        List<Case> caseList = [SELECT Id, CaseNumber FROM Case LIMIT 1];
        // Create the inbound email with a text attachment
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        email.subject = 'Case ' + caseList[0].ID + ' - Issue with Product';
        email.replyTo = 'test1405@gmail.com';
        email.toAddresses = new List<String>{'test12@gmail.com'};
        String formattedToken = EmailMessages.getFormattedThreadingToken( caseList[0].ID);
        email.plainTextBody = 'Hello, I have an issue with the product. Can you help?' +formattedToken;
        
        // Adding custom headers to the email
        email.headers = (List<Messaging.InboundEmail.Header>) JSON.deserialize(
            '[{"value": "emailAddress","name": "X-SFDC-Original-RCPT"}, { "value": "OPP_REF", "name": "X-SFDC-EntityId" },{ "value": "' + caseList[0].ID + '", "name": "Case-Id" }]',
            List<Messaging.InboundEmail.Header>.class
        );
              
            Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
        envelope.fromAddress = 'test@gmail.com';
        
        EmailFromCustomerHandler handler = new EmailFromCustomerHandler();
        
        Test.StartTest();
        // Handle the inbound email
        EmailFromCustomerHandler.CreateCaseFromEmail(email.replyTo, email.subject, email.plainTextBody, email);
        EmailFromCustomerHandler.sendCaseClosureEmail(email.replyTo, '747484');
        EmailFromCustomerHandler.caseCreationFromCloseCase(email.replyTo, email.subject, email.plainTextBody, email, caseList[0].ID, '454555');
        Group groupRecord = [SELECT Id, DeveloperName FROM Group WHERE Type = 'Queue' AND DeveloperName = 'Cloud_Ops_Queue'];
        
        CaseCommentNotificationHandler.fetchUsersfromQueueMethod(groupRecord.Id);
        Test.StopTest();
    }  
}