/*
 *  Update accounts with VIR Industry Mapping Based by SIC Code
 *  test class
 *  @author Peter Yim
 *  @date Aug 6 2019
 * 
 * 
 */
 @isTest
private class updateAccountsVIRtest
{
	@isTest
	static void updateAccountsVIRtest()
	{
		       

      DNBoptimizer__DnBCompanyRecord__c CreateDNBRec = new DNBoptimizer__DnBCompanyRecord__c();
      CreateDNBRec.DNBoptimizer__SIC8Code1__c = '44';
      insert CreateDNBRec;
		// Account to Create

        Account AccountToCreate = new account();

        AccountToCreate.name = 'New Account';
        AccountToCreate.BillingCountry = 'United States';
        AccountToCreate.BillingState = 'CA';
        AccountToCreate.SIC = '44';
        AccountToCreate.DNBoptimizer__DnBCompanyRecord__c = CreateDNBRec.Id;
        AccountToCreate.VIR_Main__c = NULL;
        AccountToCreate.VIR_Sub__c = NULL;
        insert AccountToCreate;

      Account AccountToCreate2 = new account();

        AccountToCreate2.name = 'New Account';
        AccountToCreate2.BillingCountry = 'United States';
        AccountToCreate2.BillingState = 'CA';
        AccountToCreate2.SIC = '131';
        AccountToCreate2.VIR_Main__c = NULL;
        AccountToCreate2.VIR_Sub__c = NULL;
        insert AccountToCreate2;

            
        Account AccountToCreate3 = new account();

        AccountToCreate3.name = 'New Account';
        AccountToCreate3.BillingCountry = 'United States';
        AccountToCreate3.BillingState = 'CA';
        AccountToCreate3.SIC = '384';
        AccountToCreate3.VIR_Main__c = NULL;
        AccountToCreate3.VIR_Sub__c = NULL;
        insert AccountToCreate3;

  Account AccountToCreate4 = new account();

        AccountToCreate4.name = 'New Account';
        AccountToCreate4.BillingCountry = 'United States';
        AccountToCreate4.BillingState = 'CA';
        AccountToCreate4.SIC = '391';
        AccountToCreate4.VIR_Main__c = NULL;
        AccountToCreate4.VIR_Sub__c = NULL;
        insert AccountToCreate4;

            

 
           Test.startTest();
           updateAccountsVIR updateVIR = new updateAccountsVIR();
           Database.executeBatch(updateVIR);
           Test.stopTest();
         
         // Verify Record are updated 
           Integer i = [SELECT COUNT() FROM Account WHERE VIR_Main__c != NULL ];
           System.assertEquals(i, 4);



	}
}