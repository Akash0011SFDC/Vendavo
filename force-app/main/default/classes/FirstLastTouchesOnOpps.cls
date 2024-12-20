global class FirstLastTouchesOnOpps implements Database.Batchable<sObject>
{
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        String query = 'SELECT ID, CreatedDate, CloseDate FROM Opportunity';
        return Database.getQueryLocator(query);
    }
   
    global void execute(Database.BatchableContext BC, List<Opportunity> opps)
    {          
      for(Opportunity opps2Query : opps){

      //Refrence Variables to hold Opportunity Date & DateTime Fields
      Date oppsCloseDateRefrence = opps2Query.closeDate;
      Date oppsCreateDateRefrence = opps2Query.CreatedDate.date();
      List <LeanData__Marketing_Touch__c> firstToucchOnOppAllTime = [SELECT Id ,LeanData__Campaign__r.name, LeanData__Campaign_Member_Created_Date__c, LeanData__Campaign__r.Type,  LeanData__Campaign__r.Channel__c, LeanData__Lead__r.Name, LeanData__Contact__r.Name FROM  LeanData__Marketing_Touch__c WHERE LeanData__Opportunity__r.Id = :opps2Query.ID ORDER BY LeanData__Campaign_Member_Created_Date__c ASC];
   
      //Variables to Hold AGG Values
          //First Touch on Opp
              String firstTouchCampaignName;
              String firstTouchCampaignType;
              String firstTouchCampaignNamePerson;
              Date firstTouchCampaignDate;
              
          //Last Touch Before Close
              String lastTouchBeforeOppCloseName;
              String lastTouchBeforeOppCloseType;
              String lastTouchBeforeOppClosePerson;
              Date lastTouchBeforeOppCloseDate;
          //Last Touch Before Create
              String lastTouchBeforeOppCreateName;
              String lastTouchBeforeOppCreateType;
              String lastTouchBeforeOppCreatePerson;
              Date lastTouchBeforeOppCreateDate;


          // Touches

       
     
      for(LeanData__Marketing_Touch__c LDobjectDataFTAT : firstToucchOnOppAllTime){
              if(firstToucchOnOppAllTime.size() > 0){

            Integer marketingTouches = 0;

      //First touch on opportunity all time
              if( marketingTouches == 0){

                DateTime dT = LDobjectDataFTAT.LeanData__Campaign_Member_Created_Date__c; 
                Date myDate = date.newinstance(dT.year(), dT.month(), dT.day());

                  firstTouchCampaignName = LDobjectDataFTAT.LeanData__Campaign__r.name; 
                  firstTouchCampaignType = LDobjectDataFTAT.LeanData__Campaign__r.Type; 
                  firstTouchCampaignDate = myDate;
                
              if(LDobjectDataFTAT.LeanData__Contact__r.Name != NULL){
                  firstTouchCampaignNamePerson = LDobjectDataFTAT.LeanData__Contact__r.Name;
              }else{
                  firstTouchCampaignNamePerson = LDobjectDataFTAT.LeanData__Lead__r.Name;
              }

            } //end if first touch



         if( LDobjectDataFTAT.LeanData__Campaign_Member_Created_Date__c <=  oppsCloseDateRefrence ){
                DateTime dT = LDobjectDataFTAT.LeanData__Campaign_Member_Created_Date__c;
                Date myDate = date.newinstance(dT.year(), dT.month(), dT.day());
                  lastTouchBeforeOppCloseName = LDobjectDataFTAT.LeanData__Campaign__r.name;
                  lastTouchBeforeOppCloseType = LDobjectDataFTAT.LeanData__Campaign__r.type;
                  lastTouchBeforeOppCloseDate =  myDate;
                 
              if(LDobjectDataFTAT.LeanData__Contact__r.Name != NULL){
                  lastTouchBeforeOppClosePerson = LDobjectDataFTAT.LeanData__Contact__r.Name;
              }else{
                  lastTouchBeforeOppClosePerson = LDobjectDataFTAT.LeanData__Lead__r.Name;
              }                     
           }




      if( LDobjectDataFTAT.LeanData__Campaign_Member_Created_Date__c <=  oppsCreateDateRefrence){  
      //Last touch on opportunity before create date      
         DateTime dT = LDobjectDataFTAT.LeanData__Campaign_Member_Created_Date__c;
                    Date myDate = date.newinstance(dT.year(), dT.month(), dT.day());
      
                  lastTouchBeforeOppCreateName = LDobjectDataFTAT.LeanData__Campaign__r.name;
                  lastTouchBeforeOppCreateType = LDobjectDataFTAT.LeanData__Campaign__r.type;
                  lastTouchBeforeOppCreateDate = myDate;
                
              if(LDobjectDataFTAT.LeanData__Contact__r.Name != NULL){
                  lastTouchBeforeOppCreatePerson = LDobjectDataFTAT.LeanData__Contact__r.Name;
              }else{
                  lastTouchBeforeOppCreatePerson = LDobjectDataFTAT.LeanData__Lead__r.Name;
              }                      
          }


              marketingTouches++;

            }
          }



   


       
       //Field update on opportunity object    
               
               //First Touch  
                  opps2Query.First_Marketing_Touch_Before_Create_Name__c = firstTouchCampaignName;      
                  opps2Query.First_Marketing_Touch_Before_Create_Type__c = firstTouchCampaignType;           
                  opps2Query.First_Marketing_Touch_Before_Create_Date__c = firstTouchCampaignDate ;
                  opps2Query.First_Marketing_Touch_Person__c = firstTouchCampaignNamePerson;
      
              //Last Touch Before Opportunity Creation
                   opps2Query.Last_Marketing_Touch_Before_Close_Name__c = lastTouchBeforeOppCloseName;
                   opps2Query.Last_Marketing_Touch_Before_Close_Type__c = lastTouchBeforeOppCloseType;
                   opps2Query.Last_Marketing_Touch_Before_Close_Date__c = lastTouchBeforeOppCloseDate; 
                   opps2Query.Last_Marketing_Touch_Before_Close_Person__c = lastTouchBeforeOppClosePerson;            
      
              //Last Touch Before Opportunity CloseDate 
                   opps2Query.Last_Marketing_Touch_Before_Opp_Name__c = lastTouchBeforeOppCreateName;
                   opps2Query.Last_Marketing_Touch_Before_Opp_Type__c = lastTouchBeforeOppCreateType;
                   opps2Query.Last_Marketing_Touch_Before_Opp_Date__c = lastTouchBeforeOppCreateDate;   
                   opps2Query.Last_Marketing_Touch_Before_Opp_Person__c = lastTouchBeforeOppCreatePerson;   
      
      update Opps;
      }
      

      
    }   
    global void finish(Database.BatchableContext BC)
    {
    }
}