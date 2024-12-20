public class MX_CaseUnitTest {
    static testMethod void MX_CaseUnitTest() 
    {
    Test.startTest();
    Case a = new Case();
    a.Origin='Email';
    a.Status='New';
    a.Type='Technical Support';
    insert a;
    
        
  //  Case c1=[select Id,CaseNumber,subject,Last_Status__c from Case where id='500T0000000so04'];     
    Case c1=[select Id,CaseNumber,subject,Last_Status__c from Case LIMIT 1];     

 
    //Asset a1 = new Asset();
//  Asset[] a1=[select Id,Name,Quantity from Asset where Id='02iT0000000sFWMIA2'];
    c1.subject='test';
    c1.Last_Status__c='New';
    //c1.Priority='P2';
    c1.Status='Assigned';
    c1.Number_of_Days_with_Support_Engineer__c=2000;
    //c1.Last_Status_Change_Date__c=system.now()-4;
    update c1;
    
    c1.Last_Status__c='Pending-Customer';
    c1.Customer_Pending__c=20;
    update c1;

    c1.Last_Status__c='Pending-Customer';
    //c1.Priority='P2';
    c1.Status='Assigned';
    c1.Number_of_Days_with_Support_Engineer__c=2000;
    c1.Customer_Pending__c=null;
    update c1;

    c1.Last_Status__c='New';
    //c1.Priority='P2';
    c1.Status='Assigned';
    c1.Number_of_Days_with_Support_Engineer__c=2000;
    c1.Customer_Pending__c=null;
    update c1;

    c1.Last_Status__c='New';
    //c1.Priority='P2';
    c1.Status='Assigned';
    c1.Number_of_Days_with_Support_Engineer__c=null;
        c1.Customer_Pending__c=null;
    update c1;


    c1.Last_Status__c='Pending-Production';
    c1.Production_Pending__c=2000;
    
    update c1;

    c1.Last_Status__c='Pending-Production';
    c1.Production_Pending__c=null;
    update c1;
    
    c1.Last_Status__c='Escalated-Engineering';
    c1.Escalated_Engineering__c=10;

    update c1;

    c1.Last_Status__c='Escalated-Engineering';
    c1.Escalated_Engineering__c=null;

    update c1;
    
    c1.Last_Status__c='Assigned';
    update c1;

    c1.Last_Status__c='Escalated-Acct Mgt';
    c1.Status='Assigned';
    update c1;

    c1.Last_Status__c='Escalated-Product Management';
    update c1;

    c1.Last_Status__c='Escalated-PSO';
    update c1;

    c1.Last_Status__c='In Progress';
    update c1;

    c1.Last_Status__c='New';
    update c1;

    c1.Last_Status__c='Pending-Partner';
    update c1;
    
    c1.Last_Status__c='Pending-PatchDelivery-PSO';
    update c1;

    c1.Last_Status__c='Not Replicable';
    update c1;

    c1.Last_Status__c='Pending-QA';
    update c1;

    c1.Last_Status__c='Reassigned';
    update c1;

    c1.Last_Status__c='Resolved';
    update c1;
    
    Test.stopTest();



    }

}