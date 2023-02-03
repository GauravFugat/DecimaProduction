@IsTest
public class product_TriggerHandler_Test {
    
    @IsTest
    public static void method1(){
        Product2 prod = new Product2(Name = 'Fully Fixed', default__c=true,IsActive = true,
                                     Family = 'Fixed',State__c = 'NY');
        insert prod;
        update prod;
    }

}