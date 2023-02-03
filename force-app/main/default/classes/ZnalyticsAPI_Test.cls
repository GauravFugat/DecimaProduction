/*
* @Purpose: Test class to check the Functionality of znalyics API
* @Author: Akanksha Pandharkame
* @CreatedDate: 11/20/2019
* @Related Code: 
* @Test Class:
* @LastModifiedDate:
* @LastModifiedBy: Rahul Ghaytadak
*/

@isTest
public class ZnalyticsAPI_Test {
    
    public static testMethod void setupMethod(){
        
        List<Id> enrollmentRecIdVal = new List<Id>();
        
        Account objAcc = new Account(Name = 'Account Test',Utility_Short_Name__c='Test');
        objAcc.RecordTypeId = [SELECT Id, Name, DeveloperName FROM RecordType where DeveloperName = 'Utility'].Id;
        insert objAcc;
        
        Contract objCon = new Contract();
        objCon.ContractTerm = 4;
        objCon.StartDate = system.today().addMonths(-1);
        objCon.AccountId = objAcc.Id;
        //objCon.Status = 'Draft';
        objCon.ContractTerm=200;
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
        insert objOpp;
        
        Utility_Account__c objUA = new Utility_Account__c();
        objUA.Account__c = objAcc.Id;
        objUA.Name = '1234567890';
        objUA.Utility__c = objAcc.Id;
        objUA.Street__c = 'Street';
       // objUA.
        objUA.Zone__c='Test';
     //   objUA.Utility__r.Zip_4_Required__c=null;
        objUA.City__c = 'City';
        objUA.Utility__c=objAcc.Id;
     //   objUA.Utility__r.Utility_Short_Name__c='Test';
        objUA.State__c = 'NY';
        objUA.Country__c = 'US';
        objUA.Zip__c = '123456';
        insert objUA;
        
        Enrollment__c objEN = new Enrollment__c();
        objEN.Contract__c = objCon.Id;
        objEn.Account__c = objAcc.Id;
     /////==== check contract object this is formula field   objEn.Contract_Term__c='200.00';
		objEn.Contract__c=objCon.Id;
        insert objEN;
        
        Utility_Account_Enrollment__c objUAE = new Utility_Account_Enrollment__c();
        objUAE.Enrollment__c = objEN.Id;
        objUAE.Utility_Account__c = objUA.Id;
        insert objUAE;
        List<Utility_Account_Enrollment__c> selectedUAEs = new List<Utility_Account_Enrollment__c>{objUAE};
        
        Utility_Account_Contract__c objUAC = new Utility_Account_Contract__c();
        objUAC.Utility_Account__c = objUA.Id;
        objUAC.Contract__c = objCon.Id;
        Insert objUAC;
        enrollmentRecIdVal.add(objEN.Id);
        
         Marketer__c getMarketer = new Marketer__c(name = 'xyz', MarketerDunsNumber__c = 'ten');
         Insert getMarketer;
        
        Program_Code__c prodcode = new Program_Code__c();
        prodcode.Commodity__c = 'Electric';
       	prodcode.Effective_Date__c = Date.newInstance(2022, 05, 12);
		prodcode.Rate__c =1200.00000;
       	prodcode.Service_Class__c='Group A';
        insert prodcode;
        
        //Call to StubDataApiRequest
        //Wrapper_Znalytics_Enrollment 
        //Call HttpCalloutMock
        Map<Id,Decimal> uaIdEnrollRateAmt = new Map<Id,Decimal>();
        uaIdEnrollRateAmt.put(objUA.id, 1200.00000);
       Map<Id,Id> uaeUaMap = new Map<Id,Id>();
        uaeUaMap.put(objUA.Id,objUAE.Id);
        
        String APIstring = '{"model":{"requestGuid":"b3ad8e43-be7e-4e1d-a190-81ec4651b109","isSucess":true,"enrollmentResultDetailList":[{"isSuccess":true,"customerId":398,"billingAccountId":434,"serviceAccountId":484,"customerProspectId":0,"billingAccountReferenceId":10001,"serviceAccountReferenceId":10001,"linkToBillingAccountNumber":"","enrollmentRequestDetailId":254,"customerNumber":"20-1000177","billingAccountNumber":"30-100000819","utilityAccountNumber":"1234567890"}],"enrollmentWarningList":null},"code":200,"messages":null}';

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        test.startTest();
        HttpRequestClassZnalyticsApi obj = new HttpRequestClassZnalyticsApi();
        String responseStr = obj.doPost('POST', APIstring);
        ////////////////////////////
        SubmitEnrollment.submitEnrollment(objEN.Id, selectedUAEs);
        SubmitEnrollment.getUAEs(objEN.Id);
        SubmitEnrollment.saveUAE(selectedUAEs);
        SubmitEnrollment.getProgramCodes(objEN.Id, new List<Id>{objUA.Id},uaIdEnrollRateAmt,uaeUaMap);
        test.stopTest();
    }
    
    
    public static testMethod void setupMethod2(){
        
           SubmitEnrollment_RenewalAPI.contractSegmentDetailList contDet = new SubmitEnrollment_RenewalAPI.contractSegmentDetailList();
		contDet.ContractSegmentDetailId = 5;
        contDet.rateAmount = 14.25;
       // Utility_Account_Enrollment__c uuae = [SELECT Id, Name FROM Utility_Account_Enrollment__c LIMIT 1];
       //String UAEString = '[{"attributes":{"type":"Utility_Account_Enrollment__c","url":"/services/data/v53.0/sobjects/Utility_Account_Enrollment__c/a1017000006C7ctAAC"},"Id":"a1017000006C7ctAAC","IsDeleted":false,"Name":"UAE-00000553","Enrollment__c":"a0z17000002G1zPAAS","Utility_Account__c":"a0J17000004It0tEAC","Rate_Schedule_Name__c":"test","Status__c":"Enrollment Request Pending","Bill_Type__c":"UtilityRateReady","Program_Code__c":"41/820","Start_Date__c":"2021-02-15","Hold_Reason_Code__c":"SCH","Hold_Transaction__c":true,"Effective_Date__c":"2021-01-05","Percentage__c":12,"Tax_Exempt_Certificate_Number__c":"10","Tax_Exempt_Code__c":"99","Tax_Exempt__c":true,"AutoSubmitFlag__c":false,"RateClass__c":"Custom Product","Category__c":"Undefined","Rate_Type__c":"Linked"}]';
       // String UAEString =  '[{"Name":"ABC","Tax_Exempt__c":"1312321","Bill_Type__c":"Enrollment Request Pending"}]';
       // SubmitEnrollment_RenewalAPI.callRenewalEndpoint(objEN.Id,UAEString);
        SubmitEnrollment_RenewalAPI.contractRateSchedule contsch = new SubmitEnrollment_RenewalAPI.contractRateSchedule();
        contsch.contractRateSegmentList =null;
		contsch.rateChangeEffectiveDate = String.valueOf(date.today());
        contsch.rateChangeScheduledDate = String.valueOf(date.today());
        contsch.rateScheduleName = 'Test';
        contsch.rolloverRateScheduleName = 'Test00';
        contsch.utilityRateCode = '10210';
        SubmitEnrollment_RenewalAPI.RenewalWrapper renwrap = new SubmitEnrollment_RenewalAPI.RenewalWrapper();
        renwrap.contractTerm = 2;
        renwrap.contractSignedDate = 'Test';
        renwrap.renewalDateOptionCode = 'Test1';
        renwrap.saleDetails = 'Test2';
        renwrap.previousContractNumber = 'Test3';
        renwrap.documentUrl = 'test4';
        renwrap.customerNumber = '123145';
        SubmitEnrollment_RenewalAPI.contractDetails contrdtl1 = new SubmitEnrollment_RenewalAPI.contractDetails();
        contrdtl1.commissionTypeCode = 'Test';
        contrdtl1.salesAgencyCode = 'Test1';
        contrdtl1.salesAgent = 'Test2';
        contrdtl1.brokerFee = 5;
        contrdtl1.salesAgentCode ='44';
        contrdtl1.channelFee = 4;
        contrdtl1.salesChannelCode = '444';
        contrdtl1.contractEndDate = '11/11/21';
        contrdtl1.salesChannelPartnerCode = '44';
        contrdtl1.contractStartDate = '12/12/21';
        contrdtl1.volumes = '44';
        contrdtl1.utilityAccountNumber = '123545645';
        contrdtl1.contractRateSchedule = null; 
        contrdtl1.contractNumber = '12';
    
        SubmitEnrollment_RenewalAPI.contractRateSegmentList contrSegLst = new SubmitEnrollment_RenewalAPI.contractRateSegmentList();
        contrSegLst.contractSegmentDetailList = null;
        List<Id> enrollmentRecIdVal = new List<Id>();
        
        Account objAcc = new Account(Name = 'Account Test');
        objAcc.RecordTypeId = [SELECT Id, Name, DeveloperName FROM RecordType where DeveloperName = 'Utility'].Id;
        insert objAcc;
        
        Contract objCon = new Contract();
        objCon.ContractTerm = 4;
        objCon.StartDate = system.today().addMonths(-3);
        objCon.AccountId = objAcc.Id;
        //objCon.Status = 'Draft';
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
        insert objOpp;
        
        Utility_Account__c objUA = new Utility_Account__c();
        objUA.Account__c = objAcc.Id;
        objUA.Name = '1234567890';
        objUA.Utility__c = objAcc.Id;
        //objUA.Utility__r.Bill_Type__c = 'Dual';
        objUA.Street__c = 'Street';
        objUA.City__c = 'City';
        objUA.State__c = 'NY';
        objUA.Country__c = 'US';
        objUA.Zip__c = '123456';
        objUA.Status__c = 'Never Supplied';
       // objUA.Commodity__c = 'Electricity';
        insert objUA;
        
        Enrollment__c objEN = new Enrollment__c();
        objEN.Contract__c = objCon.Id;
        //objEN.Invoice_Billing_Type__c = 'Summary Billing'; 
        objEn.Account__c = objAcc.Id;
        insert objEN;
        
        Utility_Account_Enrollment__c objUAE = new Utility_Account_Enrollment__c();
        objUAE.Tax_Exempt__c = true;
        objUAE.Enrollment__c = objEN.Id;
        objUAE.Utility_Account__c = objUA.Id;
         objUAE.Hold_Transaction__c = true;
		objUAE.Hold_Reason_Code__c = 'SCH';
        objUAE.Tax_Exempt__c = true;
        objUAE.Start_Date__c = Date.today();
        //objUAE.Utility_Account__r.Status__c = 'ACT';
        insert objUAE;
        List<Utility_Account_Enrollment__c> selectedUAEs = new List<Utility_Account_Enrollment__c>{objUAE};
        
        Utility_Account_Enrollment__c uae = new Utility_Account_Enrollment__c();
        uae.Enrollment__c = objEN.Id;
        uae.Utility_Account__c = objUA.Id;
        uae.Hold_Transaction__c = true;
		uae.Hold_Reason_Code__c = 'SCH';
        uae.Tax_Exempt__c = true;
        uae.Start_Date__c = Date.today();
        insert uae;
            
        Utility_Account_Contract__c objUAC = new Utility_Account_Contract__c();
        objUAC.Utility_Account__c = objUA.Id;
        objUAC.Contract__c = objCon.Id;
        Insert objUAC;
        enrollmentRecIdVal.add(objEN.Id);
        Marketer__c getMarketer = new Marketer__c(name = 'xyz', MarketerDunsNumber__c = 'ten');
            Insert getMarketer;
        
        Map<Id,Decimal> uaIdEnrollRateAmt = new Map<Id,Decimal>();
        uaIdEnrollRateAmt.put(objUA.id, 1200.00000); 
        Map<Id,Id> uaeUaMap = new Map<Id,Id>();
        uaeUaMap.put(objUA.Id,objUAE.Id);

        //Call to StubDataApiRequest
        //Wrapper_Znalytics_Enrollment 
        //Call HttpCalloutMock
        SubmitEnrollment.UAField uaf1 = new  SubmitEnrollment.UAField();
        uaf1.ITS_Tag = 'Test';
        uaf1.ITS_Tag_Future = 'Test2'; 
        uaf1.apacity_Tag ='Test3';
        uaf1.apacity_Tag_Future ='Test4';
        uaf1.apacity_Tag_Future1 ='Test4';
        uaf1.apacity_Tag_Future2 ='Test4';
        uaf1.apacity_Tag_Future3 = 'Test4';   
        String APIstring = '{"model":{"requestGuid":"b3ad8e43-be7e-4e1d-a190-81ec4651b109","isSucess":true,"enrollmentResultDetailList":[{"isSuccess":true,"customerId":398,"billingAccountId":434,"serviceAccountId":484,"customerProspectId":0,"billingAccountReferenceId":10001,"serviceAccountReferenceId":10001,"linkToBillingAccountNumber":"","enrollmentRequestDetailId":254,"customerNumber":"20-1000177","billingAccountNumber":"30-100000819","utilityAccountNumber":"1234567890"}],"enrollmentWarningList":null},"code":200,"messages":null}';
							
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        test.startTest();
        HttpRequestClassZnalyticsApi obj = new HttpRequestClassZnalyticsApi();
        String responseStr = obj.doPost('POST', APIstring);
         String UAEString = '[{"attributes":{"type":"Utility_Account_Enrollment__c","url":"/services/data/v53.0/sobjects/Utility_Account_Enrollment__c/a1017000006C7ctAAC"},"Id":"a1017000006C7ctAAC","IsDeleted":false,"Name":"UAE-00000553","Enrollment__c":"a0z17000002G1zPAAS","Utility_Account__c":"a0J17000004It0tEAC","Rate_Schedule_Name__c":"test","Status__c":"Enrollment Request Pending","Bill_Type__c":"UtilityRateReady","Program_Code__c":"41/820","Start_Date__c":"2021-02-15","Hold_Reason_Code__c":"SCH","Hold_Transaction__c":true,"Effective_Date__c":"2021-01-05","Percentage__c":12,"Tax_Exempt_Certificate_Number__c":"10","Tax_Exempt_Code__c":"99","Tax_Exempt__c":true,"AutoSubmitFlag__c":false,"RateClass__c":"Custom Product","Category__c":"Undefined","Rate_Type__c":"Linked"}]';
       // String UAEString =  '[{"Name":"ABC","Tax_Exempt__c":"1312321","Bill_Type__c":"Enrollment Request Pending"}]';
        SubmitEnrollment_RenewalAPI.callRenewalEndpoint(objEN.Id,UAEString);
        
        
        SubmitEnrollment.submitEnrollment(objEN.Id, selectedUAEs);
        SubmitEnrollment.getUAEs(objEN.Id);
        SubmitEnrollment.getDateSortedUAEs(objEN.Id,true,'Bill_Type__c');
        SubmitEnrollment.getDateSortedUAEs(objEN.Id,false,'Bill_Type__c');
        SubmitEnrollment.saveUAE(selectedUAEs);
        SubmitEnrollment.getProgramCodes(objEN.Id, new List<Id>{objUA.Id},uaIdEnrollRateAmt,uaeUaMap);
        SubmitEnrollment.callZnalyticsAPI(objEN.Id, selectedUAEs); 
        Utility_Account_Enrollment__c objUAE1 = new Utility_Account_Enrollment__c();
        objUAE1.Tax_Exempt__c = false;
        objUAE1.Enrollment__c = objEN.Id;
        objUAE1.Utility_Account__c = objUA.Id;
        //objUAE.Utility_Account__r.Status__c = 'ACT';
        insert objUAE1;
        List<Utility_Account_Enrollment__c> selectedUAEs1 = new List<Utility_Account_Enrollment__c>{objUAE1};
        SubmitEnrollment.callZnalyticsAPI(objEN.Id, selectedUAEs1); 
         list<String> SaleDetails =  new list<String>();
        SaleDetails.add('rtr');
 
     
    }
        public static testMethod void setupMethod3(){
        
           SubmitEnrollment_RenewalAPI.contractSegmentDetailList contDet = new SubmitEnrollment_RenewalAPI.contractSegmentDetailList();
		contDet.ContractSegmentDetailId = 5;
        contDet.rateAmount = 14.25;
       // Utility_Account_Enrollment__c uuae = [SELECT Id, Name FROM Utility_Account_Enrollment__c LIMIT 1];
       //String UAEString = '[{"attributes":{"type":"Utility_Account_Enrollment__c","url":"/services/data/v53.0/sobjects/Utility_Account_Enrollment__c/a1017000006C7ctAAC"},"Id":"a1017000006C7ctAAC","IsDeleted":false,"Name":"UAE-00000553","Enrollment__c":"a0z17000002G1zPAAS","Utility_Account__c":"a0J17000004It0tEAC","Rate_Schedule_Name__c":"test","Status__c":"Enrollment Request Pending","Bill_Type__c":"UtilityRateReady","Program_Code__c":"41/820","Start_Date__c":"2021-02-15","Hold_Reason_Code__c":"SCH","Hold_Transaction__c":true,"Effective_Date__c":"2021-01-05","Percentage__c":12,"Tax_Exempt_Certificate_Number__c":"10","Tax_Exempt_Code__c":"99","Tax_Exempt__c":true,"AutoSubmitFlag__c":false,"RateClass__c":"Custom Product","Category__c":"Undefined","Rate_Type__c":"Linked"}]';
       // String UAEString =  '[{"Name":"ABC","Tax_Exempt__c":"1312321","Bill_Type__c":"Enrollment Request Pending"}]';
       // SubmitEnrollment_RenewalAPI.callRenewalEndpoint(objEN.Id,UAEString);
        SubmitEnrollment_RenewalAPI.contractRateSchedule contsch = new SubmitEnrollment_RenewalAPI.contractRateSchedule();
        contsch.contractRateSegmentList =null;
		contsch.rateChangeEffectiveDate = String.valueOf(date.today());
        contsch.rateChangeScheduledDate = String.valueOf(date.today());
        contsch.rateScheduleName = 'Test';
        contsch.rolloverRateScheduleName = 'Test00';
        contsch.utilityRateCode = '10210';
        SubmitEnrollment_RenewalAPI.RenewalWrapper renwrap = new SubmitEnrollment_RenewalAPI.RenewalWrapper();
        renwrap.contractTerm = 2;
        renwrap.contractSignedDate = 'Test';
        renwrap.renewalDateOptionCode = 'Test1';
        renwrap.saleDetails = 'Test2';
        renwrap.previousContractNumber = 'Test3';
        renwrap.documentUrl = 'test4';
        renwrap.customerNumber = '123145';
        SubmitEnrollment_RenewalAPI.contractDetails contrdtl1 = new SubmitEnrollment_RenewalAPI.contractDetails();
        contrdtl1.commissionTypeCode = 'Test';
        contrdtl1.salesAgencyCode = 'Test1';
        contrdtl1.salesAgent = 'Test2';
        contrdtl1.brokerFee = 5;
        contrdtl1.salesAgentCode ='44';
        contrdtl1.channelFee = 4;
        contrdtl1.salesChannelCode = '444';
        contrdtl1.contractEndDate = '11/11/21';
        contrdtl1.salesChannelPartnerCode = '44';
        contrdtl1.contractStartDate = '12/12/21';
        contrdtl1.volumes = '44';
        contrdtl1.utilityAccountNumber = '123545645';
        contrdtl1.contractRateSchedule = null; 
        contrdtl1.contractNumber = '12';
    
        SubmitEnrollment_RenewalAPI.contractRateSegmentList contrSegLst = new SubmitEnrollment_RenewalAPI.contractRateSegmentList();
        contrSegLst.contractSegmentDetailList = null;
        List<Id> enrollmentRecIdVal = new List<Id>();
        
        Account objAcc = new Account(Name = 'Account Test');
        objAcc.RecordTypeId = [SELECT Id, Name, DeveloperName FROM RecordType where DeveloperName = 'Utility'].Id;
        insert objAcc;
        
        Contract objCon = new Contract();
        objCon.ContractTerm = 4;
        objCon.StartDate = system.today().addMonths(5);
        objCon.AccountId = objAcc.Id;
        //objCon.Status = 'Draft';
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
        insert objOpp;
        
        Utility_Account__c objUA = new Utility_Account__c();
        objUA.Account__c = objAcc.Id;
        objUA.Name = '1234567890';
        objUA.Utility__c = objAcc.Id;
        //objUA.Utility__r.Bill_Type__c = 'Dual';
        objUA.Street__c = 'Street';
        objUA.City__c = 'City';
        objUA.State__c = 'NY';
        objUA.Country__c = 'US';
        objUA.Zip__c = '123456';
        objUA.Status__c = 'Never Supplied';
       // objUA.Commodity__c = 'Electricity';
        insert objUA;
        
        Enrollment__c objEN = new Enrollment__c();
        objEN.Contract__c = objCon.Id;
        //objEN.Invoice_Billing_Type__c = 'Summary Billing'; 
        objEn.Account__c = objAcc.Id;
        insert objEN;
        
        Utility_Account_Enrollment__c objUAE = new Utility_Account_Enrollment__c();
        objUAE.Tax_Exempt__c = true;
        objUAE.Enrollment__c = objEN.Id;
        objUAE.Utility_Account__c = objUA.Id;
         objUAE.Hold_Transaction__c = true;
		objUAE.Hold_Reason_Code__c = 'SCH';
        objUAE.Tax_Exempt__c = true;
        objUAE.Start_Date__c = Date.today();
        //objUAE.Utility_Account__r.Status__c = 'ACT';
        insert objUAE;
        List<Utility_Account_Enrollment__c> selectedUAEs = new List<Utility_Account_Enrollment__c>{objUAE};
        
        Utility_Account_Enrollment__c uae = new Utility_Account_Enrollment__c();
        uae.Enrollment__c = objEN.Id;
        uae.Utility_Account__c = objUA.Id;
        uae.Hold_Transaction__c = true;
		uae.Hold_Reason_Code__c = 'SCH';
        uae.Tax_Exempt__c = true;
        uae.Start_Date__c = Date.today();
        insert uae;
            
        Utility_Account_Contract__c objUAC = new Utility_Account_Contract__c();
        objUAC.Utility_Account__c = objUA.Id;
        objUAC.Contract__c = objCon.Id;
        Insert objUAC;
        enrollmentRecIdVal.add(objEN.Id);
        Marketer__c getMarketer = new Marketer__c(name = 'xyz', MarketerDunsNumber__c = 'ten');
            Insert getMarketer;
        
        Map<Id,Decimal> uaIdEnrollRateAmt = new Map<Id,Decimal>();
        uaIdEnrollRateAmt.put(objUA.id, 1200.00000); 
        Map<Id,Id> uaeUaMap = new Map<Id,Id>();
        uaeUaMap.put(objUA.Id,objUAE.Id);

        //Call to StubDataApiRequest
        //Wrapper_Znalytics_Enrollment 
        //Call HttpCalloutMock
        SubmitEnrollment.UAField uaf1 = new  SubmitEnrollment.UAField();
        uaf1.ITS_Tag = 'Test';
        uaf1.ITS_Tag_Future = 'Test2'; 
        uaf1.apacity_Tag ='Test3';
        uaf1.apacity_Tag_Future ='Test4';
        uaf1.apacity_Tag_Future1 ='Test4';
        uaf1.apacity_Tag_Future2 ='Test4';
        uaf1.apacity_Tag_Future3 = 'Test4';   
        String APIstring = '{"model":{"requestGuid":"b3ad8e43-be7e-4e1d-a190-81ec4651b109","isSucess":true,"enrollmentResultDetailList":[{"isSuccess":true,"customerId":398,"billingAccountId":434,"serviceAccountId":484,"customerProspectId":0,"billingAccountReferenceId":10001,"serviceAccountReferenceId":10001,"linkToBillingAccountNumber":"","enrollmentRequestDetailId":254,"customerNumber":"20-1000177","billingAccountNumber":"30-100000819","utilityAccountNumber":"1234567890"}],"enrollmentWarningList":null},"code":200,"messages":null}';
							
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        test.startTest();
        HttpRequestClassZnalyticsApi obj = new HttpRequestClassZnalyticsApi();
        String responseStr = obj.doPost('POST', APIstring);
         String UAEString = '[{"attributes":{"type":"Utility_Account_Enrollment__c","url":"/services/data/v53.0/sobjects/Utility_Account_Enrollment__c/a1017000006C7ctAAC"},"Id":"a1017000006C7ctAAC","IsDeleted":false,"Name":"UAE-00000553","Enrollment__c":"a0z17000002G1zPAAS","Utility_Account__c":"a0J17000004It0tEAC","Rate_Schedule_Name__c":"test","Status__c":"Enrollment Request Pending","Bill_Type__c":"UtilityRateReady","Program_Code__c":"41/820","Start_Date__c":"2021-02-15","Hold_Reason_Code__c":"SCH","Hold_Transaction__c":true,"Effective_Date__c":"2021-01-05","Percentage__c":12,"Tax_Exempt_Certificate_Number__c":"10","Tax_Exempt_Code__c":"99","Tax_Exempt__c":true,"AutoSubmitFlag__c":false,"RateClass__c":"Custom Product","Category__c":"Undefined","Rate_Type__c":"Linked"}]';
       // String UAEString =  '[{"Name":"ABC","Tax_Exempt__c":"1312321","Bill_Type__c":"Enrollment Request Pending"}]';
        SubmitEnrollment_RenewalAPI.callRenewalEndpoint(objEN.Id,UAEString);
        
            SubmitEnrollment.getHoldReasonPicValIntoList();
        SubmitEnrollment.submitEnrollment(objEN.Id, selectedUAEs);
        SubmitEnrollment.getUAEs(objEN.Id);
        SubmitEnrollment.getDateSortedUAEs(objEN.Id,true,'Bill_Type__c');
        SubmitEnrollment.getDateSortedUAEs(objEN.Id,false,'Bill_Type__c');
        SubmitEnrollment.saveUAE(selectedUAEs);
        SubmitEnrollment.getProgramCodes(objEN.Id, new List<Id>{objUA.Id},uaIdEnrollRateAmt,uaeUaMap);
        SubmitEnrollment.callZnalyticsAPI(objEN.Id, selectedUAEs); 
        Utility_Account_Enrollment__c objUAE1 = new Utility_Account_Enrollment__c();
        objUAE1.Tax_Exempt__c = false;
        objUAE1.Enrollment__c = objEN.Id;
        objUAE1.Utility_Account__c = objUA.Id;
        //objUAE.Utility_Account__r.Status__c = 'ACT';
        insert objUAE1;
        List<Utility_Account_Enrollment__c> selectedUAEs1 = new List<Utility_Account_Enrollment__c>{objUAE1};
        SubmitEnrollment.callZnalyticsAPI(objEN.Id, selectedUAEs1); 
         list<String> SaleDetails =  new list<String>();
        SaleDetails.add('rtr');
 
     
    }

