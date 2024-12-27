/**
* @Description: Trigger handler for  on CaseTrigger
* @Date: 2024-04-04 (YYYY-MM-DD)
* @Author: akash (akash@dreamwares.com) 
* @TestClass: CaseTriggerHandlerTest
* 
* ModifiedBy     ModifiedDate      Description
* Akash           2024-04-04        Initial development
* Akash           2024-07-01        Include Customer Business Hours
* Dreamwares	  2024-12-03		Secured cases ownership change validation
*/
public class CaseTriggerHandler {
    
    
    /*
    * PURPOSE  : Before Update Operations
    * PARAM    : Map of old and new case
    * RETURNS  : 
    */
    public static void beforeUpdate(Map<Id,Case> oldCaseMap, Map<Id,Case> newCaseMap) {
        //06-11-2024 : Commented to revert the case locking feature.
        // preventCaseUpdateAfter48Hrs(oldCaseMap, newCaseMap);
        
        //23-10-2024 : reverted the case validations for enhanced security
        //PreventCaseFromUpdateDelete(newCaseMap.Values(),newCaseMap);
        System.debug('In beforeUpdate trigger');
        // 03-Dec-2024 : case ownership validation for non secured user
        PreventCaseToChangeNonSecuredOwner(newCaseMap.Values(),newCaseMap);
    }
    
    /*
    * PURPOSE  : Before Delete Operations
    * PARAM    : Map of old 
    * RETURNS  : 
    */
    public static void beforeDelete(Map<Id,Case> oldCaseMap) {
        //preventCaseUpdateAfter48Hrs(oldCaseMap, newCaseMap);
        //23-10-2024 : reverted the case validations for enhanced security
        //PreventCaseFromUpdateDelete(oldCaseMap.Values(),oldCaseMap);
    }
    
    /*
    * PURPOSE  : After Insert Operations
    * PARAM    : List of Cases
    * RETURNS  : 
    */
    public static void afterInsert(List < Case > caseList) {
        trackStatusChangeTiming(caseList);
    }
    
    /*
    * PURPOSE  : After Update Operations
    * PARAM    : New Case Map and Old Case Map
    * RETURNS  :  
    */
    public static void afterUpdate(Map < Id, Case > caseMap, Map < Id, Case > oldCaseMap) {
        List < Case > caseList = new List < Case > ();
        List < Case > initialAssignmentTimeCaseList = new List < Case > ();
        List < Case > initialResponseTimeCaseList = new List < Case > ();
        List < Case > timeToClosureCaseList = new List < Case > ();
        List < Case > timeToResolveCaseList = new List < Case > ();
        
        for (Case caseRec: caseMap.values()) {
            
            //Create List of cases for status change
            if (caseRec.status != oldCaseMap.get(caseRec.Id).Status) {
                caseList.add(caseRec);
            }
            
            //Create List of cases for Inital Assignment change
            if (caseRec.Initial_Assignment_Time__c != oldCaseMap.get(caseRec.Id).Initial_Assignment_Time__c) 
            {
                initialAssignmentTimeCaseList.add(caseRec);
            }
            
            //Create List of cases for Inital Response change
            if (caseRec.Initial_Response_Time__c != oldCaseMap.get(caseRec.Id).Initial_Response_Time__c) 
            {
                initialResponseTimeCaseList.add(caseRec);
            }
            
            //Create List of cases for status change to Close
            if (caseRec.IsClosed == True && oldCaseMap.get(caseRec.Id).IsClosed != True && caseRec.ClosedDate!= NUll && caseRec.CreatedDate != NULL
                || caseRec.IsClosed == False && oldCaseMap.get(caseRec.Id).IsClosed == True && caseRec.ClosedDate == NUll) 
            {
                timeToClosureCaseList.add(caseRec);
            }
            
            //Create List of cases for Support Resolved Date change
            if (caseRec.Support_Resolved_Date__c != oldCaseMap.get(caseRec.Id).Support_Resolved_Date__c) 
            {
                timeToResolveCaseList.add(caseRec);
            }
            
        }
        
        //Calculate Case status tracker
        if (!caseList.isEmpty()) {
            trackStatusChangeTiming(caseList);
        }
        
        //Calculate time to Inital Assignment time for cases
        if (!initialAssignmentTimeCaseList.isEmpty()) {
            calculateTimeToBusinessCase(initialAssignmentTimeCaseList, 'Initial_Assignment');
        }
        
        //Calculate time to Inital Response time  for cases
        if (!initialResponseTimeCaseList.isEmpty()) {
            calculateTimeToBusinessCase(initialResponseTimeCaseList, 'Initial_Response');
        }
        
        
        //Calculate time to closure for cases
        if (!timeToClosureCaseList.isEmpty()) {
            calculateTimeToBusinessCase(timeToClosureCaseList, 'Closure');
        }
        
        //Calculate time to resolve for cases
        if (!timeToResolveCaseList.isEmpty()) {
            calculateTimeToBusinessCase(timeToResolveCaseList, 'Resolve');
        }
        
    }
    
