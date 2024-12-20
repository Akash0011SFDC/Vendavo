@isTest
public class ToutMigratePack2CustomAccountTest {
    @testSetup
    static void setup() {
        Account t = new Account(
            Name='Honey Pots Inc.',
            ToutApp__Tout_Current_Campaign__c = '1',
            ToutApp__Tout_Last_Activity__c = DateTime.newInstance(1986, 1, 3, 15, 03, 22),
            ToutApp__Tout_Last_Engagement__c = DateTime.newInstance(1986, 1, 3, 15, 03, 23),
            ToutApp__Tout_Last_Replied__c = DateTime.newInstance(1986, 1, 3, 15, 03, 24)
        );
        insert t;
    }
    static testmethod void test() {
        Test.startTest();
        ToutMigratePack2CustomAccount task = new ToutMigratePack2CustomAccount();
        Id batchId = Database.executeBatch(task);
        Test.stopTest();

        System.assertEquals(1, ToutMigratePack2CustomAccount.totalCount());
        System.assertEquals(1, ToutMigratePack2CustomAccount.batchesCount());

        Account result = [select
                        MSE_Current_Campaign__c,
                        MSE_Last_Activity__c,
                        MSE_Last_Engagement__c,
                        MSE_Last_Replied__c
                       from Account];
        System.assertEquals('1', result.MSE_Current_Campaign__c);
        System.assertEquals(DateTime.newInstance(1986, 1, 3, 15, 03, 22), result.MSE_Last_Activity__c);
        System.assertEquals(DateTime.newInstance(1986, 1, 3, 15, 03, 23), result.MSE_Last_Engagement__c);
        System.assertEquals(DateTime.newInstance(1986, 1, 3, 15, 03, 24), result.MSE_Last_Replied__c);
    }
}