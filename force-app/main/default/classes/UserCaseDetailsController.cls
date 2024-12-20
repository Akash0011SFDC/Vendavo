/**
 * @description       : 
 * @author            : 
 * @group             : 
 * @last modified on  : 07-08-2024 
 * @last modified by  : 
**/ 
public class UserCaseDetailsController {
    private String userId;                 // Private member variable to store userId 
   
    public List<Case> cases { get; set; }  // Public property to hold the list of cases
    
    public UserCaseDetailsController() {   // Constructor initializes the cases list
        cases = new List<Case>();
    }
    
    public void setUserId(String userId) {  // Setter method for userId
        this.userId = userId;
        fetchCaseData();
    }
   
    public String getUserId() {   // Getter method for userId
        return this.userId;
    }
    
    private void fetchCaseData() {   		// Private method to fetch case data based on userId
        cases = new List<Case>(); 			// Initialize the cases list to ensure it's empty before querying     
        
        if (String.isNotBlank(userId)) {   // Check if userId is not blank before querying
            cases = [
                SELECT CaseNumber, Case_Owner_Name__c, Account.Name, Subject, Status, Priority, CreatedDate, LastModifiedDate
                FROM Case
                WHERE OwnerId = :userId 
                AND Status = 'In Progress'
                AND RecordType.Name = 'Support Case'
                AND LastModifiedDate < YESTERDAY
            ];
        }
    }
}