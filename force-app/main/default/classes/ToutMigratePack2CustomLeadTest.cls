@isTest
public class ToutMigratePack2CustomLeadTest {
    @testSetup
    static void setup() {
        Lead t = new Lead(
            LastName='Winnie',
            Company='Honey Pots Inc.',
            ToutApp__Tout_Current_Campaign__c = '1',
            ToutApp__Tout_Last_Activity__c = DateTime.newInstance(1986, 1, 3, 15, 03, 22),
            ToutApp__Tout_Last_Engagement__c = DateTime.newInstance(1986, 1, 3, 15, 03, 23),
            ToutApp__Tout_Last_Replied__c = DateTime.newInstance(1986, 1, 3, 15, 03, 24)
        );
        insert t;
    }
    static testmethod void test() {
        Test.startTest();
        ToutMigratePack2CustomLead task = new ToutMigratePack2CustomLead();
        Id batchId = Database.executeBatch(task);
        Test.stopTest();

        System.assertEquals(1, ToutMigratePack2CustomLead.totalCount());
        System.assertEquals(1, ToutMigratePack2CustomLead.batchesCount());

        Lead result = [select
                        MSE_Current_Campaign__c,
                        MSE_Last_Activity__c,
                        MSE_Last_Engagement__c,
                        MSE_Last_Replied__c
                       from Lead];
        System.assertEquals('1', result.MSE_Current_Campaign__c);
        System.assertEquals(DateTime.newInstance(1986, 1, 3, 15, 03, 22), result.MSE_Last_Activity__c);
        System.assertEquals(DateTime.newInstance(1986, 1, 3, 15, 03, 23), result.MSE_Last_Engagement__c);
        System.assertEquals(DateTime.newInstance(1986, 1, 3, 15, 03, 24), result.MSE_Last_Replied__c);
    }
}