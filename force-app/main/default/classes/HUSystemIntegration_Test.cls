@isTest
public class HUSystemIntegration_Test {
    
    
   /*  static void setupData(){
        
         Account brokerAcc = new Account(Name = 'Account Test');
        brokerAcc.RecordTypeId = [SELECT Id, Name, DeveloperName FROM RecordType where DeveloperName = 'Broker'].Id;
        insert brokerAcc;
        
        Account utilityAcc = new Account(Name = 'Account Test');
        utilityAcc.RecordTypeId = [SELECT Id, Name, DeveloperName FROM RecordType where DeveloperName = 'Utility'].Id;
        insert utilityAcc;
            
        
        
         Id recordTypeCus = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Customer').getRecordTypeId();
        Account CusAcc= new Account();
        CusAcc.Name = 'Test Acc1';
        CusAcc.RecordTypeId =recordTypeCus;
        //CusAcc.EXPRN__Exp_Business__c = expObj.Id;
        CusAcc.Customer_Credit_Limit__c =10000;
        insert CusAcc;
        
        Utility_Account__c objUA = new Utility_Account__c();
        objUA.Account__c = CusAcc.Id;
        objUA.Annual_Usage_kWh__c = 1000;
        //objUA.Credit_Limit__c = 1500;
        objUA.Name = '1234567890';
        objUA.Utility__c = utilityAcc.Id;
        objUA.Street__c = 'Street';
        objUA.City__c = 'City';
        objUA.State__c = 'NY';
        objUA.Country__c = 'US';
        objUA.Zip__c = '123456';
        Insert objUA;
        
        
        EXPRN__Exp_Business_Info__c expBusinessInfo = new EXPRN__Exp_Business_Info__c();
        expBusinessInfo.EXPRN__Tax_Lien_filings__c = '27';
        expBusinessInfo.EXPRN__Judgment_filings__c	 = '20';
        expBusinessInfo.EXPRN__Bankruptcy__c = 'Yes';
        expBusinessInfo.EXPRN__Experian_Bankruptcy_Count__c = ''; 
        expBusinessInfo.EXPRN__Experian_Lien_Bal__c = '';
        expBusinessInfo.EXPRN__Experian_Judgment_Bal__c = '';
        expBusinessInfo.EXPRN__UCC_filings__c = '';
        expBusinessInfo.EXPRN__All_Collections_Count__c = '';
        expBusinessInfo.EXPRN__All_collections_147__c = '';
        expBusinessInfo.EXPRN__Account_Name__c=CusAcc.Id;
        insert expBusinessInfo;
        
        Contract objCon = new Contract();
        objCon.ContractTerm = 4;
        objCon.StartDate = system.today().addMonths(-1);
        objCon.AccountId = CusAcc.Id;
        //objCon.Status = 'Draft';
        //insert objCon;
        
        Contact objContact = new Contact();
        //objContact.LastName = 'Test Lastname';
        objContact.firstName = 'Pricing';
        objContact.lastName ='Team';
        objContact.AccountId = CusAcc.Id;
        objContact.Phone = '1234567890';
        insert objContact;
        
        CusAcc.Primary_Contact__c = objContact.Id;
        update CusAcc;
        
        
        Opportunity objOpp = new Opportunity();
        objOpp.AccountId = CusAcc.Id;
        objOpp.ContractId = objCon.Id;
        objOpp.Name = 'Oppo Test';
        objOpp.StageName = 'New';
        objOpp.CloseDate = system.today().addMonths(1);
        objOpp.Broker__c = brokerAcc.id;
        objOpp.ContactId = objContact.Id;
        insert objOpp;
        
        
        
        Pricing_Request__c objPR1 = new Pricing_Request__c();
        objPR1.Opportunity__c = objOpp.Id;
        objPR1.Start_Date__c = System.today();
        objPR1.Record_Created__c = true;
        objPR1.Customer__c = CusAcc.Id;
        objPR1.Bill_Type__c = 'Dual';
       // objPR1.Credit_details__c = creditCheckRecord.Id;
        Insert objPR1;
    
     }   */
    

