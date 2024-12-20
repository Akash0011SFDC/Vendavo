/**
* @File Name : DeleteOldCaseFilesBatchScheduler.cls
* @Description : For running the batch class DeleteOldCaseFilesBatch.cls.
* @Author : Dreamwares
* @Last Modified By : Dreamwares
* @Last Modified On : December 12, 2024
* @Modification Log :
*==============================================================================
* Ver | Date 			| Author 		| Modification
*==============================================================================
* 1.0 | December 11, 2024 | Dreamwares  	| Initial Version
* 1.1 | December 12, 2024 | Dreamwares	| Added comments
**/


public class DeleteOldCaseFilesBatchScheduler implements Schedulable {
    private Date startDate;
    private Date endDate;
    
    public DeleteOldCaseFilesBatchScheduler(Date startDate, Date endDate) {
        if (startDate == null || endDate == null) {
            throw new IllegalArgumentException('Start and end dates must be provided');
        }
        
        if (startDate >= endDate) {
            throw new IllegalArgumentException('Start date must be before or equal to end date');
        }
        
        this.startDate = startDate;
        this.endDate = endDate;
    }
    
    public void execute(SchedulableContext sc) {
        DateTime startDateTime = DateTime.newInstance(startDate, Time.newInstance(0, 0, 0, 0));
        DateTime endDateTime = DateTime.newInstance(endDate, Time.newInstance(0, 0, 0, 0));
        
        DeleteOldCaseFilesBatch batchJob = new DeleteOldCaseFilesBatch(startDateTime, endDateTime);
        Database.executeBatch(batchJob, 200);
    }
    
    
    public static void schedule(Date startDate, Date endDate,String cronExpression, String jobName) {
        DeleteOldCaseFilesBatchScheduler scheduler = new DeleteOldCaseFilesBatchScheduler(startDate, endDate);
        
        try {
            System.schedule(
                String.isBlank(jobName) 
                ? 'Delete Case Files: ' + startDate + ' to ' + endDate 
                : jobName, 
                cronExpression, 
                scheduler
            );
        } catch (Exception e) {
            System.debug('Error scheduling batch job: ' + e.getMessage());
            throw e;
        }
    }
}