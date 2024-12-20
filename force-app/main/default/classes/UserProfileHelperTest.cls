@isTest
public class UserProfileHelperTest {
    @isTest
    static void testGetCurrentUserProfileName() {
        // Step 1: Set up test data
        // Create a mock Profile
        Profile testProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];

        // Create a mock User
        User testUser = new User(
            Alias = 'tuser',
            Email = 'testuser1998@example.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'User',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = testProfile.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'testuser1998@example.com'
        );
        insert testUser;

        // Step 2: Run the method as the mock user
        System.runAs(testUser) {
            Test.startTest();
            String profileName = UserProfileHelper.getCurrentUserProfileName();
            Test.stopTest();

            // Step 3: Verify results
            System.assertEquals('Standard User', profileName, 'The profile name should match the mock user profile.');
        }
    }
}