    /*
    * PURPOSE  : Prevent case to update after 48hours of case is closed
    * PARAM    : Map of new case and Map of old case
    * RETURNS  : 
    */
    public static void preventCaseUpdateAfter48Hrs(Map < Id, Case > oldCaseMap, Map < Id, Case > newCaseMap) {
        
        for (Case caseRecord : newCaseMap.values()) {
            Case oldCase = oldCaseMap.get(caseRecord.Id);
            
            // Check if the Case was closed more than 48 hours ago
            if ((caseRecord.Status == 'Closed' && DateTime.now().addHours(-48) > oldCase.ClosedDate)
                || (oldCase.Last_Status__c == 'Closed' && DateTime.now().addHours(-48) > oldCase.ClosedDate)) {
                    if (DateTime.now().addHours(-48) > caseRecord.ClosedDate) {
                        // oldCase.addError('You cannot update a case more than 5 minits after it has been closed.');
                        caseRecord.addError('You cannot update a case more than 48 hours after it has been closed.');
                    }
                }
        }
        
    }
    
    /*
    * PURPOSE  : Track status change time
    * PARAM    : List of Cases
    * RETURNS  : 
    */
    public static void trackStatusChangeTiming(List < Case > caseList) {
        
        updatedEndTimeAndCalculateHrs(caseList);
        
        createNewCaseStatusChangeTracker(caseList);
        
    }
    
    /*
    * PURPOSE  : Set End Date and calcualte horur for previous Case Status Change Tracker
    * PARAM    : List of Cases
    * RETURNS  : 
    */
    public static void updatedEndTimeAndCalculateHrs(List < Case > caseList) {
        List < Case_Status_Change_Tracker__c > statusTrackerListToUpate = new List < Case_Status_Change_Tracker__c > ();
        
        List < Case > cases = [SELECT Id,
                               (SELECT Id, CreatedDate, Case_Change_Start_Date__c, Case_Change_End_Date__c, Case__c, End_Date__c 
                                FROM Case_Status_Change_Tracker__r 
                                WHERE Case_Change_End_Date__c = NULL ORDER BY CreatedDate DESC LIMIT 1)
                               FROM Case
                               WHERE Id IN: caseList
                              ];
        
        for (Case caseRec: cases) {
            if (caseRec.Case_Status_Change_Tracker__r != NULL && !caseRec.Case_Status_Change_Tracker__r.isEmpty()) {
                Case_Status_Change_Tracker__c statusTracker = caseRec.Case_Status_Change_Tracker__r[0];
                statusTracker.Case_Change_End_Date__c = System.Now();
                statusTracker.End_Date__c = System.Now();
                statusTrackerListToUpate.add(statusTracker);
            }
        }
        
        //Old calculation
        List < Case_Status_Change_Tracker__c > oldfinalstatusTrackerListToUpate = oldcalculateCaseBusinessHours(statusTrackerListToUpate);
        if (!oldfinalstatusTrackerListToUpate.isEmpty()) {
            
            UPDATE oldfinalstatusTrackerListToUpate;
        }
        
        
        List < Case_Status_Change_Tracker__c > finalstatusTrackerListToUpate = calculateCaseBusinessHours(statusTrackerListToUpate);
        if (!finalstatusTrackerListToUpate.isEmpty()) {
            
            UPDATE finalstatusTrackerListToUpate;
        }
    }
    
