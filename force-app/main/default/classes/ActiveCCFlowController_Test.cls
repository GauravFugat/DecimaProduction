@isTest
public class ActiveCCFlowController_Test {
   public static testMethod void setupMethod(){
        
        List<Id> enrollmentRecIdVal = new List<Id>();
        HU_Api_Call__c huObj = new HU_Api_Call__c();
        huObj.Call_AWS__c = true;
        huObj.Call_Azure__c = true;
        insert huObj;
       
       Marketer__c getMarketer = new Marketer__c(name = 'xyz', MarketerDunsNumber__c = 'ten');
        Insert getMarketer;
       
       
        
        
        Experian__c expObj = new Experian__c();
        expObj.Auth_Body__c = 'a';
        expObj.Auth_URL__c ='b';
        expObj.Auto_Search_URL__c='a';
        expObj.Auth_Body__c = 'test';
        expObj.Subcode__c = '01';
        insert expObj;
        
        Account objAcc = new Account(Name = 'Account Test');
        objAcc.RecordTypeId = [SELECT Id, Name, DeveloperName FROM RecordType where DeveloperName = 'Utility'].Id;
        insert objAcc;
        
        Contract objCon = new Contract();
        objCon.ContractTerm = 4;
        objCon.StartDate = system.today().addMonths(-1);
        objCon.AccountId = objAcc.Id;
        //objCon.Status = 'Draft';
        //insert objCon;
        
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
        Insert objUA;
        
        Pricing_Request__c objPR = new Pricing_Request__c();
        objPR.Opportunity__c = objOpp.Id;
        objPR.Start_Date__c = System.today();
        Insert objPR;
        
        Utility_Account_Pricing__c objUAP = new Utility_Account_Pricing__c();
        objUAP.Utility_Account__c = objUA.Id;
        objUAP.Pricing_Request__c = objPR.Id;
        objUAP.Start_Date__c = System.today();
        Insert objUAP;  
        
        Credit_Check__c creditCheckRecord = new Credit_Check__c(Customer__c = objAcc.Id,Pricing_REquest__c = objPR.Id, Opportunity__c = objOpp.Id, Status__c = 'Active', Credit_Check_Outcome__C = 'Passed', FSR_Score__c = 19, IP_Score__c = 9);
        Insert creditCheckRecord;
        
        Credit_Check__c creditCheckRecord2 = new Credit_Check__c(Customer__c = objAcc.Id,Pricing_REquest__c = objPR.Id, Opportunity__c = objOpp.Id, Status__c = 'Active', Credit_Check_Outcome__C = 'Passed', FSR_Score__c = 19, IP_Score__c = 9);
        Insert creditCheckRecord2;
        
        Credit_Check__c creditCheckRecord3 = new Credit_Check__c(Customer__c = objAcc.Id,Pricing_REquest__c = objPR.Id, Opportunity__c = objOpp.Id, Status__c = 'Active', Credit_Check_Outcome__C = 'Passed', FSR_Score__c = 19, IP_Score__c = 9);
        Insert creditCheckRecord3;
       Pricing_Request__c objPR1 = new Pricing_Request__c();
        objPR1.Opportunity__c = objOpp.Id;
        objPR1.Start_Date__c = System.today();
    	objPR1.Credit_Details__c = creditCheckRecord3.Id;
        Insert objPR1; 
       
        List<Id> prIds = new List<Id>();
        prIds.add(objPR.Id);
         test.startTest();
        //Call HttpCalloutMock
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorExperian());
        ActiveCCFlowController.getPremiums(creditCheckRecord.Id);
        ActiveCCFlowController.getPremiums1(objPR.Id);
        HUDataRequestAPI.CallMakeCallout(prIds);
        ActiveCCFlowController.getPremiums(creditCheckRecord2.Id);
        ActiveCCFlowController.getPremiums(creditCheckRecord3.Id);
        test.stopTest();
    }
