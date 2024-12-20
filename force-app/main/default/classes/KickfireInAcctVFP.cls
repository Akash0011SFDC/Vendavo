public class KickfireInAcctVFP {
public String currentRecordId {get;set;}
public String parameterValue {get;set;}
public Account acc{get;set;}
private final Kickfire__c kickfire {get;set;}
private final Account acct;


     public ApexPages.StandardSetController setCon {
        get {
            if(setCon == null) {
                currentRecordId  = ApexPages.CurrentPage().getparameters().get('id');
                setCon = new ApexPages.StandardSetController(Database.getQueryLocator(
                    [select name, Page_Visit_Datetime__c, identity__c, Referral__c from Kickfire__c where Account__c =: ApexPages.currentPage().getParameters().get('id') ORDER BY Page_Visit_Datetime__c DESC ]));
            }
            return setCon;
        }
         set;

    }
     public KickfireInAcctVFP(ApexPages.StandardController setCon) {
        this.acct = (Account)setCon.getRecord();
    }

      public List<Kickfire__c> getKickfires() {
        return (List<Kickfire__c>) setCon.getRecords();
    }
  
}