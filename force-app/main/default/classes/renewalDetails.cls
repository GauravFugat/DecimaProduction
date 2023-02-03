public class renewalDetails {
    
    
    public class existingDetailsWrapper{
        @AuraEnabled
        public String utilities;
        @AuraEnabled
        public contract contr;
        @AuraEnabled
        public Boolean isLoadFollowing;
        @AuraEnabled
        public Boolean isFinalMargin;
        
    }
    
    
    @AuraEnabled
    public static existingDetailsWrapper getDetails(Id oppId){
        System.debug('oppId-->> '+oppId);
        existingDetailsWrapper wrappToReturn = new existingDetailsWrapper();
        
        Opportunity opp = [SELECT Id,
                           Type,
                           Existing_Contract__c,
                           Index_Contract__c
                           FROM Opportunity
                           WHERE Id =: oppId];
        System.debug('opp-->> '+opp);
        String recId;
        if(opp.Type == 'Load Following'){
            recId = opp.Index_Contract__c; 
            wrappToReturn.isLoadFollowing = true;
        }else{
            recId = opp.Existing_Contract__c;
            wrappToReturn.isLoadFollowing = false;
        }        
        Contract contractToReturn = [SELECT Id,
                                     Name,
                                     StartDate,
                                     ContractTerm,
                                     Output_Total_Unit_Price__c,
                                     Opportunity__r.Final_SEUS_Margin__c ,
                                     Opportunity__r.Point_of_Sale_SEUS_Margin__c,
                                     Opportunity__r.Broker_Margin_per_unit__c,
                                     Opportunity__r.Commission_Type__c,
                                     Opportunity__r.SyncedQuote.Contract_Volume_kWh__c,
                                     Account.Name,
                                     Account.Customer_ID__c ,
                                     Product__r.Name
                                     FROM Contract
                                     WHERE Id =: recId];        //Id =: opp.Existing_Contract__c];
        
        wrappToReturn.contr = contractToReturn;
        Set<String> utilities = new Set<String>();
        List<Utility_Account_Contract__c> uacLst = [SELECT Id, Utility_Account__r.Utility__r.Name FROM Utility_Account_Contract__c WHERE Contract__c =: recId]; // Contract__c =: opp.Existing_Contract__c];
        
        for(Utility_Account_Contract__c uac : uacLst){
            utilities.add(uac.Utility_Account__r.Utility__r.Name);
        }
        if (contractToReturn.Opportunity__r.Final_SEUS_Margin__c != null)
            wrappToReturn.isFinalMargin = true;
            
        wrappToReturn.utilities = String.join(new List<String>(utilities), ',');
        System.debug('wrappToReturn-->> '+wrappToReturn);
        return wrappToReturn;
        
    }

}