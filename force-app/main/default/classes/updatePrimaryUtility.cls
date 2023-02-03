/*
* @Purpose: Invocable Class for UtiltyUpdate, To Update Utility_Category__c, To Update Start_Date_Category__c (SU-712, SU-798).
* @Author:  Tushar Shinde
* @CreatedDate: 29/06/2021
* @Test Class: updatePrimaryUtility_Test
*/
public class updatePrimaryUtility {
    @invocableMethod
    public static void upUtilCategory(List<Id> utilId){
        List<Enrollment__c> updateUAE = new List<Enrollment__c>();
        List<Enrollment__c> updateUAE1 = new List<Enrollment__c>();
        List<Enrollment__c> updateUAE2 = new List<Enrollment__c>();
        List<Utility_Account_Enrollment__c> uaeList = [SELECT Id, Utility_Account__c,Utility_Account__r.Utility__r.Name,Start_Date__c,Enrollment__c,Enrollment__r.Utility_Category__c,
                                                       Name FROM Utility_Account_Enrollment__c WHERE Enrollment__c In : utilId]; 
        Map<String,Integer> elCount = new Map<String,Integer>();
        // The Utility wihich appears maximum times is set as Primary Utility
        for(Utility_Account_Enrollment__c key : uaeList){
            if(!elCount.containsKey(key.Utility_Account__r.Utility__c)){
                elCount.put(key.Utility_Account__r.Utility__c,0);
            }
            Integer currentInt=elCount.get(key.Utility_Account__r.Utility__c)+1;
            elCount.put(key.Utility_Account__r.Utility__c,currentInt);
        }
        Map<Integer,String> ecount = new Map<Integer,String>();
        for(String s: elCount.keyset()){
            ecount.put(elCount.get(s), s);
        }
        Integer max =0;
        for(Integer i : ecount.keyset()){
            if(max<i){
                max = i; 
            }else{
                break;
            }
        }
        for(Enrollment__c e : [Select Id,name,Primary_Utility__c from Enrollment__c Where Id In:utilId]){
            e.Primary_Utility__c = ecount.get(max);
            updateUAE.add(e);
        }
        update updateUAE;
        
        // To Update Utility_Category__c 
        String tempUtilCategory = uaeList[0].Utility_Account__r.Utility__r.Name;
        Date tempDt = uaeList[0].Start_Date__c;
        System.debug('tempDt==>> '+tempDt);
        for(Utility_Account_Enrollment__c uae : uaeList){
            if(uae.Utility_Account__r.Utility__r.Name == tempUtilCategory){               
                uae.Enrollment__r.Utility_Category__c = 'Single Utility';
            }else{ 
                uae.Enrollment__r.Utility_Category__c = 'Multiple Utility';
                break;
            }
            if(!updateUAE1.contains(uae.Enrollment__r)){
                updateUAE1.add(uae.Enrollment__r);
            }
        }
        update updateUAE1;
        
        // To Update Start_Date_Category__c
        for(Utility_Account_Enrollment__c uae1 : uaeList){
            System.debug('uae1.Start_Date__c==>> '+uae1.Start_Date__c);
            if(uae1.Start_Date__c == tempDt){
                uae1.Enrollment__r.Start_Date_Category__c = 'Single Start Date';
            }else{ 
                uae1.Enrollment__r.Start_Date_Category__c = 'Multiple Start Date';
                break;
            }
            if(!updateUAE2.contains(uae1.Enrollment__r)){
                updateUAE2.add(uae1.Enrollment__r);
            }
        }
        update updateUAE2;
    }
}