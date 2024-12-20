/**
 * Name: CustomerAccessDetailsControllerTest
 * Description : Test class for CustomerAccessDetailsController
 * Change History:
 * <Version>    <Date of Change>    <Author Name>        <Describe the changes made>
 * ---------------------------------------------------------------------------------
 * v1.0          30-Oct-2023        Dreamwares              Created
 */
 
@IsTest 
private class CustomerAccessDetailsControllerTest {
    
    @IsTest
    static void CustomerAccessDetailsTest() {
        
        Case caseRec = createCase();
        Test.startTest();
        CaseHistory  caseHistoryRec = CustomerAccessDetailsController.getCaseHistory(caseRec.Id, 'Customer_Access_Approval__c');
        //System.assertEquals(null, caseHistoryRec.id);
        //History tracking not enable in test class. https://ideas.salesforce.com/s/idea/a0B8W00000GdciTUAR/enable-history-tracking-for-apex-test-methods
        
        caseRec.Customer_Access_Approval__c = 'Yes';
        UPDATE caseRec;
        
        caseHistoryRec = CustomerAccessDetailsController.getCaseHistory(caseRec.Id, 'Customer_Access_Approval__c');
        //System.assertNotEquals(null, caseHistoryRec.id);
        
        Test.stopTest();

    }
    
    private static case createCase(){
        
        Case caseRec = new Case();
        caseRec.Origin='Email';
        caseRec.Status='New';
        caseRec.Type='Technical Support';
        caseRec.subject = 'test';
        
        INSERT caseRec;
        
        return caseRec;
    }
    
}