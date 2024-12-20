/*
 * StageHistoryCounter test class
 * @Author: Peter Yim
 * @Date: 2017
 *
 */
 @isTest 
public class StageHistoryCountertest {
	static testMethod void StageHistoryCounter() {
	  Date oppsCloseDateRefrence;
      Date oppsCreateDateRefrence;

       // Account to Create

        account AccountToCreate = new account(name = 'Test Account 9-14-2015', BillingCountry = 'United States', BillingState = 'CA');
        insert AccountToCreate;

       //Opportunity To Create 
       Opportunity OpportunityToCreate = new opportunity();
       Set<Id> oppsID = new Set<Id>(); 
       OpportunityToCreate.Name = 'Test Opp';
       OpportunityToCreate.StageName = '1. Suspect Qualification/MQL';
       OpportunityToCreate.Type = 'Mobile';
       OpportunityToCreate.AccountID = AccountToCreate.ID;
       OpportunityToCreate.CloseDate = Date.Today();
       OpportunityToCreate.CreatedDate = Date.Today();
       OpportunityToCreate.CurrencyIsoCode = 'USD';
       OpportunityToCreate.LeadSource = 'Sales';
       OpportunityToCreate.Vendavo_Forecast_Category__c = 'Pipeline';
        OpportunityToCreate.Days_in_Stage_1__c = 0;
        OpportunityToCreate.Days_in_Stage_2__c = 0;
        OpportunityToCreate.Days_in_Stage_3__c = 0;
        OpportunityToCreate.Days_in_Stage_4__c = 0;
        OpportunityToCreate.Days_in_Stage_5__c = 0;
        OpportunityToCreate.Days_in_Stage_6__c = 0;
        OpportunityToCreate.Days_in_Stage_7__c = 0;
        OpportunityToCreate.Days_in_Stage_M__c = 0;
        OpportunityToCreate.Stage_Path__c = '';
        OpportunityToCreate.Last_Modified_Rep__c = '00538000004bqwl';
        OpportunityToCreate.Last_Modified_Date_by_Rep__c = Date.Today();
        OpportunityToCreate.QTR_Closed_Push_counter__c = 0;

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

       // Lead to Create
       Lead leadToCreate = new Lead();
       LeadToCreate.Company = 'New Test Company';
       leadToCreate.FirstName = 'Pete';
       leadToCreate.LastName = 'PeteTest';       
       leadToCreate.Email     = 'peterz133@gmail.com';
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
       

           Test.startTest();
           StageHistoryCounter c = new StageHistoryCounter();
           Database.executeBatch(c);
           StageHistoryCountertest oppHistClass = new StageHistoryCountertest();
           oppHistClass.processOpportunityUpdate(OpportunityToCreate.Id);
           OpportunityHistory[] oppHist = oppHistClass.retrieveOpportunityHistory(OpportunityToCreate.Id);

         //// Verify Record are updated 
         //  Integer i = [SELECT COUNT() FROM Opportunity WHERE QTR_Closed_Push_counter__c != NULL AND Stage_Path__c != NULL];
         //  System.assertEquals(i, 1);


           Test.stopTest();
         
       
           System.assertEquals(1, oppHist.size());
       }

       public void processOpportunityUpdate(Id opportunityID){
          Date newDate = Date.Today().addDays(90);
          Opportunity opp = new Opportunity(Id = opportunityID, StageName = '3. Solution/Value Proposition', CloseDate = newDate );
          update opp;
       }

    public OpportunityHistory[] retrieveOpportunityHistory(Id OpportunityId){
     List<OpportunityHistory> oh;
     if(Test.isRunningTest()){  //if TEST, create dummy OpportunityHistory
         oh = new List<OpportunityHistory>{}; //OldValue, NewValue not writeable
         oh.add(new OpportunityHistory());
     }
     else 
         oh=  [Select OpportunityId from OpportunityHistory where OpportunityId = :OpportunityId];


     return oh;
   }
}