trigger autoChangeForcast on Opportunity (before update) {
    for(Opportunity t : Trigger.New) {
     list <Opportunity> o;

        if(t.StageName == 'Unqualified' || t.StageName == 'Closed Lost'  || t.StageName == 'M2. Lead - Actively Engaged' || t.StageName == 'M1. Nurture' ){
           // t.Probability = 0;     
           // t.Vendavo_Forecast_Category__c = 'Omitted';


        }//end if stage

         if(t.StageName == 'Closed Won' ){
            //t.Probability = 100;     
           // t.Vendavo_Forecast_Category__c = 'Closed Won';


        }//end if stage

     

        }
}