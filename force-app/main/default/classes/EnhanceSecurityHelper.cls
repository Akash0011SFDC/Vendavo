/**
* @File Name : EnhanceSecurityController.cls
* @Description : Controller for the Securty Enahance LWC components
* @Author : Dreamwares
* @Last Modified By : Dreamwares
* @Last Modified On : October 4, 2024
* @Modification Log :
*==============================================================================
* Ver | Date 			| Author 		| Modification
*==============================================================================
* 1.0 | October 4, 2024 | Dreamwares  	| Initial Version
* 1.1 | November 14,2024| Dreamwares	| Modified Case Visibility Logic
**/
public with sharing class EnhanceSecurityHelper {
    
    // Get the Metadata Records
    public static List<Security_Enhancement_Setting__mdt> getMetadataRecords(String tabName){
        return [
            SELECT Id, Field_API_Name__c, Object_API_Name__c, Tab_Name__c
            FROM Security_Enhancement_Setting__mdt 
            WHERE Tab_Name__c =: tabName
        ];
    }
    
    // Creatd the Dynamic Soql Query using custom Metadata
    public static ResponseDTO createSOQLQuery( String tabName, String searchKey,Integer limitSize, Integer offset, List<Security_Enhancement_Setting__mdt> metadataRecords, String sortBy, string sortDirection ) {
        
        String SOQLStr = 'SELECT ' ;
        String objectName;
        for (Security_Enhancement_Setting__mdt record : metadataRecords) {
            
            if(String.isNotBlank(record.Field_API_Name__c) ){
                SOQLStr += record.Field_API_Name__c;
            }
            
            objectName = record.Object_API_Name__c;
        }
        
        SOQLStr = SOQLStr.removeEnd(', ');
        SOQLStr += ' FROM '+objectName;
        
        Set<Id> groupUserIds = getGroupUserIds();
        String userId = UserInfo.getUserId();
        
        Id profileId = UserInfo.getProfileId();
        
        String profileName = [SELECT Id,Name  FROM Profile WHERE Id=:ProfileId].Name;
        System.debug('profileName:'+profileName);
        
        // Logic based on the profile and searchKey
        if (profileName == 'System Administrator') {
            if (String.isEmpty(searchKey)) {
                SOQLStr +=  ' ORDER By '+ sortBy + ' ' + sortDirection + ' LIMIT ' + limitSize + ' OFFSET ' + offset;
            } else {
                searchKey = '\'' + '%' + searchKey + '%' + '\'';
                if (tabName =='Accounts'){
                    SOQLStr += ' WHERE (Name LIKE ' + searchKey + ' OR Type LIKE '+ searchKey + ' OR Phone LIKE '+ searchKey + ' OR Site LIKE '+ searchKey +')';
                }else if(tabName =='Cases'){
                    SOQLStr += ' WHERE (CaseNumber LIKE ' + searchKey + ' OR Account.Name LIKE '+ searchKey + ' OR Origin LIKE '+ searchKey + ' OR Subject LIKE '+ searchKey  + ' OR Status LIKE '+ searchKey + ' OR Priority LIKE '+ searchKey +')';
                }
                SOQLStr +=  ' ORDER By '+ sortBy + ' ' + sortDirection + ' LIMIT ' + limitSize + ' OFFSET ' + offset;
            }
        } else {
            //Check user is present in any Queue
            if(objectName == 'Case' && !getQueuesInWhichUserPresent(userId).isEmpty()){
                List<String> formattedIds = new List<String>();
                
                for (Id queueId : getQueuesInWhichUserPresent(userId)) {
                    formattedIds.add('\'' + queueId + '\'');
                }
                String queueIdsStr = String.join(formattedIds, ','); 
                
                if (groupUserIds.contains(userId)) {
                    //SOQLStr += ' WHERE (Security_Enhancement__c = true OR OwnerId = \'' + userId + '\' OR OwnerId IN (' + queueIdsStr + '))';
                    //Added on 14-11-2024, secured user can able to view both secured & non secured cases
                    //added condition [OR Security_Enhancement__c = false]
					SOQLStr += ' WHERE (Security_Enhancement__c = true OR Security_Enhancement__c = false OR OwnerId = \'' + userId + '\' OR OwnerId IN (' + queueIdsStr + '))';
                } 
                else {
                    SOQLStr += ' WHERE (Security_Enhancement__c = false OR OwnerId = \'' + userId + '\' OR OwnerId IN (' + queueIdsStr + '))';
                }  
            } else {                    
                if (groupUserIds.contains(userId)) {
                    SOQLStr += ' WHERE (Security_Enhancement__c = true OR Security_Enhancement__c = false OR OwnerId = \'' + userId + '\')';
                } else {
                    //SOQLStr += ' WHERE (Security_Enhancement__c = FALSE OR OwnerId = \'' + userId + '\')';
                    //Added on 7-Nov-2011 : because User who is not owner or any group member, 
                    //he was able to see all security enhance = false cases
                    SOQLStr += ' WHERE (Security_Enhancement__c = false OR OwnerId = \'' + userId + '\')';
                }
            }   
            
            // Add search criteria if searchKey is provided
            if (!String.isEmpty(searchKey)) {
                searchKey = '\'' + '%' + searchKey + '%' + '\'';
                if (tabName =='Accounts'){
                    SOQLStr += ' AND (Name LIKE ' + searchKey + ' OR Type LIKE '+ searchKey + ' OR Phone LIKE '+ searchKey + ' OR Site LIKE '+ searchKey +')';
                }else if(tabName =='Cases'){
                    SOQLStr += ' AND (CaseNumber LIKE ' + searchKey + ' OR Account.Name LIKE '+ searchKey + ' OR Origin LIKE '+ searchKey + ' OR Subject LIKE '+ searchKey  + ' OR Status LIKE '+ searchKey +')';
                }
            }
            
            SOQLStr +=  ' ORDER By '+ sortBy + ' ' + sortDirection + ' LIMIT ' + limitSize + ' OFFSET ' + offset; 
        }
        System.debug('SOQLStr :'+SOQLStr);
        return new ResponseDTO(true, 'SOQL query created successfully', SOQLStr, null);
    }
    
    // Creatd the Dynamic Soql Query using custom Metadata
    public static Integer  getTotalRecordCountQuery( String tabName, String searchKey, List<Security_Enhancement_Setting__mdt> metadataRecords ) {        
        Integer totalCount = 0;
        String SOQLStr = 'SELECT COUNT() ' ;
        String objectName;
        
        for (Security_Enhancement_Setting__mdt record : metadataRecords) {
            objectName = record.Object_API_Name__c;
        }
        
        SOQLStr += ' FROM '+objectName;
        
        Set<Id> groupUserIds = getGroupUserIds();
        String userId = UserInfo.getUserId();
        Id profileId = UserInfo.getProfileId();
        String profileName = [Select Id,Name from Profile where Id=:ProfileId].Name;
        
        if (profileName == 'System Administrator') {                
            searchKey = '\'' + '%' + searchKey + '%' + '\'';
            if (tabName =='Accounts'){
                SOQLStr += ' WHERE (Name LIKE ' + searchKey + ' OR Type LIKE '+ searchKey + ' OR Phone LIKE '+ searchKey + ' OR Site LIKE '+ searchKey +')';
            }else if(tabName =='Cases'){
                SOQLStr += ' WHERE (CaseNumber LIKE ' + searchKey + ' OR Account.Name LIKE '+ searchKey + ' OR Origin LIKE '+ searchKey + ' OR Subject LIKE '+ searchKey  + ' OR Status LIKE '+ searchKey + ' OR Priority LIKE '+ searchKey +')';
            }
        } else {
            //Check user is present in any Queue || Test.isRunningTest()
            if(objectName == 'Case' && !getQueuesInWhichUserPresent(userId).isEmpty()){
                
                List<String> formattedIds = new List<String>();
                
                for (Id queueId : getQueuesInWhichUserPresent(userId)) {
                    formattedIds.add('\'' + queueId + '\'');
                }
                String queueIdsStr = String.join(formattedIds, ','); 
                
                if (groupUserIds.contains(userId)) {
                    //SOQLStr += ' WHERE (Security_Enhancement__c = true OR OwnerId = \'' + userId + '\' OR OwnerId IN (' + queueIdsStr + '))';
                    //Added on 14-11-2024, secured user can able to view both secured & non secured cases
                    //added condition [OR Security_Enhancement__c = false]
                    SOQLStr += ' WHERE (Security_Enhancement__c = true OR Security_Enhancement__c = false OR OwnerId = \'' + userId + '\' OR OwnerId IN (' + queueIdsStr + '))';
                } 
                else {
                    SOQLStr += ' WHERE (Security_Enhancement__c = false OR OwnerId = \'' + userId + '\' OR OwnerId IN (' + queueIdsStr + '))';
                }  
            } else {                    
                if (groupUserIds.contains(userId)) {
                    //SOQLStr += ' WHERE (Security_Enhancement__c = true OR OwnerId = \'' + userId + '\')';
                    //Added on 14-11-2024, secured user can able to view both secured & non secured cases
                    //added condition [OR Security_Enhancement__c = false]
                    SOQLStr += ' WHERE (Security_Enhancement__c = true OR Security_Enhancement__c = false OR OwnerId = \'' + userId + '\')';
                } else {
                    //SOQLStr += ' WHERE (Security_Enhancement__c = FALSE OR OwnerId = \'' + userId + '\')';
                    //Added on 7-Nov-2011 : because User who is not owner or any group member, 
                    //he was able to see all security enhance = false cases
                    SOQLStr += ' WHERE (Security_Enhancement__c = false OR OwnerId = \'' + userId + '\')';
                }
            }
            if (!String.isEmpty(searchKey)) {
                searchKey = '\'' + '%' + searchKey + '%' + '\'';
                if (tabName =='Accounts'){
                    SOQLStr += ' AND (Name LIKE ' + searchKey + ' OR Type LIKE '+ searchKey + ' OR Phone LIKE '+ searchKey + ' OR Site LIKE '+ searchKey +')';
                }else if(tabName =='Cases'){
                    SOQLStr += ' AND (CaseNumber LIKE ' + searchKey + ' OR Account.Name LIKE '+ searchKey + ' OR Origin LIKE '+ searchKey + ' OR Subject LIKE '+ searchKey  + ' OR Status LIKE '+ searchKey + ' OR Priority LIKE '+ searchKey +')';
                }
            }              
        }
        
        totalCount = Database.countQuery(SOQLStr);        
        return totalCount;
    }
    
    // Get the Public group Id
    private static Id getPublicGroupId(){
        return [SELECT Id FROM Group WHERE DeveloperName = 'Security_Enhancement_User' AND Type = 'Regular'].Id;
    }
    
    // get the group of User Id
    private static Set<Id> getGroupUserIds(){
        Id publicGroupId = getPublicGroupId();
        
        Set<Id> groupUserIds = new Set<Id>();
        if (publicGroupId != null) {
            for (GroupMember gm : [ SELECT UserOrGroupId FROM GroupMember WHERE GroupId = :publicGroupId]) {
                		groupUserIds.add(gm.UserOrGroupId);
            }
        }
        return groupUserIds;
    }
    
    public static Set<Id> getQueuesInWhichUserPresent(Id userId){
        Set<Id> queueIdsToReturn = new Set<Id>();
        List<GroupMember> queueMembers = [SELECT GroupId, Group.Name,UserOrGroupId,Group.Type FROM GroupMember WHERE Group.Type = 'Queue'];
        
        Set<Id> subQueueIds = new Set<Id>();
        
        if(!queueMembers.isEmpty()){
            for(GroupMember member : queueMembers){
                String recordPrefix = member.UserOrGroupId.getSObjectType().getDescribe().getKeyPrefix();
                if(recordPrefix == '00G'){
                    subQueueIds.add(member.UserOrGroupId);
                } else{
                    if(member.UserOrGroupId == userId){
                        queueIdsToReturn.add(member.GroupId);
                    }
                }
            }               
        }
        
        //Get Users from SubQue
        if(subQueueIds.isEmpty()){
            return queueIdsToReturn;                
        }
        
        Set<Id> relatedIds = new Set<Id>();
        Map<Id,String> roleGroupIdMap = new Map<Id,String>();
        List<Group> subGroups = [
            SELECT Id, Name, DeveloperName, RelatedId, Type, Email, OwnerId,Owner.Name, DoesSendEmailToMembers, DoesIncludeBosses 
            FROM Group
            WHERE ID IN :subQueueIds
        ];
        
        for(Group groupRecord : subGroups){
            if(groupRecord.RelatedId != null){						
                relatedIds.add(groupRecord.RelatedId);
                roleGroupIdMap.put(groupRecord.RelatedId,groupRecord.Id);
            }
        } 
        
        //Get Users from Roles 
        List<User> users = [
            SELECT Id, Name,UserRoleId 
            FROM User 
            WHERE UserRoleId IN :relatedIds
        ];
        
        for(User user : users){
            if(user.Id == userId){
                queueIdsToReturn.add(roleGroupIdMap.get(user.UserRoleId));
            }
        }
        
        return queueIdsToReturn;      
    }
    
    public static Boolean checkUserIsPresentInQueue(Id userId,Id queueId){
        // Query to check if the user is a member of the queue
        List<GroupMember> groupMembers = [
            SELECT Id, GroupId, UserOrGroupId 
            FROM GroupMember 
            WHERE GroupId = :queueId 
        ];
        
        // Check if any records were returned
        if (!groupMembers.isEmpty()) {
            Set<Id> subQueueIds = new Set<Id>();
            for(GroupMember member : groupMembers){
                String recordPrefix = member.UserOrGroupId.getSObjectType().getDescribe().getKeyPrefix();
                if(recordPrefix == '00G'){
                    subQueueIds.add(member.UserOrGroupId);
                } else{
                    if(member.UserOrGroupId == userId){
                        return true;
                    }
                }
            }
            
            if(!subQueueIds.isEmpty()){
                Set<Id> relatedIds = new Set<Id>();
                
                List<Group> subGroups = [
                    SELECT Id, Name, DeveloperName, RelatedId, Type, Email, OwnerId,Owner.Name, DoesSendEmailToMembers, DoesIncludeBosses 
                    FROM Group
                    WHERE ID IN :subQueueIds
                ];
                
                for(Group groupRecord : subGroups){
                    if(groupRecord.RelatedId != null){						
                        relatedIds.add(groupRecord.RelatedId);
                    }
                } 
                
                //Get Users from Roles 
                List<User> users = [
                    SELECT Id, Name,UserRoleId 
                    FROM User 
                    WHERE UserRoleId IN :relatedIds
                ];
                
                for(User user : users){
                    if(user.Id == userId){
                        return true;
                    }
                }          
            }
            return false;
        } else {
            System.debug('User is NOT a member of the Queue');
            return false;
        }  
    }
    
    // Helper method to check ownership and group membership for a record (Case/Account)
    public static DTO.EnhanceSecurityControllerResponse checkOwnershipAndGroupMembership(SObject record, Id currentUserId, Set<Id> groupUserIds) {
        Boolean isOwner = false;
        Boolean isInGroup = false;
        Boolean securityEnhancement = false;
        
        if (record instanceof Case) {
            Case caseRecord = (Case) record;
            isOwner = (caseRecord.OwnerId == currentUserId || (caseRecord.Owner.Type == 'Queue' && checkUserIsPresentInQueue(currentUserId, caseRecord.OwnerId)));
            securityEnhancement = caseRecord.Security_Enhancement__c;
            System.debug('isOwner :'+isOwner);
            System.debug('securityEnhancement :'+securityEnhancement);
        } else if (record instanceof Account) {
            Account accountRecord = (Account) record;
            isOwner = (accountRecord.OwnerId == currentUserId);
            securityEnhancement = accountRecord.Security_Enhancement__c;
        }
        
        // Check group membership
        isInGroup = groupUserIds.contains(currentUserId);
       
        if(isOwner && !isInGroup && securityEnhancement){
            // 03-Dec-2024 : when secured case owner is Queue, but q user is not secured 
            return new DTO.EnhanceSecurityControllerResponse(false);
        }else if (isOwner || (isInGroup && securityEnhancement) || (!isInGroup && !securityEnhancement) || (isInGroup && !securityEnhancement)) {
            // Criteria: Return access based on ownership and group membership
        	// 14-Nov-2024 : Added condition (isInGroup && !securityEnhancement) 
            return new DTO.EnhanceSecurityControllerResponse(true);
        }
        
        return new DTO.EnhanceSecurityControllerResponse(false);
    }
    
    public static Set<Id> getPublicGroupMembers() {
        Set<Id> groupUserIds = new Set<Id>();
        Id publicGroupId = [SELECT Id FROM Group WHERE DeveloperName = 'Security_Enhancement_User' AND Type = 'Regular' LIMIT 1].Id;
        
        if (publicGroupId != null) {
            for (GroupMember gm : [SELECT UserOrGroupId FROM GroupMember WHERE GroupId = :publicGroupId]) {
                groupUserIds.add(gm.UserOrGroupId);
            }
        }
        return groupUserIds;
    }
    
    public static Map<Id, DTO.EnhanceSecurityControllerResponse> ValidateRecordsAccess(List<SObject> records, SObjectType sObjectType) {
        Map<Id, DTO.EnhanceSecurityControllerResponse> accessMap = new Map<Id, DTO.EnhanceSecurityControllerResponse>();
        // Get current user info
        Id currentUserId = UserInfo.getUserId();
        Id profileId = UserInfo.getProfileId();
        String profileName = [SELECT Name FROM Profile WHERE Id = :profileId].Name;
        // Criteria 1: If the user is a System Administrator, grant access to all records
        if (profileName == 'System Administrator') {
            for (SObject record : records) {
                accessMap.put(record.Id, new DTO.EnhanceSecurityControllerResponse(true));
            }
            return accessMap;
        }
        
        // Prepare public group "Security_Enhancement_User" members
        Set<Id> groupUserIds = getPublicGroupMembers();
        
        Set<Id> recordIds = new Map<Id, SObject>(records).keySet();
        List<Case> caseList = new List<Case>();
        List<Account> accountList = new List<Account>();
        
        if (sObjectType == Case.SObjectType) {
            caseList = [ SELECT Id, Security_Enhancement__c, OwnerId, Owner.Type FROM Case WHERE Id IN :recordIds];
        }
        
        if (sObjectType == Account.SObjectType) {
            accountList = [SELECT Id, Security_Enhancement__c, OwnerId FROM Account WHERE Id IN :recordIds];
        }
        
        // Process each record based on the SObjectType (Case or Account)
        for (SObject record : records) {
            if (sObjectType == Case.SObjectType) {
                if (!caseList.isEmpty()) {
                    accessMap.put(caseList[0].Id, checkOwnershipAndGroupMembership(caseList[0], currentUserId, groupUserIds));
                }
            } else if (sObjectType == Account.SObjectType) {                
                if (!accountList.isEmpty()) {
                    accessMap.put(accountList[0].Id, checkOwnershipAndGroupMembership(accountList[0], currentUserId, groupUserIds));
                }
            }
        }
        System.debug('accessMap : '+accessMap);
        return accessMap;
    }
    
    // 03-Dec-2024 : to validate secured case ownership to change from non secured user
    public static Map<Id, DTO.EnhanceSecurityControllerResponse> ValidateQueueOwnerAccess(List<Case> caseRecords) {
        Map<Id, DTO.EnhanceSecurityControllerResponse> accessMap = new Map<Id, DTO.EnhanceSecurityControllerResponse>();
        Boolean isInGroup = false;
        Set<Id> groupUserIds = getPublicGroupMembers(); 
        
        for (Case caseRecord : caseRecords) {
            isInGroup = groupUserIds.contains(caseRecord.ownerId);
            if (!isInGroup) {
                accessMap.put(caseRecord.Id, new DTO.EnhanceSecurityControllerResponse(false));
            }else {
                accessMap.put(caseRecord.Id, new DTO.EnhanceSecurityControllerResponse(true));
            }
        }
        return accessMap;
    }
    
    
    /*public static Map<Id, DTO.EnhanceSecurityControllerResponse> ValidateRecordsAccess(List<SObject> records, SObjectType sObjectType) {
        Map<Id, DTO.EnhanceSecurityControllerResponse> accessMap = new Map<Id, DTO.EnhanceSecurityControllerResponse>();
        
        // Get current user info
        Id currentUserId = UserInfo.getUserId();
        Id profileId = UserInfo.getProfileId();
        String profileName = [SELECT Name FROM Profile WHERE Id = :profileId].Name;
        
        // Criteria 1: If the user is a System Administrator, grant access to all records
        if (profileName == 'System Administrator') {
            for (SObject record : records) {
                accessMap.put(record.Id, new DTO.EnhanceSecurityControllerResponse(true));
            }
            return accessMap;
        }
        
        // Prepare public group "Security_Enhancement_User" members
        Set<Id> groupUserIds = getPublicGroupMembers();
        
        Set<Id> recordIds = new Map<Id, SObject>(records).keySet();
        List<Case> caseList = new List<Case>();
        List<Account> accountList = new List<Account>();
        
        if (sObjectType == Case.SObjectType) {
            caseList = [ SELECT Id, Security_Enhancement__c, OwnerId, Owner.Type FROM Case WHERE Id IN :recordIds];
        }
        
        if (sObjectType == Account.SObjectType) {
            accountList = [SELECT Id, Security_Enhancement__c, OwnerId FROM Account WHERE Id IN :recordIds];
        }
        
        // Process each record based on the SObjectType (Case or Account)
        for (SObject record : records) {
            if (sObjectType == Case.SObjectType) {
                if (!caseList.isEmpty()) {
                    accessMap.put(caseList[0].Id, checkOwnershipAndGroupMembership(caseList[0], currentUserId, groupUserIds));
                }
            } else if (sObjectType == Account.SObjectType) {                
                if (!accountList.isEmpty()) {
                    accessMap.put(accountList[0].Id, checkOwnershipAndGroupMembership(accountList[0], currentUserId, groupUserIds));
                }
            }
        }
        
        return accessMap;
    }*/
    
}