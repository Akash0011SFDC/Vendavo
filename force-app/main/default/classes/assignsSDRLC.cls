/*
 * accassignsSDRLC reassign Lead and contact Owner if the account has a sdr, and match the lead and contact owner if the current owner is a SDR
 * @Author: Peter Yim
 * @Date: 2017
 *
 */
global class assignsSDRLC implements Database.Batchable<sObject>
{
        Public String query = 'SELECT ID, SDR__c FROM Account WHERE SDR__c != NULL';

    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        return Database.getQueryLocator(query);
    }
   
    global void execute(Database.BatchableContext BC, List<Account> accs)
    {  
  
    	 list <Lead> leadsInAccount;
       list <Contact> contactInAccount;
       String acctSdr;
       String mikeKrug = '00550000002YkQz';


         // SDR Queue '00538000004bcHy';
         // Rich '00550000004U4mP' ;
         // Shirin '00538000004bl4Z';
         // alcia '00550000003vZZP';
      for(Account accs2Query : accs){

        acctSdr = accs2Query.SDR__c;

        if(acctSdr != mikeKrug){
          for(Lead ldz : leadsInAccount = [SELECT Id, OwnerId,  Status, Behavior_Score__c, Demographic_Score__c FROM Lead WHERE Lead.OwnerId in ('00538000004bcHy','00550000004U4mP','00538000004bl4Z','00550000003vZZP') AND Lead.LeanData__Reporting_Matched_Account__r.Id = : accs2query.id]){
            if (ldz.OwnerId != acctSdr && ldz.OwnerId != mikeKrug){
              ldz.OwnerId = acctSdr;
            }            
          }
          for(Contact conz : contactInAccount = [SELECT Id,  OwnerId,   Status__c, Behavior_Score__c, Demographic_Score__c FROM Contact WHERE OwnerId in ('00538000004bcHy','00550000004U4mP','00538000004bl4Z','00550000003vZZP') AND AccountID = : accs2query.id]){
              if (conz.OwnerId != acctSdr && conz.OwnerId != mikeKrug){
              conz.OwnerId = acctSdr;
            }            
          }

          update leadsInAccount;
          update contactInAccount;

          } //end if not mike krug
            

      }
    }   
    global void finish(Database.BatchableContext BC)
    {
    }
}