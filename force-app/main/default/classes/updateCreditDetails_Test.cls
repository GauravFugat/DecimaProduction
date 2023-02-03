@IsTest
public class updateCreditDetails_Test {
    
    public static testMethod void setupMethod1(){
        
        Marketer__c getMarketer = new Marketer__c(name = 'xyz', MarketerDunsNumber__c = 'ten');
        Insert getMarketer;
        Account acc1= new Account();
        acc1.Name = 'Test Acc';
        //acc1.Utility_Account_Number_Prefix__c  = 'TST';
        insert acc1;
        
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
        expObj.Business_Search_URL__c = 'https://sandbox-us-api.experian.com/businessinformation/businesses/v1/search';
        insert expObj;
        
        Experian_Recency_Threshold__c ERT = new Experian_Recency_Threshold__c();
        ERT.No_of_days__c = 1;
        insert ERT;
        
        
        Id recordTypeCus = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Customer').getRecordTypeId();
        Account CusAcc= new Account();
        CusAcc.Name = 'Test Acc1';
        CusAcc.RecordTypeId =recordTypeCus;
        CusAcc.EXPRN__Exp_Business__c = exp.Id;
        CusAcc.Customer_Credit_Limit__c =1000;
        CusAcc.Last_Successful_Experian_Scores__c = system.now();
        CusAcc.Last_Successful_Experian_Fraud_Shields__c= system.now();
        CusAcc.Last_Successful_Experian_Business_Fact__c= system.now();
        CusAcc.Last_Successful_Experian_Judgements__c= system.now();
        CusAcc.Last_Successful_Experian_Legal_Filings__c= system.now();
        CusAcc.Last_Successful_Experian_Liens__c= system.now();
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
        pr.Status__c = 'new';
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
        cc.FSR_Score__c=999;
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
        
        List<Integration_Log__c> intLogLst = new List<Integration_Log__c>();
        Integration_Log__c intLog = new Integration_Log__c();
        intLog.EndPointURL__c = 'https://sandbox-us-api.experian.com/businessinformation/businesses/v1/search';
        intLog.Response_Body__c = '{"requestId":"rrt-0ad5395c70356c361-c-ea-19327-3406950-2","comments":null,"success":true,"results":[{"bin":"711655002","reliabilityCode":100,"businessName":"BASF CATALYSTS LLC","phone":"+19732456000","address":{"street":"101 WOOD AVE S","city":"ISELIN","state":"NJ","zip":"08830","zipExtension":"2749"},"numberOfTradelines":71,"financialStatementIndicator":false,"keyFactsIndicator":true,"inquiryIndicator":false,"bankDataIndicator":false,"governmentDataIndicator":false,"executiveSummaryIndicator":true,"uccIndicator":true,"matchingNameAndAddress":null,"businessGeocode":{"latitudeLongitudeLevel":"Roof Top Level","latitude":40.563754,"longitude":-74.328738,"msaCode":"5015","censusBlkGrpCode":"","censusTractCode":"002603","cottageIndicator":false,"congressionalDistrictCode":"06","dateLastReported":"2018-01-31"}}]}}';
        intLog.Account__c = CusAcc.Id;
        intLog.Status_Code__c = 200;
        intLogLst.add(intLog);
        
        Integration_Log__c intLogfacts = new Integration_Log__c();
        intLogfacts.EndPointURL__c = 'https://sandbox-us-api.experian.com/businessinformation/businesses/v1/facts';
        intLogfacts.Response_Body__c = '{"requestId":"rrt-0f7898a6c30703d75-c-ea-20546-136691396-2","success":true,"results":{"businessHeader":{"bin":"700163758","businessName":"SONY MUSIC ENTERTAINMENT","address":{"street":"550 MADISON AVE FL 6","city":"NEW YORK","state":"NY","zip":"10022","zipExtension":"3211"},"phone":"+12128338000","taxId":"131914734","websiteUrl":"www.sonybmg.com","legalBusinessName":"SONY MUSIC ENTERTAINMENT","dbaNames":["SONY MUSIC ENTERTAINMENT","SONY BMG MUSIC ENTERTAINMENT","SONY HMG MUSIC ENTERTAINMENT"],"customerDisputeIndicator":false},"sicCodes":[{"code":"8999","definition":"SERVICES, NEC"},{"code":"3652","definition":"RECORDS, AUDIO TAPES & DISKS"},{"code":"7389","definition":"BUSINESS SERVICES, NEC"}],"naicsCodes":[{"code":"541990","definition":"All Other Professional, Scientific, and Technical Services"},{"code":"334614","definition":"Software and Other Prerecorded Compact Disc, Tape, and Record Reproducing"},{"code":"512240","definition":"Sound Recording Studios"}],"publicIndicator":false,"nonProfitIndicator":false,"yearsOnFile":33,"stateOfIncorporation":"MI","dateOfIncorporation":"1991-02-28","businessType":"Corporation","employeeSize":null,"employeeSizeCode":null,"salesRevenue":null,"salesSizeCode":null,"fortune1000":{"year":null,"rank":null},"corporateLinkageType":"Headquarters/Parent","executiveInformation":[{"firstName":"DOUGLAS","middleName":"P","lastName":"MORRIS","title":"CHIEF EXECUTIVE OFFICER"},{"firstName":"AFO","middleName":null,"lastName":"VERDE","title":"CHIEF EXECUTIVE OFFICER"},{"firstName":"PATRICK","middleName":null,"lastName":"MOXEY","title":"PRESIDENT"}]}}';
        intLogfacts.Account__c = CusAcc.Id;
        intLogfacts.Status_Code__c = 200;
        intLogLst.add(intLogfacts);
        
        Integration_Log__c intLogScore = new Integration_Log__c();
        //intLogScore.EndPointURL__c = 'https://sandbox-us-api.experian.com/businessinformation/businesses/v1/scores/search';
        intLogScore.Response_Body__c = '{"requestId":"rrt-0f63683ebc491fca4-b-ea-16993-7363800-8","success":true,"comments":null,"results":{"businessHeader":{"bin":"882980499","businessName":"KEYBANK","address":{"street":"100 DUTCH HILL RD","city":"ORANGEBURG","state":"NY","zip":"10962","zipExtension":"2197"},"phone":null,"taxId":null,"websiteUrl":"key.com","legalBusinessName":"KEYBANK","dbaNames":["KEYBANK NA","FIRST NIAGARA BANK NA","FIRST NIAGARA SPECIALTY INSURANCE AGENCY","KEYBANK NA","KEYBANK N A","KEY BANK NA","KEYBANK NATL ASSN","KEYCORP INSURANCE AGENCY USA INC INC","HARLEYSVILLE NATIONAL BANK","EAST PENN BANK"],"customerDisputeIndicator":false},"commercialScore":{"modelCode":"000224","modelTitle":"INTELLISCORE PLUS V2","customModelCode":"02","score":64,"percentileRanking":63,"recommendedCreditLimitAmount":2784600,"riskClass":{"code":2,"definition":"LOW TO MEDIUM RISK"}},"commercialScoreFactors":[{"code":"033","definition":"NUMBER OF COMMERCIAL ACCOUNTS THAT ARE CURRENT"},{"code":"066","definition":"PERCENT OF DELINQUENT COMMERCIAL ACCOUNTS"},{"code":"012","definition":"NUMBER OF COMMERCIAL COLLECTION ACCOUNTS RECENTLY PLACED"},{"code":"067","definition":"PERCENT OF SERIOUSLY DELINQUENT COMMERCIAL ACCOUNTS"}],"commercialScoreTrends":[{"quarter":"JAN-MAR","score":58},{"quarter":"OCT-DEC","score":57},{"quarter":"JUL-SEP","score":66},{"quarter":"APR-JUN","score":56}],"fsrScore":{"modelCode":"000223","modelTitle":"FINANCIAL STABILITY RISK","score":32,"percentileRanking":31,"recommendedCreditLimitAmount":null,"riskClass":{"code":2,"definition":"LOW TO MEDIUM RISK"}},"fsrScoreFactors":[{"code":"001","definition":"NUMBER OF COMMERCIAL COLLECTION ACCOUNTS"},{"code":"005","definition":"NUMBER OF COMMERCIAL DEROGATORY PUBLIC RECORDS"},{"code":"002","definition":"RISK ASSOCIATED WITH THE BUSINESS TYPE"},{"code":"014","definition":"PERCENT OF TOTAL COMMERCIAL BALANCE MODERATELY DELINQ"}],"fsrScoreTrends":[{"quarter":"JAN-MAR","score":31},{"quarter":"OCT-DEC","score":32},{"quarter":"JUL-SEP","score":33},{"quarter":"APR-JUN","score":29}],"listOfSimilars":[{"bin":"882980499","reliabilityCode":100,"businessName":"KEYBANK","phone":null,"address":{"street":"100 DUTCH HILL RD","city":"ORANGEBURG","state":"NY","zip":"10962","zipExtension":"2197"},"numberOfTradelines":124,"financialStatementIndicator":false,"keyFactsIndicator":true,"inquiryIndicator":true,"bankDataIndicator":true,"governmentDataIndicator":false,"executiveSummaryIndicator":true,"uccIndicator":true,"matchingNameAndAddress":null,"businessGeocode":{"latitudeLongitudeLevel":"Roof Top Level","latitude":41.044063,"longitude":-73.954865,"msaCode":"5600","censusBlkGrpCode":"","censusTractCode":"013002","cottageIndicator":false,"congressionalDistrictCode":"17","dateLastReported":"2017-06-01"}}]}}';
        intLogScore.Response_Body__c = '{"requestId":"rrt-0f63683ebc491fca4-b-ea-16993-7363800-8","success":true,"comments":null,"results":{"businessHeader":{"bin":"882980499","businessName":"KEYBANK","address":{"street":"100 DUTCH HILL RD","city":"ORANGEBURG","state":"NY","zip":"10962","zipExtension":"2197"},"phone":null,"taxId":null,"websiteUrl":"key.com","legalBusinessName":"KEYBANK","dbaNames":["KEYBANK NA","FIRST NIAGARA BANK NA","FIRST NIAGARA SPECIALTY INSURANCE AGENCY","KEYBANK NA","KEYBANK N A","KEY BANK NA","KEYBANK NATL ASSN","KEYCORP INSURANCE AGENCY USA INC INC","HARLEYSVILLE NATIONAL BANK","EAST PENN BANK"],"customerDisputeIndicator":false},"commercialScore":{"modelCode":"000224","modelTitle":"INTELLISCORE PLUS V2","customModelCode":"02","score":999,"percentileRanking":63,"recommendedCreditLimitAmount":2784600,"riskClass":{"code":2,"definition":"LOW TO MEDIUM RISK"}},"commercialScoreFactors":[{"code":"033","definition":"NUMBER OF COMMERCIAL ACCOUNTS THAT ARE CURRENT"},{"code":"066","definition":"PERCENT OF DELINQUENT COMMERCIAL ACCOUNTS"},{"code":"012","definition":"NUMBER OF COMMERCIAL COLLECTION ACCOUNTS RECENTLY PLACED"},{"code":"067","definition":"PERCENT OF SERIOUSLY DELINQUENT COMMERCIAL ACCOUNTS"}],"commercialScoreTrends":[{"quarter":"JAN-MAR","score":999},{"quarter":"OCT-DEC","score":999},{"quarter":"JUL-SEP","score":999},{"quarter":"APR-JUN","score":999}],"fsrScore":{"modelCode":"000223","modelTitle":"FINANCIAL STABILITY RISK","score":999,"percentileRanking":31,"recommendedCreditLimitAmount":null,"riskClass":{"code":2,"definition":"LOW TO MEDIUM RISK"}},"fsrScoreFactors":[{"code":"001","definition":"NUMBER OF COMMERCIAL COLLECTION ACCOUNTS"},{"code":"005","definition":"NUMBER OF COMMERCIAL DEROGATORY PUBLIC RECORDS"},{"code":"002","definition":"RISK ASSOCIATED WITH THE BUSINESS TYPE"},{"code":"014","definition":"PERCENT OF TOTAL COMMERCIAL BALANCE MODERATELY DELINQ"}],"fsrScoreTrends":[{"quarter":"JAN-MAR","score":999},{"quarter":"OCT-DEC","score":999},{"quarter":"JUL-SEP","score":999},{"quarter":"APR-JUN","score":999}],"listOfSimilars":[{"bin":"882980499","reliabilityCode":100,"businessName":"KEYBANK","phone":null,"address":{"street":"100 DUTCH HILL RD","city":"ORANGEBURG","state":"NY","zip":"10962","zipExtension":"2197"},"numberOfTradelines":124,"financialStatementIndicator":false,"keyFactsIndicator":true,"inquiryIndicator":true,"bankDataIndicator":true,"governmentDataIndicator":false,"executiveSummaryIndicator":true,"uccIndicator":true,"matchingNameAndAddress":null,"businessGeocode":{"latitudeLongitudeLevel":"Roof Top Level","latitude":41.044063,"longitude":-73.954865,"msaCode":"5600","censusBlkGrpCode":"","censusTractCode":"013002","cottageIndicator":false,"congressionalDistrictCode":"17","dateLastReported":"2017-06-01"}}]}}';
        intLogScore.Account__c = CusAcc.Id;
        intLogScore.Status_Code__c = 200;
        intLogLst.add(intLogScore);
        
        Integration_Log__c intLogfraud = new Integration_Log__c();
        intLogfraud.EndPointURL__c = 'https://sandbox-us-api.experian.com/businessinformation/businesses/v1/fraudshields';
        intLogfraud.Response_Body__c = '{"requestId":"rrt-08009e7bdc5fde3e1-c-ea-10309-153468156-4","success":true,"results":{"businessHeader":{"bin":"700163758","businessName":"SONY MUSIC ENTERTAINMENT","address":{"street":"550 MADISON AVE FL 6","city":"NEW YORK","state":"NY","zip":"10022","zipExtension":"3211"},"phone":"+12128338000","taxId":"131914734","websiteUrl":"www.sonybmg.com","legalBusinessName":"SONY MUSIC ENTERTAINMENT","dbaNames":["SONY MUSIC ENTERTAINMENT","SONY BMG MUSIC ENTERTAINMENT","SONY HMG MUSIC ENTERTAINMENT"],"customerDisputeIndicator":false},"matchingBusinessAddress":"Primary Business","activeBusinessIndicator":true,"ofacMatchWarning":{"code":1,"definition":"No Match Found"},"businessVictimStatementIndicator":false,"businessRiskTriggersIndicator":false,"businessRiskTriggersStatement":null,"nameAddressVerificationIndicator":true}}';
        intLogfraud.Account__c = CusAcc.Id;
        intLogfraud.Status_Code__c = 200;
        intLogLst.add(intLogfraud);
        insert intLogLst;
        
        EXPRN__Exp_Business_Info__c expInfo = new EXPRN__Exp_Business_Info__c();
        expInfo.EXPRN__Financial_Stability_Risk__c = '37';
        expInfo.EXPRN__sbcs_score__c =  '32';
        expInfo.EXPRN__Account_Name__c = CusAcc.Id;
        expInfo.EXPRN__FSR_Score_Change__c = '21';
        expInfo.EXPRN__Score_Change__c = '21';
        insert expInfo;
        
        
        MockScoreResponse mockObj = new MockScoreResponse();
        mockObj.res = '{"requestId":"rrt-0ad5395c70356c361-c-ea-19327-3406950-2","comments":null,"success":true,"results":[{"bin":"711655002","reliabilityCode":100,"businessName":"BASF CATALYSTS LLC","phone":"+19732456000","address":{"street":"101 WOOD AVE S","city":"ISELIN","state":"NJ","zip":"08830","zipExtension":"2749"},"numberOfTradelines":71,"financialStatementIndicator":false,"keyFactsIndicator":true,"inquiryIndicator":false,"bankDataIndicator":false,"governmentDataIndicator":false,"executiveSummaryIndicator":true,"uccIndicator":true,"matchingNameAndAddress":null,"businessGeocode":{"latitudeLongitudeLevel":"Roof Top Level","latitude":40.563754,"longitude":-74.328738,"msaCode":"5015","censusBlkGrpCode":"","censusTractCode":"002603","cottageIndicator":false,"congressionalDistrictCode":"06","dateLastReported":"2018-01-31"}}]}}';
        Test.setMock(HttpCalloutMock.class, mockObj);
        test.startTest();
        
        String scoredata = '{"requestId":"rrt-0ad5395c70356c361-c-ea-19327-3406950-2","comments":null,"success":true,"results":[{"bin":"711655002","reliabilityCode":100,"businessName":"BASF CATALYSTS LLC","phone":"+19732456000","address":{"street":"101 WOOD AVE S","city":"ISELIN","state":"NJ","zip":"08830","zipExtension":"2749"},"numberOfTradelines":71,"financialStatementIndicator":false,"keyFactsIndicator":true,"inquiryIndicator":false,"bankDataIndicator":false,"governmentDataIndicator":false,"executiveSummaryIndicator":true,"uccIndicator":true,"matchingNameAndAddress":null,"businessGeocode":{"latitudeLongitudeLevel":"Roof Top Level","latitude":40.563754,"longitude":-74.328738,"msaCode":"5015","censusBlkGrpCode":"","censusTractCode":"002603","cottageIndicator":false,"congressionalDistrictCode":"06","dateLastReported":"2018-01-31"}}]}}';
        
        updateCreditDetails.callExperianCreditAssessment(new List<Id>{cc.Id});
        
        String prListToUpdate = JSON.serialize(new List<Pricing_Request__c>{pr});
        updateCreditDetails.callExperianSync(cc.Id, prListToUpdate, true, price);
        updateCreditDetails.codeCvrMeth();
        test.stopTest();
        
    }
    
