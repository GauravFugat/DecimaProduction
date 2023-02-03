@isTest
public class Credit_Test {
    
    // @isTest
    // public static void CallCreditTestMeth(){
    public static testMethod void setupMethod5(){
        Account acc1= new Account();
        acc1.Name = 'Test Acc';
        //acc1.Utility_Account_Number_Prefix__c  = 'TST';
        insert acc1;
        
        Marketer__c getMarketer = new Marketer__c(name = 'xyz', MarketerDunsNumber__c = 'ten');
        Insert getMarketer;
        
        
        HU_Api_Call__c huObj = new HU_Api_Call__c();
        huObj.Call_AWS__c = false;
        huObj.Call_Azure__c = false;
        insert huObj;
        
        Id recordTypeCus = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Customer').getRecordTypeId();
        Account CusAcc= new Account();
        CusAcc.Name = 'Test Acc1';
        CusAcc.RecordTypeId =recordTypeCus;
        insert CusAcc;
        
        Id id1 = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Utility').getRecordTypeId();
        Account acc2= new Account();
        acc2.Name = 'Test Acc1';
        acc2.RecordTypeId =id1;
        //acc2.Utility_Account_Number_Prefix__c  = 'TST';
        insert acc2;
        
        
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
        system.debug('opp======='+opp);
        
        Product2 prodObj = new Product2(Name='Fully Fixed',ProductCode = '0',Product_Id__c = '0');
        insert prodObj;
        
        List<Pricing_Request__c> prList = new List<Pricing_Request__c>();
        
        List<Id> prLst = new List<Id>();
        RecordType rt = [SELECT Id, Name, DeveloperName, SobjectType FROM RecordType where SobjectType = 'Pricing_Request__c' AND DeveloperName = 'Default_Pricing_Request' limit 1];
        
        Pricing_Request__c pr = new Pricing_Request__c();
        pr.Opportunity__c = opp.Id;
        pr.Notes__c = 'Hello';
        pr.Status__c = 'Complete';
        pr.Bill_Type__c = 'Dual';
        pr.RecordTypeId = rt.Id;
        pr.Product_Lookup__c = prodObj.Id;
        pr.Customer__c = CusAcc.id;
        pr.Voluntary_RECs__c = 'Any';
        pr.Voluntary_RECs_percent__c = 100;
        pr.Mark_to_Market__c = 100;
        pr.Due_Date__c = system.today().addMonths(1);
        pr.Urgent_Request__c = true;
        pr.Pricing_Quote_Comments__c ='test';
        pr.Treatment__c='Fixed';
        pr.Start_Dates__c='Same';
        pr.Record_Created__c = true;
        //prList.add(pr);
        insert pr; 
        
        
        Credit_Check__c creditCheckRecord = new Credit_Check__c(Customer__c = acc1.Id,Pricing_Request__c = pr.Id, Opportunity__c = opp.Id, Status__c = 'Active', Credit_Check_Outcome__C = 'Passed', FSR_Score__c = 20, IP_Score__c = 20);
        List<Credit_Check__c> creditDetailList = new List<Credit_Check__c>();
        creditDetailList.add(creditCheckRecord);
       // Insert creditCheckRecord;
        
        Process_Event__c proEv = new Process_Event__c();
        proEv.Name__c = 'Process Credit from HU Data';
        proEv.Related_Record_Name__c = Null;
        proEv.Account__c = CusAcc.Id;
        proEv.Related_Record_Id__c = null; 
        insert proEv;
        
        // createCreditDetail(String Opp, Boolean creditRequired, List<Pricing_Request__c> PricingRequest, String optionSelected, Credit_Check__c newCCRecord, Boolean callFromLoop){
		Opportunity getAccId = [Select Id,Type,Name,OwnerId,AccountId,Existing_Contract__c from Opportunity where Id=:opp.Id];	
        
        Test.startTest();
        //Credit.createCreditDetail(opp.Id, true, new List<Pricing_Request__c>{pr}, 'Refresh with Changes',creditCheckRecord,false);
        Credit.createCreditDetail(creditDetailList,getAccId,true, new List<Pricing_Request__c>{pr}, 'Refresh with Changes',creditCheckRecord,false);				
        Credit.createCreditDetail(creditDetailList,getAccId,true, new List<Pricing_Request__c>{pr}, 'Refresh with Changes',creditCheckRecord,true);				
        //Credit.createCreditDetail(opp.Id, true, new List<Pricing_Request__c>{pr}, 'Refresh',creditCheckRecord,true);
        Credit.createCreditDetail(creditDetailList,getAccId,true, new List<Pricing_Request__c>{pr}, 'Refresh',creditCheckRecord,false);
        Credit.createCreditDetail(creditDetailList,getAccId,true, new List<Pricing_Request__c>{pr}, 'Refresh',creditCheckRecord,true);
        Credit.createCreditDetail(new List<Credit_Check__c>{},getAccId,true, new List<Pricing_Request__c>{pr}, 'Initial Request',creditCheckRecord,true);
		//Credit.createCreditDetail(new List<Credit_Check__c>{},getAccId,true, new List<Pricing_Request__c>{pr}, 'Initial Request',creditCheckRecord,false);
        //Credit.createCreditDetail(opp.Id, true, new List<Pricing_Request__c>{pr}, 'Refresh with Changes',creditCheckRecord,true);
		Credit.createCreditDetail(creditDetailList,getAccId,true, new List<Pricing_Request__c>{pr}, 'Initial Request',creditCheckRecord,false);
        Credit.createCreditDetail(creditDetailList,getAccId,true, new List<Pricing_Request__c>{pr}, 'Initial Request',creditCheckRecord,true);				
        Test.stopTest();
    }
    
