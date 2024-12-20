// Created: 08/2014
// Kyle Halstvedt
// Elixiter
// kyle@elixiter.com
// -----------------
public class LeadReassignmentClass {
    // re-run assignment rules for an array of lead Id's
    public static void rerunAssignment(Id[] leadIds) {
        // fetch lead records
        Lead[] leads = new List<Lead>();
        leads = [Select Re_assign_lead_trigger__c From Lead Where Id In :leadIds Limit 49999];
        // set DML options
        Database.DMLOptions dmo = new Database.DMLOptions();
        dmo.assignmentRuleHeader.useDefaultRule = true;
        if (leads != null && leads.size() > 0) {
            for (Lead l : leads) {
                // testing field, since Re_assign_lead_trigger__c is immediately reset to false
          		l.Has_been_reassigned__c = true;
                // restore default false value for trigger
        		l.Re_assign_lead_trigger__c = false;
                // set DML options for update operation
      	      	l.setOptions(dmo);
    	    }
            update leads;
        }
    }
}