public class createCreditLogs {

    public static void createCreditProcessLog(Id accountId, String name, String processType, String description,String RecordName,String RecordId,String outcome){
        
        Process_Event__c pe = new Process_Event__c();
        pe.Account__c = accountId;
        pe.Name__c = name;
        pe.Type__c = processType;
        pe.Description__c = description;
        pe.Related_Record_Name__c = RecordName;
        pe.Related_Record_Id__c = RecordId;
        pe.Outcome__c = outcome;
		insert pe;        
    }
    public static Process_Event__c createCreditProcessLogs(Id accountId, String name, String processType, String description,String RecordName,String RecordId,String outcome){
        
        Process_Event__c pe = new Process_Event__c();
        pe.Account__c = accountId;
        pe.Name__c = name;
        pe.Type__c = processType;
        pe.Description__c = description;
        pe.Related_Record_Name__c = RecordName;
        pe.Related_Record_Id__c = RecordId;
        pe.Outcome__c = outcome;
		return pe;        
    }
}