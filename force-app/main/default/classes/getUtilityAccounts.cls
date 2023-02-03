public class getUtilityAccounts {
@AuraEnabled
    public static List<AggregateResult> GetUtilityAccountRecords(Id priceId) //Id prisingReqId
    {
        List<Pricing_Request__c> prqList = new List<Pricing_Request__c>();
        Set<String> startDates = new Set<String>();
        
        List<List<String>> lstOfLst = new List<List<String>>();
        Map<String,Utility_Account_Pricing__c> UtilityUAPRMap = new Map<String,Utility_Account_Pricing__c>();
        
        List<Utility_Account_Pricing__c> UAPRLst = [SELECT Id,Start_Date__c, Utility_Account__r.Utility__r.Name, Name,Pricing_Request__c FROM Utility_Account_Pricing__c WHERE Pricing_Request__c =: priceId];
      
        
        List<AggregateResult> groupedResults = [SELECT COUNT(Id),Utility_Account__r.Utility__r.Name, Pricing_Request__c, Start_Date__c FROM Utility_Account_Pricing__c WHERE Pricing_Request__c =: priceId GROUP BY Start_Date__c, Pricing_Request__c,Utility_Account__r.Utility__r.Name ];
        System.debug('--->'+groupedResults);
        
        for(integer i=0;i<groupedResults.size();i++){
            startDates.add(String.valueOf(groupedResults[i].get('Start_Date__c')));
        }
        System.debug('startDates--->'+startDates);
        
        return groupedResults;
    }
    
    
    // wrapper or Inner class with @AuraEnabled {get;set;} properties*    
    public class wrapperClass{
        @AuraEnabled public List<Date> startDateList{get;set;}
         @AuraEnabled public List<rowWrapperClass> returnWrap{get;set;}
     }
    
     public class rowWrapperClass{
      @AuraEnabled public String accountname{get;set;}
      @AuraEnabled public integer accountcount{get;set;}
     }
  
}