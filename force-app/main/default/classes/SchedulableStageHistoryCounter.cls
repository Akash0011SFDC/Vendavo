global class SchedulableStageHistoryCounter implements Schedulable {
	global void execute(SchedulableContext sc) {
		StageHistoryCounter stageHistory = new StageHistoryCounter();
 	    Database.executeBatch(stageHistory,50);
	}
}