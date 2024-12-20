// Created: 08/2014
// Kyle Halstvedt
// Elixiter
// kyle@elixiter.com
// -----------------
@isTest
private class LeadReassignmentTest {
    static testMethod void testRerunAssignment() {
        // create and insert test lead
        Lead l = new Lead(FirstName='Test', LastName='Lead', Country='USA', Company='Testing, Inc.');
        insert l;
        // retrieve created lead
        l = [SELECT Re_assign_lead_trigger__c FROM Lead WHERE Id = :l.Id];
        // set lead reassignment trigger
        l.Re_assign_lead_trigger__c = true;
        // update record, triggering reassignment after update
        update l;
        // test that trigger variable has been reset after reassignment
        l = [SELECT Re_assign_lead_trigger__c, Has_been_reassigned__c FROM Lead WHERE Id = :l.Id];
        System.debug('Reassign trigger: ' + l.Re_assign_lead_trigger__c);
        System.debug('Has been reassigned: ' + l.Has_been_reassigned__c);
        System.assertEquals(false, l.Re_assign_lead_trigger__c);
        System.assertEquals(true, l.Has_been_reassigned__c);
    }

}