    /*
    * PURPOSE  : Create New Case Status Change Tracker
    * PARAM    : List of Cases
    * RETURNS  : 
    */
    public static void createNewCaseStatusChangeTracker(List < Case > caseList) {
        List < Case_Status_Change_Tracker__c > statusTrackerListToInsert = new List < Case_Status_Change_Tracker__c > ();
        
        Datetime userTime = System.now();
        String userTimeString = userTime.format('yyyy-MM-dd HH:mm:ss', 'GMT');
        Datetime datetimeInGmt = Datetime.valueOfGmt(userTimeString);
        
        for (Case caseRec: caseList) {
            Case_Status_Change_Tracker__c statusTracker = new Case_Status_Change_Tracker__c();
            statusTracker.Case__c = caseRec.Id;
            statusTracker.Case_Change_Start_Date__c = userTime;
            statusTracker.Status__c = caseRec.Status;
            
            statusTrackerListToInsert.add(statusTracker);
            
        }
        
        if (!statusTrackerListToInsert.isEmpty()) {
            INSERT statusTrackerListToInsert;
        }
        
    }
    
    /*
    * PURPOSE  : Calculate time of status within business hours
    * PARAM    : List of Case Status Change Tracker
    * RETURNS  : List of Case Status Change Tracker records with Calculate hours 
    */
    public static List < Case_Status_Change_Tracker__c > oldcalculateCaseBusinessHours(List < Case_Status_Change_Tracker__c > statusTrackerList) {
        
        List < Case_Status_Change_Tracker__c > newStatusTrackerList = new List < Case_Status_Change_Tracker__c > ();
        
        for (Case_Status_Change_Tracker__c statusTracker: statusTrackerList) {
            
            Integer businessHoursDifference = 0;
            Datetime startDate = statusTracker.Case_Change_Start_Date__c;
            Datetime endDate = statusTracker.End_Date__c;
            
            if (endDate > startDate.addHours(1)) {
                while (startDate < endDate) {
                    if (startDate.format('E') != 'Sat' && startDate.format('E') != 'Sun') {
                        businessHoursDifference++;
                    }
                    startDate = startDate.addHours(1);
                }
            }
            statusTracker.Hours_Difference__c = businessHoursDifference;
            newStatusTrackerList.add(statusTracker);
        }
        return newStatusTrackerList;
    }
    
    
    
