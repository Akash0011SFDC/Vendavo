@isTest 
public class SchedulableAccountLeadSnapshotTest{
static testMethod void SchedulableAccountLeadSnapshot() {
   test.startTest();
   SchedulableAccountLeadSnapshot lrs = new SchedulableAccountLeadSnapshot();
   //lrs.iGetJobs = new GetTestJobs();  // will return > 5 asyncjobs and execute your else condition
   String schedule = '0 0 23 * * ?';
   system.schedule('Daily Schedule' , schedule, lrs);
   test.stopTest();
}
}