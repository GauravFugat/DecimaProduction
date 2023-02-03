@isTest
public class PrepareForContractAura_Test {
    
    public static testMethod void TestgetQuoteSummaryDataOpp(){
        
        Account objAcc = new Account(Name = 'Account Test');
        objAcc.RecordTypeId = [SELECT Id, Name, DeveloperName FROM RecordType where DeveloperName = 'Utility'].Id;
        insert objAcc;
        
        Account objAcc1 = new Account(Name = 'Account Test1');
        insert objAcc1;
        
        
        Contact objContact = new Contact();
        objContact.LastName = 'Test Lastname';
        objContact.AccountId = objAcc.Id;
        objContact.Phone = '1234567890';
        objContact.Email = 'test123@test.com';
        insert objContact;
        
        objAcc.Primary_Contact__c = objContact.Id;
        update objAcc;
        
        Id  standardPb = Test.getStandardPricebookId();
        
        Opportunity objOpp = new Opportunity();
        objOpp.AccountId = objAcc.Id;
        //objOpp.ContractId = objCon.Id;
        objOpp.Name = 'Oppo Test';
        objOpp.StageName = 'New';
        objOpp.CloseDate = system.today().addMonths(1);
        objOpp.Broker__c = objAcc.id;
        objOpp.ContactId = objContact.Id;
        objOpp.AccountId=objAcc.Id;
        objOpp.Pricebook2Id = standardPb;
        insert objOpp;
        
        Trigger_Settings__c settings = new Trigger_Settings__c();
        settings.Name = 'QuoteLineItem_Trigger';
        settings.TriggerOn__c = true;
        insert settings;
        
        Pricebook2 pbk1 = new Pricebook2 (Name='Test Pricebook Entry 1',Description='Test Pricebook Entry 1', isActive=true);
        insert pbk1;
        
        Product2 prod = new Product2(Name='test1',Family='Liner', IsActive=true);
        insert prod;
        
        PricebookEntry pbe = new PricebookEntry (Product2Id=prod.id,Pricebook2ID=standardPb,UnitPrice=50, isActive=true,UseStandardPrice = false);
        insert pbe;
        
        Quote qt = new Quote(Name='test quote',OpportunityId=objOpp.id,Pricebook2Id = standardPb, Bill_Type__c = 'Dual'                
                             );
        insert qt;
        
        QuoteLineItem qliliner = new QuoteLineItem(Revised_Sales_Margin_per_unit__c = 12,Total_Usage__c = 4,QuoteId=qt.id,PriceBookEntryID=pbe.id,Quantity=4, UnitPrice =pbe.UnitPrice);
		insert qliliner;
        
        //Quote newQuoteRecord = new Quote();
        //newQuoteRecord.Name = 'New Quote';
        //newQuoteRecord.Bill_Type__c='Dual';
        //newQuoteRecord.OpportunityId = objOpp.Id;
        //insert newQuoteRecord;
        
        //QuoteLineItem qli = new QuoteLineItem();
        //qli.Term_Months__c = 6;
        //qli.UnitPrice = 0.0542;
        //qli.QuoteId = newQuoteRecord.Id;
        //insert qli;
        
        objOpp.syncedQuoteId = qt.Id;        
        update objOpp;
        
        test.startTest();
        PrepareForContractAura.getOppData(objOpp.Id);
        PrepareForContractAura.getContactData(objOpp.Id, objAcc.ID);
        // getContactData
        PrepareForContractAura.getQuoteSummaryData(objOpp.id);
        test.stopTest();
        
    }
    
