@isTest
public class BrokerExceptionDataTest {
    public static testMethod void testBatch(){
     
        Id recordTypeBro = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Broker').getRecordTypeId();
        Account BroAcc= new Account();
        BroAcc.Name = 'Test Acc1';
        BroAcc.RecordTypeId =recordTypeBro;
         BroAcc.Not_Won_Opportunity_Count_Broker__c =1;
        insert BroAcc;
        
        /*BroAcc.Name='test broker acc';
        BroAcc.Not_Won_Opportunity_Count_Broker__c =1;
        
        update BroAcc;*/
        
         Account objAcc = new Account(Name = 'Account Test');
        objAcc.RecordTypeId = [SELECT Id, Name, DeveloperName FROM RecordType where DeveloperName = 'Utility'].Id;
        //objAcc.Tax_Exempt__c = null;
        //objAcc. street
        insert objAcc;
        
        Account objAcc1 = new Account(Name = 'Account Test1');
        insert objAcc1;
        
        Contract objCon = new Contract();
        objCon.ContractTerm = 4;
        objCon.StartDate = system.today().addMonths(-1);
        objCon.AccountId = objAcc.Id;
        //objCon.Status = 'Live';
        insert objCon;
	
        
        Opportunity opp = new Opportunity();
        opp.AccountId = BroAcc.Id;
        opp.Broker__c = BroAcc.Id;
        opp.StageName = 'Closed Lost';
        opp.CloseDate = Date.newInstance(2022, 07, 05);
        //opp.Annual_Volume_kWh__c = 78965;
        opp.Name = 'Test opp';
        opp.ContractId = objCon.Id;
        opp.Loss_Reason__c = 'Lost to Competitor';
        insert opp;
        
        
        
        
        
        Id pricebookId1 = Test.getStandardPricebookId();
        
        //Create your product
        Product2 prod = new Product2(
            Name = 'Product X',
            ProductCode = 'Pro-X',
            isActive = true
        );
        insert prod;
        
        //Create your pricebook entry
        PricebookEntry pbEntry = new PricebookEntry(
            Pricebook2Id = pricebookId1,
            Product2Id = prod.Id,
            UnitPrice = 100.00,
            IsActive = true
        );
        insert pbEntry;
        
        
        Opportunity opp1 = new Opportunity();        
        opp1.AccountId = BroAcc.Id;
        opp1.Broker__c = BroAcc.Id;
        opp1.StageName = 'New';
        opp1.CloseDate = Date.newInstance(2022, 07, 05);
        //opp.Annual_Volume_kWh__c = 78965;
        opp1.Name = 'Test opp';
        opp1.ContractId = objCon.Id;
        opp1.Loss_Reason__c = 'Lost to Competitor';
        
        
        insert opp1;
        
         OpportunityLineItem oli = new OpportunityLineItem(
            OpportunityId = opp1.Id,
            Quantity=10,
            PricebookEntryId = pbEntry.Id,
             TotalPrice=50
            
        );
                insert oli;
		/*opp1.StageName = 'Closed Won';
        update opp1;*/
        
        Credit_Check__c cr= new Credit_Check__c();
        cr.Credit_Check_Outcome__c='Passed';
        cr.Status__c='Active';
        cr.Name='raj';
        cr.Customer__c= objAcc1.Id;
        insert cr;

        Pricing_Request__c prc = new Pricing_Request__c();
        prc.Credit_Details__c= cr.Id;
        prc.Bill_Type__c = 'Dual';
        insert prc;
        
        Price__c pr = new Price__c();
        pr.Price_Type__c = 'Quote';
        pr.Opportunity__c = opp.Id;
        pr.Pricing_Request__c=prc.Id;
        pr.Credit_Detail__c =cr.Id;
        Insert pr;
        
        Id pricebookId = Test.getStandardPricebookId();
        
        Quote newQuoteRecord = new Quote();
        newQuoteRecord.Name = 'New Quote';
        newQuoteRecord.Bill_Type__c='Dual';
        newQuoteRecord.Price__c = pr.Id;
        newQuoteRecord.Pricebook2Id = pricebookId;
        newQuoteRecord.OpportunityId = opp.Id;
        
        insert newQuoteRecord;
        
      Test.StartTest();
       
		BrokerExceptionDataSchedule testsche = new BrokerExceptionDataSchedule();
		String sch = '0 15 04 ? * 3';
		system.schedule('Test status Check', sch, testsche );
		Test.stopTest();  
    }

}