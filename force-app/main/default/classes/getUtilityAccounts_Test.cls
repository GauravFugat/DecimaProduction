@isTest
public class getUtilityAccounts_Test {
 @isTest
    public static void tesMEthod(){
   	     Pricing_Request__c pr = new Pricing_Request__c();
         insert pr;
        getUtilityAccounts.rowWrapperClass gr = new getUtilityAccounts.rowWrapperClass();
        gr.accountcount = 1;
        gr.accountname = 'Test';
       // getUtilityAccounts.wrapperClass gw = new getUtilityAccounts.wrapperClass();
        //gw.returnWrap =
        Test.startTest();
        getUtilityAccounts.GetUtilityAccountRecords(pr.Id);
        Test.stopTest();
    }
}