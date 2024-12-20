public with sharing class CaseSecurityEnhanceController {
    /*
    @AuraEnabled(cacheable=true)
    public static DTO.EnhanceSecurityControllerResponse getCases(String tabName, String searchKey,Integer limitSize, Integer offset, String sortBy, string sortDirection){
        try {
            List<DTO.CaseWrapper> caseWrapperList = new List<DTO.CaseWrapper>();
            SecurityEnhanceHelper SecurityEnhanceObj = new SecurityEnhanceHelper();
            if(tabName == 'Cases'){
                System.debug('in Cases :');
                List<Security_Enhancement_Setting__mdt> metadataRecords = SecurityEnhanceObj.getMetadataRecords(tabName);
                System.debug('metadataRecords :'+metadataRecords);
                List<Case> casesList = new List<Case>(); 

                if(metadataRecords != NULL && !metadataRecords.isEmpty()){  
                    ResponseDTO response = SecurityEnhanceObj.createSOQLQuery(tabName,searchKey,limitSize,offset, metadataRecords,sortBy,sortDirection);
                    String soqlStr = string.valueOf(response.soqlQuery);
                    System.debug('soqlStr::'+ soqlStr);
                    casesList = Database.query(soqlStr);
                    System.debug('CaseList::'+ JSON.Serialize(casesList));
                }
                  
                // Map each Case record to the CaseWrapper
                if(casesList!=null && !casesList.isEmpty()){
                    for(Case caseRecord : casesList) {
                        caseWrapperList.add(new DTO.CaseWrapper(caseRecord));
                    }
                }   
                // Serialize the list to pass to LWC
                System.debug('CaseWrapperList::'+ JSON.Serialize(caseWrapperList));

                Integer totalCount = SecurityEnhanceObj.getTotalRecordCountQuery(tabName,searchKey, metadataRecords);
                System.debug('totalCount::'+totalCount);
                
                return new DTO.EnhanceSecurityControllerResponse(caseWrapperList,totalCount);
            }
            // If tabName is not 'Cases', return an error
           
            return new DTO.EnhanceSecurityControllerResponse('Invalid tab name provided: ' + tabName);
            
        } catch (Exception e) {
            System.debug('Error in getCases: ' + e.getMessage());
            throw new AuraHandledException('An error occurred while fetching cases: ' + e.getMessage());
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static DTO.EnhanceSecurityControllerResponse ValidateCaseAccess(Id caseId){
    	Id currentUserId = UserInfo.getUserId();
        //Criteria 1 : Check if user is System admin or not (System admin can view any account)
        Id profileId = UserInfo.getProfileId();
        String profileName = [Select Id,Name from Profile where Id=:ProfileId].Name;
        System.debug('profileName ==>' +profileName);
        if (profileName == 'System Administrator'){
           return new DTO.EnhanceSecurityControllerResponse(true);
        }
        // Criteria 2 : Check if account is present 
        List<Case> cases = [SELECT Id,Security_Enhancement__c,OwnerId,Owner.Type FROM Case WHERE Id = :caseId LIMIT 1];
        System.debug('cases ==>' + cases);
        if(cases.isEmpty()){
             return new DTO.EnhanceSecurityControllerResponse(false);
        }
        // Criteria 3 : Check if current user is owner of case
        if(cases[0].Owner.Type == 'Queue'){
            if(SecurityEnhanceHelper.checkUserIsPresentInQueue(currentUserId,cases[0].OwnerId)){
                return new DTO.EnhanceSecurityControllerResponse(true);
            } 
        } else if(cases[0].OwnerId == currentUserId){
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
        if (groupUserIds.contains(currentUserId) && cases[0].Security_Enhancement__c) {
            //return true;
             return new DTO.EnhanceSecurityControllerResponse(true);
        } else if(!groupUserIds.contains(currentUserId) && !cases[0].Security_Enhancement__c) {
             return new DTO.EnhanceSecurityControllerResponse(true);
        } 
       	return new DTO.EnhanceSecurityControllerResponse(false);
    }
    
    public static Map<Id, DTO.EnhanceSecurityControllerResponse> ValidateCasesAccess(List<Case> cases){
        Id currentUserId = UserInfo.getUserId();
        
        // Criteria 1: Check if the user is a System Administrator
        Id profileId = UserInfo.getProfileId();
        String profileName = [SELECT Name FROM Profile WHERE Id = :profileId].Name;
        
        // If the user is a System Administrator, return access for all accounts
        Set<Id> adminUserSet = new Set<Id>();
        Map<Id, DTO.EnhanceSecurityControllerResponse> adminAccessMap = new Map<Id, DTO.EnhanceSecurityControllerResponse>();           
        if (profileName == 'System Administrator') {           
            for (Case caseRecord : cases) {
                adminUserSet.add(caseRecord.Id);
                adminAccessMap.put(caseRecord.Id, new DTO.EnhanceSecurityControllerResponse(true));
            }
        }
        // check account Id if in Admin or not, remove from list
        Set<Id> caseIds = new Set<Id>();
        for(Case caseRecord : cases){
            if(!adminUserSet.contains(caseRecord.Id)){
                caseIds.add(caseRecord.Id);
            }
        }        
        
        if(caseIds.IsEmpty()){
            return adminAccessMap;
        }
        // Criteria 2: Retrieve account information for the provided account IDs
        List<Case> caseList = [SELECT Id, Security_Enhancement__c, OwnerId,Owner.Type FROM Case WHERE Id IN :caseIds];
        
        // Initialize map for account results
        Map<Id, DTO.EnhanceSecurityControllerResponse> mapCaseResult = new Map<Id, DTO.EnhanceSecurityControllerResponse>();
        // Retrieve the public group ID and its members if needed
        Id publicGroupId = [SELECT Id FROM Group WHERE DeveloperName = 'Security_Enhancement_User' AND Type = 'Regular' LIMIT 1].Id;
        Set<Id> groupUserIds = new Set<Id>();
        if (publicGroupId != null) {
            for (GroupMember gm : [SELECT UserOrGroupId FROM GroupMember WHERE GroupId = :publicGroupId]) {
                groupUserIds.add(gm.UserOrGroupId);
            }
        }
        
        // Criteria 3: Check ownership for each account
        for (Case caseRecord : caseList) {
            System.debug('Queue Type ==>' + caseRecord.Owner.Type);
            if(caseRecord.Owner.Type == 'Queue'){
                if(SecurityEnhanceHelper.checkUserIsPresentInQueue(currentUserId,caseRecord.OwnerId)){
                    mapCaseResult.put(caseRecord.Id, new DTO.EnhanceSecurityControllerResponse(true));
                } 
            } else if (caseRecord.OwnerId == currentUserId) {
                mapCaseResult.put(caseRecord.Id, new DTO.EnhanceSecurityControllerResponse(true));
            } else if (groupUserIds.contains(currentUserId) && caseRecord.Security_Enhancement__c) {
              
                mapCaseResult.put(caseRecord.Id, new DTO.EnhanceSecurityControllerResponse(true));
            } else if (!groupUserIds.contains(currentUserId) && !caseRecord.Security_Enhancement__c) {
                mapCaseResult.put(caseRecord.Id, new DTO.EnhanceSecurityControllerResponse(true));
            } else{
                mapCaseResult.put(caseRecord.Id, new DTO.EnhanceSecurityControllerResponse(false));
            }
        }
        // Return the final map of account results
        return mapCaseResult;
    }
	*/
}