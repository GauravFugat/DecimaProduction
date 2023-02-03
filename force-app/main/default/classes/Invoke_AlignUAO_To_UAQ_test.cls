@isTest
public class Invoke_AlignUAO_To_UAQ_test {
   @isTest
    public static void testSetup(){
        
        Id id2 = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Customer').getRecordTypeId();
        Account acc1= new Account();
        acc1.Name = 'Test Acc1';
        acc1.RecordTypeId =id2;
        //acc2.Utility_Account_Number_Prefix__c  = 'TST';
        insert acc1;
        
     Id id1 = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Utility').getRecordTypeId();
        Account acc2= new Account();
        acc2.Name = 'Test Acc1';
        acc2.RecordTypeId =id1;
        //acc2.Utility_Account_Number_Prefix__c  = 'TST';
        insert acc2;
        
        Contact con = new Contact();
        con.FirstName = 'Con First';
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
        opp.AccountId = acc2.id;
        opp.ContractId = objCon.Id;
        opp.CloseDate = system.today().addMonths(1);
        opp.StageName ='New';
        opp.Broker__c = acc2.id;
        opp.ContactId = con.Id;
        opp.Price_Request_Count__c = 2;
        insert opp;
        system.debug('opp======='+opp);
        
        HU_Api_Call__c huObj = new HU_Api_Call__c();
        huObj.Call_AWS__c = false;
        huObj.Call_Azure__c = false;
        insert huObj;
        
        Product2 prodObj = new Product2(Name='Fully Fixed',ProductCode = '0',Product_Id__c = '0');
        insert prodObj;
        
        /*   RecordType rtToinsert = new RecordType();
rtToinsert.SobjectType = 'Pricing_Request__c';
rtToinsert.Name = 'Default_Pricing_Request';
insert rtToinsert;*/
        
        RecordType rt = [SELECT Id, Name, DeveloperName, SobjectType FROM RecordType where SobjectType = 'Pricing_Request__c' AND DeveloperName = 'Default_Pricing_Request' limit 1];
        Pricing_Request__c pr = new Pricing_Request__c();
        pr.Opportunity__c = opp.Id;
        pr.Notes__c = 'Hello';
        pr.Status__c = 'Complete';
        pr.Bill_Type__c = 'UCB';
        pr.RecordTypeId = rt.Id;
        pr.Product_Lookup__c = prodObj.Id;
        pr.Voluntary_RECs__c = 'NA';
        pr.Voluntary_RECs_percent__c = 100;
        pr.Record_Created__c = true;
        insert pr;
        Date myDate = date.newInstance(2020,01,17);
        Utility_Account__c ua1 = new Utility_Account__c();
        ua1.Name = '08016502840006269351';
        ua1.Account__c = acc1.Id;
        ua1.Utility__c = acc2.Id;
        insert ua1;
        
        Utility_Account_Pricing__c uapr = new Utility_Account_Pricing__c();
        uapr.Pricing_Request__c = pr.Id;
        
        uapr.Start_Date__c = myDate;
        uapr.Utility_Account__c = ua1.Id;
        insert uapr;
        
        system.debug('pr======='+pr);
        Utility_Account__c ua = new Utility_Account__c();
        ua.Name = '1234567891';
        ua.Account__c = acc1.Id;
        ua.Utility__c = acc2.Id;
        ua.Street__c ='street 43';
        ua.City__c ='Test';
        ua.State__c = 'NY';
        ua.zip__c ='343438';
        ua.Country__c = 'US';
        //ua.Service_Address__c = '';
        ua.Zone__c = 'E';
        insert ua;
        
        Utility_Account_Opportunity__c uao = new Utility_Account_Opportunity__c();
        uao.Opportunity__c = opp.Id;
        uao.Utility_Account__c = ua1.Id;
        uao.Start_Date__c = myDate;
        uao.Status__c = 'Priced';
        insert uao;
        
        
        Product2 prod = new Product2(Name = 'Laptop X200', 
                                     Family = 'Hardware');
        insert prod;
        Pricing_Request__c pReq = new Pricing_Request__c();
        insert pReq;
        
        
      /*  List<Price__c> prlst = new List<Price__c>();
        Price__c pr = new Price__c();
        pr.Pricing_Request__c = pReq.Id;
        pr.Price_Type__c = 'Quote';
        pr.Opportunity__c = objOpp.Id;
        pr.Product_Lookup__c = prod.Id;
        prlst.add(pr);
        insert prlst;*/
        
        
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
        
        
        /* SELECT Id, Quote__c,Start_Date__c,Utility_Account__c   FROM Utility_Account_Quote__c WHERE Quote__c =:syncedQuote[0].Id */
        String Pricebook2Id = [select id, name from pricebook2].Id;
        PricebookEntry pricebookEntryRecord = [SELECT Id, Product2Id, Pricebook2Id FROM PricebookEntry WHERE Pricebook2Id =: Pricebook2Id ];
        String PricebookEntryId = pricebookEntryRecord.Id;
        String product2Id = pricebookEntryRecord.Product2Id;
        Quote newQuoteRecord = new Quote();
        newQuoteRecord.Name = 'New Quote';
        newQuoteRecord.Pricebook2Id = Pricebook2Id;
        newQuoteRecord.OpportunityId = opp.Id;
        //newQuoteRecord.IsSyncing = true;
        insert newQuoteRecord;
        
        Utility_Account_Quote__c uaq = new Utility_Account_Quote__c();
        uaq.Quote__c = newQuoteRecord.Id;
        uaq.Start_Date__c = System.today();
        uaq.Utility_Account__c = ua.Id;
        insert uaq;
        
        
        
        Test.startTest();
        Invoke_AlignUAO_To_UAQ.alignUAO_UAQ(new List<Id>{opp.Id});
        Test.stopTest();
        
    }
}