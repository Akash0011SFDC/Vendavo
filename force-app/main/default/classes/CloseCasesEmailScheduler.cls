/**
* @description       : A Schedular class to call the CloseCasesEmailBatch Class.
* @author            : 
* @group             : 
* @last modified on  : 27-08-2024 
* @last modified by  : 
**/ 
public class CloseCasesEmailScheduler implements Schedulable {
    public void execute(SchedulableContext sc) {
        // Fetch cases with Status 'Closed' and Sub-Status 'Closed - No Response' 
        // Prepare a set of Account IDs
        Set<Id> accountIds = new Set<Id>();
        DateTime last24Hours = DateTime.now().addHours(-24);
        for (Case caseRec : [SELECT Id, AccountId, Status, Sub_Status__c,ClosedDate
                             FROM Case
                             WHERE Status = 'Closed' 
                             AND Sub_Status__c = 'Closed - No Response' 
                             AND ClosedDate >= :last24Hours
                             ]) {
                                 if (caseRec.AccountId != null) {
                                     accountIds.add(caseRec.AccountId);
                                 }
                             }
        
        // Convert the set of Account IDs to a list
        List<Id> accountIdList = new List<Id>(accountIds);
        
        // Pass the accountIdList to the batch class
        if (!accountIdList.isEmpty()) {
            CloseCasesEmailBatch batch = new CloseCasesEmailBatch(accountIdList);
            Database.executeBatch(batch);
        }
    }
}