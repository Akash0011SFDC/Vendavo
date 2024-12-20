global class leadLifecycleLeadSummery implements Database.Batchable<sObject> {
	
	
    public String query = 'SELECT Id, Lead_Status_2019__c FROM Lead WHERE ConvertedContactId = null';

	

	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

   	 global void execute(Database.BatchableContext BC, List<Lead> Leads)
    {   

        //Lead Status 2019     
       

        Integer rawNow = 0;
        Integer suspectNow = 0;
        Integer inquiryNow = 0;
        Integer MQLNow = 0;
        Integer SALNow = 0;
        Integer SQLNow = 0;
        Integer recycledNow = 0;
        Integer nurtureNow = 0;
        Integer disqualifiedNow = 0;
        Date todayDate = system.today();
        List <Lead_Lifecycle__c> leadLife;


    	  for(Lead myLead : Leads){

            if(myLead.Lead_Status_2019__c == 'Raw'){
                rawNow++;
            }
            if(myLead.Lead_Status_2019__c == 'Suspect'){
                suspectNow++;
            }
            if(myLead.Lead_Status_2019__c == 'Inquiry'){
                inquiryNow++;
            }
            if(myLead.Lead_Status_2019__c == 'MQL'){
                MQLNow++;
            }
            if(myLead.Lead_Status_2019__c == 'SAL'){
                SALNow++;
            }
            if(myLead.Lead_Status_2019__c == 'SQL'){
                SQLNow++;
            }
            if(myLead.Lead_Status_2019__c == 'Recycle'){
                recycledNow++;
            }
            if(myLead.Lead_Status_2019__c == 'Nurture'){
                nurtureNow++;
            }
            if(myLead.Lead_Status_2019__c == 'Disqualified'){
                disqualifiedNow++;
            }
				
            
    	  }



       
         leadLife  = [SELECT Id,Raw__c, Suspect__c, Inquiry__c, MQL__c, SAL__c, SQL__c, Recycled__c, Nurture__c, Disqualified__c, Report_Date__c FROM Lead_Lifecycle__c WHERE  Report_Date__c >= :todayDate LIMIT 1 ];
         if(leadLife.size() == 0){
            Lead_Lifecycle__c ll = new Lead_Lifecycle__c();
            ll.Raw__c = rawNow;
            ll.Suspect__c = suspectNow;
            ll.Inquiry__c = inquiryNow;
            ll.MQL__c = MQLNow;
            ll.SAL__c = SALNow;
            ll.SQL__c = SQLNow;
            ll.Recycled__c = RecycledNow;
            ll.Nurture__c = NurtureNow;
            ll.Disqualified__c = DisqualifiedNow;
            ll.Report_Date__c = todayDate;

            insert ll;
         } else{
              for(Lead_Lifecycle__c ll  : leadLife ){
                ll.Raw__c += rawNow;
                ll.Suspect__c += suspectNow;
                ll.Inquiry__c += inquiryNow;
                ll.MQL__c += MQLNow;
                ll.SAL__c += SALNow;
                ll.SQL__c += SQLNow;
                ll.Recycled__c += RecycledNow;
                ll.Nurture__c += NurtureNow;
                ll.Disqualified__c += DisqualifiedNow;
                update ll;
              }
      
         }
      
     
	}
	
	global void finish(Database.BatchableContext BC) {
		
	}
	
}