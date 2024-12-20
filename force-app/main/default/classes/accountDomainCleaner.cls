/*
 * accountDomainCleaner is created as a one time batch class to update accounts with website data by using the emails of the contacts 
 * @Author: Peter Yim
 * @Date: 2017
 *
 */
global class accountDomainCleaner implements Database.Batchable<sObject> {
	
	public String query = 'SELECT Id, Name FROM Account WHERE Website = NULL';
	
	global accountDomainCleaner() {
		
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<Account> accountList) {
   		 String domain = '';
         Integer domainStrong = 0;
         List <Contact> contactList;  
         List <Lead> leadList;  

		for(Account acct : accountList ){
           domain = '';
           domainStrong = 0;
		   contactList  = [SELECT Email FROM Contact WHERE AccountId = :acct.Id];
          if (contactList.size() != 0){
		       for(Contact conz : contactList){
		        if( conz.Email != NULL && conz.Email.contains('@') ){
		        	String newDomain = conz.Email.split('@').get(1);
					if(domain == ''){
		                domain = newDomain;
		                domainStrong++;
		          } else {
		            if ( domain == newDomain ){
		              domainStrong++;
		            } else if(domainStrong == 1){
		               domain = newDomain;
		               domainStrong = 1;
		            }
		          }

		     }//end if email null
		       acct.Website = domain;
		 }
  	} else{
          leadList  = [SELECT Email FROM Lead WHERE LeanData__Reporting_Matched_Account__c = :acct.Id];
           if (leadList.size() != 0){
	       for(Lead leadz : leadList){
	        if( leadz.Email != NULL && leadz.Email.contains('@') ){
	        	String newDomain = leadz.Email.split('@').get(1);
		          if(domain == ''){
	                domain = newDomain;
	                domainStrong++;
		          } else {
		            if ( domain == newDomain ){
		              domainStrong++;
		            } else if(domainStrong == 1){
		               domain = newDomain;
		               domainStrong = 1;
		            }
		          }
	        }//end if email null
	       acct.Website = domain;
		 }
	  }//end if leadsize
	}//end if contactsize
  if(domain != null){
      update acct;    
  }
}//end acct for
	
	}
	
	global void finish(Database.BatchableContext BC) {
		
	}
	
}