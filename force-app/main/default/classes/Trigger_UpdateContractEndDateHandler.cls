/*
* @Purpose: Update Utility Accounts End Date when Contract is Created/updated.
* @Author: Rahul Ghaytadak
* @CreatedDate: 
* @Related Code: Trigger_UpdateContractEndDate
* @Test Class: Update_contractEndDate_Test
* @LastModifiedDate:
* @LastModifiedBy: Rahul Ghaytadak
*/
public class Trigger_UpdateContractEndDateHandler {
    @InvocableMethod(label='Get Contracts' description='Update Utility Accounts contract End Date' )
    public Static void updateContractEndDate(List<Contract> Contract_Id){
        try{
            Date dt = Date.newInstance(1901, 01, 01);
            system.debug('Contract_Id>>'+Contract_Id);
            Set<Id> contractList = new Set<Id>();
            Set<Id> UAIds = new Set<Id>();
            Set<Id> ContractIds = new Set<Id>();
            Set<Id> Cont_Ids = new Set<Id>();
            for(Contract cont : Contract_Id){
                Cont_Ids.add(cont.Id);
            }
            List<Utility_Account__c> UAListToUpdate = new List<Utility_Account__c>();
            List<Utility_Account__c> UAListToUpdate1 = new List<Utility_Account__c>();
            //Retrieve Utility Account Contracts related to Contracts
            List<Utility_Account_Contract__c> UAC = [SELECT Id, Utility_Account__c, Contract__c,Status__c  FROM Utility_Account_Contract__c 
                                                     Where Contract__c =: Cont_Ids AND Status__c = 'Contracted'];
            if(UAC.size()>0){
                for(Utility_Account_Contract__c Ua_cont : UAC){
                    UAIds.add(Ua_cont.Utility_Account__c);
                }
                //Retrieve Utility Account related to Contracts
                List<Utility_Account__c> UAList = [SELECT Id, Contract_End_Date__c FROM Utility_Account__c Where Id=:UAIds];
                //Retrieve Contracts
                List<Contract> contrct = [SELECT Id, StartDate,EndDate, Status, ContractTerm,Latest_Contract__c FROM Contract Where Id=:Cont_Ids AND Status ='Live' order by Latest_Contract__c desc];
                List<Contract> contrct1 = [SELECT Id, StartDate,EndDate, Status, ContractTerm,Latest_Contract__c FROM Contract Where Id=:Cont_Ids AND Status ='Pending Live' order by Latest_Contract__c desc];
                List<Utility_Account_Contract__c> UAC1 = [SELECT Id, Utility_Account__c, Contract__c,Status__c  FROM Utility_Account_Contract__c 
                                                          Where Utility_Account__c =: UAIds AND Status__c = 'Contracted'];
                for(Utility_Account_Contract__c uacc : UAC1){
                    ContractIds.add(uacc.Contract__c);
                }
                List<Contract> contrct2 = [SELECT Id, StartDate,EndDate, Status, ContractTerm,Latest_Contract__c FROM Contract Where Id IN : ContractIds AND Status ='Pending_Live' order by Latest_Contract__c desc];
                if(contrct2.size()>0){
                    for(Contract c : contrct2){
                        if(c.EndDate>dt){
                            dt = c.EndDate;
                        }
                    }
                    for(Utility_Account__c Ua : UAList){
                        if(dt==Date.valueOf('1901-01-01')){
                            ua.Future_Contract_End_Date__c = null;
                        }else{
                            ua.Future_Contract_End_Date__c = dt;
                        }
                        if(contrct.size() == 0){
                            Ua.Contract_End_Date__c = null;
                        }
                        UAListToUpdate1.add(Ua);   
                    }
                    if(UAListToUpdate1.size()>0){
                        update UAListToUpdate1;
                    }
                }
                if(contrct.size()>0){
                    for(Utility_Account__c Ua : UAList){
                        if(contrct[0].EndDate== null){
                            ua.Contract_End_Date__c = null;
                        }else{
                            ua.Contract_End_Date__c = contrct[0].EndDate;
                        }
                        UAListToUpdate.add(Ua);   
                    }
                    if(UAListToUpdate.size()>0){
                        update UAListToUpdate;
                    }
                }
            }            
        }Catch(Exception e){
            System.debug('->'+e.getCause()+'-'+e.getMessage()+'-'+e.getLineNumber());
        }    
    }
}