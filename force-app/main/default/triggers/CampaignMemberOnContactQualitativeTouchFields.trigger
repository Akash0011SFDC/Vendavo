trigger CampaignMemberOnContactQualitativeTouchFields on CampaignMember (after insert) {
       
           Set<Id> conWithCampaignId = new Set<Id>();
       //First Meaningful Touch (Campaign Name, CampaignMember CreatedDate, and Campaign Type)

    if(Trigger.isAfter){
        for(CampaignMember opp : Trigger.new){
            conWithCampaignId.add(opp.ContactId);
        }
        List<Contact> con8 = [select id, First_Meaningful_Touch_Campaign_Name__c, First_Meaningful_Touch_Campaign_Type__c, First_Meaningful_Touch_Date__c  from Contact where Id in:conWithCampaignId];
        List<CampaignMember > campaignmembers = [select id, CreatedDate from CampaignMember where ContactId in :conWithCampaignId];

        sObject firstMeaningfulTouch0 = [select id from CampaignMember where (
       
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
        AND ContactId in :conWithCampaignId  ORDER BY CreatedDate ASC LIMIT 1];
        
              
       String fMMTcampaignName = (String) firstMeaningfulTouch0.get(Campaign.Name);
       String fMMTcampaignType = (String) firstMeaningfulTouch0.get(Campaign.Type);
       Datetime fMMTcampaignDate = (Datetime) firstMeaningfulTouch0.get('CreatedDate');

         
        
        for(Contact c : con8){
            c.First_Meaningful_Touch_Campaign_Name__c = fMMTcampaignName;
            c.First_Meaningful_Touch_Campaign_Type__c = fMMTcampaignType;
            c.First_Meaningful_Touch_Date__c = fMMTcampaignDate;
           
          
        }  update con8; 

}
}