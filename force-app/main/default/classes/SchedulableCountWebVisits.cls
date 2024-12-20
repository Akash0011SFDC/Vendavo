global class SchedulableCountWebVisits implements Schedulable {
	global void execute(SchedulableContext sc) {
		 CountWebVisits newCount = new CountWebVisits();
 	    Database.executeBatch(newCount,30);
	}
}