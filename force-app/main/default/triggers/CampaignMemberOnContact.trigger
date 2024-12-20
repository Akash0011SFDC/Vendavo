trigger CampaignMemberOnContact on CampaignMember ( after insert ) {

    Set<Id> conId = new Set<Id>();
   // List<Id> aId= new List<Id>();
/**
    //All campaigns 
    if(Trigger.isAfter){
        for(CampaignMember opp : Trigger.new){
            conId.add(opp.ContactId);
        }
         List<Contact> con = [select id,Total_number_of_touches__c from Contact where Id in:conId];
         List<CampaignMember > cms = [select id from CampaignMember where (
       
        //Events SOQL
                     //Profit Summit Touches 
        ((((((CampaignMember.campaign.type = 'Profit Summit') AND (CampaignMember.Status = 'Attended' OR CampaignMember.Status = 'Registered' OR CampaignMember.Status = 'No Show'))) 
        OR
                    //Trade Show Touches 
                    (((((campaignmember.campaign.type = 'tradeshow' OR campaignmember.campaign.type = 'trade show') AND (CampaignMember.Status = 'Visited Booth' OR CampaignMember.Status = 'Visited Booth - Hot Lead' OR CampaignMember.Status = 'Requested Meeting'   OR  CampaignMember.Status = 'Attended'))) 
                    //Field Events & Field Event - User Group
                        OR
                    (((((campaignmember.campaign.type = 'Field Event' OR campaignmember.campaign.type = 'Field Event - User Group') AND (CampaignMember.Status = 'Attended' OR CampaignMember.Status = 'Registered' OR CampaignMember.Status = 'No Show'))))))))))
       
        OR
        //Webinar SOQL 
        (campaignmember.campaign.Channel__c = 'Webinar' AND (CampaignMember.Status = 'Attended' OR CampaignMember.Status = 'Attended On-Demand' OR CampaignMember.Status = 'No Show' OR CampaignMember.Status = 'Registered'))
        OR
        //Advertising SOQL 
        (Campaign.Channel__c = 'Advertising' AND ((((Campaign.type = 'Google AdWords' OR Campaign.type = 'Advertising') AND (Status = 'Clicked' OR Status = 'Converted')) OR (Campaign.type = 'Lead Accelerator' AND (Status = 'Downloaded' OR  Status = 'Subscribed' OR Status = 'Registered' ))))) OR

        //Website SOQL
        (Campaign.Channel__c = 'Website' AND (Status = 'Subscribed' OR Status = 'Requested Contact' OR Status = 'Downloaded' OR Status = 'Visited Page') ) 
        OR
        //Email SOQL
        (Campaign.Channel__c = 'Email' AND ( Status = 'Clicked' OR Status = 'Clicked 1 Email' OR Status = 'Clicked 2 Email' OR Status = 'Clicked 3 Email' OR Status = 'Clicked 4 Email' OR Status = 'Clicked 5 Email' OR Status = 'Clicked 6 Email' OR Status = 'Clicked 7 Email' OR Status = 'Clicked 8 Email' OR Status = 'Clicked 9 Email' OR Status = 'Clicked 10 Email')) 
            )
        AND ContactId in :conId];

         
        
        for(Contact c : con){
            c.Total_number_of_touches__c = cms.size();
           
          
        }  update con; 
    }

    //For Events

       if(Trigger.isAfter){
        for(CampaignMember opp : Trigger.New){
            conId.add(opp.ContactId);
        }
        List<Contact> con2 = [select id,Total_number_of_touches__c ,Number_of_Event_touches__c  from Contact where Id in:conId];
        List<CampaignMember > cms2 = [SELECT ID from CampaignMember 
        where 
        //Profit Summit Touches 
        (((((CampaignMember.campaign.type = 'Profit Summit') AND (CampaignMember.Status = 'Attended' OR CampaignMember.Status = 'Registered' OR CampaignMember.Status = 'No Show'))) 
        OR
        //Trade Show Touches 
        (((((campaignmember.campaign.type = 'tradeshow' OR campaignmember.campaign.type = 'trade show') AND (CampaignMember.Status = 'Visited Booth' OR CampaignMember.Status = 'Visited Booth - Hot Lead' OR CampaignMember.Status = 'Requested Meeting'   OR  CampaignMember.Status = 'Attended'))) 
        //Field Events & Field Event - User Group
        OR
        (((((campaignmember.campaign.type = 'Field Event' OR campaignmember.campaign.type = 'Field Event - User Group') AND (CampaignMember.Status = 'Attended' OR CampaignMember.Status = 'Registered' OR CampaignMember.Status = 'No Show'))))))))) 

        AND ContactId in :conId];
        
        for(Contact c : con2){
            c.Number_of_Event_touches__c = cms2.size();
            
        }update con2;
    }
    
    
    //For Webinars
       if(Trigger.isAfter){
        for(CampaignMember opp : Trigger.New){
            conId.add(opp.ContactId);
        }
        List<Contact> con3 = [select id,Total_number_of_touches__c ,Number_of_Webinar_touches__c  from Contact where Id in:conId];
        List<CampaignMember > cms3 = [select id from CampaignMember where 
        campaignmember.campaign.Channel__c = 'Webinar' AND (CampaignMember.Status = 'Attended' OR CampaignMember.Status = 'Attended On-Demand' OR CampaignMember.Status = 'No Show' OR CampaignMember.Status = 'Registered')
        AND ContactId in :conId];
        
        for(Contact c : con3){
            c.Number_of_Webinar_touches__c = cms3.size();
            
        }update con3;
    }

    //For Advertising 

     if(Trigger.isAfter){
        for(CampaignMember opp : Trigger.new){
            conId.add(opp.ContactId);
        }
        List<Contact> con4 = [select id,Total_number_of_touches__c, Number_of_advertising_touches__c from Contact where Id in:conId];
        List<CampaignMember > cms4 = [select id from CampaignMember where Campaign.Channel__c = 'Advertising' AND ((((Campaign.type = 'Google AdWords' OR Campaign.type = 'Advertising') AND (Status = 'Clicked' OR Status = 'Converted')) OR (Campaign.type = 'Lead Accelerator' AND (Status = 'Downloaded' OR  Status = 'Subscribed' OR Status = 'Registered' )))) AND ContactId in :conId];
         
        
        for(Contact c : con4){
            c.Number_of_advertising_touches__c = cms4.size();
           
          
        }  update con4; 
    }



    //For Website
     if(Trigger.isAfter){
        for(CampaignMember opp : Trigger.new){
            conId.add(opp.ContactId);
        }
        List<Contact> con5 = [select id, Number_of_website_touches__c from Contact where Id in:conId];
        List<CampaignMember > cms5 = [select id from CampaignMember where Campaign.Channel__c = 'Website' AND (Status = 'Subscribed' OR Status = 'Requested Contact' OR Status = 'Downloaded' OR Status = 'Visited Page') AND ContactId in :conId];
         
        
        for(Contact c : con5){
            c.Total_number_of_touches__c = cms5.size();
           
          
        }  update con5; 
    }


    //For Email

    if(Trigger.isAfter){
        for(CampaignMember opp : Trigger.new){
            conId.add(opp.ContactId);
        }
        List<Contact> con6 = [select id,Number_of_email_touches__c from Contact where Id in:conId];
        List<CampaignMember > cms6 = [select id from CampaignMember where Campaign.Channel__c = 'Email' AND ( Status = 'Clicked' OR Status = 'Clicked 1 Email' OR Status = 'Clicked 2 Email' OR Status = 'Clicked 3 Email' OR Status = 'Clicked 4 Email' OR Status = 'Clicked 5 Email' OR Status = 'Clicked 6 Email' OR Status = 'Clicked 7 Email' OR Status = 'Clicked 8 Email' OR Status = 'Clicked 9 Email' OR Status = 'Clicked 10 Email') AND ContactId in :conId];
         
        
        for(Contact c : con6){
            c.Number_of_email_touches__c = cms6.size();
           
          
        }  update con6; 
    }
    */
    //Number of Successes
      if(Trigger.isAfter){
        for(CampaignMember opp : Trigger.new){
            conId.add(opp.ContactId);
        }
        List<Contact> con7 = [select id, Number_of_Successes__c from Contact where Id in:conId];
        List<CampaignMember > cms7 = [select id from CampaignMember where 
        Success__c = True AND Campaign.Name = 'No Campaign So This Thing Wont Run'
        AND ContactId in :conId];
         
        
        for(Contact c : con7){
            c.Number_of_Successes__c = cms7.size();
           
          
        }  update con7;

    }


        
         
}