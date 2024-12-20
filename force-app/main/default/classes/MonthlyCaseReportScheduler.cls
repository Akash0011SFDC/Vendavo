public class MonthlyCaseReportScheduler implements Schedulable{
    public void execute(SchedulableContext SC) {
        MonthlyCaseReportBatch batch = new MonthlyCaseReportBatch();
        Database.executeBatch(batch,200);
    }
}