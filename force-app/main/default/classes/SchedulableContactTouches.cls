global class SchedulableContactTouches Implements Schedulable{

global void execute(SchedulableContext sc) {

    UpdateCountOfContactsTouches updateTouches = new UpdateCountOfContactsTouches();
    Database.executeBatch(updateTouches,10);


}
}