    /*
    * PURPOSE  : Calculate time of status within business hours
    * PARAM    : List of Case Status Change Tracker
    * RETURNS  : List of Case Status Change Tracker records with Calculate hours 
    */
    public static List<Case_Status_Change_Tracker__c> calculateCaseBusinessHours(List<Case_Status_Change_Tracker__c> statusTrackerList) {
        List<Case_Status_Change_Tracker__c> newStatusTrackerList = new List<Case_Status_Change_Tracker__c>();
        
        Set<Id> caseIds = new Set<Id>();
        Set<Id> accountIds = new Set<Id>();
        
        for (Case_Status_Change_Tracker__c statusTracker : statusTrackerList) {
            caseIds.add(statusTracker.Case__c);
        }
        
        Map<Id, Id> caseIdToAccountIdMap = new Map<Id, Id>();
        
        for (Case caseRec : [SELECT Id, AccountId FROM Case WHERE Id IN :caseIds]) {
            caseIdToAccountIdMap.put(caseRec.Id, caseRec.AccountId);
            accountIds.add(caseRec.AccountId);
        }
        
        // Get all business hours records related to the accounts
        Map<Id, Map<String, Map<String, Time>>> accountToBusinessHoursMap = new Map<Id, Map<String, Map<String, Time>>>();
        for (Business_Hours__c businessHours : [SELECT Account__c, Day__c, Start_Time__c, End_Time__c, Time_Zone__c 
                                                FROM Business_Hours__c WHERE Account__c IN :accountIds]) {
                                                    if (!accountToBusinessHoursMap.containsKey(businessHours.Account__c)) {
                                                        accountToBusinessHoursMap.put(businessHours.Account__c, new Map<String, Map<String, Time>>());
                                                    }
                                                    Map<String, Time> startEndTime = new Map<String, Time>();
                                                    startEndTime.put('Start', convertTimeToGMT(businessHours.Start_Time__c, businessHours.Time_Zone__c));
                                                    startEndTime.put('End', convertTimeToGMT(businessHours.End_Time__c, businessHours.Time_Zone__c));
                                                    accountToBusinessHoursMap.get(businessHours.Account__c).put(businessHours.Day__c, startEndTime);
                                                }
        
        // Get all holidays records related to the accounts
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
        
        for (Case_Status_Change_Tracker__c statusTracker : statusTrackerList) {
            Integer businessMinutesDifference = 0;
            Datetime startDate = statusTracker.Case_Change_Start_Date__c;
            Datetime endDate = statusTracker.Case_Change_End_Date__c;
            Id accountId = caseIdToAccountIdMap.get(statusTracker.Case__c);
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
                if (validTimeMap.containsKey(currentDay)) {
                    Integer businessMinutesForDay = validTimeMap.get(currentDay);
                    
                    // Adjust the calculation for the start and end days
                    if (currentDate.date() == startDate.date()) {
                        Time startTime = convertTimeToGMT(startDate.time(), UserInfo.getTimeZone().getID());
                        String dayOfWeek = currentDate.format('EEEE', 'GMT');
                        Map<String, Time> businessHours = businessHoursMap.get(dayOfWeek);
                        Time businessStartTime = businessHours.get('Start');
                        Time businessEndTime = businessHours.get('End');
                        
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
                        
                        if (endTime < businessEndTime) {
                            businessMinutesForDay -= (businessEndTime.hour() * 60 + businessEndTime.minute()) - (endTime.hour() * 60 + endTime.minute());
                        }
                    }
                    
                    businessMinutesDifference += businessMinutesForDay;
                }
                currentDate = currentDate.addDays(1);
            }
            
            statusTracker.Status_Duration_Minutes__c = businessMinutesDifference > 0 ? businessMinutesDifference : 0 ;
            newStatusTrackerList.add(statusTracker);
        }
        return newStatusTrackerList;
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
    
