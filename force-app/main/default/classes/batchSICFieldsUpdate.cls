global class batchSICFieldsUpdate implements Database.Batchable<sObject>
{
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        String query = 'SELECT ID FROM SIC__c';
        return Database.getQueryLocator(query);
    }
   
    global void execute(Database.BatchableContext BC, List<SIC__c> sics)
    {   
      for(SIC__c sics2update : sics){
     //Variables          
          //Account Variables
      Integer numberOfCustomers = 0;
      Integer numberOfProspects = 0;
      Integer numberOfPartners = 0;
      Integer numberOfPoolAccounts = 0;
      Integer totalCountOfAccs = 0;      
      Integer numberOfFortune500s = 0;
          //Lead Variables
      Integer numberOfQualifiedLeads = 0;
      Integer numberOfSQLs = 0;
      Integer numberOfSALs = 0;
      Integer numberOfNutureLeads = 0;
      Integer numberOfEngagedLeads = 0;
      Integer numberOfContactedLeads = 0;
          //Opportunity Variables
      Integer numberOfOpenDeals = 0;
      Integer numberofWonDeals = 0;
      Integer numberofLostDeals = 0;
      Decimal closedDealRevenue = 0;                             
      Decimal inFlightRevenue = 0;            
      Decimal avgSalesVelocity = 0;
          //Marketing Touch Variables 
      Integer numberOfWebinarTouches = 0;
      Integer numberOfEventTouches = 0;
      Integer numberOfEmailTouches = 0;
      Integer numberOfWebsiteTouches = 0;
      Integer numberOfAdvertisingTouches = 0;
      Integer numberOfTeleMarketingTouches = 0;
      Integer numberOfDirectMailTouches = 0;
          //Aggregate Results Variables 
      String mostEffectiveChannel_AT;
      String mostEffectiveCampaign_AT;
      String topSalesRepThisYear;
      String topGlobalRegion;

          //Object Lists & Aggregated Results List
          List<Account> accsWithSics = [SELECT Id, Type  FROM Account WHERE SIC_Code_Lookup__r.Id = : sics2update.id];
          List<Opportunity> listOppsType = [SELECT Opportunity.Id, Opportunity.StageName, Opportunity.CloseDate FROM Opportunity WHERE Account.SIC_Code_Lookup__r.Id = : sics2update.id];
          List<Lead> leadsWithSics = [SELECT ID, Status FROM Lead WHERE SIC_Code_Lookup__r.Id = : sics2update.id];          
          List<LeanData__Campaign_Opportunity__c> marketingTouches = [SELECT Id, LeanData__Campaign__r.Channel__c FROM LeanData__Campaign_Opportunity__c WHERE LeanData__Account__r.SIC_Code_Lookup__r.ID = : sics2update.id];
          List<AggregateResult> OppRev = [SELECT Sum(Opportunity.Amount) revenue FROM Opportunity WHERE Account.SIC_Code_Lookup__r.Id = : sics2update.id AND Opportunity.StageName = 'Closed Won'];
          List<AggregateResult> inFlightDollars = [SELECT Sum(Opportunity.Amount) revenue FROM Opportunity WHERE Account.SIC_Code_Lookup__r.Id = : sics2update.id AND Opportunity.StageName = 'Closed Won'];
          List<AggregateResult> numberOfF500 =  [SELECT COUNT_DISTINCT(Name) FROM Account WHERE Fortune_500__c != NULL AND SIC_Code_Lookup__r.ID = : sics2update.id];
          //AGG Variable Lists
          List<AggregateResult> mostEffectiveChannel_list = [SELECT Count(Id), LeanData__Campaign__r.Channel__c Channel FROM LeanData__Campaign_Opportunity__c WHERE LeanData__Account__r.SIC_Code_Lookup__r.ID = : sics2update.id GROUP BY LeanData__Campaign__r.Channel__c ORDER BY Count(Id) DESC LIMIT 1];  
          List<AggregateResult> mostEffectiveCamp_List = [SELECT Count(Id), LeanData__Campaign__r.Name CampName FROM LeanData__Campaign_Opportunity__c WHERE LeanData__Account__r.SIC_Code_Lookup__r.ID = : sics2update.id GROUP BY LeanData__Campaign__r.Name ORDER BY Count(Id) DESC LIMIT 1];
          List<AggregateResult> topSalesRep_YTD_List = [SELECT SUM(Amount), Owner.Name FROM Opportunity WHERE StageName = 'Closed Won' AND Account.SIC_Code_Lookup__r.ID = : sics2update.id AND  CloseDate >= THIS_YEAR GROUP BY Owner.Name  Order By Sum(Amount) DESC LIMIT 1];      
          List<AggregateResult> topGlobalRegion_List = [SELECT SUM(Amount), Account.Global_Region__c Region FROM Opportunity WHERE CloseDate >= THIS_YEAR AND StageName = 'Closed Won' AND Account.SIC_Code_Lookup__r.ID = : sics2update.id GROUP BY Account.Global_Region__c  Order By Sum(Amount) DESC LIMIT 1];       
          //Lists For Ranking 

                  //Most Effective Marketing Channel (All Time)
                  if(mostEffectiveChannel_list.isEmpty()){
                      mostEffectiveChannel_AT = 'none';
                  }else{
                      mostEffectiveChannel_AT = (String) [SELECT Count(Id), LeanData__Campaign__r.Channel__c Channel FROM LeanData__Campaign_Opportunity__c WHERE LeanData__Account__r.SIC_Code_Lookup__r.ID = : sics2update.id GROUP BY LeanData__Campaign__r.Channel__c ORDER BY Count(Id) DESC][0].get('Channel');
                  }                 
                  //Most Effective Marketing Campaign (ALL Time)
                  if(mostEffectiveCamp_List.isEmpty()){
                      mostEffectiveCampaign_AT = 'None';
                  }else{
                      mostEffectiveCampaign_AT = (String) [SELECT Count(Id), LeanData__Campaign__r.Name CampName FROM LeanData__Campaign_Opportunity__c WHERE LeanData__Account__r.SIC_Code_Lookup__r.ID = : sics2update.id GROUP BY LeanData__Campaign__r.Name ORDER BY Count(Id) DESC][0].get('CampName');                     
                  }
                  //Top Sales Representative in Indusry (This Year)
                  if(topSalesRep_YTD_List.isEmpty()){
                      topSalesRepThisYear = 'None';
                  }else{
                      topSalesRepThisYear = (String) [SELECT SUM(Amount), Owner.Name Name FROM Opportunity WHERE StageName = 'Closed Won' AND Account.SIC_Code_Lookup__r.ID = : sics2update.id AND  CloseDate >= THIS_YEAR GROUP BY Owner.Name  Order By Sum(Amount) DESC][0].get('Name');
                  }
                  //Top Global Region 
                  if(topGlobalRegion_List.isEmpty()){
                      topGlobalRegion = 'None';
                  }else{          
                      topGlobalRegion = (String) [SELECT SUM(Amount), Account.Global_Region__c Region FROM Opportunity WHERE CloseDate >= THIS_YEAR AND StageName = 'Closed Won' AND Account.SIC_Code_Lookup__r.ID = : sics2update.id GROUP BY Account.Global_Region__c  Order By Sum(Amount) DESC LIMIT 1][0].get('Region');
                  }
                     


        //Accounts For Loop. Counts Number of Accounts By Type 
      
            for(Account accs2iterate : accsWithSics){
                if(accsWithSics.size() > 0){
                totalCountOfAccs++;
              if(accs2iterate.Type =='Customer'){
                numberOfCustomers++;
              }
              if(accs2iterate.Type == 'Prospect'){
                numberOfProspects++;
              }
              if(accs2iterate.Type == 'Partner'){
                numberOfPartners++;
              }
              if(accs2iterate.Type == 'Pool Account'){
                numberOfPoolAccounts++;
              }              
                }
            }
    
     //For loop to update Opportunty related Integers 

            for(Opportunity oppsInSic : listOppsType ){
             if(listOppsType.size() > 0){ 
              if(oppsInSic.StageName == 'Closed Won'){
                  numberofWonDeals++;                                  
              }
              if(oppsInSic.StageName == 'Closed Lost'){
                 numberofLostDeals++;
              }
              if(oppsInSic.StageName != 'Closed Lost' || oppsInSic.StageName != 'Closed Won' || oppsInSic.StageName != 'Disqualified'){
                  numberofOpenDeals++;
              }
              }
            }

     //Marketing Touches from LeanData
 
            for(LeanData__Campaign_Opportunity__c touchCount : marketingTouches){
              if(!marketingTouches.isEmpty() ){
              if(touchCount.LeanData__Campaign__r.Channel__c == 'Webinar'){
                numberOfWebinarTouches++;
              }
              if(touchCount.LeanData__Campaign__r.Channel__c == 'Email'){
                numberOfEmailTouches++;
              }
              if(touchCount.LeanData__Campaign__r.Channel__c == 'Advertising'){
                numberOfAdvertisingTouches++;
              }
              if(touchCount.LeanData__Campaign__r.Channel__c == 'Events'){
                numberOfEventTouches ++;
              }
              if(touchCount.LeanData__Campaign__r.Channel__c == 'Website'){
                numberOfWebsiteTouches++;
              }
              if(touchCount.LeanData__Campaign__r.Channel__c == 'Telemarketing'){
                numberOfTelemarketingTouches++;
              }
              if(touchCount.LeanData__Campaign__r.Channel__c == 'Direct Mail'){
                numberOfDirectMailTouches++;
              }
              }                                                                                    
            } 


          //Lead Variable Updates
            for(Lead industryLeads : leadsWithSics){
              if(industryLeads.Status == 'Qualified Lead'){
                numberOfQualifiedLeads++;
              }
              if(industryLeads.Status == 'Nurture'){
                numberOfNutureLeads++;
              }
              if(industryLeads.Status == 'SQL'){
                numberOfSQLs++;
              }
              if(industryLeads.Status ==  'Contacted'){
                numberOfContactedLeads++;
              }
              if(industryLeads.Status == 'SAL'){
                numberOfSALs++;
              }
              if(industryLeads.Status == 'Prospect'){
                numberOfProspects++;
              }                            
            }

            if(OppRev != NULL){
                closedDealRevenue = (Decimal) [SELECT Sum(Opportunity.Amount) revenue FROM Opportunity WHERE Account.SIC_Code_Lookup__r.Id = : sics2update.id AND Opportunity.StageName = 'Closed Won'][0].get('revenue');                  
            } 
            if(inFlightDollars != NULL){
                inFlightRevenue = (Decimal) [SELECT Sum(Opportunity.Amount) revenue FROM Opportunity WHERE Account.SIC_Code_Lookup__r.Id = : sics2update.id AND (Opportunity.StageName != 'Closed Won' OR Opportunity.StageName != 'Closed Lost' OR Opportunity.StageName != 'Disqualified' OR Opportunity.StageName != '1 - Identify Initiatives')][0].get('revenue'); 
            } 
            if(numberOfF500 != NULL){
                numberOfFortune500s = (Integer) [SELECT COUNT_DISTINCT(Name) f500 FROM Account WHERE Fortune_500__c != NULL AND SIC_Code_Lookup__r.ID = : sics2update.id][0].get('f500');             
            }                 
                              
         //SIC Object Custom Field Updates
              sics2update.Most_Effect_Marketing_Channel_All_Time__c = MostEffectiveChannel_AT;
              sics2update.Top_Sales_Representative__c = topSalesRepThisYear;
              sics2update.Top_Global_Region__c = topGlobalRegion;
              sics2update.Number_Of_Fortune_500_Accounts__c = numberOfFortune500s;
              sics2update.Closed_Deal_Revenue__c = closedDealRevenue;
              sics2update.Number_of_Open_Deals__c = numberOfOpenDeals;
              sics2update.Number_of_Lost_Deals__c = numberOfLostDeals;
              sics2update.Number_of_Won_Deals__c = numberOfWonDeals;
              sics2update.Number_Of_Customers__c = numberOfcustomers;
              sics2update.Number_of_Partner_Accounts__c = numberOfPartners;
              sics2update.Number_of_Prospect_Account__c = numberOfProspects;
              sics2update.In_Flight_Revenue__c = inFlightRevenue;
              sics2update.Number_of_Webinar_touches__c = numberOfWebinarTouches;
              sics2update.Number_of_Event_touches__c = numberOfEventTouches;
              sics2update.Number_of_Direct_Mail_Touches__c = numberOfDirectMailTouches;
              sics2update.Number_of_Advertising_Touches__c = numberOfAdvertisingTouches;
              sics2update.Number_of_Email_touches__c = numberOfEmailTouches;
              sics2update.Number_of_website_touches__c = numberOfWebsiteTouches;
              sics2update.Number_of_telemarketing_touches__c = numberOfTelemarketingTouches;
              sics2update.Number_Of_Qualified_Leads__c = numberOfQualifiedLeads;
              sics2update.Number_Of_Contacted_Leads__c = numberOfContactedLeads;
              sics2update.Number_Of_Engaged_Leads__c = numberOfEngagedLeads;
              sics2update.Number_Of_SAL_Leads__c = numberOfSALs;
              sics2update.Number_Of_SQL_Leads__c = numberOfSQLs;
              sics2update.Top_Campaign_All_Time__c = mostEffectiveCampaign_AT;
              update sics;
      }
     
    }   
    global void finish(Database.BatchableContext BC)
    {
    }
}