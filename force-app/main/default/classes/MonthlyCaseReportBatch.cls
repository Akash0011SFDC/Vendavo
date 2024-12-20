/**
* @description       : This Apex class implements a batch process to send emails about Account and case details which open percentage greater than 60%
*                        The batch process retrieves accounts, associated cases. 
*                        It generates an HTML email cases.
* @author            : 
* @group         
* @Created on        : 8/11/24
* @last modified on  : 
* @last modified by  : 
**/ 
public class MonthlyCaseReportBatch implements Database.Batchable<SObject>,Database.Stateful {
     // Define date range variables
    Date currentMonthStartDate;
    Date previousMonthStartDate;
    Date previousMonthEndDate;
    Date twoMonthsAgoStartDate;
    Date twoMonthsAgoEndDate;

    // Maps to store open case counts per account
    Map<Id, Integer> previousMonthOpenCasesByAccount = new Map<Id, Integer>();
    Map<Id, Integer> twoMonthsAgoOpenCasesByAccount = new Map<Id, Integer>();

    public MonthlyCaseReportBatch() {
        // Calculate date ranges for current and previous months
        Date today = Date.today();
        currentMonthStartDate = today.toStartOfMonth();
        previousMonthStartDate = currentMonthStartDate.addMonths(-1);
        previousMonthEndDate = currentMonthStartDate.addDays(-1); // End of previous month
        twoMonthsAgoStartDate = previousMonthStartDate.addMonths(-1);
        twoMonthsAgoEndDate = previousMonthStartDate.addDays(-1);
    }

    public Database.QueryLocator start(Database.BatchableContext BC) {
        // Query all cases from the last two months
        String query = 'SELECT Id, AccountId, CreatedDate, Status FROM Case ' + 
                       'WHERE Status != \'Closed\' AND CreatedDate >= :twoMonthsAgoStartDate AND CreatedDate <= :previousMonthEndDate AND AccountId != NULL';
        System.debug('query'+query);
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<Case> scope) {
        System.debug('scope'+scope.size());
        // Count open cases for each account for each month
        for (Case caseRecord : scope) {
            Id accountId = caseRecord.AccountId;
            
            // Count open cases for the previous month
            if (caseRecord.CreatedDate >= previousMonthStartDate && 
                caseRecord.CreatedDate <= previousMonthEndDate) {
                
                if (!previousMonthOpenCasesByAccount.containsKey(accountId)) {
                    previousMonthOpenCasesByAccount.put(accountId, 0);
                }
                previousMonthOpenCasesByAccount.put(accountId, previousMonthOpenCasesByAccount.get(accountId) + 1);
            }
            
            // Count open cases for two months ago 
            if (caseRecord.CreatedDate >= twoMonthsAgoStartDate && 
                caseRecord.CreatedDate <= twoMonthsAgoEndDate) {
                
                if (!twoMonthsAgoOpenCasesByAccount.containsKey(accountId)) {
                    twoMonthsAgoOpenCasesByAccount.put(accountId, 0);
                }
                twoMonthsAgoOpenCasesByAccount.put(accountId, twoMonthsAgoOpenCasesByAccount.get(accountId) + 1);
            }
        }
  }

