@isTest
public class ToutMigratePack2CustomContactTest {
    @testSetup
    static void setup() {
        Contact t = new Contact(
            LastName='Winnie',
            ToutApp__Tout_Current_Campaign__c = '1',
            ToutApp__Tout_Last_Activity__c = DateTime.newInstance(1986, 1, 3, 15, 03, 22),
            ToutApp__Tout_Last_Engagement__c = DateTime.newInstance(1986, 1, 3, 15, 03, 23),
            ToutApp__Tout_Last_Replied__c = DateTime.newInstance(1986, 1, 3, 15, 03, 24)
        );
        insert t;
    }
    static testmethod void test() {
        Test.startTest();
        ToutMigratePack2CustomContact task = new ToutMigratePack2CustomContact();
        Id batchId = Database.executeBatch(task);
        Test.stopTest();

        System.assertEquals(1, ToutMigratePack2CustomContact.totalCount());
        System.assertEquals(1, ToutMigratePack2CustomContact.batchesCount());

        Contact result = [select
                        MSE_Current_Campaign__c,
                        MSE_Last_Activity__c,
                        MSE_Last_Engagement__c,
                        MSE_Last_Replied__c
                       from Contact];
        System.assertEquals('1', result.MSE_Current_Campaign__c);
        System.assertEquals(DateTime.newInstance(1986, 1, 3, 15, 03, 22), result.MSE_Last_Activity__c);
        System.assertEquals(DateTime.newInstance(1986, 1, 3, 15, 03, 23), result.MSE_Last_Engagement__c);
        System.assertEquals(DateTime.newInstance(1986, 1, 3, 15, 03, 24), result.MSE_Last_Replied__c);
    }
}