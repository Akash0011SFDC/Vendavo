public class keysInAcctVFP {
public String currentRecordId {get;set;}
public String parameterValue {get;set;}
public Account acc{get;set;}
private final Keyword__c keys{get;set;}
private final Account acct;


     public ApexPages.StandardSetController setCon {
        get {
            if(setCon == null) {
                currentRecordId  = ApexPages.CurrentPage().getparameters().get('id');
                setCon = new ApexPages.StandardSetController(Database.getQueryLocator(
                    [select name, Domain__c, Score__c from Keyword__c where Account__c =: ApexPages.currentPage().getParameters().get('id') ]));
            }
            return setCon;
        }
         set;

    }
     public keysInAcctVFP(ApexPages.StandardController setCon) {
        this.acct = (Account)setCon.getRecord();
    }

      public List<Keyword__c> getKeywords() {
        return (List<Keyword__c>) setCon.getRecords();
    }
  
}