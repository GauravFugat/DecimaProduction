//Test class : salesRenewal_Test

global with sharing class GetTerminatedUACs {
    
    // Declaring variables to use further in the class
    global string prIdValue {get; set;}
    global string BillType {get; set;}
    global string requestType {get; set;}
    global string product {get; set;}
    global String prId;
    global Date DueDate{get;set;}
    global Id prOppId{get; set;}
    global List<Utility_Account_Contract__c> lstUAO {get; set;}
    global string StartDates {get; set;}
    global Contract prReq{get; set;}
    // Get set PrId from vf component
    global void setprId(String prIdValue){
        SYstem.debug('=== '+prIdValue);
        prId = prIdValue; 
        lstUAO = getlstUAOs();
        StartDates = getStartDates();
    } 
    
    global String getprId(){
        return prId; 
    }
    
    // Blank constructor 
   global GetTerminatedUACs (){
     
    }
    global String getStartDates(){
        prReq = [Select Name FROM COntract where ID =: prId];
       StartDates = prReq.Name;
        return StartDates;
    }
    global List<Utility_Account_Contract__c> getlstUAOs(){
        
        
        lstUAO = [SELECT Id, Utility_Account__r.Name,Utility_Account__r.Utility__r.Name FROM Utility_Account_Contract__c where Contract__c=: prId];

        return lstUAO;
        
    }
}