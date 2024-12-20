/**
 * @Description: Trigger on Case
 * @Date: 2024-04-04 (YYYY-MM-DD)
 * @Author: akash (akash@dreamwares.com) 
 * @TestClass: CaseTriggerHandlerTest
 * 
 * ModifiedBy     ModifiedDate      Description
 * Akash           2024-04-04        Initial development
 * Sayali 		   2024-09-09        BeforeUpdate & Delete
*/
trigger CaseTrigger on Case (after insert, after update, before Update,before Delete)  
{   
    if (Trigger.isBefore) {
        if(Trigger.isUpdate){
            caseTriggerHandler.beforeUpdate(trigger.oldMap,trigger.newMap);
        }
        if(Trigger.isDelete){
            caseTriggerHandler.beforeDelete(trigger.oldMap);
        }
    }
    if (Trigger.isAfter) {
        if(Trigger.isInsert){
            caseTriggerHandler.afterInsert(trigger.new);
        }    
        if(Trigger.isUpdate){
            caseTriggerHandler.afterUpdate(trigger.newMap, trigger.oldMap);
        }
    }
}