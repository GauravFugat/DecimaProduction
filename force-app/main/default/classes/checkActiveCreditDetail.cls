public class checkActiveCreditDetail {
    
    public static Credit_Check__c checkforCustomer(Id customerId){
        
        List<Credit_Check__c> creditDetailToCheck = [SELECT Id,Status__c
                                                     FROM Credit_Check__c
                                                     WHERE Customer__c =: customerId
                                                     AND Status__c = 'Active' order by CreatedDate DESC Limit 1 ];
        return creditDetailToCheck[0];
    }
    
}