@isTest 
public class ScheduleFirstTouchCleanTestClass{
static testMethod void SchedulableFirstLastTouchesOnOpps() {
   test.startTest();
   SchedulableFirstLastTouchesOnOpps lrs = new SchedulableFirstLastTouchesOnOpps();
   //lrs.iGetJobs = new GetTestJobs();  // will return > 5 asyncjobs and execute your else condition
   String schedule = '0 0 23 * * ?';
   system.schedule('Daily Schedule' , schedule, lrs);
   test.stopTest();
}
}