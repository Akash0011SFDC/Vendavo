/*
 *  Triggers if the box is checked for sap cases to transfer to the proper account if the contact is in the system
 *  @author Peter Yim
 *  @date Mar 19 2019
 * 
 * 
 */


global class updateSapCasestoRealAccounts implements Database.Batchable<sObject>
{
	public String dummyAccount = '0015000000GFQQRAA5';
    public String query = 'SELECT ID, ReporterEmail__c FROM Case WHERE ReporterEmail__c != null AND AccountId = : dummyAccount AND CaseToTransfer__c = TRUE';

    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        return Database.getQueryLocator(query);
    }
   
    global void execute(Database.BatchableContext BC, List<Case> cas)
    {  

     Database.DMLOptions dmo = new Database.DMLOptions();
	 dmo.assignmentRuleHeader.useDefaultRule = FALSE;

   
     for(Case updateCase : cas ){
      List <Contact> contactList = [SELECT Id, AccountId FROM Contact  WHERE email = : updateCase.ReporterEmail__c LIMIT 1 ];
      if(contactList.size() != 0){
	     	for( Contact contz : contactList ){   	
	     		updateCase.ContactId = contz.Id;
	     		updateCase.AccountId = contz.AccountId;
	     		updateCase.CaseToTransfer__c = FALSE;
	     		updateCase.setOptions(dmo);
	     	}
		}//end for contacts
	}//end size;
		update cas;
	}

    

    	global void finish(Database.BatchableContext BC) {
		
	}
	

}