    /* public static testMethod void setupMethod2(){

Marketer__c getMarketer = new Marketer__c(name = 'xyz', MarketerDunsNumber__c = 'ten');
Insert getMarketer;
Account acc1= new Account();
acc1.Name = 'Test Acc';
//acc1.Utility_Account_Number_Prefix__c  = 'TST';
insert acc1;

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
expObj.Business_Search_URL__c = 'https://sandbox-us-api.experian.com/businessinformation/businesses/v1/search';
insert expObj;

Experian_Recency_Threshold__c ERT = new Experian_Recency_Threshold__c();
ERT.No_of_days__c = 1;
insert ERT;


Id recordTypeCus = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Customer').getRecordTypeId();
Account CusAcc= new Account();
CusAcc.Name = 'Test Acc1';
CusAcc.RecordTypeId =recordTypeCus;
CusAcc.EXPRN__Exp_Business__c = exp.Id;
CusAcc.Customer_Credit_Limit__c =1000;
// CusAcc.Last_Successful_Experian_Scores__c = system.now();
CusAcc.Last_Successful_Experian_Fraud_Shields__c= system.now();
CusAcc.Last_Successful_Experian_Business_Fact__c= system.now();
CusAcc.Last_Successful_Experian_Judgements__c= system.now();
CusAcc.Last_Successful_Experian_Legal_Filings__c= system.now();
CusAcc.Last_Successful_Experian_Liens__c= system.now();
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
pr.Status__c = 'new';
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

List<Integration_Log__c> intLogLst = new List<Integration_Log__c>();
Integration_Log__c intLog = new Integration_Log__c();
intLog.EndPointURL__c = 'https://sandbox-us-api.experian.com/businessinformation/businesses/v1/search';
intLog.Response_Body__c = '{"requestId":"rrt-0ad5395c70356c361-c-ea-19327-3406950-2","comments":null,"success":true,"results":[{"bin":"711655002","reliabilityCode":100,"businessName":"BASF CATALYSTS LLC","phone":"+19732456000","address":{"street":"101 WOOD AVE S","city":"ISELIN","state":"NJ","zip":"08830","zipExtension":"2749"},"numberOfTradelines":71,"financialStatementIndicator":false,"keyFactsIndicator":true,"inquiryIndicator":false,"bankDataIndicator":false,"governmentDataIndicator":false,"executiveSummaryIndicator":true,"uccIndicator":true,"matchingNameAndAddress":null,"businessGeocode":{"latitudeLongitudeLevel":"Roof Top Level","latitude":40.563754,"longitude":-74.328738,"msaCode":"5015","censusBlkGrpCode":"","censusTractCode":"002603","cottageIndicator":false,"congressionalDistrictCode":"06","dateLastReported":"2018-01-31"}}]}}';
intLog.Account__c = CusAcc.Id;
intLog.Status_Code__c = 200;
intLogLst.add(intLog);

Integration_Log__c intLogfacts = new Integration_Log__c();
intLogfacts.EndPointURL__c = 'https://sandbox-us-api.experian.com/businessinformation/businesses/v1/facts';
intLogfacts.Response_Body__c = '{"requestId":"rrt-0f7898a6c30703d75-c-ea-20546-136691396-2","success":true,"results":{"businessHeader":{"bin":"700163758","businessName":"SONY MUSIC ENTERTAINMENT","address":{"street":"550 MADISON AVE FL 6","city":"NEW YORK","state":"NY","zip":"10022","zipExtension":"3211"},"phone":"+12128338000","taxId":"131914734","websiteUrl":"www.sonybmg.com","legalBusinessName":"SONY MUSIC ENTERTAINMENT","dbaNames":["SONY MUSIC ENTERTAINMENT","SONY BMG MUSIC ENTERTAINMENT","SONY HMG MUSIC ENTERTAINMENT"],"customerDisputeIndicator":false},"sicCodes":[{"code":"8999","definition":"SERVICES, NEC"},{"code":"3652","definition":"RECORDS, AUDIO TAPES & DISKS"},{"code":"7389","definition":"BUSINESS SERVICES, NEC"}],"naicsCodes":[{"code":"541990","definition":"All Other Professional, Scientific, and Technical Services"},{"code":"334614","definition":"Software and Other Prerecorded Compact Disc, Tape, and Record Reproducing"},{"code":"512240","definition":"Sound Recording Studios"}],"publicIndicator":false,"nonProfitIndicator":false,"yearsOnFile":33,"stateOfIncorporation":"MI","dateOfIncorporation":"1991-02-28","businessType":"Corporation","employeeSize":null,"employeeSizeCode":null,"salesRevenue":null,"salesSizeCode":null,"fortune1000":{"year":null,"rank":null},"corporateLinkageType":"Headquarters/Parent","executiveInformation":[{"firstName":"DOUGLAS","middleName":"P","lastName":"MORRIS","title":"CHIEF EXECUTIVE OFFICER"},{"firstName":"AFO","middleName":null,"lastName":"VERDE","title":"CHIEF EXECUTIVE OFFICER"},{"firstName":"PATRICK","middleName":null,"lastName":"MOXEY","title":"PRESIDENT"}]}}';
intLogfacts.Account__c = CusAcc.Id;
intLogfacts.Status_Code__c = 200;
intLogLst.add(intLogfacts);

Integration_Log__c intLogScore = new Integration_Log__c();
intLogScore.EndPointURL__c = 'https://sandbox-us-api.experian.com/businessinformation/businesses/v1/scores/search';
intLogScore.Response_Body__c = '{"requestId":"rrt-0f63683ebc491fca4-b-ea-16993-7363800-8","success":true,"comments":null,"results":{"businessHeader":{"bin":"882980499","businessName":"KEYBANK","address":{"street":"100 DUTCH HILL RD","city":"ORANGEBURG","state":"NY","zip":"10962","zipExtension":"2197"},"phone":null,"taxId":null,"websiteUrl":"key.com","legalBusinessName":"KEYBANK","dbaNames":["KEYBANK NA","FIRST NIAGARA BANK NA","FIRST NIAGARA SPECIALTY INSURANCE AGENCY","KEYBANK NA","KEYBANK N A","KEY BANK NA","KEYBANK NATL ASSN","KEYCORP INSURANCE AGENCY USA INC INC","HARLEYSVILLE NATIONAL BANK","EAST PENN BANK"],"customerDisputeIndicator":false},"commercialScore":{"modelCode":"000224","modelTitle":"INTELLISCORE PLUS V2","customModelCode":"02","score":64,"percentileRanking":63,"recommendedCreditLimitAmount":2784600,"riskClass":{"code":2,"definition":"LOW TO MEDIUM RISK"}},"commercialScoreFactors":[{"code":"033","definition":"NUMBER OF COMMERCIAL ACCOUNTS THAT ARE CURRENT"},{"code":"066","definition":"PERCENT OF DELINQUENT COMMERCIAL ACCOUNTS"},{"code":"012","definition":"NUMBER OF COMMERCIAL COLLECTION ACCOUNTS RECENTLY PLACED"},{"code":"067","definition":"PERCENT OF SERIOUSLY DELINQUENT COMMERCIAL ACCOUNTS"}],"commercialScoreTrends":[{"quarter":"JAN-MAR","score":58},{"quarter":"OCT-DEC","score":57},{"quarter":"JUL-SEP","score":66},{"quarter":"APR-JUN","score":56}],"fsrScore":{"modelCode":"000223","modelTitle":"FINANCIAL STABILITY RISK","score":32,"percentileRanking":31,"recommendedCreditLimitAmount":null,"riskClass":{"code":2,"definition":"LOW TO MEDIUM RISK"}},"fsrScoreFactors":[{"code":"001","definition":"NUMBER OF COMMERCIAL COLLECTION ACCOUNTS"},{"code":"005","definition":"NUMBER OF COMMERCIAL DEROGATORY PUBLIC RECORDS"},{"code":"002","definition":"RISK ASSOCIATED WITH THE BUSINESS TYPE"},{"code":"014","definition":"PERCENT OF TOTAL COMMERCIAL BALANCE MODERATELY DELINQ"}],"fsrScoreTrends":[{"quarter":"JAN-MAR","score":31},{"quarter":"OCT-DEC","score":32},{"quarter":"JUL-SEP","score":33},{"quarter":"APR-JUN","score":29}],"listOfSimilars":[{"bin":"882980499","reliabilityCode":100,"businessName":"KEYBANK","phone":null,"address":{"street":"100 DUTCH HILL RD","city":"ORANGEBURG","state":"NY","zip":"10962","zipExtension":"2197"},"numberOfTradelines":124,"financialStatementIndicator":false,"keyFactsIndicator":true,"inquiryIndicator":true,"bankDataIndicator":true,"governmentDataIndicator":false,"executiveSummaryIndicator":true,"uccIndicator":true,"matchingNameAndAddress":null,"businessGeocode":{"latitudeLongitudeLevel":"Roof Top Level","latitude":41.044063,"longitude":-73.954865,"msaCode":"5600","censusBlkGrpCode":"","censusTractCode":"013002","cottageIndicator":false,"congressionalDistrictCode":"17","dateLastReported":"2017-06-01"}}]}}';
intLogScore.Account__c = CusAcc.Id;
intLogScore.Status_Code__c = 200;
intLogLst.add(intLogScore);

Integration_Log__c intLogfraud = new Integration_Log__c();
intLogfraud.EndPointURL__c = 'https://sandbox-us-api.experian.com/businessinformation/businesses/v1/fraudshields';
intLogfraud.Response_Body__c = '{"requestId":"rrt-08009e7bdc5fde3e1-c-ea-10309-153468156-4","success":true,"results":{"businessHeader":{"bin":"700163758","businessName":"SONY MUSIC ENTERTAINMENT","address":{"street":"550 MADISON AVE FL 6","city":"NEW YORK","state":"NY","zip":"10022","zipExtension":"3211"},"phone":"+12128338000","taxId":"131914734","websiteUrl":"www.sonybmg.com","legalBusinessName":"SONY MUSIC ENTERTAINMENT","dbaNames":["SONY MUSIC ENTERTAINMENT","SONY BMG MUSIC ENTERTAINMENT","SONY HMG MUSIC ENTERTAINMENT"],"customerDisputeIndicator":false},"matchingBusinessAddress":"Primary Business","activeBusinessIndicator":true,"ofacMatchWarning":{"code":1,"definition":"No Match Found"},"businessVictimStatementIndicator":false,"businessRiskTriggersIndicator":false,"businessRiskTriggersStatement":null,"nameAddressVerificationIndicator":true}}';
intLogfraud.Account__c = CusAcc.Id;
intLogfraud.Status_Code__c = 200;
intLogLst.add(intLogfraud);
insert intLogLst;

EXPRN__Exp_Business_Info__c expInfo = new EXPRN__Exp_Business_Info__c();
expInfo.EXPRN__Financial_Stability_Risk__c = '67';
expInfo.EXPRN__sbcs_score__c =  '32';
expInfo.EXPRN__Account_Name__c = CusAcc.Id;
expInfo.EXPRN__FSR_Score_Change__c = '21';
expInfo.EXPRN__Score_Change__c = '21';
insert expInfo;


MockScoreResponse mockObj = new MockScoreResponse();
mockObj.res = '{"requestId":"rrt-0f63683ebc491fca4-b-ea-16993-7363800-8","success":true,"comments":null,"results":{"businessHeader":{"bin":"882980499","businessName":"KEYBANK","address":{"street":"100 DUTCH HILL RD","city":"ORANGEBURG","state":"NY","zip":"10962","zipExtension":"2197"},"phone":null,"taxId":null,"websiteUrl":"key.com","legalBusinessName":"KEYBANK","dbaNames":["KEYBANK NA","FIRST NIAGARA BANK NA","FIRST NIAGARA SPECIALTY INSURANCE AGENCY","KEYBANK NA","KEYBANK N A","KEY BANK NA","KEYBANK NATL ASSN","KEYCORP INSURANCE AGENCY USA INC INC","HARLEYSVILLE NATIONAL BANK","EAST PENN BANK"],"customerDisputeIndicator":false},"commercialScore":{"modelCode":"000224","modelTitle":"INTELLISCORE PLUS V2","customModelCode":"02","score":64,"percentileRanking":63,"recommendedCreditLimitAmount":2784600,"riskClass":{"code":2,"definition":"LOW TO MEDIUM RISK"}},"commercialScoreFactors":[{"code":"033","definition":"NUMBER OF COMMERCIAL ACCOUNTS THAT ARE CURRENT"},{"code":"066","definition":"PERCENT OF DELINQUENT COMMERCIAL ACCOUNTS"},{"code":"012","definition":"NUMBER OF COMMERCIAL COLLECTION ACCOUNTS RECENTLY PLACED"},{"code":"067","definition":"PERCENT OF SERIOUSLY DELINQUENT COMMERCIAL ACCOUNTS"}],"commercialScoreTrends":[{"quarter":"JAN-MAR","score":58},{"quarter":"OCT-DEC","score":57},{"quarter":"JUL-SEP","score":66},{"quarter":"APR-JUN","score":56}],"fsrScore":{"modelCode":"000223","modelTitle":"FINANCIAL STABILITY RISK","score":32,"percentileRanking":31,"recommendedCreditLimitAmount":null,"riskClass":{"code":2,"definition":"LOW TO MEDIUM RISK"}},"fsrScoreFactors":[{"code":"001","definition":"NUMBER OF COMMERCIAL COLLECTION ACCOUNTS"},{"code":"005","definition":"NUMBER OF COMMERCIAL DEROGATORY PUBLIC RECORDS"},{"code":"002","definition":"RISK ASSOCIATED WITH THE BUSINESS TYPE"},{"code":"014","definition":"PERCENT OF TOTAL COMMERCIAL BALANCE MODERATELY DELINQ"}],"fsrScoreTrends":[{"quarter":"JAN-MAR","score":31},{"quarter":"OCT-DEC","score":32},{"quarter":"JUL-SEP","score":33},{"quarter":"APR-JUN","score":29}],"listOfSimilars":[{"bin":"882980499","reliabilityCode":100,"businessName":"KEYBANK","phone":null,"address":{"street":"100 DUTCH HILL RD","city":"ORANGEBURG","state":"NY","zip":"10962","zipExtension":"2197"},"numberOfTradelines":124,"financialStatementIndicator":false,"keyFactsIndicator":true,"inquiryIndicator":true,"bankDataIndicator":true,"governmentDataIndicator":false,"executiveSummaryIndicator":true,"uccIndicator":true,"matchingNameAndAddress":null,"businessGeocode":{"latitudeLongitudeLevel":"Roof Top Level","latitude":41.044063,"longitude":-73.954865,"msaCode":"5600","censusBlkGrpCode":"","censusTractCode":"013002","cottageIndicator":false,"congressionalDistrictCode":"17","dateLastReported":"2017-06-01"}}]}}';
Test.setMock(HttpCalloutMock.class, mockObj);
test.startTest();



updateCreditDetails.callExperianCreditAssessment(new List<Id>{cc.Id});

String prListToUpdate = JSON.serialize(new List<Pricing_Request__c>{pr});
updateCreditDetails.callExperianSync(cc.Id, prListToUpdate, true, price);

test.stopTest();

} */
    