public static testMethod void setupMethod1(){
        
        List<Id> enrollmentRecIdVal = new List<Id>();
        HU_Api_Call__c huObj = new HU_Api_Call__c();
        huObj.Call_AWS__c = true;
        huObj.Call_Azure__c = true;
        insert huObj;
    
    	Marketer__c getMarketer = new Marketer__c(name = 'xyz', MarketerDunsNumber__c = 'ten');
        Insert getMarketer;
        
        
        Experian__c expObj = new Experian__c();
        expObj.Auth_Body__c = 'a';
        expObj.Auth_URL__c ='b';
        expObj.Auto_Search_URL__c='a';
        expObj.Auth_Body__c = 'test';
        expObj.Subcode__c = '01';
        insert expObj;
        
        Account objAcc = new Account(Name = 'Account Test');
        objAcc.RecordTypeId = [SELECT Id, Name, DeveloperName FROM RecordType where DeveloperName = 'Utility'].Id;
        insert objAcc;
        
        Contract objCon = new Contract();
        objCon.ContractTerm = 4;
        objCon.StartDate = system.today().addMonths(-1);
        objCon.AccountId = objAcc.Id;
        //objCon.Status = 'Draft';
       // insert objCon;
        
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
        Insert objUA;
        
        Pricing_Request__c objPR = new Pricing_Request__c();
        objPR.Opportunity__c = objOpp.Id;
        objPR.Start_Date__c = System.today();
        Insert objPR;
        
        Utility_Account_Pricing__c objUAP = new Utility_Account_Pricing__c();
        objUAP.Utility_Account__c = objUA.Id;
        objUAP.Pricing_Request__c = objPR.Id;
        objUAP.Start_Date__c = System.today();
        Insert objUAP;  
        
        Credit_Check__c creditCheckRecord = new Credit_Check__c(Customer__c = objAcc.Id,Pricing_REquest__c = objPR.Id, Opportunity__c = objOpp.Id, Status__c = 'Active', Credit_Check_Outcome__C = 'Passed', FSR_Score__c = 20, IP_Score__c = 20);
        Insert creditCheckRecord;
        
        Credit_Check__c creditCheckRecord2 = new Credit_Check__c(Customer__c = objAcc.Id,Pricing_REquest__c = objPR.Id, Opportunity__c = objOpp.Id, Status__c = 'Active', Credit_Check_Outcome__C = 'Passed', FSR_Score__c = 20, IP_Score__c = 20);
        Insert creditCheckRecord2;
        
        Credit_Check__c creditCheckRecord3 = new Credit_Check__c(Customer__c = objAcc.Id,Pricing_REquest__c = objPR.Id, Opportunity__c = objOpp.Id, Status__c = 'Active', Credit_Check_Outcome__C = 'Passed', FSR_Score__c = 20, IP_Score__c =20);
        Insert creditCheckRecord3;

    Pricing_Request__c objPR1 = new Pricing_Request__c();
        objPR1.Opportunity__c = objOpp.Id;
        objPR1.Start_Date__c = System.today();
    	objPR1.Credit_Details__c = creditCheckRecord3.Id;
        Insert objPR1;
    
        List<Id> prIds = new List<Id>();
        prIds.add(objPR.Id);
    Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorExperian());
         test.startTest();
        //Call HttpCalloutMock
        
       
        ActiveCCFlowController.getPremiums(creditCheckRecord.Id);
        ActiveCCFlowController.getPremiums1(objPR.Id);
        HUDataRequestAPI.CallMakeCallout(prIds);
        ActiveCCFlowController.getPremiums(creditCheckRecord2.Id);
        ActiveCCFlowController.getPremiums(creditCheckRecord3.Id);
        test.stopTest();
    }
