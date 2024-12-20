/**
* @File Name : EnhanceSecurityController.cls
* @Description : Controller for the Securty Enahance LWC components
* @Author : Dreamwares
* @Last Modified By : Dreamwares
* @Last Modified On : October 3, 2024
* @Modification Log :
*==============================================================================
* Ver | Date 			| Author 		| Modification
*==============================================================================
* 1.0 | October 3, 2024 | Dreamwares  	| Initial Version
**/

public with sharing class EnhanceSecurityController {
    
    @AuraEnabled(cacheable=true)
    public static DTO.EnhanceSecurityControllerResponse getRecords(String tabName, String searchKey,Integer limitSize, Integer offset, String sortBy, string sortDirection){
        try {

            List<Security_Enhancement_Setting__mdt> metadataRecords = EnhanceSecurityHelper.getMetadataRecords(tabName);
            
            List<sObject> sObjectList = new List<sObject>(); 
            
            if(metadataRecords != NULL && !metadataRecords.isEmpty()){  
                ResponseDTO response = EnhanceSecurityHelper.createSOQLQuery(tabName,searchKey,limitSize,offset, metadataRecords,sortBy,sortDirection);
                String soqlStr = string.valueOf(response.soqlQuery);
                System.debug('soqlStr:'+soqlStr);
                sObjectList = Database.query(soqlStr);
            }
            
            Integer totalCount = EnhanceSecurityHelper.getTotalRecordCountQuery(tabName, searchKey, metadataRecords);
            
            return new DTO.EnhanceSecurityControllerResponse(sObjectList,totalCount);
            
        } catch (Exception ex) {
            //throw new AuraHandledException('An error occurred while fetching cases: ' + ex.getMessage());
            return new DTO.EnhanceSecurityControllerResponse(false, 'An error occurred while fetching cases: ' + ex.getMessage());
        }
    }

	@AuraEnabled(cacheable=true)
    public static Map<Id, DTO.EnhanceSecurityControllerResponse> ValidateRecordAccess(Id recordId) {
    	SObject record = recordId.getSObjectType().newSObject(recordId);
        Map<Id, DTO.EnhanceSecurityControllerResponse> res = EnhanceSecurityHelper.ValidateRecordsAccess(new List<SObject>{ record }, recordId.getSObjectType());
        return res;
    }
}