public with sharing class leadFunnelAggcontroller{
        
        public string [] timeframe;
        // Current Snapshot 

        public Integer qualifiedNOW {get; set;}
        public Integer engagedNow {get; set;} 
        public Integer contactedNow {get; set;}
        public Integer nurtureNow {get; set;}
        public Integer sqlNow {get; set;}
        public Integer salNow {get; set;}
        public Integer prospectNow {get; set;}  
        public Integer opportunityNow {get; set;}  
        //Starting Balance        
        public Integer qualifiedStartMonth {get; set;} 
        public Integer engagedStartMonth {get; set;} 
        public Integer contactedStartMonth {get; set;}
        public Integer nurtureStartMonth {get; set;}
        public Integer sqlStartMonth {get; set;}
        public Integer salStartMonth {get; set;}
        public Integer prospectStartMonth {get; set;}
        public Integer opportunityStartMonth {get; set;}


        //New Value: How many transitioned in                         
        public Integer qualifiedNewValue {get; set;}
        public Integer engagedNewValue {get; set;} 
        public Integer contactedNewValue {get; set;}
        public Integer nurtureNewValue {get; set;}
        public Integer sqlNewValue {get; set;}
        public Integer salNewValue {get; set;} 
        public Integer prospectNewValue {get; set;}
        public Integer opportunityNewValue {get; set;}

        //Old Values: how many transitioned out
        public Integer qualifiedOldValue {get; set;}
        public Integer engagedOldValue {get; set;} 
        public Integer contactedOldValue {get; set;}
        public Integer nurtureOldValue {get; set;}
        public Integer sqlOldValue {get; set;}
        public Integer salOldValue {get; set;} 
        public Integer prospectOldValue {get; set;}    
        public Integer opportunityOldValue {get; set;}    

        //Transitioned
        public Integer transitionProspect_Qualified {get; set;} 
        public Decimal ratio_Prospect_Qualified {get; set;}   
        public Integer transitionQualified_SAL {get; set;} 
        public Decimal ratio_Qualified_SAL {get; set;}
        public Integer transitionSAL_SQL {get; set;} 
        public Decimal ratio_SAL_SQL {get; set;}
        public Integer transitionSQL_Opportunity {get; set;} 
        public Decimal ratio_SQL_Opportunity {get; set;}
        //Avg Score By Status
        public Decimal avgScoreQualified {get; set;}
        public Decimal avgScoreEngaged {get; set;}
        public Decimal avgScoreContacted {get; set;}
        public Decimal avgScoreNurture {get; set;}
        public Decimal avgScoreSql {get; set;}
        public Decimal avgScoreSAL {get; set;}
        public Decimal avgScoreProspect {get; set;}
        //Happy Path Transition 
        public Decimal happyPath_Trans_ScoreQualified {get; set;}
        public Decimal happyPath_Trans_ScoreEngaged {get; set;}
        public Decimal happyPath_Trans_ScoreContacted {get; set;}
        public Decimal happyPath_Trans_ScoreNurture {get; set;}
        public Decimal happyPath_Trans_ScoreSql {get; set;}
        public Decimal happyPath_Trans_ScoreSAL {get; set;}
        public Decimal happyPath_Trans_ScoreProspect {get; set;}
        //Happy Path Transition Ratio 
        public Decimal happyPath_Ratio_ScoreQualified {get; set;}
        public Decimal happyPath_Ratio_ScoreEngaged {get; set;}
        public Decimal happyPath_Ratio_ScoreContacted {get; set;}
        public Decimal happyPath_Ratio_ScoreNurture {get; set;}
        public Decimal happyPath_Ratio_ScoreSql {get; set;}
        public Decimal happyPath_Ratio_ScoreSAL {get; set;}
        public Decimal happyPath_Ratio_ScoreProspect {get; set;}        

         Public Date ThirtyDaysAgo = system.today().addDays(-30);  
         Public Date SixtyDaysAgo = system.today().addDays(-60);
        
        
        public list<LeadHistory> statusSnapShotTHISmonth = [SELECT Id, NewValue, OldValue, CreatedDate, Field, Lead.Status FROM LeadHistory WHERE Field = 'Status' AND CreatedDate = LAST_N_DAYS:30 AND Lead.LeanData__Reporting_Matched_Account__r.X6_Cs_Target_Account__c != '' LIMIT 50000];
        public list<LeadHistory> statusSnapShotLASTmonth = [SELECT Id, NewValue, OldValue, CreatedDate, Field FROM LeadHistory WHERE Field = 'Status' AND CreatedDate <= : ThirtyDaysAgo AND CreatedDate >= : SixtyDaysAgo AND Lead.LeanData__Reporting_Matched_Account__r.X6_Cs_Target_Account__c != '' LIMIT 50000];


     

        public list<Lead> ld = [SELECT Id, Status FROM Lead WHERE (Status != 'Raw' OR Status != 'Disqualified') AND LeanData__Reporting_Matched_Account__r.X6_Cs_Target_Account__c != ''];
        public list<AggregateResult> avgLeadScorebyStatus;
        


        public void getLeadTallyResults() {



                      qualifiedNOW = 0;
                      engagedNow = 0; 
                      contactedNow = 0;
                      nurtureNow = 0;
                      sqlNow = 0;
                      salNow = 0;
                      prospectNow = 0;  
                      opportunityNow = 0;  
        //Starting Balance        
                      qualifiedStartMonth = 0;
                      engagedStartMonth = 0; 
                      contactedStartMonth = 0;
                      nurtureStartMonth = 0;
                      sqlStartMonth = 0;
                      salStartMonth = 0;
                      prospectStartMonth = 0;
                      opportunityStartMonth = 0;


        //Total within the Month                          
                      qualifiedNewValue = 0;
                      engagedNewValue = 0; 
                      contactedNewValue = 0;
                      nurtureNewValue = 0;
                      sqlNewValue = 0;
                      salNewValue = 0; 
                      prospectNewValue = 0;
                      opportunityNewValue = 0;

        //Old Values
                      qualifiedOldValue = 0;
                      engagedOldValue = 0; 
                      contactedOldValue = 0;
                      nurtureOldValue = 0;
                      sqlOldValue = 0;
                      salOldValue = 0; 
                      prospectOldValue = 0;    
                      opportunityOldValue = 0;    

        //Transitioned
                      transitionProspect_Qualified = 0; 
                      ratio_Prospect_Qualified = 0;   
                      transitionQualified_SAL = 0; 
                      ratio_Qualified_SAL = 0;
                      transitionSAL_SQL = 0; 
                      ratio_SAL_SQL = 0;
                      transitionSQL_Opportunity = 0; 
                      ratio_SQL_Opportunity = 0;
        //Avg Score By Status
                      avgScoreQualified = 0;
                      avgScoreEngaged = 0;
                      avgScoreContacted = 0;
                      avgScoreNurture = 0;
                      avgScoreSql = 0;
                      avgScoreSAL = 0;
                      avgScoreProspect = 0;


        //Happy Path Transition 
                      happyPath_Trans_ScoreQualified = 0;
                      happyPath_Trans_ScoreEngaged = 0;
                      happyPath_Trans_ScoreContacted = 0;
                      happyPath_Trans_ScoreNurture = 0;
                      happyPath_Trans_ScoreSql = 0;
                      happyPath_Trans_ScoreSAL = 0;
                      happyPath_Trans_ScoreProspect = 0;

        //Happy Path Transition Ratio 
                      happyPath_Ratio_ScoreQualified = 0;
                      happyPath_Ratio_ScoreEngaged = 0;
                      happyPath_Ratio_ScoreContacted = 0;
                      happyPath_Ratio_ScoreNurture = 0;
                      happyPath_Ratio_ScoreSql = 0;
                      happyPath_Ratio_ScoreSAL = 0;
                      happyPath_Ratio_ScoreProspect = 0;                        
        
          //avgLeadScorebyStatus ;
         //Avg Score by Status

                /**
                avgScoreQualified = (Decimal) [SELECT Avg(mkto2__Lead_Score__c) score FROM Lead WHERE status = 'Qualified Lead'][0].get('Score');
                avgScoreSQL = (Decimal) [SELECT Avg(mkto2__Lead_Score__c) score FROM Lead WHERE status = 'SQL'][0].get('Score');
                avgScoreSAL = (Decimal) [SELECT Avg(mkto2__Lead_Score__c) score FROM Lead WHERE status = 'SAL'][0].get('Score');
                avgScoreEngaged = (Decimal) [SELECT Avg(mkto2__Lead_Score__c) score FROM Lead WHERE status = 'Engaged'][0].get('Score');
                avgScoreContacted = (Decimal) [SELECT Avg(mkto2__Lead_Score__c) score FROM Lead WHERE status = 'Contacted'][0].get('Score');
                avgScoreNurture = (Decimal) [SELECT Avg(mkto2__Lead_Score__c) score FROM Lead WHERE status = 'Nurture'][0].get('Score');
                avgScoreEngaged = (Decimal) [SELECT Avg(mkto2__Lead_Score__c) score FROM Lead WHERE status = 'Engaged'][0].get('Score');
                avgScoreProspect = (Decimal) [SELECT Avg(mkto2__Lead_Score__c) score FROM Lead WHERE status = 'Prospect'][0].get('Score');
                */

        Integer prospectNow = 50;


        //Incrementing touches by status. Current and Historic 
        for(Lead leadz : ld){

          if(leadz.Status == 'qualified lead'){
              
              qualifiedNow++;
              

          }
          if(leadz.Status == 'engaged'){
              engagedNow++;
          }
          if(leadz.Status == 'Contacted'){
              contactedNow++;
          }     
          if(leadz.Status == 'Nurture'){
              nurtureNow++;
          }     
          if(leadz.Status == 'SQL'){
              sqlNow++;
          } 
          if(leadz.Status == 'Sal'){
              salNow++;
          }
          if(leadz.Status == 'Prospect'){
              prospectNow++;
          }
          
                      
          Date ThirtyDaysAgo = system.today().addDays(-30);  
          Date SixtyDaysAgo = system.today().addDays(-60);  
          
 
      //ending balance
      for(LeadHistory thisMonth : statusSnapShotTHISmonth){

              //Qualified Leads Through Out the Month
          if(thisMonth.NewValue == 'qualified lead'){
              qualifiedNewValue++;
          }
          if(thisMonth.NewValue == 'engaged'){
              engagedNewValue++;
          }
          if(thisMonth.NewValue == 'Contacted'){
              contactedNewValue++;
          }     
          if(thisMonth.NewValue == 'Nurture'){
              nurtureNewValue++;
          }     
          if(thisMonth.NewValue == 'SQL'){
              sqlNewValue++;
          } 
          if(thisMonth.NewValue == 'Sal'){
              salNewValue++;
          }
            //OLD VALUES Historical Leads
          if(thisMonth.OldValue == 'qualified lead'){
              qualifiedOldValue++;
          }
          if(thisMonth.OldValue == 'engaged'){
              engagedOldValue++;
          }
          if(thisMonth.OldValue == 'Contacted'){
              contactedOldValue++;
          }     
          if(thisMonth.OldValue == 'Nurture'){
              nurtureOldValue++;
          }     
          if(thisMonth.OldValue == 'SQL'){
              sqlOldValue++;
          } 
          if(thisMonth.OldValue == 'Sal'){
              salOldValue++;
          }                                    
          if(thisMonth.OldValue == 'Prospect'){
              prospectOldValue++;
          } 
                               
      }
      //Highlighted Transitions 
      transitionProspect_Qualified = prospectOldValue - qualifiedNewValue;
      if(transitionProspect_Qualified > 0){
      ratio_Prospect_Qualified = transitionProspect_Qualified/prospectOldValue; 
      }else{
        ratio_Prospect_Qualified = 0.00;
      }

      transitionQualified_SAL = qualifiedOldValue - salNewValue;
      if(transitionQualified_SAL > 0){
        ratio_Qualified_SAL = transitionQualified_SAL/qualifiedOldValue;
      }else{
        ratio_Qualified_SAL = 0.00;
      }

      transitionSAL_SQL = salOldValue - sqlNewValue;
      if(transitionSAL_SQL > 0){
        ratio_SAL_SQL = transitionSAL_SQL/salOldValue;
      }else{
        ratio_SAL_SQL = 0.00;
      }

      //Happy Path Transitions
    for(LeadHistory happyPath : statusSnapShotTHISmonth){ 
        //Nurture & Raw Happy Path Transitions 
        if(happyPath.OldValue == 'Nurture' || happyPath.NewValue == 'Raw' && (happyPath.NewValue == 'Prospect' || happyPath.NewValue == 'Engaged' || happyPath.NewValue == 'Contacted' || happyPath.NewValue == 'Qualified Lead' || happyPath.NewValue == 'SAL' || happyPath.NewValue == 'SQL' || happyPath.NewValue == 'Opportunity') ){
            happyPath_Trans_ScoreNurture++;
        } 
              //Ratio
              if(nurtureOldValue > 0 && happyPath_Trans_ScoreNurture > 0){
               happyPath_Ratio_ScoreNurture = (nurtureOldValue / happyPath_Trans_ScoreNurture) * 100;
             }
        //Prospect Happy Path Transitions
        if( happyPath.OldValue == 'Prospect' && (happyPath.NewValue == 'Engaged' || happyPath.NewValue == 'Contacted' || happyPath.NewValue == 'Qualified Lead' || happyPath.NewValue == 'SAL' || happyPath.NewValue == 'SQL' || happyPath.NewValue == 'Opportunity') ){
            happyPath_Trans_ScoreProspect++;
        } 
            //Ratio
            if(prospectOldValue > 0 && happyPath_Trans_ScoreProspect > 0){
              happyPath_Ratio_ScoreProspect = (prospectOldValue / happyPath_Trans_ScoreProspect) * 100;
            }
        //Engaged Happy Path Transitions 
        if( happyPath.OldValue == 'Engaged' && (happyPath.NewValue == 'Contacted' || happyPath.NewValue == 'Qualified Lead' || happyPath.NewValue == 'SAL' || happyPath.NewValue == 'SQL' || happyPath.NewValue == 'Opportunity') ){
            happyPath_Trans_ScoreEngaged++;
        }
            //Ratio
            if(engagedOldValue > 0 && happyPath_Trans_ScoreEngaged> 0){
              happyPath_Ratio_ScoreEngaged = (engagedOldValue / happyPath_Trans_ScoreEngaged) * 100;
            }           
        //Contacted Happy Path Transitions 
        if( happyPath.OldValue == 'Contacted' && (happyPath.NewValue == 'Qualified Lead' || happyPath.NewValue == 'SAL' || happyPath.NewValue == 'SQL' || happyPath.NewValue == 'Opportunity') ){
            happyPath_Trans_ScoreContacted++;
        } 
            //Ratio
            if(contactedOldValue > 0 && happyPath_Trans_Scorecontacted> 0){
              happyPath_Ratio_Scorecontacted = (contactedOldValue / happyPath_Trans_Scorecontacted) * 100;
            }         
        //Qualified Lead Happy Path Transitions
        if( happyPath.OldValue == 'Qualified Lead' && ( happyPath.NewValue == 'SAL' || happyPath.NewValue == 'SQL' || happyPath.NewValue == 'Opportunity') ){
            happyPath_Trans_ScoreQualified++;
        }  
            //Ratio
            if(qualifiedOldValue > 0 && happyPath_Trans_Scorequalified> 0){
              happyPath_Ratio_Scorequalified = (qualifiedOldValue / happyPath_Trans_Scorequalified) * 100;
            }           
        //SAL Happy Path Transitions 
        if( happyPath.OldValue == 'SAL' && ( happyPath.NewValue == 'SQL' || happyPath.NewValue == 'Opportunity') ){
            happyPath_Trans_ScoreSAL++;
        } 
            //Ratio
            if(salOldValue > 0 && happyPath_Trans_Scoresal> 0){
              happyPath_Ratio_Scoresal = (salOldValue / happyPath_Trans_Scoresal) * 100;
            }          
        //SQL Happy Path Transitions
        if( happyPath.OldValue == 'SQL' && (  happyPath.NewValue == 'Opportunity') ){
            happyPath_Trans_ScoreSQL++;
        } 
            //Ratio
            if(sqlOldValue > 0 && happyPath_Trans_Scoresql> 0){
              happyPath_Ratio_Scoresql = (sqlOldValue * happyPath_Trans_Scoresql) * 100;
            }                                                            
      }


      for(LeadHistory lastMonth : statusSnapShotLASTmonth){
          if(lastMonth.NewValue == 'qualified lead'){
              qualifiedStartMonth++;
          }
          if(lastMonth.NewValue == 'engaged'){
              engagedStartMonth++;
          }
          if(lastMonth.NewValue == 'Contacted'){
              contactedStartMonth++;
          }     
          if(lastMonth.NewValue == 'Nurture'){
              nurtureStartMonth++;
          }     
          if(lastMonth.NewValue == 'SQL'){
              sqlStartMonth++;
          } 
          if(lastMonth.NewValue == 'Sal'){
              salStartMonth++;
          }                         
      }
      
}


}

}