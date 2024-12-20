global class leadContactCleanUp implements Database.Batchable<sObject>
{
	   public String query = 'SELECT ID, SIC, SDR__C, Region__c FROM Account WHERE SDR__C != NULL  ';
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        return Database.getQueryLocator(query);
    }
   
    global void execute(Database.BatchableContext BC, List<Account> accs)
    {  

       list <Lead> leadsInAccount;
       list <Contact> contactInAccount;
      for(Account accs2Query : accs){

       if(accs2Query.Region__C != 'EMEA' || ( accs2Query.Region__C == 'EMEA' && accs2query.SDR__c == NULL ) ){

       }
          for(Lead ldz : leadsInAccount = [SELECT Id, Matched_Account_SDR__c, Matched_Account_SIC__c FROM Lead WHERE Lead.LeanData__Reporting_Matched_Account__r.Id = : accs2query.id ]){
           ldz.Matched_Account_SDR__c = accs2query.SDR__c;
           ldz.Matched_Account_SIC__c = accs2query.SIC;

          }
       

          for(Contact conz : contactInAccount = [SELECT Id, Matched_Account_SDR__c, Status__c, Behavior_Score__c, Demographic_Score__c FROM Contact WHERE AccountID = : accs2query.id ] ){
            conz.Matched_Account_SDR__c = accs2query.SDR__c;
          }

          
          update leadsInAccount;
          update contactInAccount;
       

      }
      update accs;
    }   
    global void finish(Database.BatchableContext BC)
    {
    }
}