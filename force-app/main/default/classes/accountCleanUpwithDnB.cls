global class accountCleanUpwithDnB implements Database.Batchable<sObject> {
	
	public String query = 'SELECT Id, D_U_N_S__c, SIC, SicDesc, BillingCity, BillingCountry, BillingStreet, BillingState, BillingPostalCode, Website, AnnualRevenue, Phone, NumberOfEmployees, Ownership, TickerSymbol,DNBoptimizer__DnBCompanyRecord__c FROM Account WHERE DNBoptimizer__DnBCompanyRecord__c != NULL';

    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        return Database.getQueryLocator(query);
    }
   global void execute(Database.BatchableContext BC, List<Account> accs)
    {  

         list <DNBoptimizer__DnBCompanyRecord__c> dnb_record;
         DateTime dt = System.now(); 
         String updateNote;


      for(Account accs2Query : accs){
        
          for(DNBoptimizer__DnBCompanyRecord__c  dnb : dnb_record = [SELECT DNBoptimizer__DUNSNumber__c, DNBoptimizer__SIC8Code1__c, DNBoptimizer__SIC8Code1Description__c, DNBoptimizer__PrimaryCityName__c , DNBoptimizer__PrimaryCountryCode_ISO__c, DNBoptimizer__PrimaryStreetAddress__c , DNBoptimizer__PrimaryStateProvinceName__c, DNBoptimizer__PrimaryPostalCode__c, DNBoptimizer__WebAddress__c, DNBoptimizer__SalesVolumeUSDollars__c, DNBoptimizer__TelephoneNumber__c, DNBoptimizer__EmployeeCountTotal__c, DNBoptimizer__Public_PrivateIndicator__c, DNBoptimizer__StockSymbol__c FROM DNBoptimizer__DnBCompanyRecord__c WHERE DNBoptimizer__DnBCompanyRecord__c.Id = : accs2Query.DNBoptimizer__DnBCompanyRecord__c ]){
            updateNote = null;
            if(accs2Query.D_U_N_S__c == null){
                accs2Query.D_U_N_S__c = dnb.DNBoptimizer__DUNSNumber__c;
                updateNote = 'Duns #';
            }

              if (accs2Query.SIC == null){
                accs2Query.SIC = dnb.DNBoptimizer__SIC8Code1__c;
                updateNote += ', SIC#';
              }
              if (accs2Query.SicDesc == null){
                accs2Query.SicDesc = dnb.DNBoptimizer__SIC8Code1Description__c;
                updateNote += ', SIC Desc';
              }
               if (accs2Query.BillingStreet == null){
                accs2Query.BillingStreet = dnb.DNBoptimizer__PrimaryStreetAddress__c ;
                updateNote += ', Address';
              }
              if (accs2Query.BillingCity == null){
                accs2Query.BillingCity = dnb.DNBoptimizer__PrimaryCityName__c ;
                updateNote += ', Address City';
              }

              if (accs2Query.BillingState == null){
                accs2Query.BillingState = dnb.DNBoptimizer__PrimaryStateProvinceName__c;
                updateNote += ', Address State';
              }
              if (accs2Query.BillingPostalCode == null){
                accs2Query.BillingPostalCode = dnb.DNBoptimizer__PrimaryPostalCode__c;
                updateNote += ', Address Postal Code';
              }
              if (accs2Query.BillingCountry == null){
                accs2Query.BillingCountry = dnb.DNBoptimizer__PrimaryCountryCode_ISO__c;
                updateNote += ', Address Country';
              }
             
              if (accs2Query.Website == null){
                accs2Query.Website = dnb.DNBoptimizer__WebAddress__c;
                updateNote += ', Website';
              }

              if (accs2Query.AnnualRevenue == null){
                accs2Query.AnnualRevenue = dnb.DNBoptimizer__SalesVolumeUSDollars__c;
                updateNote += ', Revenue';
              }
              if (accs2Query.Phone == null){
                accs2Query.Phone = dnb.DNBoptimizer__TelephoneNumber__c;
                updateNote += ', Telephone';
              }
              if (accs2Query.NumberOfEmployees == null  && dnb.DNBoptimizer__EmployeeCountTotal__c > 1 ){
                accs2Query.NumberOfEmployees = dnb.DNBoptimizer__EmployeeCountTotal__c.intValue();
                updateNote += 'Employee Count';
              }

              if (accs2Query.Ownership == null){
                accs2Query.Ownership = dnb.DNBoptimizer__Public_PrivateIndicator__c;
                updateNote += ', Ownership';
              }
              if (accs2Query.TickerSymbol == null){
                accs2Query.TickerSymbol = dnb.DNBoptimizer__StockSymbol__c;
                updateNote += ', Stock Symbol';
              }



          }

          if(updateNote != null){

            accs2Query.Last_Update_by_Script__c = updateNote;
            accs2Query.Last_Update_by_Script_Date__c = dt;  
          }

       
        

      }
      update accs;
    }   
	
	global void finish(Database.BatchableContext BC) {
		
	}
	
}