  @isTest
    static void Method(){
        
         Account brokerAcc = new Account(Name = 'Account Test');
        brokerAcc.RecordTypeId = [SELECT Id, Name, DeveloperName FROM RecordType where DeveloperName = 'Broker'].Id;
        insert brokerAcc;
        
        Account utilityAcc = new Account(Name = 'Account Test');
        utilityAcc.RecordTypeId = [SELECT Id, Name, DeveloperName FROM RecordType where DeveloperName = 'Utility'].Id;
        insert utilityAcc;
            
        
        
         Id recordTypeCus = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Customer').getRecordTypeId();
        Account CusAcc= new Account();
        CusAcc.Name = 'Test Acc1';
        CusAcc.RecordTypeId =recordTypeCus;
        //CusAcc.EXPRN__Exp_Business__c = expObj.Id;
        CusAcc.Customer_Credit_Limit__c =10000;
        insert CusAcc;
        
        Utility_Account__c objUA = new Utility_Account__c();
        objUA.Account__c = CusAcc.Id;
        objUA.Annual_Usage_kWh__c = 1000;
        //objUA.Credit_Limit__c = 1500;
        objUA.Name = '1234567890';
        objUA.Utility__c = utilityAcc.Id;
        objUA.Street__c = 'Street';
        objUA.City__c = 'City';
        objUA.State__c = 'NY';
        objUA.Country__c = 'US';
        objUA.Zip__c = '123456';
        Insert objUA;
        
        
        EXPRN__Exp_Business_Info__c expBusinessInfo = new EXPRN__Exp_Business_Info__c();
        expBusinessInfo.EXPRN__Tax_Lien_filings__c = '27';
        expBusinessInfo.EXPRN__Judgment_filings__c	 = '20';
        expBusinessInfo.EXPRN__Bankruptcy__c = 'Yes';
        expBusinessInfo.EXPRN__Experian_Bankruptcy_Count__c = ''; 
        expBusinessInfo.EXPRN__Experian_Lien_Bal__c = '';
        expBusinessInfo.EXPRN__Experian_Judgment_Bal__c = '';
        expBusinessInfo.EXPRN__UCC_filings__c = '';
        expBusinessInfo.EXPRN__All_Collections_Count__c = '';
        expBusinessInfo.EXPRN__All_collections_147__c = '';
        expBusinessInfo.EXPRN__Account_Name__c=CusAcc.Id;
        insert expBusinessInfo;
        
        Contract objCon = new Contract();
        objCon.ContractTerm = 4;
        objCon.StartDate = system.today().addMonths(-1);
        objCon.AccountId = CusAcc.Id;
        //objCon.Status = 'Draft';
        //insert objCon;
        
        Contact objContact = new Contact();
        //objContact.LastName = 'Test Lastname';
        objContact.firstName = 'Pricing';
        objContact.lastName ='Team';
        objContact.AccountId = CusAcc.Id;
        objContact.Phone = '1234567890';
        insert objContact;
        
        CusAcc.Primary_Contact__c = objContact.Id;
        update CusAcc;
        
        
        Opportunity objOpp = new Opportunity();
        objOpp.AccountId = CusAcc.Id;
        objOpp.ContractId = objCon.Id;
        objOpp.Name = 'Oppo Test';
        objOpp.StageName = 'New';
        objOpp.CloseDate = system.today().addMonths(1);
        objOpp.Broker__c = brokerAcc.id;
        objOpp.ContactId = objContact.Id;
        insert objOpp;
        
        
        
        Pricing_Request__c objPR1 = new Pricing_Request__c();
        objPR1.Opportunity__c = objOpp.Id;
        objPR1.Start_Date__c = System.today();
        objPR1.Record_Created__c = true;
        objPR1.Customer__c = CusAcc.Id;
        objPR1.Bill_Type__c = 'Dual';
       // objPR1.Credit_details__c = creditCheckRecord.Id;
        Insert objPR1;
        
        Credit_Check__c creditCheckRecord = new Credit_Check__c(Customer__c = CusAcc.Id,Pricing_Request__c = objPR1.Id,
                                                                Opportunity__c = objOpp.Id, Status__c = 'New', 
                                                                Credit_Check_Outcome__C = 'Passed', FSR_Score__c = 19, IP_Score__c = 9,
                                                                Credit_Limit__c = 15000,Credit_Automation_Fail__c = false
                                                               );
        insert creditCheckRecord;

      /*  SELECT Id,Name,Name__c,Related_Record_Name__c,Related_Record_Id__c,Account__c FROM Process_Event__c 
            WHERE (Account__c =: PricingReq.Customer__c AND Related_Record_Name__c = null AND Related_Record_Id__c = null AND 
                   Name__c Like 'Process Credit from HU Data%') ORDER BY CreatedDate DESC */
        Process_Event__c proEv = new Process_Event__c();
        proEv.Name__c = 'Process Credit from HU Data';
        proEv.Related_Record_Name__c = Null;
        proEv.Account__c = CusAcc.Id;
        proEv.Related_Record_Id__c = null; 
        insert proEv;
        
        Test.startTest();

         RestRequest req = new RestRequest(); 
         RestResponse res = new RestResponse();

         req.requestURI = '/services/apexrest/processCreditFromHU';  //Request URL
         req.httpMethod = 'POST';//HTTP Request Type
         req.addHeader('Content-Type', 'application/json');
         String prName = objPR1.Name;
        
        Pricing_Request__c prq = [SELECT Id,Name FROM Pricing_Request__c LIMIT 1];
         req.requestBody= Blob.valueof('{"PricingRequest":"'+prq.Name+'"}');

         RestContext.request = req;
         RestContext.response= res;
          
        HUSystemIntegration.processCreditFromHU();
         //opportunityiWiseUpdate.fetchopportunity();
       Test.stopTest();
    }
    
