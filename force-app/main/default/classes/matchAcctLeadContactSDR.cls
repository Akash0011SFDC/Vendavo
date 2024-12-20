/*
 * matchAcctLeadContactSDR Assign SDR Owner of lead and contact where the account owner is a SDR
 * @Author: Peter Yim
 * @Date: 2017
 *
 */

global class matchAcctLeadContactSDR implements Database.Batchable<sObject> {
	public String rich = '00550000004U4mP';
	public String alcia = '00550000003vZZP';
	
	public String query = 'SELECT ID, SDR__c FROM Account WHERE SDR__c = : rich OR SDR__c = : alcia ';
    


	global matchAcctLeadContactSDR(){

	}
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC,  List<Account> Acct) {
	        List <Contact> contactList = new List <Contact>();
	        List <Lead>    leadList = new List <Lead>();  	
     for(Account acct2update : Acct ){
	     	for( Contact contz : contactList = [SELECT ID FROM Contact  WHERE OwnerId = '00538000004bcHy' AND AccountID = : acct2update.id ]){
	     		contz.OwnerId = acct2update.SDR__c;

	     	}
	     	update contactList;

	     	for( Lead leadz : leadList = [SELECT Id FROM Lead WHERE OwnerId = '00538000004bcHy' AND  LeanData__Reporting_Matched_Account__c = : acct2update.id ]){
	     		leadz.OwnerId = acct2update.SDR__c;
	     	}
	     	update leadList;
		}//end of for
	}
	
	global void finish(Database.BatchableContext BC) {
		
	}
	
}