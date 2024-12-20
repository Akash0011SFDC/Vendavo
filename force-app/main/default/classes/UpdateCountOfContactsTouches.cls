global class UpdateCountOfContactsTouches implements Database.Batchable<sObject>
{
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        String query = 'SELECT ID FROM Contact';
        return Database.getQueryLocator(query);
    }
   
    global void execute(Database.BatchableContext BC, List<Contact> Con)
    {   
      for(Contact conz : Con){
        List<CampaignMember> cm = [SELECT Campaign.Name, Campaign.Channel__c, Status, Campaign.type, CreatedDate FROM CampaignMember WHERE ContactID = :conz.ID AND Campaign.type != 'Lead Lifecycle' ORDER BY CreatedDate ASC];


        //First Touch
        String cmsFirst2inputName;
        String cmsFirst2inputType;   
        DateTime cmsFirstinputDate;
        
        
        //Last Touch
        DateTime cmsLastinputDate;  
        String cmsLast2inputName;  
        String cmsLast2inputType; 


    
        //Integer Touched  
        Integer marketingTouches = 0;
        Integer intNumberOfCmbrs_Webinars = 0;
        Integer intNumberOfCmbrs_Total = 0;
        Integer intNumberOfCmbrs_Events = 0;
        Integer intNumberOfCmbrs_Website = 0;
        Integer intNumberOfCmbrs_Advertising = 0;
        Integer intNumberOfCmbrs_Email = 0;
        Integer intNumberOfCmbrs_Telemarketing = 0;
        Integer intNumberOfCmbrs_DirectMail = 0;


        for(CampaignMember cmdata : cm ){
            if (marketingTouches == 0){
               cmsFirst2inputName = cmdata.Campaign.Name;
               cmsFirst2inputType = cmdata.Campaign.type;   
               cmsFirstinputDate = cmdata.CreatedDate;
            }

            //Webinar Touches
              if( ( cmdata.Campaign.Channel__c == 'Webinar' || cmdata.Campaign.type == 'Webinar' ) && (cmdata.Status == 'Attended' || cmdata.Status == 'Attended On-Demand' || cmdata.Status == 'No Show' || cmdata.Status == 'Registered')){
                  intNumberOfCmbrs_Webinars++;
              }
              //Website Touches
              if( (cmdata.Campaign.Channel__c == 'Website' || cmdata.Campaign.type == 'Website Resource') && (cmData.Status == 'Subscribed' || cmData.Status == 'Requested Contact' || cmData.Status == 'Downloaded' || cmData.Status == 'Visited Page' )){
                  intNumberOfCmbrs_Website++;
              }
              //Advertising Touches
              if( cmdata.Campaign.Channel__c == 'Advertising' && (((cmdata.Campaign.type == 'Google AdWords' || cmdata.Campaign.type == 'Advertising') && (cmData.Status == 'Clicked' || cmData.Status == 'Converted')) ||  (cmdata.Campaign.type == 'Lead Accelerator' && (cmData.Status == 'Downloaded' ||  cmData.Status == 'Subscribed' || cmData.Status == 'Registered' )))) {
                intNumberOfCmbrs_Advertising++;
              }
              //Events Touches
              if( cmdata.Campaign.Channel__c == 'Events' && (((((cmData.Campaign.type == 'Profit Summit') && (cmData.Status == 'Attended' || cmData.Status == 'Registered' || cmData.Status == 'No Show'))) || (((((cmData.Campaign.type == 'tradeshow' || cmData.Campaign.type == 'trade show') && (cmData.Status == 'Visited Booth' || cmData.Status == 'Visited Booth - Hot Lead' || cmData.Status == 'Requested Meeting'   ||  cmData.Status == 'Attended'))) || (((((cmData.Campaign.type == 'Field Event' || cmData.Campaign.type == 'Field Event - User Group') && (cmData.Status == 'Attended' || cmData.Status == 'Registered' || cmData.Status == 'No Show')))))))))){
                intNumberOfCmbrs_Events++;
              }
              //Email
              if( (cmData.Campaign.Channel__c == 'Email' || cmData.Campaign.type == 'Email Blast' )  && ( cmData.Status == 'Converted' || cmData.Status == 'Opened' || cmData.Status == 'Clicked' || cmData.Status == 'Clicked 1 Email' || cmData.Status == 'Clicked 2 Email' || cmData.Status == 'Clicked 3 Email' || cmData.Status == 'Clicked 4 Email' || cmData.Status == 'Clicked 5 Email' || cmData.Status == 'Clicked 6 Email' || cmData.Status == 'Clicked 7 Email' || cmData.Status == 'Clicked 8 Email' || cmData.Status == 'Clicked 9 Email' || cmData.Status == 'Clicked 10 Email')){
                intNumberOfCmbrs_Email++;
              }
              if(cmData.Campaign.Channel__c == 'Telemarketing' && (cmData.Status == 'Engaged')){
                intNumberOfCmbrs_Telemarketing++;
              }
              if(cmData.Campaign.Channel__c == 'DirectMail' && (cmData.Status == 'Sent')){
                intNumberOfCmbrs_DirectMail++;
              }

            marketingTouches++;
          
            cmsLastinputDate = cmdata.CreatedDate;  
            cmsLast2inputName = cmdata.Campaign.Name;  
            cmsLast2inputType = cmdata.Campaign.Type;   



        }
          intNumberOfCmbrs_Total = intNumberOfCmbrs_Webinars + intNumberOfCmbrs_Events + intNumberOfCmbrs_Website + intNumberOfCmbrs_Advertising + intNumberOfCmbrs_Email;

        //Contact Object Field Update
            //Tally of all touches mapped to contact object fields 
          Conz.Number_of_Webinar_Touches__c = intNumberOfCmbrs_Webinars;
          Conz.Number_of_Email_Touches__c = intNumberOfCmbrs_Email;
          Conz.Number_of_Advertising_Touches__c = intNumberOfCmbrs_Advertising;
          Conz.Number_of_Website_Touches__c = intNumberOfCmbrs_Website;
          Conz.Total_Number_Of_Touches__c = intNumberOfCmbrs_Total;
          Conz.Number_of_Event_Touches__c = intNumberOfCmbrs_Events;
          Conz.Number_of_Telemarketing_Touches__c= intNumberOfCmbrs_Telemarketing;
          Conz.Number_of_DirectMail_Touches__c = intNumberOfCmbrs_DirectMail;
            //First & Last Touch Information
                //First Touch
          Conz.First_Meaningful_Touch_Campaign_Name__c = cmsFirst2inputName;
          Conz.First_Meaningful_Touch_Campaign_type__c = cmsFirst2inputtype;
          Conz.First_Meaningful_Touch_Date__c = cmsFirstinputDate;
                //Last Touch
          Conz.Last_Meaningful_Touch_Campaign_Name__c = cmsLast2inputName;
          Conz.Last_Meaningful_Touch_Campaign_type__c = cmsLast2inputtype;
          Conz.Last_Meaningful_Touch_Date__c = cmsLastinputDate;              
       

       update con; 
      
      }

    }   
    global void finish(Database.BatchableContext BC)
    {
    }
}