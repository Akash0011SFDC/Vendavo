global class SchedulableSICObjectFieldUpdate Implements Schedulable{

global void execute(SchedulableContext sc) {

    batchSICFieldsUpdate sic = new batchSICFieldsUpdate();
    Database.executeBatch(sic,1);



}
}