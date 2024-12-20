@isTest 
public class NumberOfSalesTouchesOnContactTestClass {
    public static String testAccountID;
    public static String testContactID;
    public static String testCampaignID;
    static testMethod void batchSalesTouchesCount (){
       
     // test.startTest();

       // Account to Create

        account AccountToCreate = new account(name = 'Test Account 9-14-2015', BillingCountry = 'United States', BillingState = 'CA');


            testAccountID = AccountToCreate.ID; 
            insert AccountToCreate;


        
       Contact ContactToCreate = new Contact();
       
       // Contact to Create
       ContactToCreate.FirstName = 'Ken';
       ContactToCreate.LastName  = 'test1';
       ContactToCreate.Email     = 'kennaku1@uw.edu';
       ContactToCreate.CurrencyIsoCode = 'USD';
       ContactToCreate.AccountID = AccountToCreate.ID; 
       ContactToCreate.MailingCountry = 'United States';
       ContactToCreate.MailingState = 'CA';
       
             
           insert ContactToCreate;
           
           testContactID = ContactToCreate.ID;  
       
        // Create New Task 
        Task TaskToCreate = new Task();
        
        TaskToCreate.WhoID = ContactToCreate.ID; 
        TaskToCreate.Subject = 'Test Subject Line';
        TaskToCreate.Type = 'Call';
        
            insert TaskToCreate;        
       
           //test.stopTest();
           
           Test.startTest();
           batchSalesTouchesCount c = new batchSalesTouchesCount();
           Database.executeBatch(c);
           Test.stopTest();
         
         // Verify Record are updated 
           Integer i = [SELECT COUNT() FROM Contact WHERE Total_Sales_Interactions__c != NULL];
           System.assertEquals(i, 1);

}
}