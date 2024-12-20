global class moveAmountToPL implements Database.Batchable<sObject> {
	
	
	public String query = 'SELECT Id, amount, Perpetual_License__c FROM Opportunity';
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}


	

   	global void execute(Database.BatchableContext BC, List<Opportunity> oppt) {
		

		for(Opportunity o : oppt){
		   o.Perpetual_License__c = o.amount ; 
		}

		update oppt;


	}
	
	global void finish(Database.BatchableContext BC) {
		
	}
	
}