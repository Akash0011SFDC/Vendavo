trigger OppCloseLost on Opportunity (before update) {
    integer newChange = 0;
    
  for(Opportunity oppOLD : Trigger.old){
      if(oppOLD.StageName != 'Closed Lost' ){
        newChange = 1;
      }     
    }

 
  for(Opportunity opp : Trigger.new){
      if(opp.StageName == 'Closed Lost' && newChange == 1 ){
      //  opp.CloseDate  = system.today();
      }     
    }

}