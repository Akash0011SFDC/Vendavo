/*
 * batchConvertLeads Convert Leads if MarktoConvert is checked 
 * @Author: Peter Yim
 * @Date: 2018
 *
 */
 
 global class batchConvertLeads implements Database.Batchable<sObject> {
    
    
     public String query = 'SELECT Id,markToConvert__c, LeanData__Reporting_Matched_Account__c, Status FROM Lead WHERE ConvertedContactId = NULL AND markToConvert__c = TRUE ';

    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Lead> leads) {
        //if marked to convert then Lead is converted
            for(Lead updateLeads : leads){
                Database.LeadConvert lc = new Database.LeadConvert();
                lc.setLeadId(updateLeads.Id);
                lc.setAccountId(updateLeads.LeanData__Reporting_Matched_Account__c);
                lc.setConvertedStatus(updateLeads.Status);

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