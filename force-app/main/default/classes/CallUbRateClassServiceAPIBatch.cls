public class CallUbRateClassServiceAPIBatch implements Database.batchable<UB_RateClassService.RateClassIdentifier>, Database.AllowsCallouts, Database.Stateful {
    List<UB_RateClassService.RateClassIdentifier> RateClassIdentifierList = new List<UB_RateClassService.RateClassIdentifier>();
    List<UB_RateClassService.RateClassSchedule> RateClassScheduleList = new List<UB_RateClassService.RateClassSchedule>();
    String endpoint;
    
    Wrapper_UbEnrollmentResponse renewalResponse ;     
    Wrapper_UbEnrollmentResponse renewalResponse1;
    
    List<Utility_Account_Enrollment__c> sentUAEList = new List<Utility_Account_Enrollment__c>();
    List<String> sentRenewalList = new List<String>();
    List<String> requestBodyList = new List<String>();
    List<String> respBodyList = new List<String>();
    List<Integer> statusCodeList = new List<Integer>();
    List<String> respStatusList = new List<String>();
    List<String> respErrorCodeList = new List<String>();
    List<String> respErrorMessageList = new List<String>();
    List<String> respAdditionalInfoList = new List<String>();
    List<String> emailXMLlist = new List<String>();
    List<String> emailXMLlist1 = new List<String>();
    List<String> resultAPIlist = new List<String>();
    List<String> resultAPIlist1 = new List<String>();
    String response2;
    Integer code2;
    String result2;
    String emailXML2;
    
    public CallUbRateClassServiceAPIBatch(List<UB_RateClassService.RateClassIdentifier> apiRateClassIdentifierList,List<UB_RateClassService.RateClassSchedule> apiRateClassScheduleList,String endpoint){
        this.RateClassIdentifierList = apiRateClassIdentifierList;
        this.RateClassScheduleList = apiRateClassScheduleList;
        this.endpoint = endpoint;
    }
    
    public Iterable<UB_RateClassService.RateClassIdentifier> start(Database.BatchableContext BC) {
        return RateClassIdentifierList;
    }
    public void execute(Database.BatchableContext bc, List<UB_RateClassService.RateClassIdentifier> RateClassIdentifierList){
        String accessToken = Label.UBEnrollemt_User_Token;
        String usrName = Label.UBEnrollemt_User_Name;
        String pass = Label.UBEnrollemt_Password;
        String method = 'POST';
        string apimkey = Label.UBEnrollment_APIKey;
        if(RateClassIdentifierList.size()>0 && !RateClassIdentifierList.isEmpty()){
            
            System.debug('RateClassIdentifierList size: ' + RateClassIdentifierList.size());
            System.debug('UbRenewal AddRateScheduleName API calling');
            List<Wrapper_UbEnrollmentResponse> renewalResponseList = new List<Wrapper_UbEnrollmentResponse>();
            
            
            Boolean anyFailed = false;
            system.debug('rrr-->');
            
            // String emailBody;
            for (Integer i=0; i < RateClassIdentifierList.size(); i++) {
                
                System.Debug('RateClassIdentifier->'+RateClassIdentifierList[i]);
                System.Debug('RateClassScheduleList->'+RateClassScheduleList[i]);
                //Call API 
                for ( UB_RateClassService.RateClassIdentifier  rateClassIdentifier: RateClassIdentifierList)  {
                    
                    UB_RateClassService.RateClassSchedule rateClassSchedule = RateClassScheduleList[i];
                    HttpRequest req = new HttpRequest();
                    HTTPResponse res; 
                    req.setEndpoint(endpoint);
                    req.setMethod(method);
                    req.setHeader('Content-Type', 'text/xml;  charset=utf-8');
                    req.setHeader('SOAPAction', 'http://tempuri.org/IRateClassService/AddRateClassSchedule');
                    req.setHeader('Ocp-Apim-Subscription-Key', apimkey);
                    String xml ='<?xml version="1.0" encoding="utf-8"?>';
                    xml+= '<soapenv:Envelope xmlns:arr="http://schemas.microsoft.com/2003/10/Serialization/Arrays" xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:tem="http://tempuri.org/" xmlns:ubs="http://schemas.datacontract.org/2004/07/UbSystemServices.RateClassLibrary">';
                    xml+= '<soapenv:Header>';
                    xml+= '<wsse:Security soapenv:mustUnderstand="1" xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd" xmlns:wsu="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd">';
                    xml+= accessToken;
                    xml+= '<wsse:Username>'+usrName+'</wsse:Username>';
                    xml+= '<wsse:Password Type="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-username-token-profile-1.0#PasswordText">'+pass+'</wsse:Password>';
                    xml+='</wsse:UsernameToken>';
                    xml+= '</wsse:Security>';
                    xml+= '</soapenv:Header>';
                    xml+= '<soapenv:Body>';
                    xml+= '<tem:AddRateClassSchedule>';
                    xml+= '<tem:RateClassIdentifier>';
                    
                    if(rateClassIdentifier.Commodity != '') {
                        xml+= '<ubs:Commodity>'+rateClassIdentifier.Commodity+'</ubs:Commodity>';
                    }
                    
                    if (rateClassIdentifier.MarketerAccountNumber != ''){
                        xml+= '<ubs:MarketerAccountNumber>'+rateClassIdentifier.MarketerAccountNumber+'</ubs:MarketerAccountNumber>';
                    }
                    
                    if(rateClassIdentifier.UtilityAccountNumber != '') {
                        xml+= '<ubs:UtilityAccountNumber>'+rateClassIdentifier.UtilityAccountNumber+'</ubs:UtilityAccountNumber>';
                    }
                    
                    xml+= '</tem:RateClassIdentifier>';
                    xml+= '<tem:RateClassSchedule>';
                    
                    if(rateClassSchedule.Adder1 != null) {
                        xml+= '<ubs:Adder1>'+rateClassSchedule.Adder1+'</ubs:Adder1>';
                    }
                    if(rateClassSchedule.Category != '') {
                        xml+= '<ubs:Category>'+rateClassSchedule.Category+'</ubs:Category>';
                    }
                    if(rateClassSchedule.ContractStartDate != null) {
                        xml+= '<ubs:ContractStartDate>'+rateClassSchedule.ContractStartDate.addHours(5).format('yyyy-MM-dd')+'</ubs:ContractStartDate>';
                    }
                    if(rateClassSchedule.ContractTerm != null) {
                        xml+= '<ubs:ContractTerm>'+rateClassSchedule.ContractTerm+'</ubs:ContractTerm>';
                    }
                    if(rateClassSchedule.ContractTermUOM != '') {
                        xml+= '<ubs:ContractTermUOM>'+rateClassSchedule.ContractTermUOM+'</ubs:ContractTermUOM>';
                    } 
                    if(rateClassSchedule.Info1 != '') {
                        xml+= '<ubs:Info1>'+rateClassSchedule.Info1+'</ubs:Info1>';
                    } 
                    if(rateClassSchedule.Info2 != '') {
                        xml+= '<ubs:Info2>'+rateClassSchedule.Info2+'</ubs:Info2>';
                    }
                    if(rateClassSchedule.Info3 != '') {
                        xml+= '<ubs:Info3>'+rateClassSchedule.Info3+'</ubs:Info3>';
                    }
                    if(rateClassSchedule.Info4 != '') {
                        xml+= '<ubs:Info4>'+rateClassSchedule.Info4+'</ubs:Info4>';
                    }
                    if(rateClassSchedule.Info5 != '') {
                        xml+= '<ubs:Info5>'+rateClassSchedule.Info5+'</ubs:Info5>';
                    }
                    System.Debug('XML - LinkedClass-->' + rateClassSchedule.LinkedClass);
                    if(rateClassSchedule.LinkedClass != null && rateClassSchedule.LinkedClass != '') {
                        xml+= '<ubs:LinkedClass>'+rateClassSchedule.LinkedClass+'</ubs:LinkedClass>';
                    }
                    System.Debug('XML-->' + xml);
                    if(rateClassSchedule.Rate != null) {
                        xml+= '<ubs:Rate>'+rateClassSchedule.Rate+'</ubs:Rate>';
                    }
                    if(rateClassSchedule.RateEffectiveDate != null) {
                        xml+= '<ubs:RateEffectiveDate>'+rateClassSchedule.RateEffectiveDate.addHours(5).format('yyyy-MM-dd')+'</ubs:RateEffectiveDate>';
                    }
                    if(rateClassSchedule.RateType != '') {
                        xml+= '<ubs:RateType>'+rateClassSchedule.RateType+'</ubs:RateType>';
                    }
                    xml+= '</tem:RateClassSchedule>';
                    xml+= '</tem:AddRateClassSchedule>';
                    xml+= '</soapenv:Body>';
                    xml+= '</soapenv:Envelope>';
                    xml = xml.replace('&', '&amp;');
                    System.debug('XML Body '+ xml);
                    
                    req.setBody(xml);
                    Blob headerValue = Blob.valueOf(usrName + ':' + pass);
                    String authorizationHeader = 'Basic ' +
                        EncodingUtil.base64Encode(headerValue);
                    req.setHeader('Authorization', authorizationHeader);  
                    // Create a new http object to send the request object
                    // A response object is generated as a result of the request  
                    Http http = new Http();
                    req.setTimeout(100000);
                    try {
                        String response;
                        Integer code;
                        if (!Test.isRunningTest()){
                            res = http.send(req);
                            response = res.getBody();
                            code = res.getStatusCode();
                        }else{
                            response = '<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/" xmlns:u="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd"><s:Header><o:Security s:mustUnderstand="1" xmlns:o="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd"><u:Timestamp u:Id="_0"><u:Created>2022-03-03T14:39:19.022Z</u:Created><u:Expires>2022-03-03T14:44:19.022Z</u:Expires></u:Timestamp></o:Security></s:Header><s:Body><AddRateClassScheduleResponse xmlns="http://tempuri.org/"><AddRateClassScheduleResult xmlns:a="http://schemas.datacontract.org/2004/07/UbSystemServices.RateClassLibrary" xmlns:i="http://www.w3.org/2001/XMLSchema-instance"><a:AdditionalInfo/><a:Data><a:ItemOfRateClassKey><a:Errors xmlns:b="http://schemas.microsoft.com/2003/10/Serialization/Arrays"><b:string>Linked Class is missing or invalid.</b:string></a:Errors><a:Item><a:RateClassCode i:nil="true"/><a:RateEffectiveDate i:nil="true"/></a:Item><a:Warnings xmlns:b="http://schemas.microsoft.com/2003/10/Serialization/Arrays"><b:string>The Contract Expiration Date was missing, and was calculated as \'03/13/2024\'.</b:string></a:Warnings></a:ItemOfRateClassKey></a:Data><a:ErrorCode>BusinessLogicError</a:ErrorCode><a:ErrorMessage>1 Rate Class Schedule(s) were not processed due to errors. Please visit inner Errors/Warnings property for details.</a:ErrorMessage><a:Status>Warning</a:Status></AddRateClassScheduleResult></AddRateClassScheduleResponse></s:Body></s:Envelope>';
                            code = 200;
                        }
                        
                        String result;
                        String xml2 ='<?xml version="1.0" encoding="utf-8"?>';
                        Boolean isSuccess = false;
                        
                        System.debug('Response Body - ' + response);
                        if (code == 200 || code == 201) {
                            System.debug('UbEnrollment Callout Successed');
                            result = 'Success';
                            isSuccess = true;
                            
                        }//if
                        else
                            result = 'Fail';
                        
                        xml = xml.replace(usrName, '**REMOVED**').replace(pass, '**REMOVED**').replace(accessToken, '**REMOVED**');
                        string emailXML = xml + '\n\n\nResponse XML\n\n' + response;
                        
                        renewalResponse = new Wrapper_UbEnrollmentResponse(response,code, result, emailXML, xml);
                        
                        // Send XML email
                        
                        System.Debug('emailXML: -' + emailXML);
                        System.debug('Status Code: ' + code);
                        System.debug('API response: ' + response);   
                        
                        if (isSuccess = true && renewalResponse.Status != 'Failure'){
                            
                            //2nd API Call for RollOver Rate Information
                            
                            xml2+= '<soapenv:Envelope xmlns:arr="http://schemas.microsoft.com/2003/10/Serialization/Arrays" xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:tem="http://tempuri.org/" xmlns:ubs="http://schemas.datacontract.org/2004/07/UbSystemServices.RateClassLibrary">';
                            xml2+= '<soapenv:Header>';
                            xml2+= '<wsse:Security soapenv:mustUnderstand="1" xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd" xmlns:wsu="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd">';
                            xml2+= accessToken;
                            xml2+= '<wsse:Username>'+usrName+'</wsse:Username>';
                            xml2+= '<wsse:Password Type="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-username-token-profile-1.0#PasswordText">'+pass+'</wsse:Password>';
                            xml2+='</wsse:UsernameToken>';
                            xml2+= '</wsse:Security>';
                            xml2+= '</soapenv:Header>';
                            xml2+= '<soapenv:Body>';
                            xml2+= '<tem:AddRateClassSchedule>';
                            xml2+= '<tem:RateClassIdentifier>';
                            
                            if (rateClassIdentifier.MarketerAccountNumber != ''){
                                xml2+= '<ubs:MarketerAccountNumber>'+rateClassIdentifier.MarketerAccountNumber+'</ubs:MarketerAccountNumber>';
                            }
                            
                            if(rateClassIdentifier.UtilityAccountNumber != '') {
                                xml2+= '<ubs:UtilityAccountNumber>'+rateClassIdentifier.UtilityAccountNumber+'</ubs:UtilityAccountNumber>';
                            } 
                            if(rateClassIdentifier.Commodity != '') {
                                xml2+= '<ubs:Commodity>'+rateClassIdentifier.Commodity+'</ubs:Commodity>';
                            }
                            
                            xml2+= '</tem:RateClassIdentifier>';   
                            xml2+= '<tem:RateClassSchedule>';
                            xml2+= '<ubs:Category>Undefined</ubs:Category>';
                            
                            if(rateClassSchedule.ContractStartDate1 != null) {
                                xml2+= '<ubs:ContractStartDate>'+rateClassSchedule.ContractStartDate1.format('yyyy-MM-dd')+'</ubs:ContractStartDate>';
                            }
                            if(rateClassSchedule.ContractTerm1 != null) {
                                xml2+= '<ubs:ContractTerm>'+rateClassSchedule.ContractTerm1+'</ubs:ContractTerm>';
                            }                            
                            if(rateClassSchedule.ContractTermUOM != '') {
                                xml2+= '<ubs:ContractTermUOM>'+rateClassSchedule.ContractTermUOM+'</ubs:ContractTermUOM>';
                            }
                            if(rateClassSchedule.Info2 != '') {
                                xml2+= '<ubs:Info2>'+rateClassSchedule.Info2+'</ubs:Info2>';
                            }
                            if(rateClassSchedule.Info3 != '') {
                                xml2+= '<ubs:Info3>'+rateClassSchedule.Info3+'</ubs:Info3>';
                            }
                            if(rateClassSchedule.Info4 != '') {
                                xml2+= '<ubs:Info4>'+rateClassSchedule.Info4+'</ubs:Info4>';
                            }
                            if(rateClassSchedule.Info5_1 != '') {
                                xml2+= '<ubs:Info5>'+rateClassSchedule.Info5_1+'</ubs:Info5>';
                            }
                            if(rateClassSchedule.LinkedClass1 != null && rateClassSchedule.LinkedClass1 != '') {
                                xml2+= '<ubs:LinkedClass>'+rateClassSchedule.LinkedClass1+'</ubs:LinkedClass>';
                            }
                            if(rateClassSchedule.RateEffectiveDate1 != null) {
                                xml2+= '<ubs:RateEffectiveDate>'+rateClassSchedule.RateEffectiveDate1.format('yyyy-MM-dd')+'</ubs:RateEffectiveDate>';
                            }
                            xml2+= '<ubs:RateType>Linked</ubs:RateType>';
                            
                            xml2+= '</tem:RateClassSchedule>';
                            xml2+= '</tem:AddRateClassSchedule>';
                            xml2+= '</soapenv:Body>';
                            xml2+= '</soapenv:Envelope>';
                            xml2 = xml2.replace('&', '&amp;');
                            
                            HttpRequest req2 = new HttpRequest();
                            HTTPResponse res2; 
                            req2.setEndpoint(endpoint);
                            req2.setMethod(method);
                            req2.setHeader('Content-Type', 'text/xml;  charset=utf-8');
                            req2.setHeader('SOAPAction', 'http://tempuri.org/IRateClassService/AddRateClassSchedule');
                            req2.setHeader('Ocp-Apim-Subscription-Key', apimkey);
                            System.debug('XML Body2 '+ xml2);
                            req2.setBody(xml2);
                            req2.setHeader('Authorization', authorizationHeader);  
                            Http http2 = new Http();
                            req2.setTimeout(100000);
                            
                            try {
                                
                                if (!Test.isRunningTest()){
                                    res2 = http.send(req2);
                                    response2 = res2.getBody();
                                    code2 = res2.getStatusCode();
                                }else{
                                    response = '<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/" xmlns:u="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd"><s:Header><o:Security s:mustUnderstand="1" xmlns:o="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd"><u:Timestamp u:Id="_0"><u:Created>2022-03-03T14:39:19.022Z</u:Created><u:Expires>2022-03-03T14:44:19.022Z</u:Expires></u:Timestamp></o:Security></s:Header><s:Body><AddRateClassScheduleResponse xmlns="http://tempuri.org/"><AddRateClassScheduleResult xmlns:a="http://schemas.datacontract.org/2004/07/UbSystemServices.RateClassLibrary" xmlns:i="http://www.w3.org/2001/XMLSchema-instance"><a:AdditionalInfo/><a:Data><a:ItemOfRateClassKey><a:Errors xmlns:b="http://schemas.microsoft.com/2003/10/Serialization/Arrays"><b:string>Linked Class is missing or invalid.</b:string></a:Errors><a:Item><a:RateClassCode i:nil="true"/><a:RateEffectiveDate i:nil="true"/></a:Item><a:Warnings xmlns:b="http://schemas.microsoft.com/2003/10/Serialization/Arrays"><b:string>The Contract Expiration Date was missing, and was calculated as \'03/13/2024\'.</b:string></a:Warnings></a:ItemOfRateClassKey></a:Data><a:ErrorCode>BusinessLogicError</a:ErrorCode><a:ErrorMessage>1 Rate Class Schedule(s) were not processed due to errors. Please visit inner Errors/Warnings property for details.</a:ErrorMessage><a:Status>Warning</a:Status></AddRateClassScheduleResult></AddRateClassScheduleResponse></s:Body></s:Envelope>';
                                    code2 = 200;
                                }
                        
                                //String result2;
                                System.debug('Response Body2- ' + response2);
                                System.debug('Response code2  - ' + code2);
                                if (code2 == 200 || code2 == 201) {
                                    System.debug('UbEnrollment Callout Successed');
                                    result2 = 'Success';
                                    
                                    xml2 = xml2.replace(usrName, '**REMOVED**').replace(pass, '**REMOVED**').replace(accessToken, '**REMOVED**');
                                    emailXML2 = xml2 + '\n\n\nResponse XML\n\n' + response2;
                                    
                                    renewalResponse1 = new Wrapper_UbEnrollmentResponse(response2,code2, result2, emailXML2, xml2);
                                    
                                    // Send XML email
                                    system.debug('result2'+result2);
                                    System.Debug('emailXML2: -' + emailXML2);
                                    System.debug('Status Code2: ' + code2);
                                    System.debug('API response2: ' + response2);
                                    
                                    
                                }
                            }catch(System.Exception ex) {
                                System.debug('Exception in UbEnrollment Callout : ' + ex.getMessage());
                                System.debug('Exception in UbEnrollment Callout Line : ' + ex.getLineNumber());
                                renewalResponse1 = new Wrapper_UbEnrollmentResponse('Error - FAILED TO GET RESPONSE' + '\n\n\nException Message\n\n' + ex.getMessage(),code2, result2, emailXML2, xml2);
                                
                            }
                            //check response code is success or fail and according to the code update the value of status field of integration log
                            
                            
                            if(Integer.valueof(renewalResponse1.statusCode) == 200 || Integer.valueof(renewalResponse1.statusCode) == 201){
                                if (renewalResponse1.Status == 'Failure')
                                {
                                    RateClassIdentifierList[i].uaeRecord.Status__c = 'Enrollment Request Failed';
                                    anyFailed = true;
                                }
                                else
                                    RateClassIdentifierList[i].uaeRecord.Status__c = 'Enrollment Request Accepted'; 
                                
                            }
                            else{
                                RateClassIdentifierList[i].uaeRecord.Status__c = 'Enrollment Request Failed';
                                anyFailed = true;
                                
                            }
                            
                            sentUAEList.add(RateClassIdentifierList[i].uaeRecord);
                    		sentRenewalList.add(RateClassIdentifierList[i].enrollmentId);                            
                            requestBodyList.add(renewalResponse1.requestXML);
                            respBodyList.add(renewalResponse1.strBody);
                            statusCodeList.add(Integer.valueOf(renewalResponse1.statusCode));
                            resultAPIlist.add(renewalResponse1.result2);
                            emailXMLlist.add(renewalResponse1.emailXML2);
                            respStatusList.add(renewalResponse1.Status);
                            respErrorCodeList.add(renewalResponse1.ErrorCode);
                            respErrorMessageList.add(renewalResponse1.ErrorMessage);
                            respAdditionalInfoList.add(renewalResponse1.AdditionalInfo);
                            system.debug(' emailXMLlist.size()-->'+ emailXMLlist.size());
                            //InsertIntegrationLog intLog1 = new InsertIntegrationLog(requestBodyList,respBodyList, statusCodeList, sentRenewalList, endpoint, 'POST', sentUAEList, respAdditionalInfoList, respStatusList,respErrorCodeList,respErrorMessageList);
                            //System.enqueueJob(intLog1);
                            
                        }
                        
                        
                        
                        
                    }catch(System.Exception ex) {
                        System.debug('Exception in UbEnrollment Callout : ' + ex.getMessage());
                        System.debug('Exception in UbEnrollment Callout Line : ' + ex.getLineNumber());
                        
                        string result;
                        Integer code;
                        if (ex.getMessage() == 'Read timed out'){
                            result = 'Fail - Timeout';
                            code = 408;
                        }
                        else{
                            result = 'Fail - Unknown';
                            code = 0;
                        }
                        xml = xml.replace(usrName, '**REMOVED**').replace(pass, '**REMOVED**').replace(accessToken, '**REMOVED**');
                        string emailXML = xml + '\n\n\nResponse XML\n\n' + 'FAILED TO GET RESPONSE' + '\n\n\nException Message\n\n' + ex.getMessage() ;
                        
                        System.Debug('emailXML: -' + emailXML);
                        renewalResponse = new Wrapper_UbEnrollmentResponse('Error - FAILED TO GET RESPONSE' + '\n\n\nException Message\n\n' + ex.getMessage(),code, result, emailXML, xml);
                    }
                    System.debug('renewal response Obj'+renewalResponse);
                    //                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      
                    System.debug('renewalResponse Body ==>> '+renewalResponse.strBody);
                    System.Debug('uaeId: ' + RateClassIdentifierList[i].uaeId);
                    
                    
                    //check response code is success or fail and according to the code update the value of status field of integration log
                    
                    
                    if(Integer.valueof(renewalResponse.statusCode) == 200 || Integer.valueof(renewalResponse.statusCode) == 201){
                        if (renewalResponse.Status == 'Failure')
                        {
                            RateClassIdentifierList[i].uaeRecord.Status__c = 'Enrollment Request Failed';
                            anyFailed = true;
                        }
                        else
                            RateClassIdentifierList[i].uaeRecord.Status__c = 'Enrollment Request Accepted'; 
                        
                    }
                    else{
                        RateClassIdentifierList[i].uaeRecord.Status__c = 'Enrollment Request Failed';
                        anyFailed = true;
                    }
                    
                    System.Debug('emailXML: ' + renewalResponse.emailXML);
                    
                    sentUAEList.add(RateClassIdentifierList[i].uaeRecord);
                    sentRenewalList.add(RateClassIdentifierList[i].enrollmentId);
                    requestBodyList.add(renewalResponse.requestXML);
                    respBodyList.add(renewalResponse.strBody);
                    statusCodeList.add(Integer.valueOf(renewalResponse.statusCode));
                    resultAPIlist.add(renewalResponse.result);
                    emailXMLlist.add(renewalResponse.emailXML);
                    respStatusList.add(renewalResponse.Status);
                    respErrorCodeList.add(renewalResponse.ErrorCode);
                    respErrorMessageList.add(renewalResponse.ErrorMessage);
                    respAdditionalInfoList.add(renewalResponse.AdditionalInfo);
                    system.debug(' emailXMLlist.size()-->'+ emailXMLlist.size());
                    //update updatedUAE;
                    
                    
                }
            }
            
            
            
        }
        
        
        
        
        
        
    }
    
    public void finish(Database.BatchableContext BC){
        system.debug('rrr-->');
        InsertIntegrationLog intLog = new InsertIntegrationLog(requestBodyList,respBodyList, statusCodeList, sentRenewalList, endpoint, 'POST', sentUAEList, respAdditionalInfoList, respStatusList,respErrorCodeList,respErrorMessageList);
        System.enqueueJob(intLog);
        
        /*InsertIntegrationLog intLog1 = new InsertIntegrationLog(requestBodyList,respBodyList, statusCodeList, sentRenewalList, endpoint, 'POST', sentUAEList, respAdditionalInfoList, respStatusList,respErrorCodeList,respErrorMessageList);
System.enqueueJob(intLog1);*/
        
        
        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'admin@decima.one'];             
        Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage>();
        for (Integer i = 0; i < emailXMLlist.size(); i++){
            Messaging.SingleEmailMessage message = SendUBEnrollmentBody.sendUBEnrollmentBody(emailXMLlist[i], resultAPIlist[i], statusCodeList[i], 'Renewal', owea[0].Id);
            messages.add(message);
        }
        Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
    }
    
    
}