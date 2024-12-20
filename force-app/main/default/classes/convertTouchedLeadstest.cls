@isTest 
public class convertTouchedLeadstest {
	static testMethod void ConvertTouchedLeads() {
	  Date oppsCloseDateRefrence;
    Date oppsCreateDateRefrence;
      List <Account> assoList = new List<Account>();   
      List <Opportunity> oppsList = new List<Opportunity>();   
      List <Lead> leadsList = new List<Lead>();
    List <Contact> contactList = new List<Contact>();
    Set <String> checkedBefore;
      Boolean hasOpps = FALSE;
      Boolean markedOpp = FALSE;
      Boolean hasParent = FALSE;
      Integer leadCount = 0;  
      List<string> leadsID = new List<string>();
      List<string> associatedID = new List<string>();
      List<string> contactID = new List<string>();
       List<string> leadToContact = new List<string>();
       List<string> contactToAdd = new List<string>();
        List <CampaignMember> campaigns = new List <CampaignMember>();
        List <CampaignMember> campaignsLead = new List <CampaignMember>();



       // Account to Create



        account AccountToCreate = new account(name = 'Test Account 9-14-2015', BillingCountry = 'United States', BillingState = 'CA');
        insert AccountToCreate;

       //Opportunity To Create 
       Opportunity OpportunityToCreate = new opportunity();
       Set<Id> oppsID = new Set<Id>(); 
        OpportunityToCreate.Name = 'Activated Account';
        OpportunityToCreate.StageName = 'Marketing';
        OpportunityToCreate.Type = 'Direct - Perpetual License';
        OpportunityToCreate.Deal_Scope__c = 'Profit Analyzer and Price Optimization Manager';
        OpportunityToCreate.Short_Description__c='Activated Account';
         OpportunityToCreate.AccountID = AccountToCreate.ID;

               OpportunityToCreate.CloseDate = Date.Today().addYears(1);
               OpportunityToCreate.CreatedDate = Date.Today();
               OpportunityToCreate.CurrencyIsoCode = 'USD';
               OpportunityToCreate.LeadSource = 'Marketing - MQL';
               OpportunityToCreate.Vendavo_Forecast_Category__c = 'Omitted';
             OpportunityToCreate.Maintenance_Amount__c = 81000;
             OpportunityToCreate.Amount = 450000;

                  OpportunityToCreate.Days_in_Stage_1__c = 0;
                  OpportunityToCreate.Days_in_Stage_2__c = 0;
                  OpportunityToCreate.Days_in_Stage_3__c = 0;
                  OpportunityToCreate.Days_in_Stage_4__c = 0;
                  OpportunityToCreate.Days_in_Stage_5__c = 0;
                  OpportunityToCreate.Days_in_Stage_6__c = 0;
                  OpportunityToCreate.Days_in_Stage_M__c = 0;


           insert OpportunityToCreate;
     
        
       Contact ContactToCreate = new Contact();
       
       // Contact to Create
       ContactToCreate.FirstName = 'Peter';
       ContactToCreate.LastName  = 'test1';
       ContactToCreate.Email     = 'yim@chalk.org';
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


           insert ContactToCreate;


       // Contact2 to Create
       Contact ContactToCreate2 = new Contact();
       
       ContactToCreate2.FirstName = 'Peter';
       ContactToCreate2.LastName  = 'test1';
       ContactToCreate2.Email     = 'yim@chalk.org';
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


      OpportunityContactRole ocr = new OpportunityContactRole();
      ocr.ContactId = ContactToCreate.id;
      ocr.Role = 'Don\'t Know';
      ocr.OpportunityId = OpportunityToCreate.id;
      insert ocr;
      OpportunityContactRole ocr2 = new OpportunityContactRole();
      ocr2.ContactId = ContactToCreate2.id;
      ocr2.Role = 'Don\'t Know';
      ocr2.OpportunityId = OpportunityToCreate.id;
      insert ocr2;
       // Lead to Create
       Lead leadToCreate = new Lead();
       LeadToCreate.Company = 'New Test Company';
       leadToCreate.FirstName = 'Pete';
       leadToCreate.LastName = 'PeteTest';       
       leadToCreate.Email     = 'peterz133@gmail.com';
       leadToCreate.Country = 'United States';
       leadToCreate.State = 'CA';  
       leadToCreate.Status = 'Nurture';    
       leadToCreate.Total_Number_of_Touches__c = 0;    
       leadToCreate.LeanData__Matched_Account_Name__c = 'Test Account 9-14-2015';

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
          LeanData__Campaign_Opportunity__c campaignOppCONtoCreate = new LeanData__Campaign_Opportunity__c();
           campaignOppCONtoCreate.LeanData__Account__c = AccountToCreate.Id;
           campaignOppCONtoCreate.LeanData__Contact__c = contactToCreate.Id;
           campaignOppCONtoCreate.LeanData__Opportunity__c = OpportunityToCreate.Id;
           campaignOppCONtoCreate.LeanData__Campaign__c = campaignToCreate.Id;
           
           insert campaignOppCONtoCreate;

      //Lean date opportunity Lead object record to create
          LeanData__Campaign_Opportunity__c campaignOppCONtoCreate2 = new LeanData__Campaign_Opportunity__c();
           campaignOppCONtoCreate2.LeanData__Account__c = AccountToCreate.Id;
           campaignOppCONtoCreate2.LeanData__Lead__c = LeadToCreate.Id;
           campaignOppCONtoCreate2.LeanData__Opportunity__c = OpportunityToCreate.Id;
           campaignOppCONtoCreate2.LeanData__Campaign__c = campaignToCreate.Id;
           
           insert campaignOppCONtoCreate2;
       
           //test.stopTest();
           
           Test.startTest();
           ConvertTouchedLeads c = new ConvertTouchedLeads();
           c.query = 'Select Id From Lead Limit 200';
           Database.executeBatch(c, 200);
           Test.stopTest();
         


         // Verify Record are updated 
           Integer i = [SELECT COUNT() FROM Lead WHERE Total_Number_of_Touches__c = 0];
           System.assertEquals(i, 1);
       }
}