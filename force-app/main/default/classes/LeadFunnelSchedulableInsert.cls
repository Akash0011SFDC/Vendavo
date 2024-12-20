global class LeadFunnelSchedulableInsert Implements Schedulable{




global void execute(SchedulableContext sc) {

         String funnelName = 'Lead Funnel for:' + Date.today(); 
         Integer qualifiedNOW = 0;
         Integer engagedNow = 0; 
         Integer contactedNow = 0;
         Integer nurtureNow = 0;
         Integer sqlNow = 0;
         Integer salNow = 0;
         Integer prospectNow = 0;  
         Integer opportunityNow = 0;  
        
         Integer ClosedLostNow = 0;         
         Integer ClosedWonNow = 0;         




        //New Value: How many transitioned in                         
         Integer qualifiedNewValue = 0;
         Integer engagedNewValue = 0; 
         Integer contactedNewValue = 0;
         Integer nurtureNewValue = 0;
         Integer sqlNewValue = 0;
         Integer salNewValue = 0; 
         Integer prospectNewValue = 0;
         Integer opportunityNewValue = 0;
         Integer closedWonNewValue = 0;
         Integer closedLostNewValue = 0;


        //Old Values: how many transitioned out
         Integer qualifiedOldValue = 0;
         Integer engagedOldValue = 0; 
         Integer contactedOldValue = 0;
         Integer nurtureOldValue = 0;
         Integer sqlOldValue = 0;
         Integer salOldValue = 0; 
         Integer prospectOldValue = 0;    
         Integer opportunityOldValue = 0;    
         Integer closedWonOldValue = 0;    
         Integer closedLostOldValue = 0;    

        //Transitioned
         Integer transitionProspect_Qualified = 0; 
         Decimal ratio_Prospect_Qualified = 0;   
         Integer transitionQualified_SAL = 0; 
         Decimal ratio_Qualified_SAL = 0;
         Integer transitionSAL_SQL = 0; 
         Decimal ratio_SAL_SQL = 0;
         Integer transitionSQL_Opportunity = 0; 
         Decimal ratio_SQL_Opportunity = 0;
        //Avg Score By Status
         Decimal avgScoreQualified = 0;
         Decimal avgScoreEngaged = 0;
         Decimal avgScoreContacted = 0;
         Decimal avgScoreNurture = 0;
         Decimal avgScoreSql = 0;
         Decimal avgScoreSAL = 0;
         Decimal avgScoreProspect = 0;
         Decimal avgScoreClosedWon = 0;
         Decimal avgScoreClosedLost = 0;
        //Happy Path Transition 
         Decimal happyPath_Trans_ScoreQualified = 0;
         Decimal happyPath_Trans_ScoreEngaged = 0;
         Decimal happyPath_Trans_ScoreContacted = 0;
         Decimal happyPath_Trans_ScoreNurture = 0;
         Decimal happyPath_Trans_ScoreSql = 0;
         Decimal happyPath_Trans_ScoreSAL = 0;
         Decimal happyPath_Trans_ScoreProspect = 0;

               

          Date ThirtyDaysAgo = system.today().addDays(-30);  
          Date SixtyDaysAgo = system.today().addDays(-60);

    list<Lead> ld = [SELECT Id, Status FROM Lead WHERE (Status != 'Raw' OR Status != 'Disqualified') AND (LeanData__Reporting_Matched_Account__r.X6_Cs_Target_Account__c != NULL ) LIMIT 49999];  //OR Lead.AnnualRevenue >= 1000000000 OR Lead.AnnualRevenue >= 1000000000      
    list<Contact> con = [SELECT Id, Status__c FROM Contact WHERE (Status__c != 'Raw' OR Status__c != 'Disqualified')  AND (Account.X6_Cs_Target_Account__c != NULL )  LIMIT 40000];  // OR Account.AnnualRevenue >= 1000000000      
    list<LeadHistory> statusSnapShotTHISmonth = [SELECT Id, NewValue, OldValue, CreatedDate, Field, Lead.Status FROM LeadHistory WHERE Field = 'Status' AND (Lead.Status != 'Raw' OR Lead.Status != 'Disqualified') AND (Lead.LeanData__Reporting_Matched_Account__r.X6_Cs_Target_Account__c != NULL )  AND CreatedDate >= :ThirtyDaysAgo LIMIT 49999]; // OR Lead.AnnualRevenue >= 1000000000 OR Lead.AnnualRevenue >= 1000000000
    list<ContactHistory> statusSnapShotTHISmonthCon  = [SELECT Id, NewValue, OldValue, CreatedDate, Field, Contact.Status__c FROM ContactHistory WHERE Field = 'Status' AND (Contact.Status__c != 'Raw' OR Contact.Status__c != 'Disqualified')  AND (Contact.Account.X6_Cs_Target_Account__c != NULL )  AND CreatedDate >= :ThirtyDaysAgo LIMIT 49999]; //OR Contact.Account.AnnualRevenue >= 1000000000

        
        //Lead Lists
       //  list<LeadHistory> statusSnapShotLASTmonth = [SELECT Id, NewValue, OldValue, CreatedDate, Field FROM LeadHistory WHERE Field = 'Status' AND CreatedDate <= : ThirtyDaysAgo AND CreatedDate >= : SixtyDaysAgo AND LeadId IN : Ld LIMIT 50000];      
        //Contact Lists
       //  list<ContactHistory> statusSnapShotLASTmonthCon = [SELECT Id, NewValue, OldValue, CreatedDate, Field FROM ContactHistory WHERE Field = 'Status' AND CreatedDate <= : ThirtyDaysAgo AND CreatedDate >= : SixtyDaysAgo  AND ContactId IN : Con LIMIT 50000];      

         
                  
/*        
          //avgLeadScorebyStatus ;
         //Avg Score by Status

                avgScoreQualified = (Decimal) [SELECT Status,Avg(mkto2__Lead_Score__c) score FROM Lead WHERE status = 'Qualified Lead' GROUP BY Status LIMIT 49999][0].get('Score');
                    if(avgScoreQualified == NULL){
                        avgScoreQualified = 0;
                    } 
                avgScoreSQL = (Decimal) [SELECT Status,Avg(mkto2__Lead_Score__c) score FROM Lead WHERE status = 'SQL' GROUP BY Status LIMIT 49999][0].get('Score');
                    if(avgScoreSQL == NULL){
                    avgScoreSQL = 0;
                    }
                avgScoreSAL = (Decimal) [SELECT Status,Avg(mkto2__Lead_Score__c) score FROM Lead WHERE status = 'SAL' GROUP BY Status LIMIT 49999][0].get('Score');
                    if(avgScoreSAL == NULL){
                    avgScoreSAL = 0;
                    }
                avgScoreEngaged = (Decimal) [SELECT Status ,Avg(mkto2__Lead_Score__c) score FROM Lead WHERE status = 'Engaged' GROUP BY Status LIMIT 49999][0].get('Score');
                    if(avgScoreEngaged  == NULL){
                    avgScoreEngaged = 0;
                    }
                avgScoreContacted = (Decimal) [SELECT Status,Avg(mkto2__Lead_Score__c) score FROM Lead WHERE status = 'Contacted' GROUP BY Status LIMIT 49999][0].get('Score');
                    if(avgScoreContacted == NULL){
                    avgScoreContacted = 0;
                    }
                avgScoreNurture = (Decimal) [SELECT Status,Avg(mkto2__Lead_Score__c) score FROM Lead WHERE status = 'Nurture' GROUP BY Status LIMIT 49999][0].get('Score');
                    if(avgScoreNurture == NULL){
                    avgScoreNurture = 0;
                    }
                avgScoreEngaged = (Decimal) [SELECT Status,Avg(mkto2__Lead_Score__c) score FROM Lead WHERE status = 'Engaged' GROUP BY Status LIMIT 49999][0].get('Score');
                    if(avgScoreEngaged == NULL){
                    avgScoreEngaged = 0;
                    }
                avgScoreProspect = (Decimal) [SELECT Status,Avg(mkto2__Lead_Score__c) score FROM Lead WHERE status = 'Prospect' GROUP BY Status LIMIT 49999][0].get('Score');
                    if(avgScoreProspect == NULL){
                    avgScoreProspect = 0;
                    }
                avgScoreClosedWon = (Decimal) [SELECT Status,Avg(mkto2__Lead_Score__c) score FROM Lead WHERE status = 'Closed Won' GROUP BY Status LIMIT 49999][0].get('Score');
                    if(avgScoreClosedWon == NULL){
                    avgScoreClosedWon = 0;
                    }
                avgScoreClosedLost = (Decimal) [SELECT Status,Avg(mkto2__Lead_Score__c) score FROM Lead WHERE status = 'Closed Lost' GROUP BY Status LIMIT 49999][0].get('Score');
                    if(avgScoreClosedLost == NULL){
                    avgScoreClosedLost = 0;
                    }
               
*/


        //Incrementing touches by status. Current and Historic LEADS
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
       }   
           /**           
          Date ThirtyDaysAgo = system.today().addDays(-30);  
          Date SixtyDaysAgo = system.today().addDays(-60);  
          */
 
      //ending balance
      for(LeadHistory thisMonth : statusSnapShotTHISmonth ){

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
        //Nurture & Raw Happy Path Transitions 
        if(thisMonth.OldValue == 'Nurture' || thisMonth.NewValue == 'Raw' && (thisMonth.NewValue == 'Prospect' || thisMonth.NewValue == 'Engaged' || thisMonth.NewValue == 'Contacted' || thisMonth.NewValue == 'Qualified Lead' || thisMonth.NewValue == 'SAL' || thisMonth.NewValue == 'SQL' || thisMonth.NewValue == 'Closed Won') ){
            happyPath_Trans_ScoreNurture++;
        } 
             /*
              //Ratio
              if(nurtureOldValue > 0 && happyPath_Trans_ScoreNurture > 0){
               happyPath_Ratio_ScoreNurture = (nurtureOldValue / happyPath_Trans_ScoreNurture) * 100;
             }
             **/
        //Prospect Happy Path Transitions
        if( thisMonth.OldValue == 'Prospect' && (thisMonth.NewValue == 'Engaged' || thisMonth.NewValue == 'Contacted' || thisMonth.NewValue == 'Qualified Lead' || thisMonth.NewValue == 'SAL' || thisMonth.NewValue == 'SQL' || thisMonth.NewValue == 'Closed Won') ){
            happyPath_Trans_ScoreProspect++;
        } 
        /*
            //Ratio
            if(prospectOldValue > 0 && happyPath_Trans_ScoreProspect > 0){
              happyPath_Ratio_ScoreProspect = (prospectOldValue / happyPath_Trans_ScoreProspect) * 100;
            }
            **/
        //Engaged Happy Path Transitions 
        if( thisMonth.OldValue == 'Engaged' && (thisMonth.NewValue == 'Contacted' || thisMonth.NewValue == 'Qualified Lead' || thisMonth.NewValue == 'SAL' || thisMonth.NewValue == 'SQL' || thisMonth.NewValue == 'Closed Won') ){
            happyPath_Trans_ScoreEngaged++;
        }
            /*
            //Ratio
            if(engagedOldValue > 0 && happyPath_Trans_ScoreEngaged> 0){
              happyPath_Ratio_ScoreEngaged = (engagedOldValue / happyPath_Trans_ScoreEngaged) * 100;
            }   
            **/        
        //Contacted Happy Path Transitions 
        if( thisMonth.OldValue == 'Contacted' && (thisMonth.NewValue == 'Qualified Lead' || thisMonth.NewValue == 'SAL' || thisMonth.NewValue == 'SQL' || thisMonth.NewValue == 'Closed Won') ){
            happyPath_Trans_ScoreContacted++;
        } 
        /*
            //Ratio
            if(contactedOldValue > 0 && happyPath_Trans_Scorecontacted> 0){
              happyPath_Ratio_Scorecontacted = (contactedOldValue / happyPath_Trans_Scorecontacted) * 100;
            }   
            */      
        //Qualified Lead Happy Path Transitions
        if( thisMonth.OldValue == 'Qualified Lead' && ( thisMonth.NewValue == 'SAL' || thisMonth.NewValue == 'SQL' || thisMonth.NewValue == 'Closed Won') ){
            happyPath_Trans_ScoreQualified++;
        }  
        /*
            //Ratio
            if(qualifiedOldValue > 0 && happyPath_Trans_Scorequalified> 0){
              happyPath_Ratio_Scorequalified = (qualifiedOldValue / happyPath_Trans_Scorequalified) * 100;
            }  
            */         
        //SAL Happy Path Transitions 
        if( thisMonth.OldValue == 'SAL' && ( thisMonth.NewValue == 'SQL' || thisMonth.NewValue == 'Closed Won') ){
            happyPath_Trans_ScoreSAL++;
        } 
        /*
            //Ratio
            if(salOldValue > 0 && happyPath_Trans_Scoresal> 0){
              happyPath_Ratio_Scoresal = (salOldValue / happyPath_Trans_Scoresal) * 100;
            }  
            */        
        //SQL Happy Path Transitions
        if( thisMonth.OldValue == 'SQL' && (  thisMonth.NewValue == 'Closed Won') ){
            happyPath_Trans_ScoreSQL++;
        } 
        /*
            //Ratio
            if(sqlOldValue > 0 && happyPath_Trans_Scoresql> 0){
              happyPath_Ratio_Scoresql = (sqlOldValue * happyPath_Trans_Scoresql) * 100;
            }      
            */ 

                               
      }

/**     
      
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

*/ 








      //Contacts
for(Contact conz : con){

          if(conz.Status__c == 'qualified lead'){
              
              qualifiedNow++;
              

          }
          if(conz.Status__c == 'engaged'){
              engagedNow++;
          }
          if(conz.Status__c == 'Contacted'){
              contactedNow++;
          }     
          if(conz.Status__c == 'Nurture'){
              nurtureNow++;
          }     
          if(conz.Status__c == 'SQL'){
              sqlNow++;
          } 
          if(conz.Status__c == 'Sal'){
              salNow++;
          }
          if(conz.Status__c == 'Prospect'){
              prospectNow++;
          }
          
  }
          
 
      //ending balance
      for(ContactHistory thisMonth : statusSnapShotTHISmonthCon){

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
       //Nurture & Raw Happy Path Transitions 
        if(thisMonth.OldValue == 'Nurture' && (thisMonth.NewValue == 'Prospect' || thisMonth.NewValue == 'Engaged' || thisMonth.NewValue == 'Contacted' || thisMonth.NewValue == 'Qualified Lead' || thisMonth.NewValue == 'SAL' || thisMonth.NewValue == 'SQL' || thisMonth.NewValue == 'Closed Won') ){
            happyPath_Trans_ScoreNurture++;
        } 
        /*
              //Ratio
              if(nurtureOldValue > 0 && happyPath_Trans_ScoreNurture > 0){
               happyPath_Ratio_ScoreNurture = (nurtureOldValue / happyPath_Trans_ScoreNurture) * 100;
             }
             */
        //Prospect Happy Path Transitions
        if( thisMonth.OldValue == 'Prospect' && (thisMonth.NewValue == 'Engaged' || thisMonth.NewValue == 'Contacted' || thisMonth.NewValue == 'Qualified Lead' || thisMonth.NewValue == 'SAL' || thisMonth.NewValue == 'SQL' || thisMonth.NewValue == 'Closed Won') ){
            happyPath_Trans_ScoreProspect++;
        } 
        /*
            //Ratio
            if(prospectOldValue > 0 && happyPath_Trans_ScoreProspect > 0){
              happyPath_Ratio_ScoreProspect = (prospectOldValue / happyPath_Trans_ScoreProspect) * 100;
            }
            */
        //Engaged Happy Path Transitions 
        if( thisMonth.OldValue == 'Engaged' && (thisMonth.NewValue == 'Contacted' || thisMonth.NewValue == 'Qualified Lead' || thisMonth.NewValue == 'SAL' || thisMonth.NewValue == 'SQL' || thisMonth.NewValue == 'Closed Won') ){
            happyPath_Trans_ScoreEngaged++;
        }
        /*
            //Ratio
            if(engagedOldValue > 0 && happyPath_Trans_ScoreEngaged> 0){
              happyPath_Ratio_ScoreEngaged = (engagedOldValue / happyPath_Trans_ScoreEngaged) * 100;
            }
            */           
        //Contacted Happy Path Transitions 
        if( thisMonth.OldValue == 'Contacted' && (thisMonth.NewValue == 'Qualified Lead' || thisMonth.NewValue == 'SAL' || thisMonth.NewValue == 'SQL' || thisMonth.NewValue == 'Closed Won') ){
            happyPath_Trans_ScoreContacted++;
        } 
        /*
            //Ratio
            if(contactedOldValue > 0 && happyPath_Trans_Scorecontacted> 0){
              happyPath_Ratio_Scorecontacted = (contactedOldValue / happyPath_Trans_Scorecontacted) * 100;
            }    
            */     
        //Qualified Lead Happy Path Transitions
        if( thisMonth.OldValue == 'Qualified Lead' && ( thisMonth.NewValue == 'SAL' || thisMonth.NewValue == 'SQL' || thisMonth.NewValue == 'Closed Won') ){
            happyPath_Trans_ScoreQualified++;
        }  
        /*
            //Ratio
            if(qualifiedOldValue > 0 && happyPath_Trans_Scorequalified> 0){
              happyPath_Ratio_Scorequalified = (qualifiedOldValue / happyPath_Trans_Scorequalified) * 100;
            } 
            */          
        //SAL Happy Path Transitions 
        if( thisMonth.OldValue == 'SAL' && ( thisMonth.NewValue == 'SQL' || thisMonth.NewValue == 'Closed Won') ){
            happyPath_Trans_ScoreSAL++;
        } 
            /*
            //Ratio 
            if(salOldValue > 0 && happyPath_Trans_Scoresal> 0){
              happyPath_Ratio_Scoresal = (salOldValue / happyPath_Trans_Scoresal) * 100;
            } 
            */         
        //SQL Happy Path Transitions
        if( thisMonth.OldValue == 'SQL' && (  thisMonth.NewValue == 'Closed Won') ){
            happyPath_Trans_ScoreSQL++;
        } 
        /*
            //Ratio 
            if(sqlOldValue > 0 && happyPath_Trans_Scoresql> 0){
              happyPath_Ratio_Scoresql = (sqlOldValue * happyPath_Trans_Scoresql) * 100;
            } 
          */   

                               
      }
      /*
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
*/
 


      
 Lead_Funnel__c leadFunnelEntry = new Lead_Funnel__c(
Name = funnelName,
avgScoreClosedLost__c = avgScoreClosedLost,
avgScoreClosedWon__c = avgScoreClosedWon,
avgScoreContacted__c = avgScoreContacted,

avgScoreEngaged__c = avgScoreEngaged  ,
avgScoreNurture__c = avgScoreNurture,
avgScoreProspect__c = avgScoreProspect, 
avgScoreQualified__c = avgScoreQualified,
avgScoreSAL__c = avgScoreSAL, 
avgScoreSql__c = avgScoreSQL ,
Closed_Lost_Leads_Snapshot__c = ClosedLostNow,
Closed_Lost_Leads_Transitioned__c = ClosedLostOldValue,
Closed_Lost_Net_New__c = ClosedLostNewValue,
Closed_Won_Leads_Snapshot__c = ClosedWonNow,
Closed_Won_Net_New__c = ClosedWonNewValue,
Closed_Won_Transitioned__c = ClosedWonOldValue, 
Contacted_Leads_Net_New__c = ContactedNewValue,
Contacted_Leads_Now__c = ContactedNow,
Contacted_Leads_Transitioned__c = ContactedOldValue,
Engaged_Leads_Net_New__c = EngagedNewValue,
Engaged_Leads_Snapshot__c = EngagedNow,
Engaged_Leads_Transitioned__c = EngagedOldValue,
happyPath_Trans_Contacted__c = happyPath_Trans_ScoreContacted,
happyPath_Trans_Engaged__c = happyPath_Trans_ScoreEngaged,
happyPath_Trans_Nurture__c = happyPath_Trans_ScoreNurture,
happyPath_Trans_Prospect__c = happyPath_Trans_ScoreProspect,
happyPath_Trans_Qualified__c =  happyPath_Trans_ScoreQualified,
happyPath_Trans_SAL__c = happyPath_Trans_ScoreSAL,
happyPath_Trans_Sql__c  = happyPath_Trans_ScoreSQL,
Nurture_Leads_Net_New__c = NurtureNewValue,
Nurture_Leads_Snapshot__c = NurtureNow, 
Nurture_Leads_Transitioned__c = NurtureOldValue,
Prospect_Leads_Net_New__c = ProspectNewValue,
Prospect_Leads_Snapshot__c = ProspectNow,
Prospect_Leads_Transitioned__c = ProspectOldValue,
Qualified_Leads_Net_New__c = qualifiedNewValue, 
Qualified_Snapshot__c = qualifiedNow,
Qualified_Leads_Transitioned__c = qualifiedOldValue,
//ratio_Prospect_Qualified__c = 
SAL_Leads_Net_New__c = SALNewValue,
SAL_Leads_Snapshot__c = SALNow,
SAL_Leads_Transitioned__c = SALOldValue,
SQL_Leads_Net_New__c = SQLNewValue,
SQL_Leads_Snapshot__c = SQLNow,
SQL_Leads_Transitioned__c = SQLOldValue,
transitioned_Prospect_To_Qualified__c = transitionProspect_Qualified,
transitionQualified_SAL__c = transitionQualified_SAL,
transitionSAL_SQL__c = transitionSAL_SQL,
transitionSQL_Opportunity__c = transitionSQL_Opportunity 

 
 
 );

insert leadFunnelEntry;

}
}