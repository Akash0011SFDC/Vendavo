global class SchedulableFirstLastTouchesOnOpps Implements Schedulable{

global void execute(SchedulableContext sc) {

    FirstLastTouchesOnOpps fl = new FirstLastTouchesOnOpps();
    Database.executeBatch(fl,1);


}
}