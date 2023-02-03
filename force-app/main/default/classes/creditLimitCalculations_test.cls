@isTest
public class creditLimitCalculations_test {
    @isTest
    public static void setupMethod(){
        Marketer__c getMarketer = new Marketer__c(name = 'xyz', MarketerDunsNumber__c = 'ten');
        Insert getMarketer;
        HU_Api_Call__c huObj = new HU_Api_Call__c();
        huObj.Call_AWS__c = false;
        huObj.Call_Azure__c = false;
        insert huObj;
        Account acc1= new Account();
        acc1.Name = 'Test Acc';
        insert acc1;
        
        Id recordTypeCus = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Customer').getRecordTypeId();
        Account CusAcc= new Account();
        CusAcc.Name = 'Test Acc1';
        CusAcc.RecordTypeId =recordTypeCus;
        insert CusAcc;
        
        
        Id id1 = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Utility').getRecordTypeId();
        Account acc2= new Account();
        acc2.Name = 'Test Acc1';
        acc2.RecordTypeId =id1;
        acc2.Utility_Average_Rate__c=0.05000;
        //acc2.Utility_Account_Number_Prefix__c  = 'TST';
        insert acc2;
        
        Utility_Account__c ua1 = new Utility_Account__c();
        ua1.Name = '1234567890';
        ua1.Account__c = acc1.Id;
        ua1.Utility__c = acc2.Id;
        //ua1.Credit_Limit__c=7500;
        ua1.Annual_Usage_kWh__c=600000;
        insert ua1;
        
        Contact con = new Contact();
        con.FirstName = 'Con First';
        con.Email = 'ttest@test.com';
        con.LastName = 'Test Last';
        con.AccountId = acc2.Id;
        insert con;
        
        acc2.Primary_Contact__c = con.Id;
        update acc2;
        
        Contract objCon = new Contract();
        objCon.ContractTerm = 4;
        objCon.StartDate = system.today().addMonths(-1);
        objCon.AccountId = acc1.Id;
        //objCon.Status = 'Draft';
        insert objCon;
        
        Opportunity opp = new Opportunity();
        opp.Name='Test Opp';
        opp.AccountId = CusAcc.id;
        opp.ContractId = objCon.Id;
        opp.CloseDate = system.today().addMonths(1);
        opp.StageName ='New';
        opp.Broker__c = acc2.id;
        opp.ContactId = con.Id;
        opp.Price_Request_Count__c = 2;
        opp.Pricing_Request_Complete__c=true;
        insert opp;
        Product2 prodObj = new Product2(Name='Fully Fixed',ProductCode = '0',Product_Id__c = '0');
        insert prodObj;
        List<Pricing_Request__c> prqList = new List<Pricing_Request__c>();
        
        Pricing_Request__c pr = new Pricing_Request__c();
        pr.Opportunity__c = opp.Id;
        pr.Notes__c = 'Hello';
        pr.Status__c = 'Complete';
        pr.Bill_Type__c = 'UCB with Credit';
        // pr.RecordTypeId = rt.Id;
        pr.Product_Lookup__c = prodObj.Id;
        pr.Customer__c = CusAcc.id;
        pr.Voluntary_RECs__c = 'Any';
        pr.Voluntary_RECs_percent__c = 100;
        pr.Mark_to_Market__c = 100;
        pr.Pricing_Request_Credit_Limit__c=7500;
        pr.Pricing_Request_Credit_Annual_Volume__c=600000;
        pr.Record_Created__c = true;
        prqList.add(pr);
        
        insert prqList;
        
        Utility_Account_Pricing__c uapr = new Utility_Account_Pricing__c();
        uapr.Pricing_Request__c = pr.Id;
        uapr.Start_Date__c =system.today();
        uapr.Utility_Account__c = ua1.Id;
        uapr.Status__c ='Priced';
        insert uapr;
        
        Credit_Check__c creditCheckRecord = new Credit_Check__c(Customer__c = CusAcc.Id,Pricing_REquest__c = pr.Id, Opportunity__c = opp.Id, Status__c = 'Active', Credit_Check_Outcome__C = 'Passed', FSR_Score__c = 19, IP_Score__c = 9);
        Insert creditCheckRecord;
        
        test.startTest();
        creditLimitCalculations.calculatePRCreditLimits(new List<Id>{pr.Id});
        creditLimitCalculationsAccount.checkCreditType(CusAcc.Id);
        test.stopTest();
    }
}