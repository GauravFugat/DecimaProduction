/*
* @Purpose: Update Utility Accounts contract End Date.
* @Author: Rahul Ghaytadak
* @CreatedDate: 
* @Related Code: 
* @Test Class: Update_contractEndDate_Test
* @LastModifiedDate:
* @LastModifiedBy: Rahul Ghaytadak
*/
public class UpdateContractEndDate_UA {
    @InvocableMethod(label='Get Utility Account' description='Update Utility Accounts contract End Date' )
    public Static void updateContractEndDate(List<Id> UA_Id){
        try{
            Set<Id> contractList = new Set<Id>();
            List<Utility_Account__c> UAListToUpdate = new List<Utility_Account__c>();
            List<Utility_Account__c> UAListToUpdate1 = new List<Utility_Account__c>();
            Date dt = Date.newInstance(0001, 01, 01);
            //Retrieve Utility Account
            List<Utility_Account__c> UAList = [SELECT Id, Contract_End_Date__c FROM Utility_Account__c Where Id=:UA_Id];
            //Retrieve Utility Account Contract related to Utility Account
            List<Utility_Account_Contract__c> UAC = [SELECT Id, Utility_Account__c, Contract__c,Status__c  FROM Utility_Account_Contract__c 
                                                     Where Utility_Account__c =: UA_Id AND Status__c = 'Contracted'];
            if(UAC.size()>0){
                for(Utility_Account_Contract__c UAC_Instance : UAC){
                    contractList.add(UAC_Instance.Contract__c); 
                }
                //Retrieve Contract related to Utility Account Contract
                List<Contract> contrct = [SELECT Id, StartDate,EndDate, Status, ContractTerm,Latest_Contract__c FROM Contract Where Id=:contractList AND Status ='Live' order by Latest_Contract__c desc];
                List<Contract> contrct1 = [SELECT Id, StartDate,EndDate, Status, ContractTerm,Latest_Contract__c FROM Contract Where Id=:contractList order by Latest_Contract__c desc];
                
                if(contrct1.size()>0){
                    for(Contract c : contrct1){
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
                        UAListToUpdate1.add(Ua);   
                    }
                    if(UAListToUpdate1.size()>0){
                        update UAListToUpdate1;
                    }
                }
                if(contrct.size()>0){
                    for(Contract c : contrct1){
                        if(c.EndDate>dt){
                            dt = c.EndDate;
                        }
                    }
                    for(Utility_Account__c Ua : UAList){
                        if(contrct[0].EndDate!= null){
                            ua.Contract_End_Date__c = contrct[0].EndDate; 
                        }
                        ua.Future_Contract_End_Date__c = dt;
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