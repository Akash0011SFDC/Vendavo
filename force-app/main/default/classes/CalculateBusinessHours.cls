public class CalculateBusinessHours {
     @InvocableMethod(label='Send Data for Update InitialAssignmentTime and InitialResponseTime')
    public static void updateInitialAssignmentTime(List<FlowInput> flowInputs) {
        Set<Id> accountIds = new Set<Id>();
        Set<Id> caseIds = new Set<Id>();
        String flowInputName = '';
        // Process each input received
        for (FlowInput input : flowInputs) {
			accountIds.add(input.accountId);
            caseIds.add(input.caseId);
            flowInputName = input.flowName;
        }
        List<Case> caseRecords = [SELECT Id, Initial_Assignment_Time_in_Minutes__c, Initial_Response_Time_in_Minutes__c
                                 FROM Case
                                 WHERE Id IN :caseIds];
        // Get all business hours records related to the accounts
        Map<Id, Map<String, Map<String, Time>>> accountToBusinessHoursMap = new Map<Id, Map<String, Map<String, Time>>>();
        for (Business_Hours__c businessHours : [SELECT Account__c, Day__c, Start_Time__c, End_Time__c, Time_Zone__c 
                                                FROM Business_Hours__c WHERE Account__c IN :accountIds]) {
            if (!accountToBusinessHoursMap.containsKey(businessHours.Account__c)) {
                accountToBusinessHoursMap.put(businessHours.Account__c, new Map<String, Map<String, Time>>());
            }
            Map<String, Time> startEndTime = new Map<String, Time>();
            startEndTime.put('Start', CaseTriggerHandler.convertTimeToGMT(businessHours.Start_Time__c, businessHours.Time_Zone__c));
            startEndTime.put('End', CaseTriggerHandler.convertTimeToGMT(businessHours.End_Time__c, businessHours.Time_Zone__c));
            accountToBusinessHoursMap.get(businessHours.Account__c).put(businessHours.Day__c, startEndTime);
        }
        system.debug('accountToBusinessHoursMap'+ accountToBusinessHoursMap);
        // Map to hold holidays for each account
        Map<Id, Set<Date>> accountToHolidaysMap = new Map<Id, Set<Date>>();
        for (Holiday__c holiday : [SELECT Account__c, Date__c, IsRecurrence__c FROM Holiday__c WHERE Account__c IN :accountIds]) {
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
        for (FlowInput input : flowInputs) {
            Integer businessMinutesDifference = 0;
            Datetime startDate = input.startDateTime;
            Datetime endDate = input.endDateTime;
            Id accountId = input.accountId;
            Id caseId = input.caseId;
            Map<String, Map<String, Time>> businessHoursMap = accountToBusinessHoursMap.get(accountId);
        	Set<Date> holidaysSet = accountToHolidaysMap.containsKey(accountId) ? accountToHolidaysMap.get(accountId) : new Set<Date>();
            Map<Date, Integer> validTimeMap = new Map<Date, Integer>();
            // Create a map of valid times for each day
            Datetime currentDate = startDate;
            while (currentDate <= endDate) {
                Date currentDay = currentDate.date();
                if (!holidaysSet.contains(currentDay)) {
                    String dayOfWeek = currentDate.format('EEEE', 'GMT'); // Get full day name in GMT
                    system.debug('dayOfWeek'+ dayOfWeek);
                    if (businessHoursMap != null && businessHoursMap.containsKey(dayOfWeek)) {
                        Map<String, Time> businessHours = businessHoursMap.get(dayOfWeek);
                        system.debug('businessHours'+ businessHours);
                        Time startTime = businessHours.get('Start');
                        Time endTime = businessHours.get('End');
                        system.debug('startTime'+ startTime);
                        system.debug('endTime'+ endTime);
                        // Calculate the total business minutes for the current day
                        Integer businessMinutes;
                        if (endTime.hour() < startTime.hour() || (endTime.hour() == startTime.hour() && endTime.minute() < startTime.minute())) {
                            // End time is on the next day, calculate across midnight
                            businessMinutes = ((24 * 60) - (startTime.hour() * 60 + startTime.minute())) + (endTime.hour() * 60 + endTime.minute());
                        } else {
                            // Normal same-day business hours calculation
                            businessMinutes = (endTime.hour() * 60 + endTime.minute()) - (startTime.hour() * 60 + startTime.minute());
                        }
                        system.debug('businessMinutes'+ businessMinutes);
                        if (validTimeMap.containsKey(currentDay)) {
                            validTimeMap.put(currentDay, validTimeMap.get(currentDay) + businessMinutes);
                        } else {
                            validTimeMap.put(currentDay, businessMinutes);
                        }
                    }
                }
                currentDate = currentDate.addDays(1);
            }
        	// Calculate the total business minutes
            currentDate = startDate;
            system.debug('currentDate'+ currentDate);
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
            system.debug('businessMinutesDifference'+ businessMinutesDifference);
            for(Case caseRecord : caseRecords){
                if(flowInputName == 'Update Initial Assignment Time Flow'){
                    caseRecord.Initial_Assignment_Time_in_Minutes__c = businessMinutesDifference;
                }
                else if (flowInputName == 'Update Initial Response Time Flow'){                    
                    caseRecord.Initial_Response_Time_in_Minutes__c = businessMinutesDifference;                    
                }
            }
            UPDATE caseRecords;
        }   
    }
    
    
    
    
    
    
    public static Case calculateCaseBusinessHours(Case caseRecord, Datetime startDateTime, Datetime endDateTime, Map<Id, Id> caseIdToAccountIdMap, Map<Id, Map<String, Map<String, Time>>> accountToBusinessHoursMap, Map<Id, Set<Date>> accountToHolidaysMap, String fieldToUpdate) {
        
        Case returnCaseRec = new Case();
        
        Set<Id> caseIds = new Set<Id>();
        Set<Id> accountIds = new Set<Id>();
        
        Integer businessMinutesDifference = 0;
        Datetime startDate = startDateTime;
        Datetime endDate = endDateTime;
        Id accountId = caseRecord.AccountId;
        Map<String, Map<String, Time>> businessHoursMap = accountToBusinessHoursMap.get(accountId);
        Set<Date> holidaysSet = accountToHolidaysMap.containsKey(accountId) ? accountToHolidaysMap.get(accountId) : new Set<Date>();
        
        // Convert startDate and endDate to GMT
        startDate = startDate.addSeconds(-startDate.second()); // Align start date to the beginning of the minute
        endDate = endDate.addSeconds(-endDate.second()); // Align end date to the beginning of the minute
        
        Map<Date, Integer> validTimeMap = new Map<Date, Integer>();
        
        // Create a map of valid times for each day
        Datetime currentDate = startDate;
        while (currentDate <= endDate) {
            Date currentDay = currentDate.date();
            if (!holidaysSet.contains(currentDay)) {
                String dayOfWeek = currentDate.format('EEEE', 'GMT'); // Get full day name in GMT
                if (businessHoursMap != null && businessHoursMap.containsKey(dayOfWeek)) {
                    Map<String, Time> businessHours = businessHoursMap.get(dayOfWeek);
                    Time startTime = businessHours.get('Start');
                    Time endTime = businessHours.get('End');
                    
                    // Calculate the total business minutes for the current day
                    Integer businessMinutes = (endTime.hour() * 60 + endTime.minute()) - (startTime.hour() * 60 + startTime.minute());
                    if (validTimeMap.containsKey(currentDay)) {
                        validTimeMap.put(currentDay, validTimeMap.get(currentDay) + businessMinutes);
                    } else {
                        validTimeMap.put(currentDay, businessMinutes);
                    }
                }
            }
            currentDate = currentDate.addDays(1);
        }
        
        // Calculate the total business minutes
        currentDate = startDate;
        while (currentDate <= endDate) {
            Date currentDay = currentDate.date();
            system.debug('validTimeMap ::'+validTimeMap.KeySet());
                
            if (validTimeMap.containsKey(currentDay)) {
                Integer businessMinutesForDay = validTimeMap.get(currentDay);
                
                // Adjust the calculation for the start and end days
                if (currentDate.date() == startDate.date()) {
                    Time startTime = convertTimeToGMT(startDate.time(), UserInfo.getTimeZone().getID());
                    String dayOfWeek = currentDate.format('EEEE', 'GMT');
                    Map<String, Time> businessHours = businessHoursMap.get(dayOfWeek);
                    Time businessStartTime = businessHours.get('Start');
                    Time businessEndTime = businessHours.get('End');
                    system.debug('businessStartTime ::'+businessStartTime);
                    system.debug('businessEndTime ::'+businessEndTime);
                    
                    
                    if (startTime > businessStartTime) {
                        businessMinutesForDay -= (startTime.hour() * 60 + startTime.minute()) - (businessStartTime.hour() * 60 + businessStartTime.minute());
                    }
                }
                
                if (currentDate.date() == endDate.date()) {
                    Time endTime = convertTimeToGMT(endDate.time(), UserInfo.getTimeZone().getID());
                    String dayOfWeek = currentDate.format('EEEE', 'GMT');
                    Map<String, Time> businessHours = businessHoursMap.get(dayOfWeek);
                    Time businessStartTime = businessHours.get('Start');
                    Time businessEndTime = businessHours.get('End');
                    system.debug('businessStartTime ::'+businessStartTime);
                    system.debug('businessEndTime ::'+businessEndTime);
                    
                    if (endTime < businessEndTime) {
                        businessMinutesForDay -= (businessEndTime.hour() * 60 + businessEndTime.minute()) - (endTime.hour() * 60 + endTime.minute());
                    }
                }
                
                businessMinutesDifference += businessMinutesForDay;
                system.debug('currentDate ::'+currentDate);
                system.debug('businessMinutesForDay ::'+businessMinutesForDay);
                
            }
            currentDate = currentDate.addDays(1);
        }
        
        system.debug('businessMinutesDifference ::'+businessMinutesDifference);
        if(fieldToUpdate == 'Initial Assignment'){
            
            caseRecord.Initial_Assignment_Time_in_Minutes__c = businessMinutesDifference > 0 ? businessMinutesDifference : 0;
            
        }
        
        else if (fieldToUpdate == 'Initial Response'){                    
            
            caseRecord.Initial_Response_Time_in_Minutes__c = businessMinutesDifference > 0 ? businessMinutesDifference : 0;                    
            
        }
           else if (fieldToUpdate == 'Closure'){                                                               
            returnCaseRec.Id = caseRecord.Id;
            returnCaseRec.Time_to_Closur_Business__c = businessMinutesDifference > 0 ? businessMinutesDifference : 0;                    
            
        }
                                                      
                                                      
       System.debug('caseRecord'+caseRecord);
      System.debug('caseRecord.Time_to_Closur_Business__c'+caseRecord.Time_to_Closur_Business__c);
        return returnCaseRec;
    }
    
    
    
public class FlowInput {
        @InvocableVariable(label='CaseId' required= true)
        public Id caseId;
        
        @InvocableVariable(label='Account ID' required=true)
        public Id accountId;

        @InvocableVariable(label='Start DateTime' required=true)
        public Datetime startDateTime;

        @InvocableVariable(label='End DateTime' required=true)
        public Datetime endDateTime;
        
        @InvocableVariable(label = 'FlowName' required=true)
        public String flowName;
    }
    
    /*
    * PURPOSE  : Convert Time to GMT
    * PARAM    : Time field to be converted and Timezonekey
    * RETURNS  : Converted Time
    */
    public static Time convertTimeToGMT(Time timeToBeConverted, String timeZoneKey) {
        // Define the time zone IDs
        String denverTimeZoneId = timeZoneKey;
        String gmtTimeZoneId = 'GMT';
        
        // Get the current date (today)
        Date currentDate = Date.today();
        
        // Create a DateTime object for today's date with the given Denver time
        DateTime denverDateTime = DateTime.newInstance(currentDate.year(), currentDate.month(), currentDate.day(),
                                                       timeToBeConverted.hour(), timeToBeConverted.minute(), timeToBeConverted.second());
        
        // Get time zone objects for the specified time zone and GMT
        TimeZone denverTimeZone = TimeZone.getTimeZone(denverTimeZoneId);
        TimeZone gmtTimeZone = TimeZone.getTimeZone(gmtTimeZoneId);
        
        // Get offsets from GMT in milliseconds
        Integer denverOffsetMillis = denverTimeZone.getOffset(denverDateTime);
        Integer gmtOffsetMillis = gmtTimeZone.getOffset(denverDateTime);
        
        // Calculate the offset difference in seconds
        Integer offsetDifferenceSeconds = (denverOffsetMillis - gmtOffsetMillis) / 1000;
        
        // Adjust the DateTime by the offset difference to get GMT time
        DateTime gmtDateTime = denverDateTime.addSeconds(-offsetDifferenceSeconds);
        
        // Extract the time component from the GMT DateTime
        Time gmtTime = Time.newInstance(gmtDateTime.hour(), gmtDateTime.minute(), gmtDateTime.second(), gmtDateTime.millisecond());
        
        return gmtTime;
    }
}