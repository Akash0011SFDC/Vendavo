trigger matchAmount on Opportunity (before update) {
  for(Opportunity t : Trigger.New) { 
        if(t.Pricebook2Id == null  ){
          t.amount = t.Total_Opportunity_Amount__c;     
      }//end if no price book
 } //end for
}