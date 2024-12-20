/*
 * matchAcctSDRRouting Assign SDR to Accounts based off 2017 Tam Industries Alignment 
 * @Author: Peter Yim
 * @Date: 2017
 *
 */

global class matchAcctSDRRouting implements Database.Batchable<sObject> {
	
	public String emea = 'EMEA';
	
	public String query = 'SELECT ID, SDR__c,  Industry,Region__c,TAM_Industry__c,TAM_Sub_Industry__c,TAM__c FROM Account WHERE Region__C != : emea ';
    


	global matchAcctSDRRouting(){

	}
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC,  List<Account> Acct) {
        List <Contact> contactList = new List <Contact>();
        List <Lead>    leadList = new List <Lead>();  	
        String accountSDR = '';
     for(Account acct2update : Acct ){

     	accountSDR = acct2update.SDR__c;
     	if(acct2update.Region__c != 'EMEA'){


     	 	if(acct2update.SDR__c == NULL || (acct2update.SDR__c != '00550000004U4mP' && acct2update.SDR__c != '00550000003vZZP' ) ){
     	
     	//if rich

	     	if ( (acct2update.Industry == 'Chemicals, Oil & Gas') || 
	     		(acct2update.Industry == 'Health Care') || 
	     		 (acct2update.Industry == 'Wholesale & Distribution' && acct2update.TAM_Sub_Industry__c == NULL) || 
	     		 ( (acct2update.TAM_Industry__c == 'Manufacturing' || acct2update.Industry == 'Manufacturing') && (acct2update.TAM_Sub_Industry__c == 'Pharma and Medical Devices' || acct2update.TAM_Sub_Industry__c == 'Food and Beverages') ) ){
			     
			      accountSDR = '00550000004U4mP';		
			      acct2update.SDR__c = '00550000004U4mP';		
	     		}
	     	   
	     		//if alcia

	     	   if ( 
	     	   		(acct2update.Industry == 'Telco, Media & entertainment') || 
	     	   		(acct2update.TAM_Industry__c == 'High Tech' || acct2update.Industry == 'High Tech' || acct2update.Industry.contains('Tech') || acct2update.TAM_Sub_Industry__c == 'High Tech') || 
	     		 	((acct2update.TAM_Industry__c == 'Manufacturing' || acct2update.Industry == 'Manufacturing' || acct2update.Industry.contains('Manufacturing') ) && (acct2update.TAM_Sub_Industry__c != 'Pharma and Medical Devices' && acct2update.TAM_Sub_Industry__c != 'Food and Beverages') ) 
	     		  ){
			     
			      accountSDR = '00550000003vZZP';		
			      acct2update.SDR__c = '00550000003vZZP';		
	     		}
	     	   
	     	}//endif sdr null


	     	if(accountSDR != ''){
		     	for( Contact contz : contactList = [SELECT ID FROM Contact  WHERE OwnerId = '00538000004bcHy' AND AccountID = : acct2update.id ]){
	     			contz.OwnerId = accountSDR;
		     	}
			    update contactList;

			    for( Lead leadz : leadList = [SELECT Id FROM Lead WHERE  OwnerId = '00538000004bcHy'   AND ConvertedDate = null AND   LeanData__Reporting_Matched_Account__c = : acct2update.id ]){
			   		leadz.OwnerId = accountSDR;
			   	}
			    update leadList;
			} //end if no sdr assigned


	     }//endif emea

		}//end of for

		update Acct;

	
     	
	}
	
	global void finish(Database.BatchableContext BC) {
		
	}
	
}