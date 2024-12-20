@isTest 
public class NumberOfTouchesOnContactTestClass {
    public static String testAccountID;
    public static String testContactID;
    public static String testCampaignID;
    static testMethod void UpdateCountOfContactsTouches(){
       
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
       
       // Campaign to Create    
           Campaign campaignToCreate = new Campaign(Name = 'Testcampaign', IsActive = TRUE);
           campaignToCreate.type = 'Email';
           campaignToCreate.Channel__c = 'Email';
           //campaignToCreate.RecordType = Email ;
          
           insert campaignToCreate;
           testCampaignID = campaignToCreate.ID;
           
       //CampaignMember to Create     
           CampaignMember campaignMemberToCreate = new CampaignMember();
           campaignMemberToCreate.CampaignID = campaignToCreate.ID;
           campaignMemberToCreate.ContactID = ContactToCreate.ID;

           
           insert campaignMemberToCreate;
           
           campaignMemberToCreate.Status = 'Clicked';
           update campaignMemberToCreate;
           update campaignToCreate;
           update contactToCreate;
           
       
           //test.stopTest();
           
           Test.startTest();
           UpdateCountOfContactsTouches c = new UpdateCountOfContactsTouches();
           Database.executeBatch(c);
           Test.stopTest();
         
         // Verify Record are updated 
           Integer i = [SELECT COUNT() FROM Contact WHERE Total_Number_Of_Touches__c != NULL];
           System.assertEquals(i, 1);

}
}