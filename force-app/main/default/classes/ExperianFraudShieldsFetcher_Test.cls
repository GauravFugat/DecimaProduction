@IsTest
public class ExperianFraudShieldsFetcher_Test {

    
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
        
        ExperianFraudShieldsFetcher.ResponseWrapper wrapVar = new ExperianFraudShieldsFetcher.ResponseWrapper();
        wrapVar.success = true;
        wrapVar.requestId = '';

        
        ExperianFraudShieldsFetcher.results res1 = new ExperianFraudShieldsFetcher.results();
        res1.businessRiskTriggersIndicator = null ;
        res1.matchingBusinessAddress = '';
        res1.nameAddressVerificationIndicator = true;
        res1.businessRiskTriggersStatement = null;
        res1.bin = '';
        res1.ofacMatchWarning = null;
        
        ExperianFraudShieldsFetcher.ofacMatchWarning var2 = new ExperianFraudShieldsFetcher.ofacMatchWarning();
        var2.code = 1;
        var2.definition = '';
        var2.detailStatement = '';
        
        MockScoreResponse mockObj = new MockScoreResponse();
        mockObj.res = '{"requestId":"rrt-08009e7bdc5fde3e1-c-ea-10309-153468156-4","success":true,"results":{"businessHeader":{"bin":"700163758","businessName":"SONY MUSIC ENTERTAINMENT","address":{"street":"550 MADISON AVE FL 6","city":"NEW YORK","state":"NY","zip":"10022","zipExtension":"3211"},"phone":"+12128338000","taxId":"131914734","websiteUrl":"www.sonybmg.com","legalBusinessName":"SONY MUSIC ENTERTAINMENT","dbaNames":["SONY MUSIC ENTERTAINMENT","SONY BMG MUSIC ENTERTAINMENT","SONY HMG MUSIC ENTERTAINMENT"],"customerDisputeIndicator":false},"matchingBusinessAddress":"Primary Business","activeBusinessIndicator":true,"ofacMatchWarning":{"code":1,"definition":"No Match Found"},"businessVictimStatementIndicator":false,"businessRiskTriggersIndicator":false,"businessRiskTriggersStatement":null,"nameAddressVerificationIndicator":true}}';
        Test.setMock(HttpCalloutMock.class, mockObj);
        test.startTest();
        
        String scoredata = '{"requestId":"rrt-08009e7bdc5fde3e1-c-ea-10309-153468156-4","success":true,"results":{"businessHeader":{"bin":"700163758","businessName":"SONY MUSIC ENTERTAINMENT","address":{"street":"550 MADISON AVE FL 6","city":"NEW YORK","state":"NY","zip":"10022","zipExtension":"3211"},"phone":"+12128338000","taxId":"131914734","websiteUrl":"www.sonybmg.com","legalBusinessName":"SONY MUSIC ENTERTAINMENT","dbaNames":["SONY MUSIC ENTERTAINMENT","SONY BMG MUSIC ENTERTAINMENT","SONY HMG MUSIC ENTERTAINMENT"],"customerDisputeIndicator":false},"matchingBusinessAddress":"Primary Business","activeBusinessIndicator":true,"ofacMatchWarning":{"code":1,"definition":"No Match Found"},"businessVictimStatementIndicator":false,"businessRiskTriggersIndicator":false,"businessRiskTriggersStatement":null,"nameAddressVerificationIndicator":true}}';
  
        ExperianFraudShieldsFetcher.makeCalloutSync(CusAcc.Id);
        ExperianFraudShieldsFetcher.getBusinessFacts(new List<Id>{CusAcc.Id});
        ExperianFraudShieldsFetcher.updateFraudShields(scoredata, CusAcc.Id);
        
        //ExperianBusinessjudgementsfetcher.getBusinessFacts(new List<Id>{CusAcc.Id});
        //ExperianBusinessjudgementsfetcher.makeCallout(CusAcc.Id);
        
        test.stopTest();
        
    }
    
    
}