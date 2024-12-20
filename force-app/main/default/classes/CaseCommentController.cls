/*
Author: Dreamwares
Created on: 2024-03-04 (YYYY-MM-DD)
Test Class : CaseCommentControllerTest 
Function: Fetch CaseComment records and return all related case comment record for CaseID    
Developer    Date            Version    Description
-------------------------------------------------------
Dreamwares        2024-03-04     V1.0       Initial Version
*/
public with sharing class CaseCommentController {
    
    /*
* PURPOSE  : Fetch CaseComment records related to caseId
* PARAM    : Parent Case Id
* RETURNS  : List of CaseComment
*/
    @AuraEnabled
    public static List<CaseComment> getCaseComments(Id caseId) {
        List<CaseComment> caseCommentRecords = [SELECT Id, ParentId, IsPublished, CommentBody, ConnectionReceivedId, ConnectionSentId, CreatedDate
                                                FROM CaseComment 
                                                WHERE ParentId = :caseId 
                                                ORDER BY CreatedDate DESC];
        
        return caseCommentRecords;
    }
    
    
    
    @InvocableMethod(label='Calculate Business Hours' description='Returns the Hours')
    public static List<Integer> calculateCaseBusinessHours(List<ID> caseIds) {
        List<Integer> calculateHours = new List<Integer>();
        Id caseId = caseIds[0];
        Case parentCase = [SELECT Id, ClosedDate FROM Case Where Id =: caseId LIMIT 1];
        
        Integer businessHoursDifference = 0;
        Datetime startDate = parentCase.ClosedDate;
        Datetime endDate = System.Now();
        
        while (startDate < endDate) {
            if (startDate.format('E') != 'Sat' && startDate.format('E') != 'Sun') {
                businessHoursDifference++;
            }
            startDate = startDate.addHours(1);
        }
        
        if(businessHoursDifference != NULL){
            calculateHours.add(businessHoursDifference);
        }
        
        return calculateHours;
    }
}