global class batchSalesTouchesCount implements Database.Batchable<sObject>
{
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        String query = 'SELECT ID FROM Contact';
        return Database.getQueryLocator(query);
    }
   
    global void execute(Database.BatchableContext BC, List<Contact> Con)
    {   
      for(Contact conz : Con){
        List<Task> ts = [SELECT Id, Type  FROM Task WHERE WhoID  = :conz.ID]; 
        List<Task> firstTouch = [SELECT Type, CreatedDate, Subject FROM Task WHERE  WhoID  = :conz.ID ORDER BY CreatedDate ASC];
        List<Task> LastTouch = [SELECT Type, CreatedDate, Subject FROM Task WHERE  WhoID  = :conz.ID ORDER BY CreatedDate DESC];
     
         //String & Date for First and Last Touches

        String firstSalesTouchType;
        String firstSalesTouchSubject;
        DateTime firstSalesTouchDate;

        String lastSalesTouchType;
        String lastSalesTouchSubject;
        DateTime lastSalesTouchDate;
        
        
                  //String & Date Contact Object Field Update
              //First Touch
        for(Task firstTouchData : firstTouch){
              if(firstTouch.size() > 0){
                  firstSalesTouchType = firstTouch[0].Type;
                  firstSalesTouchSubject = firstTouch[0].Subject;
                  firstSalesTouchDate = firstTouch[0].CreatedDate;
          }
        }
              //Last Touch
        for(Task lastTouchData : lastTouch){       
               if(lastTouch.size() > 0){
                  lastSalesTouchType = LastTouch[0].Type;
                  lastSalesTouchSubject = LastTouch[0].Subject;
                  lastSalesTouchDate = LastTouch[0].CreatedDate;
          }
        
        }
       //Integer Update 
        Integer intNumberOfInfoRequest = 0;
        Integer intNumberOfMeetings = 0;
        Integer intNumberOfRFP = 0;
        Integer intNumberOfAnalystEngagement = 0;
        Integer intNumberOfOther = 0;
        Integer intNumberTotalSales = 0;

        

  
        for(Task taskdata : ts ){
            if(taskdata.Type == 'Call' || taskdata.Type == 'Email' || taskdata.Type == 'Information Request'){
                intNumberOfInfoRequest++;
            }
            if(taskdata.Type == 'Meeting (1st)' || taskdata.Type == 'Meeting (WebEx)' || taskdata.Type == 'Meeting (Onsite)' || taskdata.Type == 'Meeting Add-On (WebEx)' || taskdata.Type == 'Demo (WebEx)' || taskdata.Type == 'Demo (Onsite)'){
                intNumberOfMeetings++;
            }
            if(taskdata.Type == 'Business Case Created' || taskdata.Type == 'Business Case Submitted' || taskdata.Type == 'RFP Submitted'){
                intNumberOfRFP++;
            }
            if(taskdata.Type == 'Analyst Meeting' || taskdata.Type == 'Analyst Reference'){
                intNumberOfAnalystEngagement++;
            }
            if(taskdata.Type == 'Content Piece Authored' || taskdata.Type == 'Other'){
                intNumberOfOther++;
            }

        }
          intNumberTotalSales = intNumberOfMeetings + intNumberOfOther + intNumberOfRFP + intNumberOfAnalystEngagement + intNumberOfInfoRequest;


          Conz.Number_of_Sales_Requests__c = intNumberOfInfoRequest;
          Conz.Number_of_Sales_Analyst_Engagements__c = intNumberOfAnalystEngagement;
          Conz.Number_of_Sales_rfp__c = intNumberOfRFP;
          Conz.Number_of_Sales_Meetings__c = intNumberOfMeetings;
          Conz.Number_of_Sales_Other_Tasks__c = intNumberOfOther;
          Conz.Total_Sales_Interactions__c = intNumberTotalSales; 
          
          Conz.First_Sales_Touch_Type__c = firstSalesTouchType; 
          Conz.First_Sales_Touch_Date__c = firstSalesTouchDate;  
          Conz.First_Sales_Touch_Subject__c = firstSalesTouchSubject; 
          
          Conz.Last_Sales_Touch_Type__c = lastSalesTouchType; 
          Conz.Last_Sales_Touch_Date__c = lastSalesTouchDate;  
          Conz.Last_Sales_Touch_Subject__c = lastSalesTouchSubject; 
  
       update con; 
      
      }

    }   
    global void finish(Database.BatchableContext BC)
    {
    }
}