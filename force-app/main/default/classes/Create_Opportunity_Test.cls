/*
* @Purpose: Test class for Create_Opportunity Apex.
* @Author: Aress Software
* @CreatedDate: 07/21/2020
* @Related Code: 
* @LastModifiedDate:
* @LastModifiedBy:
*/

@isTest
public class Create_Opportunity_Test {
    @testSetup
        public static void setupMethod(){
        HU_Api_Call__c huObj = new HU_Api_Call__c();
        huObj.Call_AWS__c = false;
        huObj.Call_Azure__c = false;
        insert huObj;
            
        Marketer__c getMarketer = new Marketer__c(name = 'xyz', MarketerDunsNumber__c = 'ten');
        Insert getMarketer;
        Account objAccb = new Account(Name = 'Account Test',State__c = 'NY',Credit_Check_Required__c = true,Phone='1234567894');
        insert objAccb;
        Account objAccb1 = new Account(Name = 'Account Test',State__c = 'NY',Credit_Check_Required__c = true,Phone='1234567894');
        objAccb1.RecordTypeId = [SELECT Id, Name, DeveloperName FROM RecordType where DeveloperName = 'Customer'].Id;
        insert objAccb1;
        Account objAcc = new Account(Name = 'Account Test',Bill_Type__c = 'UCB',State__c = 'NY',Credit_Check_Required__c = true,Broker__c = objAccb.Id,Phone='1234567894' );
        objAcc.RecordTypeId = [SELECT Id, Name, DeveloperName FROM RecordType where DeveloperName = 'Utility'].Id;
        insert objAcc;
        
        Contact con = new Contact();
        con.LastName = 'Contracts Group';
        con.Email = 'test@test.com';
        insert con;
        
        Contact objContact1 = new Contact();
        objContact1.LastName = 'Pricing Team';
        objContact1.AccountId = objAcc.Id;
        objContact1.Phone = '1234567890';
        objContact1.Email = 'test@test.com';
        insert objContact1;
        
        Contract objCon = new Contract();
        objCon.ContractTerm = 4;
        objCon.StartDate = system.today().addMonths(-1);
        objCon.AccountId = objAcc.Id;
        //objCon.Status = 'Live';
        insert objCon;
        
        
        
        Contact objContact = new Contact();
        objContact.LastName = 'Test Lastname';
        objContact.AccountId = objAcc.Id;
        objContact.Phone = '1234567890';
        insert objContact;
        
        objAcc.Primary_Contact__c = objContact.Id;
        update objAcc;
        
        Opportunity objOpp = new Opportunity();
        objOpp.State__c = 'NY';
        objOpp.AccountId = objAccb1.Id;
        objOpp.ContractId = objCon.Id;
        objOpp.Name = 'Oppo Test';
        objOpp.StageName = 'New';
        objOpp.CloseDate = system.today().addMonths(1);
        objOpp.Broker__c = objAcc.id;
        objOpp.ContactId = objContact.Id;
        insert objOpp;
        Utility_Account__c objUA = new Utility_Account__c();
        objUA.Account__c = objAcc.Id;
        objUA.Name = '1234567890';
        objUA.Utility__c = objAcc.Id;
        objUA.Street__c = 'Street';
        objUA.City__c = 'City';
        objUA.State__c = 'NY';
        objUA.Country__c = 'US';
        objUA.Zip__c = '123456';
        objUA.Annual_Usage_kWh__c = 152000;
        insert objUA;      
        List<Utility_Account__c> newUAs = new List<Utility_Account__c>{objUA};
            Utility_Account_Opportunity__c objUAO = new Utility_Account_Opportunity__c();
        objUAO.Utility_Account__c = objUA.Id;
        objUAO.Twelve_Month_Price__c = 1200;
        objUAO.Opportunity__c = objOpp.Id;
        objUAO.Status__c = 'Priced - Excluded';
        objUAO.Start_Date__c = system.today();
        insert objUAO;
        
        Utility_Account_Opportunity__c objUAO2 = new Utility_Account_Opportunity__c();
        objUAO2.Utility_Account__c = objUA.Id;
        objUAO2.Twelve_Month_Price__c = 1200;
        objUAO2.Opportunity__c = objOpp.Id;
        objUAO2.Status__c = 'Priced - Excluded';
        objUAO2.Start_Date__c = system.today();
        insert objUAO2;
        
        Utility_Account_Opportunity__c objUAO3 = new Utility_Account_Opportunity__c();
        objUAO3.Utility_Account__c = objUA.Id;
        objUAO3.Twelve_Month_Price__c = 1200;
        objUAO3.Opportunity__c = objOpp.Id;
        objUAO3.Status__c = 'Priced';
        objUAO3.Start_Date__c = system.today();
        insert objUAO3;
        
        List<Utility_Account_Opportunity__c> UAOList = new List<Utility_Account_Opportunity__c>();
        UAOList.add(objUAO2);
        List<Utility_Account_Opportunity__c> incUAOList = new List<Utility_Account_Opportunity__c>();
        incUAOList.add(objUAO); 
        
        Product2 prod = new Product2(Name = 'Fully Fixed', default__c=true,IsActive = true,
                                     Family = 'Fixed',State__c = 'NY');
        insert prod;
        Product2 prod1 = new Product2(Name = 'Capacity Reset', default__c=false,IsActive = true,
                                      Family = 'Fixed',State__c = 'NY');
        insert prod1;
        
        
        List<Create_Opportunity.UAWrapper> UALstWrapper = new List<Create_Opportunity.UAWrapper>();
        List<Create_Opportunity.UAWrapper> UALstWrapperNew = new List<Create_Opportunity.UAWrapper>();
        
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        test.startTest();
        UALstWrapperNew = Create_Opportunity.getUAList(objUA.Account__c, 'NY', 'ASC', 'Name', UALstWrapper,new List<String>{});
        Create_Opportunity.getUAList(objUA.Account__c, 'NY', 'ASC', 'Name', UALstWrapperNew,new List<String>{'Test','Test1','Test','Test','Test','Test','Test','Test','Test','Test','Test','Test','Test','Test','Test','Test','Test','Test','Test','Test','Test','Test','Test','Test','Test','Test','Test','Test','Test','Test','Test','Test','Test','Test','Test','Test','Test'});
        Create_Opportunity.getUAList(objUA.Account__c, 'NY', 'ASC', 'Name', UALstWrapperNew,new List<String>{});
        Create_Opportunity.getStatePicklist(objUA.Id);
        Create_Opportunity.SaleType();
        Create_Opportunity.GetStatusPicklist();
        Create_Opportunity.ProductFamily();
        Create_Opportunity.GetProducts('Fixed', 'NY',null);
        Create_Opportunity.GetUAOsandState(objOpp.Id);
        Create_Opportunity.CreateOpptywithUAOs(UALstWrapperNew, UALstWrapperNew, UALstWrapperNew);
        Create_Opportunity.SetPgLst(UALstWrapperNew);
        Create_Opportunity.setPgLstcheckbox(UALstWrapperNew);
        Create_Opportunity.getselectOptionNew('Pricing_Request__c','Bill_Type__c',prod.Id); 
        
        test.stopTest();
    }
    