  public void finish(Database.BatchableContext BC) {
    //Custom label for orgEmailAddress for MonthlyCaseReport
    String monthlyCaseReportToOrgWideEmail = System.Label.MonthlyCaseReportToOrgWideEmail;
    String targetEmailsStr = System.Label.MonthlyCaseReportToEmails;
      
    if(monthlyCaseReportToOrgWideEmail != null && targetEmailsStr != null){
      
        //get OrgWideEmailAddress
        OrgWideEmailAddress orgEmailAddress = [SELECT Id, Address FROM OrgWideEmailAddress WHERE Address =:monthlyCaseReportToOrgWideEmail  LIMIT 1];
          
        if(previousMonthOpenCasesByAccount!=null && twoMonthsAgoOpenCasesByAccount!=null){
            // Query account names for all accounts with open cases in the maps
            Set<Id> accountIds = new Set<Id>();
            accountIds.addAll(previousMonthOpenCasesByAccount.keySet());
            accountIds.addAll(twoMonthsAgoOpenCasesByAccount.keySet());
            System.debug('accountIds' + accountIds);
     
            if(accountIds!=null){
                Map<Id, String> accountNames = new Map<Id, String>();
                for (Account acc : [SELECT Id, Name FROM Account WHERE Id IN :accountIds]) {
                    accountNames.put(acc.Id, acc.Name);
                }
            
                List<String> targetEmails = targetEmailsStr.split(',');
            
                // Generate the HTML email body and check if there are any accounts with >60% increase
                String emailBody = generateEmailBody(accountNames);
            
                // Only send the email if the emailBody contains data (accounts with >60% increase)
                if (emailBody!=null && emailBody.contains('<tr>')) {
                    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                    email.setToAddresses(targetEmails); // Add desired recipient(s) here
                    email.setSubject('Monthly Account Case Report: Accounts with Over 60% Open Cases Increase');
                    email.setHtmlBody(emailBody);
                    email.setSaveAsActivity(false);
                    email.setOrgWideEmailAddressId(orgEmailAddress.Id);
            
                    System.debug('Sending email: ' + email);
            
                    try {
                        // Send the email
                        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
                    } catch (Exception e) {
                        System.debug('Error sending email: ' + e.getMessage());
                    }
                } else {
                    System.debug('No accounts with >60% increase. Email not sent.');
                } 
            }
        } 
   }
}
 
 /* 
  * @MethodName  : generateEmailBody
  * @Parameters  : Map<Id, String> accountNames
  * @Description : Helper method to generate the HTML email body for each account
  * @ReturnType  : String - emailbody
 */
  private String generateEmailBody(Map<Id, String> accountNames) {
      String emailBody = '<html><body>';
      emailBody += '<p>The following report identifies account(s) with an open ticket number increase of more than 60 percent from previous month:</p>';
      emailBody += '<table style="width:100%;border-collapse:collapse;">';
      emailBody += '<thead><tr style="background-color:#f2f2f2;">';
      emailBody += '<th style="border:1px solid #ddd;padding:8px;">Customer Name</th>';
      emailBody += '<th style="border:1px solid #ddd;padding:8px;">Current Month</th>';
      emailBody += '<th style="border:1px solid #ddd;padding:8px;">Previous Month</th>';
      emailBody += '<th style="border:1px solid #ddd;padding:8px;">Percentage Increase</th>';
      emailBody += '</tr></thead><tbody>';
      
      for (Id accountId : previousMonthOpenCasesByAccount.keySet()) {
          Integer previousCount = previousMonthOpenCasesByAccount.get(accountId);
          Integer twoMonthsAgoCount = twoMonthsAgoOpenCasesByAccount.get(accountId);
          Decimal percentageDifference = twoMonthsAgoCount > 0 
              ? ((Decimal.valueOf(previousCount) - Decimal.valueOf(twoMonthsAgoCount)) / Decimal.valueOf(twoMonthsAgoCount)) * 100
              : 0;
          
          // Check if percentage difference is greater than 60%
          if (percentageDifference > 60) {
              String accountName = accountNames.containsKey(accountId) ? accountNames.get(accountId) : 'Unknown Account';
              emailBody += '<tr>';
              emailBody += '<td style="border:1px solid #ddd;padding:8px;">' + accountName + '</td>';
              emailBody += '<td style="border:1px solid #ddd;padding:8px;">' + previousCount + '</td>';
              emailBody += '<td style="border:1px solid #ddd;padding:8px;">' + twoMonthsAgoCount + '</td>';
              emailBody += '<td style="border:1px solid #ddd;padding:8px;">' + percentageDifference + '%</td>';
              emailBody += '</tr>';
          }
      }
      
      emailBody += '</tbody></table></body></html>';
      return emailBody;
  }
}