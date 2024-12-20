/**
* @description       : A Helper class to send email notifications to Case Owners when case comment added to the case.
* @author            : 
* @group             : 
* @last modified on  : 02-12-2024 
* @last modified by  : 
**/ 
public class CaseCommentNotificationHelper {
    
    public static void helperCaseCommentNotificationMethod(List<CaseComment> caseCommentList){
        CaseCommentNotificationHandler.sendCaseCommentNotification(caseCommentList);
    }

}