trigger AccountAccessTrigger on Account (before update,before delete) {

    if(Trigger.isUpdate && Trigger.isBefore){
        /*Map<Id, DTO.EnhanceSecurityControllerResponse> accResult = EnhanceSecurityHelper.ValidateRecordsAccess(Trigger.new, Account.SObjectType);
        Map<Id,Account> accMap = Trigger.newMap;
        
        for(Id accId : accResult.keySet()){            
            if (!accResult.get(accId).IsValid) {
                accMap.get(accId).addError('You do not have access to update or delete this account.');
            }   
        }*/
    }

    if(Trigger.isDelete && Trigger.isBefore){
        /*Map<Id, DTO.EnhanceSecurityControllerResponse> accResult = EnhanceSecurityHelper.ValidateRecordsAccess(Trigger.old, Account.SObjectType);
        Map<Id,Account> accMap = Trigger.newMap;

        for(Id accId : accResult.keySet()){            
            if (!accResult.get(accId).IsValid) {
                accMap.get(accId).addError('You do not have access to update or delete this account.');
            }   
        }*/
    }
}