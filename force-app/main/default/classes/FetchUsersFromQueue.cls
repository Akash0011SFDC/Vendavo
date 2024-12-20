public class FetchUsersFromQueue {
    
    public static void fetchUsersfromQueueMethod(String queueId){
        List<GroupMember> groupMemberRecords = [SELECT Group.Name, UserOrGroup.Email FROM GroupMember WHERE GroupId =: queueId];
        Set<Id> userIds = new Set<Id>();
        if (!groupMemberRecords.isEmpty()) {
            Set<Id> subQueueIds = new Set<Id>();
            
            for(GroupMember member : groupMemberRecords){
            	String recordPrefix = member.UserOrGroupId.getSObjectType().getDescribe().getKeyPrefix();
                if(recordPrefix == '00G'){
                    subQueueIds.add(member.UserOrGroupId);
                } else{
                    if(recordPrefix == '005'){
                       userIds.add(member.UserOrGroupId);
                    }
                }
        	}
            System.debug('userIds'+userIds);
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
                Map<Id, User> users = new Map<Id, User>([
                    SELECT Id, Name,UserRoleId 
                    FROM User 
                    WHERE UserRoleId IN :relatedIds
                ]);
                
                userIds.addall(users.KeySet());
            }
        }
        System.debug('userIds222'+userIds);
        List<User> userRecords = [SELECT Id, Email, isActive FROM User WHERE Id =: userIds AND isActive = True];
        List<String> recipientEmails = New List<String>();
        for(User userRecord : userRecords){
            recipientEmails.add(userRecord.Email);
        }
        System.debug(recipientEmails);
		        
    }

}