    @isTest
    public static void TestMethod1(){
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        EXPRN__Experian_Business__c  exp = new EXPRN__Experian_Business__c ();
        exp.EXPRN__BIN__c = '701852096';
        insert exp;
        
        Experian__c creds = new Experian__c();
        creds.Auth_URL__c = 'https://sandbox-us-api.experian.com/oauth2/v1/token';
        creds.Auto_Search_URL__c= 'https://sandbox-us-api.experian.com/businessinformation/businesses/v1/scores/search';
        creds.Auth_Body__c='{"username": "admin@decima.one","password": "IHz8OJ93E16G!","client_id": "W7o3bmXvo1aZCSdD3SaMLwRw3nJzg1YB","client_secret":"xpp2lyKgfJO7kl4R"}';
            creds.Subcode__c= '517614';
        insert creds;
        
        
        
        
 
        Marketer__c getMarketer = new Marketer__c(name = 'xyz', MarketerDunsNumber__c = 'ten');
        Insert getMarketer;
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User testUser = new User(Alias = 'standt', Email='standarduseremail@testorg.com', 
                                 EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                 LocaleSidKey='en_US', ProfileId = p.Id, 
                                 TimeZoneSidKey='America/Los_Angeles', UserName='StandardUserName@testorg12345678.com');
        insert testUser;
        
        List<Utility_Account__c> newUAs =[Select Id, Name,Account__c,Account__r.Broker__c,Status__c,Utility__r.Credit_Check_Required__c, Utility__r.Name, Utility_State__c , Supply_Start_Date__c from Utility_Account__c limit 1];
        
        List<Utility_Account_Opportunity__c> UAOList = [Select Id,Utility_Account__c,Utility_Account__r.Utility__c,Opportunity__r.ContractId,Start_Date__c,Twelve_Month_Price__c,Status__c,Opportunity__c from Utility_Account_Opportunity__c limit 1];
        Id objOpp = UAOList[0].Opportunity__c;
        User userObj = [Select Id,Name from User where Id =: UserInfo.getUserId()];
        Product2 ProductId = [Select Id,Name from Product2 where name = 'Fully Fixed'];
        list <Pricing_Request__c> pr1 = new list<Pricing_Request__c>();
        list<Account> acc = [Select Id, Name From Account];
        list<Contact> con = [Select Id, Name From Contact];
        
      
        
        //pr1.add(prObj1);
  
        Create_Opportunity.PRWrapper obj = new Create_Opportunity.PRWrapper();
        obj.Product = ProductId.Id;
        obj.BillType = 'UCB';
        obj.InvoiceBillingtype='';
        obj.SaleType = 'New';
        obj.BrokerMargin = 2;
        obj.UrgentRequest = false;
        obj.DueDate = System.today();
        obj.StartDate = System.today();
        obj.Notes = '';
        obj.PricingRequestList = pr1;

        Account objAccb = new Account(Name = 'Account Test',State__c = 'NY',Credit_Check_Required__c = true,Phone='1234567894',OwnerId=testUser.Id);
        insert objAccb;

        Account objAcc = new Account(Name = 'Account Test',Bill_Type__c = 'UCB',State__c = 'NY',Credit_Check_Required__c = true,Broker__c = objAccb.Id,Phone='1234567894',OwnerId=testUser.Id);
        objAcc.RecordTypeId = [SELECT Id, Name, DeveloperName FROM RecordType where DeveloperName = 'Utility'].Id;
        insert objAcc;
        
        Account objAccb1 = new Account(Name = 'Account Test',State__c = 'NY',Credit_Check_Required__c = true,Phone='1234567894',OwnerId=testUser.Id);
        objAccb1.RecordTypeId = [SELECT Id, Name, DeveloperName FROM RecordType where DeveloperName = 'Customer'].Id;
        insert objAccb1;
        
          Pricing_Request__c prObj= new Pricing_Request__c();
        prObj.Bill_Type__c='UCB with Credit';
        prObj.Invoice_Billing_Type__c='	';
        prObj.Product_Lookup__c= ProductId.Id;
       	probj.Customer__c = objAccb1.Id;
  
        Pricing_Request__c prObj1= new Pricing_Request__c();
        prObj1.Bill_Type__c='UCB with Credit';
        prObj1.Invoice_Billing_Type__c='';
        prObj1.Product_Lookup__c= ProductId.Id;
        probj1.Customer__c = objAccb1.Id;
        pr1.add(prObj);
        insert pr1; 
        
        
        Contact objContact = new Contact();
        objContact.LastName = 'Test Lastname';
        objContact.AccountId = objAcc.Id;
        objContact.OwnerId=testUser.Id;
        objContact.Phone = '1234567890';
        insert objContact;
        
        Contract objCon = new Contract();
        objCon.ContractTerm = 4;
        objCon.OwnerId=testUser.Id;
        objCon.StartDate = system.today().addMonths(-1);
        objCon.AccountId = objAccb1.Id;
        insert objCon;   
        // Preparing data for Create_Opportunity.CreateUAccs() method 
        Create_Opportunity.PRWrapper PricingRequest = new Create_Opportunity.PRWrapper();
        PricingRequest.Product = 'Fully Fixed';
        PricingRequest.BillType = 'UCB';
        PricingRequest.SaleType = 'New';
        PricingRequest.BrokerMargin = 2;
        PricingRequest.UrgentRequest = false;
        PricingRequest.DueDate = System.today();
        PricingRequest.StartDate = System.today();
        PricingRequest.Notes = '';
        PricingRequest.PricingRequestList = pr1;
                
        String AccId=objAccb.Id;
        
        List<String> ContactId = new List<String>();
        String conId = objContact.Id;
        ContactId.add(conId);
        
        String contractId=objCon.Id;
        
        Opportunity objOpp1 = new Opportunity();
        objOpp1.State__c = 'NY';
        objOpp1.OwnerId=testUser.Id;
        objOpp1.Type='Blend and Extend';
        objOpp1.AccountId = objAccb1.Id;
        objOpp1.ContractId = objCon.Id;
        objOpp1.Name = 'Oppo Test';
        objOpp1.StageName = 'New';
        objOpp1.CloseDate = system.today().addMonths(1);
        objOpp1.Broker__c = objAccb1.id;
        objOpp1.ContactId = objContact.Id;
        insert objOpp1;
        
        Create_Opportunity.UAOWrapper cou = new Create_Opportunity.UAOWrapper();
        cou.Treatment = new List<String>();
        
        Create_Opportunity.OppIdExceptionWrapper testVar = new Create_Opportunity.OppIdExceptionWrapper();
        testVar.OppId = objOpp1.Id;
        testVar.exceptionMsg = 'Test';
        Test.startTest(); 
        testVar=Create_Opportunity.CreateUAccs(newUAs,PricingRequest,true,testUser,AccId,ContactId,contractId,null,null,null);
        //testVar = 
        //Create_Opportunity.CreateUAccs(UAList, PricingRequest, CreatePricingReq, CPMUser, AccId, ContactId, contractId)
        Create_Opportunity.CreatePR(UAOList,PricingRequest,testUser,objOpp1.Id,true,contractId,false,200.00,'option1',prObj1.Id,true,new List<String>{'UCB with Credit','Dual'});
        Create_Opportunity.getselectOption('Pricing_Request__c','Bill_Type__c');
        Create_Opportunity.getPicklists(acc[0].Id,ProductId.Id);
        Create_Opportunity.getBillType(UAOList);
        Create_Opportunity.getExistingPR(objOpp1.Id);
        Create_Opportunity.utilAccounts(objOpp1);
        Create_Opportunity.getProd('Fully Fixed');
        Create_Opportunity.codeCovMethod();
        Test.stopTest();
        
    }
    
