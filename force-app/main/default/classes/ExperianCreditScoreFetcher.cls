public class ExperianCreditScoreFetcher {
    
    @invocableMethod
    public static void getCreditScores(List<Id> pricingReq){
        String sObjName = pricingReq[0].getSObjectType().getDescribe().getName();
        if(sObjName == 'Account'){
            makeCalloutAcc(pricingReq[0]);
        }
        else{
            system.debug('pricingReq==>'+pricingReq);
            String oppId = [SELECT Id, Opportunity__c FROM Pricing_Request__c WHERE ID IN: pricingReq LIMIT 1].Opportunity__c;
            List<Credit_Check__c> activeCCRecords = [SELECT Id FROM Credit_Check__c WHERE Opportunity__c =: oppId AND Status__c = 'Active'];
            String recordTypeName = [SELECT ID, RecordType.Name FROM Pricing_Request__c WHERE Id IN: pricingReq limit 1].RecordType.Name;
            if(activeCCRecords.isEmpty() && recordTypeName == 'Credit Check Required'){
                makeCallout(pricingReq[0], oppId);
            }
        }
    }
    @future(callout=true)
    public static void makeCallout(Id pricingReqId, Id oppId){
        Experian__c creds = [SELECT Id, Scores_EndPoint__c, Auth_URL__c, Auto_Search_URL__c, Auth_Body__c, Subcode__c FROM Experian__c];
        Opportunity oppRecord = [SELECT Id,AccountId, Account.Name, Account.BillingPostalCode, Account.BillingStreet, Account.BillingCity, Account.BillingState FROM Opportunity WHERE Id =: oppId];
        Account accRecord = [SELECT EXPRN__Exp_Business__c FROM Account WHERE Id =: oppRecord.AccountId];
        EXPRN__Experian_Business__c expBusiness1 = [SELECT Id,EXPRN__BIN__c FROM EXPRN__Experian_Business__c where Id =: accRecord.EXPRN__Exp_Business__c ORDER BY CreatedDate DESC LIMIT 1];
        requestPayload body = new requestPayload();
        body.bin = expBusiness1.EXPRN__BIN__c;
        body.commercialScore = True;
        body.subcode = creds.Subcode__c;//String.valueOf(creds.Subcode__c);
        body.fsrScore = True;
        String token = ExperianCallout.tokenFetcher(String.valueOf(creds.Auth_URL__c), creds.Auth_Body__c);
        HttpResponse response = ExperianCallout.serchResponseFetcher(String.valueOf(creds.Scores_EndPoint__c), token, JSON.serialize(body));
        Integer fsrScoreValue = 0;
        Integer ipScoreValue = 0;
        if(response.getStatusCode() == 200){
            Map<String, Object> resp = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            Map<String, Object> res = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(resp.get('results')));
            commercialScore cScore = (commercialScore) JSON.deserialize(JSON.serialize(res.get('commercialScore')), commercialScore.class);
            fsrScore fsrScore = (fsrScore) JSON.deserialize(JSON.serialize(res.get('fsrScore')), fsrScore.class);
            ipScoreValue = cScore.Score;
            fsrScoreValue = fsrScore.Score;
        }
        Credit_Check__c newCCRecord = new Credit_Check__c();
        if(fsrScoreValue != NULL && ipScoreValue != NULL && response.getStatusCode() == 200){
            newCCRecord.Status__c = 'Active';
            newCCRecord.FSR_Score__c = fsrScoreValue;
            newCCRecord.IP_Score__c = ipScoreValue;
            newCCRecord.Customer__c = oppRecord.AccountId;
        }
        else
            newCCRecord.Status__c = 'New';
        newCCRecord.Pricing_Request__c = pricingReqId;
        newCCRecord.Opportunity__c = oppId;
        newCCRecord.Customer__c = oppRecord.AccountId;
        Insert newCCRecord;
        
        Integration_Log__c newIntegrationLog = new Integration_Log__c();
        newIntegrationLog.EndPointURL__c = String.valueOf(creds.Scores_EndPoint__c);
        newIntegrationLog.Request_Type__c = 'Post';
        newIntegrationLog.Pricing_Request__c = pricingReqId;
        newIntegrationLog.Response_Body__c = response.getBody();
        newIntegrationLog.Status_Code__c = response.getStatusCode();
        newIntegrationLog.Status__c = response.getStatus();
        newIntegrationLog.Request_Body__c = JSON.serialize(body);
        Insert newIntegrationLog;
        System.debug('newIntegrationLog-->> '+newIntegrationLog);
    }
    
    @future(callout=true)
    public static void makeCalloutAcc (Id AccId){
        Account accRecord = [SELECT Id, EXPRN__Exp_Business__c,Name, BillingPostalCode,Last_Successful_Experian_Scores__c, BillingStreet, BillingCity, BillingState FROM Account WHERE Id =: AccId];
        EXPRN__Experian_Business__c expBusiness1 = [SELECT Id,EXPRN__BIN__c FROM EXPRN__Experian_Business__c where Id =: accRecord.EXPRN__Exp_Business__c ORDER BY CreatedDate DESC LIMIT 1];
        Experian__c creds = [SELECT Id,Scores_EndPoint__c, Auth_URL__c, Auto_Search_URL__c, Auth_Body__c, Subcode__c FROM Experian__c];
        requestPayload body = new requestPayload();
        body.bin = expBusiness1.EXPRN__BIN__c;
        body.commercialScore = True; 
        body.subcode = creds.Subcode__c;//String.valueOf(creds.Subcode__c);
        body.fsrScore = True;
        String token = ExperianCallout.tokenFetcher(String.valueOf(creds.Auth_URL__c), creds.Auth_Body__c);
        
        HttpResponse response = ExperianCallout.serchResponseFetcher(String.valueOf(creds.Scores_EndPoint__c), token, JSON.serialize(body));
        System.debug('response11-->> '+response);
        Integer fsrScoreValue = 0;
        Integer ipScoreValue = 0;
        if(response.getStatusCode() == 200){
            Map<String, Object> resp = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            Map<String, Object> res = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(resp.get('results')));
            
            commercialScore cScore = (commercialScore) JSON.deserialize(JSON.serialize(res.get('commercialScore')), commercialScore.class);
            fsrScore fsrScore = (fsrScore) JSON.deserialize(JSON.serialize(res.get('fsrScore')), fsrScore.class);
            ipScoreValue = cScore.Score;
            fsrScoreValue = fsrScore.Score;
            
            List<EXPRN__Exp_Business_Info__c> expBusinessInfo = [SELECT Id, EXPRN__Financial_Stability_Risk__c, EXPRN__sbcs_score__c, EXPRN__Account_Name__c
                                                                 FROM EXPRN__Exp_Business_Info__c
                                                                 WHERE EXPRN__Account_Name__c =: AccId ORDER BY CreatedDate DESC LIMIT 1];
            
            if(expBusinessInfo.size() > 0){
                System.debug('Socres-->'+String.valueOf(fsrScore.Score)+'-->'+String.valueOf(cScore.Score));
                expBusinessInfo[0].EXPRN__FSR_Score__c  = String.valueOf(fsrScore.Score);
                expBusinessInfo[0].EXPRN__Intelliscore_Plus__c  = String.valueOf(cScore.Score);
                expBusinessInfo[0].EXPRN__Financial_Stability_Risk__c = String.valueOf(fsrScore.Score);
                expBusinessInfo[0].EXPRN__sbcs_score__c  = String.valueOf(cScore.Score);
                expBusinessInfo[0].EXPRN__Credit_Limit_Recommendation__c = String.valueOf(fsrScore.recommendedCreditLimitAmount);
                update expBusinessInfo[0];
                
                Account acc = [SELECT EXPRN__Exp_Business__c FROM Account WHERE Id =: AccId ];
                EXPRN__Experian_Business__c expBusiness = [SELECT Id,EXPRN__BIN__c FROM EXPRN__Experian_Business__c where Id =: acc.EXPRN__Exp_Business__c ORDER BY CreatedDate DESC LIMIT 1];
                expBusiness.EXPRN__Scoring_Model__c = cScore.modelCode;
                update expBusiness;
            }
        }
        
        if(response.getStatusCode() == 200){  
            accRecord.Last_Successful_Experian_Scores__c = System.now();
            update accRecord;
        }
        
        Integration_Log__c newIntegrationLog = new Integration_Log__c();
        newIntegrationLog.EndPointURL__c = String.valueOf(creds.Scores_EndPoint__c);
        newIntegrationLog.Request_Type__c = 'Post';
        newIntegrationLog.Account__c = AccId;
        //if(!Test.isRunningTest()){
        newIntegrationLog.Response_Body__c = response.getBody();
        newIntegrationLog.Status_Code__c = response.getStatusCode();
        newIntegrationLog.Status__c = response.getStatus();
       // }
        newIntegrationLog.Request_Body__c = JSON.serialize(body);
        Insert newIntegrationLog;
        
    }
    
    /***************************************FROM PRICING REQUEST COMPONENT*******************************************************/
    
    
    public static sendSocreData makeCalloutAccSync (Id AccId){
        
        sendSocreData sendSocreDataobj = new sendSocreData();
        Integration_Log__c newIntegrationLog = new Integration_Log__c();
        Account accRecord = [SELECT Id,EXPRN__Exp_Business__c, Name, BillingPostalCode,Last_Successful_Experian_Scores__c, BillingStreet, BillingCity, BillingState FROM Account WHERE Id =: AccId];
        
        EXPRN__Experian_Business__c expBusiness1 = [SELECT Id,EXPRN__BIN__c FROM EXPRN__Experian_Business__c where Id =: accRecord.EXPRN__Exp_Business__c ORDER BY CreatedDate DESC LIMIT 1];
        
        if(checkThreshold.checkDate(accRecord.Last_Successful_Experian_Scores__c)){
            Experian__c creds = [SELECT Id,Scores_EndPoint__c, Auth_URL__c, Auto_Search_URL__c,Business_Search_URL__c, Auth_Body__c, Subcode__c FROM Experian__c];
            System.debug('creds-->> '+creds);
            sendSocreDataobj.apiCalled = true;
            
            requestPayload body = new requestPayload();
            //body.name = accRecord.Name;
            //body.zip = accRecord.BillingPostalCode;
            //body.street = accRecord.BillingStreet;
            //body.City = accRecord.BillingCity;
            //body.State = accRecord.BillingState;
            //body.geo = True;
            body.bin = expBusiness1.EXPRN__BIN__c;
            body.commercialScore = True;
            body.subcode = creds.Subcode__c;//String.valueOf(creds.Subcode__c);
            body.fsrScore = True;
            System.debug('JSON.serialize(body)-->> '+JSON.serialize(body));
            Integer fsrScoreValue = 0;
            Integer ipScoreValue = 0;
            Integer ipScoreTrend = 0;
            Integer fsrScoreTrend = 0;  
            String token;
            HttpResponse response ;
            try{
                
                token = ExperianCallout.tokenFetcher(String.valueOf(creds.Auth_URL__c), creds.Auth_Body__c);
            // HttpResponse response = ExperianCallout.serchResponseFetcher(String.valueOf(creds.Auto_Search_URL__c), token, JSON.serialize(body));
            //String url = 'https://sandbox-us-api.experian.com/businessinformation/businesses/v1/scores';
            response = ExperianCallout.serchResponseFetcher(String.valueOf(creds.Scores_EndPoint__c), token, JSON.serialize(body));
            if(response.getStatusCode() == 200){
                Map<String, Object> resp = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                Map<String, Object> res = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(resp.get('results')));
                JsonParser JsonParser ;
                JsonParser = (JsonParser) System.JSON.deserialize(response.getBody(), JsonParser.class);
                List<commercialScoreTrends> csTrendLst = new List<commercialScoreTrends>();
                List<fsrScoreTrends> fsrTrendLst = new List<fsrScoreTrends>();
                csTrendLst = JsonParser.results.commercialScoreTrends;
                fsrTrendLst = JsonParser.results.fsrScoreTrends;
                commercialScore cScore = (commercialScore) JSON.deserialize(JSON.serialize(res.get('commercialScore')), commercialScore.class);
                fsrScore fsrScore = (fsrScore) JSON.deserialize(JSON.serialize(res.get('fsrScore')), fsrScore.class);
                ipScoreValue = cScore.Score;
                fsrScoreValue = fsrScore.Score;
                if(csTrendLst?.size() > 0){                    
                    ipScoreTrend = getVariance(ipScoreValue,csTrendLst[0].score);
                    fsrScoreTrend = getVariance(fsrScoreValue,fsrTrendLst[0].score);
                    sendSocreDataobj.commercialScoreTrends = csTrendLst;
                    sendSocreDataobj.fsrScoreTrends = fsrTrendLst;    
                }
                sendSocreDataobj.commercialscoreTrend = ipScoreTrend;
                sendSocreDataobj.fsrScoreTrend = fsrScoreTrend;    
                List<EXPRN__Exp_Business_Info__c> expBusinessInfo = [SELECT Id, EXPRN__Financial_Stability_Risk__c, EXPRN__sbcs_score__c, EXPRN__Account_Name__c
                                                                     FROM EXPRN__Exp_Business_Info__c
                                                                     WHERE EXPRN__Account_Name__c =: AccId];
                
                if(expBusinessInfo.size() > 0){
                    System.debug('Socres-->'+String.valueOf(fsrScore.Score)+'-->'+String.valueOf(cScore.Score));
                    sendSocreDataobj.ipscore = cScore.Score;
                    sendSocreDataobj.fsrscore = fsrScore.Score;
                    expBusinessInfo[0].EXPRN__FSR_Score__c  = String.valueOf(fsrScore.Score);
                    expBusinessInfo[0].EXPRN__Intelliscore_Plus__c  = String.valueOf(cScore.Score);
                    expBusinessInfo[0].EXPRN__Financial_Stability_Risk__c = String.valueOf(fsrScore.Score);
                    expBusinessInfo[0].EXPRN__sbcs_score__c  = String.valueOf(cScore.Score);
                    expBusinessInfo[0].EXPRN__Credit_Limit_Recommendation__c = String.valueOf(fsrScore.recommendedCreditLimitAmount);
                    expBusinessInfo[0].CommercialTrends__c = JSON.serialize(csTrendLst);
                    sendSocreDataobj.commercialScoreTrendsString = JSON.serialize(csTrendLst);
                    sendSocreDataobj.fsrScoreTrendsString = JSON.serialize(fsrTrendLst);
                    expBusinessInfo[0].FsrTrends__c = JSON.serialize(fsrTrendLst);
                    //update expBusinessInfo[0];
                    
                    Account acc = [SELECT EXPRN__Exp_Business__c FROM Account WHERE Id =: AccId ];
                    EXPRN__Experian_Business__c expBusiness = [SELECT Id,EXPRN__BIN__c FROM EXPRN__Experian_Business__c where Id =: acc.EXPRN__Exp_Business__c ];
                    expBusiness.EXPRN__Scoring_Model__c = cScore.modelCode;
                    //  update expBusiness;
                }
            }
            
            if(response.getStatusCode() == 200 ||response.getStatusCode() == 201 ){
                accRecord.Last_Successful_Experian_Scores__c = System.now();
                // update accRecord;
            }
            newIntegrationLog.EndPointURL__c = String.valueOf(creds.Scores_EndPoint__c);
            newIntegrationLog.Request_Type__c = 'Post';
            newIntegrationLog.Account__c = AccId;
            newIntegrationLog.Response_Body__c = response.getBody();
            newIntegrationLog.Status_Code__c = response.getStatusCode();
            newIntegrationLog.Status__c = response.getStatus();
            newIntegrationLog.Request_Body__c = JSON.serialize(body);
                sendSocreDataobj.intLog = newIntegrationLog;
            //Insert Statement below was commented before
            //Insert newIntegrationLog;
            }catch(Exception ex){
            
            system.debug('Error message'+ex.getMessage() + ' line No:- '+ex.getLineNumber());
            newIntegrationLog.EndPointURL__c = String.valueOf(creds.Auto_Search_URL__c);
            newIntegrationLog.Request_Type__c = 'Post';
            newIntegrationLog.Account__c = AccId;
            newIntegrationLog.Response_Body__c = ex.getMessage();
            newIntegrationLog.Status_Code__c = response.getStatusCode();
            newIntegrationLog.Status__c = response.getStatus();
            newIntegrationLog.Request_Body__c = JSON.serialize(body);
            sendSocreDataobj.intLog = newIntegrationLog;
             //Insert newIntegrationLog;
        }
            
        }
        else{
            sendSocreDataobj.apiCalled = false;
            List<EXPRN__Exp_Business_Info__c> expBusinessInfo = [SELECT Id,CommercialTrends__c,FsrTrends__c,EXPRN__Intelliscore_Plus__c,EXPRN__FSR_Score_Change__c,EXPRN__Score_Change__c ,EXPRN__FSR_Score__c, EXPRN__Financial_Stability_Risk__c, EXPRN__sbcs_score__c, EXPRN__Account_Name__c
                                                                 FROM EXPRN__Exp_Business_Info__c
                                                                 WHERE EXPRN__Account_Name__c =: AccId ORDER BY CreatedDate DESC LIMIT 1];
            if(expBusinessInfo.size() > 0){
                if(expBusinessInfo[0].EXPRN__sbcs_score__c != null && expBusinessInfo[0].EXPRN__sbcs_score__c != 'N/A'){
                    sendSocreDataobj.ipscore = integer.valueof(expBusinessInfo[0].EXPRN__sbcs_score__c);
                }
                if(expBusinessInfo[0].EXPRN__Financial_Stability_Risk__c != null && expBusinessInfo[0].EXPRN__Financial_Stability_Risk__c != 'N/A'){
                    sendSocreDataobj.fsrscore = integer.valueof(expBusinessInfo[0].EXPRN__Financial_Stability_Risk__c);
                }
                if(expBusinessInfo[0].EXPRN__Intelliscore_Plus__c != null && expBusinessInfo[0].EXPRN__Intelliscore_Plus__c != 'N/A'){
                    sendSocreDataobj.ipscore = integer.valueof(expBusinessInfo[0].EXPRN__Intelliscore_Plus__c);
                }
                if(expBusinessInfo[0].EXPRN__FSR_Score__c != null && expBusinessInfo[0].EXPRN__FSR_Score__c != 'N/A'){
                    sendSocreDataobj.fsrscore = integer.valueof(expBusinessInfo[0].EXPRN__FSR_Score__c);
                }
                if(expBusinessInfo[0].EXPRN__FSR_Score_Change__c != null && expBusinessInfo[0].EXPRN__FSR_Score_Change__c != 'N/A'){
                    sendSocreDataobj.fsrscoreTrend = integer.valueof(expBusinessInfo[0].EXPRN__FSR_Score_Change__c);
                }
                if(expBusinessInfo[0].EXPRN__Score_Change__c  != null && expBusinessInfo[0].EXPRN__Score_Change__c  != 'N/A'){
                    sendSocreDataobj.commercialscoreTrend = integer.valueof(expBusinessInfo[0].EXPRN__Score_Change__c);
                }
                if(expBusinessInfo[0].CommercialTrends__c  != null){
                    sendSocreDataobj.commercialScoreTrendsString = expBusinessInfo[0].CommercialTrends__c;
                }
                if(expBusinessInfo[0].fsrTrends__c  != null){
                    sendSocreDataobj.fsrScoreTrendsString = expBusinessInfo[0].fsrTrends__c;
                }
            }
            
        }
        
        //sendSocreDataobj.intLog = newIntegrationLog;
        return sendSocreDataobj;
    }
    
    public static void updateSocres(String response,Id AccId){
        sendSocreData sendSocreData ;
        sendSocreData = (sendSocreData) System.JSON.deserialize(response, sendSocreData.class);
        
        Account accRecord = [SELECT Id, 
                             Last_Successful_Experian_Scores__c
                             FROM Account 
                             WHERE Id =: AccId];
        
        List<EXPRN__Exp_Business_Info__c> expBusinessInfo = [SELECT Id,
                                                             EXPRN__FSR_Score_Change__c,
                                                             EXPRN__Score_Change__c,
                                                             EXPRN__Financial_Stability_Risk__c, 
                                                             EXPRN__sbcs_score__c,
                                                             EXPRN__Account_Name__c
                                                             FROM EXPRN__Exp_Business_Info__c
                                                             WHERE EXPRN__Account_Name__c =: AccId ORDER BY CreatedDate DESC LIMIT 1];
        
        expBusinessInfo[0].EXPRN__FSR_Score__c  = String.valueOf(sendSocreData.fsrscore);
        expBusinessInfo[0].EXPRN__Intelliscore_Plus__c  = String.valueOf(sendSocreData.ipscore);
        expBusinessInfo[0].EXPRN__Financial_Stability_Risk__c = String.valueOf(sendSocreData.fsrscore);
        expBusinessInfo[0].EXPRN__sbcs_score__c  = String.valueOf(sendSocreData.ipscore);
        expBusinessInfo[0].EXPRN__FSR_Score_Change__c = String.valueOf(sendSocreData.fsrscoreTrend);
        expBusinessInfo[0].EXPRN__Score_Change__c = String.valueOf(sendSocreData.commercialscoreTrend);
        try{
            expBusinessInfo[0].FsrTrends__c  = sendSocreData.fsrScoreTrendsString.replace('/','');
            expBusinessInfo[0].CommercialTrends__c = sendSocreData.commercialScoreTrendsString.replace('/',''); 
        }catch(Exception e){
            
        }
        update expBusinessInfo[0];
        
    }
    
    public static integer getVariance(integer num1, integer num2){
        integer diff = num1 - num2;
        return Math.abs(diff);
    }
    
    
    public class sendSocreData{
        public Integer ipscore{get;set;}
        public Integer fsrscore{get;set;}
        public Integer commercialscoreTrend{get;set;}
        public Integer fsrscoreTrend{get;set;}
        public Integration_Log__c intLog{get;set;}
        public boolean apiCalled{get;set;}
        public list<commercialScoreTrends> commercialScoreTrends{get;set;}
        public list<fsrScoreTrends> fsrScoreTrends{get;set;}
        public String commercialScoreTrendsString{get;set;}
        public String fsrScoreTrendsString{get;set;}
        
        public sendSocreData(Integer ipscore,Integer fsrscore){
            this.ipscore = ipscore;
            this.fsrscore = fsrscore;
        }
        public sendSocreData(){
            
        }
    }
    
    
    
    public class requestPayload{
        // public String taxId{get;set;}
        // public String phone{get;set;}
        // public Boolean geo{get;set;}
        // public String zip{get;set;}
        // public String comments{get;set;}
        // public String street{get;set;}
        public String modelCode{get;set;}
        public String subcode{get;set;}
        // public Integer matchReliabilityCode{get;set;}
        // public String state{get;set;}
        public Boolean commercialScore{get;set;}
        // public String city{get;set;}
        public Boolean fsrScore{get;set;}
        // public String name{get;set;}
        
        public String bin{get;set;}
    }
    
    
    
    public class JsonParser{
        public String comments{get;set;}
        public Boolean success{get;set;}
        public results results{get;set;}
        public String requestId{get;set;}
    }
    public class riskClass{
        public String definition{get;set;}
        public Integer code{get;set;}
        
    }
    public class results{
        public list<commercialScoreTrends> commercialScoreTrends{get;set;}
        public fsrScore fsrScore{get;set;}
        public list<fsrScoreFactors> fsrScoreFactors{get;set;}
        public list<commercialScoreFactors> commercialScoreFactors{get;set;}
        public list<fsrScoreTrends> fsrScoreTrends{get;set;}
        public commercialScore commercialScore{get;set;}
        //public list<listOfSimilars> listOfSimilars{get;set;}
        public businessHeader businessHeader{get;set;}
    }
    /*public class listOfSimilars{
public String bin{get;set;}
public Integer numberOfTradelines{get;set;}
public address address{get;set;}
public Boolean financialStatementIndicator{get;set;}
public String phone{get;set;}
public Boolean keyFactsIndicator{get;set;}
public String businessName{get;set;}
public Boolean inquiryIndicator{get;set;}
public Integer reliabilityCode{get;set;}
public Boolean bankDataIndicator{get;set;}
public Boolean executiveSummaryIndicator{get;set;}
public Boolean uccIndicator{get;set;}
public Boolean governmentDataIndicator{get;set;}
public String matchingNameAndAddress{get;set;}
public businessGeocode businessGeocode{get;set;}
}*/
    public class fsrScoreTrends{
        public Integer score{get;set;}
        public String quarter{get;set;}
    }
    public class fsrScoreFactors{
        public String definition{get;set;}
        public String code{get;set;}
    }
    public class fsrScore{
        //public riskClass riskClass{get;set;}
        //public String modelTitle{get;set;}
        public Integer score{get;set;}
        public String modelCode{get;set;}
        public Integer percentileRanking{get;set;}
        public String recommendedCreditLimitAmount{get;set;}
    }
    public class commercialScoreTrends{
        public Integer score{get;set;}
        public String quarter{get;set;}
    }
    public class commercialScoreFactors{
        public String definition{get;set;}
        public String code{get;set;}
    }
    public class commercialScore{
        public Integer percentileRanking{get;set;}
        public Integer score{get;set;}
        //public String customModelCode{get;set;}
        //public Integer recommendedCreditLimitAmount{get;set;}
        //public String modelTitle{get;set;}
        //public riskClass riskClass{get;set;}
        public String modelCode{get;set;}
    }
    public class businessHeader{
        public String taxId{get;set;}
        public String websiteUrl{get;set;}
        public String phone{get;set;}
        public String legalBusinessName{get;set;}
        public address address{get;set;}
        //public list<String> dbaNames{get;set;}
        public String businessName{get;set;}
        //public Boolean customerDisputeIndicator{get;set;}
        public String bin{get;set;}
    }
    /*public class businessGeocode{
public String latitudeLongitudeLevel{get;set;}
public String censusTractCode{get;set;}
public String censusBlkGrpCode{get;set;}
public Boolean cottageIndicator{get;set;}
public String msaCode{get;set;}
public String congressionalDistrictCode{get;set;}
public Decimal longitude{get;set;}
public String dateLastReported{get;set;}
public Decimal latitude{get;set;}
}*/
    public class address{
        public String street{get;set;}
        public String zipExtension{get;set;}
        public String city{get;set;}
        public String zip{get;set;}
        public String state{get;set;}
        
    }
    
    
    
    
}