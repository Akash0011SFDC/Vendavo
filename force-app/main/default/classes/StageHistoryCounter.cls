/*
 *  StageHistoryCounter Tallys stage movement track stage paths progression.
 *  @author  Peter Yim
 *  @date 2018
 * 
 * 
 */

global class StageHistoryCounter implements Database.Batchable<sObject> {
	
	String query;
	
	global StageHistoryCounter() {
		
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		String query = 'SELECT ID, CreatedDate, CloseDate FROM Opportunity';
        return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<Opportunity> Opps) {
		
	     //list
      list <OpportunityHistory> historylist;   
      //exlude API Admins
	  List <User> admins;

   	  Set<id> adminID = new set<id>();
		
		adminID.add('00538000004bqwl');
		adminID.add('005500000010QInAAM');
		adminID.add('00550000000yOG4AAM');
		
		

     for(Opportunity opps2update : Opps){
     	//Stage Interger

     	Map<String, Integer> stageCount = new Map<String, Integer>();
	     stageCount.put('1', 0 );
	     stageCount.put('2', 0 );
	     stageCount.put('3', 0 );
	     stageCount.put('4', 0 );
	     stageCount.put('5', 0 );
	     stageCount.put('6', 0 );
	     stageCount.put('7', 0 );
	     stageCount.put('M', 0 );
         
         Map<String, Datetime> stageCountDate = new Map<String, Datetime>();
		 stageCountDate.put('1', null );
	     stageCountDate.put('2', null );
	     stageCountDate.put('3', null );
	     stageCountDate.put('4', null );
	     stageCountDate.put('5', null );
	     stageCountDate.put('6', null );
	     stageCountDate.put('7', null );
	     stageCountDate.put('M', null );

	     Integer currentStage = 0;
	     Boolean first = TRUE;

	     String stage = '';
	     String stagePath = '';
	     Datetime startdate = opps2update.CreatedDate;
	     Datetime enddate;
	     Datetime currentEndDate = system.now(); 


	     Integer startMonth = 0;
	     Integer startYear = 0;
	     Integer currentQtr = 0;
	     Datetime nextdate = opps2update.CreatedDate;
	     Integer nextMonth = 0;
	     Integer nextYear = 0;

	     Integer nextQtr = 0;
	     Integer closeQtrPush = 0;




    	 List <OpportunityFieldHistory> oppHistory = [SELECT CreatedById,CreatedDate FROM OpportunityFieldHistory WHERE OpportunityId = : opps2update.id AND CreatedById NOT IN : adminID ORDER BY CreatedDate DESC NULLS FIRST LIMIT 1 ];

		 for(OpportunityHistory history : historylist  = [SELECT CreatedDate,CloseDate,Id,OpportunityId,StageName,SystemModstamp FROM OpportunityHistory WHERE OpportunityId = : opps2update.id  ORDER BY CreatedDate ASC]){
            
		 	//first row
            if(first){
            	stage = history.StageName.substring(0,1);
            	startdate = history.CreatedDate;
            	stageCountDate.put(stage, startdate);

            	stagePath = stage;
            	first = FALSE;


            	//qtr count
            	startMonth = history.CloseDate.month();
            	startYear = history.CloseDate.year();

            	if(startMonth > 9){
            		currentQtr = startYear + 4;
            	} else if(startMonth > 6){
            		currentQtr = startYear + 3;
				} else if(startMonth > 3){
            		currentQtr = startYear + 2;
            	} else {
            		currentQtr = startYear + 1;
            	}
            } else {
            	nextdate = history.CloseDate;
            	nextMonth = history.CloseDate.month();
            	nextYear = history.CloseDate.year();

            	if(nextMonth > 9){
            		nextQtr = nextYear + 4;
            	} else if(nextMonth > 6){
            		nextQtr = nextYear + 3;
				} else if(nextMonth > 3){
            		nextQtr = nextYear + 2;
            	} else {
            		nextQtr = nextYear + 1;
            	}

            	if(currentQtr != nextQtr){
            		currentQtr = nextQtr;
            		closeQtrPush++;
            	}

            }

			 if(stage != history.StageName.substring(0,1)){
	           
            	enddate =  history.CreatedDate;
            	integer daysDiff =  startdate.Date().daysBetween(enddate.Date());

            	//if the stage change was made in the same day
            	if(daysDiff == 0){
            		daysDiff = 1;
            	}


            	if(stage != '1' && stage != '2' && stage != '3' && stage != '4' && stage != '5' && stage != '6' && stage != '7' && stage != 'M'){
	            	startdate = history.CreatedDate;
	            } else {
		            	 	
					stageCount.put(stage,  stageCount.get(stage) + daysDiff );
	            	stageCountDate.put(stage, startdate);


	            }
	         
	            stage = history.StageName.substring(0,1);
            	startdate = history.CreatedDate;
            	stagePath += '->' + stage;

            


            }




		  } //end of historyList

		  
		  if(stage != null){
            	integer daysDiff =  startdate.Date().daysBetween(currentEndDate.Date());
	            currentStage = daysDiff;
	            if(stage == '1' || stage == '2' || stage == '3' || stage == '4' || stage == '5' || stage == '6' || stage == '7' || stage == 'M'){
					stageCount.put(stage,  stageCount.get(stage) + daysDiff );
	            	stageCountDate.put(stage, startdate);
	            }
	        }//if null results for

	     opps2update.Days_in_Stage_1__c = stageCount.get('1');
	     opps2update.Days_in_Stage_2__c = stageCount.get('2');
	     opps2update.Days_in_Stage_3__c = stageCount.get('3');
	     opps2update.Days_in_Stage_4__c = stageCount.get('4');
	     opps2update.Days_in_Stage_5__c = stageCount.get('5');
	     opps2update.Days_in_Stage_6__c = stageCount.get('6');
	     opps2update.Days_in_Stage_7__c = stageCount.get('7');
	     opps2update.Days_in_Stage_M__c = stageCount.get('M');

	  //   //add Dates
		 if(stageCountDate.get('1') != null){
		     opps2update.Date_in_Stage_1__c = stageCountDate.get('1');
		 }
	     if(stageCountDate.get('2') != null){
		     opps2update.Date_in_Stage_2__c = stageCountDate.get('2');
		 }
	     if(stageCountDate.get('3') != null){
		     opps2update.Date_in_Stage_3__c = stageCountDate.get('3');
		 }
	     if(stageCountDate.get('4') != null){
		     opps2update.Date_in_Stage_4__c = stageCountDate.get('4');
		 }
	     if(stageCountDate.get('5') != null){
		     opps2update.Date_in_Stage_5__c = stageCountDate.get('5');
		 }
	     if(stageCountDate.get('6') != null){
		     opps2update.Date_in_Stage_6__c = stageCountDate.get('6');
		 }
		   if(stageCountDate.get('7') != null){
		     opps2update.Date_in_Stage_7__c = stageCountDate.get('7');
		 }
	     if(stageCountDate.get('M') != null){
		     opps2update.Date_in_Stage_M__c = stageCountDate.get('M');
		 }
	     opps2update.Days_in_Current_Stage__c = currentStage;
	     opps2update.Stage_Path__c = stagePath;
		 opps2update.QTR_Closed_Push_counter__c = closeQtrPush;
		
		 if(oppHistory.size() != 0){
	     	opps2update.Last_Modified_Rep__c = oppHistory[0].CreatedById;
	     	opps2update.Last_Modified_Date_by_Rep__c = oppHistory[0].CreatedDate;

		}//end size;


		 }//end of oppertunity

		  update opps;
	
	}
	
	global void finish(Database.BatchableContext BC) {
		
	}
	
}