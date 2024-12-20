public with sharing class LDTouchesforVFPIndividual{ 
        
        private final Opportunity opps;
        
        Public String oppType { get; set; }
                      
        public AggregateResult ListOfCamps2 { get; set; }

        public AggregateResult ListOfSalesTouch {get; set;}
        
        Public AggregateResult CampaignNamesWithTouches {get; set;}
         
        Public AggregateResult ContactnLeads {get; set;}
        
        Public LDTouchesforVFPIndividual[]CampaignTouches {get; set;}      
                
        Public AggregateResult closedWonVelocity2YEARS {get;set;}
        
        Public AggregateResult closedLostVelocity2YEARS {get;set;}    
        
        public AggregateResult salesVelocityCW  {get;set;}
       
        public AggregateResult salesVelocityCL  {get;set;}  
        
        Public Date dateToRefrence {get;set;}          
                
        Public LDTouchesforVFPIndividual(ApexPages.StandardController OpportunityAnalyzer) {
                this.OPPs = (Opportunity)OpportunityAnalyzer.getRecord();

                    dateToRefrence = system.today().addDays(-730);
        
    
        List<AggregateResult> CampaignNamesWithTouches = new LIST<AggregateResult> ();
        List<AggregateResult> ContactLeadTouches = new LIST<AggregateResult> ();
        
        oppType = (string) [SELECT Type FROM Opportunity WHERE ID = : Opps.ID][0].get('Type');
        

        ListOfSalesTouch = [SELECT SUM(LeanData__Contact__R.Total_sales_interactions__c) TotalSalesInteractions, SUM(LeanData__Contact__R.Number_of_Sales_Analyst_Engagements__c) AnalystEngagements,SUM(LeanData__Contact__R.Number_of_Sales_Meetings__c) SalesMeetings, SUM(LeanData__Contact__R.Number_of_Sales_Requests__c) SalesRequests,SUM(LeanData__Contact__R.Number_of_Sales_rfp__c) SalesRFP,SUM(LeanData__Contact__R.Number_of_Sales_Other_Tasks__c) SalesOther  FROM LeanData__Campaign_Opportunity__c WHERE LeanData__Opportunity__r.id = : Opps.ID];
        
                salesVelocityCW = [SELECT AVG(of_days_to_close__c) avgClosedWon FROM Opportunity WHERE StageName = 'Closed Won' AND CloseDate > : dateToRefrence AND Type = :oppType];
 
                
                salesVelocityCL = [SELECT AVG(of_days_to_close__c) avgClosedLost FROM Opportunity WHERE StageName = 'Closed Lost' AND CloseDate > : dateToRefrence AND Type = :oppType];
  
        
        CampaignNamesWithTouches = [SELECT LeanData__Campaign__R.Name CampName, Count(ID) NumberOfTouches,  Max(LeanData__Campaign__R.Channel__c) Channel, Max(LeanData__Campaign__R.type) Type FROM LeanData__Campaign_Opportunity__c WHERE LeanData__Opportunity__r.id = : Opps.ID GROUP BY LeanData__Campaign__R.Name ORDER BY Count(ID) DESC Limit 99];
        CampaignTouches = new List<LDTouchesforVFPIndividual>();
        for (AggregateResult arCamp : CampaignNamesWithTouches) {
            CampaignTouches.add(new LDTouchesforVFPIndividual(arCamp));
        }
        
        } 
 
    
    
    //Push Aggregate Campaign Data 
        Public Double NumberOfTouchesOnCamp {get; set;}
        Public String CampaignName {get; set;}
        Public String CampaignChannel {get;set;}
        Public String CampaignType {get;set;}

        public Double salesVelocityIndusryAvg {get;set;}
        Public Double thisOppDisplayTime {get;set;} 
  
        public LDTouchesforVFPIndividual(AggregateResult ar3) {
                    

                    NumberOfTouchesOnCamp = (double) ar3.get('NumberOfTouches');
                    CampaignName = (string) ar3.get('CampName');  
                    CampaignChannel = (string) ar3.get('Channel');
                    CampaignType = (string) ar3.get('type');
                     
                 
       
}
}