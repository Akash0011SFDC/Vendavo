global class SchedulableBatchConvertLeads implements Schedulable {
  global void execute(SchedulableContext sc) {
     batchConvertLeads convertLeads = new batchConvertLeads();
 	    Database.executeBatch(convertLeads,30);
  }
}