     public static testMethod void setupMethod6(){
        Account acc1= new Account();
        acc1.Name = 'Test Acc';
        //acc1.Utility_Account_Number_Prefix__c  = 'TST';
        insert acc1;
        
        Marketer__c getMarketer = new Marketer__c(name = 'xyz', MarketerDunsNumber__c = 'ten');
        Insert getMarketer;
        
        
        HU_Api_Call__c huObj = new HU_Api_Call__c();
        huObj.Call_AWS__c = false;
        huObj.Call_Azure__c = false;
        insert huObj;
        
        Id recordTypeCus = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Customer').getRecordTypeId();
        Account CusAcc= new Account();
        CusAcc.Name = 'Test Acc1';
        CusAcc.RecordTypeId =recordTypeCus;
        insert CusAcc;
        
        Id id1 = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Utility').getRecordTypeId();
        Account acc2= new Account();
        acc2.Name = 'Test Acc1';
        acc2.RecordTypeId =id1;
        //acc2.Utility_Account_Number_Prefix__c  = 'TST';
        insert acc2;
        
        
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
        system.debug('opp======='+opp);
        
        Product2 prodObj = new Product2(Name='Fully Fixed',ProductCode = '0',Product_Id__c = '0');
        insert prodObj;
        
        List<Pricing_Request__c> prList = new List<Pricing_Request__c>();
        
        List<Id> prLst = new List<Id>();
        RecordType rt = [SELECT Id, Name, DeveloperName, SobjectType FROM RecordType where SobjectType = 'Pricing_Request__c' AND DeveloperName = 'Default_Pricing_Request' limit 1];
        
        Pricing_Request__c pr = new Pricing_Request__c();
        pr.Opportunity__c = opp.Id;
        pr.Notes__c = 'Hello';
        pr.Status__c = 'Complete';
        pr.Bill_Type__c = 'Dual';
        pr.RecordTypeId = rt.Id;
        pr.Product_Lookup__c = prodObj.Id;
        pr.Customer__c = CusAcc.id;
        pr.Voluntary_RECs__c = 'Any';
        pr.Voluntary_RECs_percent__c = 100;
        pr.Mark_to_Market__c = 100;
        pr.Due_Date__c = system.today().addMonths(1);
        pr.Urgent_Request__c = true;
        pr.Pricing_Quote_Comments__c ='test';
        pr.Treatment__c='Fixed';
        pr.Start_Dates__c='Same';
        pr.Record_Created__c = true;
        //prList.add(pr);
        insert pr; 
        
        
        Credit_Check__c creditCheckRecord = new Credit_Check__c(Customer__c = acc1.Id,Pricing_Request__c = pr.Id, Opportunity__c = opp.Id, Status__c = 'Active', Credit_Check_Outcome__C = 'Passed', FSR_Score__c = 20, IP_Score__c = 20);
        List<Credit_Check__c> creditDetailList = new List<Credit_Check__c>();
        creditDetailList.add(creditCheckRecord);
       // Insert creditCheckRecord;
        
        Process_Event__c proEv = new Process_Event__c();
        proEv.Name__c = 'Process Credit from HU Data';
        proEv.Related_Record_Name__c = Null;
        proEv.Account__c = CusAcc.Id;
        proEv.Related_Record_Id__c = null; 
        insert proEv;
        
        // createCreditDetail(String Opp, Boolean creditRequired, List<Pricing_Request__c> PricingRequest, String optionSelected, Credit_Check__c newCCRecord, Boolean callFromLoop){
		Opportunity getAccId = [Select Id,Type,Name,OwnerId,AccountId,Existing_Contract__c from Opportunity where Id=:opp.Id];	
        
        Test.startTest();        
		Credit.createCreditDetail(new List<Credit_Check__c>{},getAccId,true, new List<Pricing_Request__c>{pr}, 'Initial Request',creditCheckRecord,false);
        Test.stopTest();
    }
}