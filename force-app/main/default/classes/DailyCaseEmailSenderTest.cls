/**
* @description       : A class to send email notifications to users based on their specified time.
* @author            : 
* @group             : 
* @last modified on  : 24-10-2024 
* @last modified by  : 
**/ 
@isTest
public class DailyCaseEmailSenderTest {

    @testSetup
    static void setupTestData() {
     
        EmailTemplate template = new EmailTemplate(
            DeveloperName = 'User_Case_Detail_Email_Template',
            Name = 'User Case Detail Email Template',
            TemplateType = 'text',
            Subject = 'Test Email Subject',
            HtmlValue = '<p>This is a test email</p>',
            FolderId = UserInfo.getUserId()
        );
        insert template;
        // Step 3: Create a test User
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User testUser = new User(
            Alias = 'testuser',
            Email = 'testuser@example.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Test',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = p.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'testuser_' + System.currentTimeMillis() + '@example.com'
        );
        insert testUser;
    }

    @isTest
    static void testSendEmails() {
        EmailTemplate template = [SELECT Id From EmailTemplate LIMIT 1];
        User fetchRecord =[Select ID,Email from User WHERE Email = 'testuser@example.com'LIMIT 1];
        OrgWideEmailAddress emailAddress = [select id, Address from OrgWideEmailAddress where Address = 'vsupport@vendavo.com' LIMIT 1];
        Time emailSendTime = Time.newInstance(08, 30, 0, 0);
        Test.startTest();

        String cronExpression = '0 0 10 * * ?'; // Run at 10:00 AM daily
        System.schedule('Test DailyCaseEmailScheduler', cronExpression, new DailyCaseEmailScheduler());
        DailyCaseEmailSender.sendEmails();
        DailyCaseEmailSender.createEmailForUser(fetchRecord.Id, template.Id, emailAddress.Id);
        DailyOpenCasesEmailSender.sendEmails();
        DailyOpenCasesEmailSender.createEmailForUser(fetchRecord.Id, template.Id, emailAddress.Id, emailSendTime);
        Test.stopTest();

    }
    @isTest
    static void testSendEmailsat8AM() {
        EmailTemplate template = [SELECT Id From EmailTemplate LIMIT 1];
        User fetchRecord =[Select ID,Email from User WHERE Email = 'testuser@example.com'LIMIT 1];
        OrgWideEmailAddress emailAddress = [select id, Address from OrgWideEmailAddress where Address = 'vsupport@vendavo.com' LIMIT 1];
        Time emailSendTime = Time.newInstance(08, 00, 0, 0);
        Test.startTest();

        String cronExpression = '0 0 10 * * ?'; // Run at 10:00 AM daily
        System.schedule('Test DailyCaseEmailScheduler', cronExpression, new DailyCaseEmailScheduler());
        DailyCaseEmailSender.sendEmails();
        DailyCaseEmailSender.createEmailForUser(fetchRecord.Id, template.Id, emailAddress.Id);
        DailyOpenCasesEmailSender.sendEmails();
        DailyOpenCasesEmailSender.createEmailForUser(fetchRecord.Id, template.Id, emailAddress.Id, emailSendTime);
        Test.stopTest();

    }
    
    @isTest
    static void testSendEmailsat2PM() {
        EmailTemplate template = [SELECT Id From EmailTemplate LIMIT 1];
        User fetchRecord =[Select ID,Email from User WHERE Email = 'testuser@example.com'LIMIT 1];
        OrgWideEmailAddress emailAddress = [select id, Address from OrgWideEmailAddress where Address = 'vsupport@vendavo.com' LIMIT 1];
        Time emailSendTime = Time.newInstance(02, 00, 0, 0);
        Test.startTest();

        String cronExpression = '0 0 10 * * ?'; // Run at 10:00 AM daily
        System.schedule('Test DailyOpenCasesEmailScheduler', cronExpression, new DailyOpenCasesEmailScheduler());
        DailyCaseEmailSender.createEmailForUser(fetchRecord.Id, template.Id, emailAddress.Id);
        DailyOpenCasesEmailSender.sendEmails();
        DailyOpenCasesEmailSender.createEmailForUser(fetchRecord.Id, template.Id, emailAddress.Id, emailSendTime);
        Test.stopTest();

    }
}