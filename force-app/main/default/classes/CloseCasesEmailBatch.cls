/**
* @description       : This Apex class implements a batch process to send emails about closed cases with no response. 
*                        The batch process retrieves accounts, associated cases, and relevant users. 
*                        It generates an HTML email for each user with details of closed cases, then sends these emails
* @author            : 
* @group             : 
* @last modified on  : 27-08-2024 
* @last modified by  : 
**/ 
public class CloseCasesEmailBatch implements Database.Batchable<sObject>, Database.stateful{
    private List<Id> accountIdList;
    public List<EmailWrapper> emailWrapperList = new List<EmailWrapper>();
    
    public CloseCasesEmailBatch(List<Id> accountIdList) {
        this.accountIdList = accountIdList;
    }
    // The start method returns the query locator to specify the records to be processed in the batch.
    public Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'SELECT Id, Name, OwnerId, CSM__c FROM Account WHERE Id IN :accountIdList';
        return Database.getQueryLocator(query);
    }
    
    // The execute method processes each batch of records retrieved in the start method.
    public void execute(Database.BatchableContext bc, List<Account> accounts) {
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        DateTime last24Hours = DateTime.now().addHours(-24);
        for (Account accountRecord : [SELECT Id, Name, OwnerId, CSM__c, 
                                      (SELECT Id, UserId, AccountId, User.Name, TeamMemberRole 
                                       FROM AccountTeamMembers
                                       WHERE TeamMemberRole = 'Technical Engagement Manager'),
                                      (SELECT Id, AccountId, CaseNumber, Subject, Status,  Account.Name, Priority, Sub_Status__c, Product_Module__c, Owner.Name, CreatedDate, Account.Owner.Name, Account.CSM__r.Name, ClosedDate
                                       FROM Cases 
                                       WHERE Status = 'Closed' AND  Sub_Status__c = 'Closed - No Response' AND RecordType.Name = 'Support Case' AND
                                       ClosedDate >= :last24Hours)
                                      FROM Account
                                      WHERE Id IN :accounts]) {
                                          
                                          // Initialize the wrapper for the current account
                                          AccountCaseUserWrapper wrapper = new AccountCaseUserWrapper(accountRecord.Id);
                                          
                                          
                                          // Add Account Owner to users list in the wrapper
                                          wrapper.users.add(new User(Id = accountRecord.OwnerId));
                                          
                                          // Add CSM to users list in the wrapper if not null
                                          if (accountRecord.CSM__c != null) {
                                              wrapper.users.add(new User(Id = accountRecord.CSM__c));
                                          }
                                          
                                          // Add Account Team Members to users list in the wrapper
                                          for (AccountTeamMember teamMember : accountRecord.AccountTeamMembers) {
                                              wrapper.users.add(new User(Id = teamMember.UserId));
                                          }
                                          
                                          // Add Cases to the cases list in the wrapper
                                          for (Case caseRecord : accountRecord.Cases) {
                                              wrapper.cases.add(caseRecord);
                                          }
                                          
                                          // Generate the email body
                                          String emailBody = generateEmailBody(wrapper.cases, accountRecord);
                                          
                                          for (User user : wrapper.users) {
                                              emailWrapperList.add(new EmailWrapper(
                                                  'Action Required: Cases Closed Due to No Response from Customer ', 
                                                  emailBody, 
                                                  false, 
                                                  user.Id
                                              ));
                                          }
                                      }
        
        
    }
    
    // The finish method for Sending the mails.
    public void finish(Database.BatchableContext bc) {
        if (emailWrapperList != null && !emailWrapperList.isEmpty()) {
            List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
            OrgWideEmailAddress emailAddress = [SELECT Id, Address from OrgWideEmailAddress
                                                WHERE Address = 'vsupport@vendavo.com' LIMIT 1];
            for (EmailWrapper emailWrap : emailWrapperList) {
                Messaging.SingleEmailMessage singleEmail = new Messaging.SingleEmailMessage();
                //String[] ccaddresses = new String[] {'vicky@dreamwares.com'}; 
                singleEmail.setSubject(emailWrap.subject);
                singleEmail.setHtmlBody(emailWrap.emailBody);
                singleEmail.setSaveAsActivity(emailWrap.setAsActivity);
                singleEmail.setTargetObjectId(emailWrap.targetObjectId);
                //singleEmail.setToAddresses(new String[] {'testingdeveloper954@gmail.com'});
                singleEmail.setOrgWideEmailAddressId(emailAddress.Id);
                //singleEmail.SetccAddresses(ccaddresses);
                emails.add(singleEmail);
            }
            
            System.debug('Sending ' + emails.size() + ' emails.');
            Messaging.SendEmailResult[] results = Messaging.sendEmail(emails);
            
            // Debug each email send result
            for (Integer i = 0; i < results.size(); i++) {
                if (results[i].isSuccess()) {
                    System.debug('Email ' + i + ' sent successfully.');
                } else {
                    System.debug('Failed to send email ' + i + '. Error: ' + results[i].getErrors()[0].getMessage());
                }
            }
        } else {
            System.debug('No emails to send.');
        }
    }
    
    //Method for Generate HTML Email Body
    private String generateEmailBody(List<Case> cases, Account account) {
        String emailBody = '<html><body>';
        emailBody += '<p>Hello,<br><br>' + 
                   'The following case(s) listed below have been closed with no response. This is due to the customer not replying back to our support teams within the required timeframe. ' + 
                   'We ask that you please follow up with your customer and take appropriate steps with your contact to avoid this from recurring.</p>';
        emailBody += '<table style="width:100%;border-collapse:collapse;">';
        emailBody += '<thead>';
        emailBody += '<tr style="background-color:#f2f2f2;">';
        emailBody += '<th style="border:1px solid #ddd;padding:8px;">Account Name</th>';
        emailBody += '<th style="border:1px solid #ddd;padding:8px;">Case Number</th>';
        emailBody += '<th style="border:1px solid #ddd;padding:8px;">Priority</th>';
        emailBody += '<th style="border:1px solid #ddd;padding:8px;">Status</th>';
        emailBody += '<th style="border:1px solid #ddd;padding:8px;">Sub Status</th>';
        emailBody += '<th style="border:1px solid #ddd;padding:8px;">Product Module</th>';
        emailBody += '<th style="border:1px solid #ddd;padding:8px;">Owner</th>';
        emailBody += '<th style="border:1px solid #ddd;padding:8px;">Subject</th>';
        emailBody += '<th style="border:1px solid #ddd;padding:8px;">Created Date</th>';
        emailBody += '<th style="border:1px solid #ddd;padding:8px;">Account Owner</th>';
        emailBody += '<th style="border:1px solid #ddd;padding:8px;">CSM</th>';
        emailBody += '<th style="border:1px solid #ddd;padding:8px;">Technical Engagement Manager</th>';
        emailBody += '</tr>';
        emailBody += '</thead>';
        emailBody += '<tbody>';
        
        for (Case c : cases) {
            emailBody += '<tr>';
            emailBody += '<td style="border:1px solid #ddd;padding:8px;">' + c.Account.Name + '</td>';
            emailBody += '<td style="border:1px solid #ddd;padding:8px;">' + c.CaseNumber + '</td>';
            emailBody += '<td style="border:1px solid #ddd;padding:8px;">' + c.Priority + '</td>';
            emailBody += '<td style="border:1px solid #ddd;padding:8px;">' + c.Status + '</td>';
            emailBody += '<td style="border:1px solid #ddd;padding:8px;">' + c.Sub_Status__c + '</td>';
            emailBody += '<td style="border:1px solid #ddd;padding:8px;">' + c.Product_Module__c + '</td>';
            emailBody += '<td style="border:1px solid #ddd;padding:8px;">' + c.Owner.Name + '</td>';
            emailBody += '<td style="border:1px solid #ddd;padding:8px;">' + c.Subject + '</td>';
            emailBody += '<td style="border:1px solid #ddd;padding:8px;">' + c.CreatedDate + '</td>';
            emailBody += '<td style="border:1px solid #ddd;padding:8px;">' + c.Account.Owner.Name + '</td>';
            String csmName = c.Account.CSM__r != null ? c.Account.CSM__r.Name : '';
        	emailBody += '<td style="border:1px solid #ddd;padding:8px;">' + csmName + '</td>';
        
            // Generate a comma-separated list of Account Team Members' names
            List<String> teamMemberNames = new List<String>();
            for (AccountTeamMember member : account.AccountTeamMembers) {
                teamMemberNames.add(member.User.Name);
            }
            String teamMembers = String.join(teamMemberNames, ', ');
            emailBody += '<td style="border:1px solid #ddd;padding:8px;">' + teamMembers + '</td>';
            
            emailBody += '</tr>';
            emailBody += '</tr>';
        }
        
        emailBody += '</tbody>';
        emailBody += '</table>';
        emailBody += '</body></html>';
        
        return emailBody;
    }
    
}