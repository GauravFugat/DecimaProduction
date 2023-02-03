@isTest
public class HomeSubmitEnrollment_Test {
    
    public static testMethod void setupMethod(){
        
        
        //to cover wrapper
        HomesubmitEnrollment.UAEListWrapper uaeW = new HomesubmitEnrollment.UAEListWrapper();
        uaeW.isChecked = true;
        uaeW.editRSN = true;
        uaeW.editStatus = true;
        uaeW.editPC = true;
        uaeW.editHoldReasonCode = true;
        
        uaeW.editHoldTransaction = true;
        uaeW.editStartDate = true;
        uaeW.invalidDate = true;
        uaeW.StartDateIsValid = true;
        uaeW.editTEC = true;
        uaeW.editEffectiveDate = true;
        uaeW.editPercentage = true;
        uaeW.editTEC_Number = true;
        uaeW.editTax_Exempt = true;
        uaeW.editTET = true;
        uaeW.contractSignedDate = true;
        uaeW.errorMsg = 'test';
        uaeW.objUAE = new Utility_Account_Enrollment__c();
        uaeW.userOptions = new List<String>{'test','test1'};
        
        sortOrderCustomSetting__c socs = new sortOrderCustomSetting__c();
        socs.Name__c = 'Sort Order';
        insert socs;
            
        Id userId = UserInfo.getUserId();
        User usr = [SELECT Id,Name,Selected_Options_1__c,My_Utility_Groups__c FROM User WHERE Id =: userId]; 
	//	usr.My_Utility_Groups__c='Group A';
     //   insert usr;
        
        List<Id> enrollmentRecIdVal = new List<Id>();
        
        Account objAcc = new Account(Name = 'Account Test');
        objAcc.Group__c= 'Group A';
        objAcc.RecordTypeId = [SELECT Id, Name, DeveloperName FROM RecordType where DeveloperName = 'Utility'].Id;
        insert objAcc;
        
        Contract objCon = new Contract();
        objCon.ContractTerm = 4;
        objCon.StartDate = system.today().addMonths(-1);
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
        objUA.Street__c = 'Street';
        objUA.City__c = 'City';
        objUA.State__c = 'NY';
        objUA.Country__c = 'US';
        objUA.Status__c = 'Active';
        objUA.Zip__c = '123456';
        objUA.Commodity__c = 'Electric';
        objUA.Service_Class__c = 'Group A';
        insert objUA;
        
        
         Utility_Account__c objUA1 = new Utility_Account__c();
        objUA1.Account__c = objAcc.Id;
        objUA1.Name = '1234567891';
        objUA1.Utility__c = objAcc.Id;
        objUA1.Street__c = 'Street';
        objUA1.City__c = 'City';
        objUA1.State__c = 'NY';
        objUA1.Country__c = 'US';
        objUA1.Status__c = 'Pending';
        objUA1.Zip__c = '123456';
        insert objUA1;
        
         Program_Code__c prodcode = new Program_Code__c();
        prodcode.Commodity__c = 'Electric';
       	prodcode.Effective_Date__c = Date.newInstance(2022, 05, 12);
		prodcode.Rate__c =1200.00000;
       	prodcode.Service_Class__c='Group A';
        insert prodcode;
        
        Enrollment__c objEN = new Enrollment__c();
        objEN.Contract__c = objCon.Id;
        objEn.Account__c = objAcc.Id;
        objEN.Start_Date_Category__c = 'Single Start Date';
        objEN.Primary_Utility__c = objAcc.Id;
        objEN.Utility_Category__c = 'Single Utility';
       // objEN.Product__c = 'Fully Fixed';
        insert objEN;
        
        Utility_Account_Enrollment__c objUAE = new Utility_Account_Enrollment__c();
        objUAE.Enrollment__c = objEN.Id;
        objUAE.Utility_Account__c = objUA.Id;
        objUAE.Status__c= 'Enrollment Request Pending';
        insert objUAE;
        List<Utility_Account_Enrollment__c> selectedUAEs = new List<Utility_Account_Enrollment__c>{objUAE};
        
        Utility_Account_Enrollment__c objUAE1 = new Utility_Account_Enrollment__c();
        objUAE1.Enrollment__c = objEN.Id;
        objUAE1.Utility_Account__c = objUA1.Id;
        
        insert objUAE1;
        List<Utility_Account_Enrollment__c> selectedUAEs1 = new List<Utility_Account_Enrollment__c>{objUAE1};    
            
            
        Utility_Account_Contract__c objUAC = new Utility_Account_Contract__c();
        objUAC.Utility_Account__c = objUA.Id;
        objUAC.Contract__c = objCon.Id;
        Insert objUAC;
        enrollmentRecIdVal.add(objEN.Id);
         Marketer__c getMarketer = new Marketer__c(name = 'xyz', MarketerDunsNumber__c = 'ten');
            Insert getMarketer;
        //Call to StubDataApiRequest
        //Wrapper_Znalytics_Enrollment 
        //Call HttpCalloutMock
        
        String APIstring = '{"model":{"requestGuid":"b3ad8e43-be7e-4e1d-a190-81ec4651b109","isSucess":true,"enrollmentResultDetailList":[{"isSuccess":true,"customerId":398,"billingAccountId":434,"serviceAccountId":484,"customerProspectId":0,"billingAccountReferenceId":10001,"serviceAccountReferenceId":10001,"linkToBillingAccountNumber":"","enrollmentRequestDetailId":254,"customerNumber":"20-1000177","billingAccountNumber":"30-100000819","utilityAccountNumber":"1234567890"}],"enrollmentWarningList":null},"code":200,"messages":null}';
		
        list<string> selecteValues = new list<string>();
        list<string> allFilters = new list<string>();
        HomesubmitEnrollment.getStartDateUAEs('myGroups','defaultUAEs' , null, null, selecteValues, null, null, allFilters);
        string columnNameAndDataType = 'Utility_Account__r.Name,string';
        selecteValues.add('10101010101');
        string fromDate1='2023-01-01';
        string toDate1= '2023-01-31';
        string dateColumnName = 'Enrollment__r.Contract__r.StartDate';
        
        allFilters.add('Enrollment__r.Product__c in (\'Fully Fixed\')');
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        HttpRequestClassZnalyticsApi obj = new HttpRequestClassZnalyticsApi();
        String responseStr = obj.doPost('POST', APIstring);
        HomesubmitEnrollment.submitEnrollment(objEN.Id, selectedUAEs,true);
        HomesubmitEnrollment.submitEnrollment(objEN.Id, selectedUAEs1,true);
        HomesubmitEnrollment.getFilteredUAEs('allUAEs',false,'Group A');
         HomesubmitEnrollment.getFilteredUAEs('allUAEs',false,'GroupB');
         HomesubmitEnrollment.getFilteredUAEs('allUAEs',false,'GroupC');
        HomesubmitEnrollment.getFilteredUAEs('allUAEs',false,'myGroups');
        HomesubmitEnrollment.getFilteredUAEs('defaultUAEs',false,'myGroups');
        HomesubmitEnrollment.getFilteredUAEs('acceptedUAEs',false,'myGroups');
        HomesubmitEnrollment.getFilteredUAEs('submittedUAEs',false,'myGroups');
        HomesubmitEnrollment.getFilteredUAEs('pendingUAEs',false,'myGroups');
        HomesubmitEnrollment.getFilteredUAEs('failedUAEs',false,'myGroups');
        HomesubmitEnrollment.getFilteredUAEs('failedUAEs',true,'GroupA');
        HomesubmitEnrollment.getFilteredUAEs('failedUAEs',true,'myGroups');
        HomesubmitEnrollment.SaveSelectedOptions(new List<String>{'test'});
        
        HomesubmitEnrollment.getFilteredUAEs('failedUAEs',false,'myGroups');
        
        test.startTest();
        HomesubmitEnrollment.getGroupedUAEs('myGroups', 'defaultUAEs');
        HomesubmitEnrollment.getStartDateUAEs('myGroups','defaultUAEs' , fromDate1, toDate1, selecteValues, columnNameAndDataType, dateColumnName, allFilters);
        string temp= 'Enrollment__r.Rate_Amount__c,integer';
        list<string> templist =new list<string>();
        templist.add('0.10000');
        toDate1=null;
        HomesubmitEnrollment.getStartDateUAEs('GroupA','defaultUAEs' , fromDate1, toDate1, templist, temp, dateColumnName, allFilters);
        string temp1= 'Tax_Exempt__c,boolean';
        list<string> templist1 =new list<string>();
        templist1.add('True');
        fromDate1=null;
        toDate1='2023-01-01';
        HomesubmitEnrollment.getStartDateUAEs('GroupA','defaultUAEs' , fromDate1, toDate1, templist1, temp1, dateColumnName, allFilters);
        
        HomesubmitEnrollment.getGroupedUAEs('GroupA', 'defaultUAEs');
        HomesubmitEnrollment.getStartDateUAEs('GroupA','defaultUAEs' , fromDate1, toDate1, selecteValues, columnNameAndDataType, dateColumnName, allFilters);
        HomesubmitEnrollment.getGroupedUAEs('GroupB', 'defaultUAEs');
        HomesubmitEnrollment.getStartDateUAEs('GroupB','defaultUAEs' , fromDate1, toDate1, selecteValues, columnNameAndDataType, dateColumnName, allFilters);
        HomesubmitEnrollment.getGroupedUAEs('GroupC', 'defaultUAEs');
        HomesubmitEnrollment.getStartDateUAEs('GroupC','defaultUAEs' , fromDate1, toDate1, selecteValues, columnNameAndDataType, dateColumnName, allFilters);
        HomesubmitEnrollment.getGroupedUAEs('GroupC', 'acceptedUAEs');
        HomesubmitEnrollment.getStartDateUAEs('GroupC','acceptedUAEs' , fromDate1, toDate1, selecteValues, columnNameAndDataType, dateColumnName, allFilters);
        HomesubmitEnrollment.getGroupedUAEs('GroupC', 'pendingUAEs');
        HomesubmitEnrollment.getStartDateUAEs('GroupC','pendingUAEs' , fromDate1, toDate1, selecteValues, columnNameAndDataType, dateColumnName, allFilters);
        HomesubmitEnrollment.getGroupedUAEs('GroupC', 'failedUAEs');
        HomesubmitEnrollment.getStartDateUAEs('GroupC','failedUAEs' , fromDate1, toDate1, selecteValues, columnNameAndDataType, dateColumnName, allFilters);
        HomesubmitEnrollment.getGroupedUAEs('GroupA', 'submittedUAEs');
        HomesubmitEnrollment.getStartDateUAEs('GroupA','submittedUAEs' , fromDate1, toDate1, selecteValues, columnNameAndDataType, dateColumnName, allFilters);
        HomesubmitEnrollment.saveUAE(selectedUAEs);
        
        usr.My_Utility_Groups__c = 'Group A';
        update usr;
        HomesubmitEnrollment.getGroupedUAEs('myGroups', 'defaultUAEs');
        HomesubmitEnrollment.getStartDateUAEs('myGroups','defaultUAEs' , fromDate1, toDate1, selecteValues, columnNameAndDataType, dateColumnName, allFilters);
        HomesubmitEnrollment.getFilteredUAEs('allUAEs',false,'myGroups');
        
        usr.My_Utility_Groups__c = 'Group B';
        update usr;
        HomesubmitEnrollment.getGroupedUAEs('myGroups', 'defaultUAEs');
        HomesubmitEnrollment.getStartDateUAEs('myGroups','defaultUAEs' , fromDate1, toDate1, selecteValues, columnNameAndDataType, dateColumnName, allFilters);
        HomesubmitEnrollment.getFilteredUAEs('allUAEs',false,'Group B');
        
        usr.My_Utility_Groups__c = 'Group C';
        update usr;
        HomesubmitEnrollment.getGroupedUAEs('myGroups', 'defaultUAEs');
        HomesubmitEnrollment.getStartDateUAEs('myGroups','defaultUAEs' , fromDate1, toDate1, selecteValues, columnNameAndDataType, dateColumnName, allFilters);
        
        usr.My_Utility_Groups__c = 'Group A;Group B';
        update usr;
        HomesubmitEnrollment.getGroupedUAEs('myGroups', 'defaultUAEs');
        HomesubmitEnrollment.getStartDateUAEs('myGroups','defaultUAEs' , fromDate1, toDate1, selecteValues, columnNameAndDataType, dateColumnName, allFilters);
        
        usr.My_Utility_Groups__c = 'Group A;Group C';
        update usr;
        HomesubmitEnrollment.getGroupedUAEs('myGroups', 'defaultUAEs');
        HomesubmitEnrollment.getStartDateUAEs('myGroups','defaultUAEs' , fromDate1, toDate1, selecteValues, columnNameAndDataType, dateColumnName, allFilters);
        
        usr.My_Utility_Groups__c = 'Group B;Group C';
        update usr;
        HomesubmitEnrollment.getGroupedUAEs('myGroups', 'defaultUAEs');
        HomesubmitEnrollment.getStartDateUAEs('myGroups','defaultUAEs' , fromDate1, toDate1, selecteValues, columnNameAndDataType, dateColumnName, allFilters);
        
         usr.My_Utility_Groups__c = 'Group A;Group B;Group C';
        update usr;
        HomesubmitEnrollment.getGroupedUAEs('myGroups', 'defaultUAEs');
        HomesubmitEnrollment.getStartDateUAEs('myGroups','defaultUAEs' , fromDate1, toDate1, selecteValues, columnNameAndDataType, dateColumnName, allFilters);
        
        
        Map<Id,Decimal> uaIdEnrollRateAmt = new Map<Id,Decimal>();
        uaIdEnrollRateAmt.put(objUA.id, 1200.00000);
        Map<Id,Id> uaeUaMap = new Map<Id,Id>();
        uaeUaMap.put(objUA.Id,objUAE.Id);
       // Group A;Group B;Group C
        HomesubmitEnrollment.getProgramCodes(new List<Id>{objUA.Id},uaIdEnrollRateAmt,uaeUaMap);
        
       /* prodcode.Service_Class__c ='Group A | Group B';
        update prodcode;
         objUA.Service_Class__c = 'Group A | Group B';
        update objUA;
           HomesubmitEnrollment.getProgramCodes(objEN.Id, new List<Id>{objUA.Id},uaIdEnrollRateAmt,uaeUaMap);*/
        test.stopTest();
    }
    
