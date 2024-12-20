/*
 * matchAcctSDRRouting Test Class
 * @Author: Peter Yim
 * @Date: 2017
 *
 */
 @isTest 
public class matchAcctLeadContactSDRtest{

    static testMethod void matchAcctLeadContactSDR(){
       
      Date oppsCloseDateRefrence;
      Date oppsCreateDateRefrence;

       // Account to Create

        account AccountToCreate = new account(name = 'Test Account 9-14-2015', BillingCountry = 'United States', BillingState = 'CA',Most_Recent_Touch_Campaign__c = 'none', SDR__c = '00550000004U4mP');
        insert AccountToCreate;

        account AccountToCreate2 = new account(name = 'Test Account 9-14-2015', BillingCountry = 'United States', BillingState = 'CA',Most_Recent_Touch_Campaign__c = 'none', SDR__c = '00550000003vZZP');
        insert AccountToCreate2;

       Contact ContactToCreate = new Contact();
       
       // Contact to Create
       ContactToCreate.FirstName = 'Ken';
       ContactToCreate.LastName  = 'test1';
       ContactToCreate.Email     = 'kennaku1@uw.edu';
       ContactToCreate.CurrencyIsoCode = 'USD';
       ContactToCreate.AccountID = AccountToCreate.ID; 
       ContactToCreate.MailingCountry = 'United States';
       ContactToCreate.MailingState = 'CA';
       ContactToCreate.Status__c = 'Nurture';   
       ContactToCreate.LeadSource = 'None';    
       ContactToCreate.Last_Sales_Touch_Type__c = 'NONE';
       ContactToCreate.Number_of_Sales_Requests__c = 0;
       ContactToCreate.Number_of_Sales_Analyst_Engagements__c = 0;
       ContactToCreate.Number_of_Sales_rfp__c = 0;
       ContactToCreate.Number_of_Sales_Meetings__c = 0;
       ContactToCreate.Number_of_Sales_Other_Tasks__c = 0;
       ContactToCreate.Total_Sales_Interactions__c = 0; 
       ContactToCreate.OwnerID = '00538000004bcHy'; 

       //ContactToCreate.LeanData_reporting_matched_account__c = AccountToCreate.ID;      
       insert ContactToCreate;

       // Lead to Create
       Lead leadToCreate = new Lead();
       LeadToCreate.Company = 'New Test Company';
       leadToCreate.FirstName= 'Kenny';
       leadToCreate.LastName= 'Kenny';       
       leadToCreate.Email     = 'ken_naku@yahoo.com';
       leadToCreate.Country = 'United States';
       leadToCreate.State = 'CA';  
       leadToCreate.Status = 'Nurture';       
       leadToCreate.Behavior_Score__c = 0;
       leadToCreate.OwnerID = '00538000004bcHy'; 
       leadToCreate.LeanData__Reporting_Matched_Account__c =  AccountToCreate.ID;     
           insert leadToCreate;           
 
   // Contact to Create
       Contact ContactToCreate2 = new Contact();

       ContactToCreate2.FirstName = 'Ken';
       ContactToCreate2.LastName  = 'test1';
       ContactToCreate2.Email     = 'kennaku1@uw.edu';
       ContactToCreate2.CurrencyIsoCode = 'USD';
       ContactToCreate2.AccountID = AccountToCreate2.ID; 
       ContactToCreate2.MailingCountry = 'United States';
       ContactToCreate2.MailingState = 'CA';
       ContactToCreate2.Status__c = 'Nurture';   
       ContactToCreate2.LeadSource = 'None';    
       ContactToCreate2.Last_Sales_Touch_Type__c = 'NONE';
       ContactToCreate2.Number_of_Sales_Requests__c = 0;
       ContactToCreate2.Number_of_Sales_Analyst_Engagements__c = 0;
       ContactToCreate2.Number_of_Sales_rfp__c = 0;
       ContactToCreate2.Number_of_Sales_Meetings__c = 0;
       ContactToCreate2.Number_of_Sales_Other_Tasks__c = 0;
       ContactToCreate2.Total_Sales_Interactions__c = 0; 
       ContactToCreate2.OwnerID = '00538000004bcHy'; 

       //ContactToCreate2.LeanData_reporting_matched_account__c = AccountToCreate.ID;      
       insert ContactToCreate2;

       // Lead to Create
       Lead leadToCreate2 = new Lead();
       LeadToCreate2.Company = 'New Test Company';
       leadToCreate2.FirstName= 'Kenny';
       leadToCreate2.LastName= 'Kenny';       
       leadToCreate2.Email     = 'ken_naku@yahoo.com';
       leadToCreate2.Country = 'United States';
       leadToCreate2.State = 'CA';  
       leadToCreate2.Status = 'Nurture';       
       leadToCreate2.Behavior_Score__c = 0;
       leadToCreate2.OwnerID = '00538000004bcHy'; 
       leadToCreate2.LeanData__Reporting_Matched_Account__c =  AccountToCreate2.ID;     
           insert leadToCreate2;           
 

   

      
           //test.stopTest();
           
   LeadHistory leadhist1 =new LeadHistory(Field='status', leadid = leadtocreate.id);
        insert leadhist1;
        

        
        
        ContactHistory contacthist1 =new ContactHistory(Field='status__c', contactid = contacttocreate.id);
        insert contacthist1 ;
        
      
           
           Test.startTest();
           matchAcctLeadContactSDR c = new matchAcctLeadContactSDR();
           Database.executeBatch(c);
           Test.stopTest();
         
         // Verify Record are updated 
           Integer i = [SELECT COUNT() FROM Account WHERE SDR__c = '00550000004U4mP'];
           System.assertEquals(i, 1);

}
}