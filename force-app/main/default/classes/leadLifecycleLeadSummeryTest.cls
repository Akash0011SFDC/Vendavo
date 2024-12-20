@isTest 
public class leadLifecycleLeadSummeryTest{

    static testMethod void leadLifecycleLeadSummery(){
    
     Date oppsCloseDateRefrence;
      Date oppsCreateDateRefrence;

       // Account to Create

        account AccountToCreate = new account(name = 'Test Account ', BillingCountry = 'United States', BillingState = 'CA',Most_Recent_Touch_Campaign__c = 'none'
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
,Number_of_365_Days_Advertising_Touches__c = 0
,Number_of_365_Days_DirectMail_Touches__c = 0
,Number_of_365_Days_Email_Touches__c = 0
,Number_of_365_Days_Event_Touches__c = 0
,Number_of_365_Days_Telemarketing_Touches__c = 0
,Number_of_365_Days_Webinar_Touches__c = 0
,Number_of_365_Days_Website_Touches__c = 0
,Number_of_18_Months_Advertising_Touches__c = 0
,Number_of_18_Months_DirectMail_Touches__c = 0
,Number_of_18_Months_Email_Touches__c = 0
,Number_of_18_Months_Event_Touches__c = 0
,Number_of_18_Months_Telemarketing_Touch__c = 0
,Number_of_18_Months_Webinar_Touches__c = 0
,Number_of_18_Months_Website_Touches__c = 0
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
,Score_Lost_No_Decision_Stage_3__c = 0
,Score_Snapshot_Hot_Leads__c = 0
,Score_Snapshot_Warm_Leads__c = 0
,Score_LC_Demographics__c = 0
,Score_LC_Behavior__c = 0
,Score_Recent_Engagement_180_Days__c = 0
,Score_Recent_Engagement_365_Days__c = 0
,Score_Relevant_Search__c = 0
,Score_Stage_Opportunity__c = 0
,Score_Vendavo_Page_Views__c = 0
,Score_Vendavo_Total__c = 0
,Stage_M_Opportunity__c = FALSE
,Stage_M_Creation_Date__c = null
,Current_Opportunity__c = null
,Stage_3_Or_More_in_the_Last_18_Months__c = FALSE
,Total_Number_of_Sales_Touches__c = 0
,Number_of_180_Days_Sales_Touches__c = 0
,Last_Sales_Touch_Date__c = null
,Page_Visit_Last_7_Days__c =1
,Page_Visit_Last_30_Days__c = 0




,Happy_Path_Transition_Qualified__c = 0
,Happy_Path_Transition_Engaged__c = 0
,Happy_Path_Transition_Contacted__c = 0
,Happy_Path_Transition_Nurture__c = 0
,Happy_Path_Transition_Sql__c = 0
,Happy_Path_Transition_SAL__c = 0
,Happy_Path_Transition_Prospect__c = 0 
,Snapshot_Contacted_leads__c = 0
,Transitioned_Contacted_Leads__c = 0
,Net_New_Contacted_Leads__c = 0 );
            
            insert AccountToCreate;

        
       Contact ContactToCreate = new Contact();
       
       // Contact to Create
       ContactToCreate.FirstName = 'Ken';
       ContactToCreate.LastName  = 'test1';
       ContactToCreate.Email     = 'kennaku1@uw.edu';
       ContactToCreate.CurrencyIsoCode = 'USD';
       ContactToCreate.AccountID = AccountToCreate.ID; 
       ContactToCreate.MailingCountry = 'United States';
       ContactToCreate.MailingState = 'CA';
       ContactToCreate.Lead_Status_2019__c = 'MQL';   
       ContactToCreate.LeadSource = 'None';    
       ContactToCreate.Last_Sales_Touch_Type__c = 'NONE';
          ContactToCreate.Number_of_Sales_Requests__c = 0;
          ContactToCreate.Number_of_Sales_Analyst_Engagements__c = 0;
          ContactToCreate.Number_of_Sales_rfp__c = 0;
          ContactToCreate.Number_of_Sales_Meetings__c = 0;
          ContactToCreate.Number_of_Sales_Other_Tasks__c = 0;
          ContactToCreate.Total_Sales_Interactions__c = 0; 
       //ContactToCreate.LeanData_reporting_matched_account__c = AccountToCreate.ID;      
           insert ContactToCreate;


       // Contact2 to Create
       Contact ContactToCreate2 = new Contact();
       
       ContactToCreate2.FirstName = 'Ken';
       ContactToCreate2.LastName  = 'test1';
       ContactToCreate2.Email     = 'kennaku1@uw.edu';
       ContactToCreate2.CurrencyIsoCode = 'USD';
       ContactToCreate2.AccountID = AccountToCreate.ID; 
       ContactToCreate2.MailingCountry = 'United States';
       ContactToCreate2.MailingState = 'CA';
       ContactToCreate2.Lead_Status_2019__c = 'SQL';   
       ContactToCreate2.LeadSource = 'Partner';  
       ContactToCreate2.CreatedDate = date.Today().addDays(-25);  
       ContactToCreate2.Last_Sales_Touch_Type__c = 'NONE';
       
       //     
           insert ContactToCreate2;

       // Lead to Create
       Lead leadToCreate = new Lead();
       LeadToCreate.Company = 'New Test Company';
       leadToCreate.FirstName= 'Kenny';
       leadToCreate.LastName= 'Kenny';       
       leadToCreate.Email     = 'ken_naku@yahoo.com';
       leadToCreate.Country = 'United States';
       leadToCreate.State = 'CA';  
       leadToCreate.Lead_Status_2019__c = 'Nurture';               
       leadToCreate.LeanData__Reporting_Matched_Account__c =  AccountToCreate.ID;     
        insert leadToCreate;           

       Lead leadToCreate2 = new Lead();
       LeadToCreate2.Company = 'New Test Company';
       leadToCreate2.FirstName= 'Fred';
       leadToCreate2.LastName= 'Ca';       
       leadToCreate2.Email     = 'fred_ca@yahoo.com';
       leadToCreate2.Country = 'United States';
       leadToCreate2.State = 'CA';  
       leadToCreate2.Lead_Status_2019__c = 'Nurture';               
       leadToCreate2.LeanData__Reporting_Matched_Account__c =  AccountToCreate.ID;     
       insert leadToCreate2;           

        Test.startTest();
           leadLifecycleLeadSummery c = new leadLifecycleLeadSummery();
           Database.executeBatch(c);
           Test.stopTest();
         
         // Verify Record are updated 
           Integer i = [SELECT COUNT() FROM Lead_Lifecycle__c];
           System.assertEquals(i, 1);
 

    }
}