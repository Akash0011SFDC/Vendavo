/*
 * accountLeadSnapShot is used to capture number of marketing touches by 18 months and 12 months,
 * Capture Vendavo Engagement Score (VES) per Account
 * Capture Lead Status progression by account
 * Roll up Value Consulting Data by Modified Date
 * Roll up Products from 360 to one field
 * @Author: Peter Yim
 * @Date: 2015
 * @Modified: Sept 9 2019
 */
 global class accountLeadSnapShot implements Database.Batchable<sObject>
{
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        String query = 'SELECT ID, Page_Visit_Last_30_Days__c FROM Account';
        return Database.getQueryLocator(query);
    }
   
    global void execute(Database.BatchableContext BC, List<Account> accs)
    {  
  //Lead Funnel     
         Integer rawNOW = 0;
         Integer disqualifedNOW = 0;
         Integer qualifiedNOW = 0;
         Integer engagedNow = 0; 
         Integer contactedNow = 0;
         Integer nurtureNow = 0;
         Integer sqlNow = 0;
         Integer salNow = 0;
         Integer prospectNow = 0;  
         Integer opportunityNow = 0;  
        
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



         Integer engagedLeadsNContacts30Days = 0;
         Integer engagedLeadNContactAllTime = 0; 
         Integer totalLeadsNContacts = 0;

         String mostRecentTouchCampaign;
         String mostRecentTouchType;
         String mostRecentTouchPerson;
         Date mostRecentTouchDate;
         Datetime mostRecentTouchDatetime;

         String mostRecentNonEmailTouchCampaign;
         String mostRecentNonEmailTouchType;
         String mostRecentNonEmailTouchPerson;
         Date mostRecentNonEmailTouchDate;
         Datetime mostRecentNonEmailTouchDatetime;
         Boolean mostRecentNonEmailTouch;

         Date date30DaysAgo = system.today().addDays(-30);
         
         // Oppertunity counter
         String currentOpportunity ='';
         Boolean stageM = FALSE;
         Datetime stageMCreateDate = null;

        //salestouch
         Datetime lastTouchSalesCloseDate = null;

 
// Touches By Type FINISH!!!!!!!!!!!!
     Integer webinarTouches = 0;
     Integer eventTouches = 0;
     Integer emailTouches = 0;
     Integer advertisingTouches = 0;
     Integer websiteTouches = 0;
     Integer telemarketingTouches = 0;
     Integer directMailTouches = 0;
     Integer contentSyndicationTouches = 0; 
     

     //180days
     //marketing touches
      Date date180DaysAgo = system.today().addDays(-180);
      Integer webinar180DaysTouches = 0;
      Integer event180DaysTouches = 0;
      Integer email180DaysTouches = 0;
      Integer advertising180DaysTouches = 0;
      Integer website180DaysTouches = 0;
      Integer telemarketing180DaysTouches = 0;
      Integer directMail180DaysTouches = 0;
     Integer contentSyndication180DaysTouches = 0; 

     //365days
     //marketing touches
      Date date365DaysAgo = system.today().addDays(-365);
      Integer webinar365DaysTouches = 0;
      Integer event365DaysTouches = 0;
      Integer email365DaysTouches = 0;
      Integer advertising365DaysTouches = 0;
      Integer website365DaysTouches = 0;
      Integer telemarketing365DaysTouches = 0;
      Integer directMail365DaysTouches = 0;
      Integer contentSyndication365DaysTouches = 0; 


    //18Months
     //marketing touches
      Integer webinar18MonthsTouches = 0;
      Integer event18MonthsTouches = 0;
      Integer email18MonthsTouches = 0;
      Integer advertising18MonthsTouches = 0;
      Integer website18MonthsTouches = 0;
      Integer telemarketing18MonthsTouches = 0;
      Integer directMail18MonthsTouches = 0;
      Integer contentSyndication18MonthsTouches = 0; 

      //engaged
       Integer totalEngagedLeads = 0;
       Integer totalEngagedContact = 0;  
       Integer totalEngaged180DaysLeads = 0;
       Integer totalEngaged180DaysContact = 0;
      
      //Scoring
       Double totalLeadsBehavorScore = 0;
       Double totalContactsBehavorScore = 0;
       Double totalLeadsDemographicScore = 0;
       Double totalContactsDemographicScore = 0;
       Double totalLeadsBehavorDemoScore = 0;
       Double totalContactsBehavorDemoScore = 0;
       Double totalLeadsContactsBehavorScore = 0;
       Double totalLeadsContactsDemographicScore = 0;
       Double totalLeadsContactsBehavorDemoScore = 0;

       //scoring to exclude raw and disqulified
       Double totalLeadsBehavorScoreRD = 0;
       Double totalContactsBehavorScoreRD = 0;
       Double totalLeadsDemographicScoreRD = 0;
       Double totalContactsDemographicScoreRD = 0;
       Double totalLeadsBehavorDemoScoreRD = 0;
       Double totalContactsBehavorDemoScoreRD = 0;
       Double totalLeadsContactsBehavorScoreRD = 0;
       Double totalLeadsContactsDemographicScoreRD = 0;
       Double totalLeadsContactsBehavorDemoScoreRD = 0;


        //Happy Path Transition 
         Decimal happyPath_Transition_Qualified = 0;
         Decimal happyPath_Transition_Engaged = 0;
         Decimal happyPath_Transition_Contacted = 0;
         Decimal happyPath_Transition_Nurture = 0;
         Decimal happyPath_Transition_Sql = 0;
         Decimal happyPath_Transition_SAL = 0;
         Decimal happyPath_Transition_Prospect = 0;     
    
         list <Lead> leadsInAccount;
         list <Contact> contactInAccount;
         list <Opportunity> opportunityInAccount;
         list <Kickfire__c> kickfireInAccount;

         list <LeanData__Marketing_Touch__c> salesLastTouchesBeforeClose;
         list <LeanData__Marketing_Touch__c> masterTouchesList; 
         list <LeadHistory> ldHistoryThisMonth; 
         list <ContactHistory> conHistoryThisMonth; 
           List<string> oppID;

         //sales touch
         list <AggregateResult> salesTouchesIntegers;
         Decimal totalSalesTouchOnOpp = 0;
         Decimal totalSalesTouchOnOpp180Days = 0;

         Integer salesTouchesIntegersSize = 0;

      
         list<Account> updateTheseAccounts;

      Date date18MonthsAgo = system.today().addMonths(-18);
      list <OpportunityHistory> historylist;   
      Boolean stage3OrMore = FALSE;

      //Vendavo score
      Date date90DaysAgo = system.today().addDays(-90);

      Integer scoreStage3More = 0;
      Integer scoreHotLeads = 0;
      Integer scoreWarmLeads = 0;
      Integer scoreDemographics = 0;
      Integer scoreBehavior = 0;
      Integer scoreRecentTouch180 = 0;
      Integer scoreRecentTouch365 = 0;
      Integer scoreKeywords = 0;
      Integer scoreStageM = 0;
      Integer scoreKickfire = 0;
      Integer scoreVendavoScore = 0;



      Integer newVesScore = 0;
      String newVesScoreNotes ='';
      Integer activeLead = 0;

      Integer vesWebinar = 0;
      Integer vesResource = 0;
      Integer vesEvent = 0;

      Map<String,Integer> webinarName = new Map<String,Integer>();
      Map<String,Integer> resourceName = new Map<String,Integer>();
      Map<String,Integer> eventName = new Map<String,Integer>();


      Integer webinarCount = 0;
      Integer resourceCount = 0;
      Integer eventCount = 0;      

      Integer vesProductPageCount = 0;
      Integer vesPageCount = 0;
      Integer vesResourcePageCount = 0;

      //products Count Roll Up
      List<Product2> product = [SELECT Id,Name FROM Product2];    

      Map<String,String> productList = new Map<String,String>();
      List<Product_Inventory__c> acctProduct;
      String productSummary = '';  

      //Latest VC Data
      List<Value_Consulting_Metric__c> valueConsultingData;
      Double acctFullYearPlan = 0;
      Double acctFullYearRev = 0;
      Date   acctLatestMeasurementDate = null;
      Double acctYTDBenefits= 0;
      Double acctYTDPlan = 0;
      Double acctYTDRevenue = 0;
      Integer hasVCData = 0;



       if(product.size() != 0){
          for(Product2 sku : product){
            productList.put(sku.Id, sku.Name);
          }
        }
        

      
      for(Account accs2Query : accs){
          disqualifedNOW =0;
          rawNOW = 0;
          qualifiedNOW = 0;
          engagedNow = 0; 
          contactedNow = 0;
          nurtureNow = 0;
          sqlNow = 0;
          salNow = 0;
          prospectNow = 0;  
          opportunityNow = 0;
          engagedLeadsNContacts30Days = 0;
          engagedLeadNContactAllTime = 0; 
          totalLeadsNContacts = 0;
          
     webinarTouches = 0;
     eventTouches = 0;
     emailTouches = 0;
     advertisingTouches = 0;
     websiteTouches = 0;
     telemarketingTouches = 0;
     directMailTouches = 0;
     contentSyndicationTouches = 0;

     webinar180DaysTouches = 0;
     event180DaysTouches = 0;
     email180DaysTouches = 0;
     advertising180DaysTouches = 0;
     website180DaysTouches = 0;
     telemarketing180DaysTouches = 0;
     directMail180DaysTouches = 0;
     contentSyndication180DaysTouches = 0; 
     
     //365
     webinar365DaysTouches = 0;
     event365DaysTouches = 0;
     email365DaysTouches = 0;
     advertising365DaysTouches = 0;
     website365DaysTouches = 0;
     telemarketing365DaysTouches = 0;
     directMail365DaysTouches = 0;
     contentSyndication365DaysTouches = 0; 

     //18 Months
     webinar18MonthsTouches = 0;
     event18MonthsTouches = 0;
     email18MonthsTouches = 0;
     advertising18MonthsTouches = 0;
     website18MonthsTouches = 0;
     telemarketing18MonthsTouches = 0;
     directMail18MonthsTouches = 0;
     contentSyndication18MonthsTouches = 0; 


     //engagement
     totalEngagedLeads = 0;
     totalEngagedContact = 0;  
     totalEngaged180DaysLeads = 0;
     totalEngaged180DaysContact = 0; 

        //Scoring
      totalLeadsBehavorScore = 0;
      totalContactsBehavorScore = 0;
      totalLeadsDemographicScore = 0;
      totalContactsDemographicScore = 0;
      totalLeadsBehavorDemoScore = 0;
      totalContactsBehavorDemoScore = 0;
      totalLeadsContactsBehavorScore = 0;
      totalLeadsContactsDemographicScore = 0;
      totalLeadsContactsBehavorDemoScore = 0;


      //scoring excluding raw and disqulified
       totalLeadsBehavorScoreRD = 0;
      totalContactsBehavorScoreRD = 0;
      totalLeadsDemographicScoreRD = 0;
      totalContactsDemographicScoreRD = 0;
      totalLeadsBehavorDemoScoreRD = 0;
      totalContactsBehavorDemoScoreRD = 0;
      totalLeadsContactsBehavorScoreRD = 0;
      totalLeadsContactsDemographicScoreRD = 0;
      totalLeadsContactsBehavorDemoScoreRD = 0;


        //Happy Path Transition 
          happyPath_Transition_Qualified = 0;
          happyPath_Transition_Engaged = 0;
          happyPath_Transition_Contacted = 0;
          happyPath_Transition_Nurture = 0;
          happyPath_Transition_Sql = 0;
          happyPath_Transition_SAL = 0;
          happyPath_Transition_Prospect = 0;   
          
        //oppertunty
          currentOpportunity ='';
          stageM = FALSE;
          stageMCreateDate = null;

     //stage 3 or more
      stage3OrMore = FALSE;


          
  //Lead Funnel     
          qualifiedNOW = 0;
          engagedNow = 0; 
          contactedNow = 0;
          nurtureNow = 0;
          sqlNow = 0;
          salNow = 0;
          prospectNow = 0;  
          opportunityNow = 0;  
//New Value: How many transitioned in                         
          qualifiedNewValue = 0;
          engagedNewValue = 0; 
          contactedNewValue = 0;
          nurtureNewValue = 0;
          sqlNewValue = 0;
          salNewValue = 0; 
          prospectNewValue = 0;
          opportunityNewValue = 0;
          closedWonNewValue = 0;
          closedLostNewValue = 0;
//Old Values: how many transitioned out
          qualifiedOldValue = 0;
          engagedOldValue = 0; 
          contactedOldValue = 0;
          nurtureOldValue = 0;
          sqlOldValue = 0;
          salOldValue = 0; 
          prospectOldValue = 0;    
          opportunityOldValue = 0;    
          closedWonOldValue = 0;    
          closedLostOldValue = 0;    

                
     
        // Sales
        totalSalesTouchOnOpp = 0;
        totalSalesTouchOnOpp180Days = 0;

        salesTouchesIntegersSize = 0;
     
              oppID = new List<string>();
      //salestouch
       lastTouchSalesCloseDate = null;
        
      //find most rescent;
      mostRecentNonEmailTouch = TRUE;
  

      //Vendavo score
      scoreStage3More = 0;
      scoreHotLeads = 0;
      scoreWarmLeads = 0;
      scoreDemographics = 0;
      scoreBehavior = 0;
      scoreRecentTouch180 = 0;
      scoreRecentTouch365 = 0;
      scoreKeywords = 0;
      scoreStageM = 0;
  
    //new ves score
     newVesScore = 0;
     newVesScoreNotes ='';
     activeLead = 0;
     vesWebinar = 0;
     vesResource = 0;
     vesEvent = 0;
    
     webinarName = new Map<String,Integer>();
     resourceName = new Map<String,Integer>();
     eventName = new Map<String,Integer>();

     webinarCount = 0;
     resourceCount = 0;
     eventCount = 0;     
     vesProductPageCount = 0;
     vesPageCount = 0;
     vesResourcePageCount = 0;
    //prdoduct
    productSummary = '';  

     acctFullYearPlan = 0;
     acctFullYearRev = 0;
     acctLatestMeasurementDate = null;
     acctYTDBenefits= 0;
     acctYTDPlan = 0;
     acctYTDRevenue = 0;
     hasVCData = 0;


          for(Lead ldz : leadsInAccount = [SELECT Id, Status, Behavior_Score__c, Demographic_Score__c FROM Lead WHERE Lead.LeanData__Reporting_Matched_Account__r.Id = : accs2query.id]){
            totalLeadsNContacts++;
            if(ldz.status == 'Qualified Lead'){
                qualifiedNOW++;
            }
            if(ldz.status == 'Contacted'){
                contactedNow++;
            }
            if(ldz.status == 'Nurture'){
                nurtureNow++;
            }
            if(ldz.status == 'Engaged'){
                engagedNow++;
            }
            if(ldz.status == 'Contacted'){
                contactedNow++;
            }
            if(ldz.status == 'Prospect'){
                prospectNow++;
            }
            if(ldz.status == 'SAL'){
                salNow++;
            }
            if(ldz.status == 'SQL'){
                sqlNow++;
            }
             if(ldz.status == 'Raw'){
                rawNow++;
            }
             if(ldz.status == 'Disqualifed'){
                disqualifedNOW++;
            }
            if(ldz.Behavior_Score__c != null){
              totalLeadsBehavorScore +=  ldz.Behavior_Score__c;
              
              if(ldz.status != 'Disqualifed' && ldz.status != 'Raw'){
                totalLeadsBehavorScoreRD +=  ldz.Behavior_Score__c;
              }


              //new VES
              if (ldz.Behavior_Score__c > 29){
                activeLead++;
              }
            } 
            if(ldz.Demographic_Score__c != null){
              totalLeadsDemographicScore += ldz.Demographic_Score__c;

               if(ldz.status != 'Disqualifed' && ldz.status != 'Raw'){
                totalLeadsDemographicScoreRD += ldz.Demographic_Score__c;
              }

            }




          }
          Integer calcSnapshotEngaged = contactedNow + qualifiedNOW + salNow + sqlNow;

          if(calcSnapshotEngaged  > 2){
            scoreHotLeads = 20;
          }
          if(calcSnapshotEngaged  == 2){
            scoreHotLeads = 15;
          }
          if(calcSnapshotEngaged  == 1){
            scoreHotLeads = 10;
          }

          totalLeadsBehavorDemoScore = totalLeadsBehavorScore + totalLeadsDemographicScore;
          totalLeadsBehavorDemoScoreRD = totalLeadsBehavorScoreRD + totalLeadsDemographicScoreRD;


          for(Contact conz : contactInAccount = [SELECT Id, Status__c, Behavior_Score__c, Demographic_Score__c FROM Contact WHERE AccountID = : accs2query.id]){
            totalLeadsNContacts++;

            if(conz.status__c == 'Qualified Lead'){
                qualifiedNOW++;
            }
            if(conz.status__c == 'Contacted'){
                contactedNow++;
            }
            if(conz.status__c == 'Nurture'){
                nurtureNow++;
            }
            if(conz.status__c == 'Engaged'){
                engagedNow++;
            }
            if(conz.status__c == 'Contacted'){
                contactedNow++;
            }
            if(conz.status__c == 'Prospect'){
                prospectNow++;
            }
            if(conz.status__c == 'SAL'){
                salNow++;
            }
            if(conz.status__c == 'SQL'){
                sqlNow++;
            }
            if(conz.status__c == 'Raw'){
                rawNow++;
            }
             if(conz.status__c == 'Disqualifed'){
                disqualifedNOW++;
            }
            if(conz.Behavior_Score__c != null){
              totalContactsBehavorScore +=  conz.Behavior_Score__c;
              if(conz.status__c != 'Raw' && conz.status__c != 'Disqualifed'){
                totalContactsBehavorScoreRD +=  conz.Behavior_Score__c;
              }

              //newVesScore
              if (conz.Behavior_Score__c > 19){
                activeLead++;
              }
            }
            if(conz.Demographic_Score__c != null){
              totalContactsDemographicScore += conz.Demographic_Score__c;
              if(conz.status__c != 'Raw' && conz.status__c != 'Disqualifed'){
                totalContactsDemographicScoreRD += conz.Demographic_Score__c;
              }
            }


          }

           Integer calcSnapshotProspect = prospectNow + nurtureNow;

          if(calcSnapshotProspect  > 2){
            scoreWarmLeads = 5;
          }
        

          totalContactsBehavorDemoScore = totalContactsBehavorScore + totalContactsDemographicScore;
          totalContactsBehavorDemoScoreRD = totalContactsBehavorScoreRD + totalContactsDemographicScoreRD;


          for(LeanData__Marketing_Touch__c  marketingTouches : masterTouchesList = [SELECT Id, LeanData__Campaign__r.channel__c, LeanData__Campaign_Member_Status__c, LeanData__Campaign__r.type, LeanData__Campaign__r.Name,LeanData__Campaign_Member_Created_Date__c, LeanData__Contact__r.Name, LeanData__Lead__r.Name   FROM LeanData__Marketing_Touch__c WHERE LeanData__Account__c = : accs2Query.id ORDER BY LeanData__Campaign_Member_Created_Date__c DESC]){
            engagedLeadNContactAllTime++;
            if(marketingTouches.LeanData__Campaign_Member_Created_Date__c >= date30DaysAgo){
            engagedLeadsNContacts30Days++;
            }
            mostRecentTouchCampaign = masterTouchesList[0].LeanData__Campaign__r.Name;
            mostRecentTouchPerson = masterTouchesList[0].LeanData__Lead__r.Name;
            if(mostRecentTouchPerson  == NULL){
                mostRecentTouchPerson = masterTouchesList[0].LeanData__Contact__r.Name;
            }
            mostRecentTouchDatetime = masterTouchesList[0].LeanData__Campaign_Member_Created_Date__c;
            if(mostRecentTouchDatetime != NULL){
              mostRecentTouchDate = date.newinstance(mostRecentTouchDatetime.year(), mostRecentTouchDatetime.month(), mostRecentTouchDatetime.day());

            }
            mostRecentTouchType = masterTouchesList[0].LeanData__Campaign__r.type;

            if(mostRecentNonEmailTouch && marketingTouches.LeanData__Campaign__r.channel__c != 'Email' && marketingTouches.LeanData__Campaign__r.type != 'Email Blast' && marketingTouches.LeanData__Campaign__r.type != 'Lead Lifecycle'){
              mostRecentNonEmailTouch = FALSE;
              mostRecentNonEmailTouchCampaign = marketingTouches.LeanData__Campaign__r.Name;
              mostRecentNonEmailTouchPerson = marketingTouches.LeanData__Lead__r.Name;
              if(mostRecentNonEmailTouchPerson  == NULL){
                  mostRecentNonEmailTouchPerson = marketingTouches.LeanData__Contact__r.Name;
              }
            mostRecentNonEmailTouchDatetime = marketingTouches.LeanData__Campaign_Member_Created_Date__c;
            if(mostRecentNonEmailTouchDatetime != NULL){
              mostRecentNonEmailTouchDate = date.newinstance(mostRecentNonEmailTouchDatetime.year(), mostRecentNonEmailTouchDatetime.month(), mostRecentNonEmailTouchDatetime.day());
                            
            }

            mostRecentNonEmailTouchType = marketingTouches.LeanData__Campaign__r.type;

            }

            
            if(marketingTouches.LeanData__Campaign__r.type == 'Webinar'){
              webinarTouches++;
            }
            if(marketingTouches.LeanData__Campaign__r.channel__c == 'Events' || marketingTouches.LeanData__Campaign__r.type == 'Tradeshow'){
              eventTouches++;
            }
            if(marketingTouches.LeanData__Campaign__r.channel__c == 'Telemarketing'){
              telemarketingTouches++;
            }
            if(marketingTouches.LeanData__Campaign__r.channel__c == 'Email' || marketingTouches.LeanData__Campaign__r.type == 'Email Blast' || marketingTouches.LeanData__Campaign__r.channel__c == 'Direct Mail'){
              emailTouches++;
            }
            if(marketingTouches.LeanData__Campaign__r.channel__c == 'Website' || marketingTouches.LeanData__Campaign__r.type == 'Website Resource'){
              websiteTouches++;
            }
            if(marketingTouches.LeanData__Campaign__r.channel__c == 'Advertising'){
              advertisingTouches++;
             }   
            if(marketingTouches.LeanData__Campaign__r.channel__c == 'Content Syndication'){
              contentSyndicationTouches++;
             }     


             if(marketingTouches.LeanData__Campaign_Member_Created_Date__c >= date180DaysAgo){
              if(marketingTouches.LeanData__Campaign__r.type == 'Webinar'){
                webinar180DaysTouches++;
              }
              if(marketingTouches.LeanData__Campaign__r.channel__c == 'Events' || marketingTouches.LeanData__Campaign__r.type == 'Tradeshow'){
                event180DaysTouches++;
              }
              if(marketingTouches.LeanData__Campaign__r.channel__c == 'Telemarketing'){
                telemarketing180DaysTouches++;
              }
              if(marketingTouches.LeanData__Campaign__r.channel__c == 'Email' || marketingTouches.LeanData__Campaign__r.type == 'Email Blast' || marketingTouches.LeanData__Campaign__r.channel__c == 'Direct Mail'){
                email180DaysTouches++;
              }
              if(marketingTouches.LeanData__Campaign__r.channel__c == 'Website' || marketingTouches.LeanData__Campaign__r.type == 'Website Resource'){
                website180DaysTouches++;
              }
              if(marketingTouches.LeanData__Campaign__r.channel__c == 'Advertising'){
                advertising180DaysTouches++;
               }   
                if(marketingTouches.LeanData__Campaign__r.channel__c == 'Content Syndication'){
                contentSyndication180DaysTouches++;
               }  
             }    

             if(marketingTouches.LeanData__Campaign_Member_Created_Date__c >= date365DaysAgo){
              if(marketingTouches.LeanData__Campaign__r.type == 'Webinar'){
                webinar365DaysTouches++;

                //new ves
                if(marketingTouches.LeanData__Campaign_Member_Status__c != null && marketingTouches.LeanData__Campaign_Member_Status__c.contains('Attended') ){
                  if( marketingTouches.LeanData__Contact__r.Name != ''){
                    if ( ! webinarName.containsKey(marketingTouches.LeanData__Contact__r.Name) ){
                        webinarName.put(marketingTouches.LeanData__Contact__r.Name, webinarCount++);
                      }

                    } else {
                       if ( ! webinarName.containsKey(marketingTouches.LeanData__Lead__r.Name) ){
                        webinarName.put(marketingTouches.LeanData__Lead__r.Name, webinarCount++);
                        
                      }
                    }
                }


              }
              if(marketingTouches.LeanData__Campaign__r.channel__c == 'Events' || marketingTouches.LeanData__Campaign__r.type == 'Tradeshow'){
                event365DaysTouches++;
                 if( marketingTouches.LeanData__Contact__r.Name != ''){
                    if ( ! eventName.containsKey(marketingTouches.LeanData__Contact__r.Name) ){
                        eventName.put(marketingTouches.LeanData__Contact__r.Name, eventCount++);
                      }

                    } else {
                       if ( ! eventName.containsKey(marketingTouches.LeanData__Lead__r.Name) ){
                        eventName.put(marketingTouches.LeanData__Lead__r.Name, eventCount++);
                        
                      }
                    }
              }
              if(marketingTouches.LeanData__Campaign__r.channel__c == 'Telemarketing'){
                telemarketing365DaysTouches++;
              }
              if(marketingTouches.LeanData__Campaign__r.channel__c == 'Email' || marketingTouches.LeanData__Campaign__r.type == 'Email Blast' || marketingTouches.LeanData__Campaign__r.channel__c == 'Direct Mail' ){
                email365DaysTouches++;
              }
              if(marketingTouches.LeanData__Campaign__r.channel__c == 'Website' || marketingTouches.LeanData__Campaign__r.type == 'Website Resource'){
                website365DaysTouches++;
                 if( marketingTouches.LeanData__Contact__r.Name != ''){
                    if ( ! resourceName.containsKey(marketingTouches.LeanData__Contact__r.Name) ){
                        resourceName.put(marketingTouches.LeanData__Contact__r.Name, resourceCount++);
                      }

                    } else {
                       if ( ! resourceName.containsKey(marketingTouches.LeanData__Lead__r.Name) ){
                        resourceName.put(marketingTouches.LeanData__Lead__r.Name, resourceCount++);
                        
                      }
                    }
              }
              if(marketingTouches.LeanData__Campaign__r.channel__c == 'Advertising'){
                advertising365DaysTouches++;
               }   
                if(marketingTouches.LeanData__Campaign__r.channel__c == 'Content Syndication'){
                contentSyndication365DaysTouches++;
               }  
             }                                

             if(marketingTouches.LeanData__Campaign_Member_Created_Date__c >= date18MonthsAgo){
              if(marketingTouches.LeanData__Campaign__r.type == 'Webinar'){
                webinar18MonthsTouches++;
              }
              if(marketingTouches.LeanData__Campaign__r.channel__c == 'Events' || marketingTouches.LeanData__Campaign__r.type == 'Tradeshow'){
                event18MonthsTouches++;
              }
              if(marketingTouches.LeanData__Campaign__r.channel__c == 'Telemarketing'){
                telemarketing18MonthsTouches++;
              }
              if(marketingTouches.LeanData__Campaign__r.channel__c == 'Email' || marketingTouches.LeanData__Campaign__r.channel__c == 'Email Blast' || marketingTouches.LeanData__Campaign__r.channel__c == 'Direct Mail'){
                email18MonthsTouches++;
              }
              if(marketingTouches.LeanData__Campaign__r.channel__c == 'Website' || marketingTouches.LeanData__Campaign__r.channel__c == 'Website Resource'){
                website18MonthsTouches++;
              }
          
              if(marketingTouches.LeanData__Campaign__r.channel__c == 'Advertising'){
                advertising18MonthsTouches++;
               }   
                if(marketingTouches.LeanData__Campaign__r.channel__c == 'Content Syndication'){
                contentSyndication18MonthsTouches++;
               }  
             }                                

          }


        for(LeadHistory ldHist : ldHistoryThisMonth = [SELECT Id, NewValue, OldValue, Field, CreatedDate FROM LeadHistory WHERE Field = 'Status' AND CreatedDate >= :date30DaysAgo and Lead.LeanData__Reporting_Matched_Account__r.Id = : accs2query.id]){
          
          totalEngagedLeads++;
          if(ldHist.CreatedDate >= date180DaysAgo){
            totalEngaged180DaysLeads++;
          }
          if(ldHist.CreatedDate >= date30DaysAgo){
            //Qualified Leads Through Out the Month
          if(ldHist.NewValue == 'qualified lead'){
              qualifiedNewValue++;
          }
          if(ldHist.NewValue == 'engaged'){
              engagedNewValue++;
          }
          if(ldHist.NewValue == 'Contacted'){
              contactedNewValue++;
          }     
          if(ldHist.NewValue == 'Nurture'){
              nurtureNewValue++;
          }     
          if(ldHist.NewValue == 'SQL'){
              sqlNewValue++;
          } 
          if(ldHist.NewValue == 'Sal'){
              salNewValue++;
          }
            //OLD VALUES Historical Leads
          if(ldHist.OldValue == 'qualified lead'){
              qualifiedOldValue++;
          }
          if(ldHist.OldValue == 'engaged'){
              engagedOldValue++;
          }
          if(ldHist.OldValue == 'Contacted'){
              contactedOldValue++;
          }     
          if(ldHist.OldValue == 'Nurture'){
              nurtureOldValue++;
          }     
          if(ldHist.OldValue == 'SQL'){
              sqlOldValue++;
          } 
          if(ldHist.OldValue == 'Sal'){
              salOldValue++;
          }                                    
          if(ldHist.OldValue == 'Prospect'){
              prospectOldValue++;
          }

// Happy Path Transition 
        if(ldHist.OldValue == 'Nurture' && (ldHist.NewValue == 'Prospect' || ldHist.NewValue == 'Engaged' || ldHist.NewValue == 'Contacted' || ldHist.NewValue == 'Qualified Lead' || ldHist.NewValue == 'SAL' || ldHist.NewValue == 'SQL' || ldHist.NewValue == 'Closed Won') ){
            happyPath_Transition_Nurture++;
        } 
        /*
              //Ratio
              if(nurtureOldValue > 0 && happyPath_Transition_Nurture > 0){
               happyPath_Ratio_ScoreNurture = (nurtureOldValue / happyPath_Transition_Nurture) * 100;
             }
             */
        //Prospect Happy Path Transitions
        if( ldHist.OldValue == 'Prospect' && (ldHist.NewValue == 'Engaged' || ldHist.NewValue == 'Contacted' || ldHist.NewValue == 'Qualified Lead' || ldHist.NewValue == 'SAL' || ldHist.NewValue == 'SQL' || ldHist.NewValue == 'Closed Won') ){
            happyPath_Transition_Prospect++;
        } 
        /*
            //Ratio
            if(prospectOldValue > 0 && happyPath_Transition_Prospect > 0){
              happyPath_Ratio_ScoreProspect = (prospectOldValue / happyPath_Transition_Prospect) * 100;
            }
            */
        //Engaged Happy Path Transitions 
        if( ldHist.OldValue == 'Engaged' && (ldHist.NewValue == 'Contacted' || ldHist.NewValue == 'Qualified Lead' || ldHist.NewValue == 'SAL' || ldHist.NewValue == 'SQL' || ldHist.NewValue == 'Closed Won') ){
            happyPath_Transition_Engaged++;
        }
        /*
            //Ratio
            if(engagedOldValue > 0 && happyPath_Transition_Engaged> 0){
              happyPath_Ratio_ScoreEngaged = (engagedOldValue / happyPath_Transition_Engaged) * 100;
            }
            */           
        //Contacted Happy Path Transitions 
        if( ldHist.OldValue == 'Contacted' && (ldHist.NewValue == 'Qualified Lead' || ldHist.NewValue == 'SAL' || ldHist.NewValue == 'SQL' || ldHist.NewValue == 'Closed Won') ){
            happyPath_Transition_Contacted++;
        } 
        /*
            //Ratio
            if(contactedOldValue > 0 && happyPath_Transition_contacted> 0){
              happyPath_Ratio_Scorecontacted = (contactedOldValue / happyPath_Transition_contacted) * 100;
            }    
            */     
        //Qualified Lead Happy Path Transitions
        if( ldHist.OldValue == 'Qualified Lead' && ( ldHist.NewValue == 'SAL' || ldHist.NewValue == 'SQL' || ldHist.NewValue == 'Closed Won') ){
            happyPath_Transition_Qualified++;
        }  
        /*
            //Ratio
            if(qualifiedOldValue > 0 && happyPath_Transition_qualified> 0){
              happyPath_Ratio_Scorequalified = (qualifiedOldValue / happyPath_Transition_qualified) * 100;
            } 
            */          
        //SAL Happy Path Transitions 
        if( ldHist.OldValue == 'SAL' && ( ldHist.NewValue == 'SQL' || ldHist.NewValue == 'Closed Won') ){
            happyPath_Transition_SAL++;
        } 
            /*
            //Ratio 
            if(salOldValue > 0 && happyPath_Transition_sal> 0){
              happyPath_Ratio_Scoresal = (salOldValue / happyPath_Transition_sal) * 100;
            } 
            */         
        //SQL Happy Path Transitions
        if( ldHist.OldValue == 'SQL' && (  ldHist.NewValue == 'Closed Won') ){
            happyPath_Transition_SQL++;
        } 
        /*
            //Ratio 
            if(sqlOldValue > 0 && happyPath_Transition_sql> 0){
              happyPath_Ratio_Scoresql = (sqlOldValue * happyPath_Transition_sql) * 100;
            } 
          */ 

           
          }//end if 30days

        }




        for(ContactHistory conHist : conHistoryThisMonth  = [SELECT Id, NewValue, OldValue, Field, CreatedDate FROM ContactHistory WHERE Field = 'Status__c' AND Contact.AccountID = : accs2query.id]){
          totalEngagedContact++;
          if(conHist.CreatedDate >= date180DaysAgo){
            totalEngaged180DaysContact++;
          }//endif 180 days

          if(conHist.CreatedDate >= date30DaysAgo){
            //Qualified Leads Through Out the Month
          if(conHist.NewValue == 'qualified lead'){
              qualifiedNewValue++;
          }
          if(conHist.NewValue == 'engaged'){
              engagedNewValue++;
          }
          if(conHist.NewValue == 'Contacted'){
              contactedNewValue++;
          }     
          if(conHist.NewValue == 'Nurture'){
              nurtureNewValue++;
          }     
          if(conHist.NewValue == 'SQL'){
              sqlNewValue++;
          } 
          if(conHist.NewValue == 'Sal'){
              salNewValue++;
          }
            //OLD VALUES Historical Leads
          if(conHist.OldValue == 'qualified lead'){
              qualifiedOldValue++;
          }
          if(conHist.OldValue == 'engaged'){
              engagedOldValue++;
          }
          if(conHist.OldValue == 'Contacted'){
              contactedOldValue++;
          }     
          if(conHist.OldValue == 'Nurture'){
              nurtureOldValue++;
          }     
          if(conHist.OldValue == 'SQL'){
              sqlOldValue++;
          } 
          if(conHist.OldValue == 'Sal'){
              salOldValue++;
          }                                    
          if(conHist.OldValue == 'Prospect'){
              prospectOldValue++;
          } 
          
// Happy Path Transition 
        if(conHist.OldValue == 'Nurture' && (conHist.NewValue == 'Prospect' || conHist.NewValue == 'Engaged' || conHist.NewValue == 'Contacted' || conHist.NewValue == 'Qualified Lead' || conHist.NewValue == 'SAL' || conHist.NewValue == 'SQL' || conHist.NewValue == 'Closed Won') ){
            happyPath_Transition_Nurture++;
        } 
        /*
              //Ratio
              if(nurtureOldValue > 0 && happyPath_Transition_Nurture > 0){
               happyPath_Ratio_ScoreNurture = (nurtureOldValue / happyPath_Transition_Nurture) * 100;
             }
             */
        //Prospect Happy Path Transitions
        if( conHist.OldValue == 'Prospect' && (conHist.NewValue == 'Engaged' || conHist.NewValue == 'Contacted' || conHist.NewValue == 'Qualified Lead' || conHist.NewValue == 'SAL' || conHist.NewValue == 'SQL' || conHist.NewValue == 'Closed Won') ){
            happyPath_Transition_Prospect++;
        } 
        /*
            //Ratio
            if(prospectOldValue > 0 && happyPath_Transition_Prospect > 0){
              happyPath_Ratio_ScoreProspect = (prospectOldValue / happyPath_Transition_Prospect) * 100;
            }
            */
        //Engaged Happy Path Transitions 
        if( conHist.OldValue == 'Engaged' && (conHist.NewValue == 'Contacted' || conHist.NewValue == 'Qualified Lead' || conHist.NewValue == 'SAL' || conHist.NewValue == 'SQL' || conHist.NewValue == 'Closed Won') ){
            happyPath_Transition_Engaged++;
        }
        /*
            //Ratio
            if(engagedOldValue > 0 && happyPath_Transition_Engaged> 0){
              happyPath_Ratio_ScoreEngaged = (engagedOldValue / happyPath_Transition_Engaged) * 100;
            }
            */           
        //Contacted Happy Path Transitions 
        if( conHist.OldValue == 'Contacted' && (conHist.NewValue == 'Qualified Lead' || conHist.NewValue == 'SAL' || conHist.NewValue == 'SQL' || conHist.NewValue == 'Closed Won') ){
            happyPath_Transition_Contacted++;
        } 
        /*
            //Ratio
            if(contactedOldValue > 0 && happyPath_Transition_contacted> 0){
              happyPath_Ratio_Scorecontacted = (contactedOldValue / happyPath_Transition_contacted) * 100;
            }    
            */     
        //Qualified Lead Happy Path Transitions
        if( conHist.OldValue == 'Qualified Lead' && ( conHist.NewValue == 'SAL' || conHist.NewValue == 'SQL' || conHist.NewValue == 'Closed Won') ){
            happyPath_Transition_Qualified++;
        }  
        /*
            //Ratio
            if(qualifiedOldValue > 0 && happyPath_Transition_qualified> 0){
              happyPath_Ratio_Scorequalified = (qualifiedOldValue / happyPath_Transition_qualified) * 100;
            } 
            */          
        //SAL Happy Path Transitions 
        if( conHist.OldValue == 'SAL' && ( conHist.NewValue == 'SQL' || conHist.NewValue == 'Closed Won') ){
            happyPath_Transition_SAL++;
        } 
            /*
            //Ratio 
            if(salOldValue > 0 && happyPath_Transition_sal> 0){
              happyPath_Ratio_Scoresal = (salOldValue / happyPath_Transition_sal) * 100;
            } 
            */         
        //SQL Happy Path Transitions
        if( conHist.OldValue == 'SQL' && (  conHist.NewValue == 'Closed Won') ){
            happyPath_Transition_SQL++;
        } 
        /*
            //Ratio 
            if(sqlOldValue > 0 && happyPath_Transition_sql> 0){
              happyPath_Ratio_Scoresql = (sqlOldValue * happyPath_Transition_sql) * 100;
            } 
          */  

          } //endif 30days


        }

            

    //product
    acctProduct = [SELECT Product__c FROM Product_Inventory__c WHERE Customer__c = : accs2query.Id];
    if(acctProduct.size() != 0){
      for(Product_Inventory__c acctPI : acctProduct  ){
        if(productSummary == ''){
            productSummary = productList.get(acctPI.Product__c);
        } else {
            productSummary += ', ' + productList.get(acctPI.Product__c);
        }
      }
    }
    //Value Consulting Data
  valueConsultingData = [  SELECT Full_Year_Plan__c,Latest_Measurement_Date__c,YTD_Benefits__c,YTD_Plan__c,YTD_Revenue__c, Full_Year_Revenue__c FROM Value_Consulting_Metric__c WHERE Customer__c = : accs2query.Id ORDER BY Latest_Measurement_Date__c DESC NULLS LAST LIMIT 1 ];

  if(valueConsultingData.size() != 0) {
    
     acctFullYearPlan = valueConsultingData[0].Full_Year_Plan__c;
     acctLatestMeasurementDate =  valueConsultingData[0].Latest_Measurement_Date__c;
     acctYTDBenefits= valueConsultingData[0].YTD_Benefits__c;
     acctYTDPlan = valueConsultingData[0].YTD_Plan__c;
     acctYTDRevenue = valueConsultingData[0].YTD_Revenue__c;
     acctFullYearRev = valueConsultingData[0].Full_Year_Revenue__c;
     hasVCData = 1;

  }


    //loopv throught opp
      for(Opportunity oppz : opportunityInAccount = [  SELECT Id, AccountId,CloseDate,CreatedDate,StageName FROM Opportunity WHERE AccountID = : accs2query.id]){
           //Apply the Current opportunty 
           if(oppz.CloseDate > system.today() ){
                  

                if(oppz.StageName.substring(0,1) == 'M'){
                  stageM = TRUE;
                  stageMCreateDate = oppz.CreatedDate;
                  
                  if ( currentOpportunity == '' || currentOpportunity == NULL && (oppz.StageName.substring(0,1) == '1'  ||  oppz.StageName.substring(0,1)  == '2' || oppz.StageName.substring(0,1) == '3' || oppz.StageName.substring(0,1) == '4'  || oppz.StageName.substring(0,1) == '5' || oppz.StageName.substring(0,1) == '6' || oppz.StageName.substring(0,1) == '7') ){
                    currentOpportunity = oppz.StageName;
                  }

                } else {
                
                if (currentOpportunity != '' && currentOpportunity != NULL && 
                   (oppz.StageName.substring(0,1) == '1'  ||  oppz.StageName.substring(0,1)  == '2' || oppz.StageName.substring(0,1) == '3' || oppz.StageName.substring(0,1) == '4'  || oppz.StageName.substring(0,1) == '5' || oppz.StageName.substring(0,1) == '6' || oppz.StageName.substring(0,1) == '7') &&
                   (currentOpportunity.substring(0,1) == '1'  ||  currentOpportunity.substring(0,1)  == '2' || currentOpportunity.substring(0,1) == '3' || currentOpportunity.substring(0,1) == '4'  || currentOpportunity.substring(0,1) == '5' || currentOpportunity.substring(0,1) == '6' || currentOpportunity.substring(0,1) == '7') ){
                      Integer currentOpp = integer.valueof(currentOpportunity.substring(0,1));
                      Integer newOpp = integer.valueof(oppz.StageName.substring(0,1));
                    if(newOpp > currentOpp){
                      currentOpportunity = oppz.StageName;                    
                    }

                  } else{
                    currentOpportunity = oppz.StageName;
                                        
                  }
                }
           }

          //scores if the account has a stage 3 or higher open opp
          if(oppz.StageName.substring(0,1) == '3' || oppz.StageName.substring(0,1) == '4' || oppz.StageName.substring(0,1) == '5' || oppz.StageName.substring(0,1) == '6' || oppz.StageName.substring(0,1) == '7' ){
             if(oppz.CloseDate >= date365DaysAgo && stage3OrMore == FALSE){
              newVesScore += 20;
              newVesScoreNotes = newVesScoreNotes + 'Stage 3 Opportunity,'; 
            }

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
      salesTouchesIntegers = [SELECT LeanData__Contact__r.Id , Max(LeanData__Contact__r.Number_of_Sales_Requests__c) salesRequests, Max(LeanData__Contact__r.Number_of_Sales_Analyst_Engagements__c) salesAnalystEngagement, Max(LeanData__Contact__r.Number_of_Sales_rfp__c) salesRFPTouches, Max(LeanData__Contact__r.Number_of_Sales_Meetings__c) salesMeetingsTouches, Max(LeanData__Contact__r.Number_of_Sales_Other_Tasks__c) salesOtherTouch, Max(LeanData__Contact__r.Total_Sales_Interactions__c) totalSalesTouch FROM LeanData__Marketing_Touch__c WHERE LeanData__Opportunity__r.Id in :oppID AND LeanData__Contact__r.Total_Sales_Interactions__c != Null GROUP BY LeanData__Contact__r.Id];
      salesTouchesIntegersSize = salesTouchesIntegers.size() - 1;
      for(integer i = 0; i <= salesTouchesIntegersSize; i++){
            totalSalesTouchOnOpp += (double) salesTouchesIntegers[i].get('totalSalesTouch');
        }


       for(LeanData__Marketing_Touch__c lastSalesB4CLoseData : salesLastTouchesBeforeClose = [SELECT LeanData__Contact__r.Id, LeanData__Contact__r.Name , LeanData__Contact__r.Last_Sales_Touch_Date__c, LeanData__Contact__r.Last_Sales_Touch_Type__c, LeanData__Contact__r.Last_Sales_Touch_Subject__c  FROM  LeanData__Marketing_Touch__c WHERE LeanData__Opportunity__r.Id in :oppID ORDER BY LeanData__Contact__r.First_Sales_Touch_Date__c DESC]){             
          if(lastTouchSalesCloseDate == null || lastTouchSalesCloseDate < lastSalesB4CLoseData.LeanData__Contact__r.Last_Sales_Touch_Date__c ){
             lastTouchSalesCloseDate = lastSalesB4CLoseData.LeanData__Contact__r.Last_Sales_Touch_Date__c;  
          }
          if( lastSalesB4CLoseData.LeanData__Contact__r.Last_Sales_Touch_Date__c >= date180DaysAgo){
              totalSalesTouchOnOpp180Days++;
           }            
       }

      //
      if(stage3OrMore){
        scoreStage3More = 15;
      }

      //combine both scores
      totalLeadsContactsBehavorScore = totalLeadsBehavorScore + totalContactsBehavorScore;
      totalLeadsContactsDemographicScore = totalLeadsDemographicScore + totalContactsDemographicScore;
      totalLeadsContactsBehavorDemoScore = totalLeadsContactsBehavorScore + totalLeadsContactsDemographicScore;
      //combine both scores excluding raw and disqulified
      totalLeadsContactsBehavorScoreRD = totalLeadsBehavorScoreRD + totalContactsBehavorScoreRD;
      totalLeadsContactsDemographicScoreRD = totalLeadsDemographicScoreRD + totalContactsDemographicScoreRD;
      totalLeadsContactsBehavorDemoScoreRD = totalLeadsContactsBehavorScoreRD + totalLeadsContactsDemographicScoreRD;


      //scoreing
      if(totalLeadsContactsDemographicScoreRD > 249){
        scoreDemographics = 5;

           
              newVesScore += 5;
              newVesScoreNotes = newVesScoreNotes + 'Demographic Score:' + totalLeadsContactsDemographicScoreRD + ' , '; 
            
      }
        if(totalLeadsContactsBehavorScoreRD > 1){
        scoreBehavior = 5;
      }
      if(totalLeadsContactsBehavorScoreRD > 25){ 
        scoreBehavior = 10;
      }
     
      if(totalLeadsContactsBehavorScoreRD > 51){
        scoreBehavior = 15;
      }
       


      if(mostRecentTouchDate >= date365DaysAgo ){
        scoreRecentTouch365 = 5;
      }
      if(mostRecentTouchDate >= date180DaysAgo ){
        scoreRecentTouch180 = 10;
        scoreRecentTouch365 = 0;

      }
      //if(stageMCreateDate >= date90DaysAgo){
      //  scoreStageM = 10;
      //}

      scoreKeywords = 0;
      list<Keyword__c> keywordResult = [SELECT Account__c FROM Keyword__c WHERE Account__c = : accs2query.Id AND Score__c > 74];
      Integer keywordCalc = keywordResult.size();

      if(keywordCalc > 2){
        scoreKeywords = 20;
      }
      if(keywordCalc == 2){
        scoreKeywords = 15;
      }
      if(keywordCalc == 1 ){
        scoreKeywords = 5;
      }



      scoreKickfire = 0;

      for(Kickfire__c kick : kickfireInAccount = [  SELECT Name, Page_Visit_Datetime__c FROM Kickfire__c WHERE Account__c = : accs2query.id AND Page_Visit_Datetime__c > : date180DaysAgo ]){
           
           if(kick.name.contains('product')){
            vesProductPageCount++;
           }
            if(kick.name.contains('resource') || kick.name.contains('blog')){
             vesResourcePageCount++;
           }

           vesPageCount++;
          
       }


      Double kickfireCalc = accs2query.Page_Visit_Last_30_Days__c;
      if(kickfireCalc > 2 ){
        scoreKickfire = 10;
      }
      
      scoreVendavoScore = scoreStage3More + scoreHotLeads + scoreWarmLeads + scoreDemographics + scoreBehavior + scoreRecentTouch180 + scoreRecentTouch365 + scoreKeywords + scoreStageM + scoreKickfire;




      //vesScore
      if(activeLead != 0){
        if(activeLead > 2){
          newVesScore += 25;
        }
        if(activeLead == 2){
          newVesScore += 15;
        }
        if(activeLead == 1 ){
          newVesScore += 10;
        }
        newVesScoreNotes = newVesScoreNotes + 'Active Leads:' +activeLead;
      }


      if (webinarCount != 0){
        if(webinarCount > 2){
          newVesScore += 10;
        }
        
        if(webinarCount == 1 ){
          newVesScore += 5;
        }
        newVesScoreNotes = newVesScoreNotes + ', Attended Webinar:' +webinarCount;
      }

      if (resourceCount != 0){
        if(resourceCount > 2){
          newVesScore += 10;
        }
        
        if(resourceCount == 1 ){
          newVesScore += 5;
        }
        newVesScoreNotes = newVesScoreNotes + ', Downloaded Resources:' +resourceCount;
      }
      if (eventCount != 0){
        if(eventCount > 2){
          newVesScore += 5;
        }
        
        newVesScoreNotes = newVesScoreNotes + ', Atteneded Live Event:' + eventCount;
      }


      if(vesPageCount != 0){

        if(vesPageCount > 2){
          newVesScore += 10;
        } else {
          newVesScore += 5;

        }
        newVesScoreNotes = newVesScoreNotes + ', Web Page Count:' + vesPageCount;
        
        if(vesProductPageCount != 0){
          newVesScore += 10;
          newVesScoreNotes = newVesScoreNotes + ', Web Product Page:' + vesProductPageCount;

        }
        if(vesResourcePageCount != 0){
          newVesScore += 5;
          newVesScoreNotes = newVesScoreNotes + ', Web Resource/Blog:' + vesResourcePageCount;

        }
      }


//sales touches
accs2Query.Total_Number_of_Sales_Touches__c = totalSalesTouchOnOpp;
accs2Query.Number_of_180_Days_Sales_Touches__c = totalSalesTouchOnOpp180Days;
accs2query.Last_Sales_Touch_Date__c = lastTouchSalesCloseDate;


accs2Query.Most_Recent_Touch_Campaign__c = mostRecentTouchCampaign;
accs2Query.Most_Recent_Touch_Date__c = mostRecentTouchDate;
accs2Query.Most_Recent_Touch_Person__c = mostRecentTouchPerson;
accs2Query.Most_Recent_Touch_Type__c = mostRecentTouchType;

accs2Query.Most_Recent_Non_Email_Touch_Campaign__c = mostRecentNonEmailTouchCampaign;
accs2Query.Most_Recent_Non_Email_Touch_Date__c = mostRecentNonEmailTouchDate;
accs2Query.Most_Recent_Non_Email_Touch_Person__c = mostRecentNonEmailTouchPerson;
accs2Query.Most_Recent_Non_Email_Touch_Type__c = mostRecentNonEmailTouchType;

accs2Query.Net_New_Engaged_Leads__c = engagedNewValue;
accs2Query.Net_New_Nurture_Leads__c = nurtureNewValue;
accs2Query.Net_New_Prospect_Leads__c = prospectNewValue;
accs2Query.Net_New_Qualified_Leads__c = qualifiedNewValue;
accs2Query.Net_New_SAL_Leads__c = salNewValue;
accs2Query.Net_New_SQL_Leads__c = sqlNewValue;
accs2Query.Net_New_Contacted_Leads__c = contactedNewValue;

accs2Query.Total_Engaged_Leads_Contacts__c = engagedLeadNContactAllTime;
accs2Query.Total_Leads_and_Contacts__c = totalLeadsNContacts;
accs2Query.Engaged_Contacts_in_Last_30_Days__c = engagedLeadsNContacts30Days;

accs2Query.Snapshot_Engaged_Leads__c = engagedNow;
accs2Query.Snapshot_Nurture_Leads__c = nurtureNow;
accs2Query.Snapshot_Prospect_Leads__c = prospectNow;
accs2Query.Snapshot_Qualified_Leads__c = qualifiedNOW;
accs2Query.Snapshot_SAL_Leads__c = salNow;
accs2Query.Snapshot_SQL_Leads__c = sqlNow;
accs2Query.Snapshot_Contacted_leads__c = contactedNow;  
accs2Query.Snapshot_Disqualified_Leads__c = disqualifedNOW;  
accs2Query.Snapshot_Raw_Leads__c = rawNow;  


accs2Query.Transitioned_Engaged_Leads__c = engagedOldValue;
accs2Query.Transitioned_Nurture_Leads__c = nurtureOldValue;
accs2Query.Transitioned_Prospect_Leads__c = prospectOldValue;
accs2Query.Transitioned_Qualified_Leads__c = qualifiedOldValue;
accs2Query.Transitioned_SAL_Leads__c = salOldValue;
accs2Query.Transitioned_SQL_Leads__c = sqlOldValue;
accs2Query.Transitioned_Contacted_Leads__c = ContactedOldValue;


accs2Query.Number_of_Advertising_Touches__c = advertisingTouches;
accs2Query.Number_of_DirectMail_Touches__c = directMailTouches;
accs2Query.Number_of_Email_Touches__c = emailTouches;
accs2Query.Number_of_Event_Touches__c = eventTouches;
accs2Query.Number_of_Telemarketing_Touches__c = telemarketingTouches;
accs2Query.Number_of_Webinar_Touches__c = webinarTouches;
accs2Query.Number_of_Website_Touches__c = websiteTouches;
accs2Query.Content_Syndication_Touches__c = contentsyndicationTouches;

accs2Query.Number_of_Marketing_Touches__c = advertisingTouches + directMailTouches + emailTouches + eventTouches + telemarketingTouches + webinarTouches + websiteTouches + contentsyndicationTouches;


//by 180 days
accs2Query.Number_of_180_Days_Advertising_Touches__c = advertising180DaysTouches;
accs2Query.Number_of_180_Days_DirectMail_Touches__c = directMail180DaysTouches;
accs2Query.Number_of_180_Days_Email_Touches__c = email180DaysTouches;
accs2Query.Number_of_180_Days_Event_Touches__c = event180DaysTouches;
accs2Query.Number_of_180_Days_Telemarketing_Touches__c = telemarketing180DaysTouches;
accs2Query.Number_of_180_Days_Webinar_Touches__c = webinar180DaysTouches;
accs2Query.Number_of_180_Days_Website_Touches__c = website180DaysTouches;
accs2Query.Number_of_180_Days_Content_Syndication_T__c = contentsyndication180DaysTouches;
accs2Query.Number_of_180_Days_Marketing_Touches__c = advertising180DaysTouches + directMail180DaysTouches + email180DaysTouches + event180DaysTouches + telemarketing180DaysTouches + webinar180DaysTouches + website180DaysTouches + contentsyndication180DaysTouches;
//by 365 days
accs2Query.Number_of_365_Days_Advertising_Touches__c = advertising365DaysTouches;
accs2Query.Number_of_365_Days_DirectMail_Touches__c = directMail365DaysTouches;
accs2Query.Number_of_365_Days_Email_Touches__c = email365DaysTouches;
accs2Query.Number_of_365_Days_Event_Touches__c = event365DaysTouches;
accs2Query.Number_of_365_Days_Telemarketing_Touches__c = telemarketing365DaysTouches;
accs2Query.Number_of_365_Days_Webinar_Touches__c = webinar365DaysTouches;
accs2Query.Number_of_365_Days_Website_Touches__c = website365DaysTouches;
accs2Query.Number_of_365_Days_Content_Syndication_T__c = contentsyndication365DaysTouches;
accs2Query.Number_of_365_Days_Marketing_Touches__c = advertising365DaysTouches + directMail365DaysTouches + email365DaysTouches + event365DaysTouches + telemarketing365DaysTouches + webinar365DaysTouches + website365DaysTouches + contentsyndication365DaysTouches;

//by 18 Months
accs2Query.Number_of_18_Months_Advertising_Touches__c = advertising18MonthsTouches;
accs2Query.Number_of_18_Months_DirectMail_Touches__c = directMail18MonthsTouches;
accs2Query.Number_of_18_Months_Email_Touches__c = email18MonthsTouches;
accs2Query.Number_of_18_Months_Event_Touches__c = event18MonthsTouches;
accs2Query.Number_of_18_Months_Telemarketing_Touch__c = telemarketing18MonthsTouches;
accs2Query.Number_of_18_Months_Webinar_Touches__c = webinar18MonthsTouches;
accs2Query.Number_of_18_Months_Website_Touches__c = website18MonthsTouches;
accs2Query.Number_of_18_Months_Content_Syndication__c = contentsyndication18MonthsTouches;
//No Email
//accs2Query.Number_of_18_Months_Marketing_Touches__c = advertising18MonthsTouches + directMail18MonthsTouches + email18MonthsTouches + event18MonthsTouches + telemarketing18MonthsTouches + webinar18MonthsTouches + website18MonthsTouches + contentsyndication18MonthsTouches;
accs2Query.Number_of_18_Months_Marketing_Touches__c = advertising18MonthsTouches + directMail18MonthsTouches  + event18MonthsTouches + telemarketing18MonthsTouches + webinar18MonthsTouches + website18MonthsTouches + contentsyndication18MonthsTouches;

//Current Oppertunity 

accs2Query.Stage_M_Opportunity__c = stageM;
accs2Query.Stage_M_Creation_Date__c = stageMCreateDate;
accs2Query.Current_Opportunity__c = currentOpportunity;
accs2Query.Stage_3_Or_More_in_the_Last_18_Months__c = stage3OrMore;

//engagement Lead and Contacts
accs2Query.Total_Number_of_Engaged_Contacts__c = totalEngagedContact;
accs2Query.Total_Number_of_Engaged_Contacts_in_180__c = totalEngaged180DaysContact;
accs2Query.Total_Number_of_Engaged_Leads__c = totalEngagedLeads;
accs2Query.Total_Number_of_Engaged_Leads_in_180_day__c = totalEngaged180DaysLeads;

//Total Lead/Contact Demgraphic and Behavior Score
accs2Query.Total_Leads_Behavior_Score__c = totalLeadsBehavorScore;
accs2Query.Total_Leads_Demographic_Score__c = totalLeadsDemographicScore;
accs2Query.Total_Leads_Behavior_Demo_Score__c = totalLeadsBehavorDemoScore;
accs2Query.Total_Contacts_Behavior_Score__c = totalContactsBehavorScore;
accs2Query.Total_Contacts_Demographic_Score__c = totalContactsDemographicScore;
accs2Query.Total_Contacts_Behavior_Demo_Score__c = totalContactsBehavorDemoScore;

accs2Query.Total_Leads_Contacts_Behavior_Score__c = totalLeadsContactsBehavorScore;
accs2Query.Total_Leads_Contacts_Demographic_Score__c = totalLeadsContactsDemographicScore;
accs2Query.Total_Leads_Contacts_Behavior_Demo_Score__c = totalLeadsContactsBehavorDemoScore;

//exlcude raw and disqulified 
accs2Query.Total_Leads_Contacts_BehavDemo_Score_RD__c = totalLeadsContactsBehavorDemoScoreRD;
accs2Query.Total_Leads_Contacts_Behavior_Score_RD__c = totalLeadsContactsBehavorScoreRD;
accs2Query.Total_Leads_Contacts_Demo_Score_RD__c = totalLeadsContactsDemographicScoreRD;

//vendavo scoreing 
accs2Query.Score_Lost_No_Decision_Stage_3__c = scoreStage3More;
accs2Query.Score_Snapshot_Hot_Leads__c = scoreHotLeads;
accs2Query.Score_Snapshot_Warm_Leads__c = scoreWarmLeads;
accs2Query.Score_LC_Demographics__c = scoreDemographics;
accs2Query.Score_LC_Behavior__c = scoreBehavior;
accs2Query.Score_Recent_Engagement_180_Days__c = scoreRecentTouch180;
accs2Query.Score_Recent_Engagement_365_Days__c = scoreRecentTouch365;
accs2Query.Score_Relevant_Search__c = scoreKeywords;
accs2Query.Score_Stage_Opportunity__c = scoreStageM;
accs2Query.Score_Vendavo_Page_Views__c = scoreKickfire;
accs2Query.Score_Vendavo_Total__c = scoreVendavoScore;


//updating scoreing
accs2Query.VES_Score__c = newVesScore;
accs2Query.VES_Score_Notes__c = newVesScoreNotes;

accs2Query.Happy_Path_Transition_Qualified__c = happyPath_Transition_Qualified;
accs2Query.Happy_Path_Transition_Engaged__c = happyPath_Transition_Engaged;
accs2Query.Happy_Path_Transition_Contacted__c = happyPath_Transition_Contacted;
accs2Query.Happy_Path_Transition_Nurture__c = happyPath_Transition_Nurture;
accs2Query.Happy_Path_Transition_Sql__c = happyPath_Transition_Sql;
accs2Query.Happy_Path_Transition_SAL__c = happyPath_Transition_SAL;
accs2Query.Happy_Path_Transition_Prospect__c = happyPath_Transition_Prospect;  
accs2Query.Product_Summary__c = productSummary;


   if(hasVCData == 1){
     accs2Query.Full_Year_Plan_VC__c = acctFullYearPlan;
     accs2Query.Latest_Measurement_Date_VC__c = acctLatestMeasurementDate;
     accs2Query.YTD_Benefits_VC__c = acctYTDBenefits;
     accs2Query.YTD_Plan_VC__c = acctYTDPlan;
     accs2Query.YTD_Revenue_VC__c = acctYTDRevenue;
     accs2Query.Full_Year_Revenue_VC__c = acctFullYearRev;
    }

      }
      update accs;
    }   
    global void finish(Database.BatchableContext BC)
    {
    }
}