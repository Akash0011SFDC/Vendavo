@isTest
private class moveAmountToPLtest {
	
	static testMethod void moveAmountToPLtest() {
	 Date oppsCloseDateRefrence;
      Date oppsCreateDateRefrence;

       // Account to Create

        account AccountToCreate = new account(name = 'Test Account 9-14-2018', BillingCountry = 'United States', BillingState = 'CA',Most_Recent_Touch_Campaign__c = 'none', Industry = 'Chemicals, Oil & Gas', Region__c = ' NA - Central',  SDR__c = '00550000004U4mP');
        insert AccountToCreate;

        Opportunity OpportunityToCreate = new opportunity();
       		Set<Id> oppsID = new Set<Id>(); 
        OpportunityToCreate.Name = 'Activated Account';
        OpportunityToCreate.StageName = 'Marketing';
        OpportunityToCreate.Type = 'Direct - Perpetual License';
        OpportunityToCreate.Deal_Scope__c = 'Profit Analyzer and Price Optimization Manager';
        OpportunityToCreate.Short_Description__c='Activated Account';
         OpportunityToCreate.AccountID = AccountToCreate.ID;

               OpportunityToCreate.CloseDate = Date.Today().addYears(1);
               OpportunityToCreate.CreatedDate = Date.Today();
               OpportunityToCreate.CurrencyIsoCode = 'USD';
               OpportunityToCreate.LeadSource = 'Marketing - MQL';
               OpportunityToCreate.Vendavo_Forecast_Category__c = 'Omitted';
             OpportunityToCreate.Maintenance_Amount__c = 81000;
             OpportunityToCreate.amount = 450000;
             OpportunityToCreate.Perpetual_License__c = 0;

                  OpportunityToCreate.Days_in_Stage_1__c = 0;
                  OpportunityToCreate.Days_in_Stage_2__c = 0;
                  OpportunityToCreate.Days_in_Stage_3__c = 0;
                  OpportunityToCreate.Days_in_Stage_4__c = 0;
                  OpportunityToCreate.Days_in_Stage_5__c = 0;
                  OpportunityToCreate.Days_in_Stage_6__c = 0;
                  OpportunityToCreate.Days_in_Stage_M__c = 0;


       insert OpportunityToCreate;


       Test.startTest();
       MoveAmountToPL c = new MoveAmountToPL();
       Database.executeBatch(c);
       Test.stopTest();
     
     // Verify Record are updated 
       Integer i = [SELECT COUNT() FROM Opportunity WHERE Perpetual_License__c != NULL];
       System.assertEquals(i, 1);

     
	}
	
	
	
}