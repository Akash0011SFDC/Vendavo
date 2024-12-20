global class countWebVisits implements Database.Batchable<sObject> {
	
	
    public String query = 'SELECT Id FROM Account';

	

	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

   	 global void execute(Database.BatchableContext BC, List<Account> accounts){   

         Date date30DaysAgo = system.today().addDays(-30);
         Date date7DaysAgo = system.today().addDays(-7);
         Integer pageVisit7Days = 0;
         Integer pageVisit30Days = 0;
	     String lastPage = '';


         list <Kickfire__c> kickfireList;
			 
    	  for(Account myAccount : accounts){
    	  	pageVisit7Days = 0;
	        pageVisit30Days = 0;
	        lastPage = '';
	        for(Kickfire__c kickfire : kickfireList = [SELECT Account__c,Name, Page_Visit_Datetime__c FROM Kickfire__c WHERE Account__c = : myAccount.id AND Page_Visit_Datetime__c > :date30DaysAgo ORDER BY Page_Visit_Datetime__c DESC]){
	        	
	        	if(kickfireList.size() != 0){
		        	String newPage = kickfire.Page_Visit_Datetime__c + kickfire.name;
		        	if(lastPage != newPage ){
		        		if (kickfire.Page_Visit_Datetime__c > date7DaysAgo){
		        			pageVisit7Days++;
		        		}//endif 7days
		        		pageVisit30Days++;
						lastPage = kickfire.Page_Visit_Datetime__c + kickfire.name;	        		
					}//end if samepage
		    	  }//end kickfor
	    	  }//end if size

		    myAccount.Page_Visit_Last_7_Days__c = pageVisit7Days;
		    myAccount.Page_Visit_Last_30_Days__c = pageVisit30Days;
	    }//end acct for
	    update accounts;
	}
	
	global void finish(Database.BatchableContext BC) {
		
	}
	

	

	
}