/* 
* @Purpose: test class for all Experian.
* @Author: Rahul Ghaytadak
* @CreatedDate: 03/15/2021
* @Related Code: ExperianBusinessFactsFetcher, ExperianLegalFilingSummariesFetcher, checkThreshold, MockCallout
* @LastModifiedDate: 03/15/2021
* @LastModifiedBy: Rahul Ghaytadak
*/

@isTest
public class Experian_testClass {
    public static testMethod void setupMethod(){
        
        
        Account acc1= new Account();
        acc1.Name = 'Test Acc';
        //acc1.Utility_Account_Number_Prefix__c  = 'TST';
        insert acc1;
        
        Marketer__c getMarketer = new Marketer__c(name = 'xyz', MarketerDunsNumber__c = 'ten');
        Insert getMarketer;
        
        EXPRN__Experian_Business__c  exp = new EXPRN__Experian_Business__c ();
        exp.EXPRN__BIN__c = '701852096';
        insert exp;
        
        Experian__c expObj = new Experian__c();
        expObj.Auth_Body__c = '{"username": "vishwanath.kodgire@aress.com.sel.staging","password": "Aress123456","client_id": "W7o3bmXvo1aZCSdD3SaMLwRw3nJzg1YB","client_secret":"xpp2lyKgfJO7kl4R"}';
        expObj.Auth_URL__c ='https://https://smartestenergy--staging.my.salesforce.com/servlet/servlet.ExternalRedirect?url=https%3A%2F%2Fsandbox-us-api.experian.com%2Foauth2%2Fv1%2Ftoken&';
        expObj.Auto_Search_URL__c='https://sandbox-us-api.experian.com/businessinformation/businesses/v1/scores/search';
        expObj.Subcode__c = '517614';
        expObj.Business_Facts_URL__c = 'https://sandbox-us-api.experian.com/businessinformation/businesses/v1/facts';
        expObj.Legal_Filings_Summary_URL__c= 'https://sandbox-us-api.experian.com/businessinformation/businesses/v1/legalcollectionsummaries';
        expObj.Fraud_Shields_URL__c = 'https://sandbox-us-api.experian.com/businessinformation/businesses/v1/fraudshields';
        expObj.Judgments_URL__c = 'https://sandbox-us-api.experian.com/businessinformation/businesses/v1/judgments';
        expObj.Liens_URL__c = 'https://sandbox-us-api.experian.com/businessinformation/businesses/v1/liens';
        expObj.Business_Search_URL__c = 'https://https://smartestenergy--staging.my.salesforce.com//servlet/servlet.ExternalRedirect?url=https%3A%2F%2Fsandbox-us-api.experian.com%2Fbusinessinformation%2Fbusinesses%2Fv1%2Fsearch&';
        expObj.Scores_EndPoint__c = 'https://sandbox-us-api.experian.com/businessinformation/businesses/v1/scores';
        insert expObj;
        
        
        Id recordTypeCus = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Customer').getRecordTypeId();
        Account CusAcc= new Account();
        CusAcc.Name = 'Test Acc1';
        CusAcc.RecordTypeId =recordTypeCus;
        CusAcc.EXPRN__Exp_Business__c = exp.Id;
        CusAcc.Customer_Credit_Limit__c =1000;
        insert CusAcc;
        
        EXPRN__Exp_Business_Info__c expBusinessInfo = new EXPRN__Exp_Business_Info__c();
        expBusinessInfo.EXPRN__Tax_Lien_filings__c = '';
        expBusinessInfo.EXPRN__Judgment_filings__c	 = '';
        expBusinessInfo.EXPRN__Bankruptcy__c = 'Yes';
        expBusinessInfo.EXPRN__Experian_Bankruptcy_Count__c = ''; 
        expBusinessInfo.EXPRN__Experian_Lien_Bal__c = '';
        expBusinessInfo.EXPRN__Experian_Judgment_Bal__c = '';
        expBusinessInfo.EXPRN__UCC_filings__c = '';
        expBusinessInfo.EXPRN__All_Collections_Count__c = '';
        expBusinessInfo.EXPRN__All_collections_147__c = '';
        expBusinessInfo.EXPRN__Account_Name__c=CusAcc.Id;
        insert expBusinessInfo;
        
        Price_File_Validation__c addValidation = new Price_File_Validation__c();
        addValidation.Validate__c = true;
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
        opp.AccountId = CusAcc.id;
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
        
       
        
        RecordType rt = [SELECT Id, Name, DeveloperName, SobjectType FROM RecordType where SobjectType = 'Pricing_Request__c' AND DeveloperName = 'Credit_Check_Required' limit 1];
        Pricing_Request__c pr = new Pricing_Request__c();
        pr.Opportunity__c = opp.Id;
        pr.Notes__c = 'Hello';
        pr.Status__c = 'Complete';
        pr.Bill_Type__c = 'Dual';
        pr.RecordTypeId = rt.Id;
        pr.Product_Lookup__c = prodObj.Id;
        pr.Customer__c = CusAcc.id;
        pr.Voluntary_RECs__c = 'Any';
        pr.Voluntary_RECs_percent__c = 100;
        
        // pr.Calculate_Credit_Limits__c = false;
        pr.Record_Created__c = true;
        
        insert pr;
        
        Price__c price = new Price__c();
        price.Credit__c = true;
        price.P_D__c = true;
        price.Subject_to_Credit__c = true;
        price.Pricing_Request__c = pr.Id;
        insert price;
        
        Date myDate = date.newInstance(2020,01,17);
        Utility_Account__c ua1 = new Utility_Account__c();
        ua1.Name = '1234567890';
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
        cc.Credit_Check_Outcome__c = 'Passed';
        insert cc;
        
        
        List<Id> accIds = new List<Id>();
        accIds.add(CusAcc.Id);
        
        List<Term_Price__c> tp = new List<Term_price__c>();
        for(Integer i=0; i<36;i++){
            Term_Price__c tp1 = new Term_Price__c();
            tp1.Price__c = price.Id;
            tp1.Cumulative_Volume__c = 2500;
            tp1.Base_Price__c = 1.555;
            tp1.Term__c = string.valueOf(i +1);
            tp1.Utility__c = acc2.Id;
            tp1.Volume__c = 5;
            tp1.Utility_Account_Opportunity__c = uao.Id;
            tp1.Opportunity__c = opp.Id;
            tp.add(tp1);
        }
        insert tp;
        
        ExperianBusinessFactsFetcher.wrapText wrp = new ExperianBusinessFactsFetcher.wrapText();
        wrp.asd = 1;
        wrp.asd1 = 1;
        wrp.asd2 = 1;
        wrp.asd3 = 1;
        wrp.asd4 = 1;
        wrp.asd5 = 1;
        wrp.asd6 = 1;
        wrp.asd7 = 1;
        wrp.asd8 = 1;
        
          ExperianBusinessFactsFetcher.wrapText1 wrp1 = new ExperianBusinessFactsFetcher.wrapText1();
        wrp1.asd = 1;
        wrp1.asd1 = 1;
        wrp1.asd2 = 1;
        wrp1.asd3 = 1;
        wrp1.asd4 = 1;
        wrp1.asd5 = 1;
        wrp1.asd6 = 1;
        wrp1.asd7 = 1;
        wrp1.asd8 = 1;
        
        Test.setMock(HttpCalloutMock.class, new MockCallout());
        test.startTest();
        ExperianLegalFilingSummariesFetcher.getBusinessFacts(accIds);
        ExperianLegalFilingSummariesFetcher.makeCallout(CusAcc.Id);
        ExperianLegalFilingSummariesFetcher.makeCalloutNew(CusAcc.Id);
        
        ExperianBusinessFactsFetcher.getBusinessFacts(accIds);
        ExperianBusinessFactsFetcher.makeCallout(CusAcc.Id);
        //ExperianBusinessFactsFetcher.makeCalloutSync(CusAcc.Id);
        
        
        test.stopTest();
        
    }
    
    
    public static testMethod void setupMethod1(){
        
        
        Account acc1= new Account();
        acc1.Name = 'Test Acc';
        //acc1.Utility_Account_Number_Prefix__c  = 'TST';
        insert acc1;
        
        Marketer__c getMarketer = new Marketer__c(name = 'xyz', MarketerDunsNumber__c = 'ten');
        Insert getMarketer;
        
        EXPRN__Experian_Business__c  exp = new EXPRN__Experian_Business__c ();
        exp.EXPRN__BIN__c = '701852096';
        insert exp;
        
        Experian__c expObj = new Experian__c();
        expObj.Auth_Body__c = '{"username": "vishwanath.kodgire@aress.com.sel.staging","password": "Aress123456","client_id": "W7o3bmXvo1aZCSdD3SaMLwRw3nJzg1YB","client_secret":"xpp2lyKgfJO7kl4R"}';
        expObj.Auth_URL__c ='https://smartestenergyus--dev5.my.salesforce.com/servlet/servlet.ExternalRedirect?url=https%3A%2F%2Fsandbox-us-api.experian.com%2Foauth2%2Fv1%2Ftoken&';
        expObj.Auto_Search_URL__c='https://sandbox-us-api.experian.com/businessinformation/businesses/v1/scores/search';
        expObj.Subcode__c = '517614';
        expObj.Business_Facts_URL__c = 'https://sandbox-us-api.experian.com/businessinformation/businesses/v1/facts';
        expObj.Legal_Filings_Summary_URL__c= 'https://sandbox-us-api.experian.com/businessinformation/businesses/v1/legalcollectionsummaries';
        expObj.Fraud_Shields_URL__c = 'https://sandbox-us-api.experian.com/businessinformation/businesses/v1/fraudshields';
        expObj.Judgments_URL__c = 'https://sandbox-us-api.experian.com/businessinformation/businesses/v1/judgments';
        expObj.Liens_URL__c = 'https://sandbox-us-api.experian.com/businessinformation/businesses/v1/liens';
        expObj.Business_Search_URL__c = 'https://smartestenergyus--dev5.my.salesforce.com/servlet/servlet.ExternalRedirect?url=https%3A%2F%2Fsandbox-us-api.experian.com%2Fbusinessinformation%2Fbusinesses%2Fv1%2Fsearch&';
        expObj.Scores_EndPoint__c = 'https://sandbox-us-api.experian.com/businessinformation/businesses/v1/scores';
        insert expObj;
        
        
        Id recordTypeCus = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Customer').getRecordTypeId();
        Account CusAcc= new Account();
        CusAcc.Name = 'Test Acc1';
        CusAcc.RecordTypeId =recordTypeCus;
        CusAcc.EXPRN__Exp_Business__c = exp.Id;
        CusAcc.Customer_Credit_Limit__c =1000;
        insert CusAcc;
        
        EXPRN__Exp_Business_Info__c expBusinessInfo = new EXPRN__Exp_Business_Info__c();
        expBusinessInfo.EXPRN__Tax_Lien_filings__c = '';
        expBusinessInfo.EXPRN__Judgment_filings__c	 = '';
        expBusinessInfo.EXPRN__Bankruptcy__c = 'Yes';
        expBusinessInfo.EXPRN__Experian_Bankruptcy_Count__c = ''; 
        expBusinessInfo.EXPRN__Experian_Lien_Bal__c = '';
        expBusinessInfo.EXPRN__Experian_Judgment_Bal__c = '';
        expBusinessInfo.EXPRN__UCC_filings__c = '';
        expBusinessInfo.EXPRN__All_Collections_Count__c = '';
        expBusinessInfo.EXPRN__All_collections_147__c = '';
        expBusinessInfo.EXPRN__Account_Name__c=CusAcc.Id;
        insert expBusinessInfo;
        
        Price_File_Validation__c addValidation = new Price_File_Validation__c();
        addValidation.Validate__c = true;
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
        opp.AccountId = CusAcc.id;
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
        
       
        
        RecordType rt = [SELECT Id, Name, DeveloperName, SobjectType FROM RecordType where SobjectType = 'Pricing_Request__c' AND DeveloperName = 'Credit_Check_Required' limit 1];
        Pricing_Request__c pr = new Pricing_Request__c();
        pr.Opportunity__c = opp.Id;
        pr.Notes__c = 'Hello';
        pr.Status__c = 'Complete';
        pr.Bill_Type__c = 'Dual';
        pr.RecordTypeId = rt.Id;
        pr.Product_Lookup__c = prodObj.Id;
        pr.Customer__c = CusAcc.id;
        pr.Voluntary_RECs__c = 'Any';
        pr.Voluntary_RECs_percent__c = 100;

        // pr.Calculate_Credit_Limits__c = false;
        pr.Record_Created__c = true;        
        
        insert pr;
        
        Price__c price = new Price__c();
        price.Credit__c = true;
        price.P_D__c = true;
        price.Subject_to_Credit__c = true;
        price.Pricing_Request__c = pr.Id;
        insert price;
        
        Date myDate = date.newInstance(2020,01,17);
        Utility_Account__c ua1 = new Utility_Account__c();
        ua1.Name = '1234567890';
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
        cc.Credit_Check_Outcome__c = 'Passed';
        insert cc;
        
        
        List<Id> accIds = new List<Id>();
        accIds.add(CusAcc.Id);
        
        List<Term_Price__c> tp = new List<Term_price__c>();
        for(Integer i=0; i<36;i++){
            Term_Price__c tp1 = new Term_Price__c();
            tp1.Price__c = price.Id;
            tp1.Cumulative_Volume__c = 2500;
            tp1.Base_Price__c = 1.555;
            tp1.Term__c = string.valueOf(i +1);
            tp1.Utility__c = acc2.Id;
            tp1.Volume__c = 5;
            tp1.Utility_Account_Opportunity__c = uao.Id;
            tp1.Opportunity__c = opp.Id;
            tp.add(tp1);
        }
        insert tp;
        
        Test.setMock(HttpCalloutMock.class, new MockScoreResponse());
        test.startTest();
        
        String scoredata = '{"requestId":"rrt-0179c636db13027e5-c-ea-19264-3751308-6","success":true,"comments":null,"results":{"businessHeader":{"bin":"711655002","businessName":"BASF CATALYSTS LLC","address":{"street":"101 WOOD AVE S","city":"ISELIN","state":"NJ","zip":"08830","zipExtension":"2749"},"phone":"+19732456000","taxId":"000952801","websiteUrl":"engelhard.com","legalBusinessName":null,"dbaNames":["BASF CORP"],"customerDisputeIndicator":false},"commercialScore":{"modelCode":"000224","modelTitle":"INTELLISCORE PLUS V2","customModelCode":"02","score":54,"percentileRanking":53,"recommendedCreditLimitAmount":2227700,"riskClass":{"code":2,"definition":"LOW TO MEDIUM RISK"}},"commercialScoreFactors":[{"code":"033","definition":"NUMBER OF COMMERCIAL ACCOUNTS THAT ARE CURRENT"},{"code":"066","definition":"PERCENT OF DELINQUENT COMMERCIAL ACCOUNTS"},{"code":"025","definition":"BALANCE OF RECENTLY DELIINQUENT COMMERCIAL ACCOUNTS"},{"code":"067","definition":"PERCENT OF SERIOUSLY DELINQUENT COMMERCIAL ACCOUNTS"}],"commercialScoreTrends":[{"quarter":"JAN-MAR","score":57},{"quarter":"OCT-DEC","score":51},{"quarter":"JUL-SEP","score":45},{"quarter":"APR-JUN","score":48}],"fsrScore":{"modelCode":"000223","modelTitle":"FINANCIAL STABILITY RISK","score":66,"percentileRanking":65,"recommendedCreditLimitAmount":null,"riskClass":{"code":1,"definition":"LOW RISK"}},"fsrScoreFactors":[{"code":"004","definition":"RISK ASSOCIATED WITH THE COMPANYS INDUSTRY SECTOR"},{"code":"016","definition":"PERCENT OF COMMERCIAL ACCOUNTS DELINQUENT"},{"code":"011","definition":"PAST COMMERCIAL DEROGATORY BALANCE"},{"code":"005","definition":"NUMBER OF COMMERCIAL DEROGATORY PUBLIC RECORDS"}],"fsrScoreTrends":[{"quarter":"JAN-MAR","score":69},{"quarter":"OCT-DEC","score":34},{"quarter":"JUL-SEP","score":33},{"quarter":"APR-JUN","score":34}],"listOfSimilars":[{"bin":"711655002","reliabilityCode":100,"businessName":"BASF CATALYSTS LLC","phone":"+19732456000","address":{"street":"101 WOOD AVE S","city":"ISELIN","state":"NJ","zip":"08830","zipExtension":"2749"},"numberOfTradelines":71,"financialStatementIndicator":false,"keyFactsIndicator":true,"inquiryIndicator":false,"bankDataIndicator":false,"governmentDataIndicator":false,"executiveSummaryIndicator":true,"uccIndicator":true,"matchingNameAndAddress":null,"businessGeocode":{"latitudeLongitudeLevel":"Roof Top Level","latitude":40.563754,"longitude":-74.328738,"msaCode":"5015","censusBlkGrpCode":"","censusTractCode":"002603","cottageIndicator":false,"congressionalDistrictCode":"06","dateLastReported":"2018-01-31"}}]}}';
  
        ExperianCreditScoreFetcher.makeCalloutAccSync(CusAcc.Id);
        ExperianCreditScoreFetcher.getCreditScores(new List<Id>{pr.Id});
        ExperianCreditScoreFetcher.makeCalloutAcc(CusAcc.Id);
        ExperianCreditScoreFetcher.makeCallout(pr.Id,opp.Id);
        ExperianCreditScoreFetcher.updateSocres(scoredata, CusAcc.Id);
 
        
        
        test.stopTest();
        
    }
    
    
    public static testMethod void setupMethod2(){
        
        
        Account acc1= new Account();
        acc1.Name = 'Test Acc';
        //acc1.Utility_Account_Number_Prefix__c  = 'TST';
        insert acc1;
        
        Marketer__c getMarketer = new Marketer__c(name = 'xyz', MarketerDunsNumber__c = 'ten');
        Insert getMarketer;
        
        EXPRN__Experian_Business__c  exp = new EXPRN__Experian_Business__c ();
        exp.EXPRN__BIN__c = '701852096';
        insert exp;
        
        Experian__c expObj = new Experian__c();
        expObj.Auth_Body__c = '{"username": "vishwanath.kodgire@aress.com.sel.staging","password": "Aress123456","client_id": "W7o3bmXvo1aZCSdD3SaMLwRw3nJzg1YB","client_secret":"xpp2lyKgfJO7kl4R"}';
        expObj.Auth_URL__c ='https://smartestenergyus--dev5.my.salesforce.com/servlet/servlet.ExternalRedirect?url=https%3A%2F%2Fsandbox-us-api.experian.com%2Foauth2%2Fv1%2Ftoken&';
        expObj.Auto_Search_URL__c='https://sandbox-us-api.experian.com/businessinformation/businesses/v1/scores/search';
        expObj.Subcode__c = '517614';
        expObj.Business_Facts_URL__c = 'https://sandbox-us-api.experian.com/businessinformation/businesses/v1/facts';
        expObj.Legal_Filings_Summary_URL__c= 'https://sandbox-us-api.experian.com/businessinformation/businesses/v1/legalcollectionsummaries';
        expObj.Fraud_Shields_URL__c = 'https://sandbox-us-api.experian.com/businessinformation/businesses/v1/fraudshields';
        expObj.Judgments_URL__c = 'https://sandbox-us-api.experian.com/businessinformation/businesses/v1/judgments';
        expObj.Liens_URL__c = 'https://sandbox-us-api.experian.com/businessinformation/businesses/v1/liens';
        expObj.Business_Search_URL__c = 'https://smartestenergyus--dev5.my.salesforce.com/servlet/servlet.ExternalRedirect?url=https%3A%2F%2Fsandbox-us-api.experian.com%2Fbusinessinformation%2Fbusinesses%2Fv1%2Fsearch&';
        expObj.Scores_EndPoint__c = 'https://sandbox-us-api.experian.com/businessinformation/businesses/v1/scores';
        insert expObj;
        
        
        Id recordTypeCus = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Customer').getRecordTypeId();
        Account CusAcc= new Account();
        CusAcc.Name = 'Test Acc1';
        CusAcc.RecordTypeId =recordTypeCus;
        CusAcc.EXPRN__Exp_Business__c = exp.Id;
        CusAcc.Customer_Credit_Limit__c =1000;
        CusAcc.Last_Successful_Experian_Legal_Filings__c =system.now().addHours(1);
        insert CusAcc;
        
        Experian_Recency_Threshold__c ERT = new Experian_Recency_Threshold__c();
        ERT.No_of_days__c = 2;
        insert ERT;
            
        EXPRN__Exp_Business_Info__c expBusinessInfo = new EXPRN__Exp_Business_Info__c();
        expBusinessInfo.EXPRN__Tax_Lien_filings__c = '10';
        expBusinessInfo.EXPRN__Judgment_filings__c	 = '45';
        expBusinessInfo.EXPRN__Bankruptcy__c = 'Yes';
        expBusinessInfo.EXPRN__Experian_Bankruptcy_Count__c = '54'; 
        expBusinessInfo.EXPRN__Experian_Lien_Bal__c = '44';
        expBusinessInfo.EXPRN__Experian_Judgment_Bal__c = '55';
        expBusinessInfo.EXPRN__UCC_filings__c = '5';
        expBusinessInfo.EXPRN__All_Collections_Count__c = '4';
        expBusinessInfo.EXPRN__All_collections_147__c = '45';
        expBusinessInfo.EXPRN__Account_Name__c=CusAcc.Id;
        insert expBusinessInfo;
        
        Price_File_Validation__c addValidation = new Price_File_Validation__c();
        addValidation.Validate__c = true;
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
        opp.AccountId = CusAcc.id;
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
        
        RecordType rt = [SELECT Id, Name, DeveloperName, SobjectType FROM RecordType where SobjectType = 'Pricing_Request__c' AND DeveloperName = 'Credit_Check_Required' limit 1];
        Pricing_Request__c pr = new Pricing_Request__c();
        pr.Opportunity__c = opp.Id;
        pr.Notes__c = 'Hello';
        pr.Status__c = 'Complete';
        pr.Bill_Type__c = 'Dual';
        pr.RecordTypeId = rt.Id;
        pr.Product_Lookup__c = prodObj.Id;
        pr.Customer__c = CusAcc.id;
        pr.Voluntary_RECs__c = 'Any';
        pr.Voluntary_RECs_percent__c = 100;
        
       // pr.Calculate_Credit_Limits__c = false;
        pr.Record_Created__c = true;
        
        insert pr;
        
        Price__c price = new Price__c();
        price.Credit__c = true;
        price.P_D__c = true;
        price.Subject_to_Credit__c = true;
        price.Pricing_Request__c = pr.Id;
        insert price;
        
        Date myDate = date.newInstance(2020,01,17);
        Utility_Account__c ua1 = new Utility_Account__c();
        ua1.Name = '1234567890';
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
        cc.Credit_Check_Outcome__c = 'Passed';
        insert cc;
        
        
        List<Id> accIds = new List<Id>();
        accIds.add(CusAcc.Id);
        
        List<Term_Price__c> tp = new List<Term_price__c>();
        for(Integer i=0; i<36;i++){
            Term_Price__c tp1 = new Term_Price__c();
            tp1.Price__c = price.Id;
            tp1.Cumulative_Volume__c = 2500;
            tp1.Base_Price__c = 1.555;
            tp1.Term__c = string.valueOf(i +1);
            tp1.Utility__c = acc2.Id;
            tp1.Volume__c = 5;
            tp1.Utility_Account_Opportunity__c = uao.Id;
            tp1.Opportunity__c = opp.Id;
            tp.add(tp1);
        }
        insert tp;
        MockCallout mk =  new MockCallout();
        String res='{"requestId":"rrt-0f7898a6c30703d75-c-ea-20546-136691396-2","success":true,"results":{"businessHeader":{"bin":"700163758","businessName":"SONY MUSIC ENTERTAINMENT","address":{"street":"550 MADISON AVE FL 6","city":"NEW YORK","state":"NY","zip":"10022","zipExtension":"3211"},"phone":"+12128338000","taxId":"131914734","websiteUrl":"www.sonybmg.com","legalBusinessName":"SONY MUSIC ENTERTAINMENT","dbaNames":["SONY MUSIC ENTERTAINMENT","SONY BMG MUSIC ENTERTAINMENT","SONY HMG MUSIC ENTERTAINMENT"],"customerDisputeIndicator":false},"sicCodes":[{"code":"8999","definition":"SERVICES, NEC"},{"code":"3652","definition":"RECORDS, AUDIO TAPES & DISKS"},{"code":"7389","definition":"BUSINESS SERVICES, NEC"}],"naicsCodes":[{"code":"541990","definition":"All Other Professional, Scientific, and Technical Services"},{"code":"334614","definition":"Software and Other Prerecorded Compact Disc, Tape, and Record Reproducing"},{"code":"512240","definition":"Sound Recording Studios"}],"publicIndicator":false,"nonProfitIndicator":false,"yearsOnFile":33,"stateOfIncorporation":"MI","dateOfIncorporation":"1991-02-28","businessType":"Corporation","employeeSize":null,"employeeSizeCode":null,"salesRevenue":null,"salesSizeCode":null,"fortune1000":{"year":null,"rank":null},"corporateLinkageType":"Headquarters/Parent","executiveInformation":[{"firstName":"DOUGLAS","middleName":"P","lastName":"MORRIS","title":"CHIEF EXECUTIVE OFFICER"},{"firstName":"AFO","middleName":null,"lastName":"VERDE","title":"CHIEF EXECUTIVE OFFICER"},{"firstName":"PATRICK","middleName":null,"lastName":"MOXEY","title":"PRESIDENT"}]}}';
        
        Test.setMock(HttpCalloutMock.class, new MockCallout());
        test.startTest();
        ExperianLegalFilingSummariesFetcher.getBusinessFacts(accIds);
        ExperianLegalFilingSummariesFetcher.makeCallout(CusAcc.Id);
        ExperianLegalFilingSummariesFetcher.makeCalloutNew(CusAcc.Id);
        
        ExperianBusinessFactsFetcher.getBusinessFacts(accIds);
        ExperianBusinessFactsFetcher.makeCallout(CusAcc.Id);
        ExperianBusinessFactsFetcher.makeCalloutSync(CusAcc.Id);
       ExperianBusinessFactsFetcher.updateBusinessFacts(res,CusAcc.Id);
        test.stopTest();
        
    }
}