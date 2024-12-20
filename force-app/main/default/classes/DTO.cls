/**
* @File Name : DTO.cls
* @Description : Hold wrapper for all classess
* @Author : Dreamwares
* @Last Modified By : Dreamwares
* @Last Modified On : October 3, 2024
* @Modification Log :
*==============================================================================
* Ver | Date 			| Author 		| Modification
*==============================================================================
* 1.0 | October 3, 2024	| Dreamwares	| Initial Version
**/

public class DTO {

    public class EnhanceSecurityControllerResponse{
        @AuraEnabled public List<sObject> records { get; set; }
        @AuraEnabled public Integer totalCount { get; set; }
        @AuraEnabled public String errorMessage { get; set; }
        @AuraEnabled public Boolean IsValid { get; set; }
                
        public EnhanceSecurityControllerResponse(List<sObject> records, Integer totalCount) {
            this.records = records;
            this.totalCount = totalCount;
        }
        
        public EnhanceSecurityControllerResponse(Boolean isValid, String errorMessage) {
            this.IsValid = isValid;
            this.errorMessage = errorMessage;
        }
        
        public EnhanceSecurityControllerResponse(Boolean isValid) {
            this.IsValid = isValid;
        }
    }
}