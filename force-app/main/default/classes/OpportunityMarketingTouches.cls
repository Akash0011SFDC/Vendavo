global class OpportunityMarketingTouches implements Database.Batchable<sObject>
{

    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        String query = 'SELECT ID, CreatedDate, CloseDate FROM Opportunity';
        return Database.getQueryLocator(query);
    }
   
    global void execute(Database.BatchableContext BC, List<Opportunity> Opps)
    {  
    
   
    //Marketing Touch Integers  
    //testings changes to script
     Integer webinarTouches = 0;
     Integer eventTouches = 0;
     Integer emailTouches = 0;
     Integer advertisingTouches = 0;
     Integer websiteTouches = 0;
     Integer telemarketingTouches = 0;
     Integer directMailTouches = 0;
     Integer contentSyndicationTouches = 0;
     Integer mktgTouchesBeforeOpp = 0;
     Integer touchesInLast12Months = 0;
     Integer totalMarketingTouches = 0;
     Integer numberOfUniqueCampaigns = 0;
     Integer numberOfPartnerSourced = 0;
     Integer salesTouchesIntegersSize = 0;
     Integer numberOfEngagedLead_Contacts = 0;
     
      //Variables to Hold AGG Values
          //First Marketing Touch on Opp
      String firstTouchCampaignName;
      String firstTouchCampaignType;
      String firstTouchCampaignNamePerson;
      Date firstTouchCampaignDate;
          //Last Marketing Touch Before Close
      String lastTouchBeforeOppCloseName;
      String lastTouchBeforeOppCloseType;
      String lastTouchBeforeOppClosePerson;
      Date lastTouchBeforeOppCloseDate;
          //Last Marketing Touch Before Create
      String lastTouchBeforeOppCreateName;
      String lastTouchBeforeOppCreateType;
      String lastTouchBeforeOppCreatePerson;
      Date lastTouchBeforeOppCreateDate;  
      

      //Sales Touches
      //First Marketing Touch on Opp
      String firstTouchSalesSubject;
      String firstTouchSalesType;
      String firstTouchSalesPerson;
      DateTime firstTouchSalesDate;
      //Last Marketing Touch Before Close
      String lastTouchSalesBeforeOppCloseSubject;
      String lastTouchSalesBeforeOppCloseType;
      String lastTouchSalesBeforeOppClosePerson;
      DateTime lastTouchSalesBeforeOppCloseDate;
      //Last Marketing Touch Before Create
      String lastTouchSalesBeforeOppCreateSubject;
      String lastTouchSalesBeforeOppCreateType;
      String lastTouchSalesBeforeOppCreatePerson;
      DateTime lastTouchSalesBeforeOppCreateDate;
      
      //Inferred Opportunity Source (Sales vs Marketing)                
     String inferredOppSource = 'None';
     String inferredOppSourceType = 'None';   
     Date inferredOppSourceDate = date.Today();  
     String inferredOppSourcePerson = 'None';   
     
     //PartnerSourced 
     String firstParnerSourceName;
     DateTime firstParnerSourceDate;  
               
      //Refrence Variables to hold Opportunity Date & DateTime Fields
      Date oppsCloseDateRefrence;
      Date oppsCreateDateRefrence;
      
      //Sales touches integers
      Decimal totalSalesTouchOnOpp = 0;
      Decimal intNumberOfInfoRequest = 0;
      Decimal intNumberOfMeetings = 0;
      Decimal intNumberOfRFP = 0;
      Decimal intNumberOfAnalystEngagement = 0;
      Decimal intNumberOfOther = 0;

      list <AggregateResult> campaignTouchList;
      list <LeanData__Marketing_Touch__c> masterTouchesList;   
      list <LeanData__Marketing_Touch__c> firstToucchOnOppAllTime;
      list <LeanData__Marketing_Touch__c> lastTouchBeforeOppClose;
      list <LeanData__Marketing_Touch__c> lastTouchBeforeOppCreate;
      list <LeanData__Marketing_Touch__c> salesfirstTouch;
      list <LeanData__Marketing_Touch__c> salesLastTouchesBeforeCreate;
      list <LeanData__Marketing_Touch__c> salesLastTouchesBeforeClose;

      list <LeanData__Marketing_Touch__c> firstPartnerSourced;

     List <AggregateResult> salesTouchesIntegers;
            

     

     for(Opportunity opps2update : Opps){

      webinarTouches = 0;
      eventTouches = 0;
      emailTouches = 0;
      advertisingTouches = 0;
      websiteTouches = 0;
      telemarketingTouches = 0;
      directMailTouches = 0;
      contentSyndicationTouches = 0;
      mktgTouchesBeforeOpp = 0;
      touchesInLast12Months = 0;
      totalMarketingTouches = 0;
      numberOfUniqueCampaigns = 0;
      numberOfPartnerSourced = 0;
      salesTouchesIntegersSize = 0; 
      totalSalesTouchOnOpp = 0;
      intNumberOfInfoRequest = 0;
      intNumberOfMeetings = 0;
      intNumberOfRFP = 0;
      intNumberOfAnalystEngagement = 0;
      intNumberOfOther = 0;     


      numberOfEngagedLead_Contacts = 0; 

      oppsCloseDateRefrence = opps2update.closeDate;
      oppsCreateDateRefrence = opps2update.createdDate.date(); 

      salesTouchesIntegers = [SELECT LeanData__Contact__r.Id , Max(LeanData__Contact__r.Number_of_Sales_Requests__c) salesRequests, Max(LeanData__Contact__r.Number_of_Sales_Analyst_Engagements__c) salesAnalystEngagement, Max(LeanData__Contact__r.Number_of_Sales_rfp__c) salesRFPTouches, Max(LeanData__Contact__r.Number_of_Sales_Meetings__c) salesMeetingsTouches, Max(LeanData__Contact__r.Number_of_Sales_Other_Tasks__c) salesOtherTouch, Max(LeanData__Contact__r.Total_Sales_Interactions__c) totalSalesTouch FROM LeanData__Marketing_Touch__c WHERE LeanData__Opportunity__r.Id = :opps2update.Id AND LeanData__Contact__r.Total_Sales_Interactions__c != Null GROUP BY LeanData__Contact__r.Id];
      
      if(salesTouchesIntegers.size() != 0){
        salesTouchesIntegersSize = salesTouchesIntegers.size() - 1;

        for(integer i = 0; i <= salesTouchesIntegersSize; i++){
            if( salesTouchesIntegers[i].get('totalSalesTouch') != NULL){
                totalSalesTouchOnOpp += (double) salesTouchesIntegers[i].get('totalSalesTouch') ;

            }
            if(salesTouchesIntegers[i].get('salesOtherTouch') != NULL){
                intNumberOfOther += (double) salesTouchesIntegers[i].get('salesOtherTouch');

            }
            if(salesTouchesIntegers[i].get('salesRFPTouches') != NULL){
              intNumberOfRFP += (double) salesTouchesIntegers[i].get('salesRFPTouches');

            }
            if(salesTouchesIntegers[i].get('salesMeetingsTouches') != NULL){
              intNumberOfMeetings += (double) salesTouchesIntegers[i].get('salesMeetingsTouches');

            }
            if(salesTouchesIntegers[i].get('salesAnalystEngagement') != NULL){
              intNumberOfAnalystEngagement += (double) salesTouchesIntegers[i].get('salesAnalystEngagement');
            } 
            if(salesTouchesIntegers[i].get('salesRequests') != NULL){
              intNumberOfInfoRequest += (double) salesTouchesIntegers[i].get('salesRequests');
            }
          }
        }


     //Number of Engaged leads and Contacts
     AggregateResult[] engagedLeads = [SELECT LeanData__Lead__r.Id , Count(Id) NumOfLeads FROM LeanData__Marketing_Touch__c WHERE LeanData__Opportunity__r.Id = :opps2update.Id  GROUP BY LeanData__Lead__r.Id ];
     AggregateResult[] engagedContacts = [SELECT LeanData__Contact__r.Id, Count(Id) NumOfContacts FROM LeanData__Marketing_Touch__c WHERE LeanData__Opportunity__r.Id = :opps2update.id GROUP BY LeanData__Contact__r.Id];
     numberOfEngagedLead_Contacts = engagedLeads.size() + engagedContacts.size();


     //Create List
     List<string> uniqueCampaigns = new List<string>();

     Integer touchCount = 1;

     masterTouchesList  = [SELECT Id, LeanData__Lead__r.Id, LeanData__Contact__r.LeadSource, LeanData__Contact__r.Id, LeanData__Contact__r.Name, LeanData__Lead__r.Name, LeanData__Campaign__r.Type, LeanData__Campaign__r.Name, LeanData__Campaign__r.channel__c, LeanData__Contact__r.Last_Sales_Touch_Date__c,  LeanData__Contact__r.Last_Sales_Touch_Type__c,  LeanData__Contact__r.Last_Sales_Touch_Subject__c, LeanData__Campaign_Member_Created_Date__c FROM LeanData__Marketing_Touch__c WHERE LeanData__Opportunity__r.Id = : opps2update.id  AND LeanData__Campaign__r.Type != 'Lead Lifecycle' ORDER BY LeanData__Campaign_Member_Created_Date__c ASC];
    if(masterTouchesList.size() != 0){

     for(LeanData__Marketing_Touch__c leanDatatouches : masterTouchesList ){

            totalMarketingTouches++;
            if(leanDataTouches.LeanData__Contact__r.LeadSource == 'Partner'){
                numberOfPartnerSourced++;
            }
            if(leanDatatouches.LeanData__Campaign_Member_Created_Date__c > system.today().addDays(-365) ){
              touchesInLast12Months++;
            }
            if(leanDatatouches.LeanData__Campaign__r.channel__c == 'Webinar' || leanDatatouches.LeanData__Campaign__r.type == 'Webinar'){
              webinarTouches++;
            }
            if(leanDatatouches.LeanData__Campaign__r.channel__c == 'Events' || leanDatatouches.LeanData__Campaign__r.type == 'Tradeshow'){
              eventTouches++;
            }
            if(leanDatatouches.LeanData__Campaign__r.channel__c == 'Telemarketing'){
              telemarketingTouches++;
            }
            if(leanDatatouches.LeanData__Campaign__r.channel__c == 'Email' || leanDatatouches.LeanData__Campaign__r.type == 'Email Blast' || leanDatatouches.LeanData__Campaign__r.channel__c == 'Direct Mail'){
              emailTouches++;
            }
            if(leanDatatouches.LeanData__Campaign__r.channel__c == 'Website' || leanDatatouches.LeanData__Campaign__r.type == 'Website Resource' ){
              websiteTouches++;
            }
            if(leanDatatouches.LeanData__Campaign__r.channel__c == 'Advertising'){
              advertisingTouches++;
             }   
            if(leanDatatouches.LeanData__Campaign__r.channel__c == 'Content Syndication'){
              contentSyndicationTouches++;
             }     

             //create a unique array of campaign ids
             Boolean notinList = TRUE;
               if(uniqueCampaigns.size() != 0){
                for(String campID : uniqueCampaigns ){
                  if( campID == leanDatatouches.LeanData__Campaign__c ){
                    notinList = FALSE;
                  }
                }  
             }
            if(notinList){
                uniqueCampaigns.add(leanDatatouches.LeanData__Campaign__c);
              }

              if(touchCount == 1){
               DateTime dT = leanDatatouches.LeanData__Campaign_Member_Created_Date__c;
                    Date myDate = date.newinstance(dT.year(), dT.month(), dT.day());

                    firstTouchCampaignName = leanDatatouches.LeanData__Campaign__r.name; 
                    firstTouchCampaignType = leanDatatouches.LeanData__Campaign__r.Type; 
                    firstTouchCampaignDate = myDate; 
                  
                if(leanDatatouches.LeanData__Contact__r.Name != NULL){
                    firstTouchCampaignNamePerson = leanDatatouches.LeanData__Contact__r.Name;
                }else{
                    firstTouchCampaignNamePerson = leanDatatouches.LeanData__Lead__r.Name;
                }
              }//first touch

              //Last touch
              if(leanDatatouches.LeanData__Campaign_Member_Created_Date__c <= oppsCloseDateRefrence){
                  DateTime dT = leanDatatouches.LeanData__Campaign_Member_Created_Date__c;
                    Date myDate = date.newinstance(dT.year(), dT.month(), dT.day());

                    lastTouchBeforeOppCloseName = leanDatatouches.LeanData__Campaign__r.name;
                    lastTouchBeforeOppCloseType = leanDatatouches.LeanData__Campaign__r.type;
                    lastTouchBeforeOppCloseDate = myDate;
                  
                if(leanDatatouches.LeanData__Contact__r.Name != NULL){
                    lastTouchBeforeOppClosePerson = leanDatatouches.LeanData__Contact__r.Name;
                }else{
                    lastTouchBeforeOppClosePerson = leanDatatouches.LeanData__Lead__r.Name;
                }   
              }//last touch


              //last touch before opp create date
              if(leanDatatouches.LeanData__Campaign_Member_Created_Date__c <= oppsCreateDateRefrence){
                  mktgTouchesBeforeOpp++;          
                    
                    DateTime dT = leanDatatouches.LeanData__Campaign_Member_Created_Date__c;
                    Date myDate = date.newinstance(dT.year(), dT.month(), dT.day());

  
                    lastTouchBeforeOppCreateName = leanDatatouches.LeanData__Campaign__r.name;
                    lastTouchBeforeOppCreateType = leanDatatouches.LeanData__Campaign__r.type;
                    lastTouchBeforeOppCreateDate = myDate;


                  
                if(leanDatatouches.LeanData__Contact__r.Name != NULL){
                    lastTouchBeforeOppCreatePerson = leanDatatouches.LeanData__Contact__r.Name;
                }else{
                    lastTouchBeforeOppCreatePerson = leanDatatouches.LeanData__Lead__r.Name;
                }   


              }
              touchCount++;







     }

   }//endif touch


     //size of unique
     numberOfUniqueCampaigns = uniqueCampaigns.size();
      for(LeanData__Marketing_Touch__c firstsalesData : salesfirstTouch  = [SELECT LeanData__Contact__r.Id, LeanData__Contact__r.Name , LeanData__Contact__r.First_Sales_Touch_Date__c, LeanData__Contact__r.First_Sales_Touch_Type__c , LeanData__Contact__r.First_Sales_Touch_Subject__c  FROM  LeanData__Marketing_Touch__c WHERE LeanData__Opportunity__r.Id = :opps2update.id ORDER BY LeanData__Contact__r.First_Sales_Touch_Date__c ASC LIMIT 1]){
              if(salesfirstTouch.size() > 0){
                  firstTouchSalesSubject = salesfirstTouch[0].LeanData__Contact__r.First_Sales_Touch_Subject__c;
                  firstTouchSalesType = salesfirstTouch[0].LeanData__Contact__r.First_Sales_Touch_Type__c;
                  firstTouchSalesDate = salesfirstTouch[0].LeanData__Contact__r.First_Sales_Touch_Date__c;
                  firstTouchSalesPerson = salesfirstTouch[0].LeanData__Contact__r.Name;
              }
      }    
      
      for(LeanData__Marketing_Touch__c lastSalesB4CreateData : salesLastTouchesBeforeCreate  = [SELECT LeanData__Contact__r.Id, LeanData__Contact__r.Name , LeanData__Contact__r.Last_Sales_Touch_Date__c, LeanData__Contact__r.Last_Sales_Touch_Type__c, LeanData__Contact__r.Last_Sales_Touch_Subject__c  FROM  LeanData__Marketing_Touch__c WHERE LeanData__Contact__r.Last_Sales_Touch_Date__c < :oppsCreateDateRefrence AND LeanData__Opportunity__r.Id = :opps2update.id ORDER BY LeanData__Contact__r.First_Sales_Touch_Date__c DESC LIMIT 1]){
              if(salesfirstTouch.size() > 0){
                  lastTouchSalesBeforeOppCreateSubject = salesLastTouchesBeforeCreate[0].LeanData__Contact__r.Last_Sales_Touch_Subject__c;
                  lastTouchSalesBeforeOppCreateType = salesLastTouchesBeforeCreate[0].LeanData__Contact__r.Last_Sales_Touch_Type__c;
                  lastTouchSalesBeforeOppCreateDate = salesLastTouchesBeforeCreate[0].LeanData__Contact__r.Last_Sales_Touch_Date__c;
                  lastTouchSalesBeforeOppCreatePerson = salesLastTouchesBeforeCreate[0].LeanData__Contact__r.Name;
              }
      }    
      
      for(LeanData__Marketing_Touch__c lastSalesB4CLoseData : salesLastTouchesBeforeClose = [SELECT LeanData__Contact__r.Id, LeanData__Contact__r.Name , LeanData__Contact__r.Last_Sales_Touch_Date__c, LeanData__Contact__r.Last_Sales_Touch_Type__c, LeanData__Contact__r.Last_Sales_Touch_Subject__c  FROM  LeanData__Marketing_Touch__c WHERE LeanData__Contact__r.Last_Sales_Touch_Date__c < :oppsCloseDateRefrence AND LeanData__Opportunity__r.Id = :opps2update.id ORDER BY LeanData__Contact__r.First_Sales_Touch_Date__c DESC LIMIT 1]){
              if(salesfirstTouch.size() > 0){
                  lastTouchSalesBeforeOppCloseSubject = salesLastTouchesBeforeClose[0].LeanData__Contact__r.Last_Sales_Touch_Subject__c;
                  lastTouchSalesBeforeOppCloseType = salesLastTouchesBeforeClose[0].LeanData__Contact__r.Last_Sales_Touch_Type__c;
                  lastTouchSalesBeforeOppCloseDate = salesLastTouchesBeforeClose[0].LeanData__Contact__r.Last_Sales_Touch_Date__c;
                  lastTouchSalesBeforeOppClosePerson = salesLastTouchesBeforeClose[0].LeanData__Contact__r.Name;
              }
      } 
      //First Partner Sourced Contact
      for(LeanData__Marketing_Touch__c firstPartnerContact: firstPartnerSourced  = [SELECT Id, LeanData__Contact__r.Id, LeanData__Contact__r.LeadSource, LeanData__Contact__r.Name, LeanData__Contact__r.CreatedDate FROM  LeanData__Marketing_Touch__c WHERE LeanData__Opportunity__r.Id = :opps2update.id AND LeanData__Contact__r.LeadSource = 'Partner' ORDER BY CreatedDate ASC LIMIT 1]){
              if(firstPartnerSourced.size() > 0){
                  firstParnerSourceDate = firstPartnerSourced[0].LeanData__Contact__r.CreatedDate;
                  firstParnerSourceName = firstPartnerSourced[0].LeanData__Contact__r.Name;
              }
      }       
     // Inferred opportunity source 
      if(firstTouchCampaignDate != NULL && ((firstTouchSalesDate > firstTouchCampaignDate && firstTouchCampaignDate < firstParnerSourceDate) || (firstTouchSalesDate == NULL &&  firstParnerSourceDate == NULL) || ( firstTouchCampaignDate < firstTouchSalesDate && firstParnerSourceDate == NULL ) || ( firstTouchCampaignDate < firstParnerSourceDate && firstTouchSalesDate == NULL )) ){
          inferredOppSource = 'Marketing';
          inferredOppSourceType = firstTouchCampaignType;
          inferredOppSourcePerson = firstTouchCampaignNamePerson;
          inferredOppSourceDate = firstTouchCampaignDate;
      }else if(firstTouchSalesDate != NULL && ((firstTouchSalesDate < firstTouchCampaignDate && firstTouchSalesDate < firstParnerSourceDate) || (firstTouchCampaignDate == NULL && firstParnerSourceDate == NULL) || ( firstTouchCampaignDate > firstTouchSalesDate && firstParnerSourceDate == NULL ) || ( firstParnerSourceDate > firstTouchSalesDate && firstTouchCampaignDate == NULL ))){
          inferredOppSource = 'Sales';
          inferredOppSourceType = firstTouchSalesType;
          inferredOppSourcePerson = firstTouchSalesPerson;
          inferredOppSourceDate = firstTouchSalesDate.Date();
      }else if(firstParnerSourceDate != NULL ){
          inferredOppSource = 'Partner';
          inferredOppSourceType = 'Partner Sourced';
          inferredOppSourcePerson = firstParnerSourceName;
          inferredOppSourceDate = firstParnerSourceDate.Date();
      } else{
          inferredOppSource = 'None';
          inferredOppSourceType = 'Error: Logic Fail (Criteria Not Met)';
          inferredOppSourcePerson = 'None';    
      
      }
            
       //Field update on opportunity object    
               
          //First Touch  
      opps2update.First_Marketing_Touch_Before_Create_Name__c = firstTouchCampaignName;      
      opps2update.First_Marketing_Touch_Before_Create_Type__c = firstTouchCampaignType;           
      opps2update.First_Marketing_Touch_Before_Create_Date__c = firstTouchCampaignDate ;
      opps2update.First_Marketing_Touch_Person__c = firstTouchCampaignNamePerson;
      
          //Last Touch Before Opportunity Creation
      opps2update.Last_Marketing_Touch_Before_Close_Name__c = lastTouchBeforeOppCloseName;
      opps2update.Last_Marketing_Touch_Before_Close_Type__c = lastTouchBeforeOppCloseType;
      opps2update.Last_Marketing_Touch_Before_Close_Date__c = lastTouchBeforeOppCloseDate; 
      opps2update.Last_Marketing_Touch_Before_Close_Person__c = lastTouchBeforeOppClosePerson;            
      
         //Last Touch Before Opportunity CloseDate 
      opps2update.Last_Marketing_Touch_Before_Opp_Name__c = lastTouchBeforeOppCreateName;
      opps2update.Last_Marketing_Touch_Before_Opp_Type__c = lastTouchBeforeOppCreateType;
      opps2update.Last_Marketing_Touch_Before_Opp_Date__c = lastTouchBeforeOppCreateDate;   
      opps2update.Last_Marketing_Touch_Before_Opp_Person__c = lastTouchBeforeOppCreatePerson;   
     
          //Marketing Touches Integers 
      opps2update.Number_of_webinar_touches__c = webinarTouches;
      opps2update.Number_of_event_touches__c = eventTouches;
      opps2update.Number_of_website_touches__c = websiteTouches;
      opps2update.Number_of_advertising_touches__c = advertisingTouches;
      opps2update.Number_of_telemarketing_touches__c = telemarketingTouches;
      opps2update.Number_of_directmail_touches__c = directMailTouches;
      opps2update.Number_of_email_touches__c = emailTouches;
      opps2update.Number_Of_Content_Syndication_Touches__c = contentSyndicationTouches;

          //Sales Touches
              //First Sales Touch
      opps2update.First_Sales_Touch_Before_Creation_Subj__c = firstTouchSalesSubject;
      if(firstTouchSalesDate != NULL){
        opps2update.First_Sales_Touch_Before_Creation_Date__c = firstTouchSalesDate.date();
      }
      opps2update.First_Sales_Touch_Before_Creation_Person__c = firstTouchSalesPerson;
      opps2update.First_Sales_Touch_Before_Create_Type__c = firstTouchSalesType;
      
              //Last Sales Touch Before Creation
      opps2update.Last_Sales_Touch_Before_Opp_Subj__c= lastTouchSalesBeforeOppCreateSubject;
          if(lastTouchSalesBeforeOppCreateDate != NULL){
      opps2update.Last_Sales_Touch_Before_Opp_Date__c = lastTouchSalesBeforeOppCreateDate.date();
          }
      opps2update.Last_Sales_Touch_Before_Opp_Type__c = lastTouchSalesBeforeOppCreateType;
      opps2update.Last_Sales_Touch_Before_Opp_Person__c = lastTouchSalesBeforeOppCreatePerson;
      
              //Last Sales Touch Before Opp Close Date
      opps2update.Last_Sales_Touch_Before_Close_Person__c= lastTouchSalesBeforeOppClosePerson;
          if(lastTouchSalesBeforeOppCloseDate != NULL){
      opps2update.Last_Sales_Touch_Before_Close_Date__c= lastTouchSalesBeforeOppCloseDate.date();
          }
      opps2update.Last_Sales_Touch_Before_Close_Subj__c= lastTouchSalesBeforeOppCloseSubject;
      opps2update.Last_Sales_Touch_Before_Close_Type__c= lastTouchSalesBeforeOppCloseType;

        //Inferred Opportunity Source
      opps2update.Inferred_Opportunity_Source__c = inferredOppSource;
      opps2update.Inferred_Opportunity_Source_Person__c = inferredOppSourcePerson;
      opps2update.Inferred_Opportunity_Source_Type__c = inferredOppSourceType;
          if(inferredOppSourceDate != NULL){
      opps2update.Inferred_Opportunity_Source_Date__c = inferredOppSourceDate;
         if(numberOfEngagedLead_Contacts != NULL){ 
            opps2update.Number_of_Engaged_Leads_Contacts__c = numberOfEngagedLead_Contacts;
          }
      opps2update.Number_of_Unique_Campaigns__c = numberOfUniqueCampaigns;
      opps2update.Marketing_Touches_in_Last_12_Months__c = touchesInLast12Months;
      opps2update.Marketing_Touches_Before_Opp_Creation__c = mktgTouchesBeforeOpp;    
      opps2update.Total_Marketing_Touches__c = totalMarketingTouches;
      opps2update.Number_of_Sales_Requests__c = intNumberOfInfoRequest;
      opps2update.Number_of_Sales_Analyst_Engagements__c = intNumberOfAnalystEngagement;
      opps2update.Number_of_Sales_rfp__c = intNumberOfRFP;
      opps2update.Number_of_Sales_Meetings__c = intNumberOfMeetings;
      opps2update.Number_of_Sales_Other_Tasks__c = intNumberOfOther;
      opps2update.Total_Sales_Touches__c = totalSalesTouchOnOpp; 
        }
      
      } update opps;

    }   
    global void finish(Database.BatchableContext BC)
    {
    }
}