public class EmailWrapper {
    
    public String subject;
    public String emailBody;
    public Boolean setAsActivity;
    public String targetObjectId;
    
    public EmailWrapper(String subject, String emailBody, Boolean setAsActivity, String targetObjectId) {
        this.subject = subject;
        this.emailBody = emailBody;
        this.setAsActivity = setAsActivity;
        this.targetObjectId = targetObjectId;
    }
}