        public static testMethod void setupMethod2(){
     //to cover wrapper
        HomesubmitEnrollment.UAEListWrapper uaeW = new HomesubmitEnrollment.UAEListWrapper();
        uaeW.isChecked = true;
        uaeW.editRSN = true;
        uaeW.editStatus = true;
        uaeW.editPC = true;
        uaeW.editHoldReasonCode = true;
        
        uaeW.editHoldTransaction = true;
        uaeW.editStartDate = true;
        uaeW.invalidDate = true;
        uaeW.StartDateIsValid = true;
        uaeW.editTEC = true;
        uaeW.editEffectiveDate = true;
        uaeW.editPercentage = true;
        uaeW.editTEC_Number = true;
        uaeW.editTax_Exempt = true;
        uaeW.editTET = true;
        uaeW.contractSignedDate = true;
        uaeW.errorMsg = 'test';
        uaeW.objUAE = new Utility_Account_Enrollment__c();
        uaeW.userOptions = new List<String>{'test','test1'};
        
        sortOrderCustomSetting__c socs = new sortOrderCustomSetting__c();
        socs.Name__c = 'Sort Order';
        insert socs;
            
        Id userId = UserInfo.getUserId();
        User usr = [SELECT Id,Name,Selected_Options_1__c,My_Utility_Groups__c FROM User WHERE Id =: userId]; 
	//	usr.My_Utility_Groups__c='Group A';
     //   insert usr;
        
        List<Id> enrollmentRecIdVal = new List<Id>();
        
        Account objAcc = new Account(Name = 'Account Test');
        objAcc.RecordTypeId = [SELECT Id, Name, DeveloperName FROM RecordType where DeveloperName = 'Utility'].Id;
        insert objAcc;
        
        Contract objCon = new Contract();
        objCon.ContractTerm = 4;
        objCon.StartDate = system.today().addMonths(-1);
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
        objUA.Street__c = 'Street';
        objUA.City__c = 'City';
        objUA.State__c = 'NY';
        objUA.Country__c = 'US';
        objUA.Status__c = 'Active';
        objUA.Zip__c = '123456';
        objUA.Commodity__c = 'Electric';
        objUA.Service_Class__c = 'Group A';
        insert objUA;
        
        
         Utility_Account__c objUA1 = new Utility_Account__c();
        objUA1.Account__c = objAcc.Id;
        objUA1.Name = '1234567891';
        objUA1.Utility__c = objAcc.Id;
        objUA1.Street__c = 'Street';
        objUA1.City__c = 'City';
        objUA1.State__c = 'NY';
        objUA1.Country__c = 'US';
        objUA1.Status__c = 'Pending';
        objUA1.Zip__c = '123456';
        insert objUA1;
        
         Program_Code__c prodcode = new Program_Code__c();
        prodcode.Commodity__c = 'Electric';
       	prodcode.Effective_Date__c = Date.newInstance(2022, 05, 12);
		prodcode.Rate__c =1200.00000;
       	prodcode.Service_Class__c='Group A|Group B';
        insert prodcode;
        
        Enrollment__c objEN = new Enrollment__c();
        objEN.Contract__c = objCon.Id;
        objEn.Account__c = objAcc.Id;
        objEN.Start_Date_Category__c = 'Single Start Date';
        objEN.Primary_Utility__c = objAcc.Id;
        objEN.Utility_Category__c = 'Single Utility';
        insert objEN;
        
        Utility_Account_Enrollment__c objUAE = new Utility_Account_Enrollment__c();
        objUAE.Enrollment__c = objEN.Id;
        objUAE.Utility_Account__c = objUA.Id;
        insert objUAE;
        List<Utility_Account_Enrollment__c> selectedUAEs = new List<Utility_Account_Enrollment__c>{objUAE};
        
        Utility_Account_Enrollment__c objUAE1 = new Utility_Account_Enrollment__c();
        objUAE1.Enrollment__c = objEN.Id;
        objUAE1.Utility_Account__c = objUA1.Id;
        insert objUAE1;
        List<Utility_Account_Enrollment__c> selectedUAEs1 = new List<Utility_Account_Enrollment__c>{objUAE1};    
            
            
        Utility_Account_Contract__c objUAC = new Utility_Account_Contract__c();
        objUAC.Utility_Account__c = objUA.Id;
        objUAC.Contract__c = objCon.Id;
        Insert objUAC;
        enrollmentRecIdVal.add(objEN.Id);
         Marketer__c getMarketer = new Marketer__c(name = 'xyz', MarketerDunsNumber__c = 'ten');
            Insert getMarketer;
        //Call to StubDataApiRequest
        //Wrapper_Znalytics_Enrollment 
        //Call HttpCalloutMock
        
        String APIstring = '{"model":{"requestGuid":"b3ad8e43-be7e-4e1d-a190-81ec4651b109","isSucess":true,"enrollmentResultDetailList":[{"isSuccess":true,"customerId":398,"billingAccountId":434,"serviceAccountId":484,"customerProspectId":0,"billingAccountReferenceId":10001,"serviceAccountReferenceId":10001,"linkToBillingAccountNumber":"","enrollmentRequestDetailId":254,"customerNumber":"20-1000177","billingAccountNumber":"30-100000819","utilityAccountNumber":"1234567890"}],"enrollmentWarningList":null},"code":200,"messages":null}';

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        test.startTest();
        HttpRequestClassZnalyticsApi obj = new HttpRequestClassZnalyticsApi();
        String responseStr = obj.doPost('POST', APIstring);
        HomesubmitEnrollment.submitEnrollment(objEN.Id, selectedUAEs,true);
        HomesubmitEnrollment.submitEnrollment(objEN.Id, selectedUAEs1,true);
        HomesubmitEnrollment.getFilteredUAEs('allUAEs',false,'Group A');
         HomesubmitEnrollment.getFilteredUAEs('allUAEs',false,'GroupB');
         HomesubmitEnrollment.getFilteredUAEs('allUAEs',false,'GroupC');
        HomesubmitEnrollment.getFilteredUAEs('allUAEs',false,'myGroups');
        HomesubmitEnrollment.getFilteredUAEs('defaultUAEs',false,'myGroups');
        HomesubmitEnrollment.getFilteredUAEs('acceptedUAEs',false,'myGroups');
        HomesubmitEnrollment.getFilteredUAEs('submittedUAEs',false,'myGroups');
        HomesubmitEnrollment.getFilteredUAEs('pendingUAEs',false,'myGroups');
        HomesubmitEnrollment.getFilteredUAEs('failedUAEs',false,'myGroups');
        HomesubmitEnrollment.getFilteredUAEs('failedUAEs',true,'GroupA');
        HomesubmitEnrollment.getFilteredUAEs('failedUAEs',true,'myGroups');
        HomesubmitEnrollment.SaveSelectedOptions(new List<String>{'test'});
        
        HomesubmitEnrollment.getFilteredUAEs('failedUAEs',false,'myGroups');
        
        HomesubmitEnrollment.getGroupedUAEs('myGroups', 'defaultUAEs');
        HomesubmitEnrollment.getGroupedUAEs('GroupA', 'defaultUAEs');
        HomesubmitEnrollment.getGroupedUAEs('GroupB', 'defaultUAEs');
        HomesubmitEnrollment.getGroupedUAEs('GroupC', 'defaultUAEs');
        HomesubmitEnrollment.getGroupedUAEs('GroupC', 'acceptedUAEs');
        HomesubmitEnrollment.getGroupedUAEs('GroupC', 'pendingUAEs');
        HomesubmitEnrollment.getGroupedUAEs('GroupC', 'failedUAEs');
        HomesubmitEnrollment.getGroupedUAEs('GroupA', 'submittedUAEs');
        HomesubmitEnrollment.saveUAE(selectedUAEs);
        
        usr.My_Utility_Groups__c = 'Group A';
        update usr;
        HomesubmitEnrollment.getGroupedUAEs('myGroups', 'defaultUAEs');
        HomesubmitEnrollment.getFilteredUAEs('allUAEs',false,'myGroups');
        
        usr.My_Utility_Groups__c = 'Group B';
        update usr;
        HomesubmitEnrollment.getGroupedUAEs('myGroups', 'defaultUAEs');
        HomesubmitEnrollment.getFilteredUAEs('allUAEs',false,'Group B');
        
        usr.My_Utility_Groups__c = 'Group C';
        update usr;
        HomesubmitEnrollment.getGroupedUAEs('myGroups', 'defaultUAEs');
        
        usr.My_Utility_Groups__c = 'Group A;Group B';
        update usr;
        HomesubmitEnrollment.getGroupedUAEs('myGroups', 'defaultUAEs');
        
        usr.My_Utility_Groups__c = 'Group A;Group C';
        update usr;
        HomesubmitEnrollment.getGroupedUAEs('myGroups', 'defaultUAEs');
        
        usr.My_Utility_Groups__c = 'Group B;Group C';
        update usr;
        HomesubmitEnrollment.getGroupedUAEs('myGroups', 'defaultUAEs');
        
         usr.My_Utility_Groups__c = 'Group A;Group B;Group C';
        update usr;
        HomesubmitEnrollment.getGroupedUAEs('myGroups', 'defaultUAEs');
        
        
        Map<Id,Decimal> uaIdEnrollRateAmt = new Map<Id,Decimal>();
        uaIdEnrollRateAmt.put(objUA.id, 1200.00000);
       /* Map<Id,Id> uaeUaMap = new Map<Id,Id>();
        uaeUaMap.put(objUA.Id,objUAE.Id);*/
       // Group A;Group B;Group C
        
       /* prodcode.Service_Class__c ='Group A | Group B';
        update prodcode;
         objUA.Service_Class__c = 'Group A | Group B';
        update objUA;*/
             Map<Id,Id> uaeUaMap = new Map<Id,Id>();
        uaeUaMap.put(objUA.Id,objUAE.Id);
           HomesubmitEnrollment.getProgramCodes( new List<Id>{objUA.Id},uaIdEnrollRateAmt,uaeUaMap);
        test.stopTest();
    }
    
    
}