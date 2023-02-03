@isTest
public class Invoke_LiensJudgementsTrends_Test {
    public static testMethod void setupMethod(){

        
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
        
        List<Invoke_LiensJudgementsTrends.wrapper_liensJudgementsTrends> varList = new List<Invoke_LiensJudgementsTrends.wrapper_liensJudgementsTrends>();
        Invoke_LiensJudgementsTrends.wrapper_liensJudgementsTrends var = new Invoke_LiensJudgementsTrends.wrapper_liensJudgementsTrends();
        var.fromPorcessBuilder = true;
        var.pricingRequestIds =objPR1.Id ;
        var.creditTypMtch = false;
        varList.add(var);
        
        List<Invoke_LiensJudgementsTrends.wrapper_liensJudgementsTrends> varList1 = new List<Invoke_LiensJudgementsTrends.wrapper_liensJudgementsTrends>();
        Invoke_LiensJudgementsTrends.wrapper_liensJudgementsTrends var1 = new Invoke_LiensJudgementsTrends.wrapper_liensJudgementsTrends();
        var1.fromPorcessBuilder = false;
        var1.pricingRequestIds =objPR1.Id ;
        var1.creditTypMtch = true;
        varList1.add(var1);
        
        Invoke_LiensJudgementsTrends.wrapper_liensJudgementsTrends wrapW = new Invoke_LiensJudgementsTrends.wrapper_liensJudgementsTrends();
        wrapW.creditTypMtch = true;
        wrapW.fromPorcessBuilder = true;
        wrapW.pricingRequestIds = null;
        
        
        Test.startTest();
        Invoke_LiensJudgementsTrends.liensJudgementsTrendsInvoke(varList);
        Invoke_LiensJudgementsTrends.liensJudgementsTrendsInvoke(varList1);
        Test.stopTest();
    }

    
    
    public static testMethod void setupMethod1(){
        
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
        CusAcc.Customer_Credit_Limit__c =1000;
        insert CusAcc;
        
        Utility_Account__c objUA = new Utility_Account__c();
        objUA.Account__c = CusAcc.Id;
        objUA.Annual_Usage_kWh__c = 100;
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
        
        Credit_Check__c creditCheckRecord1 = new Credit_Check__c(Customer__c = CusAcc.Id,
                                                                Opportunity__c = objOpp.Id, Status__c = 'Active', 
                                                                Credit_Check_Outcome__C = 'Failed', FSR_Score__c = 41, IP_Score__c = 45,
                                                                Credit_Limit__c = 15000,Credit_Automation_Fail__c = false
                                                               );
        insert creditCheckRecord1;
        
        
        
        Pricing_Request__c objPR1 = new Pricing_Request__c();
        objPR1.Opportunity__c = objOpp.Id;
        objPR1.Start_Date__c = System.today();
        objPR1.Record_Created__c = true;
        objPR1.Customer__c = CusAcc.Id;
        objPR1.Bill_Type__c = 'Dual';
        objPR1.Credit_details__c = creditCheckRecord1.Id;
        Insert objPR1;
        
  
        
        List<Invoke_LiensJudgementsTrends.wrapper_liensJudgementsTrends> varList = new List<Invoke_LiensJudgementsTrends.wrapper_liensJudgementsTrends>();
        Invoke_LiensJudgementsTrends.wrapper_liensJudgementsTrends var = new Invoke_LiensJudgementsTrends.wrapper_liensJudgementsTrends();
        var.fromPorcessBuilder = true;
        var.pricingRequestIds =objPR1.Id ;
        var.creditTypMtch = false;
        varList.add(var);
        
        List<Invoke_LiensJudgementsTrends.wrapper_liensJudgementsTrends> varList1 = new List<Invoke_LiensJudgementsTrends.wrapper_liensJudgementsTrends>();
        Invoke_LiensJudgementsTrends.wrapper_liensJudgementsTrends var1 = new Invoke_LiensJudgementsTrends.wrapper_liensJudgementsTrends();
        var1.fromPorcessBuilder = false;
        var1.pricingRequestIds =objPR1.Id ;
        var1.creditTypMtch = true;
        varList1.add(var1);
        
        Invoke_LiensJudgementsTrends.wrapper_liensJudgementsTrends wrapW = new Invoke_LiensJudgementsTrends.wrapper_liensJudgementsTrends();
        wrapW.creditTypMtch = true;
        wrapW.fromPorcessBuilder = true;
        wrapW.pricingRequestIds = null;
        
        Invoke_LiensJudgementsTrends.wrapInv wrapWW = new Invoke_LiensJudgementsTrends.wrapInv();
        wrapWW.inv1 = 'Test';
        wrapWW.inv2 = 'Test';
        wrapWW.inv3 = 'Test';
        wrapWW.inv4 = 'Test';
        wrapWW.inv5 = 'Test';
        wrapWW.inv6 = 'Test';
        wrapWW.inv7 = 'Test';
        wrapWW.inv8 = 'Test';
        wrapWW.inv9 = 'Test';
        wrapWW.inv10 = 'Test';
        wrapWW.inv11 = 'Test';
        wrapWW.inv12 = 'Test';
        wrapWW.inv13 = 'Test';
        wrapWW.inv14 = 'Test';
        wrapWW.inv15 = 'Test';
        
        Test.startTest();
        Invoke_LiensJudgementsTrends.liensJudgementsTrendsInvoke(varList);
        Invoke_LiensJudgementsTrends.liensJudgementsTrendsInvoke(varList1);
        Test.stopTest();
    }
    
