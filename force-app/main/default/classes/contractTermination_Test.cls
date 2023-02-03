@IsTest
public class contractTermination_Test {
    
    @testSetup static void methodName() {
		EmailTemplate e = new EmailTemplate (developerName = 'Contract_Termination', FolderId = UserInfo.getUserId(), TemplateType= 'Text', Name = 'Contract_Termination'); // plus any other fields that you want to set
        
        insert e;        
    }
    
    public static testMethod void setupMethod(){ 
    Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        test.startTest();
        Account acc1= new Account();
        acc1.Name = 'Test Acc';
        //acc1.Utility_Account_Number_Prefix__c  = 'TST';
        insert acc1;
        
        Marketer__c getMarketer = new Marketer__c(name = 'xyz', MarketerDunsNumber__c = 'ten');
        Insert getMarketer;
        
         Price_File_Validation__c addValidation = new Price_File_Validation__c();
        addValidation.Validate__c = false;
        insert addValidation;
        
        Id id1 = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Utility').getRecordTypeId();
        Account acc2= new Account();
        acc2.Name = 'Test Acc1';
        acc2.RecordTypeId =id1;
        //acc2.Utility_Account_Number_Prefix__c  = 'TST';
        insert acc2;
        
        Contact con = new Contact();
        con.LastName = 'Pricing Team';
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
        pr.Voluntary_RECs__c = 'Any';
        pr.Voluntary_RECs_percent__c=50;
        insert pr;
        Date myDate = date.newInstance(2020,05,17);
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
        ua.Name = '9248100407';
        ua.Account__c = acc1.Id;
        ua.Utility__c = acc2.Id;
        ua.Status__c = 'Requested';
        ua.Street__c ='street 43';
        ua.City__c ='Test';
        ua.State__c = 'NY';
        ua.zip__c ='343438';
        ua.Country__c = 'US';
        //ua.Service_Address__c = '';
        ua.Zone__c = 'E';
        insert ua;
        
        Utility_Account_Contract__c uao = new Utility_Account_Contract__c();
        uao.Contract__c = objCon.Id;
        uao.Utility_Account__c = ua.Id;
        uao.Start_Date__c = myDate;
        uao.Status__c = 'Contracted';
        insert uao;
        
		        
        
        // To test correct data by inserting csv file with correct data
        StaticResource sr = [select body from StaticResource where name='TerminationCSV'];
        blob csvfile = sr.body;
        
            Boolean isnum = Base_Class_Uploader.isNumeric('s');
            Boolean isDate = Base_Class_Uploader.isDate('21/02/2019');
            contractTermination.insertData(csvfile,objCon.Id,'file.csv');
        
        GetTerminatedUACs gTUACs = new GetTerminatedUACs();
            gTUACs.BillType = 'abc';
        	gTUACs.prId = objCon.Id;
        	gTUACs.DueDate = System.today();
        	gTUACs.getlstUAOs();
        	gTUACs.getStartDates();
        	gTUACs.getprId();
        	gTUACs.setprId(objCon.Id);
        	
    }
    

}