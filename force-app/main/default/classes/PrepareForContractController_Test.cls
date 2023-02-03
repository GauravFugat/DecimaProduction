@isTest
public class PrepareForContractController_Test {
    public static testMethod void setupMethod(){
        Trigger_Settings__c settings = new Trigger_Settings__c();
        settings.Name = 'QuoteLineItem_Trigger';
        settings.TriggerOn__c = false;
        insert settings;
        
        User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        System.runAs ( thisUser ) {
            EmailTemplate e = new EmailTemplate (developerName = 'Contract_Product_Details', FolderId = UserInfo.getUserId(), TemplateType= 'Text', Name = 'Contract Product Details');
            e.IsActive = true;
            Insert e;
        }
        //EmailTemplate emailTemp=[SELECT Id, Subject,body, htmlValue, name FROM EmailTemplate WHERE Name = 'Contract Product Details']; 
        //get standard pricebookId
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
        
        
        
        
        Opportunity objOpp = new Opportunity();
        objOpp.AccountId = objAcc.Id;
        //objOpp.ContractId = objCon.Id;
        objOpp.Name = 'Oppo Test';
        objOpp.StageName = 'New';
        objOpp.CloseDate = system.today().addMonths(1);
        objOpp.Broker__c = objAcc.id;
        objOpp.ContactId = objContact.Id;
        objOpp.AccountId=objAcc.Id;
        insert objOpp;
        
        Quote newQuoteRecord = new Quote();
        newQuoteRecord.Name = 'New Quote';
        newQuoteRecord.Pricebook2Id = pbk1.Id;
        newQuoteRecord.OpportunityId = objOpp.Id;
        newQuoteRecord.Start_Date__c = system.today();
        //newQuoteRecord.IsSyncing = true;
        insert newQuoteRecord;
        
        
        Pricing_Request__c prObj1= new Pricing_Request__c();
        prObj1.Bill_Type__c='UCB with Credit';
        prObj1.Invoice_Billing_Type__c='';
        prObj1.Product_Lookup__c= prod.Id;
        insert prObj1;
        
        Price__c pr1 = new Price__c();
        pr1.Price_Type__c = 'Quote';
        pr1.Opportunity__c = objOpp.Id;
        pr1.Pricing_Request__c = prObj1.Id;
        insert pr1;
        
        Quote qt = new Quote(Name='test quote',Price__c= pr1.id,OpportunityId=objOpp.id,Pricebook2Id = standardPb,Bill_Type__c=  'Dual'    );
        insert qt;
        
        
        QuoteLineItem qliliner = new QuoteLineItem(Revised_Sales_Margin_per_unit__c = 12,Total_Usage__c = 4,QuoteId=qt.id,PriceBookEntryID=pbe.id,Quantity=4, UnitPrice =pbe.UnitPrice);
        insert qliliner;
        
        Quote qtt = new Quote(Name='test quote',OpportunityId=objOpp.id,Pricebook2Id = standardPb,Bill_Type__c=  'UCB'    );
        insert qtt;
        
        PrepareForContractController.getQLIs(qt.Id, True);
        
        Credit_Check__c creadit = new Credit_Check__c();
        creadit.Customer__c = objAcc.Id;
        creadit.Credit_Check_Outcome__c ='Passed';
        insert creadit;
        // PrepareForContractController.getQLIs(qtt.Id, True);
        
        PrepareForContractController.getQuoteOptions(qt.OpportunityId);
        List<quotelineItem> quotelineItemlist = new List<quotelineItem>();
        quotelineItemlist.add(qliliner);
        PrepareForContractController.updateQuote(quotelineItemlist,'Prepayment');
        PrepareForContractController.getCustomerContacts(qt.OpportunityId);
        OpportunityContactRole ocr = new OpportunityContactRole();
        ocr.ContactId = objContact.Id;
        ocr.Role = 'Evaluator';
        ocr.OpportunityId = objOpp.Id;
        Insert ocr;
        
        PrepareForContractController.EtAttWrapper eatwr = new PrepareForContractController.EtAttWrapper(null, null, null, null, null );
        
        
        Blob b = Blob.valueOf('Test Data');
        Attachment attachment = new Attachment();
        attachment.ParentId = objOpp.Id;
        attachment.Name = 'Test Attachment for Parent';
        attachment.Body = b;
        Insert attachment;
        
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Penguins',
            PathOnClient = 'Penguins.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert contentVersion;
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
        //create ContentDocumentLink record
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = objOpp.id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        insert cdl;
        
        PrepareForContractController.updateContactRoles(objContact.Id, ocr, objOpp.Id, 'Evaluator');
        PrepareForContractController.updateContactRoles(objContact.Id, null, objOpp.Id, 'Evaluator');
        Test.startTest();
        PrepareForContractController.getEmailTemplate('Contract_Product_Details', objOpp.Id,1);
        Test.stopTest();
        PrepareForContractController.fetchLookUpValues('Test', 'User', objAcc.Id, true,'');
        PrepareForContractController.fetchLookUpValues('Test', 'Account', objAcc.Id, false,'Press');
        PrepareForContractController.fetchLookUpValues('Test', 'Contact', objAcc.Id, false,'');
        PrepareForContractController.getCreatedContact(objAcc.Id);
        PrepareForContractController.secondScreenExit(objOpp.Id, true, 'Prepayment');
        List<decimal> decimallist = new List<decimal>();
        decimallist.add(Decimal.valueOf('222'));
        PrepareForContractController.TotalPriceValidation(objOpp.Id,decimallist,qliliner);
        Quote qt1 = new Quote(Name='test quote1',Price__c= pr1.id,OpportunityId=objOpp.id,Pricebook2Id = standardPb,Bill_Type__c=  '	UCB with Credit'    );
        insert qt1;
        QuoteLineItem qliliner1 = new QuoteLineItem(Revised_Sales_Margin_per_unit__c = 12,Total_Usage__c = 4,QuoteId=qtt.id,PriceBookEntryID=pbe.id,Quantity=4, UnitPrice =pbe.UnitPrice);
        insert qliliner1;
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
        
        Utility_Account_Opportunity__c objUAO3 = new Utility_Account_Opportunity__c();
        objUAO3.Utility_Account__c = objUA.Id;
        objUAO3.Twelve_Month_Price__c = 1200;
        objUAO3.Opportunity__c = objOpp.Id;
        objUAO3.Status__c = 'Priced';
        objUAO3.Start_Date__c = system.today();
        //objUAO3.Utility__c= 'National Grid';
        insert objUAO3;
        PrepareForContractController.TotalPriceValidation(objOpp.Id,decimallist,qliliner1);
        PrepareForContractController.AllowNIMOValidation(objOpp.Id,decimallist,qliliner);
        PrepareForContractController.AllowNIMOValidation(objOpp.Id,decimallist,qliliner1);
        
        PrepareForContractController.Acc_contractValidation(objOpp.Id,'option1',true);
        List<String> toadds = new List<String>();
        toadds.add('test@test.com');
        List<String> ccAdds = new List<String>();
        ccAdds.add('test@test123.com');
        List<Id> addFiles = new List<Id>();
        addFiles.add(cdl.Id);
        PrepareForContractController.sendMailMethod(objOpp.Id, 'test', 'test', new List<ContentDocumentLink>{cdl}, toadds, ccAdds, addFiles);
        //PrepareForContractController.testcoveringMethod('etyt');
        //PrepareForContractController.testcoveringMethod1('etyt');
        PrepareForContractController.codeCover();
        
    }
}