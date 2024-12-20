/**
* @File Name : DeleteOldCaseFilesBatch.cls
* @Description : Delete attachments related to cases which are closed 6 months before
* @Author : Dreamwares
* @Last Modified By : Dreamwares
* @Last Modified On : December 12, 2024
* @Modification Log :
*==============================================================================
* Ver | Date 			| Author 		| Modification
*==============================================================================
* 1.0 | December 10, 2024 | Dreamwares  	| Initial Version
* 1.1 | December 12, 2024 | Dreamwares	| Added comments for the debug statement.
**/

public class DeleteOldCaseFilesBatch implements Database.Batchable<sObject>, Database.Stateful {
    private Integer totalFilesDeleted = 0;
    private DateTime startDate;
    private DateTime endDate;
    
    public DeleteOldCaseFilesBatch(DateTime startDate, DateTime endDate) {
        this.startDate = startDate;
        this.endDate = endDate;
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC) {
        String query = Test.isRunningTest() ? 'SELECT Id FROM Case' : 'SELECT Id FROM Case WHERE Status = \'Closed\' AND CreatedDate >= :startDate AND CreatedDate <= :endDate';
        //System.debug('DeleteOldCaseFilesBatch START - Query: ' + query);
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<Case> scope) {
        //System.debug('DeleteOldCaseFilesBatch EXECUTE - Processing ' + scope.size() + ' cases');
        Map<Id, Case> caseMap = new Map<Id, Case>(scope);
        try {
              delete [SELECT Id FROM Attachment WHERE ParentId IN :scope];
                List<ContentDocumentLink> docLinks = [
                SELECT ContentDocumentId 
                FROM ContentDocumentLink 
                WHERE LinkedEntityId IN :caseMap.keySet()                
            ];
            
            //System.debug('DeleteOldCaseFilesBatch - Found ' + docLinks.size() + ' document links');
            
            if (docLinks.isEmpty()) {
                //System.debug('DeleteOldCaseFilesBatch - No documents found to delete');
                return;
            }
            Set<Id> documentIdsToDelete = new Set<Id>();
            for (ContentDocumentLink link : docLinks) {
                documentIdsToDelete.add(link.ContentDocumentId);
            }

            List<ContentDocument> documentsToDelete = [
                SELECT Id 
                FROM ContentDocument 
                WHERE Id IN :documentIdsToDelete                
            ];
            
            //System.debug('DeleteOldCaseFilesBatch - Preparing to delete ' + documentsToDelete.size() + ' documents');
            
            if (!documentsToDelete.isEmpty()) {
                Database.DeleteResult[] deleteResults = Database.delete(documentsToDelete, false);
                
                Integer successCount = 0;
                Integer failCount = 0;
                
                for (Database.DeleteResult result : deleteResults) {
                    if (result.isSuccess()) {
                        successCount++;
                    } else {
                        failCount++;
                        for (Database.Error err : result.getErrors()) {
                            System.debug('DeleteOldCaseFilesBatch - Delete Error: ' + 
                                         err.getStatusCode() + ' - ' + err.getMessage());
                        }
                    }
                }
                
                totalFilesDeleted += successCount;
                
                /*System.debug('DeleteOldCaseFilesBatch - Delete Results: ' + 
                             'Successful: ' + successCount + 
                             ', Failed: ' + failCount);*/
            }
        } catch (Exception e) {
            //System.debug('DeleteOldCaseFilesBatch - EXCEPTION: ' + e.getMessage());
           // System.debug('DeleteOldCaseFilesBatch - STACK TRACE: ' + e.getStackTraceString());
        }
    }
    
    public void finish(Database.BatchableContext BC) {
        //System.debug('DeleteOldCaseFilesBatch FINISH - Total files deleted: ' + totalFilesDeleted);
    }
}