/*
 * accountCleanUpwithDnB Test class
 * @Author: Peter Yim
 * @Date: 2018
 *
 */
 @isTest 
public class accountCleanUpwithDnBtest{

    static testMethod void accountCleanUpwithDnB(){

		DNBoptimizer__DnBCompanyRecord__c dnbRecord = new DNBoptimizer__DnBCompanyRecord__c(
			DNBoptimizer__DUNSNumber__c = '354216335', 
			DNBoptimizer__SIC8Code1__c = '23121111', 
			DNBoptimizer__SIC8Code1Description__c = 'Test', 
			DNBoptimizer__PrimaryCityName__c  = 'Test', 
			DNBoptimizer__PrimaryCountryCode_ISO__c = 'US', 
			DNBoptimizer__PrimaryStreetAddress__c  = '123 Main St', 
			DNBoptimizer__PrimaryStateProvinceName__c = 'CA', 
			DNBoptimizer__PrimaryPostalCode__c = '94134', 
			DNBoptimizer__WebAddress__c = 'http://www.vendavo.com', 
			DNBoptimizer__SalesVolumeUSDollars__c = 234353232, 
			DNBoptimizer__TelephoneNumber__c = '2131212312', 
			DNBoptimizer__EmployeeCountTotal__c = 100, 
			DNBoptimizer__Public_PrivateIndicator__c = 'Public', 
			DNBoptimizer__StockSymbol__c = 'Test'
		);
					
		insert dnbRecord;

        account AccountToCreate = new account(
        	name = 'Test Account 9-14-2015', 
        	BillingCountry = 'United States', 
        	BillingState = 'CA',
        	Most_Recent_Touch_Campaign__c = 'none',
        	Most_Recent_Touch_Date__c = date.today(),
        	Most_Recent_Touch_Person__c = 'none',
        	Most_Recent_Touch_Type__c = 'none',
        	DNBoptimizer__DnBCompanyRecord__c = dnbRecord.Id,
        	Net_New_Engaged_Leads__c = 0,
        	Net_New_Nurture_Leads__c = 0,
        	Net_New_Prospect_Leads__c = 0,
        	Net_New_Qualified_Leads__c = 0,
        	Net_New_SAL_Leads__c = 0,
        	Net_New_SQL_Leads__c = 0,
        	Total_Engaged_Leads_Contacts__c = 0,
        	Total_Leads_and_Contacts__c = 0,
        	Snapshot_Engaged_Leads__c = 0,
        	Snapshot_Nurture_Leads__c = 0,
        	Snapshot_Prospect_Leads__c = 0,
        	Snapshot_Qualified_Leads__c = 0,
        	Snapshot_SAL_Leads__c = 0,
        	Snapshot_SQL_Leads__c = 0,
        	Transitioned_Engaged_Leads__c = 0,
        	Transitioned_Nurture_Leads__c = 0,
        	Transitioned_Prospect_Leads__c = 0,
        	Transitioned_Qualified_Leads__c = 0,
        	Transitioned_SAL_Leads__c = 0,
        	Transitioned_SQL_Leads__c = 0,
        	Engaged_Contacts_in_Last_30_Days__c = 0,
			Number_of_Advertising_Touches__c = 0,
			Number_of_DirectMail_Touches__c = 0,
			Number_of_Email_Touches__c = 0,
			Number_of_Event_Touches__c = 0,
			Number_of_Telemarketing_Touches__c = 0,
			Number_of_Webinar_Touches__c = 0,
			Number_of_Website_Touches__c = 0,
			Content_Syndication_Touches__c = 0,
			Number_of_180_Days_Advertising_Touches__c = 0,
			Number_of_180_Days_DirectMail_Touches__c = 0,
			Number_of_180_Days_Email_Touches__c = 0,
			Number_of_180_Days_Event_Touches__c = 0,
			Number_of_180_Days_Telemarketing_Touches__c = 0,
			Number_of_180_Days_Webinar_Touches__c = 0,
			Number_of_180_Days_Website_Touches__c = 0,
			Number_of_365_Days_Advertising_Touches__c = 0,
			Number_of_365_Days_DirectMail_Touches__c = 0,
			Number_of_365_Days_Email_Touches__c = 0,
			Number_of_365_Days_Event_Touches__c = 0,
			Number_of_365_Days_Telemarketing_Touches__c = 0,
			Number_of_365_Days_Webinar_Touches__c = 0,
			Number_of_365_Days_Website_Touches__c = 0,
			Number_of_18_Months_Advertising_Touches__c = 0,
			Number_of_18_Months_DirectMail_Touches__c = 0,
			Number_of_18_Months_Email_Touches__c = 0,
			Number_of_18_Months_Event_Touches__c = 0,
			Number_of_18_Months_Telemarketing_Touch__c = 0,
			Number_of_18_Months_Webinar_Touches__c = 0,
			Number_of_18_Months_Website_Touches__c = 0,
			Total_Number_of_Engaged_Contacts__c = 0,
			Total_Number_of_Engaged_Contacts_in_180__c = 0,
			Total_Number_of_Engaged_Leads__c = 0,
			Total_Number_of_Engaged_Leads_in_180_day__c = 0,
			Total_Leads_Behavior_Score__c = 0,
			Total_Leads_Demographic_Score__c = 0,
			Total_Leads_Behavior_Demo_Score__c = 0,
			Total_Contacts_Behavior_Score__c = 0,
			Total_Contacts_Demographic_Score__c = 0,
			Total_Contacts_Behavior_Demo_Score__c = 0,
			Total_Leads_Contacts_Behavior_Score__c = 0,
			Total_Leads_Contacts_Demographic_Score__c = 0,
			Total_Leads_Contacts_Behavior_Demo_Score__c = 0,
			Score_Lost_No_Decision_Stage_3__c = 0,
			Score_Snapshot_Hot_Leads__c = 0,
			Score_Snapshot_Warm_Leads__c = 0,
			Score_LC_Demographics__c = 0,
			Score_LC_Behavior__c = 0,
			Score_Recent_Engagement_180_Days__c = 0,
			Score_Recent_Engagement_365_Days__c = 0,
			Score_Relevant_Search__c = 0,
			Score_Stage_Opportunity__c = 0,
			Score_Vendavo_Page_Views__c = 0,
			Score_Vendavo_Total__c = 0,
			Stage_M_Opportunity__c = FALSE,
			Stage_M_Creation_Date__c = null,
			Current_Opportunity__c = null,
			Stage_3_Or_More_in_the_Last_18_Months__c = FALSE,
			Total_Number_of_Sales_Touches__c = 0,
			Number_of_180_Days_Sales_Touches__c = 0,
			Last_Sales_Touch_Date__c = null,
			Page_Visit_Last_7_Days__c =1,
			Page_Visit_Last_30_Days__c = 0,
			Happy_Path_Transition_Qualified__c = 0,
			Happy_Path_Transition_Engaged__c = 0,
			Happy_Path_Transition_Contacted__c = 0,
			Happy_Path_Transition_Nurture__c = 0,
			Happy_Path_Transition_Sql__c = 0,
			Happy_Path_Transition_SAL__c = 0,
			Happy_Path_Transition_Prospect__c = 0 ,
			Snapshot_Contacted_leads__c = 0,
			Transitioned_Contacted_Leads__c = 0,
			Net_New_Contacted_Leads__c = 0,
			TAM_2018__c = TRUE 
		);
            
            insert AccountToCreate;

       Test.startTest();
       accountCleanUpwithDnB dnb = new accountCleanUpwithDnB();
       Database.executeBatch(dnb);
       Test.stopTest();
     
     // Verify Record are updated 
       Integer i = [SELECT COUNT() FROM Account WHERE DNBoptimizer__DnBCompanyRecord__c != NULL];
       System.assertEquals(i, 1);



	}
}