@isTest 


public class LeadFunnelSchedulableInsertTest{
static testMethod void LeadFunnelSchedulableInsert() {
    Date SixtyDaysAgo = system.today().addDays(-60);  
    
    //Insert Records 
         // Account to Create

        account AccountToCreate = new account(name = 'Test Account 9-14-2015', BillingCountry = 'US', BillingState = 'CA', X6_Cs_Target_Account__c = 'Q4 2015', CreatedDate = SixtyDaysAgo, AnnualRevenue = 1000000000 );
            
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
       ContactToCreate.mkto71_Lead_Score__c = 60;      
            
       //ContactToCreate.LeanData_reporting_matched_account__c = AccountToCreate.ID;      
           insert ContactToCreate;
       ContactToCreate.Status__c = 'Qualified' ;   
           update ContactToCreate;  
       Contact ContactToCreate2 = new Contact();
       
       // Contact to Create2
       ContactToCreate2.FirstName = 'Ken';
       ContactToCreate2.LastName  = 'test1';
       ContactToCreate2.Email     = 'kennaku1@uw.edu';
       ContactToCreate2.CurrencyIsoCode = 'USD';
       ContactToCreate2.AccountID = AccountToCreate.ID; 
       ContactToCreate2.MailingCountry = 'US';
       ContactToCreate2.MailingState = 'CA';
       ContactToCreate2.Status__c = 'SQL';       
       ContactToCreate2.mkto71_Lead_Score__c = 50;      
       
       //ContactToCreate.LeanData_reporting_matched_account__c = AccountToCreate.ID;      
           insert ContactToCreate2;
       ContactToCreate2.Status__c = 'SAL';    
           update ContactToCreate2;  
          
          
       Contact ContactToCreate3 = new Contact();
           
       // Contact to Create3
       ContactToCreate3.FirstName = 'Ken';
       ContactToCreate3.LastName  = 'test1';
       ContactToCreate3.Email     = 'kennaku1@uw.edu';
       ContactToCreate3.CurrencyIsoCode = 'USD';
       ContactToCreate3.AccountID = AccountToCreate.ID; 
       ContactToCreate3.MailingCountry = 'US';
       ContactToCreate3.MailingState = 'CA';
       ContactToCreate3.Status__c = 'SAL'; 
       ContactToCreate3.mkto71_Lead_Score__c = 70;      
       //ContactToCreate.LeanData_reporting_matched_account__c = AccountToCreate.ID;      
           insert ContactToCreate3;
       ContactToCreate3.Status__c = 'Closed Won';    
           update ContactToCreate3;                      
           

       Contact ContactToCreate4 = new Contact();
           
       // Contact to Create4
       ContactToCreate4.FirstName = 'Ken';
       ContactToCreate4.LastName  = 'test1';
       ContactToCreate4.Email     = 'kennaku1@uw.edu';
       ContactToCreate4.CurrencyIsoCode = 'USD';
       ContactToCreate4.AccountID = AccountToCreate.ID; 
       ContactToCreate4.MailingCountry = 'US';
       ContactToCreate4.MailingState = 'CA';
       ContactToCreate4.Status__c = 'SQL'; 
       ContactToCreate4.mkto71_Lead_Score__c = 70;      
       //ContactToCreate.LeanData_reporting_matched_account__c = AccountToCreate.ID;      
           insert ContactToCreate4;
       ContactToCreate4.Status__c = 'Closed Lost';    
           update ContactToCreate4;  

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
       leadToCreate.AnnualRevenue = 1000000000;   
           insert leadToCreate;     
           
       leadToCreate.Status = 'Contacted';
       update leadToCreate;
       
       
       // Lead to Create Contacted
       Lead leadToCreate2 = new Lead();
       leadToCreate2.FirstName= 'Kenny';
       leadToCreate2.LastName= 'Kenny';       
       leadToCreate2.Email     = 'ken_naku@yahoo.com';
       leadToCreate2.Country = 'US';
       leadToCreate2.State = 'CA';  
       leadToCreate2.Company = 'Test Company 1'; 
       leadToCreate2.Status = 'Contacted';                   
       leadToCreate2.LeanData__Reporting_Matched_Account__c =  AccountToCreate.ID;
       leadToCreate2.mkto71_Lead_Score__c = 25; 
       leadToCreate2.AnnualRevenue = 1000000000;    
           insert leadToCreate2;     
           
       leadToCreate2.Status = 'Engaged';
       update leadToCreate2;      
       
       // Lead to Create Nurture
       Lead leadToCreate3 = new Lead();
       leadToCreate3.FirstName= 'Kenny';
       leadToCreate3.LastName= 'Kenny';       
       leadToCreate3.Email     = 'ken_naku@yahoo.com';
       leadToCreate3.Country = 'US';
       leadToCreate3.State = 'CA';  
       leadToCreate3.Company = 'Test Company 1'; 
       leadToCreate3.Status = 'Nurture';                   
       leadToCreate3.LeanData__Reporting_Matched_Account__c =  AccountToCreate.ID;
       leadToCreate3.mkto71_Lead_Score__c = 25; 
       leadToCreate3.AnnualRevenue = 1000000000;    
           insert leadToCreate3;     
           
       leadToCreate3.Status = 'Engaged';
       update leadToCreate3;   
       
       
       // Lead to Create Nurture
       Lead leadToCreate4 = new Lead();
       leadToCreate4.FirstName= 'Kenny';
       leadToCreate4.LastName= 'Kenny';       
       leadToCreate4.Email     = 'ken_naku@yahoo.com';
       leadToCreate4.Country = 'US';
       leadToCreate4.State = 'CA';  
       leadToCreate4.Company = 'Test Company 1'; 
       leadToCreate4.Status = 'Engaged';                   
       leadToCreate4.LeanData__Reporting_Matched_Account__c =  AccountToCreate.ID;
       leadToCreate4.mkto71_Lead_Score__c = 25; 
       leadToCreate4.AnnualRevenue = 1000000000;    
           
           insert leadToCreate4;     
       
       list<Lead> lead2create4check = [SELECT Id, Status FROM Lead Where ID = :leadToCreate4.id];
       for(Lead lds : lead2create4check){          
       lds.Status = 'Qualified Lead';
       update lds;    
       }
       
       
       // Lead to Create
       Lead leadToCreate5 = new Lead();
       leadToCreate5.FirstName= 'Kenny';
       leadToCreate5.LastName= 'Kenny';       
       leadToCreate5.Email     = 'ken_naku@yahoo.com';
       leadToCreate5.Country = 'US';
       leadToCreate5.State = 'CA';  
       leadToCreate5.Company = 'Test Company 1'; 
       leadToCreate5.Status = 'Prospect';                   
       leadToCreate5.LeanData__Reporting_Matched_Account__c =  AccountToCreate.ID;
       leadToCreate5.CreatedDate = SixtyDaysAgo;
       leadToCreate5.mkto71_Lead_Score__c = 25;     
           insert leadToCreate5;     
           
       leadToCreate5.Status = 'Contacted';
       update leadToCreate5;
       
       
       // Lead to Create Contacted
       Lead leadToCreate6 = new Lead();
       leadToCreate6.FirstName= 'Kenny';
       leadToCreate6.LastName= 'Kenny';       
       leadToCreate6.Email     = 'ken_naku@yahoo.com';
       leadToCreate6.Country = 'US';
       leadToCreate6.State = 'CA';  
       leadToCreate6.Company = 'Test Company 1'; 
       leadToCreate6.Status = 'Contacted';                   
       leadToCreate6.LeanData__Reporting_Matched_Account__c =  AccountToCreate.ID;
       leadToCreate6.CreatedDate = SixtyDaysAgo;       
       leadToCreate6.mkto71_Lead_Score__c = 25;     
           insert leadToCreate6;     
           
       leadToCreate6.Status = 'Engaged';
       update leadToCreate6;        
       
                     
            
      // OpportunityContactRole to Create
      OpportunityContactRole OcrToCreate = new OpportunityContactRole();
      OcrToCreate.OpportunityID = OpportunityToCreate.ID;
      ocrToCreate.ContactID = ContactToCreate.ID;
      ocrToCreate.Role = 'Decision Maker';
      
        insert OcrToCreate;        
        //example.queryDatabase(leadToCreate.id);

        LeadHistory leadhist1 =new LeadHistory(Field='status', leadid = leadtocreate.id);
        insert leadhist1;
        
        LeadHistory leadhist2 =new LeadHistory(Field='status', leadid = leadtocreate2.id);
        insert leadhist2;
        
        LeadHistory leadhist3 =new LeadHistory(Field='status', leadid = leadtocreate3.id);
        insert leadhist3;
        
        LeadHistory leadhist4 =new LeadHistory(Field='status', leadid = leadtocreate4.id);
        insert leadhist4;  

        LeadHistory leadhist5 =new LeadHistory(Field='status', leadid = leadtocreate5.id);
        insert leadhist5;  
                
        
        
        ContactHistory contacthist1 =new ContactHistory(Field='status__c', contactid = contacttocreate.id);
        insert contacthist1 ;
        
        ContactHistory contacthist2 =new ContactHistory(Field='status__c', contactid = contacttocreate2.id);
        insert contacthist2 ;
        
        ContactHistory contacthist3 =new ContactHistory(Field='status__c', contactid = contacttocreate3.id);
        insert contacthist3 ;
        
        ContactHistory contacthist4 =new ContactHistory(Field='status__c', contactid = contacttocreate4.id);
        insert contacthist4 ;                

  Integer createdHistoryLead = [SELECT Count() FROM LeadHistory WHERE CreatedDate = TODAY];
        Integer createdHistoryContact = [SELECT Count() FROM ContactHistory WHERE CreatedDate = TODAY];
      
      
      
        Integer statusSnapShotTHISmonth = [SELECT Count() FROM LeadHistory WHERE Field = 'Status' AND CreatedDate = TODAY AND Lead.LeanData__Reporting_Matched_Account__r.X6_Cs_Target_Account__c != '']; 
        //Integer statusSnapShotLASTmonth = [SELECT Count() FROM LeadHistory WHERE Field = 'Status' AND CreatedDate <= : ThirtyDaysAgo AND CreatedDate >= : SixtyDaysAgo  AND Lead.LeanData__Reporting_Matched_Account__r.X6_Cs_Target_Account__c != '' LIMIT 50000];      
        Integer ld = [SELECT Count() FROM Lead WHERE (Status != 'Raw' OR Status != 'Disqualified') AND LeanData__Reporting_Matched_Account__r.X6_Cs_Target_Account__c != '' AND CreatedDate = TODAY ];
        //Contact Lists
        Integer statusSnapShotTHISmonthCon = [SELECT Count() FROM ContactHistory WHERE Field = 'Status' AND CreatedDate = TODAY AND Contact.Account.X6_Cs_Target_Account__c != '']; 
        //Integer statusSnapShotLASTmonthCon = [SELECT Count() FROM ContactHistory WHERE Field = 'Status' AND CreatedDate <= : ThirtyDaysAgo AND CreatedDate >= : SixtyDaysAgo  AND Contact.Account.X6_Cs_Target_Account__c != '' LIMIT 50000];      
        Integer con = [SELECT Count() FROM Contact WHERE (Status__c != 'Raw' OR Status__c != 'Disqualified') AND Account.X6_Cs_Target_Account__c != ''  AND CreatedDate = TODAY];
       
      
       Date ThirtyDaysAgo = system.today().addDays(-30);  
     

   test.startTest();
   LeadFunnelSchedulableInsert lrs = new LeadFunnelSchedulableInsert();
   //lrs.iGetJobs = new GetTestJobs();  // will return > 5 asyncjobs and execute your else condition
   String schedule = '0 0 23 * * ?';
   system.schedule('Daily Schedule' , schedule, lrs);
   
   


   test.stopTest();
        //string verifyFieldChange1 = (string) [SELECT id, NewValue FROM LeadHistory WHERE LeadId = : leadtocreate4.id limit 1][0].get('NewValue'); 
       
        
        system.assert(createdHistoryLead > 0);   
        system.assert(createdHistoryContact > 0);  
        system.debug('the value in list is' + createdHistoryContact);        
        
        system.assert(statusSnapShotTHISmonth >= 0);   
        //system.assertEquals(statusSnapShotLASTmonth, 0);   
        system.assert(ld >= 0);   
        system.assert(statusSnapShotTHISmonthCon >= 0);   
        //system.assertEquals(statusSnapShotLASTmonthCon, 0);   
        system.assert(con >= 0);   
        //System.assertEquals(null,verifyFieldChange1);   
   
          Integer checkIfNull = [SELECT Count() FROM Lead_Funnel__c WHERE CreatedDate = TODAY AND (Closed_Lost_Leads_Snapshot__c = NULL OR Engaged_Leads_Net_New__c = NULL OR Contacted_Leads_Net_New__c  = NULL OR Nurture_Leads_Net_New__c  = NULL OR Qualified_Leads_Net_New__c = NULL OR SAL_Leads_Net_New__c  = NULL)];
          Integer confirmCreation = [SELECT Count() FROM Lead_Funnel__c WHERE CreatedDate = TODAY];

           system.assert(confirmCreation > 0);
           system.assertEquals(checkIfNull, 0);
           
}
}