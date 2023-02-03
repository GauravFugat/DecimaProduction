/* 
* @Purpose: Trigger on QuoteLineItem for updating sales price(UnitPrice) of the minimum term if term 12 is not present.
* @Author: Saurabh Chauhan
* @CreatedDate: 09/08/2020
* @Related Code: QuoteLineItem_Trigger_Handler,RecursiveTriggerHandler
* @Test Class: QuoteLineItem_Trigger_Handler_Test
* @LastModifiedDate: 12/08/2020
* @LastModifiedBy: Saurabh Chauhan
*/


trigger QuoteLineItem_Trigger on QuoteLineItem (after insert,after update) {
    
    Trigger_Settings__c settings = Trigger_Settings__c.getInstance('QuoteLineItem_Trigger');
    Boolean triggerOn = settings.TriggerOn__c;
    
    if(RecursiveTriggerHandler.isFirstTime && triggerOn){
        RecursiveTriggerHandler.isFirstTime = false;
        Set<Id> QuoteIds = new Set<Id>(); 
        for(QuoteLineItem qli: Trigger.New){
            QuoteIds.add(qli.QuoteId);
        }
        if(trigger.isAfter && trigger.isUpdate || trigger.isAfter && trigger.isInsert ){
            QuoteLineItem_Trigger_Handler.QLIupdate(QuoteIds);
        }
    }
}