/**
* @description       : A class to send email notifications to Case Owners when case comment added to the case.
* @author            : 
* @group             : 
* @last modified on  : 12-12-2024 
* @last modified by  : 
**/ 
public class CaseCommentNotificationHandler {

    public static void sendCaseCommentNotification(List<CaseComment> caseCommentList){
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        String orgWideAddressId = getOrgWideEmailAddress();
        Map<String, Schema.SObjectField> caseCommentFieldMap = Schema.getGlobalDescribe().get('CaseComment').getDescribe().fields.getMap();
        String soql = 'SELECT ';
        for(String fieldName : caseCommentFieldMap.keyset()){
            soql += fieldName + ',';
        }
        soql = soql.removeEnd(',');
        soql += ' , CreatedBy.Email, CreatedBy.Name FROM CaseComment WHERE Id IN :caseCommentList';
        caseCommentList = Database.query(soql);
        Case caseRecord = getRelatedCase(caseCommentList);
        List<String> recipientEmails = getRecipientEmails(caseRecord);
        if (!recipientEmails.isEmpty()) {
            Messaging.SingleEmailMessage mail = createEmail(caseRecord, caseCommentList, orgWideAddressId, recipientEmails);
            if (mail != null) {
                emails.add(mail);
            }
        }
        // Send all emails in bulk
        if (!emails.isEmpty()) {
            Messaging.SendEmailResult[] results = Messaging.sendEmail(emails);
            for (Messaging.SendEmailResult result : results) {
                if (result.isSuccess()) {
                    System.debug('Email sent successfully');
                } else {
                    System.debug('Error while sending email. Message: ' + result.getErrors()[0].getMessage());
                }
            }
        }
        
    }
    // Method to get the orgwideemailaddress
    Private static String getOrgWideEmailAddress(){
        OrgWideEmailAddress emailAddress = [SELECT Id, Address 
                                            FROM OrgWideEmailAddress 
                                            WHERE Address = 'caseupdates@vendavo.com' LIMIT 1];
        return emailAddress.Id;
    }
    // Method to get the related case record.
    Private static Case getRelatedCase(List<CaseComment> caseCommentList){
        Set<Id> caseIds = New Set<Id>();
        for (CaseComment comment : caseCommentList) {
            caseIds.add(comment.ParentId);
        }
        Case relatedCaseRecord =[SELECT Id, CaseNumber, Subject, Owner.Email, Owner.Name, Owner.Type 
                                 FROM Case 
                                 WHERE Id = :caseIds LIMIT 1];
        return relatedCaseRecord;
    }
    // Method to get the recepientemailid from case record
    Private static List<String> getRecipientEmails(Case caseRecord){
        List<String> recipientEmails = New List<String>();
        if(Test.isRunningTest()){
            recipientEmails.add('vicky@dreamwares.com');
        } else {
            if(caseRecord.Owner.Type == 'Queue'){
                //recipientEmails = fetchUsersfromQueueMethod(caseRecord.OwnerId);
            } else {
                if(String.isNotBlank(caseRecord.Owner.Email)){
                    recipientEmails.add(caseRecord.Owner.Email);
                }  
            }
        }
        return recipientEmails;
    }
    //method for sending emails to case owners 
    private static Messaging.SingleEmailMessage createEmail(Case caseRecord, List<CaseComment> caseComments, String orgWideAddressId, List<String> recipientEmails){
        Messaging.SingleEmailMessage email;
        List<String> emailBodies = new List<String>();
        String formattedToken = EmailMessages.getFormattedThreadingToken(caseRecord.Id);
        String caseURL = URL.getOrgDomainUrl().toExternalForm() + 
            '/' + caseRecord.Id;
        system.debug('recipientEmails2'+recipientEmails);
        for(String recipientEmail : recipientEmails){
            for (CaseComment comment : caseComments) {
                if(recipientEmail != comment.CreatedBy.Email){
                    String emailBody = '';
                    emailBody += '<p>' + comment.CreatedBy.Name + ' has added a comment to Case ' + caseRecord.CaseNumber + ': "' + caseRecord.Subject + '". Please read the comment below and then click on the link to respond appropriately.</p>';
                    emailBody += '<p>Comment:</p> \n'+ comment.CommentBody;
                    emailBody += '<p><a href="' + caseUrl + '">' + caseUrl + '</a></p>';
                    emailBody += '<br>';
                    emailBody += '<span style="color: white;">' + formattedToken + '</span>';
                    emailBodies.add(emailBody);
                    
                }
            }
        }
        if (!emailBodies.isEmpty()) {
            email = new Messaging.SingleEmailMessage();
            // Combine email bodies for all comments (or you can send one email per comment if preferred)
            String combinedBody = String.join(emailBodies, '<hr>'); // Use <hr> for a horizontal rule to separate multiple comments
            email.setHtmlBody(combinedBody);
            email.setOrgWideEmailAddressId(orgWideAddressId);
            email.setToAddresses(recipientEmails);
            email.setSubject('New case comment notification. Case Number' + caseRecord.CaseNumber);
            email.setSaveAsActivity(false);
        }
        return email;
    }
    @TestVisible
    private static List<String> fetchUsersfromQueueMethod(String queueId){
        List<GroupMember> groupMemberRecords = [SELECT Group.Name, UserOrGroup.Email FROM GroupMember WHERE GroupId =: queueId];
        Set<Id> userIds = new Set<Id>();
        if (!groupMemberRecords.isEmpty()) {
            Set<Id> subQueueIds = new Set<Id>();
            
            for(GroupMember member : groupMemberRecords){
                if(String.valueof(member.UserOrGroupId).Startswith('00G')){
                    subQueueIds.add(member.UserOrGroupId);
                } else{
                    if(String.valueof(member.UserOrGroupId).Startswith('005')){
                       userIds.add(member.UserOrGroupId);
                    }
                }
        	}
            //System.debug('userIds'+userIds);
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
        //System.debug('userIds222'+userIds);
        List<User> userRecords = [SELECT Id, Email, isActive FROM User WHERE Id =: userIds AND isActive = True];
        List<String> recipientEmails = New List<String>();
        for(User userRecord : userRecords){
            if(String.isNotBlank(userRecord.Email)){
                recipientEmails.add(userRecord.Email);
            }    
        }
        //System.debug(recipientEmails);
		return  recipientEmails;       
    }
    
}