	public static testMethod void setupMethod4(){
    	   
           SubmitEnrollment_RenewalAPI.contractSegmentDetailList contDet = new SubmitEnrollment_RenewalAPI.contractSegmentDetailList();
		contDet.ContractSegmentDetailId = 5;
        contDet.rateAmount = 14.25;
       // Utility_Account_Enrollment__c uuae = [SELECT Id, Name FROM Utility_Account_Enrollment__c LIMIT 1];
       //String UAEString = '[{"attributes":{"type":"Utility_Account_Enrollment__c","url":"/services/data/v53.0/sobjects/Utility_Account_Enrollment__c/a1017000006C7ctAAC"},"Id":"a1017000006C7ctAAC","IsDeleted":false,"Name":"UAE-00000553","Enrollment__c":"a0z17000002G1zPAAS","Utility_Account__c":"a0J17000004It0tEAC","Rate_Schedule_Name__c":"test","Status__c":"Enrollment Request Pending","Bill_Type__c":"UtilityRateReady","Program_Code__c":"41/820","Start_Date__c":"2021-02-15","Hold_Reason_Code__c":"SCH","Hold_Transaction__c":true,"Effective_Date__c":"2021-01-05","Percentage__c":12,"Tax_Exempt_Certificate_Number__c":"10","Tax_Exempt_Code__c":"99","Tax_Exempt__c":true,"AutoSubmitFlag__c":false,"RateClass__c":"Custom Product","Category__c":"Undefined","Rate_Type__c":"Linked"}]';
       // String UAEString =  '[{"Name":"ABC","Tax_Exempt__c":"1312321","Bill_Type__c":"Enrollment Request Pending"}]';
       // SubmitEnrollment_RenewalAPI.callRenewalEndpoint(objEN.Id,UAEString);
        SubmitEnrollment_RenewalAPI.contractRateSchedule contsch = new SubmitEnrollment_RenewalAPI.contractRateSchedule();
        contsch.contractRateSegmentList =null;
		contsch.rateChangeEffectiveDate = String.valueOf(date.today());
        contsch.rateChangeScheduledDate = String.valueOf(date.today());
        contsch.rateScheduleName = 'Test';
        contsch.rolloverRateScheduleName = 'Test00';
        contsch.utilityRateCode = '10210';
        SubmitEnrollment_RenewalAPI.RenewalWrapper renwrap = new SubmitEnrollment_RenewalAPI.RenewalWrapper();
        renwrap.contractTerm = 2;
        renwrap.contractSignedDate = 'Test';
        renwrap.renewalDateOptionCode = 'Test1';
        renwrap.saleDetails = 'Test2';
        renwrap.previousContractNumber = 'Test3';
        renwrap.documentUrl = 'test4';
        renwrap.customerNumber = '123145';
        SubmitEnrollment_RenewalAPI.contractDetails contrdtl1 = new SubmitEnrollment_RenewalAPI.contractDetails();
        contrdtl1.commissionTypeCode = 'Test';
        contrdtl1.salesAgencyCode = 'Test1';
        contrdtl1.salesAgent = 'Test2';
        contrdtl1.brokerFee = 5;
        contrdtl1.salesAgentCode ='44';
        contrdtl1.channelFee = 4;
        contrdtl1.salesChannelCode = '444';
        contrdtl1.contractEndDate = '11/11/21';
        contrdtl1.salesChannelPartnerCode = '44';
        contrdtl1.contractStartDate = '12/12/21';
        contrdtl1.volumes = '44';
        contrdtl1.utilityAccountNumber = '123545645';
        contrdtl1.contractRateSchedule = null; 
        contrdtl1.contractNumber = '12';
    
        SubmitEnrollment_RenewalAPI.contractRateSegmentList contrSegLst = new SubmitEnrollment_RenewalAPI.contractRateSegmentList();
        contrSegLst.contractSegmentDetailList = null;
        List<Id> enrollmentRecIdVal = new List<Id>();
        
        Account objAcc = new Account(Name = 'Account Test');
        objAcc.RecordTypeId = [SELECT Id, Name, DeveloperName FROM RecordType where DeveloperName = 'Utility'].Id;
        insert objAcc;
        
        Contract objCon = new Contract();
        objCon.ContractTerm = 4;
        objCon.StartDate = system.today().addMonths(5);
        objCon.AccountId = objAcc.Id;
        //objCon.Status = 'Draft';
        objCon.Total_Unit_Rate__c = 1200.00000;
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
        insert objOpp;
        
        Utility_Account__c objUA = new Utility_Account__c();
        objUA.Account__c = objAcc.Id;
        objUA.Name = '1234567890';
        objUA.Utility__c = objAcc.Id;
        //objUA.Utility__r.Bill_Type__c = 'Dual';
        objUA.Street__c = 'Street';
        objUA.City__c = 'City';
        objUA.State__c = 'NY';
        objUA.Country__c = 'US';
        objUA.Zip__c = '123456';
        objUA.Status__c = 'Never Supplied';
      //  objUA.Commodity__c = 'Electricity';
         objUA.Service_Class__c = 'Group A';
        insert objUA;
        
        Enrollment__c objEN = new Enrollment__c();
        objEN.Contract__c = objCon.Id;
        //objEN.Invoice_Billing_Type__c = 'Summary Billing'; 
        objEn.Account__c = objAcc.Id;
        insert objEN;
        
        Utility_Account_Enrollment__c objUAE = new Utility_Account_Enrollment__c();
        objUAE.Tax_Exempt__c = true;
        objUAE.Enrollment__c = objEN.Id;
        objUAE.Utility_Account__c = objUA.Id;
         objUAE.Hold_Transaction__c = true;
		objUAE.Hold_Reason_Code__c = 'SCH';
        objUAE.Tax_Exempt__c = true;
        objUAE.Start_Date__c = Date.today();
        //objUAE.Utility_Account__r.Status__c = 'ACT';
        insert objUAE;
        List<Utility_Account_Enrollment__c> selectedUAEs = new List<Utility_Account_Enrollment__c>{objUAE};
        
        Utility_Account_Enrollment__c uae = new Utility_Account_Enrollment__c();
        uae.Enrollment__c = objEN.Id;
        uae.Utility_Account__c = objUA.Id;
        uae.Hold_Transaction__c = true;
		uae.Hold_Reason_Code__c = 'SCH';
        uae.Tax_Exempt__c = true;
        uae.Start_Date__c = Date.today();
        insert uae;
            
        Utility_Account_Contract__c objUAC = new Utility_Account_Contract__c();
        objUAC.Utility_Account__c = objUA.Id;
        objUAC.Contract__c = objCon.Id;
        Insert objUAC;
        enrollmentRecIdVal.add(objEN.Id);
        Marketer__c getMarketer = new Marketer__c(name = 'xyz', MarketerDunsNumber__c = 'ten');
            Insert getMarketer;
        
         Program_Code__c prodcode = new Program_Code__c();
        prodcode.Commodity__c = 'Electric';
       	prodcode.Effective_Date__c = Date.newInstance(2022, 05, 12);
		prodcode.Rate__c =1200.00000;
       	prodcode.Service_Class__c='Group A';
        insert prodcode;
        
        
       
        //Call to StubDataApiRequest
        //Wrapper_Znalytics_Enrollment 
        //Call HttpCalloutMock
        SubmitEnrollment.UAField uaf1 = new  SubmitEnrollment.UAField();
        uaf1.ITS_Tag = 'Test';
        uaf1.ITS_Tag_Future = 'Test2'; 
        uaf1.apacity_Tag ='Test3';
        uaf1.apacity_Tag_Future ='Test4';
        uaf1.apacity_Tag_Future1 ='Test4';
        uaf1.apacity_Tag_Future2 ='Test4';
        uaf1.apacity_Tag_Future3 = 'Test4';   
        String APIstring = '{"model":{"requestGuid":"b3ad8e43-be7e-4e1d-a190-81ec4651b109","isSucess":true,"enrollmentResultDetailList":[{"isSuccess":true,"customerId":398,"billingAccountId":434,"serviceAccountId":484,"customerProspectId":0,"billingAccountReferenceId":10001,"serviceAccountReferenceId":10001,"linkToBillingAccountNumber":"","enrollmentRequestDetailId":254,"customerNumber":"20-1000177","billingAccountNumber":"30-100000819","utilityAccountNumber":"1234567890"}],"enrollmentWarningList":null},"code":200,"messages":null}';
		
            Map<Id,Decimal> uaIdEnrollRateAmt = new Map<Id,Decimal>();
        uaIdEnrollRateAmt.put(objUA.id, 1200.00000); 
        Map<Id,Id> uaeUaMap = new Map<Id,Id>();
        uaeUaMap.put(objUA.Id,objUAE.Id);
  
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        test.startTest();
        HttpRequestClassZnalyticsApi obj = new HttpRequestClassZnalyticsApi();
        String responseStr = obj.doPost('POST', APIstring);
         String UAEString = '[{"attributes":{"type":"Utility_Account_Enrollment__c","url":"/services/data/v53.0/sobjects/Utility_Account_Enrollment__c/a1017000006C7ctAAC"},"Id":"a1017000006C7ctAAC","IsDeleted":false,"Name":"UAE-00000553","Enrollment__c":"a0z17000002G1zPAAS","Utility_Account__c":"a0J17000004It0tEAC","Rate_Schedule_Name__c":"test","Status__c":"Enrollment Request Pending","Bill_Type__c":"UtilityRateReady","Program_Code__c":"41/820","Start_Date__c":"2021-02-15","Hold_Reason_Code__c":"SCH","Hold_Transaction__c":true,"Effective_Date__c":"2021-01-05","Percentage__c":12,"Tax_Exempt_Certificate_Number__c":"10","Tax_Exempt_Code__c":"99","Tax_Exempt__c":true,"AutoSubmitFlag__c":false,"RateClass__c":"Custom Product","Category__c":"Undefined","Rate_Type__c":"Linked"}]';
       // String UAEString =  '[{"Name":"ABC","Tax_Exempt__c":"1312321","Bill_Type__c":"Enrollment Request Pending"}]';
        SubmitEnrollment_RenewalAPI.callRenewalEndpoint(objEN.Id,UAEString);
     
          SubmitEnrollment.getProgramCodes(objEN.Id, new List<Id>{objUA.Id},uaIdEnrollRateAmt,uaeUaMap);
        SubmitEnrollment.submitEnrollment(objEN.Id, selectedUAEs);
        SubmitEnrollment.getUAEs(objEN.Id);
        SubmitEnrollment.getDateSortedUAEs(objEN.Id,true,'Bill_Type__c');
        SubmitEnrollment.getDateSortedUAEs(objEN.Id,false,'Bill_Type__c');
        SubmitEnrollment.saveUAE(selectedUAEs);
      
        SubmitEnrollment.callZnalyticsAPI(objEN.Id, selectedUAEs); 
        Utility_Account_Enrollment__c objUAE1 = new Utility_Account_Enrollment__c();
        objUAE1.Tax_Exempt__c = false;
        objUAE1.Enrollment__c = objEN.Id;
        objUAE1.Utility_Account__c = objUA.Id;
        //objUAE.Utility_Account__r.Status__c = 'ACT';
        insert objUAE1;
        List<Utility_Account_Enrollment__c> selectedUAEs1 = new List<Utility_Account_Enrollment__c>{objUAE1};
        SubmitEnrollment.callZnalyticsAPI(objEN.Id, selectedUAEs1); 
         list<String> SaleDetails =  new list<String>();
        
        SaleDetails.add('rtr');
            
        SubmitEnrollment.UAField UaField =  new  SubmitEnrollment.UAField();
		Test.stopTest();
    }
    
    
    
}