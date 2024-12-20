global class SchedulableOpportunityMarketingTouches Implements Schedulable{

global void execute(SchedulableContext sc) {

    OpportunityMarketingTouches oppMarketingTouchTally = new OpportunityMarketingTouches();
    Database.executeBatch(oppMarketingTouchTally,10);


}
}