    public static testMethod void setupMethod3(){
        
        Marketer__c getMarketer = new Marketer__c(name = 'xyz', MarketerDunsNumber__c = 'ten');
        Insert getMarketer;
        Account acc1= new Account();
        acc1.Name = 'Test Acc';
        //acc1.Utility_Account_Number_Prefix__c  = 'TST';
        insert acc1;
        
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
        expObj.Business_Search_URL__c = 'https://sandbox-us-api.experian.com/businessinformation/businesses/v1/search';
        insert expObj;
        
        Experian_Recency_Threshold__c ERT = new Experian_Recency_Threshold__c();
        ERT.No_of_days__c = 1;
        insert ERT;
        
        
        Id recordTypeCus = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Customer').getRecordTypeId();
        Account CusAcc= new Account();
        CusAcc.Name = 'Test Acc1';
        CusAcc.RecordTypeId =recordTypeCus;
        CusAcc.EXPRN__Exp_Business__c = exp.Id;
        CusAcc.Customer_Credit_Limit__c =1000;
        CusAcc.Last_Successful_Experian_Scores__c = system.now();
        //CusAcc.Last_Successful_Experian_Fraud_Shields__c= system.now();
        CusAcc.Last_Successful_Experian_Business_Fact__c= system.now();
        CusAcc.Last_Successful_Experian_Judgements__c= system.now();
        CusAcc.Last_Successful_Experian_Legal_Filings__c= system.now();
        CusAcc.Last_Successful_Experian_Liens__c= system.now();
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
        pr.Status__c = 'new';
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
        cc.IP_Score__c=999;
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
        
        List<Integration_Log__c> intLogLst = new List<Integration_Log__c>();
        Integration_Log__c intLog = new Integration_Log__c();
        intLog.EndPointURL__c = 'https://sandbox-us-api.experian.com/businessinformation/businesses/v1/search';
        intLog.Response_Body__c = '{"requestId":"rrt-0ad5395c70356c361-c-ea-19327-3406950-2","comments":null,"success":true,"results":[{"bin":"711655002","reliabilityCode":100,"businessName":"BASF CATALYSTS LLC","phone":"+19732456000","address":{"street":"101 WOOD AVE S","city":"ISELIN","state":"NJ","zip":"08830","zipExtension":"2749"},"numberOfTradelines":71,"financialStatementIndicator":false,"keyFactsIndicator":true,"inquiryIndicator":false,"bankDataIndicator":false,"governmentDataIndicator":false,"executiveSummaryIndicator":true,"uccIndicator":true,"matchingNameAndAddress":null,"businessGeocode":{"latitudeLongitudeLevel":"Roof Top Level","latitude":40.563754,"longitude":-74.328738,"msaCode":"5015","censusBlkGrpCode":"","censusTractCode":"002603","cottageIndicator":false,"congressionalDistrictCode":"06","dateLastReported":"2018-01-31"}}]}}';
        intLog.Account__c = CusAcc.Id;
        intLog.Status_Code__c = 200;
        intLogLst.add(intLog);
        
        Integration_Log__c intLogfacts = new Integration_Log__c();
        intLogfacts.EndPointURL__c = 'https://sandbox-us-api.experian.com/businessinformation/businesses/v1/facts';
        intLogfacts.Response_Body__c = '{"requestId":"rrt-0f7898a6c30703d75-c-ea-20546-136691396-2","success":true,"results":{"businessHeader":{"bin":"700163758","businessName":"SONY MUSIC ENTERTAINMENT","address":{"street":"550 MADISON AVE FL 6","city":"NEW YORK","state":"NY","zip":"10022","zipExtension":"3211"},"phone":"+12128338000","taxId":"131914734","websiteUrl":"www.sonybmg.com","legalBusinessName":"SONY MUSIC ENTERTAINMENT","dbaNames":["SONY MUSIC ENTERTAINMENT","SONY BMG MUSIC ENTERTAINMENT","SONY HMG MUSIC ENTERTAINMENT"],"customerDisputeIndicator":false},"sicCodes":[{"code":"8999","definition":"SERVICES, NEC"},{"code":"3652","definition":"RECORDS, AUDIO TAPES & DISKS"},{"code":"7389","definition":"BUSINESS SERVICES, NEC"}],"naicsCodes":[{"code":"541990","definition":"All Other Professional, Scientific, and Technical Services"},{"code":"334614","definition":"Software and Other Prerecorded Compact Disc, Tape, and Record Reproducing"},{"code":"512240","definition":"Sound Recording Studios"}],"publicIndicator":false,"nonProfitIndicator":false,"yearsOnFile":33,"stateOfIncorporation":"MI","dateOfIncorporation":"1991-02-28","businessType":"Corporation","employeeSize":null,"employeeSizeCode":null,"salesRevenue":null,"salesSizeCode":null,"fortune1000":{"year":null,"rank":null},"corporateLinkageType":"Headquarters/Parent","executiveInformation":[{"firstName":"DOUGLAS","middleName":"P","lastName":"MORRIS","title":"CHIEF EXECUTIVE OFFICER"},{"firstName":"AFO","middleName":null,"lastName":"VERDE","title":"CHIEF EXECUTIVE OFFICER"},{"firstName":"PATRICK","middleName":null,"lastName":"MOXEY","title":"PRESIDENT"}]}}';
        intLogfacts.Account__c = CusAcc.Id;
        intLogfacts.Status_Code__c = 200;
        intLogLst.add(intLogfacts);
        
        Integration_Log__c intLogScore = new Integration_Log__c();
        intLogScore.EndPointURL__c = 'https://sandbox-us-api.experian.com/businessinformation/businesses/v1/scores/search';
        intLogScore.Response_Body__c = '{"requestId":"rrt-0f63683ebc491fca4-b-ea-16993-7363800-8","success":true,"comments":null,"results":{"businessHeader":{"bin":"882980499","businessName":"KEYBANK","address":{"street":"100 DUTCH HILL RD","city":"ORANGEBURG","state":"NY","zip":"10962","zipExtension":"2197"},"phone":null,"taxId":null,"websiteUrl":"key.com","legalBusinessName":"KEYBANK","dbaNames":["KEYBANK NA","FIRST NIAGARA BANK NA","FIRST NIAGARA SPECIALTY INSURANCE AGENCY","KEYBANK NA","KEYBANK N A","KEY BANK NA","KEYBANK NATL ASSN","KEYCORP INSURANCE AGENCY USA INC INC","HARLEYSVILLE NATIONAL BANK","EAST PENN BANK"],"customerDisputeIndicator":false},"commercialScore":{"modelCode":"000224","modelTitle":"INTELLISCORE PLUS V2","customModelCode":"02","score":64,"percentileRanking":63,"recommendedCreditLimitAmount":2784600,"riskClass":{"code":2,"definition":"LOW TO MEDIUM RISK"}},"commercialScoreFactors":[{"code":"033","definition":"NUMBER OF COMMERCIAL ACCOUNTS THAT ARE CURRENT"},{"code":"066","definition":"PERCENT OF DELINQUENT COMMERCIAL ACCOUNTS"},{"code":"012","definition":"NUMBER OF COMMERCIAL COLLECTION ACCOUNTS RECENTLY PLACED"},{"code":"067","definition":"PERCENT OF SERIOUSLY DELINQUENT COMMERCIAL ACCOUNTS"}],"commercialScoreTrends":[{"quarter":"JAN-MAR","score":58},{"quarter":"OCT-DEC","score":57},{"quarter":"JUL-SEP","score":66},{"quarter":"APR-JUN","score":56}],"fsrScore":{"modelCode":"000223","modelTitle":"FINANCIAL STABILITY RISK","score":32,"percentileRanking":31,"recommendedCreditLimitAmount":null,"riskClass":{"code":2,"definition":"LOW TO MEDIUM RISK"}},"fsrScoreFactors":[{"code":"001","definition":"NUMBER OF COMMERCIAL COLLECTION ACCOUNTS"},{"code":"005","definition":"NUMBER OF COMMERCIAL DEROGATORY PUBLIC RECORDS"},{"code":"002","definition":"RISK ASSOCIATED WITH THE BUSINESS TYPE"},{"code":"014","definition":"PERCENT OF TOTAL COMMERCIAL BALANCE MODERATELY DELINQ"}],"fsrScoreTrends":[{"quarter":"JAN-MAR","score":31},{"quarter":"OCT-DEC","score":32},{"quarter":"JUL-SEP","score":33},{"quarter":"APR-JUN","score":29}],"listOfSimilars":[{"bin":"882980499","reliabilityCode":100,"businessName":"KEYBANK","phone":null,"address":{"street":"100 DUTCH HILL RD","city":"ORANGEBURG","state":"NY","zip":"10962","zipExtension":"2197"},"numberOfTradelines":124,"financialStatementIndicator":false,"keyFactsIndicator":true,"inquiryIndicator":true,"bankDataIndicator":true,"governmentDataIndicator":false,"executiveSummaryIndicator":true,"uccIndicator":true,"matchingNameAndAddress":null,"businessGeocode":{"latitudeLongitudeLevel":"Roof Top Level","latitude":41.044063,"longitude":-73.954865,"msaCode":"5600","censusBlkGrpCode":"","censusTractCode":"013002","cottageIndicator":false,"congressionalDistrictCode":"17","dateLastReported":"2017-06-01"}}]}}';
        intLogScore.Account__c = CusAcc.Id;
        intLogScore.Status_Code__c = 200;
        intLogLst.add(intLogScore);
        
        Integration_Log__c intLogfraud = new Integration_Log__c();
        intLogfraud.EndPointURL__c = 'https://sandbox-us-api.experian.com/businessinformation/businesses/v1/fraudshields';
        intLogfraud.Response_Body__c = '{"requestId":"rrt-08009e7bdc5fde3e1-c-ea-10309-153468156-4","success":true,"results":{"businessHeader":{"bin":"700163758","businessName":"SONY MUSIC ENTERTAINMENT","address":{"street":"550 MADISON AVE FL 6","city":"NEW YORK","state":"NY","zip":"10022","zipExtension":"3211"},"phone":"+12128338000","taxId":"131914734","websiteUrl":"www.sonybmg.com","legalBusinessName":"SONY MUSIC ENTERTAINMENT","dbaNames":["SONY MUSIC ENTERTAINMENT","SONY BMG MUSIC ENTERTAINMENT","SONY HMG MUSIC ENTERTAINMENT"],"customerDisputeIndicator":false},"matchingBusinessAddress":"Primary Business","activeBusinessIndicator":true,"ofacMatchWarning":{"code":1,"definition":"No Match Found"},"businessVictimStatementIndicator":false,"businessRiskTriggersIndicator":false,"businessRiskTriggersStatement":null,"nameAddressVerificationIndicator":true}}';
        intLogfraud.Account__c = CusAcc.Id;
        intLogfraud.Status_Code__c = 200;
        intLogLst.add(intLogfraud);
        insert intLogLst;
        
        EXPRN__Exp_Business_Info__c expInfo = new EXPRN__Exp_Business_Info__c();
        expInfo.EXPRN__Financial_Stability_Risk__c = '67';
        expInfo.EXPRN__sbcs_score__c =  '999';
        expInfo.EXPRN__Account_Name__c = CusAcc.Id;
        expInfo.EXPRN__FSR_Score_Change__c = '21';
        expInfo.EXPRN__Score_Change__c = '21';
        insert expInfo;
        
        
        MockScoreResponse mockObj = new MockScoreResponse();
        mockObj.res = '{"requestId":"rrt-0f63683ebc491fca4-b-ea-16993-7363800-12","success":true,"results":{"businessHeader":{"bin":"882980499","businessName":"KEYBANK","address":{"street":"100 DUTCH HILL RD","city":"ORANGEBURG","state":"NY","zip":"10962","zipExtension":"2197"},"phone":null,"taxId":null,"websiteUrl":"key.com","legalBusinessName":"KEYBANK","dbaNames":["KEYBANK NA","FIRST NIAGARA BANK NA","FIRST NIAGARA SPECIALTY INSURANCE AGENCY","KEYBANK NA","KEYBANK N A","KEY BANK NA","KEYBANK NATL ASSN","KEYCORP INSURANCE AGENCY USA INC INC","HARLEYSVILLE NATIONAL BANK","EAST PENN BANK"],"customerDisputeIndicator":false},"matchingBusinessAddress":"Primary Business","activeBusinessIndicator":true,"ofacMatchWarning":{"code":null,"definition":"Not Available"},"businessVictimStatementIndicator":false,"businessRiskTriggersIndicator":false,"businessRiskTriggersStatement":null,"nameAddressVerificationIndicator":false}}';
        Test.setMock(HttpCalloutMock.class, mockObj);
        test.startTest();
        
        
        
        updateCreditDetails.callExperianCreditAssessment(new List<Id>{cc.Id});
        
        String prListToUpdate = JSON.serialize(new List<Pricing_Request__c>{pr});
        updateCreditDetails.callExperianSync(cc.Id, prListToUpdate, true, price);
        updateCreditDetails.codeCvrMeth();
        test.stopTest();
        
    }
    
