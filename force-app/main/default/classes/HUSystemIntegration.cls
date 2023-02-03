@RestResource(urlMapping='/processCreditFromHU/*')
global class HUSystemIntegration {
    global class JsonWrapStatus{
        public String status{get;set;} 
        public String message{get;set;}
    }
    @httpPost
    global static JsonWrapStatus processCreditFromHU(){
        JsonWrapStatus js = new JsonWrapStatus();
        RestRequest request=RestContext.request;
        RestResponse response=RestContext.response;
        String PricingRequestName;
        system.debug('request.requestBody.toString-->'+request.requestBody.toString());
        Map<String , object>  StrReqBody = (Map<String , object>)JSON.deserializeUntyped(request.requestBody.toString());
        System.debug('StrReqBody-->> '+StrReqBody);
        //Create integration log
        Integration_Log__c newIntegrationLog = new Integration_Log__c();
        newIntegrationLog.Request_Type__c = 'Inbound';
        newIntegrationLog.Request_Body__c = request.requestBody.toString();
        //String recLink = URL.getSalesforceBaseUrl().toExternalForm()+ 'services/apexrest/processCreditFromHU';
        newIntegrationLog.EndPointURL__c = 'processCreditFromHU'; //recLink; //'<a href='+recLink+'>'+recLink+'</a>';
        Pricing_Request__c PricingReq;
        try{
            
            for(String key : StrReqBody.keySet()){        
                if(key=='PricingRequest')
                {
                    PricingRequestName=(String)StrReqBody.get(key); 
                }
            }
            //JsonWrapStatus js = new JsonWrapStatus();
            if(PricingRequestName != NULL){
                System.debug('PricingRequestName-->> '+PricingRequestName);
                PricingReq = [SELECT id, Name,Customer__c,Request_Type__c,Customer__r.Name, Status__c from Pricing_Request__c WHERE Name = : PricingRequestName limit 1];
                Credit_Check__c creditDetail = [SELECT Id,Credit_Check_Outcome__c FROM Credit_Check__c Where Customer__c =: PricingReq.Customer__c AND (Status__c = 'Active' OR Status__c = 'New') order by CreatedDate DESC limit 1];
                
                newIntegrationLog.Pricing_Request__c = PricingReq.Id;
                if(PricingReq != NULL){
                    if (PricingReq.Request_Type__c != 'Refresh'){ 
                        System.debug('PricingReqStatus--->'+PricingReq.Status__c);
                        if (PricingReq.Status__c != 'Complete' && PricingReq.Status__c != 'Cancelled'){
                            // Make your callout and follow-on operations here
                            // Call LineJudgement API
                            System.debug('creditDetail-->> '+creditDetail.Credit_Check_Outcome__c);
                            if(creditDetail.Credit_Check_Outcome__c=='Pending'){
                                checkRecursive.scoreResult = ExperianLegalFilingSummariesFetcher.makeCalloutNew(PricingReq.Customer__c);
                            }
                            // Credit log (Process Event) to indicate Process Credit from HU Data
                            createCreditLogs.createCreditProcessLog(PricingReq.Customer__c, 'Process Credit from HU Data', 'Action','This invokes the credit journey as it requires credit','' ,'' ,'Success'); 
                            Boolean creditTypeMatch = creditLimitCalculationsAccount.checkCreditType(PricingReq.Customer__c);
                            System.debug('99999-->> '+creditLimitCalculationsAccount.prevCreditType);
                            // Credit Limit Calculations 
                            creditLimitCalculationsAccount.calculateAccCreditLimits(new List<Id>{PricingReq.Id},true);
                            // Below method has further DML's
                            List<Invoke_LiensJudgementsTrends.wrapper_liensJudgementsTrends> invList = new List<Invoke_LiensJudgementsTrends.wrapper_liensJudgementsTrends>();
                            Invoke_LiensJudgementsTrends.wrapper_liensJudgementsTrends invvar =  new Invoke_LiensJudgementsTrends.wrapper_liensJudgementsTrends();
                            invvar.fromPorcessBuilder = false; 
                            invvar.pricingRequestIds = PricingReq.Id;
                            invvar.creditTypMtch = creditTypeMatch;
                            invvar.prevCredType = creditLimitCalculationsAccount.prevCreditType;
                            invList.add(invvar);
                            Invoke_LiensJudgementsTrends.liensJudgementsTrendsInvoke(invList);
                            
                            newIntegrationLog.Response_Body__c = 'Process Credit From HU Completed';
                            newIntegrationLog.Status__c = 'Success';
                            js.status = 'Success';
                            js.message = 'Process Credit From HU Completed';
                        }else{
                            // Credit log (Process Event) to indicate no action due to PR status being closed
                            System.debug('Cancelled--->'+PricingReq.Status__c);
                            createCreditLogs.createCreditProcessLog(PricingReq.Customer__c, 'Process Credit from HU Data', 'Decision','No action taken due to Pricing Request status ['+PricingReq.Status__c+']','','','False');
                            newIntegrationLog.Status__c = js.status = 'Invalid Operation';
                            newIntegrationLog.Response_Body__c =  js.message = 'No action taken due to Pricing Request status ['+PricingReq.Status__c+']';	
                        }                        
                    }else{
                        // Credit log (Process Event) to indicate no action due to Refresh
                        createCreditLogs.createCreditProcessLog(PricingReq.Customer__c, 'Process Credit from HU Data', 'Decision','No action taken due to price refresh','','','False');
                        newIntegrationLog.Status__c = js.status = 'Invalid Operation';
                        newIntegrationLog.Response_Body__c =  js.message = 'No action taken due to price refresh';	
                    }
                }else{
                    createCreditLogs.createCreditProcessLog(PricingReq.Customer__c, 'Process Credit from HU Data', 'Decision','Invalid Request - The supplied Pricing Request reference does not exist or is not valid','','' ,'False');
                    newIntegrationLog.Status__c = js.status = 'Invalid Request';
                    newIntegrationLog.Response_Body__c =  js.message = 'The supplied Pricing Request reference does not exist or is not valid';	
                }
            }else{
                createCreditLogs.createCreditProcessLog(PricingReq.Customer__c, 'Process Credit from HU Data', 'Decision','Invalid Request - PricingRequest is a mandatory field for this operation','','','False');
                newIntegrationLog.Status__c = js.status = 'Invalid Request';
                newIntegrationLog.Response_Body__c = js.message = 'PricingRequest is a mandatory field for this operation';
            }
            Insert newIntegrationLog; 
            System.debug('PricingReq.Customer__c==>> '+PricingReq.Customer__c);
            //Update the Credit log to populate the Integration log link and recoed to it
            List<Process_Event__c> pe = [SELECT Id,Name,Name__c,Related_Record_Name__c,Related_Record_Id__c,Account__c FROM Process_Event__c WHERE (Account__c =: PricingReq.Customer__c AND Related_Record_Name__c = null AND Related_Record_Id__c = null AND Name__c Like 'Process Credit from HU Data%') ORDER BY CreatedDate DESC];
            pe[0].Related_Record_Id__c = newIntegrationLog.Id;
            pe[0].Related_Record_Name__c = [SELECT Name FROM Integration_Log__c WHERE Id =: newIntegrationLog.Id].Name; //newIntegrationLog.Name;
            update pe[0];
            System.debug('pe==>>'+pe);
            return js;
        }catch(Exception e){
            System.debug('message-->> '+e.getMessage() + '  Line-->>  '+e.getLineNumber());
            js.status = 'Failed';
            js.message = e.getMessage();
            newIntegrationLog.Response_Body__c = e.getMessage() + '   Line-->>  '+e.getLineNumber();
            upsert newIntegrationLog;
            //Update the Credit log to populate the Integration log link and recoed to it
            List<Process_Event__c> pe = [SELECT Id,Name,Name__c,Related_Record_Name__c,Related_Record_Id__c,Account__c FROM Process_Event__c WHERE (Account__c =: PricingReq.Customer__c AND Related_Record_Name__c = null AND Related_Record_Id__c = null AND Name__c Like 'Process Credit from HU Data%') ORDER BY CreatedDate DESC];
            pe[0].Related_Record_Id__c = newIntegrationLog.Id;
            pe[0].Related_Record_Name__c = [SELECT Name FROM Integration_Log__c WHERE Id =: newIntegrationLog.Id].Name; //newIntegrationLog.Name;
            update pe[0];
            return js;
        }
    } 
}