    @isTest
    public static void TestMethod2(){
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        Experian__c creds = new Experian__c();
        creds.Auth_URL__c = 'https://sandbox-us-api.experian.com/oauth2/v1/token';
        creds.Auto_Search_URL__c= 'https://sandbox-us-api.experian.com/businessinformation/businesses/v1/scores/search';
        creds.Auth_Body__c='{"username": "admin@decima.one","password": "IHz8OJ93E16G!","client_id": "W7o3bmXvo1aZCSdD3SaMLwRw3nJzg1YB","client_secret":"xpp2lyKgfJO7kl4R"}';
            creds.Subcode__c= '517614';
        insert creds;
        
        EXPRN__Experian_Business__c  exp = new EXPRN__Experian_Business__c ();
        exp.EXPRN__BIN__c = '701852096';
        insert exp;
 
        Marketer__c getMarketer = new Marketer__c(name = 'xyz', MarketerDunsNumber__c = 'ten');
        Insert getMarketer;
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User testUser = new User(Alias = 'standt', Email='standarduseremail@testorg.com', 
                                 EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                 LocaleSidKey='en_US', ProfileId = p.Id, 
                                 TimeZoneSidKey='America/Los_Angeles', UserName='StandardUserName@testorg12345678.com');
        insert testUser;
        
        List<Utility_Account__c> newUAs =[Select Id, Name,Account__c,Account__r.Broker__c,Status__c,Utility__r.Credit_Check_Required__c, Utility__r.Name, Utility_State__c , Supply_Start_Date__c from Utility_Account__c limit 1];
        
        List<Utility_Account_Opportunity__c> UAOList = [Select Id,Utility_Account__c,Utility_Account__r.Utility__c,Opportunity__r.ContractId,Start_Date__c,Twelve_Month_Price__c,Status__c,Opportunity__c from Utility_Account_Opportunity__c limit 1];
        Id objOpp = UAOList[0].Opportunity__c;
        User userObj = [Select Id,Name from User where Id =: UserInfo.getUserId()];
        Product2 ProductId = [Select Id,Name from Product2 where name = 'Fully Fixed'];
        list <Pricing_Request__c> pr1 = new list<Pricing_Request__c>();
        list<Account> acc = [Select Id, Name From Account];
        list<Contact> con = [Select Id, Name From Contact];
        
      
        
        //pr1.add(prObj1);
  
        Create_Opportunity.PRWrapper obj = new Create_Opportunity.PRWrapper();
        obj.Product = ProductId.Id;
        obj.BillType = 'UCB';
        obj.InvoiceBillingtype='';
        obj.SaleType = 'New';
        obj.BrokerMargin = 2;
        obj.UrgentRequest = false;
        obj.DueDate = System.today();
        obj.StartDate = System.today();
        obj.Notes = '';
        obj.PricingRequestList = pr1;

        Account objAccb = new Account(Name = 'Account Test',State__c = 'NY',Credit_Check_Required__c = true,Phone='1234567894',OwnerId=testUser.Id);
        insert objAccb;

        Account objAcc = new Account(Name = 'Account Test',Bill_Type__c = 'UCB',State__c = 'NY',Credit_Check_Required__c = true,Broker__c = objAccb.Id,Phone='1234567894',OwnerId=testUser.Id);
        objAcc.RecordTypeId = [SELECT Id, Name, DeveloperName FROM RecordType where DeveloperName = 'Utility'].Id;
        insert objAcc;
        
        Account objAccb1 = new Account(Name = 'Account Test',State__c = 'NY',Credit_Check_Required__c = true,Phone='1234567894',OwnerId=testUser.Id);
        objAccb1.RecordTypeId = [SELECT Id, Name, DeveloperName FROM RecordType where DeveloperName = 'Customer'].Id;
        insert objAccb1;
        
          Pricing_Request__c prObj= new Pricing_Request__c();
        prObj.Bill_Type__c='Dual';
        prObj.Invoice_Billing_Type__c='	';
        prObj.Product_Lookup__c= ProductId.Id;
       	probj.Customer__c = objAccb1.Id;
  
        Pricing_Request__c prObj1= new Pricing_Request__c();
        prObj1.Bill_Type__c='Dual';
        prObj1.Invoice_Billing_Type__c='';
        prObj1.Product_Lookup__c= ProductId.Id;
        probj1.Customer__c = objAccb1.Id;
        pr1.add(prObj);
        insert pr1; 
        
        
        Contact objContact = new Contact();
        objContact.LastName = 'Test Lastname';
        objContact.AccountId = objAcc.Id;
        objContact.OwnerId=testUser.Id;
        objContact.Phone = '1234567890';
        insert objContact;
        
        Contract objCon = new Contract();
        objCon.ContractTerm = 4;
        objCon.OwnerId=testUser.Id;
        objCon.StartDate = system.today().addMonths(-1);
        objCon.AccountId = objAccb1.Id;
        insert objCon;   
        // Preparing data for Create_Opportunity.CreateUAccs() method 
        Create_Opportunity.PRWrapper PricingRequest = new Create_Opportunity.PRWrapper();
        PricingRequest.Product = 'Fully Fixed';
        PricingRequest.BillType = 'Dual';
        PricingRequest.SaleType = 'New';
        PricingRequest.BrokerMargin = 2;
        PricingRequest.UrgentRequest = false;
        PricingRequest.DueDate = System.today();
        PricingRequest.StartDate = System.today();
        PricingRequest.Notes = '';
        PricingRequest.PricingRequestList = pr1;
                
        String AccId=objAccb.Id;
        
        List<String> ContactId = new List<String>();
        String conId = objContact.Id;
        ContactId.add(conId);
        
        String contractId=objCon.Id;
        
        Opportunity objOpp1 = new Opportunity();
        objOpp1.State__c = 'NY';
        objOpp1.OwnerId=testUser.Id;
        objOpp1.Type='Blend and Extend';
        objOpp1.AccountId = objAccb1.Id;
        objOpp1.ContractId = objCon.Id;
        objOpp1.Name = 'Oppo Test';
        objOpp1.StageName = 'New';
        objOpp1.CloseDate = system.today().addMonths(1);
        objOpp1.Broker__c = objAccb1.id;
        objOpp1.ContactId = objContact.Id;
        insert objOpp1;
        
        Create_Opportunity.OppIdExceptionWrapper testVar = new Create_Opportunity.OppIdExceptionWrapper();
        testVar.OppId = objOpp1.Id;
        testVar.exceptionMsg = 'Test';
        Test.startTest();
        testVar=Create_Opportunity.CreateUAccs(newUAs,PricingRequest,true,testUser,AccId,ContactId,contractId,null,null,null);
        Create_Opportunity.CreatePR(UAOList,PricingRequest,testUser,objOpp1.Id,false,contractId,false,200.00,'option2',prObj1.Id,true,new List<String>{'UCB with Credit','Dual'});
        Create_Opportunity.getselectOption('Pricing_Request__c','Bill_Type__c');
        Create_Opportunity.getPicklists(acc[0].Id,ProductId.Id);
        Create_Opportunity.getBillType(UAOList);
        Create_Opportunity.getExistingPR(objOpp1.Id);
        Create_Opportunity.getProd('Fully Fixed');
        Test.stopTest();
        
    }
    
}