public static testMethod void setupMethod2(){
        
        List<Id> enrollmentRecIdVal = new List<Id>();
        HU_Api_Call__c huObj = new HU_Api_Call__c();
        huObj.Call_AWS__c = true;
        huObj.Call_Azure__c = true;
        insert huObj;
    
    	Marketer__c getMarketer = new Marketer__c(name = 'xyz', MarketerDunsNumber__c = 'ten');
        Insert getMarketer;
        
        
        Experian__c expObj = new Experian__c();
        expObj.Auth_Body__c = 'a';
        expObj.Auth_URL__c ='b';
        expObj.Auto_Search_URL__c='a';
        expObj.Auth_Body__c = 'test';
        expObj.Subcode__c = '01';
        insert expObj;
        
        Account objAcc = new Account(Name = 'Account Test');
        objAcc.RecordTypeId = [SELECT Id, Name, DeveloperName FROM RecordType where DeveloperName = 'Utility'].Id;
        insert objAcc;
        
        Contract objCon = new Contract();
        objCon.ContractTerm = 4;
        objCon.StartDate = system.today().addMonths(-1);
        objCon.AccountId = objAcc.Id;
        //objCon.Status = 'Draft';
        //insert objCon;
        
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
        Insert objUA;
        
        Pricing_Request__c objPR = new Pricing_Request__c();
        objPR.Opportunity__c = objOpp.Id;
        objPR.Start_Date__c = System.today();
        Insert objPR;
        
        Utility_Account_Pricing__c objUAP = new Utility_Account_Pricing__c();
        objUAP.Utility_Account__c = objUA.Id;
        objUAP.Pricing_Request__c = objPR.Id;
        objUAP.Start_Date__c = System.today();
        Insert objUAP;  
        
        Credit_Check__c creditCheckRecord = new Credit_Check__c(Customer__c = objAcc.Id,Pricing_REquest__c = objPR.Id, Opportunity__c = objOpp.Id, Status__c = 'Active', Credit_Check_Outcome__C = 'Passed', FSR_Score__c = 60, IP_Score__c = 60);
        Insert creditCheckRecord;
        
        Credit_Check__c creditCheckRecord2 = new Credit_Check__c(Customer__c = objAcc.Id,Pricing_REquest__c = objPR.Id, Opportunity__c = objOpp.Id, Status__c = 'Active', Credit_Check_Outcome__C = 'Passed', FSR_Score__c = 60, IP_Score__c = 60);
        Insert creditCheckRecord2;
        
        Credit_Check__c creditCheckRecord3 = new Credit_Check__c(Customer__c = objAcc.Id,Pricing_REquest__c = objPR.Id, Opportunity__c = objOpp.Id, Status__c = 'Active', Credit_Check_Outcome__C = 'Passed', FSR_Score__c = 60, IP_Score__c = 60);
        Insert creditCheckRecord3;
        
    Pricing_Request__c objPR1 = new Pricing_Request__c();
        objPR1.Opportunity__c = objOpp.Id;
        objPR1.Start_Date__c = System.today();
    	objPR1.Credit_Details__c = creditCheckRecord3.Id;
        Insert objPR1;
    
        List<Id> prIds = new List<Id>();
        prIds.add(objPR.Id);
         test.startTest();
        //Call HttpCalloutMock
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorExperian());
        ActiveCCFlowController.getPremiums(creditCheckRecord.Id);
        ActiveCCFlowController.getPremiums1(objPR.Id);
        HUDataRequestAPI.CallMakeCallout(prIds);
        ActiveCCFlowController.getPremiums(creditCheckRecord2.Id);
        ActiveCCFlowController.getPremiums(creditCheckRecord3.Id);
        test.stopTest();
    }
public static testMethod void setupMethod3(){
        
        List<Id> enrollmentRecIdVal = new List<Id>();
        HU_Api_Call__c huObj = new HU_Api_Call__c();
        huObj.Call_AWS__c = true;
        huObj.Call_Azure__c = true;
        insert huObj;
    
    	Marketer__c getMarketer = new Marketer__c(name = 'xyz', MarketerDunsNumber__c = 'ten');
        Insert getMarketer;
        
        
        Experian__c expObj = new Experian__c();
        expObj.Auth_Body__c = 'a';
        expObj.Auth_URL__c ='b';
        expObj.Auto_Search_URL__c='a';
        expObj.Auth_Body__c = 'test';
        expObj.Subcode__c = '01';
        insert expObj;
        
        Account objAcc = new Account(Name = 'Account Test');
        objAcc.RecordTypeId = [SELECT Id, Name, DeveloperName FROM RecordType where DeveloperName = 'Utility'].Id;
        insert objAcc;
        
        Contract objCon = new Contract();
        objCon.ContractTerm = 4;
        objCon.StartDate = system.today().addMonths(-1);
        objCon.AccountId = objAcc.Id;
        //objCon.Status = 'Draft';
        //insert objCon;
        
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
        Insert objUA;
        
        Pricing_Request__c objPR = new Pricing_Request__c();
        objPR.Opportunity__c = objOpp.Id;
        objPR.Start_Date__c = System.today();
        Insert objPR;
        
        Utility_Account_Pricing__c objUAP = new Utility_Account_Pricing__c();
        objUAP.Utility_Account__c = objUA.Id;
        objUAP.Pricing_Request__c = objPR.Id;
        objUAP.Start_Date__c = System.today();
        Insert objUAP;  
        
        Credit_Check__c creditCheckRecord = new Credit_Check__c(Customer__c = objAcc.Id,Pricing_REquest__c = objPR.Id, Opportunity__c = objOpp.Id, Status__c = 'Active', Credit_Check_Outcome__C = 'Passed', FSR_Score__c = 50, IP_Score__c = 60);
        Insert creditCheckRecord;
        
        Credit_Check__c creditCheckRecord2 = new Credit_Check__c(Customer__c = objAcc.Id,Pricing_REquest__c = objPR.Id, Opportunity__c = objOpp.Id, Status__c = 'Active', Credit_Check_Outcome__C = 'Passed', FSR_Score__c = 50, IP_Score__c = 60);
        Insert creditCheckRecord2;
        
        Credit_Check__c creditCheckRecord3 = new Credit_Check__c(Customer__c = objAcc.Id,Pricing_REquest__c = objPR.Id, Opportunity__c = objOpp.Id, Status__c = 'Active', Credit_Check_Outcome__C = 'Passed', FSR_Score__c = 50, IP_Score__c = 60);
        Insert creditCheckRecord3;
        
    	Pricing_Request__c objPR1 = new Pricing_Request__c();
        objPR1.Opportunity__c = objOpp.Id;
        objPR1.Start_Date__c = System.today();
    	objPR1.Credit_Details__c = creditCheckRecord3.Id;
        Insert objPR1;
    
        List<Id> prIds = new List<Id>();
        prIds.add(objPR.Id);
         test.startTest();
        //Call HttpCalloutMock
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorExperian());
        ActiveCCFlowController.getPremiums(creditCheckRecord.Id);
        ActiveCCFlowController.getPremiums1(objPR.Id);
        HUDataRequestAPI.CallMakeCallout(prIds);
        ActiveCCFlowController.getPremiums(creditCheckRecord2.Id);
        ActiveCCFlowController.getPremiums(creditCheckRecord3.Id);
        test.stopTest();
    }
