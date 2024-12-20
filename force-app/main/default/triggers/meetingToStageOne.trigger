trigger meetingToStageOne on Task (after update) {
	for(Task t : Trigger.New) {
     list <Opportunity> o;

        if(t.type == 'Meeting' && (t.Status == 'Completed - Rejected' || t.Status == 'Completed - Advanced') && t.WhatID != NULL){
        	 o = [SELECT StageName, Amount FROM Opportunity WHERE Id = :t.WhatID AND StageName = 'M2. Lead - Actively Engaged' AND (Amount = 0 OR Amount = NULL )];
    		if(o.size() != 0){
    			for (Opportunity newOpp : o){
    				if(t.Status == 'Completed - Advanced'){
                        newOpp.StageName = '1. Suspect Qualification/MQL';
                        newOpp.Amount = 1;     
                    } else {
                        newOpp.StageName = 'Unqualified';

                    }
                   
    			}//for loop opp

    			update o;
    		}//if opp

    	}//end if meeting

     

        }
    }