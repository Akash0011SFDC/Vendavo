global class DailyOpenCasesEmailScheduler implements Schedulable{
    global void execute(SchedulableContext sc) {
            DailyOpenCasesEmailSender.sendEmails();
        }
}