    public static testMethod void setupMethod4(){
        
        Marketer__c getMarketer = new Marketer__c(name = 'xyz', MarketerDunsNumber__c = 'ten');
        Insert getMarketer;
        Account acc1= new Account();
        acc1.Name = 'Test Acc';
        //acc1.Utility_Account_Number_Prefix__c  = 'TST';
        insert acc1;
        
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
        expObj.Business_Search_URL__c = 'https://sandbox-us-api.experian.com/businessinformation/businesses/v1/search';
        insert expObj;
        
        Experian_Recency_Threshold__c ERT = new Experian_Recency_Threshold__c();
        ERT.No_of_days__c = 1;
        insert ERT;
        
        
        Id recordTypeCus = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Customer').getRecordTypeId();
        Account CusAcc= new Account();
        CusAcc.Name = 'Test Acc1';
        CusAcc.RecordTypeId =recordTypeCus;
        CusAcc.EXPRN__Exp_Business__c = exp.Id;
        CusAcc.Customer_Credit_Limit__c =1000;
        CusAcc.Last_Successful_Experian_Scores__c = system.now();
        CusAcc.Last_Successful_Experian_Fraud_Shields__c= system.now();
        // CusAcc.Last_Successful_Experian_Business_Fact__c= system.now();
        CusAcc.Last_Successful_Experian_Judgements__c= system.now();
        CusAcc.Last_Successful_Experian_Legal_Filings__c= system.now();
        CusAcc.Last_Successful_Experian_Liens__c= system.now();
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
        pr.Status__c = 'new';
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
        
        List<Integration_Log__c> intLogLst = new List<Integration_Log__c>();
        Integration_Log__c intLog = new Integration_Log__c();
        intLog.EndPointURL__c = 'https://sandbox-us-api.experian.com/businessinformation/businesses/v1/search';
        intLog.Response_Body__c = '{"requestId":"rrt-0ad5395c70356c361-c-ea-19327-3406950-2","comments":null,"success":true,"results":[{"bin":"711655002","reliabilityCode":100,"businessName":"BASF CATALYSTS LLC","phone":"+19732456000","address":{"street":"101 WOOD AVE S","city":"ISELIN","state":"NJ","zip":"08830","zipExtension":"2749"},"numberOfTradelines":71,"financialStatementIndicator":false,"keyFactsIndicator":true,"inquiryIndicator":false,"bankDataIndicator":false,"governmentDataIndicator":false,"executiveSummaryIndicator":true,"uccIndicator":true,"matchingNameAndAddress":null,"businessGeocode":{"latitudeLongitudeLevel":"Roof Top Level","latitude":40.563754,"longitude":-74.328738,"msaCode":"5015","censusBlkGrpCode":"","censusTractCode":"002603","cottageIndicator":false,"congressionalDistrictCode":"06","dateLastReported":"2018-01-31"}}]}}';
        intLog.Account__c = CusAcc.Id;
        intLog.Status_Code__c = 200;
        intLogLst.add(intLog);
        
        Integration_Log__c intLogfacts = new Integration_Log__c();
        intLogfacts.EndPointURL__c = 'https://sandbox-us-api.experian.com/businessinformation/businesses/v1/facts';
        intLogfacts.Response_Body__c = '{"requestId":"rrt-0f7898a6c30703d75-c-ea-20546-136691396-2","success":true,"results":{"businessHeader":{"bin":"700163758","businessName":"SONY MUSIC ENTERTAINMENT","address":{"street":"550 MADISON AVE FL 6","city":"NEW YORK","state":"NY","zip":"10022","zipExtension":"3211"},"phone":"+12128338000","taxId":"131914734","websiteUrl":"www.sonybmg.com","legalBusinessName":"SONY MUSIC ENTERTAINMENT","dbaNames":["SONY MUSIC ENTERTAINMENT","SONY BMG MUSIC ENTERTAINMENT","SONY HMG MUSIC ENTERTAINMENT"],"customerDisputeIndicator":false},"sicCodes":[{"code":"8999","definition":"SERVICES, NEC"},{"code":"3652","definition":"RECORDS, AUDIO TAPES & DISKS"},{"code":"7389","definition":"BUSINESS SERVICES, NEC"}],"naicsCodes":[{"code":"541990","definition":"All Other Professional, Scientific, and Technical Services"},{"code":"334614","definition":"Software and Other Prerecorded Compact Disc, Tape, and Record Reproducing"},{"code":"512240","definition":"Sound Recording Studios"}],"publicIndicator":false,"nonProfitIndicator":false,"yearsOnFile":33,"stateOfIncorporation":"MI","dateOfIncorporation":"1991-02-28","businessType":"Corporation","employeeSize":null,"employeeSizeCode":null,"salesRevenue":null,"salesSizeCode":null,"fortune1000":{"year":null,"rank":null},"corporateLinkageType":"Headquarters/Parent","executiveInformation":[{"firstName":"DOUGLAS","middleName":"P","lastName":"MORRIS","title":"CHIEF EXECUTIVE OFFICER"},{"firstName":"AFO","middleName":null,"lastName":"VERDE","title":"CHIEF EXECUTIVE OFFICER"},{"firstName":"PATRICK","middleName":null,"lastName":"MOXEY","title":"PRESIDENT"}]}}';
        intLogfacts.Account__c = CusAcc.Id;
        intLogfacts.Status_Code__c = 200;
        intLogLst.add(intLogfacts);
        
        Integration_Log__c intLogScore = new Integration_Log__c();
        intLogScore.EndPointURL__c = 'https://sandbox-us-api.experian.com/businessinformation/businesses/v1/scores/search';
        intLogScore.Response_Body__c = '{"requestId":"rrt-0f63683ebc491fca4-b-ea-16993-7363800-8","success":true,"comments":null,"results":{"businessHeader":{"bin":"882980499","businessName":"KEYBANK","address":{"street":"100 DUTCH HILL RD","city":"ORANGEBURG","state":"NY","zip":"10962","zipExtension":"2197"},"phone":null,"taxId":null,"websiteUrl":"key.com","legalBusinessName":"KEYBANK","dbaNames":["KEYBANK NA","FIRST NIAGARA BANK NA","FIRST NIAGARA SPECIALTY INSURANCE AGENCY","KEYBANK NA","KEYBANK N A","KEY BANK NA","KEYBANK NATL ASSN","KEYCORP INSURANCE AGENCY USA INC INC","HARLEYSVILLE NATIONAL BANK","EAST PENN BANK"],"customerDisputeIndicator":false},"commercialScore":{"modelCode":"000224","modelTitle":"INTELLISCORE PLUS V2","customModelCode":"02","score":64,"percentileRanking":63,"recommendedCreditLimitAmount":2784600,"riskClass":{"code":2,"definition":"LOW TO MEDIUM RISK"}},"commercialScoreFactors":[{"code":"033","definition":"NUMBER OF COMMERCIAL ACCOUNTS THAT ARE CURRENT"},{"code":"066","definition":"PERCENT OF DELINQUENT COMMERCIAL ACCOUNTS"},{"code":"012","definition":"NUMBER OF COMMERCIAL COLLECTION ACCOUNTS RECENTLY PLACED"},{"code":"067","definition":"PERCENT OF SERIOUSLY DELINQUENT COMMERCIAL ACCOUNTS"}],"commercialScoreTrends":[{"quarter":"JAN-MAR","score":58},{"quarter":"OCT-DEC","score":57},{"quarter":"JUL-SEP","score":66},{"quarter":"APR-JUN","score":56}],"fsrScore":{"modelCode":"000223","modelTitle":"FINANCIAL STABILITY RISK","score":32,"percentileRanking":31,"recommendedCreditLimitAmount":null,"riskClass":{"code":2,"definition":"LOW TO MEDIUM RISK"}},"fsrScoreFactors":[{"code":"001","definition":"NUMBER OF COMMERCIAL COLLECTION ACCOUNTS"},{"code":"005","definition":"NUMBER OF COMMERCIAL DEROGATORY PUBLIC RECORDS"},{"code":"002","definition":"RISK ASSOCIATED WITH THE BUSINESS TYPE"},{"code":"014","definition":"PERCENT OF TOTAL COMMERCIAL BALANCE MODERATELY DELINQ"}],"fsrScoreTrends":[{"quarter":"JAN-MAR","score":31},{"quarter":"OCT-DEC","score":32},{"quarter":"JUL-SEP","score":33},{"quarter":"APR-JUN","score":29}],"listOfSimilars":[{"bin":"882980499","reliabilityCode":100,"businessName":"KEYBANK","phone":null,"address":{"street":"100 DUTCH HILL RD","city":"ORANGEBURG","state":"NY","zip":"10962","zipExtension":"2197"},"numberOfTradelines":124,"financialStatementIndicator":false,"keyFactsIndicator":true,"inquiryIndicator":true,"bankDataIndicator":true,"governmentDataIndicator":false,"executiveSummaryIndicator":true,"uccIndicator":true,"matchingNameAndAddress":null,"businessGeocode":{"latitudeLongitudeLevel":"Roof Top Level","latitude":41.044063,"longitude":-73.954865,"msaCode":"5600","censusBlkGrpCode":"","censusTractCode":"013002","cottageIndicator":false,"congressionalDistrictCode":"17","dateLastReported":"2017-06-01"}}]}}';
        intLogScore.Account__c = CusAcc.Id;
        intLogScore.Status_Code__c = 200;
        intLogLst.add(intLogScore);
        
        Integration_Log__c intLogfraud = new Integration_Log__c();
        intLogfraud.EndPointURL__c = 'https://sandbox-us-api.experian.com/businessinformation/businesses/v1/fraudshields';
        intLogfraud.Response_Body__c = '{"requestId":"rrt-08009e7bdc5fde3e1-c-ea-10309-153468156-4","success":true,"results":{"businessHeader":{"bin":"700163758","businessName":"SONY MUSIC ENTERTAINMENT","address":{"street":"550 MADISON AVE FL 6","city":"NEW YORK","state":"NY","zip":"10022","zipExtension":"3211"},"phone":"+12128338000","taxId":"131914734","websiteUrl":"www.sonybmg.com","legalBusinessName":"SONY MUSIC ENTERTAINMENT","dbaNames":["SONY MUSIC ENTERTAINMENT","SONY BMG MUSIC ENTERTAINMENT","SONY HMG MUSIC ENTERTAINMENT"],"customerDisputeIndicator":false},"matchingBusinessAddress":"Primary Business","activeBusinessIndicator":true,"ofacMatchWarning":{"code":1,"definition":"No Match Found"},"businessVictimStatementIndicator":false,"businessRiskTriggersIndicator":false,"businessRiskTriggersStatement":null,"nameAddressVerificationIndicator":true}}';
        intLogfraud.Account__c = CusAcc.Id;
        intLogfraud.Status_Code__c = 200;
        intLogLst.add(intLogfraud);
        insert intLogLst;
        
        EXPRN__Exp_Business_Info__c expInfo = new EXPRN__Exp_Business_Info__c();
        expInfo.EXPRN__Financial_Stability_Risk__c = '67';
        expInfo.EXPRN__sbcs_score__c =  '32';
        expInfo.EXPRN__Account_Name__c = CusAcc.Id;
        expInfo.EXPRN__FSR_Score_Change__c = '21';
        expInfo.EXPRN__Score_Change__c = '21';
        insert expInfo;
        
        
        MockScoreResponse mockObj = new MockScoreResponse();
        mockObj.res = '{"requestId":"rrt-0f63683ebc491fca4-b-ea-16993-7363800-6","success":true,"results":{"businessHeader":{"bin":"882980499","businessName":"KEYBANK","address":{"street":"100 DUTCH HILL RD","city":"ORANGEBURG","state":"NY","zip":"10962","zipExtension":"2197"},"phone":null,"taxId":null,"websiteUrl":"key.com","legalBusinessName":"KEYBANK","dbaNames":["KEYBANK NA","FIRST NIAGARA BANK NA","FIRST NIAGARA SPECIALTY INSURANCE AGENCY","KEYBANK NA","KEYBANK N A","KEY BANK NA","KEYBANK NATL ASSN","KEYCORP INSURANCE AGENCY USA INC INC","HARLEYSVILLE NATIONAL BANK","EAST PENN BANK"],"customerDisputeIndicator":false},"sicCodes":[{"code":"6029","definition":"COMMERCIAL BANKS, NEC"},{"code":"6163","definition":"LOAN BROKERS"}],"naicsCodes":[{"code":"922110","definition":"Commercial Banking"},{"code":"522310","definition":"Mortgage and Nonmortgage Loan Brokers"}],"publicIndicator":false,"nonProfitIndicator":false,"yearsOnFile":44,"stateOfIncorporation":"IN","dateOfIncorporation":"1996-06-19","businessType":null,"employeeSize":null,"employeeSizeCode":null,"salesRevenue":null,"salesSizeCode":null,"fortune1000":{"year":null,"rank":null},"corporateLinkageType":"Headquarters/Parent","executiveInformation":null}}';
        Test.setMock(HttpCalloutMock.class, mockObj);
        test.startTest();
        
        
        
        updateCreditDetails.callExperianCreditAssessment(new List<Id>{cc.Id});
        
        String prListToUpdate = JSON.serialize(new List<Pricing_Request__c>{pr});
        updateCreditDetails.callExperianSync(cc.Id, prListToUpdate, true, price);
        updateCreditDetails.codeCvrMeth();
        test.stopTest();
        
    }
    
