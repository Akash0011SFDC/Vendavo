global class ToutMigratePack2CustomAccount implements Database.Batchable<sObject>
{
   
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        String query =
                     'SELECT id,'+
                     'ToutApp__Tout_Current_Campaign__c,'+
                     'ToutApp__Tout_Last_Activity__c,'+
                     'ToutApp__Tout_Last_Engagement__c,'+
                     'ToutApp__Tout_Last_Replied__c '+
                     'FROM Account '+
                     'WHERE ToutApp__Tout_Current_Campaign__c != null OR '+
                     'ToutApp__Tout_Last_Activity__c != null OR '+
                     'ToutApp__Tout_Last_Engagement__c != null OR '+
                     'ToutApp__Tout_Last_Replied__c != null';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Account> scope)
    {
        for (Account s : scope)
        {
            s.MSE_Current_Campaign__c = s.ToutApp__Tout_Current_Campaign__c;
            s.MSE_Last_Activity__c = s.ToutApp__Tout_Last_Activity__c;
            s.MSE_Last_Engagement__c = s.ToutApp__Tout_Last_Engagement__c;
            s.MSE_Last_Replied__c = s.ToutApp__Tout_Last_Replied__c;
        }

        // Update with AllOrNone = false so we still process if there are any failures
        database.update(scope, false);
    }  
    global void finish(Database.BatchableContext BC)
    {
    }

    global static Integer totalCount()
    {
        return (Integer)[SELECT COUNT(Id) amount
                         FROM Account
                         WHERE ToutApp__Tout_Current_Campaign__c != null OR
                               ToutApp__Tout_Last_Activity__c != null OR
                               ToutApp__Tout_Last_Engagement__c != null OR
                               ToutApp__Tout_Last_Replied__c != null][0].get('amount');
    }

    global static Long batchesCount()
    {
        return (((Decimal)totalCount()) / 2000.0).round(System.RoundingMode.UP);
    }
}