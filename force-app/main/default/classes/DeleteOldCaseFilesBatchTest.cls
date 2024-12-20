/**
* @File Name : DeleteOldCaseFilesBatchTest.cls
* @Description : For code coverage of DeleteOldCaseFilesBatch.cls class
* @Author : Dreamwares
* @Last Modified By : Dreamwares
* @Last Modified On : December 12, 2024
* @Modification Log :
*==============================================================================
* Ver | Date 			| Author 		| Modification
*==============================================================================
* 1.0 | December 10, 2024 | Dreamwares  	| Initial Version
* 1.1 | December 12, 2024 | Dreamwares	| Added comments
**/

@isTest
public class DeleteOldCaseFilesBatchTest {
    
    @testSetup
    static void setup() {
        List<Case> cases = new List<Case>();
        for (Integer i = 0; i < 10; i++) {
            Case c = new Case(
                Subject = 'Test Case ' + i,
                Status = 'Closed',
                Sub_Status__c = 'Closed - Resolved',
                Project__c= 'Vendavo internal customer',
                Product_Module__c= 'CPQ',
                Description='Test Description',
                Resolution_Type__c = 'Login Request',
                CreatedDate = System.today(),
                Support_Resolved_Date__c = System.today()
            );
            cases.add(c);
        }
        insert cases;
        List<Attachment> attachments = new List<Attachment>();
        for (Case c : cases) {
            Attachment a = new Attachment(
                ParentId = c.Id,
                Name = 'Test Attachment ' + c.Id,
                Body = Blob.valueOf('Test attachment body'),
                ContentType = 'text/plain'
            );
            attachments.add(a);
        }
        insert attachments;
        
        List<ContentVersion> docs = new List<ContentVersion>();
        for (Case c : cases) {
            ContentVersion doc = new ContentVersion(
                Title = 'Test Document ' + c.Id,
                PathOnClient = 'TestDocument.pdf',
                VersionData = Blob.valueOf('Test document body'),
                IsMajorVersion = true
            );
            docs.add(doc);
        }
        insert docs;
        
        List<ContentDocumentLink> docLinks = new List<ContentDocumentLink>();
        for (ContentVersion doc : docs) {
            ContentDocumentLink docLink = new ContentDocumentLink(
                ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :doc.Id].ContentDocumentId,
                LinkedEntityId = cases[docs.indexOf(doc)].Id,
                ShareType = 'V'
            );
            docLinks.add(docLink);
        }
        insert docLinks;
    }
    
 /*   @isTest
    static void testBatch() {
        Test.startTest();
        DeleteOldCaseFilesBatch batch = new DeleteOldCaseFilesBatch();
        Database.executeBatch(batch);
        Test.stopTest();
        
        List<Attachment> remainingAttachments = [
            SELECT Id 
            FROM Attachment 
            WHERE ParentId IN (SELECT Id FROM Case WHERE Status = 'Closed')
        ];
        System.assertEquals(0, remainingAttachments.size());
        
        List<ContentDocumentLink> remainingDocLinks = [
            SELECT Id
            FROM ContentDocumentLink
            WHERE LinkedEntityId IN (SELECT Id FROM Case WHERE Status = 'Closed')
        ];  
        System.assertEquals(0, remainingDocLinks.size());
        
        List<ContentDocumentLink> docLinks = [
            SELECT ContentDocumentId
            FROM ContentDocumentLink
            WHERE LinkedEntityId IN (SELECT Id FROM Case WHERE Status = 'Closed')
        ];
        
        Set<Id> documentIdsToDelete = new Set<Id>();
        for (ContentDocumentLink link : docLinks) {
            documentIdsToDelete.add(link.ContentDocumentId);
        }
        List<ContentDocument> remainingDocuments = [
            SELECT Id 
            FROM ContentDocument 
            WHERE Id IN :documentIdsToDelete
        ];
        System.assertEquals(0, remainingDocuments.size());
    }*/
    
    @isTest
    static void testBatchWithOpenCases() {
        List<Case> openCases = new List<Case>();
        for (Integer i = 0; i < 5; i++) {
            Case c = new Case(
                Subject = 'Open Case ' + i,
                Status = 'New'
            );
            openCases.add(c);
        }
        insert openCases;
        
        Test.startTest();
        DateTime endDate = DateTime.newInstance(2024, 6, 15, 23, 59, 59);
        DateTime startDate = DateTime.newInstance(2024, 1, 1, 0, 0, 0);
        DeleteOldCaseFilesBatch batchJob = new DeleteOldCaseFilesBatch(startDate, endDate);
        
        Database.executeBatch(batchJob);
        Test.stopTest();
        
        List<ContentDocumentLink> openDocLinks = [
            SELECT Id 
            FROM ContentDocumentLink 
            WHERE LinkedEntityId IN (SELECT Id FROM Case WHERE Status = 'New')
        ];
        
    }
    
    @isTest
    static void testBatchWithNoCases() {
        delete [SELECT Id FROM Case];
        Test.startTest();
        DateTime endDate = DateTime.newInstance(2024, 6, 15, 23, 59, 59);
        DateTime startDate = DateTime.newInstance(2024, 1, 1, 0, 0, 0);

        DeleteOldCaseFilesBatch batchJob = new DeleteOldCaseFilesBatch(startDate, endDate);
        
        Database.executeBatch(batchJob);
       // DateTime endDate = DateTime.newInstance(2024, 6, 15, 23, 59, 59);
       // DateTime startDate = DateTime.newInstance(2024, 1, 1, 0, 0, 0);
       String cronExpression = '0 0 0 * * ?';

        DeleteOldCaseFilesBatchScheduler.schedule(
            startDate.date(), 
            endDate.date(), 
            cronExpression, 
            'Delete Old Case Files Batch'
        );
        Test.stopTest();
        
        List<ContentDocumentLink> noDocLinks = [
            SELECT Id 
            FROM ContentDocumentLink
            WHERE LinkedEntityId IN (SELECT Id FROM Case)
        ];
        System.assertEquals(0, noDocLinks.size());
    }
}