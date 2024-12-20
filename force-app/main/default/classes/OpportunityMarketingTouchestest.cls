@isTest 
public class OpportunityMarketingTouchestest{

    static testMethod void OpportunityMarketingTouches(){
       
      Date oppsCloseDateRefrence;
      Date oppsCreateDateRefrence;

       // Account to Create

        account AccountToCreate = new account(name = 'Test Account 9-14-2015', BillingCountry = 'United States', BillingState = 'CA');
            
            insert AccountToCreate;

       //Opportunity To Create 
       Opportunity OpportunityToCreate = new opportunity();
       Set<Id> oppsID = new Set<Id>(); 
       OpportunityToCreate.Name = 'Test Opp';
       OpportunityToCreate.StageName = '1 - Identify Initiatives';
       OpportunityToCreate.Type = 'Mobile';
       OpportunityToCreate.AccountID = AccountToCreate.ID;
       OpportunityToCreate.CloseDate = Date.Today();
       OpportunityToCreate.CreatedDate = Date.Today();
       OpportunityToCreate.CurrencyIsoCode = 'USD';
       OpportunityToCreate.LeadSource = 'Sales';
       OpportunityToCreate.Vendavo_Forecast_Category__c = '1. Pipeline';
 
       
           insert OpportunityToCreate;
     
        
       Contact ContactToCreate = new Contact();
       
       // Contact to Create
       ContactToCreate.FirstName = 'Ken';
       ContactToCreate.LastName  = 'test1';
       ContactToCreate.Email     = 'kennaku1@uw.edu';
       ContactToCreate.CurrencyIsoCode = 'USD';
       ContactToCreate.AccountID = AccountToCreate.ID; 
       ContactToCreate.MailingCountry = 'United States';
       ContactToCreate.MailingState = 'CA';
       ContactToCreate.Status__c = 'Contacted';   
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
       ContactToCreate2.Status__c = 'Contacted';   
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
       leadToCreate.Status = 'Nurture';               
       leadToCreate.LeanData__Reporting_Matched_Account__c =  AccountToCreate.ID;     
           insert leadToCreate;           
 
            
      // OpportunityContactRole to Create
      OpportunityContactRole OcrToCreate = new OpportunityContactRole();
      OcrToCreate.OpportunityID = OpportunityToCreate.ID;
      ocrToCreate.ContactID = ContactToCreate.ID;
      ocrToCreate.Role = 'Decision Maker';
      
          insert OcrToCreate ;

      // Campaign to Create    
           Campaign campaignToCreate = new Campaign(Name = 'Testcampaign', IsActive = TRUE);
           campaignToCreate.type = 'Email';
           campaignToCreate.Channel__c = 'Email';
           //campaignToCreate.RecordType = Email ;
          
           insert campaignToCreate;
           
       //CampaignMember to Create     
           CampaignMember campaignMemberToCreate = new CampaignMember();
           campaignMemberToCreate.CampaignID = campaignToCreate.ID;
           campaignMemberToCreate.ContactID = ContactToCreate.ID;

           
           insert campaignMemberToCreate;
           
           campaignMemberToCreate.Status = 'Clicked';
           update campaignMemberToCreate;
           update campaignToCreate;
           update contactToCreate;
           
      //Lean date opportunity contact object record to create
          LeanData__Marketing_Touch__c campaignOppCONtoCreate = new LeanData__Marketing_Touch__c();
           campaignOppCONtoCreate.LeanData__Account__c = AccountToCreate.Id;
           campaignOppCONtoCreate.LeanData__Contact__c = contactToCreate.Id;
           campaignOppCONtoCreate.LeanData__Opportunity__c = OpportunityToCreate.Id;
           campaignOppCONtoCreate.LeanData__Campaign__c = campaignToCreate.Id;
           campaignOppCONtoCreate.LeanData__Campaign_Member_Created_Date__c = System.now();

           insert campaignOppCONtoCreate;

      //Lean date opportunity Lead object record to create
          LeanData__Marketing_Touch__c campaignOppCONtoCreate2 = new LeanData__Marketing_Touch__c();
           campaignOppCONtoCreate2.LeanData__Account__c = AccountToCreate.Id;
           campaignOppCONtoCreate2.LeanData__Lead__c = LeadToCreate.Id;
           campaignOppCONtoCreate2.LeanData__Opportunity__c = OpportunityToCreate.Id;
           campaignOppCONtoCreate2.LeanData__Campaign__c = campaignToCreate.Id;
           campaignOppCONtoCreate2.LeanData__Campaign_Member_Created_Date__c = System.now();
           
           insert campaignOppCONtoCreate2;
       
           //test.stopTest();
           
           Test.startTest();
           OpportunityMarketingTouches c = new OpportunityMarketingTouches();
           Database.executeBatch(c);
           Test.stopTest();
         
         // Verify Record are updated 
           Integer i = [SELECT COUNT() FROM Opportunity WHERE Inferred_Opportunity_Source__c != NULL];
           System.assertEquals(i, 1);

}
}