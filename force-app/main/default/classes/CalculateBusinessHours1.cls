public class CalculateBusinessHours1 {
    
    public static void getBusinessHours(String accountId){
        // Get all business hours records related to the accounts
        Map<Id, Map<String, Map<String, Time>>> accountToBusinessHoursMap = new Map<Id, Map<String, Map<String, Time>>>();
        for (Business_Hours__c businessHours : [SELECT Account__c, Day__c, Start_Time__c, End_Time__c, Time_Zone__c 
                                                FROM Business_Hours__c WHERE Account__c =:accountId]) {
                                                    if (!accountToBusinessHoursMap.containsKey(businessHours.Account__c)) {
                                                        accountToBusinessHoursMap.put(businessHours.Account__c, new Map<String, Map<String, Time>>());
                                                    }
                                                    Map<String, Time> startEndTime = new Map<String, Time>();
                                                    startEndTime.put('Start', CaseTriggerHandler.convertTimeToGMT(businessHours.Start_Time__c, businessHours.Time_Zone__c));
                                                    startEndTime.put('End', CaseTriggerHandler.convertTimeToGMT(businessHours.End_Time__c, businessHours.Time_Zone__c));
                                                    accountToBusinessHoursMap.get(businessHours.Account__c).put(businessHours.Day__c, startEndTime);
                                                }
        System.debug('accountToBusinessHoursMap'+accountToBusinessHoursMap);
        // Map to hold holidays for each account
        Map<Id, Set<Date>> accountToHolidaysMap = new Map<Id, Set<Date>>();
        for (Holiday__c holiday : [SELECT Account__c, Date__c, IsRecurrence__c FROM Holiday__c WHERE Account__c =:accountId]) {
            if (!accountToHolidaysMap.containsKey(holiday.Account__c)) {
                accountToHolidaysMap.put(holiday.Account__c, new Set<Date>());
            }
            accountToHolidaysMap.get(holiday.Account__c).add(holiday.Date__c);
            if (holiday.IsRecurrence__c) {
                for (Integer year = Date.today().year() - 1; year <= Date.today().year() + 1; year++) {
                    accountToHolidaysMap.get(holiday.Account__c).add(Date.newInstance(year, holiday.Date__c.month(), holiday.Date__c.day()));
                }
            }
        }
        System.debug('accountToHolidaysMap'+accountToHolidaysMap);
        
        Case caseRecord = [SELECT Id, Account.Name, CaseNumber, CreatedDate, Initial_Assignment_Time__c
                           FROM Case 
                           WHERE Id=: '5007z00000VUxgmAAD' LIMIT 1];
        //Integer totalMinutes = calculateBusinessMinutes(caseRecord.CreatedDate, caseRecord.Initial_Assignment_Time__c, accountToBusinessHoursMap,accountId, accountToHolidaysMap);
        //System.debug('totalMinutes'+totalMinutes);
        
        Integer businessMinutesDifference = 0;
        Datetime startDate = caseRecord.CreatedDate;
        system.debug('startDate'+startDate);
        Datetime endDate = caseRecord.Initial_Assignment_Time__c;
        system.debug('endDate'+endDate);
        Map<String, Map<String, Time>> businessHoursMap = accountToBusinessHoursMap.get(accountId);
        Set<Date> holidaysSet = accountToHolidaysMap.containsKey(accountId) ? accountToHolidaysMap.get(accountId) : new Set<Date>();
        Map<Date, Integer> validTimeMap = new Map<Date, Integer>();
        Datetime currentDate = startDate;
        while (currentDate <= endDate) {
            Date currentDay = currentDate.date();
            if (!holidaysSet.contains(currentDay)) {
                String dayOfWeek = currentDate.format('EEEE', 'GMT'); // Get full day name in GMT
                if (businessHoursMap != null && businessHoursMap.containsKey(dayOfWeek)) {
                    Map<String, Time> businessHours = businessHoursMap.get(dayOfWeek);
                    Time startTime = businessHours.get('Start');
                    Time endTime = businessHours.get('End');
                    system.debug('startTime'+startTime);
                    system.debug('endTime'+endTime);
                    Integer businessMinutes;
                        if (endTime.hour() < startTime.hour() || (endTime.hour() == startTime.hour() && endTime.minute() < startTime.minute())) {
                            // End time is on the next day, calculate across midnight
                            businessMinutes = ((24 * 60) - (startTime.hour() * 60 + startTime.minute())) + (endTime.hour() * 60 + endTime.minute());
                        } else {
                            // Normal same-day business hours calculation
                            businessMinutes = (endTime.hour() * 60 + endTime.minute()) - (startTime.hour() * 60 + startTime.minute());
                        }
                    system.debug('businessMinutes'+businessMinutes);
                    Time actualEndTime = CaseTriggerHandler.convertTimeToGMT(endDate.time(), UserInfo.getTimeZone().getID());
                    Time actualStartTime = CaseTriggerHandler.convertTimeToGMT(startDate.time(), UserInfo.getTimeZone().getID());
                    if(actualStartTime > endTime && currentDay == currentDate.Date()){
                        validTimeMap.put(currentDay, 0);
                    } else if(actualEndTime < startTime && currentDay == endDate.Date()){
                        validTimeMap.put(currentDay, 0);
                    } else {
                        if (validTimeMap.containsKey(currentDay)) {
                            validTimeMap.put(currentDay, validTimeMap.get(currentDay) + businessMinutes);
                        } else {
                            validTimeMap.put(currentDay, businessMinutes);
                        }
                    }
                    
                    system.debug('validTimeMap'+validTimeMap);
                }
            }
            currentDate = currentDate.addDays(1);
        }
        // Step 2: Adjust First Day (startDate)
        Date firstDay = startDate.date();
        if (validTimeMap.containsKey(firstDay)) {
            String firstDayOfWeek = startDate.format('EEEE', 'GMT');
            Map<String, Time> businessHours = businessHoursMap.get(firstDayOfWeek);
            Time startTime = businessHours.get('Start');
            Time endTime = businessHours.get('End');
            Time actualStartTime = CaseTriggerHandler.convertTimeToGMT(startDate.time(), UserInfo.getTimeZone().getID());
            system.debug('actualStartTime'+actualStartTime);
            system.debug('startTime'+startTime);
            system.debug('endTime'+endTime);
            
            if(actualStartTime > startTime){
                Integer businessStartMinutes = startTime.hour() * 60 + startTime.minute();
            	Integer actualStartMinutes = actualStartTime.hour() * 60 + actualStartTime.minute();
                Integer elapsedMinutes =  actualStartMinutes - businessStartMinutes;
                validTimeMap.put(firstDay, validTimeMap.get(firstDay) - elapsedMinutes);
                system.debug('validTimeMap'+validTimeMap);
                system.debug('elapsedMinutes'+elapsedMinutes);
            }
         
 			
        }



		// Step 3: Adjust Last Day (endDate)
        Date lastDay = endDate.date();
        if (validTimeMap.containsKey(lastDay)) {
            String lastDayOfWeek = endDate.format('EEEE', 'GMT');
            Time businessStartTime = businessHoursMap.get(lastDayOfWeek).get('Start');
            Time endTime = businessHoursMap.get(lastDayOfWeek).get('End');
                  
            Time actualEndTime = CaseTriggerHandler.convertTimeToGMT(endDate.time(), UserInfo.getTimeZone().getID());
            system.debug('actualEndTime'+actualEndTime);
            system.debug('endTime'+endTime);
            
            if(actualEndTime > businessStartTime){
                Integer businessStartMinutes = businessStartTime.hour() * 60 + businessStartTime.minute();
            	Integer actualEndMinutes = actualEndTime.hour() * 60 + actualEndTime.minute();
                Integer elapsedMinutes =  actualEndMinutes - businessStartMinutes;
                validTimeMap.put(lastDay, elapsedMinutes);
                system.debug('validTimeMap'+validTimeMap);
                system.debug('elapsedMinutes'+elapsedMinutes);
            } else if(actualEndTime < endTime){
                Integer businessStartMinutes = endTime.hour() * 60 + endTime.minute();
            	Integer actualEndMinutes = actualEndTime.hour() * 60 + actualEndTime.minute();
                Integer elapsedMinutes = businessStartMinutes - actualEndMinutes;
                validTimeMap.put(lastDay, validTimeMap.get(lastDay) - elapsedMinutes);
                system.debug('validTimeMap'+validTimeMap);
                system.debug('elapsedMinutes'+elapsedMinutes);
            }
        }

// Step 4: Calculate Total Business Minutes
Integer totalBusinessMinutes = 0;
for (Date day : validTimeMap.keySet()) {
    totalBusinessMinutes += validTimeMap.get(day);
}

// Output the result
system.debug('validTimeMap: ' + validTimeMap);
system.debug('Total Business Minutes: ' + totalBusinessMinutes);
        // Calculate the total business minutes
        /*currentDate = startDate;
        while (currentDate <= endDate) {
            Date currentDay = currentDate.date();
            if (validTimeMap.containsKey(currentDay)) {
                Integer businessMinutesForDay = validTimeMap.get(currentDay);
                
                // Adjust the calculation for the start and end days
                if (currentDate.date() == startDate.date()) {
                    Time startTime = CaseTriggerHandler.convertTimeToGMT(startDate.time(), UserInfo.getTimeZone().getID());
                    String dayOfWeek = currentDate.format('EEEE', 'GMT');
                    Map<String, Time> businessHours = businessHoursMap.get(dayOfWeek);
                    Time businessStartTime = businessHours.get('Start');
                    Time businessEndTime = businessHours.get('End');
                    
                    if (startTime > businessStartTime) {
                        businessMinutesForDay -= (startTime.hour() * 60 + startTime.minute()) - (businessStartTime.hour() * 60 + businessStartTime.minute());
                    }
                }
                
                if (currentDate.date() == endDate.date()) {
                    Time endTime = CaseTriggerHandler.convertTimeToGMT(endDate.time(), UserInfo.getTimeZone().getID());
                    String dayOfWeek = currentDate.format('EEEE', 'GMT');
                    Map<String, Time> businessHours = businessHoursMap.get(dayOfWeek);
                    Time businessStartTime = businessHours.get('Start');
                    Time businessEndTime = businessHours.get('End');
                    
                    if (endTime < businessEndTime) {
                        businessMinutesForDay -= (businessEndTime.hour() * 60 + businessEndTime.minute()) - (endTime.hour() * 60 + endTime.minute());
                    }
                }
                
                businessMinutesDifference += businessMinutesForDay;
            }
            currentDate = currentDate.addDays(1);
        }
        system.debug('businessMinutesDifference'+businessMinutesDifference);*/
        
    }
    
    
    /*public static Integer calculateBusinessMinutes(DateTime startDateTime, DateTime endDateTime, 
Map<Id, Map<String, Map<String, Time>>> accountToBusinessHoursMap, 
Id accountId, 
Map<Id, Set<Date>> accountToHolidaysMap) {
Integer totalMinutes = 0;

// Get the business hours for the account
Map<String, Map<String, Time>> businessHours = accountToBusinessHoursMap.get(accountId);
Set<Date> holidays = accountToHolidaysMap.containsKey(accountId) ? accountToHolidaysMap.get(accountId) : new Set<Date>();

DateTime currentDateTime = startDateTime;

while (currentDateTime < endDateTime) {
Date currentDate = currentDateTime.date();
String dayOfWeek = currentDateTime.format('EEEE'); // Get the day name, e.g., 'Tuesday'

// Check if the current day is a holiday or if there's no business hours defined
if (!holidays.contains(currentDate) && businessHours.containsKey(dayOfWeek)) {
Time businessStartTime = businessHours.get(dayOfWeek).get('Start');
Time businessEndTime = businessHours.get(dayOfWeek).get('End');

// Convert business hours to DateTime objects for the current date
DateTime businessStartDateTime = DateTime.newInstance(currentDate, businessStartTime);
DateTime businessEndDateTime = DateTime.newInstance(currentDate, businessEndTime);

// If the business hours end before they start (e.g., due to conversion), roll the end time to the next day
if (businessEndDateTime < businessStartDateTime) {
businessEndDateTime = businessEndDateTime.addDays(1);
}

// Determine the overlap of business hours with the current time window
DateTime startOfOverlap = currentDateTime > businessStartDateTime ? currentDateTime : businessStartDateTime;
DateTime endOfOverlap = endDateTime < businessEndDateTime ? endDateTime : businessEndDateTime;

if (startOfOverlap < endOfOverlap) {
Integer minutes = (Integer) ((endOfOverlap.getTime() - startOfOverlap.getTime()) / (1000 * 60));
totalMinutes += minutes;

System.debug('Date: ' + currentDate);
System.debug('Day of Week: ' + dayOfWeek);
System.debug('Business Hours Start: ' + businessStartDateTime);
System.debug('Business Hours End: ' + businessEndDateTime);
System.debug('Start of Overlap: ' + startOfOverlap);
System.debug('End of Overlap: ' + endOfOverlap);
System.debug('Minutes Calculated for This Day: ' + minutes);
}
}

// Move to the next day at the start of business hours
currentDateTime = getNextBusinessDayStart(currentDateTime, businessHours, holidays);
}

return totalMinutes;
}
public static DateTime getNextBusinessDayStart(DateTime currentDateTime, Map<String, Map<String, Time>> businessHours, Set<Date> holidays) {
Date nextDate = currentDateTime.date().addDays(1);

while (true) {
DateTime nextDateTime = DateTime.newInstance(nextDate, Time.newInstance(0, 0, 0, 0));
String dayOfWeek = nextDateTime.format('EEEE');

// Check if it's a holiday or if business hours are not defined for this day
if (!holidays.contains(nextDate) && businessHours.containsKey(dayOfWeek)) {
Time nextStartTime = businessHours.get(dayOfWeek).get('Start');
return DateTime.newInstance(nextDate, nextStartTime);
}

// Move to the next day if it's a holiday or no business hours are defined
nextDate = nextDate.addDays(1);
}
return nextDate;
}*/
}