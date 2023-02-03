global class BrokerExceptionData implements Database.Batchable<sObject>{
    public static Decimal sum =0;
    public static Decimal sumClosedWon =0;
    public static Decimal sumClosedLost =0;
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'Select Id,Name, RecordType.Name From Account WHERE RecordType.Name =\'Broker\'';
        
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC,List<Account> acc) {
        try{
            system.debug('acc--'+acc);
            //Account brokerAccount = [select Id from Account where Id=: opp[0].Broker__c];
            //system.debug('brokerAccount--'+brokerAccount);
            List<Opportunity> AllOpportunitiesOnAccount = [SELECT Id,Annual_Volume_kWh__c,CloseDate,CreatedDate,Broker__r.name , Broker__r.Total_Opportunity_Count_Broker__c, Broker__r.Last_Opportunity_Created_Date__c, Broker__r.Last_Opportunity_Won_Date__c, Broker__r.Not_Won_Opportunity_Count_Broker__c, Broker__r.Not_Won_Opportunity_Volume_MWh_Broker__c, Broker__r.Total_Opportunity_Volume_MWh_Broker__c, Broker__r.Won_Opportunity_Count_Broker__c, Broker__r.Won_Opportunity_Volume_MWh_Broker__c, StageName FROM Opportunity WHERE Broker__c =: acc[0].id ORDER BY CreatedDate DESC ];
            system.debug('AllOpportunitiesOnAccount--'+AllOpportunitiesOnAccount + 'Size--'+AllOpportunitiesOnAccount.size());
            for(Opportunity lstopp : AllOpportunitiesOnAccount) {
                sum += lstopp.Annual_Volume_kWh__c;
                if(lstopp.StageName == 'Closed Won'){
                    sumClosedWon += lstopp.Annual_Volume_kWh__c;
                }
                if(lstopp.StageName == 'Closed Lost'){
                    sumClosedLost += lstopp.Annual_Volume_kWh__c;
                }
            }
            system.debug('sum--'+sum);
            system.debug('sumClosedWon--'+sumClosedWon);
            system.debug('sumClosedLost--'+sumClosedLost);
            List<Opportunity> lstClosedWonOpp =[select Id,StageName,CloseDate from Opportunity Where StageName ='Closed Won' AND Id IN: AllOpportunitiesOnAccount ORDER BY CloseDate DESC ];
            system.debug('lstClosedWonOpp--'+lstClosedWonOpp + 'Size--'+lstClosedWonOpp.size());
            List<Opportunity> lstClosedLostOpp =[select Id,StageName from Opportunity Where StageName ='Closed Lost' AND Id IN: AllOpportunitiesOnAccount ];
            system.debug('lstClosedLostOpp--'+lstClosedLostOpp+ 'Size--'+lstClosedLostOpp.size());
            //date.newinstance(AllOpportunitiesOnAccount[0].CreatedDate.year(), AllOpportunitiesOnAccount[0].CreatedDate.month(), AllOpportunitiesOnAccount[0].CreatedDate.day());
            if(AllOpportunitiesOnAccount.size() >0){
                acc[0].Last_Opportunity_Created_Date__c = date.newinstance(AllOpportunitiesOnAccount[0].CreatedDate.year(), AllOpportunitiesOnAccount[0].CreatedDate.month(), AllOpportunitiesOnAccount[0].CreatedDate.day());
            }
            else{ acc[0].Last_Opportunity_Created_Date__c = null;}
            acc[0].Last_Opportunity_Won_Date__c = lstClosedWonOpp.size()!=0 ? lstClosedWonOpp[0].CloseDate : null ;
            acc[0].Not_Won_Opportunity_Count_Broker__c = lstClosedLostOpp.size() >0 ? lstClosedLostOpp.size() : 0;
            acc[0].Not_Won_Opportunity_Volume_MWh_Broker__c = sumClosedLost/1000;
            acc[0].Total_Opportunity_Count_Broker__c = AllOpportunitiesOnAccount.size();
            acc[0].Total_Opportunity_Volume_MWh_Broker__c = sum/1000;
            acc[0].Won_Opportunity_Count_Broker__c = lstClosedWonOpp.size()!=0 ? lstClosedWonOpp.size() : 0 ;
            acc[0].Won_Opportunity_Volume_MWh_Broker__c = sumClosedWon/1000;
            
            
            update acc;
            
        }catch(Exception e){
            system.debug('Error Message --'+e.getMessage() +''+e.getLineNumber());
        }
        
    }
    global void finish(Database.BatchableContext BC) {}
    
}