 ////////////////   
    public static testMethod void setupMethod11(){
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        test.startTest();
       /* Marketer__c getMarketer = new Marketer__c();
        getMarketer.Name = 'SEUS MarketerDunsNumber';
        getMarketer.MarketerDunsNumber__c = 'Smartest Energy_Sandbox_Duns';
        insert getMarketer;*/
        
           EXPRN__Experian_Business__c  exp = new EXPRN__Experian_Business__c ();
        exp.EXPRN__BIN__c = '701852096';
        insert exp;
        
        Experian__c expObj = new Experian__c();
        expObj.Auth_Body__c = '{"username": "vishwanath.kodgire@aress.com.sel.staging","password": "Aress123456","client_id": "W7o3bmXvo1aZCSdD3SaMLwRw3nJzg1YB","client_secret":"xpp2lyKgfJO7kl4R"}';
        expObj.Auth_URL__c ='https://smartestenergyus--dev5.my.salesforce.com/servlet/servlet.ExternalRedirect?url=https%3A%2F%2Fsandbox-us-api.experian.com%2Foauth2%2Fv1%2Ftoken&';
        expObj.Auto_Search_URL__c='https://smartestenergyus--dev5.my.salesforce.com/servlet/servlet.ExternalRedirect?url=https%3A%2F%2Fsandbox-us-api.experian.com%2Fbusinessinformation%2Fbusinesses%2Fv1%2Fscores%2Fsearch&';
        expObj.Subcode__c = '517614';
        expObj.Business_Facts_URL__c = 'https://sandbox-us-api.experian.com/businessinformation/businesses/v1/facts';
        expObj.Legal_Filings_Summary_URL__c= 'https://sandbox-us-api.experian.com/businessinformation/businesses/v1/legalcollectionsummaries';
        expObj.Fraud_Shields_URL__c = 'https://sandbox-us-api.experian.com/businessinformation/businesses/v1/fraudshields';
        expObj.Judgments_URL__c = 'https://sandbox-us-api.experian.com/businessinformation/businesses/v1/judgments';
        expObj.Liens_URL__c = 'https://sandbox-us-api.experian.com/businessinformation/businesses/v1/liens';
        expObj.Business_Search_URL__c = 'https://smartestenergyus--dev5.my.salesforce.com/servlet/servlet.ExternalRedirect?url=https%3A%2F%2Fsandbox-us-api.experian.com%2Fbusinessinformation%2Fbusinesses%2Fv1%2Fsearch&';
        insert expObj;
        
         Id recordTypeCus = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Customer').getRecordTypeId();
        Account CusAcc= new Account();
        CusAcc.Name = 'Test Acc1';
        CusAcc.RecordTypeId =recordTypeCus;
        CusAcc.EXPRN__Exp_Business__c = exp.Id;
        CusAcc.Customer_Credit_Limit__c =1000;
        insert CusAcc;
        
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
        pr.Bill_Type__c = 'Dual';
        pr.RecordTypeId = rt.Id;
        pr.Product_Lookup__c = prodObj.Id;
        pr.Voluntary_RECs__c = 'NA';
        pr.Voluntary_RECs_percent__c = 100;
        pr.Customer__c = CusAcc.id;
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
        
        
        Credit_Check__c cc = new Credit_Check__c();
        cc.Pricing_Request__c = pr.Id;
        cc.Customer__c = pr.Customer__c;
        cc.Status__c = 'Active';
        cc.FSR_Score__c=10;
        cc.IP_Score__c=6;
        cc.Opportunity__c =opp.Id;
        cc.Credit_Limit__c = 2400;
        cc.Credit_Check_Outcome__c = 'Pending';
        insert cc;

        /////////////
        //
          Price__c pr111 = new Price__c();
        pr111.Price_Type__c = 'Quote';
        pr111.Opportunity__c = opp.Id;
        insert pr111;
        Term_Price__c tp1 = new Term_Price__c();
            tp1.Price__c = pr111.Id;
            tp1.Cumulative_Volume__c = 2500;
            tp1.Base_Price__c = 1.555;
            tp1.Term__c = '2';
            tp1.Utility__c = acc2.Id;
            tp1.Volume__c = 5;
            tp1.Utility_Account_Opportunity__c = uao.Id;
            tp1.Opportunity__c = opp.Id;
        insert tp1;
        
       ////////////////
        
        
        // To test correct data by inserting csv file with correct data
        StaticResource sr = [select body from StaticResource where name='file_upload_csv'];
        blob csvfile = sr.body;
        
        Boolean isnum = Base_Class_Uploader.isNumeric('s');
        Boolean isDate = Base_Class_Uploader.isDate('21/02/2019');
        file_upload_handler.insertData(csvfile,pr.Id,'file.csv',true);
        
        // To test incorrect data by inserting csv file with incorrect data
        StaticResource sr1 = [select body from StaticResource where name='final_upload_err'];
        blob csvfile1 = sr1.body;
        Boolean isnum2 = Base_Class_Uploader.isNumeric('s');
        Boolean isDate2 = Base_Class_Uploader.isDate('21/02/2019');
        file_upload_handler.insertData(csvfile1,pr.Id,'file1.csv',true);
        List<List<String>> inputCSVLines = new List<List<String>>();
        List<List<String>> inputCSVLines1 = new List<List<String>>();
        List<String> inpcsvHeader = new List<String>();
        inpcsvHeader.add('Account Number,Term,Month,Year,Usage,Profile On-Peak,Profile Off-Peak,Cumulative Volume,Price Term to Date,Load Factor,Address Street,Address City,Address State,Address Zip,Address Country,POR,Tax,Service Class,Zone,Product ID,Bill Type,RECs Type,Vol RECs %,ICAP Tag Current,ICAP Tag Future,NITS Tag Current,NITS Tag Future,Annual Volume,Expected FSD');
        
        
        List<String> inpcsv1 = new List<String>();
        inpcsv1.add('1234567891,1,Feb,2022,0,0.0,0.0,0,0.07112,0.4355495,,,PA,,US,1.0,1.0627,WP-GP30SD,APS,Fixed,UCB,NA,,9.2412,9.9224,9.8,9.8,35259.0,03/21/2022');
        inputCSVLines.add(inpcsvHeader); 
        inputCSVLines.add(inpcsv1); 
        List<String> inpcsv = new List<String>();        
        inpcsv.add('0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28');
        inputCSVLines1.add(inpcsv);
        inputCSVLines1.add(inpcsv);
        Price__c pr1 = new Price__c();
        pr1.Price_Type__c = 'Quote';
        pr1.Opportunity__c = opp.Id;
        insert pr1;
        BatchPriceUploader.processFileChunk(inputCSVLines, pr.Id, 29, 'FileName', pr1.Id, 29, true);
        //BatchPriceUploader.processFileChunk(inputCSVLines1, pr.Id, 29, 'FileName', pr1.Id, 29, true);
        BatchPriceUploader.UAFieldsStore uaf = new  BatchPriceUploader.UAFieldsStore();
        uaf.Capacity_Tag = 'Capacity_Tag';
        uaf.Capacity_Tag_Future = 'Capacity_Tag_Future';
        uaf.NITS_Tag='NITS_Tag';
        uaf.NITS_Tag_Future='NITS_Tag_Future';
        BatchPriceUploader.UAFieldsStore22 uaf1 = new  BatchPriceUploader.UAFieldsStore22();
        uaf1.Capacity_Tag22 = 'Capacity_Tag';
        uaf1.Capacity_Tag_Future22 = 'Capacity_Tag_Future';
        uaf1.NITS_Tag22='NITS_Tag';
        uaf1.NITS_Tag_Future22='NITS_Tag_Future';
        uaf1.Capacity_Tag33 = 'Capacity_Tag';
        uaf1.Capacity_Tag_Future33 = 'Capacity_Tag_Future';
        uaf1.NITS_Tag33='NITS_Tag';
        uaf1.NITS_Tag_Future33='NITS_Tag_Future';
        uaf1.Capacity_Tag44 = 'Capacity_Tag';
        uaf1.Capacity_Tag_Future44 = 'Capacity_Tag_Future';
        uaf1.NITS_Tag44='NITS_Tag';
        uaf1.NITS_Tag_Future44='NITS_Tag_Future';
        uaf1.Capacity_Tag55 = 'Capacity_Tag';
        uaf1.Capacity_Tag_Future55 = 'Capacity_Tag_Future';
        uaf1.NITS_Tag55='NITS_Tag';
        uaf1.NITS_Tag_Future55='NITS_Tag_Future';
        uaf1.Capacity_Tag66 = 'Capacity_Tag';
        uaf1.Capacity_Tag_Future66 = 'Capacity_Tag_Future';
        uaf1.NITS_Tag66='NITS_Tag';
        uaf1.NITS_Tag_Future66='NITS_Tag_Future';
        uaf1.Capacity_Tag77 = 'Capacity_Tag';
        uaf1.Capacity_Tag_Future77 = 'Capacity_Tag_Future';
        uaf1.NITS_Tag77='NITS_Tag';
        uaf1.NITS_Tag_Future77='NITS_Tag_Future';
        uaf1.Capacity_Tag88 = 'Capacity_Tag';
        uaf1.Capacity_Tag_Future88 = 'Capacity_Tag_Future';
        uaf1.NITS_Tag88='NITS_Tag';
        uaf1.NITS_Tag_Future88='NITS_Tag_Future';
        uaf1.Capacity_Tag99 = 'Capacity_Tag';
        uaf1.Capacity_Tag_Future99 = 'Capacity_Tag_Future';
        uaf1.NITS_Tag99='NITS_Tag';
        uaf1.NITS_Tag_Future99='NITS_Tag_Future';
        uaf1.Capacity_Tag111 = 'Capacity_Tag';
        uaf1.Capacity_Tag_Future111 = 'Capacity_Tag_Future';
        uaf1.NITS_Tag111='NITS_Tag';
        uaf1.NITS_Tag_Future111='NITS_Tag_Future';
        uaf1.Capacity_Tag222 = 'Capacity_Tag';
        uaf1.Capacity_Tag_Future222 = 'Capacity_Tag_Future';
        uaf1.NITS_Tag222='NITS_Tag';
        uaf1.NITS_Tag_Future222='NITS_Tag_Future';
        uaf1.Capacity_Tag333 = 'Capacity_Tag';
        uaf1.Capacity_Tag_Future333 = 'Capacity_Tag_Future';
        uaf1.NITS_Tag333='NITS_Tag';
        uaf1.NITS_Tag_Future333='NITS_Tag_Future';
        uaf1.Capacity_Tag444 = 'Capacity_Tag';
        uaf1.Capacity_Tag_Future444 = 'Capacity_Tag_Future';
        uaf1.NITS_Tag444='NITS_Tag';
        uaf1.NITS_Tag_Future444='NITS_Tag_Future';
        uaf1.Capacity_Tag555 = 'Capacity_Tag';
        uaf1.Capacity_Tag_Future555 = 'Capacity_Tag_Future';
        uaf1.NITS_Tag555='NITS_Tag';
        uaf1.NITS_Tag_Future555='NITS_Tag_Future';
        uaf1.Capacity_Tag666 = 'Capacity_Tag';
        uaf1.Capacity_Tag_Future666 = 'Capacity_Tag_Future';
        uaf1.NITS_Tag666='NITS_Tag';
        uaf1.NITS_Tag_Future666='NITS_Tag_Future';
        uaf1.Capacity_Tag777 = 'Capacity_Tag';
        uaf1.Capacity_Tag_Future777 = 'Capacity_Tag_Future';
        uaf1.NITS_Tag777='NITS_Tag';
        uaf1.NITS_Tag_Future777='NITS_Tag_Future';
        uaf1.Capacity_Tag888 = 'Capacity_Tag';
        uaf1.Capacity_Tag_Future888 = 'Capacity_Tag_Future';
        uaf1.NITS_Tag888='NITS_Tag';
        uaf1.NITS_Tag_Future888='NITS_Tag_Future';
        uaf1.Capacity_Tag999 = 'Capacity_Tag';
        uaf1.Capacity_Tag_Future999 = 'Capacity_Tag_Future';
        uaf1.NITS_Tag999='NITS_Tag';
        uaf1.NITS_Tag_Future999='NITS_Tag_Future';
        uaf1.Capacity_Tag01 = 'Capacity_Tag';
        uaf1.Capacity_Tag_Future01 = 'Capacity_Tag_Future';
        uaf1.NITS_Tag01='NITS_Tag';
        uaf1.NITS_Tag_Future01='NITS_Tag_Future';
        uaf1.Capacity_Tag02 = 'Capacity_Tag';
        uaf1.Capacity_Tag_Future02 = 'Capacity_Tag_Future';
        uaf1.NITS_Tag02='NITS_Tag';
        uaf1.NITS_Tag_Future02='NITS_Tag_Future';
        uaf1.Capacity_Tag03 = 'Capacity_Tag';
        uaf1.Capacity_Tag_Future03 = 'Capacity_Tag_Future';
        uaf1.NITS_Tag03='NITS_Tag';
        uaf1.NITS_Tag_Future03='NITS_Tag_Future';
        uaf1.Capacity_Tag04 = 'Capacity_Tag';
        uaf1.Capacity_Tag_Future04 = 'Capacity_Tag_Future';
        uaf1.NITS_Tag04='NITS_Tag';
        uaf1.NITS_Tag_Future04='NITS_Tag_Future';
        uaf1.Capacity_Tag05 = 'Capacity_Tag';
        uaf1.Capacity_Tag_Future05 = 'Capacity_Tag_Future';
        uaf1.NITS_Tag05='NITS_Tag';
        uaf1.NITS_Tag_Future05='NITS_Tag_Future';
        uaf1.Capacity_Tag06 = 'Capacity_Tag';
        uaf1.Capacity_Tag_Future06 = 'Capacity_Tag_Future';
        uaf1.NITS_Tag06='NITS_Tag';
        uaf1.NITS_Tag_Future06='NITS_Tag_Future';
        uaf1.Capacity_Tag07 = 'Capacity_Tag';
        uaf1.Capacity_Tag_Future07 = 'Capacity_Tag_Future';
        uaf1.NITS_Tag07='NITS_Tag';
        uaf1.NITS_Tag_Future07='NITS_Tag_Future';
        uaf1.Capacity_Tag08 = 'Capacity_Tag';
        uaf1.Capacity_Tag_Future08 = 'Capacity_Tag_Future';
        uaf1.NITS_Tag08='NITS_Tag';
        uaf1.NITS_Tag_Future08='NITS_Tag_Future';
        uaf1.Capacity_Tag09 = 'Capacity_Tag';
        uaf1.Capacity_Tag_Future09 = 'Capacity_Tag_Future';
        uaf1.NITS_Tag09='NITS_Tag';
        uaf1.NITS_Tag_Future09='NITS_Tag_Future';
        uaf1.Capacity_Tag10 = 'Capacity_Tag';
        uaf1.Capacity_Tag_Future10 = 'Capacity_Tag_Future';
        uaf1.NITS_Tag10='NITS_Tag';
        uaf1.NITS_Tag_Future10='NITS_Tag_Future';
        uaf1.Capacity_Tag11 = 'Capacity_Tag';
        uaf1.Capacity_Tag_Future11 = 'Capacity_Tag_Future';
        uaf1.NITS_Tag11='NITS_Tag';
        uaf1.NITS_Tag_Future11='NITS_Tag_Future';
        uaf1.Capacity_Tag12 = 'Capacity_Tag';
        uaf1.Capacity_Tag_Future12 = 'Capacity_Tag_Future';
        uaf1.NITS_Tag12='NITS_Tag';
        uaf1.NITS_Tag_Future12='NITS_Tag_Future';
        uaf1.Capacity_Tag13 = 'Capacity_Tag';
        uaf1.Capacity_Tag_Future13 = 'Capacity_Tag_Future';
        uaf1.NITS_Tag13='NITS_Tag';
        uaf1.NITS_Tag_Future13='NITS_Tag_Future';
        uaf1.Capacity_Tag14 = 'Capacity_Tag';
        uaf1.Capacity_Tag_Future14 = 'Capacity_Tag_Future';
        uaf1.NITS_Tag14='NITS_Tag';
        uaf1.NITS_Tag_Future14='NITS_Tag_Future';
        uaf1.Capacity_Tag15 = 'Capacity_Tag';
        uaf1.Capacity_Tag_Future15 = 'Capacity_Tag_Future';
        uaf1.NITS_Tag15='NITS_Tag';
        uaf1.NITS_Tag_Future15='NITS_Tag_Future';
        uaf1.Capacity_Tag16 = 'Capacity_Tag';
        uaf1.Capacity_Tag_Future16 = 'Capacity_Tag_Future';
        uaf1.NITS_Tag16='NITS_Tag';
        uaf1.NITS_Tag_Future16='NITS_Tag_Future';
        uaf1.Capacity_Tag17 = 'Capacity_Tag';
        uaf1.Capacity_Tag_Future17 = 'Capacity_Tag_Future';
        uaf1.NITS_Tag17='NITS_Tag';
        uaf1.NITS_Tag_Future17='NITS_Tag_Future';
        uaf1.Capacity_Tag18 = 'Capacity_Tag';
        uaf1.Capacity_Tag_Future18 = 'Capacity_Tag_Future';
        uaf1.NITS_Tag18='NITS_Tag';
        uaf1.NITS_Tag_Future18='NITS_Tag_Future';
        uaf1.Capacity_Tag19 = 'Capacity_Tag';
        uaf1.Capacity_Tag_Future19 = 'Capacity_Tag_Future';
        uaf1.NITS_Tag19='NITS_Tag';
        uaf1.NITS_Tag_Future19='NITS_Tag_Future';
        uaf1.Capacity_Tag20 = 'Capacity_Tag';
        uaf1.Capacity_Tag_Future20 = 'Capacity_Tag_Future';
        uaf1.NITS_Tag20='NITS_Tag';
        uaf1.NITS_Tag_Future20='NITS_Tag_Future';
        uaf1.Capacity_Tag21 = 'Capacity_Tag';
        uaf1.Capacity_Tag_Future21 = 'Capacity_Tag_Future';
        uaf1.NITS_Tag21='NITS_Tag';
        uaf1.NITS_Tag_Future21='NITS_Tag_Future';
        uaf1.Capacity_Tag022 = 'Capacity_Tag';
        uaf1.Capacity_Tag_Future022 = 'Capacity_Tag_Future';
        uaf1.NITS_Tag022='NITS_Tag';
        uaf1.NITS_Tag_Future022='NITS_Tag_Future';
        uaf1.Capacity_Tag23 = 'Capacity_Tag';
        uaf1.Capacity_Tag_Future23 = 'Capacity_Tag_Future';
        uaf1.NITS_Tag23='NITS_Tag';
        uaf1.NITS_Tag_Future23='NITS_Tag_Future';
        uaf1.Capacity_Tag24 = 'Capacity_Tag';
        uaf1.Capacity_Tag_Future24 = 'Capacity_Tag_Future';
        uaf1.NITS_Tag24='NITS_Tag';
        uaf1.NITS_Tag_Future24='NITS_Tag_Future';
        uaf1.Capacity_Tag25 = 'Capacity_Tag';
        uaf1.Capacity_Tag_Future25 = 'Capacity_Tag_Future';
        uaf1.NITS_Tag25='NITS_Tag';
        uaf1.NITS_Tag_Future25='NITS_Tag_Future';
        uaf1.Capacity_Tag26 = 'Capacity_Tag';
        uaf1.Capacity_Tag_Future26 = 'Capacity_Tag_Future';
        uaf1.NITS_Tag26='NITS_Tag';
        uaf1.NITS_Tag_Future26='NITS_Tag_Future';
        uaf1.Capacity_Tag27 = 'Capacity_Tag';
        uaf1.Capacity_Tag_Future27 = 'Capacity_Tag_Future';
        uaf1.NITS_Tag27='NITS_Tag';
        uaf1.NITS_Tag_Future27='NITS_Tag_Future';
        uaf1.Capacity_Tag28 = 'Capacity_Tag';
        uaf1.Capacity_Tag_Future28 = 'Capacity_Tag_Future';
        uaf1.NITS_Tag28='NITS_Tag';
        uaf1.NITS_Tag_Future28='NITS_Tag_Future';
        uaf1.Capacity_Tag29 = 'Capacity_Tag';
        uaf1.Capacity_Tag_Future29 = 'Capacity_Tag_Future';
        uaf1.NITS_Tag29='NITS_Tag';
        uaf1.NITS_Tag_Future29='NITS_Tag_Future';
        uaf1.Capacity_Tag30 = 'Capacity_Tag';
        uaf1.Capacity_Tag_Future30 = 'Capacity_Tag_Future';
        uaf1.NITS_Tag30='NITS_Tag';
        uaf1.NITS_Tag_Future30='NITS_Tag_Future';
        uaf1.Capacity_Tag31 = 'Capacity_Tag';
        uaf1.Capacity_Tag_Future31 = 'Capacity_Tag_Future';
        uaf1.NITS_Tag31='NITS_Tag';
        uaf1.NITS_Tag_Future31='NITS_Tag_Future';
        uaf1.Capacity_Tag32 = 'Capacity_Tag';
        uaf1.Capacity_Tag_Future32 = 'Capacity_Tag_Future';
        uaf1.NITS_Tag32='NITS_Tag';
        uaf1.NITS_Tag_Future32='NITS_Tag_Future';
        uaf1.Capacity_Tag033 = 'Capacity_Tag';
        uaf1.Capacity_Tag_Future033 = 'Capacity_Tag_Future';
        uaf1.NITS_Tag033='NITS_Tag';
        uaf1.NITS_Tag_Future033='NITS_Tag_Future';
        uaf1.Capacity_Tag34 = 'Capacity_Tag';
        uaf1.Capacity_Tag_Future34 = 'Capacity_Tag_Future';
        uaf1.NITS_Tag34='NITS_Tag';
        uaf1.NITS_Tag_Future34='NITS_Tag_Future';
        uaf1.Capacity_Tag35 = 'Capacity_Tag';
        uaf1.Capacity_Tag_Future35 = 'Capacity_Tag_Future';
        uaf1.NITS_Tag35='NITS_Tag';
        uaf1.NITS_Tag_Future35='NITS_Tag_Future';
        uaf1.Capacity_Tag36 = 'Capacity_Tag';
        uaf1.Capacity_Tag_Future36 = 'Capacity_Tag_Future';
        uaf1.NITS_Tag36='NITS_Tag';
        uaf1.NITS_Tag_Future36='NITS_Tag_Future';
        uaf1.Capacity_Tag37 = 'Capacity_Tag';
        uaf1.Capacity_Tag_Future37 = 'Capacity_Tag_Future';
        uaf1.NITS_Tag37='NITS_Tag';
        uaf1.NITS_Tag_Future37='NITS_Tag_Future';
        uaf1.Capacity_Tag38 = 'Capacity_Tag';
        uaf1.Capacity_Tag_Future38 = 'Capacity_Tag_Future';
        uaf1.NITS_Tag38='NITS_Tag';
        uaf1.NITS_Tag_Future38='NITS_Tag_Future';
        uaf1.Capacity_Tag39 = 'Capacity_Tag';
        uaf1.Capacity_Tag_Future39 = 'Capacity_Tag_Future';
        uaf1.NITS_Tag39='NITS_Tag';
        uaf1.NITS_Tag_Future39='NITS_Tag_Future';
        uaf1.Capacity_Tag40 = 'Capacity_Tag';
        uaf1.Capacity_Tag_Future40 = 'Capacity_Tag_Future';
        uaf1.NITS_Tag40='NITS_Tag';
        uaf1.NITS_Tag_Future40='NITS_Tag_Future';
        uaf1.Capacity_Tag41 = 'Capacity_Tag';
        uaf1.Capacity_Tag_Future41 = 'Capacity_Tag_Future';
        uaf1.NITS_Tag41='NITS_Tag';
        uaf1.NITS_Tag_Future41='NITS_Tag_Future';
        uaf1.Capacity_Tag42 = 'Capacity_Tag';
        uaf1.Capacity_Tag_Future42 = 'Capacity_Tag_Future';
        uaf1.NITS_Tag42='NITS_Tag';
        uaf1.NITS_Tag_Future42='NITS_Tag_Future';
        uaf1.Capacity_Tag043 = 'Capacity_Tag';
        uaf1.Capacity_Tag_Future043 = 'Capacity_Tag_Future';
        uaf1.NITS_Tag043='NITS_Tag';
        uaf1.NITS_Tag_Future043='NITS_Tag_Future';
        uaf1.Capacity_Tag044 = 'Capacity_Tag';
        uaf1.Capacity_Tag_Future044 = 'Capacity_Tag_Future';
        uaf1.NITS_Tag044='NITS_Tag';
        uaf1.NITS_Tag_Future044='NITS_Tag_Future';
        uaf1.Capacity_Tag45 = 'Capacity_Tag';
        uaf1.Capacity_Tag_Future45 = 'Capacity_Tag_Future';
        uaf1.NITS_Tag45='NITS_Tag';
        uaf1.NITS_Tag_Future45='NITS_Tag_Future';
        uaf1.Capacity_Tag46 = 'Capacity_Tag';
        uaf1.Capacity_Tag_Future46 = 'Capacity_Tag_Future';
        uaf1.NITS_Tag46='NITS_Tag';
        uaf1.NITS_Tag_Future46='NITS_Tag_Future';
        uaf1.Capacity_Tag47 = 'Capacity_Tag';
        uaf1.Capacity_Tag_Future47 = 'Capacity_Tag_Future';
        uaf1.NITS_Tag47='NITS_Tag';
        uaf1.NITS_Tag_Future47='NITS_Tag_Future';
        uaf1.Capacity_Tag48 = 'Capacity_Tag';
        uaf1.Capacity_Tag_Future48 = 'Capacity_Tag_Future';
        uaf1.NITS_Tag48='NITS_Tag';
        uaf1.NITS_Tag_Future48='NITS_Tag_Future';
        uaf1.Capacity_Tag49 = 'Capacity_Tag';
        uaf1.Capacity_Tag_Future49 = 'Capacity_Tag_Future';
        uaf1.NITS_Tag49='NITS_Tag';
        uaf1.NITS_Tag_Future49='NITS_Tag_Future';
        uaf1.Capacity_Tag50 = 'Capacity_Tag';
        uaf1.Capacity_Tag_Future50 = 'Capacity_Tag_Future';
        uaf1.NITS_Tag50='NITS_Tag';
        uaf1.NITS_Tag_Future50='NITS_Tag_Future';
        uaf1.Capacity_Tag51 = 'Capacity_Tag';
        uaf1.Capacity_Tag_Future51 = 'Capacity_Tag_Future';
        uaf1.NITS_Tag51='NITS_Tag';
        uaf1.NITS_Tag_Future51='NITS_Tag_Future';
        uaf1.Capacity_Tag52 = 'Capacity_Tag';
        uaf1.Capacity_Tag_Future52 = 'Capacity_Tag_Future';
        uaf1.NITS_Tag52='NITS_Tag';
        uaf1.NITS_Tag_Future52='NITS_Tag_Future';
        uaf1.Capacity_Tag53 = 'Capacity_Tag';
        uaf1.Capacity_Tag_Future53 = 'Capacity_Tag_Future';
        uaf1.NITS_Tag53='NITS_Tag';
        uaf1.NITS_Tag_Future53='NITS_Tag_Future';
        uaf1.Capacity_Tag54 = 'Capacity_Tag';
        uaf1.Capacity_Tag_Future54 = 'Capacity_Tag_Future';
        uaf1.NITS_Tag54='NITS_Tag';
        uaf1.NITS_Tag_Future54='NITS_Tag_Future';
        uaf1.Capacity_Tag055 = 'Capacity_Tag';
        uaf1.Capacity_Tag_Future055 = 'Capacity_Tag_Future';
        uaf1.NITS_Tag055='NITS_Tag';
        uaf1.NITS_Tag_Future055='NITS_Tag_Future';
        uaf1.Capacity_Tag56 = 'Capacity_Tag';
        uaf1.Capacity_Tag_Future56 = 'Capacity_Tag_Future';
        uaf1.NITS_Tag56='NITS_Tag';
        uaf1.NITS_Tag_Future56='NITS_Tag_Future';
        uaf1.Capacity_Tag57 = 'Capacity_Tag';
        uaf1.Capacity_Tag_Future57 = 'Capacity_Tag_Future';
        uaf1.NITS_Tag57='NITS_Tag';
        uaf1.NITS_Tag_Future57='NITS_Tag_Future';
        // processFileChunk(List<List<String>> inputCSVLines, Id recordId, Integer rowCount,String fileCSVdata,String FileName,Id PriceId,Integer finalrows,Boolean ToggleValue
        test.stopTest();
    }
 ////////////////   
    
    
    
}