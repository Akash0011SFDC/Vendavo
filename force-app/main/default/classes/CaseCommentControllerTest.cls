/*
Author: Dreamwares
Created on: 2024-03-11 (YYYY-MM-DD)
Function: Test class for CaseCommentController
Developer    Date            Version    Description
-------------------------------------------------------
Dreamwares        2024-03-11     V1.0       Initial Version
*/
@isTest
public class CaseCommentControllerTest {
    
    @testSetup
    public static void testData(){
        
        List<CaseComment> CaseCommentList = new List<CaseComment>();
        
        Account accountRec = new Account();
        accountRec.Name ='Parent Acc';
        INSERT accountRec;
        
        Contact contactRec = new Contact();
        contactRec.LastName='Test Contact 1';
        contactRec.email= 'test@contact1.com';
        contactRec.AccountId=accountRec.Id;
        INSERT contactRec;
        
        Case caseRec = new Case();
        caseRec.AccountId = accountRec.Id;
        caseRec.ContactId  = contactRec.Id;
        caseRec.Status = 'Closed';
        caseRec.Sub_Status__c = 'Closed - Resolved';
        caseRec.Project__c= 'Vendavo internal customer';
        caseRec.Product_Module__c= 'CPQ';
        caseRec.Subject='Test Comment';
        caseRec.Description='Test Description';
        caseRec.Resolution_Type__c = 'Login Request';
        caseRec.CreatedDate = System.today();
        caseRec.Support_Resolved_Date__c = System.today();
        caseRec.ClosedDate = System.today().addDays(1);
        INSERT caseRec;
        
        for(Integer i=0; i<20; i++){
            CaseComment comment = new CaseComment();
            comment.CommentBody = 'Sample text';
            comment.ParentId = caseRec.Id;
            comment.IsPublished = true;
            CaseCommentList.add(comment);
        }
        INSERT CaseCommentList;
    }
    
    @isTest
    public static void testGetCaseComments(){
        
        Case parentCase = [SELECT Id, caseNumber FROM Case LIMIT 1];
        
        Test.startTest();
        List<CaseComment> caseComments = CaseCommentController.getCaseComments(parentCase.Id);
        Test.stopTest();
        System.assertEquals(false, caseComments.isEmpty(), 'The list should not be empty.');
    }

    @isTest
    public static void testCalculateCaseBusinessHours(){
        List<Id> caseIds = new List<Id>();
        
        for(Case caseRec : [SELECT Id, caseNumber FROM Case]){
            caseIds.add(caseRec.Id);
        }
        
        Test.startTest();
        List<Integer> totalHours =CaseCommentController.calculateCaseBusinessHours(caseIds);
        Test.stopTest();
        
        System.assertEquals(false, totalHours.isEmpty(), 'The list should not be empty.');
        
    }    
}