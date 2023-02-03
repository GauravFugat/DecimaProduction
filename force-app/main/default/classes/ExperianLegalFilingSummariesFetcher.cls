public class ExperianLegalFilingSummariesFetcher {
    
    @invocableMethod
    public static void getBusinessFacts(List<Id> AccId){
        Account accRecord = [SELECT Id, Name, BillingPostalCode,Last_Successful_Experian_Legal_Filings__c, BillingStreet, BillingCity, BillingState FROM Account WHERE Id =: AccId[0]];
        
        if(checkThreshold.checkDate(accRecord.Last_Successful_Experian_Legal_Filings__c)){
            makeCallout(AccId[0]);
        }
    }
    
    @future(callout=true)
    public static void makeCallout(Id acctId){
        
        Account acc = [SELECT EXPRN__Exp_Business__c FROM Account WHERE Id =: acctId ];
        
        EXPRN__Experian_Business__c expBusiness = [SELECT Id,EXPRN__BIN__c FROM EXPRN__Experian_Business__c where Id =: acc.EXPRN__Exp_Business__c ORDER BY CreatedDate DESC LIMIT 1];
        
        Experian__c creds = [SELECT Id, Auth_URL__c,Legal_Filings_Summary_URL__c, Auth_Body__c, Subcode__c FROM Experian__c];
        
        reqBody body = new reqBody();
        
        body.bin = expBusiness.EXPRN__BIN__c;
        body.subcode = creds.Subcode__c;//String.valueOf(creds.Subcode__c);
        body.legalFilingsCollectionsSummary = true;
        body.legalFilingsSummary = true;
        
        ResponseWrapper ResponseWrapper ;
        String token = ExperianCallout.tokenFetcher(String.valueOf(creds.Auth_URL__c), creds.Auth_Body__c);
        HttpResponse response = ExperianCallout.serchResponseFetcher(String.valueOf(creds.Legal_Filings_Summary_URL__c), token, JSON.serialize(body));
        if(response.getStatusCode() == 200){
            
            ResponseWrapper = (ResponseWrapper) System.JSON.deserialize(response.getBody(), ResponseWrapper.class);
            
        }
        System.debug('Response - >'+ResponseWrapper.results);
        results results = ResponseWrapper.results;
        
        EXPRN__Exp_Business_Info__c expBusinessInfo = [SELECT Id FROM EXPRN__Exp_Business_Info__c Where EXPRN__Account_Name__c =: acctId ORDER BY CreatedDate DESC LIMIT 1];
        expBusinessInfo.EXPRN__Tax_Lien_filings__c = String.valueOf(results.legalFilingsCollectionsSummary.lienCount);
        expBusinessInfo.EXPRN__Judgment_filings__c	 = String.valueOf(results.legalFilingsCollectionsSummary.judgmentCount);
        if(results.legalFilingsCollectionsSummary.bankruptcyIndicator){
            expBusinessInfo.EXPRN__Bankruptcy__c = 'Yes';
        }
        
        expBusinessInfo.EXPRN__Experian_Bankruptcy_Count__c = String.valueOf(results.legalFilingsCollectionsSummary.bankruptcyCount); 
        expBusinessInfo.EXPRN__Experian_Lien_Bal__c = String.valueOf(results.legalFilingsCollectionsSummary.lienBalance);
        expBusinessInfo.EXPRN__Experian_Judgment_Bal__c = String.valueOf(results.legalFilingsCollectionsSummary.judgmentBalance);
        expBusinessInfo.EXPRN__UCC_filings__c = String.valueOf(results.legalFilingsCollectionsSummary.uccFilingsCount);
        expBusinessInfo.EXPRN__All_Collections_Count__c = String.valueOf(results.legalFilingsCollectionsSummary.collectionCount);
        expBusinessInfo.EXPRN__All_collections_147__c = String.valueOf(results.legalFilingsCollectionsSummary.collectionBalance);   
        update expBusinessInfo;
        
        acc.Last_Successful_Experian_Legal_Filings__c = System.now();
        update acc;
        
        Integration_Log__c newIntegrationLog = new Integration_Log__c();
        newIntegrationLog.EndPointURL__c = String.valueOf(creds.Legal_Filings_Summary_URL__c);
        newIntegrationLog.Request_Type__c = 'Post';
        newIntegrationLog.Account__c = acctId;
        newIntegrationLog.Response_Body__c = response.getBody();
        newIntegrationLog.Status_Code__c = response.getStatusCode();
        newIntegrationLog.Status__c = response.getStatus();
        Insert newIntegrationLog;
    }
    /*************************************************************/
    
    //Used for SU-621 to call Experian
    //  @future(callout=true)
    public static sendResponseData makeCalloutNew(Id acctId){
        
        Account accRecord = [SELECT Id, Name, BillingPostalCode,Last_Successful_Experian_Legal_Filings__c, BillingStreet, BillingCity, BillingState FROM Account WHERE Id =: acctId];
        
        if(checkThreshold.checkDate(accRecord.Last_Successful_Experian_Legal_Filings__c)){
            Account acc = [SELECT EXPRN__Exp_Business__c FROM Account WHERE Id =: acctId ];
            
            EXPRN__Experian_Business__c expBusiness = [SELECT Id,EXPRN__BIN__c FROM EXPRN__Experian_Business__c where Id =: acc.EXPRN__Exp_Business__c ORDER BY CreatedDate DESC LIMIT 1];
            
            Experian__c creds = [SELECT Id, Auth_URL__c,Legal_Filings_Summary_URL__c, Auth_Body__c, Subcode__c FROM Experian__c];
            
            reqBody body = new reqBody();
            
            body.bin = expBusiness.EXPRN__BIN__c;
            body.subcode = creds.Subcode__c;//String.valueOf(creds.Subcode__c);
            body.legalFilingsCollectionsSummary = true;
            body.legalFilingsSummary = true;
            
            ResponseWrapper ResponseWrapper = new ResponseWrapper();
            if(Test.isRunningTest()){
                 String token ='1234egnrjgfhr';
            }
           
            String token = ExperianCallout.tokenFetcher(String.valueOf(creds.Auth_URL__c), creds.Auth_Body__c);
            HttpResponse response = ExperianCallout.serchResponseFetcher(String.valueOf(creds.Legal_Filings_Summary_URL__c), token, JSON.serialize(body));
            if(response.getStatusCode() == 200){
                
                ResponseWrapper = (ResponseWrapper) System.JSON.deserialize(response.getBody(), ResponseWrapper.class);
                
            
            System.debug('Response - >'+ResponseWrapper);
            
            Integration_Log__c newIntegrationLog = new Integration_Log__c();
            newIntegrationLog.EndPointURL__c = String.valueOf(creds.Legal_Filings_Summary_URL__c);
            newIntegrationLog.Request_Type__c = 'Post';
            newIntegrationLog.Account__c = acctId;
            newIntegrationLog.Response_Body__c = response.getBody();
            newIntegrationLog.Status_Code__c = response.getStatusCode();
            newIntegrationLog.Status__c = response.getStatus();
            Insert newIntegrationLog;
            
            
            results results = ResponseWrapper.results;
            
            
            EXPRN__Exp_Business_Info__c expBusinessInfo = [SELECT Id,CreatedDate,EXPRN__Tax_Lien_filings__c,EXPRN__Judgment_filings__c,EXPRN__Account_Name__c FROM EXPRN__Exp_Business_Info__c Where EXPRN__Account_Name__c =: acctId order by CreatedDate desc limit 1];
            expBusinessInfo.EXPRN__Tax_Lien_filings__c = String.valueOf(results.legalFilingsCollectionsSummary.lienCount);
            expBusinessInfo.EXPRN__Judgment_filings__c	 = String.valueOf(results.legalFilingsCollectionsSummary.judgmentCount);
            if(results.legalFilingsCollectionsSummary.bankruptcyIndicator){
                expBusinessInfo.EXPRN__Bankruptcy__c = 'Yes';
            }
            
            expBusinessInfo.EXPRN__Experian_Bankruptcy_Count__c = String.valueOf(results.legalFilingsCollectionsSummary.bankruptcyCount); 
            expBusinessInfo.EXPRN__Experian_Lien_Bal__c = String.valueOf(results.legalFilingsCollectionsSummary.lienBalance);
            expBusinessInfo.EXPRN__Experian_Judgment_Bal__c = String.valueOf(results.legalFilingsCollectionsSummary.judgmentBalance);
            expBusinessInfo.EXPRN__UCC_filings__c = String.valueOf(results.legalFilingsCollectionsSummary.uccFilingsCount);
            expBusinessInfo.EXPRN__All_Collections_Count__c = String.valueOf(results.legalFilingsCollectionsSummary.collectionCount);
            expBusinessInfo.EXPRN__All_collections_147__c = String.valueOf(results.legalFilingsCollectionsSummary.collectionBalance);
            update expBusinessInfo;
            
            acc.Last_Successful_Experian_Legal_Filings__c = System.now();
            update acc;
            
                System.debug('lien-->'+results.legalFilingsCollectionsSummary.lienCount);
                System.debug('judgment-->'+results.legalFilingsCollectionsSummary.judgmentCount);
            
            
            return new sendResponseData(results.legalFilingsCollectionsSummary.lienCount,results.legalFilingsCollectionsSummary.judgmentCount);
        }
            else{
                Integration_Log__c newIntegrationLog = new Integration_Log__c();
            newIntegrationLog.EndPointURL__c = String.valueOf(creds.Legal_Filings_Summary_URL__c);
            newIntegrationLog.Request_Type__c = 'Post';
            newIntegrationLog.Account__c = acctId;
            newIntegrationLog.Response_Body__c = response.getBody();
            newIntegrationLog.Status_Code__c = response.getStatusCode();
            newIntegrationLog.Status__c = response.getStatus();
            Insert newIntegrationLog;
                return new sendResponseData(0,0);
            }
            
        }else{
            EXPRN__Exp_Business_Info__c expBusinessInfo = [SELECT Id,EXPRN__Tax_Lien_filings__c,EXPRN__Judgment_filings__c FROM EXPRN__Exp_Business_Info__c Where EXPRN__Account_Name__c =: acctId ORDER BY CreatedDate LIMIT 1];
            System.debug('lien-->'+Integer.valueOf(expBusinessInfo.EXPRN__Tax_Lien_filings__c));
            System.debug('judgment-->'+Integer.valueOf(expBusinessInfo.EXPRN__Judgment_filings__c));
            return new sendResponseData(Integer.valueOf(expBusinessInfo.EXPRN__Tax_Lien_filings__c),Integer.valueOf(expBusinessInfo.EXPRN__Judgment_filings__c));
        }
        
    }
    
    public class sendResponseData{
        public Integer lienCount{get;set;}
        public Integer judgmentCount{get;set;}
        
        public sendResponseData(Integer lienCount,Integer judgmentCount){
            this.lienCount = lienCount;
            this.judgmentCount = judgmentCount;
        }
        public sendResponseData(){
            
        }
    }
    
    
    //Request Wrapper class
    public class reqBody{
        public String bin{get;set;}
        public String subcode{get;set;}
        public Boolean legalFilingsCollectionsSummary{get;set;}
        public Boolean legalFilingsSummary{get;set;}
    }
    
    //Response Wrapper class
    public class ResponseWrapper{
        public Boolean success{get;set;}
        public results results{get;set;}
        public String requestId{get;set;}
    }
    public class results{
        public legalFilingsSummary legalFilingsSummary{get;set;}
        public legalFilingsCollectionsSummary legalFilingsCollectionsSummary{get;set;}
        public businessHeader businessHeader{get;set;}
    }
    public class legalFilingsSummary{
        public Integer legalBalance{get;set;}
        public Integer legalCount{get;set;}
        public Integer derogatoryLegalCount{get;set;}
    }
    public class legalFilingsCollectionsSummary{
        public Integer lienCount{get;set;}
        public Integer lienBalance{get;set;}
        public Integer judgmentCount{get;set;}
        public Integer bankruptcyCount{get;set;}
        public Integer judgmentBalance{get;set;}
        public Boolean bankruptcyIndicator{get;set;}
        public Integer uccFilingsCount{get;set;}
        public Integer derogatoryLegalCount{get;set;}
        public Integer uccDerogatoryCount{get;set;}
        public Integer legalBalance{get;set;}
        public Integer collectionCount{get;set;}
        public Integer legalCount{get;set;}
        public Integer collectionBalance{get;set;}
    }
    public class businessHeader{
        public Boolean customerDisputeIndicator{get;set;}
        public String taxId{get;set;}
        public String phone{get;set;}
        public String websiteUrl{get;set;}
        public address address{get;set;}
        public String legalBusinessName{get;set;}
        public String businessName{get;set;}
        public list<String> dbaNames{get;set;}
        public String bin{get;set;}
    }
    public class address{
        public String zipExtension{get;set;}
        public String state{get;set;}
        public String city{get;set;}
        public String zip{get;set;}
        public String street{get;set;}
    }
    
}