    public static testMethod void setupMethod5(){
        
        Marketer__c getMarketer = new Marketer__c(name = 'xyz', MarketerDunsNumber__c = 'ten');
        Insert getMarketer;
        Account acc1= new Account();
        acc1.Name = 'Test Acc';
        //acc1.Utility_Account_Number_Prefix__c  = 'TST';
        insert acc1;
        
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
        expObj.Business_Search_URL__c = 'https://sandbox-us-api.experian.com/businessinformation/businesses/v1/search';
        insert expObj;
        
        Experian_Recency_Threshold__c ERT = new Experian_Recency_Threshold__c();
        ERT.No_of_days__c = 1;
        insert ERT;
        
        
        Id recordTypeCus = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Customer').getRecordTypeId();
        Account CusAcc= new Account();
        CusAcc.Name = 'Test Acc1';
        CusAcc.RecordTypeId =recordTypeCus;
        CusAcc.EXPRN__Exp_Business__c = exp.Id;
        CusAcc.Customer_Credit_Limit__c =1000;
        CusAcc.Last_Successful_Experian_Scores__c = system.now();
        CusAcc.Last_Successful_Experian_Fraud_Shields__c= system.now();
        // CusAcc.Last_Successful_Experian_Business_Fact__c= system.now();
        CusAcc.Last_Successful_Experian_Judgements__c= system.now();
        CusAcc.Last_Successful_Experian_Legal_Filings__c= system.now();
        CusAcc.Last_Successful_Experian_Liens__c= system.now();
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
        pr.Status__c = 'new';
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
        
        List<Integration_Log__c> intLogLst = new List<Integration_Log__c>();
        Integration_Log__c intLog = new Integration_Log__c();
        intLog.EndPointURL__c = 'https://sandbox-us-api.experian.com/businessinformation/businesses/v1/search';
        intLog.Response_Body__c = '{"requestId":"rrt-0ad5395c70356c361-c-ea-19327-3406950-2","comments":null,"success":true,"results":[{"bin":"711655002","reliabilityCode":100,"businessName":"BASF CATALYSTS LLC","phone":"+19732456000","address":{"street":"101 WOOD AVE S","city":"ISELIN","state":"NJ","zip":"08830","zipExtension":"2749"},"numberOfTradelines":71,"financialStatementIndicator":false,"keyFactsIndicator":true,"inquiryIndicator":false,"bankDataIndicator":false,"governmentDataIndicator":false,"executiveSummaryIndicator":true,"uccIndicator":true,"matchingNameAndAddress":null,"businessGeocode":{"latitudeLongitudeLevel":"Roof Top Level","latitude":40.563754,"longitude":-74.328738,"msaCode":"5015","censusBlkGrpCode":"","censusTractCode":"002603","cottageIndicator":false,"congressionalDistrictCode":"06","dateLastReported":"2018-01-31"}}]}}';
        intLog.Account__c = CusAcc.Id;
        intLog.Status_Code__c = 200;
        intLogLst.add(intLog);
        
        Integration_Log__c intLogfacts = new Integration_Log__c();
        intLogfacts.EndPointURL__c = 'https://sandbox-us-api.experian.com/businessinformation/businesses/v1/facts';
        intLogfacts.Response_Body__c = '{"requestId":"rrt-0f7898a6c30703d75-c-ea-20546-136691396-2","success":true,"results":{"businessHeader":{"bin":"700163758","businessName":"SONY MUSIC ENTERTAINMENT","address":{"street":"550 MADISON AVE FL 6","city":"NEW YORK","state":"NY","zip":"10022","zipExtension":"3211"},"phone":"+12128338000","taxId":"131914734","websiteUrl":"www.sonybmg.com","legalBusinessName":"SONY MUSIC ENTERTAINMENT","dbaNames":["SONY MUSIC ENTERTAINMENT","SONY BMG MUSIC ENTERTAINMENT","SONY HMG MUSIC ENTERTAINMENT"],"customerDisputeIndicator":false},"sicCodes":[{"code":"8999","definition":"SERVICES, NEC"},{"code":"3652","definition":"RECORDS, AUDIO TAPES & DISKS"},{"code":"7389","definition":"BUSINESS SERVICES, NEC"}],"naicsCodes":[{"code":"541990","definition":"All Other Professional, Scientific, and Technical Services"},{"code":"334614","definition":"Software and Other Prerecorded Compact Disc, Tape, and Record Reproducing"},{"code":"512240","definition":"Sound Recording Studios"}],"publicIndicator":false,"nonProfitIndicator":false,"yearsOnFile":33,"stateOfIncorporation":"MI","dateOfIncorporation":"1991-02-28","businessType":"Corporation","employeeSize":null,"employeeSizeCode":null,"salesRevenue":null,"salesSizeCode":null,"fortune1000":{"year":null,"rank":null},"corporateLinkageType":"Headquarters/Parent","executiveInformation":[{"firstName":"DOUGLAS","middleName":"P","lastName":"MORRIS","title":"CHIEF EXECUTIVE OFFICER"},{"firstName":"AFO","middleName":null,"lastName":"VERDE","title":"CHIEF EXECUTIVE OFFICER"},{"firstName":"PATRICK","middleName":null,"lastName":"MOXEY","title":"PRESIDENT"}]}}';
        intLogfacts.Account__c = CusAcc.Id;
        intLogfacts.Status_Code__c = 200;
        intLogLst.add(intLogfacts);
        
        Integration_Log__c intLogScore = new Integration_Log__c();
        intLogScore.EndPointURL__c = 'https://sandbox-us-api.experian.com/businessinformation/businesses/v1/scores/search';
        intLogScore.Response_Body__c = '{"requestId":"rrt-0f63683ebc491fca4-b-ea-16993-7363800-8","success":true,"comments":null,"results":{"businessHeader":{"bin":"882980499","businessName":"KEYBANK","address":{"street":"100 DUTCH HILL RD","city":"ORANGEBURG","state":"NY","zip":"10962","zipExtension":"2197"},"phone":null,"taxId":null,"websiteUrl":"key.com","legalBusinessName":"KEYBANK","dbaNames":["KEYBANK NA","FIRST NIAGARA BANK NA","FIRST NIAGARA SPECIALTY INSURANCE AGENCY","KEYBANK NA","KEYBANK N A","KEY BANK NA","KEYBANK NATL ASSN","KEYCORP INSURANCE AGENCY USA INC INC","HARLEYSVILLE NATIONAL BANK","EAST PENN BANK"],"customerDisputeIndicator":false},"commercialScore":{"modelCode":"000224","modelTitle":"INTELLISCORE PLUS V2","customModelCode":"02","score":64,"percentileRanking":63,"recommendedCreditLimitAmount":2784600,"riskClass":{"code":2,"definition":"LOW TO MEDIUM RISK"}},"commercialScoreFactors":[{"code":"033","definition":"NUMBER OF COMMERCIAL ACCOUNTS THAT ARE CURRENT"},{"code":"066","definition":"PERCENT OF DELINQUENT COMMERCIAL ACCOUNTS"},{"code":"012","definition":"NUMBER OF COMMERCIAL COLLECTION ACCOUNTS RECENTLY PLACED"},{"code":"067","definition":"PERCENT OF SERIOUSLY DELINQUENT COMMERCIAL ACCOUNTS"}],"commercialScoreTrends":[{"quarter":"JAN-MAR","score":58},{"quarter":"OCT-DEC","score":57},{"quarter":"JUL-SEP","score":66},{"quarter":"APR-JUN","score":56}],"fsrScore":{"modelCode":"000223","modelTitle":"FINANCIAL STABILITY RISK","score":32,"percentileRanking":31,"recommendedCreditLimitAmount":null,"riskClass":{"code":2,"definition":"LOW TO MEDIUM RISK"}},"fsrScoreFactors":[{"code":"001","definition":"NUMBER OF COMMERCIAL COLLECTION ACCOUNTS"},{"code":"005","definition":"NUMBER OF COMMERCIAL DEROGATORY PUBLIC RECORDS"},{"code":"002","definition":"RISK ASSOCIATED WITH THE BUSINESS TYPE"},{"code":"014","definition":"PERCENT OF TOTAL COMMERCIAL BALANCE MODERATELY DELINQ"}],"fsrScoreTrends":[{"quarter":"JAN-MAR","score":31},{"quarter":"OCT-DEC","score":32},{"quarter":"JUL-SEP","score":33},{"quarter":"APR-JUN","score":29}],"listOfSimilars":[{"bin":"882980499","reliabilityCode":100,"businessName":"KEYBANK","phone":null,"address":{"street":"100 DUTCH HILL RD","city":"ORANGEBURG","state":"NY","zip":"10962","zipExtension":"2197"},"numberOfTradelines":124,"financialStatementIndicator":false,"keyFactsIndicator":true,"inquiryIndicator":true,"bankDataIndicator":true,"governmentDataIndicator":false,"executiveSummaryIndicator":true,"uccIndicator":true,"matchingNameAndAddress":null,"businessGeocode":{"latitudeLongitudeLevel":"Roof Top Level","latitude":41.044063,"longitude":-73.954865,"msaCode":"5600","censusBlkGrpCode":"","censusTractCode":"013002","cottageIndicator":false,"congressionalDistrictCode":"17","dateLastReported":"2017-06-01"}}]}}';
        intLogScore.Account__c = CusAcc.Id;
        intLogScore.Status_Code__c = 200;
        intLogLst.add(intLogScore);
        
        Integration_Log__c intLogfraud = new Integration_Log__c();
        intLogfraud.EndPointURL__c = 'https://sandbox-us-api.experian.com/businessinformation/businesses/v1/fraudshields';
        intLogfraud.Response_Body__c = '{"requestId":"rrt-08009e7bdc5fde3e1-c-ea-10309-153468156-4","success":true,"results":{"businessHeader":{"bin":"700163758","businessName":"SONY MUSIC ENTERTAINMENT","address":{"street":"550 MADISON AVE FL 6","city":"NEW YORK","state":"NY","zip":"10022","zipExtension":"3211"},"phone":"+12128338000","taxId":"131914734","websiteUrl":"www.sonybmg.com","legalBusinessName":"SONY MUSIC ENTERTAINMENT","dbaNames":["SONY MUSIC ENTERTAINMENT","SONY BMG MUSIC ENTERTAINMENT","SONY HMG MUSIC ENTERTAINMENT"],"customerDisputeIndicator":false},"matchingBusinessAddress":"Primary Business","activeBusinessIndicator":true,"ofacMatchWarning":{"code":1,"definition":"No Match Found"},"businessVictimStatementIndicator":false,"businessRiskTriggersIndicator":false,"businessRiskTriggersStatement":null,"nameAddressVerificationIndicator":true}}';
        intLogfraud.Account__c = CusAcc.Id;
        intLogfraud.Status_Code__c = 200;
        intLogLst.add(intLogfraud);
        insert intLogLst;
        
        EXPRN__Exp_Business_Info__c expInfo = new EXPRN__Exp_Business_Info__c();
        expInfo.EXPRN__Financial_Stability_Risk__c = '67';
        expInfo.EXPRN__sbcs_score__c =  '30';
        expInfo.EXPRN__Account_Name__c = CusAcc.Id;
        expInfo.EXPRN__FSR_Score_Change__c = '22';
        expInfo.EXPRN__Score_Change__c = '21';
        insert expInfo;
        
        updateCreditDetails.UAField wrap = new updateCreditDetails.UAField();
        for(Integer i = 0; i<100; i++){
            wrap.exp1 = 'Test';
            wrap.exp2 = 'Test';
            wrap.exp3 = 'Test';
            wrap.exp4 = 'Test';
            wrap.exp5 = 'Test';
            wrap.exp6 = 'Test';
            wrap.exp8 = 'Test';
            wrap.exp9 = 'Test';
            wrap.exp10 = 'Test';
            wrap.exp11 = 'Test';
            wrap.exp12 = 'Test';
            wrap.exp13 = 'Test';
            wrap.exp14 = 'Test';
            wrap.exp15 = 'Test';
            wrap.exp16 = 'Test';
            wrap.exp17 = 'Test';
            wrap.exp18 = 'Test';
            wrap.exp19 = 'Test';
            wrap.exp20 = 'Test';
            wrap.exp21 = 'Test';
            wrap.exp22 = 'Test';
            wrap.exp23 = 'Test';
            wrap.exp24 = 'Test';
            wrap.exp25 = 'Test';
            wrap.exp26 = 'Test';
            
             wrap.exp27 = 'Test';
            wrap.exp28 = 'Test';
            wrap.exp29 = 'Test';
            wrap.exp30 = 'Test';
            wrap.exp31 = 'Test';
            wrap.exp32 = 'Test';
            wrap.exp33 = 'Test';
            wrap.exp34 = 'Test';
            wrap.exp35 = 'Test';
            wrap.exp36 = 'Test';
            wrap.exp37 = 'Test';
            wrap.exp38 = 'Test';
            wrap.exp39 = 'Test';
            wrap.exp40 = 'Test';
            wrap.exp41 = 'Test';
            wrap.exp42 = 'Test';
            wrap.exp43 = 'Test';
            wrap.exp44 = 'Test';
            wrap.exp45 = 'Test';
            wrap.exp46 = 'Test';
            wrap.exp47 = 'Test';
            wrap.exp48 = 'Test';
            wrap.exp49 = 'Test';
            wrap.exp50 = 'Test';
            wrap.exp51 = 'Test';
            wrap.exp52 = 'Test';
            
               wrap.exp53 = 'Test';
            wrap.exp54 = 'Test';
            wrap.exp55 = 'Test';
            wrap.exp56 = 'Test';
            wrap.exp57 = 'Test';
            wrap.exp58 = 'Test';
            wrap.exp59 = 'Test';
            wrap.exp60 = 'Test';
            wrap.exp61 = 'Test';
            wrap.exp62 = 'Test';
            wrap.exp63 = 'Test';
            wrap.exp64 = 'Test';
            wrap.exp65 = 'Test';
            
             wrap.exp66 = 'Test';
            wrap.exp67 = 'Test';
            wrap.exp68 = 'Test';
            wrap.exp69 = 'Test';
            wrap.exp70 = 'Test';
            wrap.exp71 = 'Test';
            wrap.exp72 = 'Test';
            wrap.exp73 = 'Test';
            wrap.exp74 = 'Test';
            wrap.exp75 = 'Test';
            wrap.exp76 = 'Test';
            wrap.exp77 = 'Test';
            wrap.exp78 = 'Test';
        }
        
        
        MockScoreResponse mockObj = new MockScoreResponse();
        mockObj.res = '{"requestId":"rrt-0f63683ebc491fca4-b-ea-16993-7363800-6","success":true,"results":{"businessHeader":{"bin":"882980499","businessName":"KEYBANK","address":{"street":"100 DUTCH HILL RD","city":"ORANGEBURG","state":"NY","zip":"10962","zipExtension":"2197"},"phone":null,"taxId":null,"websiteUrl":"key.com","legalBusinessName":"KEYBANK","dbaNames":["KEYBANK NA","FIRST NIAGARA BANK NA","FIRST NIAGARA SPECIALTY INSURANCE AGENCY","KEYBANK NA","KEYBANK N A","KEY BANK NA","KEYBANK NATL ASSN","KEYCORP INSURANCE AGENCY USA INC INC","HARLEYSVILLE NATIONAL BANK","EAST PENN BANK"],"customerDisputeIndicator":false},"sicCodes":[{"code":"6029","definition":"COMMERCIAL BANKS, NEC"},{"code":"6163","definition":"LOAN BROKERS"}],"naicsCodes":[{"code":"922110","definition":"Commercial Banking"},{"code":"522310","definition":"Mortgage and Nonmortgage Loan Brokers"}],"publicIndicator":false,"nonProfitIndicator":false,"yearsOnFile":44,"stateOfIncorporation":"IN","dateOfIncorporation":"1996-06-19","businessType":null,"employeeSize":null,"employeeSizeCode":null,"salesRevenue":null,"salesSizeCode":null,"fortune1000":{"year":null,"rank":null},"corporateLinkageType":"Headquarters/Parent","executiveInformation":null}}';
        Test.setMock(HttpCalloutMock.class, mockObj);
        test.startTest();
        
        
        
        updateCreditDetails.callExperianCreditAssessment(new List<Id>{cc.Id});
        
        String prListToUpdate = JSON.serialize(new List<Pricing_Request__c>{pr});
        updateCreditDetails.callExperianSync(cc.Id, prListToUpdate, true, price);
        updateCreditDetails.codeCvrMeth();
        test.stopTest();
        
    }
    
