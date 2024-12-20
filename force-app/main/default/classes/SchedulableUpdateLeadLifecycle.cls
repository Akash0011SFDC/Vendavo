global class SchedulableUpdateLeadLifecycle implements Schedulable {
  global void execute(SchedulableContext sc) {
        leadLifecycleContactSummery updateContact = new leadLifecycleContactSummery();
 	    Database.executeBatch(updateContact,30);
          leadLifecycleLeadSummery updateLead = new leadLifecycleLeadSummery();
 	    Database.executeBatch(updateLead,30);
       
    }
}