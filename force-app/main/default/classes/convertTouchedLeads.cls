global class convertTouchedLeads implements Database.Batchable<sObject> {
	
	
    public String query = 'SELECT Id , LeanData__Matched_Account_Name__c FROM Lead WHERE Total_Number_of_Touches__c > 0 AND ConvertedContactId = null AND LeanData__Matched_Account_Name__c != null';

	

	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

   	 global void execute(Database.BatchableContext BC, List<Lead> Leads)
    {   
    	  for(Lead myLead : Leads){

				Database.LeadConvert lc = new Database.LeadConvert();
				lc.setLeadId(myLead.Id);
				lc.setDoNotCreateOpportunity(True);

				LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
				lc.setConvertedStatus(convertStatus.MasterLabel);

				Database.LeadConvertResult lcr = Database.convertLead(lc);
				System.assert(lcr.isSuccess());

    	  }
	}
	
	global void finish(Database.BatchableContext BC) {
		
	}
	
}