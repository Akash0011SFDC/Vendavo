/**
* @description       : A class to send email notifications to users based on their specified time.
* @author            : 
* @group             : 
* @last modified on  : 24-10-2024 
* @last modified by  : 
**/ 
public class DailyOpenCasesEmailSender {
    public static void sendEmails() {
        // Fetch the email template used for sending notifications
        EmailTemplate template = [SELECT Id 
                                  FROM EmailTemplate 
                                  WHERE DeveloperName = 'User_Open_Case_Detail_Email_Template' LIMIT 1];
        
        OrgWideEmailAddress emailAddress = [select id, Address from OrgWideEmailAddress where Address = 'vsupport@vendavo.com' LIMIT 1];
        // Get the list of user IDs to whom emails should be sent now
        List<UserEmailInfo> usersToEmail = getUsersToEmailNow(); 
        system.debug('usersToEmail'+usersToEmail);
        // Collect all emails in a list
        List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();

        // Prepare email for each user
        for (UserEmailInfo  userInfo : usersToEmail) {
            Messaging.SingleEmailMessage mail = createEmailForUser(userInfo.userId, template.Id, emailAddress.Id, userInfo.emailSendTime);
            emailsToSend.add(mail);
        }

        // Send all emails in bulk
        if (!emailsToSend.isEmpty()) {
            Messaging.SendEmailResult[] results = Messaging.sendEmail(emailsToSend);
            for (Messaging.SendEmailResult result : results) {
                if (result.isSuccess()) {
                    System.debug('Email sent successfully');
                } else {
                    System.debug('Error while sending email. Message: ' + result.getErrors()[0].getMessage());
                }
            }
        }
    }

    private static List<UserEmailInfo> getUsersToEmailNow() {
        List<UserEmailInfo> usersToEmail = new List<UserEmailInfo>();
        List<OpenCasesUserInfo__mdt> userRecords = OpenCasesUserInfo__mdt.getAll().values();
        DateTime currentDateTime = System.now();
        Time currentTime = currentDateTime.time();

        for (OpenCasesUserInfo__mdt userRecord : userRecords) {
            if (userRecord.UserId__c != null && userRecord.EmailSend_Time__c != null) {
                Time emailTime = parseTime(userRecord.EmailSend_Time__c);
                if (emailTime != null) {
                    Boolean isWithinRange = isTimeWithinRange(currentTime, emailTime, 2); 
                    if (isWithinRange) {
                        usersToEmail.add(new UserEmailInfo(userRecord.UserId__c, emailTime));
                    }
                }
            }
        }
        return usersToEmail;
    }

    //Method for Parse Metadata Time-Value into Time Format
    private static Time parseTime(String timeStr) {
        if (String.isNotBlank(timeStr)) {
            List<String> parts = timeStr.split(':');
            if (parts.size() == 2) {
                Integer hours = Integer.valueOf(parts[0]);
                Integer minutes = Integer.valueOf(parts[1]);
                return Time.newInstance(hours, minutes, 0, 0);
            }
        }
        return null;
    }

    //Method to Check the users time for sending mails is within Range or not
    private static Boolean isTimeWithinRange(Time currentTime, Time emailTime, Integer minutesRange) {
        Integer currentMinutes = currentTime.hour() * 60 + currentTime.minute();
        Integer emailMinutes = emailTime.hour() * 60 + emailTime.minute();
        Integer difference = Math.abs(currentMinutes - emailMinutes);
        
        return difference <= minutesRange;
    }

    @TestVisible
    private static Messaging.SingleEmailMessage createEmailForUser(Id userId, Id templateId, Id orgWideEmailAddressId, Time emailSendTime) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] ccAddresses = getCCAddressesForTime(emailSendTime); // Get CC addresses based on email send time
        system.debug('ccAddresses'+ccAddresses);
        mail.setTemplateId(templateId); 
        mail.setTargetObjectId(userId);
        mail.setSaveAsActivity(false);
        mail.setOrgWideEmailAddressId(orgWideEmailAddressId);
        mail.SetccAddresses(ccaddresses);
        return mail;
    }

    // method to get CC addresses based on the email send time
    private static String[] getCCAddressesForTime(Time emailSendTime) {
        if (emailSendTime != null) {
            if (emailSendTime.hour() == 8 && emailSendTime.minute() == 30) {
                return new String[] {'Jkovac@vendavo.com', 'mreddy@vendavo.com', 'cswinford@vendavo.com', 'amendoza@vendavo.com'};
            } else if (emailSendTime.hour() == 8 && emailSendTime.minute() == 00) {
                return new String[] {'vkoubik@vendavo.com', 'lpaciorek@vendavo.com', 'amendoza@vendavo.com'};
            } else if (emailSendTime.hour() == 14 && emailSendTime.minute() == 00) {
                return new String[] {'epunzalan@vendavo.com', 'cswinford@vendavo.com', 'kdonaghue@vendavo.com', 'amendoza@vendavo.com'};
            }
        }
        return new String[] {};
    }
    
    public class UserEmailInfo {
        public Id userId;
        public Time emailSendTime;
    
        public UserEmailInfo(Id userId, Time emailSendTime) {
            this.userId = userId;
            this.emailSendTime = emailSendTime;
        }
    }

}