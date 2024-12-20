global class LeadFunnelFromAccSchedulableInsert Implements Schedulable{




global void execute(SchedulableContext sc) {


         Integer sizeOfTheList = 0;
         String funnelName = 'Aggregate Lead Funnel: ' + Date.today(); 
         Decimal qualifiedNOW = 0;
         Decimal engagedNow = 0; 
         Decimal contactedNow = 0;
         Decimal nurtureNow = 0;
         Decimal sqlNow = 0;
         Decimal salNow = 0;
         Decimal prospectNow = 0;  
         Decimal opportunityNow = 0;  
        
         Integer ClosedLostNow = 0;         
         Integer ClosedWonNow = 0;         




        //New Value: How many transitioned in                         
         Decimal qualifiedNewValue = 0;
         Decimal engagedNewValue = 0; 
         Decimal contactedNewValue = 0;
         Decimal nurtureNewValue = 0;
         Decimal sqlNewValue = 0;
         Decimal salNewValue = 0; 
         Decimal prospectNewValue = 0;
         Decimal opportunityNewValue = 0;
         Decimal closedWonNewValue = 0;
         Decimal closedLostNewValue = 0;


        //Old Values: how many transitioned out
         Decimal qualifiedOldValue = 0;
         Decimal engagedOldValue = 0; 
         Decimal contactedOldValue = 0;
         Decimal nurtureOldValue = 0;
         Decimal sqlOldValue = 0;
         Decimal salOldValue = 0; 
         Decimal prospectOldValue = 0;    
         Decimal opportunityOldValue = 0;    
         Decimal closedWonOldValue = 0;    
         Decimal closedLostOldValue = 0;    

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
         Decimal listSizeToReference = 0;

  list<AggregateResult> masterAccountList  = [SELECT SUM(Net_New_Contacted_Leads__c) netnewContacted,SUM(Transitioned_Contacted_Leads__c) transitionedContacted,SUM(Happy_Path_transition_Engaged__c) happypathEngaged,SUM(Happy_Path_transition_Contacted__c) happyPathContacted,SUM(Net_New_Engaged_Leads__c) netNewEngaged,SUM(Snapshot_Qualified_Leads__c) snapshotQualified,SUM(Snapshot_Engaged_Leads__c) snapshotEngaged,SUM(Snapshot_Contacted_Leads__c) snapshotContacted,SUM(Snapshot_Nurture_Leads__c) snapshotNurture,SUM(Snapshot_SQL_Leads__c) snapshotSQL,SUM(Snapshot_SAL_Leads__c) snapshotSAL,SUM(Snapshot_Prospect_Leads__c) snapshotProspect,SUM(Transitioned_Prospect_Leads__c) transitionedProspect,SUM(Transitioned_Nurture_Leads__c) transitionedNurture,SUM(Transitioned_SQL_Leads__c) transitionedSQL,SUM(Transitioned_SAL_Leads__c) transitionedSAL,SUM(Transitioned_Qualified_Leads__c) transitionedQualified, SUM(Transitioned_Engaged_Leads__c)transitionedEngaged ,SUM(Net_New_Prospect_Leads__c) netNewProspect,SUM( Net_New_Nurture_Leads__c) netNewNurture,SUM(Net_New_SQL_Leads__c) netNewSQL,SUM(Net_New_SAL_Leads__c) netNewSAL ,SUM(Net_New_Qualified_Leads__c) netNewQualified ,SUM(Happy_Path_transition_Prospect__c) happyPathProspect,SUM(Happy_Path_transition_Nurture__c) happyPathNurture ,SUM(Happy_Path_transition_SQL__c) happyPathSQL,SUM(Happy_Path_transition_SAL__c) happyPathSAL,SUM(Happy_Path_transition_Qualified__c) happyPathQualified  FROM Account WHERE Happy_Path_transition_Qualified__c != NULL];             

//List<Account> masterAccountList; 

    //integer countofAccs = [SELECT Count() FROM Account WHERE Happy_Path_transition_Qualified__c != NULL];
       //for(integer i = 0; i <= countofAccs - 1; i++){
//Snapshot of Leads            
            qualifiedNOW += (double) masterAccountList[0].get('snapshotQualified');
            prospectNow += (double) masterAccountList[0].get('snapshotProspect');
            salNow += (double) masterAccountList[0].get('snapshotSAL');
            sqlNow += (double) masterAccountList[0].get('snapshotSQL');
            nurtureNow += (double) masterAccountList[0].get('snapshotNurture');
            contactedNow += (double) masterAccountList[0].get('snapshotContacted');
            engagedNow += (double) masterAccountList[0].get('snapshotEngaged');
   // }
                                                        

       //for(integer i = 0; i <= countofAccs - 1; i++){
//Transitioned
            qualifiedOldValue+= (double) masterAccountList[0].get('transitionedQualified');
            prospectOldValue+= (double) masterAccountList[0].get('transitionedProspect');
            salOldValue+= (double) masterAccountList[0].get('transitionedSAL');
            sqlOldValue+= (double) masterAccountList[0].get('transitionedSQL');
            nurtureOldValue+= (double) masterAccountList[0].get('transitionedNurture');
            contactedOldValue+= (double) masterAccountList[0].get('transitionedContacted');
            engagedOldValue+= (double) masterAccountList[0].get('transitionedEngaged');  
    //}

      // for(integer i = 0; i <= countofAccs - 1; i++){
//Net New Leads
            qualifiedNewValue+= (double) masterAccountList[0].get('netNewQualified');
            prospectNewValue+= (double) masterAccountList[0].get('netNewProspect');
            salNewValue+= (double) masterAccountList[0].get('netNewSAL');
            sqlNewValue+= (double) masterAccountList[0].get('netNewSQL');
            nurtureNewValue+= (double) masterAccountList[0].get('netNewNurture');
            contactedNewValue+= (double) masterAccountList[0].get('netnewContacted');
            engagedNewValue+= (double) masterAccountList[0].get('netNewEngaged');  
    //}                                                        

     //  for(integer i = 0; i <= countofAccs - 1; i++){
//Happy Path Transitioned 
            happyPath_Trans_ScoreQualified+= (double) masterAccountList[0].get('happyPathQualified');
            happyPath_Trans_ScoreProspect+= (double) masterAccountList[0].get('happyPathProspect');
            happyPath_Trans_ScoreSAl+= (double) masterAccountList[0].get('happyPathSAL');
            happyPath_Trans_ScoreSQL+= (double) masterAccountList[0].get('happyPathSQL');
            happyPath_Trans_ScoreNurture+= (double) masterAccountList[0].get('happyPathNurture');
            happyPath_Trans_ScoreContacted+= (double) masterAccountList[0].get('happyPathContacted');
            happyPath_Trans_ScoreEngaged+= (double) masterAccountList[0].get('happypathEngaged');
   // }    
            

          Date ThirtyDaysAgo = system.today().addDays(-30);  
          Date SixtyDaysAgo = system.today().addDays(-60);

      
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