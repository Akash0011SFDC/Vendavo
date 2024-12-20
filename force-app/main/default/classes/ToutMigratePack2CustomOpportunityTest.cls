@isTest
public class ToutMigratePack2CustomOpportunityTest {
    @testSetup
    static void setup() {

        Opportunity t = new Opportunity(
            Name='Honey Pot',
            StageName='prospecting',
            CloseDate=Date.today(),
            ToutApp__Tout_Current_Campaign__c = '1',
            ToutApp__Tout_Last_Activity__c = DateTime.newInstance(1986, 1, 3, 15, 03, 22),
            ToutApp__Tout_Last_Engagement__c = DateTime.newInstance(1986, 1, 3, 15, 03, 23),
            ToutApp__Tout_Last_Replied__c = DateTime.newInstance(1986, 1, 3, 15, 03, 24)
        );
        insert t;
    }
    static testmethod void test() {
        Test.startTest();
        ToutMigratePack2CustomOpportunity task = new ToutMigratePack2CustomOpportunity();
        Id batchId = Database.executeBatch(task);
        Test.stopTest();

        System.assertEquals(1, ToutMigratePack2CustomOpportunity.totalCount());
        System.assertEquals(1, ToutMigratePack2CustomOpportunity.batchesCount());

        Opportunity result = [select
                        MSE_Current_Campaign__c,
                        MSE_Last_Activity__c,
                        MSE_Last_Engagement__c,
                        MSE_Last_Replied__c
                       from Opportunity];
        System.assertEquals('1', result.MSE_Current_Campaign__c);
        System.assertEquals(DateTime.newInstance(1986, 1, 3, 15, 03, 22), result.MSE_Last_Activity__c);
        System.assertEquals(DateTime.newInstance(1986, 1, 3, 15, 03, 23), result.MSE_Last_Engagement__c);
        System.assertEquals(DateTime.newInstance(1986, 1, 3, 15, 03, 24), result.MSE_Last_Replied__c);
    }
}