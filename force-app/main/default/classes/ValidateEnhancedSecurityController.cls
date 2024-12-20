public class ValidateEnhancedSecurityController {
    public class RecordValidationResult{
        @AuraEnabled public Boolean IsValid { get; set; }
        @AuraEnabled public String ObjectType { get; set; }
        public RecordValidationResult(Boolean isRecordValid,string objectType) {
            this.IsValid = isRecordValid;
            this.ObjectType = objectType;
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static RecordValidationResult ValidateRecordAccess(Id recordId){
        //Id sampleid = '0017z00000YeSjgAAF';
        //String sObjectType = recordId.getsobjecttype();
        String sObjectType = recordId.getSObjectType().getDescribe().getName();
		System.debug('object is '+ sObjectType);
    	Id currentUserId = UserInfo.getUserId();
         System.debug('currentUserId ==>' +currentUserId);
        //Criteria 1 : Check if user is System admin or not (System admin can view any account)
        Id profileId = UserInfo.getProfileId();
        String profileName = [Select Id,Name from Profile where Id=:ProfileId].Name;
        System.debug('profileName ==>' +profileName);
        if (profileName == 'System Administrator'){
           return new RecordValidationResult(true,sObjectType); 
           //return true;
        }
        
        //Check if user is present in public group or not
        Id publicGroupId = [SELECT Id FROM Group WHERE DeveloperName = 'Security_Enhancement_User' AND Type = 'Regular'].Id;
        Set<Id> groupUserIds = new Set<Id>();
        if (publicGroupId != null) {
            for (GroupMember gm : [SELECT UserOrGroupId FROM GroupMember WHERE GroupId = :publicGroupId]) {
                groupUserIds.add(gm.UserOrGroupId);
            }
        }
        System.debug('groupUserIds ==>' + groupUserIds);
        
        if(sObjectType == 'Account'){
            List<Account> userAccounts = [SELECT Id,Security_Enhancement__c,OwnerId FROM Account WHERE Id = :recordId LIMIT 1];
            System.debug('userAccounts ==>' + userAccounts);
            // Criteria 2 : Check if account is present 
            if(userAccounts.isEmpty()){
                return new RecordValidationResult(false,sObjectType);
            }
            // Criteria 3 : Check if current user is owner of account
            if(userAccounts[0].OwnerId == currentUserId){
                return new RecordValidationResult(true,sObjectType); 
            }
            // Criteria 4 : Check if current user is present in public group & Security_Enhancement is true
            if (groupUserIds.contains(currentUserId) && userAccounts[0].Security_Enhancement__c) {
                 return new RecordValidationResult(true,sObjectType);
            } 
        }
        //-------------------
        if(sObjectType == 'Case'){
			List<Case> cases = [SELECT Id,Security_Enhancement__c,OwnerId FROM Case WHERE Id = :recordId LIMIT 1];
            System.debug('cases ==>' + cases);
            // Criteria 2 : Check if account is present 
            if(cases.isEmpty()){
                return new RecordValidationResult(false,sObjectType);
            }
            // Criteria 3 : Check if current user is owner of case
            if(cases[0].OwnerId == currentUserId){
                return new RecordValidationResult(true,sObjectType); 
            }
            // Criteria 4 : Check if current user is present in public group & Security_Enhancement is true
            if (groupUserIds.contains(currentUserId) && cases[0].Security_Enhancement__c) {
                 return new RecordValidationResult(true,sObjectType);
            }             
        }
        
       	return new RecordValidationResult(false,sObjectType);
        
		// OR Related_User__c = :currentUserId,AND OwnerId = :currentUserId
    }
}