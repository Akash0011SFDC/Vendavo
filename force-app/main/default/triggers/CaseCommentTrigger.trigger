/**
* @description       : A Trigger to send email notifications to Case Owners when case comment added to the case.
* @author            : 
* @group             : 
* @last modified on  : 02-12-2024 
* @last modified by  : 
**/ 
trigger CaseCommentTrigger on CaseComment (after insert) {
	CaseCommentNotificationHelper.helperCaseCommentNotificationMethod(trigger.new);
}