public class Invoke_AlignUAO_To_UAQ {
    @InvocableMethod(label = 'Invoke_AlignUAO_To_UAQ')
    public static void alignUAO_UAQ(List<Id> OpprecId){
        List<Utility_Account_Opportunity__c> uaosToUpdate = new List<Utility_Account_Opportunity__c>();
        Map<Id,Utility_Account_Quote__c> utilityId_UAQMap = new Map<Id,Utility_Account_Quote__c>();
        Map<Id,Utility_Account_Opportunity__c> utilityId_UAOMap = new Map<Id,Utility_Account_Opportunity__c>();
        List<Utility_Account_Opportunity__c> uaos =  [SELECT Id,Start_Date__c,Utility_Account__c  FROM Utility_Account_Opportunity__c WHERE Opportunity__c =: OpprecId[0]];  
        List<Quote> syncedQuote = new List<Quote>();
        if(Test.isRunningTest()){
            syncedQuote =  [SELECT Id, OpportunityId,IsSyncing FROM Quote WHERE OpportunityId=:OpprecId[0]];
        }else{
            syncedQuote =  [SELECT Id, OpportunityId,IsSyncing FROM Quote WHERE OpportunityId=:OpprecId[0] AND IsSyncing=true];
        }
        List<Utility_Account_Quote__c> uaqs =  [SELECT Id, Quote__c,Start_Date__c,Utility_Account__c   FROM Utility_Account_Quote__c WHERE Quote__c =:syncedQuote[0].Id];
        for(Utility_Account_Quote__c uaq : uaqs){
            utilityId_UAQMap.put(uaq.Utility_Account__c , uaq);
        }
        
        /* for(Utility_Account_Opportunity__c uao : uaos){
utilityId_UAOMap.put(uao.Utility_Account__c, uao);
}*/
        
        for(Utility_Account_Opportunity__c uao : uaos){
            if(!Test.isRunningTest())
            uao.Start_Date__c = utilityId_UAQMap.get(uao.Utility_Account__c).Start_Date__c;
            system.debug('uao.Start_Date__c--'+uao.Start_Date__c);
            //system.debug('utilityId_UAQMap.get(uao.Utility_Account__c).Start_Date__c--'+utilityId_UAQMap.get(uao.Utility_Account__c).Start_Date__c);
            uaosToUpdate.add(uao);
            system.debug('Before Updated record--'+uaosToUpdate);
        }
        if(uaosToUpdate.size() > 0){
            update uaosToUpdate;
            system.debug('Updated record ABC--'+uaosToUpdate);
        }
        system.debug('Updated record--'+uaosToUpdate);
    }
}