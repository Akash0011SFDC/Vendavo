public class UserProfileHelper {
    @AuraEnabled(cacheable=true)
    public static String getCurrentUserProfileName() {
        return [SELECT Profile.Name FROM User WHERE Id = :UserInfo.getUserId()].Profile.Name;
    }
}