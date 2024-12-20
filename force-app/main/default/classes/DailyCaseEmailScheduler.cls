/**
 * @description       : 
 * @author            : 
 * @group             : 
 * @last modified on  : 07-08-2024 
 * @last modified by  : 
**/ 
global class DailyCaseEmailScheduler implements Schedulable {
    global void execute(SchedulableContext sc) {
        DailyCaseEmailSender.sendEmails();
    }
}