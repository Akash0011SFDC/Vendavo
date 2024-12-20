@isTest
public class ToutMigratePack2CustomEventTest {
    @testSetup
    static void setup() {
        Event t = new Event(
            DurationInMinutes = 42,
            ActivityDateTime = DateTime.newInstance(1986, 1, 3, 15, 03, 22),
            ToutApp__Tout_Call_Local_Presence_ID__c = '1',
            ToutApp__Tout_Call_Recording__c = '2',
            ToutApp__Tout_Campaign__c = '4',
            ToutApp__Tout_Campaign_Details_Link__c = '5',
            ToutApp__Tout_Clicked__c = true,
            ToutApp__Tout_Details__c = '6',
            ToutApp__Tout_Presentation_Viewed__c = true,
            ToutApp__Tout_Replied__c = true,
            ToutApp__Tout_Template__c = '9',
            ToutApp__Tout_Template_Details__c = '10',
            ToutApp__Tout_Viewed__c = true
        );
        insert t;
    }
    static testmethod void test() {
        Test.startTest();
        ToutMigratePack2CustomEvent task = new ToutMigratePack2CustomEvent();
        Id batchId = Database.executeBatch(task);
        Test.stopTest();

        System.assertEquals(1, ToutMigratePack2CustomEvent.totalCount());
        System.assertEquals(1, ToutMigratePack2CustomEvent.batchesCount());

        Event result = [select
                        MSE_Call_Local_Presence_ID__c,
                        MSE_Call_Recording__c,
                        MSE_Campaign__c,
                        MSE_Campaign_Details_Link__c,
                        MSE_Clicked__c,
                        MSE_Details__c,
                        MSE_Presentation_Viewed__c,
                        MSE_Replied__c,
                        MSE_Template__c,
                        MSE_Template_Details__c,
                        MSE_Viewed__c
                       from Event];
        System.assertEquals('1', result.MSE_Call_Local_Presence_ID__c);
        System.assertEquals('2', result.MSE_Call_Recording__c);
        System.assertEquals('4', result.MSE_Campaign__c);
        System.assertEquals('5', result.MSE_Campaign_Details_Link__c);
        System.assertEquals(true, result.MSE_Clicked__c);
        System.assertEquals('6', result.MSE_Details__c);
        System.assertEquals(true, result.MSE_Presentation_Viewed__c);
        System.assertEquals(true, result.MSE_Replied__c);
        System.assertEquals('9', result.MSE_Template__c);
        System.assertEquals('10', result.MSE_Template_Details__c);
        System.assertEquals(true, result.MSE_Viewed__c);
    }
}