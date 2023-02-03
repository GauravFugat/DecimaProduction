@RestResource(urlMapping='/processPriceFile/*')
global class PricingSystemIntegration {
    global class JsonWrapStatus{
        public String status{get;set;}
        public String message{get;set;}
    }
    @httpPost
    global static JsonWrapStatus processPriceFile(){
    	JsonWrapStatus js = new JsonWrapStatus();
        RestRequest request=RestContext.request;
        RestResponse response=RestContext.response;
        String PricingRequestName;
        String ContentDocumentID;
        Boolean AlignStartDate;
        //Create integration log
        Integration_Log__c newIntegrationLog = new Integration_Log__c();
        newIntegrationLog.Request_Type__c = 'Inbound';
        newIntegrationLog.Request_Body__c = request.requestBody.toString();
        //String recLink = URL.getSalesforceBaseUrl().toExternalForm()+ 'services/apexrest/processCreditFromHU';
        newIntegrationLog.EndPointURL__c = 'processPriceFile'; //recLink; //'<a href='+recLink+'>'+recLink+'</a>';
        Pricing_Request__c PricingReq;
        try{            
            system.debug('request.requestBody.toString-->'+request.requestBody.toString());
            Map<String , object>  StrReqBody = (Map<String , object>)JSON.deserializeUntyped(request.requestBody.toString());
            for(String key : StrReqBody.keySet()){        
                if(key=='PricingRequest'){
                    PricingRequestName=(String)StrReqBody.get(key); 
                }else if(key=='ContentDocumentID'){
                    ContentDocumentID=(String)StrReqBody.get(key);
                }else if(key=='alignStartDates'){
                    AlignStartDate=(Boolean)StrReqBody.get(key);
                }                
            }
            List<ContentDocumentLink> contentDocs;
            if(ContentDocumentID == NULL){
                js.status = 'Failed';
                js.message = 'The supplied file reference for processing does not exist or is not valid';	
            }else{
                if(PricingRequestName != NULL){
                    PricingReq = [SELECT id, Name from Pricing_Request__c WHERE Name = : PricingRequestName limit 1];		                    
	                newIntegrationLog.Pricing_Request__c = PricingReq.Id;
                    if(PricingReq != NULL){
                        Boolean fileExists;
                        contentDocs =[SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =: PricingReq.id];
                        System.debug('contentDocs--->'+contentDocs);
                        System.debug('ContentDocumentID-->'+ContentDocumentID);
                        for (ContentDocumentLink cdl : contentDocs){
                            if (cdl.ContentDocumentId == ContentDocumentID)
                                fileExists = true;
                        }                    
                        if(fileExists){
                            newIntegrationLog.Status__c = js.status = 'Success';
                            ContentVersion contentVer = [SELECT Id, Title from ContentVersion where ContentDocumentId =: ContentDocumentID]	;
                            String responseFileUpload = file_upload_handler.processData(ContentDocumentID,String.valueOf(PricingReq.id),contentVer.Title,Boolean.valueOf(AlignStartDate));
                            js.message = responseFileUpload;
                            newIntegrationLog.Response_Body__c = 'Process price file operation has been successfully initiated';
                        }else{newIntegrationLog.Status__c = js.status = 'Failed';
                            newIntegrationLog.Response_Body__c = js.message = 'The supplied file reference for processing is not associated to the supplied Pricing Request';	
                        }  
                    }else{newIntegrationLog.Status__c = js.status = 'Failed';
                        newIntegrationLog.Response_Body__c = js.message = 'The supplied Pricing Request reference does not exist or is not valid';	
                    }
                }else{newIntegrationLog.Status__c = js.status = 'Failed';
                	newIntegrationLog.Response_Body__c = js.message = 'PricingRequest is a mandatory field for this operation';
                }
            }
            Insert newIntegrationLog; 
            return js;
        }catch(Exception e){js.status = 'Failed';
            js.message = 'A fatal error has been encountered processing this request - please contact your Salesforce Administrator';
            newIntegrationLog.Pricing_Request__c = PricingReq.Id;
            newIntegrationLog.Response_Body__c = e.getMessage();
            Insert newIntegrationLog;                        
            return js;
        }
    }
}