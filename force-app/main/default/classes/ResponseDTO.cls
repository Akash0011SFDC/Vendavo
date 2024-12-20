public with sharing class ResponseDTO {
    public Boolean success { get; set; }
    public String message { get; set; }
    public String soqlQuery { get; set; }
    public List<SObject> records { get; set; }
    // Constructor for success responses 
    public ResponseDTO(Boolean success, String message, String soqlQuery, List<SObject> records) {
        this.success = success;
        this.message = message;
        this.soqlQuery = soqlQuery;
        this.records = records;
    }

    // Constructor for error responses
    public ResponseDTO(Boolean success, String message) {
        this.success = success;
        this.message = message;
        this.soqlQuery = null;
        this.records = null;
    }

}