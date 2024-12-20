// Created: 08/2014
// Kyle Halstvedt
// Elixiter
// kyle@elixiter.com
// -----------------
public class LeadStatusClass {
    // propagate lead status changes to 'disqualified' or 'recycled'
    // to task type (copy status)
    public static void propagateStatus(Map<Id,Lead> leadMap) {
    //public static void propagateStatus(Lead[] leads) {
        //Id[] leadIds = new List<Id>();
        // fetch all tasks in a single query
        Task[] tasksQuery = [SELECT Status, Type, WhoId FROM Task WHERE WhoId = :leadMap.keySet() AND isClosed = false];
        Task[] updatedTasks = new List<Task>();
        // build map <Id(Lead), Task>
        Map<Id, Task[]> leadIdToTaskMap = new Map<Id, Task[]>();
        for (Task t :tasksQuery){
            Task[] tasksForLead = new List<Task>();
            // lead already has tasks from prior iteration - add to list
            if (leadIdToTaskMap.get(t.WhoId) != null){
                tasksForLead = LeadIdToTaskMap.get(t.WhoId);
            }
            // no tasks yet - initialize list
            else {
                tasksForLead = new List<Task>();
            }
            tasksForLead.add(t);
            leadIdToTaskMap.put(t.WhoId, tasksForLead);
        }
        // for each lead
        for (Id leadId :leadMap.keySet()){
            Lead l = leadMap.get(leadId);
            // if the lead has tasks
            if (leadIdToTaskMap.containsKey(l.Id)){
                Task[] tasksForLead = leadIdToTaskMap.get(l.Id);
                // Lead Status: Disqualified
                if (l.Status == 'Disqualified') {
                    // write value 'Disqualified' to task type
                    for (Task t : tasksForLead) {
                        t.Type = 'Disqualified';
                        t.Status = 'Completed';
                    }
                }
                // Lead Status: Recycled
                else if (l.Status == 'Recycled') {
                    // write value 'Recycled' to task type
                    for (Task t : tasksForLead) {
                        t.Type = 'Recycled';
                        t.Status = 'Completed';
                    }
                }
                updatedTasks.addAll(tasksForLead);
            }
        }
        if (updatedTasks.size() > 0){
            update updatedTasks;
        }
    }
}