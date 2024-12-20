global class SchedulableAccountLeadSnapshot Implements Schedulable{

global void execute(SchedulableContext sc) {
    
    accountLeadSnapShot acc2update = new accountLeadSnapShot();
    Database.executeBatch(acc2update,15);



}
}