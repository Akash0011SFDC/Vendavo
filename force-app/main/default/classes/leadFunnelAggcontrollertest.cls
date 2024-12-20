@isTest 

public class leadFunnelAggcontrollertest{
    static testMethod void ConstructorTest() {
    //Insert Records 
         // Account to Create

        account AccountToCreate = new account(name = 'Test Account 9-14-2015', BillingCountry = 'US', BillingState = 'CA');
            
            insert AccountToCreate;

       //Opportunity To Create 
       Opportunity OpportunityToCreate = new opportunity();
       OpportunityToCreate.Name = 'Test Opp';
       OpportunityToCreate.StageName = '1 - Identify Initiatives';
       OpportunityToCreate.Type = 'Direct - Perpetual License';
       OpportunityToCreate.AccountID = AccountToCreate.ID;
       OpportunityToCreate.CloseDate = Date.Today();
       OpportunityToCreate.CurrencyIsoCode = 'USD';
       OpportunityToCreate.LeadSource = 'Sales';
       
           insert OpportunityToCreate;
       
        
       Contact ContactToCreate = new Contact();
       
       // Contact to Create
       ContactToCreate.FirstName = 'Ken';
       ContactToCreate.LastName  = 'test1';
       ContactToCreate.Email     = 'kennaku1@uw.edu';
       ContactToCreate.CurrencyIsoCode = 'USD';
       ContactToCreate.AccountID = AccountToCreate.ID; 
       ContactToCreate.MailingCountry = 'US';
       ContactToCreate.MailingState = 'CA';
       ContactToCreate.Status__c = 'Contacted';       
       //ContactToCreate.LeanData_reporting_matched_account__c = AccountToCreate.ID;      
           insert ContactToCreate;

       // Lead to Create
       Lead leadToCreate = new Lead();
       leadToCreate.FirstName= 'Kenny';
       leadToCreate.LastName= 'Kenny';       
       leadToCreate.Email     = 'ken_naku@yahoo.com';
       leadToCreate.Country = 'US';
       leadToCreate.State = 'CA';  
       leadToCreate.Company = 'Test Company 1'; 
       leadToCreate.Status = 'Prospect';                   
       leadToCreate.LeanData__Reporting_Matched_Account__c =  AccountToCreate.ID;
       leadToCreate.mkto71_Lead_Score__c = 25;     
           insert leadToCreate;     
           
       leadToCreate.Status = 'Engaged';
       update leadToCreate;
            
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
          LeanData__Campaign_Opportunity__c campaignOppCONtoCreate = new LeanData__Campaign_Opportunity__c();
           campaignOppCONtoCreate.LeanData__Account__c = AccountToCreate.Id;
           campaignOppCONtoCreate.LeanData__Contact__c = contactToCreate.Id;
           campaignOppCONtoCreate.LeanData__Opportunity__c = OpportunityToCreate.Id;
           campaignOppCONtoCreate.LeanData__Campaign__c = campaignToCreate.Id;
           
           insert campaignOppCONtoCreate;    
           
           
      //Lean date opportunity lead object record to create
          LeanData__Campaign_Opportunity__c campaignOppCONtoCreateLead = new LeanData__Campaign_Opportunity__c();
           campaignOppCONtoCreateLead.LeanData__Account__c = AccountToCreate.Id;
           campaignOppCONtoCreateLead.LeanData__Lead__c = leadToCreate.Id;
           campaignOppCONtoCreateLead.LeanData__Opportunity__c = OpportunityToCreate.Id;
           campaignOppCONtoCreateLead.LeanData__Campaign__c = campaignToCreate.Id;
           
           insert campaignOppCONtoCreateLead;            
           
      Test.startTest();
      Test.setCurrentPage(Page.LeadFunnel_Visualization);
      leadFunnelAggcontroller controller = new leadFunnelAggcontroller();
      controller.getLeadTallyResults();

        system.assert(Controller != null); // controller has successfully been created
      
      System.currentPageReference();
      Test.stopTest();        
}
}