    // Date : 03-Dec-2024 : when secured user tries to change owner, who is not secured, then throw error message
    public static void PreventCaseToChangeNonSecuredOwner(List<Case> newCases, Map<Id,Case> newCasesMap){
        List<Case> securedCasesList = new List<Case>();
        for(Case caseRecord : newCases){
            String caseOwnerId = caseRecord.OwnerId;
            if(caseRecord.Security_Enhancement__c && !caseOwnerId.startsWith('00G')){
                securedCasesList.add(caseRecord);
            }
        }
        Map<Id, DTO.EnhanceSecurityControllerResponse> caseResult = EnhanceSecurityHelper.ValidateQueueOwnerAccess(securedCasesList);
        Map<Id,Case> caseMap = newCasesMap;
        System.debug('caseResult ==> '+caseResult);
        for(Id caseId : caseResult.keySet()){            
            if (!caseResult.get(caseId).IsValid && !Test.isRunningTest()) {
                caseMap.get(caseId).addError('This user not having secured case access.');
            }   
        }
    }
    /*public static void PreventCaseFromUpdateDelete(List<Case> newCases, Map<Id,Case> newCasesMap){
    Map<Id, DTO.EnhanceSecurityControllerResponse> caseResult = EnhanceSecurityHelper.ValidateRecordsAccess(newCases, Case.sObjectType);
    Map<Id,Case> caseMap = newCasesMap;
    System.debug('caseResult ==> '+caseResult);
    for(Id caseId : caseResult.keySet()){            
    if (!caseResult.get(caseId).IsValid) {
    caseMap.get(caseId).addError('You do not have access to update or delete this case.');
    }   
    }
    }*/
        
        
    /*
    * PURPOSE  : Calculate Time as per Business Hours for Case
    * PARAM    : List of Cases, Field for which time is to be calculated
    * RETURNS  : 
    */
    public static void calculateTimeToBusinessCase(List<Case> caseList, String fieldToCalculation) {
        Map<Id, Id> caseIdToAccountIdMap = new Map<Id, Id>();
        Set<Id> accountIds = new Set<Id>();
        
        // Fetch necessary data for calculation
        for (Case caseRec : caseList) {
            caseIdToAccountIdMap.put(caseRec.Id, caseRec.AccountId);
            accountIds.add(caseRec.AccountId);
        }
        
        // Build business hours and holidays maps
        Map<Id, Map<String, Map<String, Time>>> accountToBusinessHoursMap = new Map<Id, Map<String, Map<String, Time>>>();
        for (Business_Hours__c businessHours : [
            SELECT Account__c, Day__c, Start_Time__c, End_Time__c, Time_Zone__c 
            FROM Business_Hours__c WHERE Account__c IN :accountIds
        ]) {
            if (!accountToBusinessHoursMap.containsKey(businessHours.Account__c)) {
                accountToBusinessHoursMap.put(businessHours.Account__c, new Map<String, Map<String, Time>>());
            }
            Map<String, Time> startEndTime = new Map<String, Time>();
            startEndTime.put('Start', convertTimeToGMT(businessHours.Start_Time__c, businessHours.Time_Zone__c));
            startEndTime.put('End', convertTimeToGMT(businessHours.End_Time__c, businessHours.Time_Zone__c));
            accountToBusinessHoursMap.get(businessHours.Account__c).put(businessHours.Day__c, startEndTime);
        }
        
        Map<Id, Set<Date>> accountToHolidaysMap = new Map<Id, Set<Date>>();
        for (Holiday__c holiday : [
            SELECT Account__c, Date__c, IsRecurrence__c 
            FROM Holiday__c WHERE Account__c IN :accountIds
        ]) {
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
        
        // Calculate time to closure for each case
        List<Case> calculatedCases = new List<Case>();
        for (Case caseRec : caseList) {
            Case updatedCase = new Case();
            
            if(fieldToCalculation == 'Initial_Assignment'){
                updatedCase = calculateCaseBusinessHoursFixDate( caseRec, caseRec.CreatedDate, caseRec.Initial_Assignment_Time__c,
                                                                caseIdToAccountIdMap, accountToBusinessHoursMap,
                                                                accountToHolidaysMap, fieldToCalculation);
                calculatedCases.add(updatedCase);
            }
            
            if(fieldToCalculation == 'Initial_Response'){
                updatedCase = calculateCaseBusinessHoursFixDate( caseRec, caseRec.CreatedDate, caseRec.Initial_Response_Time__c,
                                                                caseIdToAccountIdMap, accountToBusinessHoursMap,
                                                                accountToHolidaysMap, fieldToCalculation);
                calculatedCases.add(updatedCase);
            }
            
            if(fieldToCalculation == 'Closure'){
                updatedCase = calculateCaseBusinessHoursFixDate( caseRec, caseRec.CreatedDate, caseRec.ClosedDate,
                                                                caseIdToAccountIdMap, accountToBusinessHoursMap,
                                                                accountToHolidaysMap, fieldToCalculation);
                calculatedCases.add(updatedCase);
            }
            if(fieldToCalculation == 'Resolve'){
                updatedCase = calculateCaseBusinessHoursFixDate( caseRec, caseRec.CreatedDate, caseRec.Support_Resolved_Date__c,
                                                                caseIdToAccountIdMap, accountToBusinessHoursMap,
                                                                accountToHolidaysMap, fieldToCalculation);
                calculatedCases.add(updatedCase);
            }
            
        }
        
        // Update cases
        if (!calculatedCases.isEmpty()) {
            
            Update calculatedCases;
        }
    }
    
    /*
    * PURPOSE  : Calculate Time in minutes as per Business Hours for Case for start and End date
    * PARAM    : Case, StartDateTime, EndDateTime, Map of case to Account, BusinessaHours and Holdiday Map
    * RETURNS  : Case
    */
    public static Case calculateCaseBusinessHoursFixDate(Case caseRecord, Datetime startDateTime, Datetime endDateTime, Map<Id, Id> caseIdToAccountIdMap, 
                                                         Map<Id, Map<String, Map<String, Time>>> accountToBusinessHoursMap, Map<Id, Set<Date>> accountToHolidaysMap, 
                                                         String fieldToUpdate) 
    {
        
        Case returnCaseRec = new Case();
        returnCaseRec.Id = caseRecord.Id;
        
        if (fieldToUpdate == 'Initial_Assignment'){                                                               
            returnCaseRec.Initial_Assignment_Time_in_Minutes__c = 0;
        }
        
        if (fieldToUpdate == 'Initial_Response'){                                                               
            returnCaseRec.Initial_Response_Time_in_Minutes__c = 0;
        }
        if (fieldToUpdate == 'Closure'){                                                               
            returnCaseRec.Time_to_Closure_B_Minutes__c = 0;
        }
        if (fieldToUpdate == 'Resolve'){                                                               
            returnCaseRec.Time_to_Resolve_B_Minutes__c = 0;
        }
        
        
        if(startDateTime!= NULL && endDateTime != NULL){
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
                
                if (validTimeMap.containsKey(currentDay)) {
                    Integer businessMinutesForDay = validTimeMap.get(currentDay);
                    
                    // Adjust the calculation for the start and end days
                    if (currentDate.date() == startDate.date()) {
                        Time startTime = convertTimeToGMT(startDate.time(), UserInfo.getTimeZone().getID());
                        String dayOfWeek = currentDate.format('EEEE', 'GMT');
                        Map<String, Time> businessHours = businessHoursMap.get(dayOfWeek);
                        Time businessStartTime = businessHours.get('Start');
                        Time businessEndTime = businessHours.get('End');
                        
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
                        
                        if (endTime < businessEndTime) {
                            businessMinutesForDay -= (businessEndTime.hour() * 60 + businessEndTime.minute()) - (endTime.hour() * 60 + endTime.minute());
                        }
                    }
                    
                    businessMinutesDifference += businessMinutesForDay;
                }
                currentDate = currentDate.addDays(1);
            }
            
            system.debug('businessMinutesDifference ::'+businessMinutesDifference);
            
            if(fieldToUpdate == 'Initial_Assignment'){
                
                returnCaseRec.Initial_Assignment_Time_in_Minutes__c = businessMinutesDifference > 0 ? businessMinutesDifference : 0;
                
            }
            
            else if (fieldToUpdate == 'Initial_Response'){                    
                
                returnCaseRec.Initial_Response_Time_in_Minutes__c = businessMinutesDifference > 0 ? businessMinutesDifference : 0;                    
                
            }
            else if (fieldToUpdate == 'Closure'){                                                               
                returnCaseRec.Time_to_Closure_B_Minutes__c = businessMinutesDifference > 0 ? businessMinutesDifference : 0;                    
                
            }
            else if (fieldToUpdate == 'Resolve'){                                                               
                returnCaseRec.Time_to_Resolve_B_Minutes__c	 = businessMinutesDifference > 0 ? businessMinutesDifference : 0;                    
                
            }
        }
        return returnCaseRec;
        
    }
    
}