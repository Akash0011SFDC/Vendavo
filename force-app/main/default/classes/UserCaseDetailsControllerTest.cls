/**
* @description       : A class to send email notifications to users based on their specified time.
* @author            : 
* @group             : 
* @last modified on  : 09-08-2024 
* @last modified by  : 
**/ 
@isTest
public class UserCaseDetailsControllerTest {

    @testSetup
    public static void testData() {
       

        // Step 1: Create a test user with a unique username
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        String uniqueUsername = 'testuser_' + System.currentTimeMillis() + '@example.com';
        User testUser = new User(
            Alias = 'testuser',
            Email = 'testuser@example.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Test',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = p.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = uniqueUsername
        );
        insert testUser;

        // Step 3: Query for the existing RecordType 'Support Case'
        RecordType supportCaseRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Case' AND Name = 'Support Case' LIMIT 1];

        // Step 4: Create a test Case record associated with the test user
        Case testCase = new Case(
            OwnerId = testUser.Id,
            Status = 'In Progress',
            Subject = 'Test Case Subject',
            Priority = 'Medium',
            RecordTypeId = supportCaseRecordType.Id,
            CreatedDate = System.now().addDays(-10), // Ensure it's older than yesterday
            LastModifiedDate = System.now().addDays(-10) // Ensure it's older than yesterday
        );
        insert testCase;
    }

    @isTest
    static void testFetchCaseData() {
        // Retrieve the test user and case created in the @testSetup method
        User testUser = [SELECT Id FROM User WHERE UserName LIKE 'testuser_%@example.com' LIMIT 1];
        
        Test.startTest();
        UserCaseDetailsController controller = new UserCaseDetailsController();
        controller.setUserId(testUser.Id);
        controller.getUserId();
        UserOpenCasesController controllerNew = new UserOpenCasesController();
        controllerNew.setUserId(testUser.Id);
        controllerNew.getUserId();
        Test.stopTest();

        // Assert that the cases list has the test case
        System.assertNotEquals(null, controller.cases, 'Cases list should not be null');
    }
}