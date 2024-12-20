global class ToutMigratePack2CustomEvent implements Database.Batchable<sObject>
{
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        String query =
                     'SELECT id,'+
                    'ToutApp__Tout_Call_Local_Presence_ID__c,'+
                    'ToutApp__Tout_Call_Recording__c,'+
                    'ToutApp__Tout_Campaign__c,'+
                    'ToutApp__Tout_Campaign_Details_Link__c,'+
                    'ToutApp__Tout_Clicked__c,'+
                    'ToutApp__Tout_Details__c,'+
                    'ToutApp__Tout_Presentation_Viewed__c,'+
                    'ToutApp__Tout_Replied__c,'+
                    'ToutApp__Tout_Template__c,'+
                    'ToutApp__Tout_Template_Details__c,'+
                    'ToutApp__Tout_Viewed__c '+
                    'FROM Event '+
                    'WHERE '+
                    'ToutApp__Tout_Call_Local_Presence_ID__c != null OR '+
                    'ToutApp__Tout_Call_Recording__c != null OR '+
                    'ToutApp__Tout_Campaign__c != null OR '+
                    'ToutApp__Tout_Campaign_Details_Link__c != null OR '+
                    'ToutApp__Tout_Clicked__c != null OR '+
                    'ToutApp__Tout_Details__c != null OR '+
                    'ToutApp__Tout_Presentation_Viewed__c != null OR '+
                    'ToutApp__Tout_Replied__c != null OR '+
                    'ToutApp__Tout_Template__c != null OR '+
                    'ToutApp__Tout_Template_Details__c != null OR '+
                    'ToutApp__Tout_Viewed__c != null';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Event> scope)
    {
        for (Event s : scope)
        {
            s.MSE_Call_Local_Presence_ID__c = s.ToutApp__Tout_Call_Local_Presence_ID__c;
            s.MSE_Call_Recording__c = s.ToutApp__Tout_Call_Recording__c;
            s.MSE_Campaign__c = s.ToutApp__Tout_Campaign__c;
            s.MSE_Campaign_Details_Link__c = s.ToutApp__Tout_Campaign_Details_Link__c;
            s.MSE_Clicked__c = s.ToutApp__Tout_Clicked__c;
            s.MSE_Details__c = s.ToutApp__Tout_Details__c;
            s.MSE_Presentation_Viewed__c = s.ToutApp__Tout_Presentation_Viewed__c;
            s.MSE_Replied__c = s.ToutApp__Tout_Replied__c;
            s.MSE_Template__c = s.ToutApp__Tout_Template__c;
            s.MSE_Template_Details__c = s.ToutApp__Tout_Template_Details__c;
            s.MSE_Viewed__c = s.ToutApp__Tout_Viewed__c;
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
                         FROM Event
                         WHERE ToutApp__Tout_Call_Local_Presence_ID__c != null OR
                               ToutApp__Tout_Call_Recording__c != null OR
                               ToutApp__Tout_Campaign__c != null OR
                               ToutApp__Tout_Campaign_Details_Link__c != null OR
                               ToutApp__Tout_Clicked__c != null OR
                               ToutApp__Tout_Details__c != null OR
                               ToutApp__Tout_Presentation_Viewed__c != null OR
                               ToutApp__Tout_Replied__c != null OR
                               ToutApp__Tout_Template__c != null OR
                               ToutApp__Tout_Template_Details__c != null OR
                               ToutApp__Tout_Viewed__c != null][0].get('amount');
    }

    global static Long batchesCount()
    {
        return (((Decimal)totalCount()) / 2000.0).round(System.RoundingMode.UP);
    }
}