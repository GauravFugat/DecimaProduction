public class ExperianFraudShieldsFetcher {
    
    @invocableMethod
    public static void getBusinessFacts(List<Id> AccId){
        Account accRecord = [SELECT Id, Name, BillingPostalCode,Last_Successful_Experian_Fraud_Shields__c, BillingStreet, BillingCity, BillingState FROM Account WHERE Id =: AccId];
   
       
           makeCallout(AccId[0]);
      
    }
    
    @future(callout=true)
    public static void makeCallout(Id acctId){
        
        Account acc = [SELECT EXPRN__Exp_Business__c FROM Account WHERE Id =: acctId ];
        
        EXPRN__Experian_Business__c expBusiness = [SELECT Id,EXPRN__BIN__c FROM EXPRN__Experian_Business__c where Id =: acc.EXPRN__Exp_Business__c ORDER BY CreatedDate DESC LIMIT 1];
        
        
        Experian__c creds = [SELECT Id, Auth_URL__c,Fraud_Shields_URL__c, Auth_Body__c, Subcode__c FROM Experian__c];
      
        reqBody body = new reqBody();
        
        //body.bin = expBusiness.EXPRN__BIN__c; 
        body.subcode = creds.Subcode__c; //String.valueOf(creds.Subcode__c);
       
        ResponseWrapper ResponseWrapper ;
        String token ;
        HttpResponse response;
        try{
            token = ExperianCallout.tokenFetcher(String.valueOf(creds.Auth_URL__c), creds.Auth_Body__c);
        response = ExperianCallout.serchResponseFetcher(String.valueOf(creds.Fraud_Shields_URL__c), token, JSON.serialize(body));
        if(response.getStatusCode() == 200 || response.getStatusCode() == 201){
        
            ResponseWrapper = (ResponseWrapper) System.JSON.deserialize(response.getBody(), ResponseWrapper.class);
            
        }
        System.debug('Response - >'+ResponseWrapper.results);
        results results = ResponseWrapper.results;
        
        EXPRN__Exp_Business_Info__c expBusinessInfo = [SELECT Id FROM EXPRN__Exp_Business_Info__c Where EXPRN__Account_Name__c =: acctId];
        expBusinessInfo.EXPRN__Active_Business_Indicator__c = results.activeBusinessIndicator;
        if(results.businessVictimStatementIndicator == true){
            expBusinessInfo.EXPRN__Business_Victim_Statement__c = 'Yes';
            expBusinessInfo.EXPRN__Verification_Triggers__c = results.businessRiskTriggersStatement[0];
        }
        
        update expBusinessInfo;
        
        if(response.getStatusCode() == 200){
        acc.Last_Successful_Experian_Fraud_Shields__c = System.now();
        update acc;
        }
        
        Integration_Log__c newIntegrationLog = new Integration_Log__c();
        newIntegrationLog.EndPointURL__c = String.valueOf(creds.Fraud_Shields_URL__c);
        newIntegrationLog.Request_Type__c = 'Post';
        newIntegrationLog.Account__c = acctId;
        newIntegrationLog.Response_Body__c = response.getBody();
        newIntegrationLog.Status_Code__c = response.getStatusCode();
        newIntegrationLog.Status__c = response.getStatus();
        Insert newIntegrationLog;
            
        }catch(Exception ex){
            system.debug('Error message'+ex.getMessage());    
        Integration_Log__c newIntegrationLog = new Integration_Log__c();
        newIntegrationLog.EndPointURL__c = String.valueOf(creds.Fraud_Shields_URL__c);
        newIntegrationLog.Request_Type__c = 'Post';
        newIntegrationLog.Account__c = acctId;
        newIntegrationLog.Response_Body__c = ex.getMessage();
        newIntegrationLog.Status_Code__c = response.getStatusCode();
        newIntegrationLog.Status__c = response.getStatus();
        Insert newIntegrationLog;
        }
        
    }
    
    public static ResponseWrapper makeCalloutSync(Id acctId){
        Integration_Log__c newIntegrationLog = new Integration_Log__c();
        ResponseWrapper ResponseWrapper  = new ResponseWrapper() ; 
        
        Account acc = [SELECT EXPRN__Exp_Business__c,Last_Successful_Experian_Fraud_Shields__c FROM Account WHERE Id =: acctId ORDER BY CreatedDate DESC LIMIT 1];
        
        if(checkThreshold.checkDate(acc.Last_Successful_Experian_Fraud_Shields__c)){
        
        EXPRN__Experian_Business__c expBusiness = [SELECT Id,EXPRN__BIN__c FROM EXPRN__Experian_Business__c where Id =: acc.EXPRN__Exp_Business__c ];
        
        
        Experian__c creds = [SELECT Id, Auth_URL__c,Fraud_Shields_URL__c, Auth_Body__c, Subcode__c FROM Experian__c];
      
        reqBody body = new reqBody();
        
        body.bin = expBusiness.EXPRN__BIN__c;
        body.subcode = creds.Subcode__c; //String.valueOf(creds.Subcode__c);
            String token;
            HttpResponse response;     
            try{
                token = ExperianCallout.tokenFetcher(String.valueOf(creds.Auth_URL__c), creds.Auth_Body__c);
                response = ExperianCallout.serchResponseFetcher(String.valueOf(creds.Fraud_Shields_URL__c), token, JSON.serialize(body));
                if(response.getStatusCode() == 200 || response.getStatusCode() == 201 ){
                    
                    ResponseWrapper = (ResponseWrapper) System.JSON.deserialize(response.getBody(), ResponseWrapper.class);
                    newIntegrationLog.EndPointURL__c = String.valueOf(creds.Fraud_Shields_URL__c);
                    newIntegrationLog.Request_Type__c = 'Post';
                    newIntegrationLog.Account__c = acctId;
                    newIntegrationLog.Response_Body__c = response.getBody();
                    newIntegrationLog.Status_Code__c = response.getStatusCode();
                    newIntegrationLog.Status__c = response.getStatus();
                    newIntegrationLog.Request_Body__c = JSON.serialize(body);
                    
                }
                else{
                    ResponseWrapper.success = false;
                    CalloutException e = new CalloutException();
                    e.setMessage(response.getBody());
                    throw e;
                }
            }catch(Exception ex){
                system.debug('Error message'+ex.getMessage());
                newIntegrationLog.EndPointURL__c = String.valueOf(creds.Fraud_Shields_URL__c);
                newIntegrationLog.Request_Type__c = 'Post';
                newIntegrationLog.Account__c = acctId;
                newIntegrationLog.Response_Body__c = ex.getMessage();
                newIntegrationLog.Status_Code__c = response.getStatusCode();
                newIntegrationLog.Status__c = response.getStatus();
                newIntegrationLog.Request_Body__c = JSON.serialize(body);
                
            }
            
            
        
        /*newIntegrationLog.EndPointURL__c = String.valueOf(creds.Fraud_Shields_URL__c);
        newIntegrationLog.Request_Type__c = 'Post';
        newIntegrationLog.Account__c = acctId;
        newIntegrationLog.Response_Body__c = response.getBody();
        newIntegrationLog.Status_Code__c = response.getStatusCode();
        newIntegrationLog.Status__c = response.getStatus();
        newIntegrationLog.Request_Body__c = JSON.serialize(body);*/
        //Insert newIntegrationLog;
        
        }
        
        System.debug('ResponseWrapper->'+ResponseWrapper);
        //System.debug('ResponseWrapper.intLog->'+ResponseWrapper.intLog);
        
        if(ResponseWrapper != null){
      
        ResponseWrapper.intLog = newIntegrationLog;
        }
        return ResponseWrapper;
    }
 
    public static void updateFraudShields(String response,Id AccId){
        System.debug('updateFraudShields');
        ResponseWrapper ResponseWrapper ;
        ResponseWrapper = (ResponseWrapper) System.JSON.deserialize(response, ResponseWrapper.class);
        
        Account accRecord = [SELECT Id, 
                             Last_Successful_Experian_Scores__c
                             FROM Account 
                             WHERE Id =: AccId];
        
        EXPRN__Exp_Business_Info__c expBusinessInfo = [SELECT Id
                                                       FROM EXPRN__Exp_Business_Info__c
                                                       Where EXPRN__Account_Name__c =: AccId ORDER BY CreatedDate DESC LIMIT 1];
        results results = ResponseWrapper.results;
        
        expBusinessInfo.EXPRN__Active_Business_Indicator__c = results.activeBusinessIndicator;
        
        if(results.businessVictimStatementIndicator == true){
            expBusinessInfo.EXPRN__Business_Victim_Statement__c = 'Yes';
            
        }
        System.debug('results-->> '+results);
        if(results.businessRiskTriggersIndicator){
            //System.debug('results?.businessRiskTriggersStatement-->> '+results.businessRiskTriggersStatement[0]);
            if(results.businessRiskTriggersStatement !=null){
            if(results?.businessRiskTriggersStatement.size() > 0){
                expBusinessInfo.EXPRN__Verification_Triggers__c = results.businessRiskTriggersStatement[0];
            }
            }
        } 
       
        
        update expBusinessInfo;
        
        
        
    }
 
    
    //Request Wrapper class
    public class reqBody{
         @AuraEnabled 
		public String bin{get;set;}
         @AuraEnabled 
		public String subcode{get;set;}
    }
    
    //Response Wrapper class
    public class ResponseWrapper{
		public Boolean success{get;set;}
		public results results{get;set;}
		public String requestId{get;set;}
        public Integration_Log__c intLog{get;set;}
    }
	public class results{
		public Boolean businessVictimStatementIndicator{get;set;}
		public ofacMatchWarning ofacMatchWarning{get;set;}
		public Boolean businessRiskTriggersIndicator{get;set;}
		public Boolean activeBusinessIndicator{get;set;}
		public List<String> businessRiskTriggersStatement{get;set;}
		public String matchingBusinessAddress{get;set;}
		public Boolean nameAddressVerificationIndicator{get;set;}
		public String bin{get;set;}
	}
	public class ofacMatchWarning{
		public String detailStatement{get;set;}
		public Integer code{get;set;}
		public String definition{get;set;}
	}



}