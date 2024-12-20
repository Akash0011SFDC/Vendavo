@isTest 


public class LeadFunnelFromAccSchedulableInsertTest{
static testMethod void LeadFunnelFromAccSchedulableInsert() {
    Date SixtyDaysAgo = system.today().addDays(-60);  
    
    //Insert Records 
         // Account to Create

     account AccountToCreate = new account(name = 'Test Account 9-14-2015', BillingCountry = 'United States', BillingState = 'CA',Most_Recent_Touch_Campaign__c = 'none'
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

      
       Date ThirtyDaysAgo = system.today().addDays(-30);  
     

   test.startTest();
   LeadFunnelFromAccSchedulableInsert lrs = new LeadFunnelFromAccSchedulableInsert();
   //lrs.iGetJobs = new GetTestJobs();  // will return > 5 asyncjobs and execute your else condition
   String schedule = '0 0 23 * * ?';
   system.schedule('Daily Schedule' , schedule, lrs);
   
   


   test.stopTest();
        //string verifyFieldChange1 = (string) [SELECT id, NewValue FROM LeadHistory WHERE LeadId = : leadtocreate4.id limit 1][0].get('NewValue'); 
       

       // Verify Record are updated 
           Integer i = [SELECT COUNT() FROM Account WHERE Happy_Path_Transition_Nurture__c != NULL];
           System.assertEquals(i, 1);
}
}