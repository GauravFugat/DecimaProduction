/*
* @Purpose: Invocable Class for Update Utiltycategory and StartDatecategory(SU-712)
* @Author:  Tushar Shinde
* @CreatedDate: 29/06/2021
* @Test Class: UpdateUtilityCategory_Test
*/
global class UpdateUtilityCategory {  
    @invocableMethod
    public static void upUtilCategory(List<Id> utilId){        
        List<Enrollment__c> updateUAE = new List<Enrollment__c>();
        List<Utility_Account_Enrollment__c> uaeList = [SELECT Id, Utility_Account__c,Utility_Account__r.Utility__r.Name,Enrollment__c,Enrollment__r.Utility_Category__c,Name, Start_Date__c FROM Utility_Account_Enrollment__c WHERE Enrollment__c In : utilId];   
        String tempUtilCategory = uaeList[0].Utility_Account__r.Utility__r.Name;
        Date tempDt = uaeList[0].Start_Date__c;
        for(Utility_Account_Enrollment__c uae : uaeList){
             if(uae.Start_Date__c == tempDt){
                uae.Enrollment__r.Start_Date_Category__c = 'Single Start Date';
            }else{ 
                uae.Enrollment__r.Start_Date_Category__c = 'Multiple Start Date';
              //  break;
            }  
            if(uae.Utility_Account__r.Utility__r.Name == tempUtilCategory){               
                uae.Enrollment__r.Utility_Category__c = 'Single Utility';
            }else{ 
                uae.Enrollment__r.Utility_Category__c = 'Multiple Utility';
                break;
            }
                     
            if(!updateUAE.contains(uae.Enrollment__r)){
                updateUAE.add(uae.Enrollment__r);
            }
        }
        update updateUAE;
    }
}