public static testMethod void setupMethod4(){
        
        List<Id> enrollmentRecIdVal = new List<Id>();
        HU_Api_Call__c huObj = new HU_Api_Call__c();
        huObj.Call_AWS__c = true;
        huObj.Call_Azure__c = true;
        insert huObj;
    
    	Marketer__c getMarketer = new Marketer__c(name = 'xyz', MarketerDunsNumber__c = 'ten');
        Insert getMarketer;
        
        
        Experian__c expObj = new Experian__c();
        expObj.Auth_Body__c = 'a';
        expObj.Auth_URL__c ='b';
        expObj.Auto_Search_URL__c='a';
        expObj.Auth_Body__c = 'test';
        expObj.Subcode__c = '01';
        insert expObj;
        
        Account objAcc = new Account(Name = 'Account Test');
        objAcc.RecordTypeId = [SELECT Id, Name, DeveloperName FROM RecordType where DeveloperName = 'Utility'].Id;
        insert objAcc;
        
        Contract objCon = new Contract();
        objCon.ContractTerm = 4;
        objCon.StartDate = system.today().addMonths(-1);
        objCon.AccountId = objAcc.Id;
        //objCon.Status = 'Draft';
        //insert objCon;
        
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
        Insert objUA;
        
        Pricing_Request__c objPR = new Pricing_Request__c();
        objPR.Opportunity__c = objOpp.Id;
        objPR.Start_Date__c = System.today();
        Insert objPR;
        
        Utility_Account_Pricing__c objUAP = new Utility_Account_Pricing__c();
        objUAP.Utility_Account__c = objUA.Id;
        objUAP.Pricing_Request__c = objPR.Id;
        objUAP.Start_Date__c = System.today();
        Insert objUAP;  
        
        Credit_Check__c creditCheckRecord = new Credit_Check__c(Customer__c = objAcc.Id,Pricing_REquest__c = objPR.Id, Opportunity__c = objOpp.Id, Status__c = 'Active', Credit_Check_Outcome__C = 'Passed', FSR_Score__c = 80, IP_Score__c = 80);
        Insert creditCheckRecord;
        
        Credit_Check__c creditCheckRecord2 = new Credit_Check__c(Customer__c = objAcc.Id,Pricing_REquest__c = objPR.Id, Opportunity__c = objOpp.Id, Status__c = 'Active', Credit_Check_Outcome__C = 'Passed', FSR_Score__c = 80, IP_Score__c = 80);
        Insert creditCheckRecord2;
        
        Credit_Check__c creditCheckRecord3 = new Credit_Check__c(Customer__c = objAcc.Id,Pricing_REquest__c = objPR.Id, Opportunity__c = objOpp.Id, Status__c = 'Active', Credit_Check_Outcome__C = 'Passed', FSR_Score__c = 80, IP_Score__c = 80);
        Insert creditCheckRecord3;
        
    Pricing_Request__c objPR1 = new Pricing_Request__c();
        objPR1.Opportunity__c = objOpp.Id;
        objPR1.Start_Date__c = System.today();
    	objPR1.Credit_Details__c = creditCheckRecord3.Id;
        Insert objPR1;
    
        List<Id> prIds = new List<Id>();
        prIds.add(objPR.Id);
         test.startTest();
        //Call HttpCalloutMock
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorExperian());
        ActiveCCFlowController.getPremiums(creditCheckRecord.Id);
        ActiveCCFlowController.getPremiums1(objPR.Id);
        HUDataRequestAPI.CallMakeCallout(prIds);
        ActiveCCFlowController.getPremiums(creditCheckRecord2.Id);
        ActiveCCFlowController.getPremiums(creditCheckRecord3.Id);
        test.stopTest();
    }    
}