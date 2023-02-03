@IsTest
public class salesRenewal_Test {
    
     public static testMethod void setupMethod(){
        Trigger_Settings__c settings = new Trigger_Settings__c();
        settings.Name = 'QuoteLineItem_Trigger';
        settings.TriggerOn__c = false;
        insert settings;
        List<Id> enrollmentRecIdVal = new List<Id>();
         
         Account objAccB = new Account(Name = 'Account BrokerTest');
        objAccB.RecordTypeId = [SELECT Id, Name, DeveloperName FROM RecordType where DeveloperName = 'Broker'].Id;
        insert objAccB;
        
        Account objAcc = new Account(Name = 'Account Test', Broker__c = objAccB.Id);
        objAcc.RecordTypeId = [SELECT Id, Name, DeveloperName FROM RecordType where DeveloperName = 'Utility'].Id;
        insert objAcc;
         
         
        
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
        objOpp.AccountId = objAcc.Id;
        objOpp.ContractId = objCon.Id;
        objOpp.Name = 'Oppo Test';
        objOpp.StageName = 'New';
        objOpp.CloseDate = system.today().addMonths(1);
        objOpp.Broker__c = objAcc.id;
        objOpp.ContactId = objContact.Id;
        objOpp.Start_Date__c = system.today();
        objOpp.Existing_Contract__c = objCon.Id;
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
        insert objUAO;
         
         Utility_Account_Contract__c objUAC2 = new Utility_Account_Contract__c();
        objUAC2.Utility_Account__c = objUA.Id;
        objUAC2.Contract__c = objCon.Id;
        insert objUAC2;
        
        Utility_Account_Opportunity__c objUAO2 = new Utility_Account_Opportunity__c();
        objUAO2.Utility_Account__c = objUA.Id;
        objUAO2.Twelve_Month_Price__c = 1200;
        objUAO2.Opportunity__c = objOpp.Id;
        objUAO2.Status__c = 'Priced - Excluded';
        insert objUAO2;
        
        Utility_Account_Opportunity__c objUAO3 = new Utility_Account_Opportunity__c();
        objUAO3.Utility_Account__c = objUA.Id;
        objUAO3.Twelve_Month_Price__c = 1200;
        objUAO3.Opportunity__c = objOpp.Id;
        objUAO3.Status__c = 'Priced';
        insert objUAO3;
        
        List<Utility_Account_Opportunity__c> UAOList = new List<Utility_Account_Opportunity__c>();
        UAOList.add(objUAO2);
        List<Utility_Account_Opportunity__c> incUAOList = new List<Utility_Account_Opportunity__c>();
        incUAOList.add(objUAO); 
       
        
        Product2 prod = new Product2(Name = 'Laptop X200', 
                                     Family = 'Hardware');
        insert prod;
        Pricing_Request__c pReq = new Pricing_Request__c();
        insert pReq;
        
        
        List<Price__c> prlst = new List<Price__c>();
        Price__c pr = new Price__c();
        pr.Pricing_Request__c = pReq.Id;
        pr.Price_Type__c = 'Quote';
        pr.Opportunity__c = objOpp.Id;
        pr.Product_Lookup__c = prod.Id;
        prlst.add(pr);
        insert prlst;
        
        
        Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry standardPrice = new PricebookEntry(
            Pricebook2Id = pricebookId, Product2Id = prod.Id,
            UnitPrice = 10000, IsActive = true);
        insert standardPrice;
        
        Pricebook2 customPB = new Pricebook2(Name='Custom Pricebook', isActive=true);
        insert customPB;
        
        PricebookEntry customPrice = new PricebookEntry(
            Pricebook2Id = customPB.Id, Product2Id = prod.Id,
            UnitPrice = 12000, IsActive = true);
        insert customPrice;

     
        
        String Pricebook2Id = [select id, name from pricebook2].Id;
        PricebookEntry pricebookEntryRecord = [SELECT Id, Product2Id, Pricebook2Id FROM PricebookEntry WHERE Pricebook2Id =: Pricebook2Id ];
        String PricebookEntryId = pricebookEntryRecord.Id;
        String product2Id = pricebookEntryRecord.Product2Id;
       Quote newQuoteRecord = new Quote();
        newQuoteRecord.Name = 'New Quote';
        newQuoteRecord.Pricebook2Id = Pricebook2Id;
        newQuoteRecord.OpportunityId = objOpp.Id;
        newQuoteRecord.Product__c =  prod.Id;
        //newQuoteRecord.IsSyncing = true;
        insert newQuoteRecord;
        objOpp.SyncedQuoteId = newQuoteRecord.Id;
        update objOpp;
         
         objCon.Opportunity__c = objOpp.Id;
         update objCon;
             
       
        
        
         
        
         test.startTest();
         
         salesRenewal.getUAs(objCon.Id,false);
         renewalDetails.getDetails(objOpp.Id);
         
         test.stopTest();
    }
    