    public static testMethod void setupMethod6(){
        
        Marketer__c getMarketer = new Marketer__c(name = 'xyz', MarketerDunsNumber__c = 'ten');
        Insert getMarketer;
        Account acc1= new Account();
        acc1.Name = 'Test Acc';
        //acc1.Utility_Account_Number_Prefix__c  = 'TST';
        insert acc1;
        
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
        expObj.Business_Search_URL__c = 'https://sandbox-us-api.experian.com/businessinformation/businesses/v1/search';
        insert expObj;
        
        Experian_Recency_Threshold__c ERT = new Experian_Recency_Threshold__c();
        ERT.No_of_days__c = 1;
        insert ERT;
        
        
        Id recordTypeCus = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Customer').getRecordTypeId();
        Account CusAcc= new Account();
        CusAcc.Name = 'Test Acc1';
        CusAcc.RecordTypeId =recordTypeCus;
        CusAcc.EXPRN__Exp_Business__c = exp.Id;
        CusAcc.Customer_Credit_Limit__c =1000;
        CusAcc.Last_Successful_Experian_Scores__c = system.now();
        CusAcc.Last_Successful_Experian_Fraud_Shields__c= system.now();
        // CusAcc.Last_Successful_Experian_Business_Fact__c= system.now();
        CusAcc.Last_Successful_Experian_Judgements__c= system.now();
        CusAcc.Last_Successful_Experian_Legal_Filings__c= system.now();
        CusAcc.Last_Successful_Experian_Liens__c= system.now();
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
        pr.Status__c = 'new';
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
        
        List<Integration_Log__c> intLogLst = new List<Integration_Log__c>();
        Integration_Log__c intLog = new Integration_Log__c();
        intLog.EndPointURL__c = 'https://sandbox-us-api.experian.com/businessinformation/businesses/v1/search';
        intLog.Response_Body__c = '{"requestId":"rrt-0ad5395c70356c361-c-ea-19327-3406950-2","comments":null,"success":true,"results":[{"bin":"711655002","reliabilityCode":100,"businessName":"BASF CATALYSTS LLC","phone":"+19732456000","address":{"street":"101 WOOD AVE S","city":"ISELIN","state":"NJ","zip":"08830","zipExtension":"2749"},"numberOfTradelines":71,"financialStatementIndicator":false,"keyFactsIndicator":true,"inquiryIndicator":false,"bankDataIndicator":false,"governmentDataIndicator":false,"executiveSummaryIndicator":true,"uccIndicator":true,"matchingNameAndAddress":null,"businessGeocode":{"latitudeLongitudeLevel":"Roof Top Level","latitude":40.563754,"longitude":-74.328738,"msaCode":"5015","censusBlkGrpCode":"","censusTractCode":"002603","cottageIndicator":false,"congressionalDistrictCode":"06","dateLastReported":"2018-01-31"}}]}}';
        intLog.Account__c = CusAcc.Id;
        intLog.Status_Code__c = 200;
        intLogLst.add(intLog);
        
        Integration_Log__c intLogfacts = new Integration_Log__c();
        intLogfacts.EndPointURL__c = 'https://sandbox-us-api.experian.com/businessinformation/businesses/v1/facts';
        intLogfacts.Response_Body__c = '{"requestId":"rrt-0f7898a6c30703d75-c-ea-20546-136691396-2","success":true,"results":{"businessHeader":{"bin":"700163758","businessName":"SONY MUSIC ENTERTAINMENT","address":{"street":"550 MADISON AVE FL 6","city":"NEW YORK","state":"NY","zip":"10022","zipExtension":"3211"},"phone":"+12128338000","taxId":"131914734","websiteUrl":"www.sonybmg.com","legalBusinessName":"SONY MUSIC ENTERTAINMENT","dbaNames":["SONY MUSIC ENTERTAINMENT","SONY BMG MUSIC ENTERTAINMENT","SONY HMG MUSIC ENTERTAINMENT"],"customerDisputeIndicator":false},"sicCodes":[{"code":"8999","definition":"SERVICES, NEC"},{"code":"3652","definition":"RECORDS, AUDIO TAPES & DISKS"},{"code":"7389","definition":"BUSINESS SERVICES, NEC"}],"naicsCodes":[{"code":"541990","definition":"All Other Professional, Scientific, and Technical Services"},{"code":"334614","definition":"Software and Other Prerecorded Compact Disc, Tape, and Record Reproducing"},{"code":"512240","definition":"Sound Recording Studios"}],"publicIndicator":false,"nonProfitIndicator":false,"yearsOnFile":33,"stateOfIncorporation":"MI","dateOfIncorporation":"1991-02-28","businessType":"Corporation","employeeSize":null,"employeeSizeCode":null,"salesRevenue":null,"salesSizeCode":null,"fortune1000":{"year":null,"rank":null},"corporateLinkageType":"Headquarters/Parent","executiveInformation":[{"firstName":"DOUGLAS","middleName":"P","lastName":"MORRIS","title":"CHIEF EXECUTIVE OFFICER"},{"firstName":"AFO","middleName":null,"lastName":"VERDE","title":"CHIEF EXECUTIVE OFFICER"},{"firstName":"PATRICK","middleName":null,"lastName":"MOXEY","title":"PRESIDENT"}]}}';
        intLogfacts.Account__c = CusAcc.Id;
        intLogfacts.Status_Code__c = 400;
        intLogLst.add(intLogfacts);
        
        Integration_Log__c intLogScore = new Integration_Log__c();
        intLogScore.EndPointURL__c = 'https://sandbox-us-api.experian.com/businessinformation/businesses/v1/scores/search';
        intLogScore.Response_Body__c = '{"requestId":"rrt-0f63683ebc491fca4-b-ea-16993-7363800-8","success":true,"comments":null,"results":{"businessHeader":{"bin":"882980499","businessName":"KEYBANK","address":{"street":"100 DUTCH HILL RD","city":"ORANGEBURG","state":"NY","zip":"10962","zipExtension":"2197"},"phone":null,"taxId":null,"websiteUrl":"key.com","legalBusinessName":"KEYBANK","dbaNames":["KEYBANK NA","FIRST NIAGARA BANK NA","FIRST NIAGARA SPECIALTY INSURANCE AGENCY","KEYBANK NA","KEYBANK N A","KEY BANK NA","KEYBANK NATL ASSN","KEYCORP INSURANCE AGENCY USA INC INC","HARLEYSVILLE NATIONAL BANK","EAST PENN BANK"],"customerDisputeIndicator":false},"commercialScore":{"modelCode":"000224","modelTitle":"INTELLISCORE PLUS V2","customModelCode":"02","score":64,"percentileRanking":63,"recommendedCreditLimitAmount":2784600,"riskClass":{"code":2,"definition":"LOW TO MEDIUM RISK"}},"commercialScoreFactors":[{"code":"033","definition":"NUMBER OF COMMERCIAL ACCOUNTS THAT ARE CURRENT"},{"code":"066","definition":"PERCENT OF DELINQUENT COMMERCIAL ACCOUNTS"},{"code":"012","definition":"NUMBER OF COMMERCIAL COLLECTION ACCOUNTS RECENTLY PLACED"},{"code":"067","definition":"PERCENT OF SERIOUSLY DELINQUENT COMMERCIAL ACCOUNTS"}],"commercialScoreTrends":[{"quarter":"JAN-MAR","score":58},{"quarter":"OCT-DEC","score":57},{"quarter":"JUL-SEP","score":66},{"quarter":"APR-JUN","score":56}],"fsrScore":{"modelCode":"000223","modelTitle":"FINANCIAL STABILITY RISK","score":32,"percentileRanking":31,"recommendedCreditLimitAmount":null,"riskClass":{"code":2,"definition":"LOW TO MEDIUM RISK"}},"fsrScoreFactors":[{"code":"001","definition":"NUMBER OF COMMERCIAL COLLECTION ACCOUNTS"},{"code":"005","definition":"NUMBER OF COMMERCIAL DEROGATORY PUBLIC RECORDS"},{"code":"002","definition":"RISK ASSOCIATED WITH THE BUSINESS TYPE"},{"code":"014","definition":"PERCENT OF TOTAL COMMERCIAL BALANCE MODERATELY DELINQ"}],"fsrScoreTrends":[{"quarter":"JAN-MAR","score":31},{"quarter":"OCT-DEC","score":32},{"quarter":"JUL-SEP","score":33},{"quarter":"APR-JUN","score":29}],"listOfSimilars":[{"bin":"882980499","reliabilityCode":100,"businessName":"KEYBANK","phone":null,"address":{"street":"100 DUTCH HILL RD","city":"ORANGEBURG","state":"NY","zip":"10962","zipExtension":"2197"},"numberOfTradelines":124,"financialStatementIndicator":false,"keyFactsIndicator":true,"inquiryIndicator":true,"bankDataIndicator":true,"governmentDataIndicator":false,"executiveSummaryIndicator":true,"uccIndicator":true,"matchingNameAndAddress":null,"businessGeocode":{"latitudeLongitudeLevel":"Roof Top Level","latitude":41.044063,"longitude":-73.954865,"msaCode":"5600","censusBlkGrpCode":"","censusTractCode":"013002","cottageIndicator":false,"congressionalDistrictCode":"17","dateLastReported":"2017-06-01"}}]}}';
        intLogScore.Account__c = CusAcc.Id;
        intLogScore.Status_Code__c = 200;
        intLogLst.add(intLogScore);
        
        Integration_Log__c intLogfraud = new Integration_Log__c();
        intLogfraud.EndPointURL__c = 'https://sandbox-us-api.experian.com/businessinformation/businesses/v1/fraudshields';
        intLogfraud.Response_Body__c = '{"requestId":"rrt-08009e7bdc5fde3e1-c-ea-10309-153468156-4","success":true,"results":{"businessHeader":{"bin":"700163758","businessName":"SONY MUSIC ENTERTAINMENT","address":{"street":"550 MADISON AVE FL 6","city":"NEW YORK","state":"NY","zip":"10022","zipExtension":"3211"},"phone":"+12128338000","taxId":"131914734","websiteUrl":"www.sonybmg.com","legalBusinessName":"SONY MUSIC ENTERTAINMENT","dbaNames":["SONY MUSIC ENTERTAINMENT","SONY BMG MUSIC ENTERTAINMENT","SONY HMG MUSIC ENTERTAINMENT"],"customerDisputeIndicator":false},"matchingBusinessAddress":"Primary Business","activeBusinessIndicator":true,"ofacMatchWarning":{"code":5,"definition":"No Match Found"},"businessVictimStatementIndicator":false,"businessRiskTriggersIndicator":false,"businessRiskTriggersStatement":null,"nameAddressVerificationIndicator":true}}';
        intLogfraud.Account__c = CusAcc.Id;
        intLogfraud.Status_Code__c = 200;
        intLogLst.add(intLogfraud);
        insert intLogLst;
        
        EXPRN__Exp_Business_Info__c expInfo = new EXPRN__Exp_Business_Info__c();
        expInfo.EXPRN__Financial_Stability_Risk__c = '67';
        expInfo.EXPRN__sbcs_score__c =  '32';
        expInfo.EXPRN__Account_Name__c = CusAcc.Id;
        expInfo.EXPRN__FSR_Score_Change__c = '21';
        expInfo.EXPRN__Score_Change__c = '21';
        insert expInfo;
        
        
        MockScoreResponse mockObj = new MockScoreResponse();
        mockObj.res = '{"requestId":"rrt-0f63683ebc491fca4-b-ea-16993-7363800-6","success":true,"results":{"businessHeader":{"bin":"882980499","businessName":"KEYBANK","address":{"street":"100 DUTCH HILL RD","city":"ORANGEBURG","state":"NY","zip":"10962","zipExtension":"2197"},"phone":null,"taxId":null,"websiteUrl":"key.com","legalBusinessName":"KEYBANK","dbaNames":["KEYBANK NA","FIRST NIAGARA BANK NA","FIRST NIAGARA SPECIALTY INSURANCE AGENCY","KEYBANK NA","KEYBANK N A","KEY BANK NA","KEYBANK NATL ASSN","KEYCORP INSURANCE AGENCY USA INC INC","HARLEYSVILLE NATIONAL BANK","EAST PENN BANK"],"customerDisputeIndicator":false},"sicCodes":[{"code":"6029","definition":"COMMERCIAL BANKS, NEC"},{"code":"6163","definition":"LOAN BROKERS"}],"naicsCodes":[{"code":"922110","definition":"Commercial Banking"},{"code":"522310","definition":"Mortgage and Nonmortgage Loan Brokers"}],"publicIndicator":false,"nonProfitIndicator":false,"yearsOnFile":44,"stateOfIncorporation":"IN","dateOfIncorporation":"1996-06-19","businessType":null,"employeeSize":null,"employeeSizeCode":null,"salesRevenue":null,"salesSizeCode":null,"fortune1000":{"year":null,"rank":null},"corporateLinkageType":"Headquarters/Parent","executiveInformation":null}}';
        Test.setMock(HttpCalloutMock.class, mockObj);
        
        test.startTest();
        
        
        
        updateCreditDetails.callExperianCreditAssessment(new List<Id>{cc.Id});
        
        String prListToUpdate = JSON.serialize(new List<Pricing_Request__c>{pr});
        updateCreditDetails.callExperianSync(cc.Id, prListToUpdate, true, price);
        updateCreditDetails.codeCvrMeth();
        test.stopTest();
        
    }
    
    /*public static testMethod void setupMethod8(){
        Test.startTest();
        updateCreditDetails.sampleMethod();
        Test.stopTest();
    }*/
    
    
    
}