    @isTest
    static void Method1(){
        
         Account brokerAcc = new Account(Name = 'Account Test');
        brokerAcc.RecordTypeId = [SELECT Id, Name, DeveloperName FROM RecordType where DeveloperName = 'Broker'].Id;
        insert brokerAcc;
        
        Account utilityAcc = new Account(Name = 'Account Test');
        utilityAcc.RecordTypeId = [SELECT Id, Name, DeveloperName FROM RecordType where DeveloperName = 'Utility'].Id;
        insert utilityAcc;

         Id recordTypeCus = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Customer').getRecordTypeId();
        Account CusAcc= new Account();
        CusAcc.Name = 'Test Acc1';
        CusAcc.RecordTypeId =recordTypeCus;
        //CusAcc.EXPRN__Exp_Business__c = expObj.Id;
        CusAcc.Customer_Credit_Limit__c =10000;
        insert CusAcc;
        
        Utility_Account__c objUA = new Utility_Account__c();
        objUA.Account__c = CusAcc.Id;
        objUA.Annual_Usage_kWh__c = 1000;
        //objUA.Credit_Limit__c = 1500;
        objUA.Name = '1234567890';
        objUA.Utility__c = utilityAcc.Id;
        objUA.Street__c = 'Street';
        objUA.City__c = 'City';
        objUA.State__c = 'NY';
        objUA.Country__c = 'US';
        objUA.Zip__c = '123456';
        Insert objUA;
        
        
        EXPRN__Exp_Business_Info__c expBusinessInfo = new EXPRN__Exp_Business_Info__c();
        expBusinessInfo.EXPRN__Tax_Lien_filings__c = '27';
        expBusinessInfo.EXPRN__Judgment_filings__c	 = '20';
        expBusinessInfo.EXPRN__Bankruptcy__c = 'Yes';
        expBusinessInfo.EXPRN__Experian_Bankruptcy_Count__c = ''; 
        expBusinessInfo.EXPRN__Experian_Lien_Bal__c = '';
        expBusinessInfo.EXPRN__Experian_Judgment_Bal__c = '';
        expBusinessInfo.EXPRN__UCC_filings__c = '';
        expBusinessInfo.EXPRN__All_Collections_Count__c = '';
        expBusinessInfo.EXPRN__All_collections_147__c = '';
        expBusinessInfo.EXPRN__Account_Name__c=CusAcc.Id;
        insert expBusinessInfo;
        
        Contract objCon = new Contract();
        objCon.ContractTerm = 4;
        objCon.StartDate = system.today().addMonths(-1);
        objCon.AccountId = CusAcc.Id;
        //objCon.Status = 'Draft';
        //insert objCon;
        
        Contact objContact = new Contact();
        //objContact.LastName = 'Test Lastname';
        objContact.firstName = 'Pricing';
        objContact.lastName ='Team';
        objContact.AccountId = CusAcc.Id;
        objContact.Phone = '1234567890';
        insert objContact;
        
        CusAcc.Primary_Contact__c = objContact.Id;
        update CusAcc;
        
        
        Opportunity objOpp = new Opportunity();
        objOpp.AccountId = CusAcc.Id;
        objOpp.ContractId = objCon.Id;
        objOpp.Name = 'Oppo Test';
        objOpp.StageName = 'New';
        objOpp.CloseDate = system.today().addMonths(1);
        objOpp.Broker__c = brokerAcc.id;
        objOpp.ContactId = objContact.Id;
        insert objOpp;
        
        
        
        Pricing_Request__c objPR1 = new Pricing_Request__c();
        objPR1.Opportunity__c = objOpp.Id;
        objPR1.Start_Date__c = System.today();
        objPR1.Record_Created__c = true;
        objPR1.Customer__c = CusAcc.Id;
        objPR1.Bill_Type__c = 'Dual';
       // objPR1.Credit_details__c = creditCheckRecord.Id;
        Insert objPR1;
        
        Credit_Check__c creditCheckRecord = new Credit_Check__c(Customer__c = CusAcc.Id,Pricing_Request__c = objPR1.Id,
                                                                Opportunity__c = objOpp.Id, Status__c = 'New', 
                                                                Credit_Check_Outcome__C = 'Pending', FSR_Score__c = 19, IP_Score__c = 9,
                                                                Credit_Limit__c = 15000,Credit_Automation_Fail__c = false
                                                               );
        insert creditCheckRecord;

      /*  SELECT Id,Name,Name__c,Related_Record_Name__c,Related_Record_Id__c,Account__c FROM Process_Event__c 
            WHERE (Account__c =: PricingReq.Customer__c AND Related_Record_Name__c = null AND Related_Record_Id__c = null AND 
                   Name__c Like 'Process Credit from HU Data%') ORDER BY CreatedDate DESC */
        Process_Event__c proEv = new Process_Event__c();
        proEv.Name__c = 'Process Credit from HU Data';
        proEv.Related_Record_Name__c = Null;
        proEv.Account__c = CusAcc.Id;
        proEv.Related_Record_Id__c = null; 
        insert proEv;
        
        Test.startTest();

         RestRequest req = new RestRequest(); 
         RestResponse res = new RestResponse();

         req.requestURI = '/services/apexrest/processCreditFromHU';  //Request URL
         req.httpMethod = 'POST';//HTTP Request Type
         req.addHeader('Content-Type', 'application/json');
         String prName = objPR1.Name;
        
        Pricing_Request__c prq = [SELECT Id,Name FROM Pricing_Request__c LIMIT 1];
         req.requestBody= Blob.valueof('{"PricingRequest":"'+prq.Name+'"}');

         RestContext.request = req;
         RestContext.response= res;
          
        HUSystemIntegration.processCreditFromHU();
         //opportunityiWiseUpdate.fetchopportunity();
       Test.stopTest();
    }

}