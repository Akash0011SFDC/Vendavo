global class accountLeadSnapShotBasedOpp implements Database.Batchable<sObject> {
	
	public String query = 'SELECT ID FROM Account';
	global accountLeadSnapShotBasedOpp() {
		
	}
	
	 global Database.QueryLocator start(Database.BatchableContext BC)
    {
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<Account> accs) {
    
     Date date18MonthsAgo = system.today().addMonths(-18);
	 list <OpportunityHistory> historylist;   
     list <Opportunity> opportunityInAccount;
     list <LeanData__Campaign_Opportunity__c> salesLastTouchesBeforeClose;
     list <LeanData__Campaign_Opportunity__c> masterTouchesList; 
     
      Boolean stage3OrMore = FALSE;


         // Oppertunity counter
         String currentOpportunity ='';
         Boolean stageM = FALSE;
         Datetime stageMCreateDate = null;

         list <AggregateResult> salesTouchesIntegers;
         Decimal totalSalesTouchOnOpp = 0;
         Decimal totalSalesTouchOnOpp180Days = 0;

         Integer salesTouchesIntegersSize = 0;

           //salestouch
         Datetime lastTouchSalesCloseDate = null;
      	 Date date180DaysAgo = system.today().addDays(-180);
      	 List<string> oppID;


      for(Account accs2Query : accs){
      	 //oppertunty
          currentOpportunity ='';
          stageM = FALSE;
          stageMCreateDate = null;

     //stage 3 or more
      stage3OrMore = FALSE;

      oppID = new List<string>();

  
        // Sales
        totalSalesTouchOnOpp = 0;
        totalSalesTouchOnOpp180Days = 0;

        salesTouchesIntegersSize = 0;

              //salestouch
       lastTouchSalesCloseDate = null;
        

      for(Opportunity oppz : opportunityInAccount = [  SELECT Id, AccountId,CloseDate,CreatedDate,StageName FROM Opportunity WHERE AccountID = : accs2query.id]){
           //Oppertunity check
           if(oppz.CloseDate > system.today() ){
                if(oppz.StageName.substring(0,1) == 'M'){
                  stageM = TRUE;
                  stageMCreateDate = oppz.CreatedDate;
                } else {
                  currentOpportunity = oppz.StageName;
                }
           }
          if(oppz.StageName.substring(0,1) == '3' || oppz.StageName.substring(0,1) == '4' || oppz.StageName.substring(0,1) == '5' || oppz.StageName.substring(0,1) == '6' ){
            stage3OrMore = TRUE;
           }

           oppID.add(oppz.Id);
       }
     
       if(!stage3OrMore){
         historylist  = [SELECT CreatedDate,Id,OpportunityId,StageName,SystemModstamp FROM OpportunityHistory WHERE OpportunityId in :oppID  AND CreatedDate >= :date18MonthsAgo AND ( StageName LIKE '3%' OR StageName LIKE '4%' OR StageName LIKE '5%' OR StageName LIKE '6%' ) ORDER BY CreatedDate ASC];
         if(historylist.size() != 0){
         	stage3OrMore = TRUE;
         }
      }
      salesTouchesIntegers = [SELECT LeanData__Contact__r.Id , Max(LeanData__Contact__r.Number_of_Sales_Requests__c) salesRequests, Max(LeanData__Contact__r.Number_of_Sales_Analyst_Engagements__c) salesAnalystEngagement, Max(LeanData__Contact__r.Number_of_Sales_rfp__c) salesRFPTouches, Max(LeanData__Contact__r.Number_of_Sales_Meetings__c) salesMeetingsTouches, Max(LeanData__Contact__r.Number_of_Sales_Other_Tasks__c) salesOtherTouch, Max(LeanData__Contact__r.Total_Sales_Interactions__c) totalSalesTouch FROM LeanData__Campaign_Opportunity__c WHERE LeanData__Opportunity__r.Id in :oppID AND LeanData__Contact__r.Total_Sales_Interactions__c != Null GROUP BY LeanData__Contact__r.Id];
      salesTouchesIntegersSize = salesTouchesIntegers.size() - 1;
      for(integer i = 0; i <= salesTouchesIntegersSize; i++){
            totalSalesTouchOnOpp += (double) salesTouchesIntegers[i].get('totalSalesTouch');
        }


       for(LeanData__Campaign_Opportunity__c lastSalesB4CLoseData : salesLastTouchesBeforeClose = [SELECT LeanData__Contact__r.Id, LeanData__Contact__r.Name , LeanData__Contact__r.Last_Sales_Touch_Date__c, LeanData__Contact__r.Last_Sales_Touch_Type__c, LeanData__Contact__r.Last_Sales_Touch_Subject__c  FROM  LeanData__Campaign_Opportunity__c WHERE LeanData__Opportunity__r.Id in :oppID ORDER BY LeanData__Contact__r.First_Sales_Touch_Date__c DESC]){             
          if(lastTouchSalesCloseDate == null || lastTouchSalesCloseDate < lastSalesB4CLoseData.LeanData__Contact__r.Last_Sales_Touch_Date__c ){
             lastTouchSalesCloseDate = lastSalesB4CLoseData.LeanData__Contact__r.Last_Sales_Touch_Date__c;  
          }
          if( lastSalesB4CLoseData.LeanData__Contact__r.Last_Sales_Touch_Date__c >= date180DaysAgo){
              totalSalesTouchOnOpp180Days++;
           }            
       }



	//sales touches
	accs2Query.Total_Number_of_Sales_Touches__c = totalSalesTouchOnOpp;
	accs2Query.Number_of_180_Days_Sales_Touches__c = totalSalesTouchOnOpp180Days;
	accs2query.Last_Sales_Touch_Date__c = lastTouchSalesCloseDate;
	//Current Oppertunity 

	accs2Query.Stage_M_Opportunity__c = stageM;
	accs2Query.Stage_M_Creation_Date__c = stageMCreateDate;
	accs2Query.Current_Opportunity__c = currentOpportunity;
	accs2Query.Stage_3_Or_More_in_the_Last_18_Months__c = stage3OrMore;
	}//end for account
 update accs;

	}
	
	global void finish(Database.BatchableContext BC) {
		
	}
	
}