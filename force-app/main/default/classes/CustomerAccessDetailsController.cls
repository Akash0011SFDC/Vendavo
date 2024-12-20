/**
 * Name: CustomerAccessDetailsController
 * Description : CaseHistory - This is use to find dateTime for given case field 
 * Change History:
 * <Version>    <Date of Change>    <Author Name>        <Describe the changes made>
 * ---------------------------------------------------------------------------------
 * v1.0          30-Oct-2023        Dreamwares              Created
 */
public class CustomerAccessDetailsController{

    @AuraEnabled(cacheable=true)
    public static CaseHistory getCaseHistory(Id caseId, String fieldName) {
        
        List<CaseHistory> caseHistoryList = [SELECT Id, createdDate 
                                             FROM CaseHistory 
                                             WHERE field =:fieldName AND 
                                                   CaseId =: caseId
                                             ORDER BY CreatedDate DESC 
                                             LIMIT 1];
                                                   
        if(caseHistoryList.size() > 0)
            return caseHistoryList [0];
            
         return null;
    }
     
}