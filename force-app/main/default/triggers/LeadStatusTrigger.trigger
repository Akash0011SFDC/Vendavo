// Created: 08/2014
// Kyle Halstvedt
// Elixiter
// kyle@elixiter.com
// -----------------
// detect if a lead's status changes
// propagate changes according to LeadStatusClass rules
trigger LeadStatusTrigger on Lead (before update) {
    Map<Id, Lead> leadsWithChangedStatus = new Map<Id, Lead>();
    // compare old and new Status to determine if changed
    for (Id i : Trigger.newMap.keySet()) {
        if (Trigger.oldMap.get(i).Status != Trigger.newMap.get(i).Status) {
            // the Status field has been changed, add to list
            Lead l = Trigger.newMap.get(i);
            leadsWithChangedStatus.put(l.Id, l);
        }
    }
    // call function to copy status to related tasks
    LeadStatusClass.propagateStatus(leadsWithChangedStatus);
}