public with sharing class AccountSecurityEnhanceController {
    /*
    @AuraEnabled(cacheable=true)
    public static DTO.EnhanceSecurityControllerResponse getAccounts(String tabName, String searchKey,Integer limitSize, Integer offset, String sortBy, string sortDirection){
        try { 
            System.debug('sortBy in Case Controller::'+sortBy);
            System.debug('sortDirection in Case Controller::'+sortDirection);
                      
            SecurityEnhanceHelper SecurityEnhanceObj = new SecurityEnhanceHelper();
            List<DTO.AccountWrapper> accountWrapperList = new List<DTO.AccountWrapper>();
            if(tabName == 'Accounts'){
                List<Security_Enhancement_Setting__mdt> metadataRecords = SecurityEnhanceObj.getMetadataRecords(tabName);
                List<Account> accountsList = new List<Account>();    
                System.debug('metadataRecords::'+metadataRecords);
                if(metadataRecords != NULL && !metadataRecords.isEmpty()){                    
                    ResponseDTO response = SecurityEnhanceObj.createSOQLQuery(tabName,searchKey,limitSize,offset, metadataRecords, sortBy, sortDirection);                    
                    String soqlStr = string.valueOf(response.soqlQuery);                    
                    System.debug('ResponseDTO response::'+response);
                    System.debug('ResponseDTO soqlStr::'+soqlStr);
                    accountsList = Database.query(soqlStr);
                    System.debug('accountList::'+accountsList);
                }
                // Map each Case record to the CaseWrapper
                if(accountsList!=null && !accountsList.isEmpty()){
                    for(Account accountRecord : accountsList) {
                        accountWrapperList.add(new DTO.AccountWrapper(accountRecord));
                    }
                }   
                // Serialize the list to pass to LWC
                System.debug('accountWrapperList::'+ JSON.Serialize(accountWrapperList));

                Integer totalCount = SecurityEnhanceObj.getTotalRecordCountQuery(tabName,searchKey, metadataRecords);
                System.debug('totalCount acc::'+totalCount);
                return new DTO.EnhanceSecurityControllerResponse(accountWrapperList,totalCount);
            }
            return new DTO.EnhanceSecurityControllerResponse('Invalid tab name provided: ' + tabName); 
        } catch (Exception e) {
            System.debug('Error in getAccounts: ' + e.getMessage());
            throw new AuraHandledException('An error occurred while fetching accounts: ' + e.getMessage());
        }        
    }
    
    @AuraEnabled(cacheable=true)
    public static DTO.EnhanceSecurityControllerResponse ValidateAccountAccess(Id accountId){
    	Id currentUserId = UserInfo.getUserId();
         System.debug('currentUserId ==>' +currentUserId);
        //Criteria 1 : Check if user is System admin or not (System admin can view any account)
        Id profileId = UserInfo.getProfileId();
        String profileName = [Select Id,Name from Profile where Id=:ProfileId].Name;
        System.debug('profileName ==>' +profileName);
        if (profileName == 'System Administrator'){
           return new DTO.EnhanceSecurityControllerResponse(true);
        }
        // Criteria 2 : Check if account is present 
        List<Account> userAccounts = [SELECT Id,Security_Enhancement__c,OwnerId FROM Account WHERE Id = :accountId LIMIT 1];
         System.debug('userAccounts ==>' + userAccounts);
        if(userAccounts.isEmpty()){
             return new DTO.EnhanceSecurityControllerResponse(false);
        }
        // Criteria 3 : Check if current user is owner of account
        if(userAccounts[0].OwnerId == currentUserId){
           return new DTO.EnhanceSecurityControllerResponse(true);  
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
        // Criteria 4 : Check if current user is present in public group & Security_Enhancement is true
        if (groupUserIds.contains(currentUserId) && userAccounts[0].Security_Enhancement__c) {
             return new DTO.EnhanceSecurityControllerResponse(true);
        } 
        System.debug('ValidateAccountAccess ==>' + userAccounts[0].Security_Enhancement__c);
       	return new DTO.EnhanceSecurityControllerResponse(false);
    }
        
    public static Map<Id, DTO.EnhanceSecurityControllerResponse> ValidateAccountsAccess(List<Account> accounts){
        Id currentUserId = UserInfo.getUserId();
        System.debug('currentUserId ==>' +currentUserId);
        
        // Criteria 1: Check if the user is a System Administrator
        Id profileId = UserInfo.getProfileId();
        String profileName = [SELECT Name FROM Profile WHERE Id = :profileId].Name;
        System.debug('profileName ==>' + profileName);
        
        // If the user is a System Administrator, return access for all accounts
        Set<Id> adminUserSet = new Set<Id>();
        Map<Id, DTO.EnhanceSecurityControllerResponse> adminAccessMap = new Map<Id, DTO.EnhanceSecurityControllerResponse>();           
        if (profileName == 'System Administrator') {           
            for (Account account : accounts) {
                adminUserSet.add(account.Id);
                adminAccessMap.put(account.Id, new DTO.EnhanceSecurityControllerResponse(true));
            }
        }
        //Check account Id if in Admin or not, remove from list
        Set<Id> accIds = new Set<Id>();
        for(Account acc : accounts){
            if(!adminUserSet.contains(acc.Id)){
                accIds.add(acc.Id);
            }
        }        
        System.debug('accIds ==>' + accIds);
        if(accIds.IsEmpty()){
            return adminAccessMap;
        }
        // Criteria 2: Retrieve account information for the provided account IDs
        List<Account> userAccounts = [SELECT Id, Security_Enhancement__c, OwnerId FROM Account WHERE Id IN :accIds];
        System.debug('userAccounts ==>' + userAccounts);
        
        // Initialize map for account results
        Map<Id, DTO.EnhanceSecurityControllerResponse> mapAccountResult = new Map<Id, DTO.EnhanceSecurityControllerResponse>();
        // Retrieve the public group ID and its members if needed
        Id publicGroupId = [SELECT Id FROM Group WHERE DeveloperName = 'Security_Enhancement_User' AND Type = 'Regular' LIMIT 1].Id;
        Set<Id> groupUserIds = new Set<Id>();
        if (publicGroupId != null) {
            for (GroupMember gm : [SELECT UserOrGroupId FROM GroupMember WHERE GroupId = :publicGroupId]) {
                groupUserIds.add(gm.UserOrGroupId);
            }
        }
        System.debug('groupUserIds ==>' + groupUserIds);
        
        // Criteria 3: Check ownership for each account
        for (Account acc : userAccounts) {
            if (acc.OwnerId == currentUserId) {
                mapAccountResult.put(acc.Id, new DTO.EnhanceSecurityControllerResponse(true));
            } 
            else if (groupUserIds.contains(currentUserId) && acc.Security_Enhancement__c) {
                mapAccountResult.put(acc.Id, new DTO.EnhanceSecurityControllerResponse(true));
            }
            else{
                mapAccountResult.put(acc.Id, new DTO.EnhanceSecurityControllerResponse(false));
            }
        }
        // Return the final map of account results
        return mapAccountResult;
    }
	*/
}