    public static testMethod void setupMethod1(){
        Trigger_Settings__c settings = new Trigger_Settings__c();
        settings.Name = 'QuoteLineItem_Trigger';
        settings.TriggerOn__c = false;
        insert settings;
        List<Id> enrollmentRecIdVal = new List<Id>();
         
         Account objAccB = new Account(Name = 'Account BrokerTest');
        objAccB.RecordTypeId = [SELECT Id, Name, DeveloperName FROM RecordType where DeveloperName = 'Broker'].Id;
        insert objAccB;
        
        Account objAcc = new Account(Name = 'Account Test', Broker__c = objAccB.Id);
        objAcc.RecordTypeId = [SELECT Id, Name, DeveloperName FROM RecordType where DeveloperName = 'Utility'].Id;
        insert objAcc;
         
         
        
        Contract objCon = new Contract();
        objCon.ContractTerm = 4;
        objCon.StartDate = system.today().addMonths(-1);
        objCon.AccountId = objAcc.Id;
        //objCon.Status = 'Live';
        insert objCon;
        
        Contact objContact = new Contact();
        objContact.LastName = 'Pricing Team';
        objContact.AccountId = objAcc.Id;
        objContact.Phone = '1234567890';
        objContact.Email = 'test@test.com';
        insert objContact;
        
        objAcc.Primary_Contact__c = objContact.Id;
        update objAcc;
        
        Opportunity objOpp = new Opportunity();
        objOpp.AccountId = objAcc.Id;
        objOpp.ContractId = objCon.Id;
        objOpp.Name = 'Oppo Test';
        objOpp.Type = 'Blend and Extend';
        objOpp.StageName = 'New';
        objOpp.CloseDate = system.today().addMonths(1);
        objOpp.Broker__c = objAcc.id;
        objOpp.ContactId = objContact.Id;
        objOpp.Start_Date__c = system.today();
        objOpp.Existing_Contract__c = objCon.Id;
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
        insert objUAO;
         
         Utility_Account_Contract__c objUAC2 = new Utility_Account_Contract__c();
        objUAC2.Utility_Account__c = objUA.Id;
        objUAC2.Contract__c = objCon.Id;
        insert objUAC2;
        
        Utility_Account_Opportunity__c objUAO2 = new Utility_Account_Opportunity__c();
        objUAO2.Utility_Account__c = objUA.Id;
        objUAO2.Twelve_Month_Price__c = 1200;
        objUAO2.Opportunity__c = objOpp.Id;
        objUAO2.Status__c = 'Priced - Excluded';
        insert objUAO2;
        
        Utility_Account_Opportunity__c objUAO3 = new Utility_Account_Opportunity__c();
        objUAO3.Utility_Account__c = objUA.Id;
        objUAO3.Twelve_Month_Price__c = 1200;
        objUAO3.Opportunity__c = objOpp.Id;
        objUAO3.Status__c = 'Priced';
        insert objUAO3;
        
        List<Utility_Account_Opportunity__c> UAOList = new List<Utility_Account_Opportunity__c>();
        UAOList.add(objUAO2);
        List<Utility_Account_Opportunity__c> incUAOList = new List<Utility_Account_Opportunity__c>();
        incUAOList.add(objUAO); 
       
        
        Product2 prod = new Product2(Name = 'Laptop X200', 
                                     Family = 'Hardware');
        insert prod;
        Pricing_Request__c pReq = new Pricing_Request__c();
        insert pReq;
        
        
        List<Price__c> prlst = new List<Price__c>();
        Price__c pr = new Price__c();
        pr.Pricing_Request__c = pReq.Id;
        pr.Price_Type__c = 'Quote';
        pr.Opportunity__c = objOpp.Id;
        pr.Product_Lookup__c = prod.Id;
        prlst.add(pr);
        insert prlst;
        
        
        Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry standardPrice = new PricebookEntry(
            Pricebook2Id = pricebookId, Product2Id = prod.Id,
            UnitPrice = 10000, IsActive = true);
        insert standardPrice;
        
        Pricebook2 customPB = new Pricebook2(Name='Custom Pricebook', isActive=true);
        insert customPB;
        
        PricebookEntry customPrice = new PricebookEntry(
            Pricebook2Id = customPB.Id, Product2Id = prod.Id,
            UnitPrice = 12000, IsActive = true);
        insert customPrice;

     
        
        String Pricebook2Id = [select id, name from pricebook2].Id;
        PricebookEntry pricebookEntryRecord = [SELECT Id, Product2Id, Pricebook2Id FROM PricebookEntry WHERE Pricebook2Id =: Pricebook2Id ];
        String PricebookEntryId = pricebookEntryRecord.Id;
        String product2Id = pricebookEntryRecord.Product2Id;
       Quote newQuoteRecord = new Quote();
        newQuoteRecord.Name = 'New Quote';
        newQuoteRecord.Pricebook2Id = Pricebook2Id;
        newQuoteRecord.OpportunityId = objOpp.Id;
        newQuoteRecord.Product__c =  prod.Id;
        //newQuoteRecord.IsSyncing = true;
        insert newQuoteRecord;
        objOpp.SyncedQuoteId = newQuoteRecord.Id;
        update objOpp;
         
         objCon.Opportunity__c = objOpp.Id;
         update objCon;
             
       
        
        
         
        
         test.startTest();
         
         Blend_Extend.getUAs(objCon.Id);
        Blend_Extend_Email.invokeSendEmail(new List<Id>{objCon.Id});
        GetTerminatedUACs gUAC = new GetTerminatedUACs(); 
         gUAC.BillType = 'sdsad';
        gUAC.product = 'Fixed';
        gUAC.requestType = 'Initial';
         test.stopTest();
    }

}