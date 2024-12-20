@isTest 
public class ScheduleSICObjectUpdateTest{
static testMethod void SchedulableSICObjectFieldUpdate() {
   test.startTest();
   SchedulableSICObjectFieldUpdate lrs = new SchedulableSICObjectFieldUpdate();
   //lrs.iGetJobs = new GetTestJobs();  // will return > 5 asyncjobs and execute your else condition
   String schedule = '0 0 23 * * ?';
   system.schedule('Daily Schedule' , schedule, lrs);
   test.stopTest();
}
}