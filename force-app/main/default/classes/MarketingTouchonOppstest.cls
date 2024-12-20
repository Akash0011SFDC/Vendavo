@isTest 
public class MarketingTouchonOppstest{
    public static String testAccountID;
    public static String testContactID;
    public static String testCampaignID;
    static testMethod void FirstLastTouchesOnOpps(){
       
     // test.startTest();

       // Account to Create

        account AccountToCreate = new account(name = 'Test Account 9-14-2015', BillingCountry = 'United States', BillingState = 'CA');
            
            insert AccountToCreate;

       //Opportunity To Create 
       Opportunity OpportunityToCreate = new opportunity();
       OpportunityToCreate.Name = 'Test Opp';
       OpportunityToCreate.StageName = '1 - Identify Initiatives';
       OpportunityToCreate.Type = 'Mobile';
       OpportunityToCreate.AccountID = AccountToCreate.ID;
       OpportunityToCreate.CloseDate = Date.Today();
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
       //ContactToCreate.LeanData_reporting_matched_account__c = AccountToCreate.ID;      
           insert ContactToCreate;
/*
       // Lead to Create
       Lead leadToCreate = new Lead();
       leadToCreate.FirstName= 'Kenny';
       leadToCreate.LastName= 'Kenny';       
       leadToCreate.Email     = 'ken_naku@yahoo.com';
       leadToCreate.Country = 'United States';
       leadToCreate.State = 'CA';       
       leadToCreate.LeanData__Reporting_Matched_Account__c =  AccountToCreate.ID;     
           insert leadToCreate;           
    **/      
            
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
       
           //test.stopTest();
           
           Test.startTest();
           FirstLastTouchesOnOpps c = new FirstLastTouchesOnOpps();
           Database.executeBatch(c);
           Test.stopTest();
         
         // Verify Record are updated 
           Integer i = [SELECT COUNT() FROM Opportunity WHERE First_Marketing_Touch_Before_Create_Name__c != NULL];
           System.assertEquals(i, 1);

}
}