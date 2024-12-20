global class SchedulableUpdateAccountVIR implements Schedulable {
  global void execute(SchedulableContext sc) {
     UpdateAccountsVIR updateACCT = new UpdateAccountsVIR();
 	    Database.executeBatch(updateACCT,30);
  }
}