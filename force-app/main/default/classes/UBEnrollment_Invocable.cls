public class UBEnrollment_Invocable {
    /*  public static void myFuture(List<Id> Ids){
UBEnrollment_Invocable.submitUbEnrollment(Ids);
}
@Future(callout=true) */
    
    @InvocableMethod(label = 'submitUbEnrollment')
    public static void submitUbEnrollment(List<Id> recordId) {
        // Standard Enrollment (Not Active UA)
        List<Utility_Account_Enrollment__c> objUAEs = [SELECT Id FROM Utility_Account_Enrollment__c WHERE Enrollment__c =:recordId AND Utility_Account__r.Status__c != 'Active'];
        List<Id> objUAEId = new List<Id>();
        for(Utility_Account_Enrollment__c uae : objUAEs){
            objUAEId.add(uae.Id);
            //CallUbEnrollmentAPI.callUBAPI(recordId[0],uae.Id);
        }
        CallUbEnrollmentAPI.callUBAPI(recordId[0],objUAEId);
        
        // Renewal - AddRateClassSchedule (Active UA)
        List<Utility_Account_Enrollment__c> objUAEActive = [SELECT Id FROM Utility_Account_Enrollment__c WHERE Enrollment__c =:recordId AND Utility_Account__r.Status__c = 'Active'];
        List<Id> objUAEIdActive = new List<Id>();
        for(Utility_Account_Enrollment__c uae : objUAEActive){
            objUAEIdActive.add(uae.Id);
            
        }
        CallUbRateClassServiceAPI.callUBRenewal(recordId[0],objUAEIdActive);
        
    }
}