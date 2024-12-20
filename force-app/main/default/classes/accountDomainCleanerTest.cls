/*
 * accountDomainCleaner test class
 * @Author: Peter Yim
 * @Date: 2017
 *
 */
@isTest 
public class accountDomainCleanerTest{

    static testMethod void accountDomainCleaner(){
       
      Date oppsCloseDateRefrence;
      Date oppsCreateDateRefrence;

       // Account to Create

        account AccountToCreate = new account(name = 'Vendavo Test', BillingCountry = 'United States', BillingState = 'CA',Most_Recent_Touch_Campaign__c = 'none'
,Website = ''
,Most_Recent_Touch_Date__c = date.today()
,Most_Recent_Touch_Person__c = 'none'
,Most_Recent_Touch_Type__c = 'none'
,Net_New_Engaged_Leads__c = 0
,Net_New_Nurture_Leads__c = 0
,Net_New_Prospect_Leads__c = 0
,Net_New_Qualified_Leads__c = 0
,Net_New_SAL_Leads__c = 0
,Net_New_SQL_Leads__c = 0
,Total_Engaged_Leads_Contacts__c = 0
,Total_Leads_and_Contacts__c = 0
,Snapshot_Engaged_Leads__c = 0
,Snapshot_Nurture_Leads__c = 0
,Snapshot_Prospect_Leads__c = 0
,Snapshot_Qualified_Leads__c = 0
,Snapshot_SAL_Leads__c = 0
,Snapshot_SQL_Leads__c = 0
,Transitioned_Engaged_Leads__c = 0
,Transitioned_Nurture_Leads__c = 0
,Transitioned_Prospect_Leads__c = 0
,Transitioned_Qualified_Leads__c = 0
,Transitioned_SAL_Leads__c = 0
,Transitioned_SQL_Leads__c = 0
,Engaged_Contacts_in_Last_30_Days__c = 0

,Number_of_Advertising_Touches__c = 0
,Number_of_DirectMail_Touches__c = 0
,Number_of_Email_Touches__c = 0
,Number_of_Event_Touches__c = 0
,Number_of_Telemarketing_Touches__c = 0
,Number_of_Webinar_Touches__c = 0
,Number_of_Website_Touches__c = 0
,Content_Syndication_Touches__c = 0

,Number_of_180_Days_Advertising_Touches__c = 0
,Number_of_180_Days_DirectMail_Touches__c = 0
,Number_of_180_Days_Email_Touches__c = 0
,Number_of_180_Days_Event_Touches__c = 0
,Number_of_180_Days_Telemarketing_Touches__c = 0
,Number_of_180_Days_Webinar_Touches__c = 0
,Number_of_180_Days_Website_Touches__c = 0
,Total_Number_of_Engaged_Contacts__c = 0
,Total_Number_of_Engaged_Contacts_in_180__c = 0
,Total_Number_of_Engaged_Leads__c = 0
,Total_Number_of_Engaged_Leads_in_180_day__c = 0
,Total_Leads_Behavior_Score__c = 0
,Total_Leads_Demographic_Score__c = 0
,Total_Leads_Behavior_Demo_Score__c = 0
,Total_Contacts_Behavior_Score__c = 0
,Total_Contacts_Demographic_Score__c = 0
,Total_Contacts_Behavior_Demo_Score__c = 0
,Total_Leads_Contacts_Behavior_Score__c = 0
,Total_Leads_Contacts_Demographic_Score__c = 0
,Total_Leads_Contacts_Behavior_Demo_Score__c = 0
,Stage_M_Opportunity__c = FALSE
,Stage_M_Creation_Date__c = null
,Current_Opportunity__c = null
,Stage_3_Or_More_in_the_Last_18_Months__c = FALSE
,Total_Number_of_Sales_Touches__c = 0
,Number_of_180_Days_Sales_Touches__c = 0
,Last_Sales_Touch_Date__c = null
,Snapshot_Contacted_leads__c = 0
,Transitioned_Contacted_Leads__c = 0
,Net_New_Contacted_Leads__c = 0 );
            
            insert AccountToCreate;

    
        
       Contact ContactToCreate = new Contact();
       
       // Contact to Create
       ContactToCreate.FirstName = 'Johnny';
       ContactToCreate.LastName  = 'Doe';
       ContactToCreate.Email     = 'jdoe@vendavo.com';
       ContactToCreate.CurrencyIsoCode = 'USD';
       ContactToCreate.AccountID = AccountToCreate.ID; 
       ContactToCreate.MailingCountry = 'United States';
       ContactToCreate.MailingState = 'CA';
       ContactToCreate.Status__c = 'Contacted';   
       ContactToCreate.LeadSource = 'None';    
       ContactToCreate.Last_Sales_Touch_Type__c = 'NONE';
          insert ContactToCreate;


       // Lead to Create
       Lead leadToCreate = new Lead();
       LeadToCreate.Company = 'Vendavo';
       leadToCreate.FirstName= 'Chan';
       leadToCreate.LastName= 'Smith';       
       leadToCreate.Email     = 'csmith@vendavo.com';
       leadToCreate.Country = 'United States';
       leadToCreate.State = 'CA';            
       leadToCreate.LeanData__Reporting_Matched_Account__c =  AccountToCreate.ID;     
        insert leadToCreate;           
 

        
             
           
           Test.startTest();
           accountDomainCleaner c = new accountDomainCleaner();
           Database.executeBatch(c);
           Test.stopTest();
         
         // Verify Record are updated 
           Integer i = [SELECT COUNT() FROM Account WHERE Website != NULL];
           System.assertEquals(i, 1);

}
}