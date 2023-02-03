@IsTest
public class CreatePricingRequestAPI_Test {
    public static testMethod void setupMethod(){
        
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
        
        List<Id> prLst = new List<Id>();
        RecordType rt = [SELECT Id, Name, DeveloperName, SobjectType FROM RecordType where SobjectType = 'Pricing_Request__c' AND DeveloperName = 'Default_Pricing_Request' limit 1];
        Pricing_Request__c pr = new Pricing_Request__c();
        pr.Opportunity__c = opp.Id;
        pr.Notes__c = 'Hello';
        pr.Status__c = 'Complete';
        pr.Bill_Type__c = 'UCB';
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
        insert pr; 
        system.debug('pr--'+pr);
        /*pr.Original_Pricing_Request__c= pr.Id;
        update pr;*/
        
         prLst.add(pr.Id);
        system.debug('prLst'+prLst);
        
        Date myDate = date.newInstance(2020,01,17);
        Utility_Account__c ua1 = new Utility_Account__c();
        ua1.Name = '1234567890';
        ua1.Account__c = acc1.Id;
        ua1.Utility__c = acc2.Id;
        insert ua1;
        
        Utility_Account_Pricing__c uapr = new Utility_Account_Pricing__c();
        uapr.Pricing_Request__c = pr.Id;
        uapr.Start_Date__c = myDate;
        uapr.Utility_Account__c = ua1.Id;
        insert uapr;
        
        Scope_Integration__c ci = new Scope_Integration__c();
        ci.Callout__c = true;
        insert ci;
        
        uapr=[select Id, Name,Pricing_Request__c,Start_Date__c,Utility_Account__c from Utility_Account_Pricing__c where id = : uapr.id];
       // update uapr;
        system.debug('uapr--->'+uapr);
        system.debug('uapr---'+uapr.Name);
        List <Pricing_Request__c> pro1 = new List <Pricing_Request__c>();
        
        pro1 =[SELECT Product_Id__c,Voluntary_RECs__c,Voluntary_RECs_percent__c,Bill_Type__c,Customer__r.Name, Name,Due_Date__c,Mark_to_Market__c,
               Opportunity_ID__c, Customer__r.Customer_ID__c, Original_Pricing_Request__r.Name, Status__c, Urgent_Request__c, No_of_Utility_Accounts__c,
               Expected_Annual_Volume__c, Notes__c, Pricing_Quote_Comments__c, Treatment__c, Start_Dates__c, CPM__c,
                (select id,Utility_Account__r.Name, Utility_Account__r.Utility__r.Name, Start_Date__c from Utility_Account_Pricing_Requests__r)
               FROM Pricing_Request__c where Id = :pr.Id];
        system.debug('pro1--'+pro1);
        
        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'suhas.pardeshi@aress.com'];
        System.Test.setMock(HttpCalloutMock.class, new MockHttpPRResponseGenerator());
        Test.startTest();
        CreatePricingRequestAPI.makePostCallout(prLst);
        Test.stopTest();
    }

}