    public static testMethod void TestgetQuoteSummaryDataOpp2(){
        
        Account objAcc = new Account(Name = 'Account Test');
        objAcc.RecordTypeId = [SELECT Id, Name, DeveloperName FROM RecordType where DeveloperName = 'Utility'].Id;
        insert objAcc;
        
        Account objAcc1 = new Account(Name = 'Account Test1');
        insert objAcc1;
        
        
        Contact objContact = new Contact();
        objContact.LastName = 'Test Lastname';
        objContact.AccountId = objAcc.Id;
        objContact.Phone = '1234567890';
        objContact.Email = 'test123@test.com';
        insert objContact;
        
        objAcc.Primary_Contact__c = objContact.Id;
        update objAcc;
        
        Id  standardPb = Test.getStandardPricebookId();
        
        Opportunity objOpp = new Opportunity();
        objOpp.AccountId = objAcc.Id;
        //objOpp.ContractId = objCon.Id;
        objOpp.Name = 'Oppo Test';
        objOpp.StageName = 'New';
        objOpp.CloseDate = system.today().addMonths(1);
        objOpp.Broker__c = objAcc.id;
        objOpp.ContactId = objContact.Id;
        objOpp.AccountId=objAcc.Id;
        objOpp.Pricebook2Id = standardPb;
        insert objOpp;
        
        Trigger_Settings__c settings = new Trigger_Settings__c();
        settings.Name = 'QuoteLineItem_Trigger';
        settings.TriggerOn__c = true;
        insert settings;
        
        Pricebook2 pbk1 = new Pricebook2 (Name='Test Pricebook Entry 1',Description='Test Pricebook Entry 1', isActive=true);
        insert pbk1;
        
        Product2 prod = new Product2(Name='test1',Family='Liner', IsActive=true);
        insert prod;
        
        PricebookEntry pbe = new PricebookEntry (Product2Id=prod.id,Pricebook2ID=standardPb,UnitPrice=50, isActive=true,UseStandardPrice = false);
        insert pbe;
        
        Quote qt = new Quote(Name='test quote',OpportunityId=objOpp.id,Pricebook2Id = standardPb, Bill_Type__c = 'Dual'                
                             );
        insert qt;
        
        QuoteLineItem qliliner = new QuoteLineItem(Revised_Sales_Margin_per_unit__c = 12,Total_Usage__c = 4,QuoteId=qt.id,PriceBookEntryID=pbe.id,Quantity=4, UnitPrice =pbe.UnitPrice);
		insert qliliner;
        
        //Quote newQuoteRecord = new Quote();
        //newQuoteRecord.Name = 'New Quote';
        //newQuoteRecord.Bill_Type__c='Dual';
        //newQuoteRecord.OpportunityId = objOpp.Id;
        //insert newQuoteRecord;
        
        //QuoteLineItem qli = new QuoteLineItem();
        //qli.Term_Months__c = 6;
        //qli.UnitPrice = 0.0542;
        //qli.QuoteId = newQuoteRecord.Id;
        //insert qli;
        
        objOpp.syncedQuoteId = null;        
        update objOpp;
        
        test.startTest();
        PrepareForContractAura.getOppData(objOpp.Id);
        PrepareForContractAura.getContactData(objOpp.Id, objAcc.ID);
        // getContactData
        PrepareForContractAura.getQuoteSummaryData(objOpp.id);
        test.stopTest();
        
    }
    
    public static testMethod void TestgetQuoteSummaryDataEnrollment(){
        Trigger_Settings__c settings = new Trigger_Settings__c();
        settings.Name = 'QuoteLineItem_Trigger';
        settings.TriggerOn__c = true;
        insert settings;
              Id  standardPb = Test.getStandardPricebookId();
        
        Pricebook2 pbk1 = new Pricebook2 (Name='Test Pricebook Entry 1',Description='Test Pricebook Entry 1', isActive=true);
        insert pbk1;
        
        Product2 prod = new Product2(Name='test1',Family='Liner', IsActive=true);
        insert prod;
        
        
        
        
        PricebookEntry pbe = new PricebookEntry (Product2Id=prod.id,Pricebook2ID=standardPb,UnitPrice=50, isActive=true,UseStandardPrice = false);
        insert pbe;
        
       
        
        Account objAcc = new Account(Name = 'Account Test');
        objAcc.RecordTypeId = [SELECT Id, Name, DeveloperName FROM RecordType where DeveloperName = 'Utility'].Id;
        insert objAcc;
        
        Contact objContact = new Contact();
        objContact.LastName = 'Test Lastname';
        objContact.AccountId = objAcc.Id;
        objContact.Phone = '1234567890';
        objContact.Email = 'test123@test.com';
        insert objContact;
        Opportunity objOpp = new Opportunity();
        objOpp.AccountId = objAcc.Id;
        objOpp.Name = 'Oppo Test';
        objOpp.StageName = 'New';
        objOpp.CloseDate = system.today().addMonths(1);
        objOpp.Broker__c = objAcc.id;
        objOpp.ContactId = objContact.Id;
        objOpp.AccountId=objAcc.Id;
        objOpp.Pricebook2Id = standardPb;
        insert objOpp;
        
         Quote qt = new Quote(Name='test quote',OpportunityId=objOpp.id,Pricebook2Id = standardPb                
                             );
        insert qt;
        
        QuoteLineItem qliliner = new QuoteLineItem(Revised_Sales_Margin_per_unit__c = 12,Total_Usage__c = 4,QuoteId=qt.id,PriceBookEntryID=pbe.id,Quantity=4, UnitPrice =pbe.UnitPrice);
		insert qliliner;
        
        Contract objCon = new Contract();
        objCon.ContractTerm = 4;
        objCon.StartDate = system.today().addMonths(-1);
        objCon.AccountId = objAcc.Id;
        objCon.Opportunity__c = objOpp.Id;
        insert objCon;      
        objOpp.SyncedQuoteId = qt.Id;
        update objOpp;
        Enrollment__c objEN = new Enrollment__c();
        objEn.Start_Date_Category__c = 'Single Start Date';
        objEn.Utility_Category__c = 'Single Utility';
        objEN.Contract__c = objCon.Id;
        insert objEN;
        PrepareForContractAura.getQuoteSummaryData(objEN.id);
        
       
    }
    
}