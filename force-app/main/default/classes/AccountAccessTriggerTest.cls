/**
* @File Name : AccountAccessTriggerTest.cls
* @Description : Test class for the AccountAccessTrigger apex class
* @Author :
* @Last Modified By :
* @Last Modified On : October 23, 2024
* @Modification Log :
*==============================================================================
* Ver | Date 				| Author 		| Modification
*==============================================================================
* 1.0 | October 23, 2024 	| Dreamwares  	| Initial Version
**/

@isTest
public class AccountAccessTriggerTest {
	
	@isTest
    public static void testAccountEnhanceSecurity() {
        List<Profile> testProfile = [SELECT Id, Name FROM Profile WHERE Name = 'Vendavo - Customer Operations'];
        Profile standardProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User testUser1;
        User testUser2;
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
        
       	DELETE testAccRecord2;
        
        List<Account> actList = [
            SELECT Id
        	FROM Account
        	WHERE Id = :testAccRecord2.Id
        ];
        
        Assert.areEqual(actList.isEmpty(), true);
    }
}