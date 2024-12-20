// Created: 08/2014
// Kyle Halstvedt
// Elixiter
// kyle@elixiter.com
// -----------------
@isTest
public class LeadStatusTest {  
    // create test lead and tasks for 'disqualified' status
    static testMethod void testPropagateDisqualified() {
        // create test lead
        Lead lead = new Lead(FirstName='Disqualified', LastName='Lead', Country='USA', Company='Testing, Inc.');
        System.debug('Lead status before insert: ' + lead.Status);
        insert lead;
        // create test task and assign it to lead record via WhoId
        Task task = new Task(Subject='Test task', Description='This is a task created as part of an Apex unit test. it really should not exist', Type='Test', WhoId=lead.Id);
        System.debug('Task status before insert: ' + task.Status);
        System.debug('Task type before insert: ' + task.Type);
        insert task;
        // retrieve saved lead
        lead = [SELECT Status FROM Lead WHERE Id = :lead.Id];
        System.debug('Lead status after retrieval: ' + lead.Status);
        // retrieve saved task(s)
        task = [SELECT Status, Type FROM Task WHERE WhoId = :lead.Id];
        System.debug('Task status after retrieveal: ' + task.Status);
        System.debug('Task type after retrieval: ' + task.Type);
        // disqualify lead
        lead.Status = 'Disqualified';
        update lead;
        
        // retrieve final records
        lead = [SELECT Id, Status FROM Lead WHERE Id = :lead.Id];
        task = [SELECT Status, Type FROM Task WHERE WhoId = :lead.Id];
        // lead status check
        System.debug('Lead status after disqualified: ' + lead.Status);
        System.assertEquals('Disqualified', lead.Status, 'lead status is incorrect');
        // task check
        System.debug('Task status after disqualified: ' + task.Status);
        System.assertEquals('Completed', task.Status, 'task status is incorrect');
        System.debug('Task type after disqualified: ' + task.Type);
        System.assertEquals('Disqualified', task.Type, 'task type is incorrect');
    }
    // create test lead and tasks for 'recycled' status
    static testMethod void testPropagateRecycled() {
        // create test lead
        Lead lead = new Lead(FirstName='Recycled', LastName='Lead', Country='USA', Company='Testing, Inc.');
        System.debug('Lead status before insert: ' + lead.Status);
        insert lead;
        // create test task and assign it to lead record via WhoId
        Task task = new Task(Subject='Test task', Description='This is a task created as part of an Apex unit test. it really should not exist', Type='Test', WhoId=lead.Id);
        System.debug('Task status before insert: ' + task.Status);
        System.debug('Task type before insert: ' + task.Type);
        insert task;
        // retrieve saved lead
        lead = [SELECT Status FROM Lead WHERE Id = :lead.Id];
        System.debug('Lead status after retrieval: ' + lead.Status);
        // retrieve saved task(s)
        task = [SELECT Status, Type FROM Task WHERE WhoId = :lead.Id];
        System.debug('Task status after retrieveal: ' + task.Status);
        System.debug('Task type after retrieval: ' + task.Type);
        // recycle lead
        lead.Status = 'Recycled';
        update lead;
        
        // retrieve final records
        lead = [SELECT Id, Status FROM Lead WHERE Id = :lead.Id];
        task = [SELECT Status, Type FROM Task WHERE WhoId = :lead.Id];
        // lead status check
        System.debug('Lead status after recycled: ' + lead.Status);
        System.assertEquals('Recycled', lead.Status, 'lead status is incorrect');
        // task check
        System.debug('Task status after recycled: ' + task.Status);
        System.assertEquals('Completed', task.Status, 'task status is incorrect');
        System.debug('Task type after recycled: ' + task.Type);
        System.assertEquals('Recycled', task.Type, 'task type is incorrect');
    }
}