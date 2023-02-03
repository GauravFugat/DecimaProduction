public class CallUbEnrollmentAPIBatch implements Database.batchable<Wrapper_UbEnrollment.EnrollmentData>, Database.AllowsCallouts, Database.Stateful {
    
    
    List<Wrapper_UbEnrollment.EnrollmentData> enrollmentRecordList=new List<Wrapper_UbEnrollment.EnrollmentData> ();
    String endpoint;
    Wrapper_UbEnrollmentResponse responseObj;
    
      List<Utility_Account_Enrollment__c> sentUAEList = new List<Utility_Account_Enrollment__c>();
        List<String> sentEnrollmentList = new List<String>();
        List<String> requestBodyList = new List<String>();
        List<String> respBodyList = new List<String>();
        List<Integer> statusCodeList = new List<Integer>();
        List<String> respStatusList = new List<String>();
        List<String> respErrorCodeList = new List<String>();
        List<String> respErrorMessageList = new List<String>();
        List<String> respAdditionalInfoList = new List<String>();
        List<String> emailXMLlist = new List<String>();
        List<String> resultAPIlist = new List<String>();
        
    
    public CallUbEnrollmentAPIBatch(  List<Wrapper_UbEnrollment.EnrollmentData>  apienrollmentRecordList, String endpoint) {
        this.enrollmentRecordList = apienrollmentRecordList;
        this.endpoint = endpoint;
    }
    
    public Iterable<Wrapper_UbEnrollment.EnrollmentData>  start(Database.BatchableContext BC) {
        return enrollmentRecordList;
    }
    
    public void execute(Database.BatchableContext bc, List<Wrapper_UbEnrollment.EnrollmentData> enrollmentRecordList){
      
        
        String accessToken = Label.UBEnrollemt_User_Token;
        String usrName = Label.UBEnrollemt_User_Name;
        String pass = Label.UBEnrollemt_Password;
        String method = 'POST';
        string apimkey = Label.UBEnrollment_APIKey;
          if(enrollmentRecordList.size()>0 && !enrollmentRecordList.isEmpty()){
                                   
            System.debug('EnrollmentRecordList size: ' + enrollmentRecordList.size());
            System.debug('UbEnrollment CreateEnrollment API calling');
                         
            Boolean anyFailed = false;
                 
        for (Wrapper_UbEnrollment.EnrollmentData enrollmentRecord : enrollmentRecordList) {
            HttpRequest req = new HttpRequest();
            HTTPResponse res; 
            req.setEndpoint(endpoint);
            req.setMethod(method);
            req.setHeader('Content-Type', 'text/xml;  charset=utf-8');
            req.setHeader('SOAPAction', 'http://tempuri.org/IUbEnrollmentRequest/CreateEnrollment');
            req.setHeader('Ocp-Apim-Subscription-Key', apimkey);
            String xml ='<?xml version="1.0" encoding="utf-8"?>';
            xml+= '<soapenv:Envelope xmlns:arr="http://schemas.microsoft.com/2003/10/Serialization/Arrays" xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:tem="http://tempuri.org/" xmlns:ubs="http://schemas.datacontract.org/2004/07/UbSystemServices.EnrollmentLibrary">';
            xml+= '<soapenv:Header>';
            xml+= '<wsse:Security soapenv:mustUnderstand="1" xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd" xmlns:wsu="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd">';
            xml+= accessToken;
            xml+= '<wsse:Username>'+usrName+'</wsse:Username>';
            xml+= '<wsse:Password Type="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-username-token-profile-1.0#PasswordText">'+pass+'</wsse:Password>';
            xml+='</wsse:UsernameToken>';
            xml+= '</wsse:Security>';
            xml+= '</soapenv:Header>';
            xml+= '<soapenv:Body>';
            xml+= '<tem:CreateEnrollment>';
            xml+= '<tem:EnrollmentRecord>';
            
            if (enrollmentRecord.AccountClassName != '') {
                xml+= '<ubs:AccountClassName>' + enrollmentRecord.AccountClassName + '</ubs:AccountClassName>';
            }
            if (enrollmentRecord.AccountClassName != '') {
                xml+= '<ubs:AccountType>' + enrollmentRecord.AccountType + '</ubs:AccountType>';
            }
            if (enrollmentRecord.AutoSubmitFlag != null) {
                xml+= '<ubs:AutoSubmitFlag>' + enrollmentRecord.AutoSubmitFlag + '</ubs:AutoSubmitFlag>';
            }
            if(enrollmentRecord.BillingAddress1 != null) {
                xml+= '<ubs:BillingAddress1>'+enrollmentRecord.BillingAddress1+'</ubs:BillingAddress1>';
            }
            if(enrollmentRecord.BillingCity != null) {
                xml+= '<ubs:BillingCity>'+enrollmentRecord.BillingCity+'</ubs:BillingCity>';
            }
            if(enrollmentRecord.BillingEmail != null) {
                xml+= '<ubs:BillingEmail>'+enrollmentRecord.BillingEmail+'</ubs:BillingEmail>';
            }
            if(enrollmentRecord.BillingMethod != '') {
                xml+= '<ubs:BillingMethod>'+enrollmentRecord.BillingMethod+'</ubs:BillingMethod>';
            }
            if(enrollmentRecord.BillingState != null) {
                xml+= '<ubs:BillingState>'+enrollmentRecord.BillingState+'</ubs:BillingState>';
            }
            if( enrollmentRecord.BillingZip != null) {
                xml+= '<ubs:BillingZip>'+ enrollmentRecord.BillingZip+'</ubs:BillingZip>';
            }
            if(enrollmentRecord.BusinessPhone != null) {
                xml+= '<ubs:BusinessPhone>'+enrollmentRecord.BusinessPhone+'</ubs:BusinessPhone>';
            }
            if(enrollmentRecord.Commodity != '') {
                xml+= '<ubs:Commodity>'+enrollmentRecord.Commodity+'</ubs:Commodity>';
            }
            if( enrollmentRecord.ContactName != null) {
                xml+= '<ubs:ContactName>'+ enrollmentRecord.ContactName+'</ubs:ContactName>';
            }
            if(enrollmentRecord.ContractStart != null) {
                System.debug('ContractStart: ' + enrollmentRecord.ContractStart);
                xml+= '<ubs:ContractStart>'+ enrollmentRecord.ContractStart.addHours(5).format('yyyy-MM-dd')+'</ubs:ContractStart>';
                System.debug('ContractStart after trim: ' + enrollmentRecord.ContractStart.addHours(5).format('yyyy-MM-dd'));
            }           
            if( enrollmentRecord.CusInfo1 != null) {
                xml+= '<ubs:CusInfo1>'+ enrollmentRecord.CusInfo1+'</ubs:CusInfo1>';
            }
            if( enrollmentRecord.CusInfo2 != null) {
                xml+= '<ubs:CusInfo2>'+ enrollmentRecord.CusInfo2+'</ubs:CusInfo2>';
            }
            if( enrollmentRecord.CusInfo3 != null) {
                xml+= '<ubs:CusInfo3>'+ enrollmentRecord.CusInfo3+'</ubs:CusInfo3>';
            }
            if(enrollmentRecord.CustomerName != '') {
                xml+= '<ubs:CustomerName>'+enrollmentRecord.CustomerName+'</ubs:CustomerName>';
            }
            if(enrollmentRecord.GlobalTaxSettings != null) {
                xml+= '<ubs:GlobalTaxSettings>'+enrollmentRecord.GlobalTaxSettings +'</ubs:GlobalTaxSettings>';
            }
            if(enrollmentRecord.HistoricalData != null) {
                xml+= '<ubs:HistoricalData>'+enrollmentRecord.HistoricalData +'</ubs:HistoricalData>';
            }
            if(enrollmentRecord.IncludeCityTax != null) {
                xml+= '<ubs:IncludeCityTax>'+enrollmentRecord.IncludeCityTax +'</ubs:IncludeCityTax>';
            }
            if(enrollmentRecord.IncludeCountyTax != null) {
                xml+= '<ubs:IncludeCountyTax>'+enrollmentRecord.IncludeCountyTax +'</ubs:IncludeCountyTax>';
            }
            if(enrollmentRecord.IncludeGRTTax != null) {
                xml+= '<ubs:IncludeGRTTax>'+enrollmentRecord.IncludeGRTTax +'</ubs:IncludeGRTTax>';
            }
            if(enrollmentRecord.IncludeMTATax != null) {
                xml+= '<ubs:IncludeMTATax>'+enrollmentRecord.IncludeMTATax +'</ubs:IncludeMTATax>';
            }
            if(enrollmentRecord.IncludeOtherTax != null) {
                xml+= '<ubs:IncludeOtherTax>'+enrollmentRecord.IncludeOtherTax +'</ubs:IncludeOtherTax>';
            }
            if(enrollmentRecord.IncludeSPDTax != null) {
                xml+= '<ubs:IncludeSPDTax>'+enrollmentRecord.IncludeSPDTax +'</ubs:IncludeSPDTax>';
            }
            if(enrollmentRecord.IncludeStateTax != null) {
                xml+= '<ubs:IncludeStateTax>'+enrollmentRecord.IncludeStateTax +'</ubs:IncludeStateTax>';
            }
            if(enrollmentRecord.LocationName != '' && enrollmentRecord.LocationName != null) {
                xml+= '<ubs:LocationName>'+enrollmentRecord.LocationName +'</ubs:LocationName>';
            }
            if(enrollmentRecord.MarketerAccountNumber == '') {
                xml+= '<ubs:MarketerAccountNumber>'+''+'</ubs:MarketerAccountNumber>';
            }else if (enrollmentRecord.MarketerAccountNumber != ''){
                xml+= '<ubs:MarketerAccountNumber>'+enrollmentRecord.MarketerAccountNumber+'</ubs:MarketerAccountNumber>';
            }
            if(enrollmentRecord.MarketerDunsNumber != '') {
                xml+= '<ubs:MarketerDunsNumber>'+enrollmentRecord.MarketerDunsNumber+'</ubs:MarketerDunsNumber>';
            }
           if(enrollmentRecord.MarketerRateCode1 != '') {
                xml+= '<ubs:MarketerRateCode1>'+enrollmentRecord.MarketerRateCode1+'</ubs:MarketerRateCode1>';
            }
            if( enrollmentRecord.MtrInfo1  != null) {
                xml+= '<ubs:MtrInfo1>'+enrollmentRecord.MtrInfo1 +'</ubs:MtrInfo1>';
            }
            if( enrollmentRecord.MtrInfo2 != null) {
                xml+= '<ubs:MtrInfo2>'+ enrollmentRecord.MtrInfo2+'</ubs:MtrInfo2>';
            }
            if( enrollmentRecord.MtrInfo3 != null) {
                xml+= '<ubs:MtrInfo3>'+ enrollmentRecord.MtrInfo3+'</ubs:MtrInfo3>';
            }
            if(enrollmentRecord.RequestType != '') {
                xml+= '<ubs:RequestType>'+enrollmentRecord.RequestType+'</ubs:RequestType>';
            }
            if(enrollmentRecord.Rx1RateInfo1 != '') {
                xml+= '<ubs:Rx1RateInfo1>'+enrollmentRecord.Rx1RateInfo1+'</ubs:Rx1RateInfo1>';
            }
            if(enrollmentRecord.Rx1RateInfo2 != null) {
                xml+= '<ubs:Rx1RateInfo2>'+enrollmentRecord.Rx1RateInfo2+'</ubs:Rx1RateInfo2>';
            }
            if(enrollmentRecord.Rx1RateInfo3 != '') {
                xml+= '<ubs:Rx1RateInfo3>'+enrollmentRecord.Rx1RateInfo3+'</ubs:Rx1RateInfo3>';
            }
            if(enrollmentRecord.Rx1RateInfo4 != null) {
                xml+= '<ubs:Rx1RateInfo4>'+enrollmentRecord.Rx1RateInfo4+'</ubs:Rx1RateInfo4>';
            }
            if(enrollmentRecord.Rx1RateInfo5 != null) {
                xml+= '<ubs:Rx1RateInfo5>'+enrollmentRecord.Rx1RateInfo5+'</ubs:Rx1RateInfo5>';
            }
            if(enrollmentRecord.Rx2RateInfo1 != '') {
                xml+= '<ubs:Rx2RateInfo1>'+enrollmentRecord.Rx2RateInfo1+'</ubs:Rx2RateInfo1>';
            }
            if(enrollmentRecord.Rx2RateInfo2 != null) {
                xml+= '<ubs:Rx2RateInfo2>'+enrollmentRecord.Rx2RateInfo2+'</ubs:Rx2RateInfo2>';
            }
            if(enrollmentRecord.Rx2RateInfo3 != '') {
                xml+= '<ubs:Rx2RateInfo3>'+enrollmentRecord.Rx2RateInfo3+'</ubs:Rx2RateInfo3>';
            }
            if(enrollmentRecord.Rx2RateInfo4 != null) {
                xml+= '<ubs:Rx2RateInfo4>'+enrollmentRecord.Rx2RateInfo4+'</ubs:Rx2RateInfo4>';
            }
            if(enrollmentRecord.Rx2RateInfo5 != null) {
                xml+= '<ubs:Rx2RateInfo5>'+enrollmentRecord.Rx2RateInfo5+'</ubs:Rx2RateInfo5>';
            }
            if(enrollmentRecord.RxEffective1 != null) {                    
                xml+= '<ubs:RxEffective1>'+enrollmentRecord.RxEffective1.addHours(5).format('yyyy-MM-dd')+'</ubs:RxEffective1>';
            }
            if(enrollmentRecord.RxEffective2 != null) {                    
                xml+= '<ubs:RxEffective2>'+enrollmentRecord.RxEffective2.addHours(5).format('yyyy-MM-dd')+'</ubs:RxEffective2>';
            } 
            if(enrollmentRecord.RxRate1 != null) {
                xml+= '<ubs:RxRate1>'+enrollmentRecord.RxRate1+'</ubs:RxRate1>';
            } 
            if(enrollmentRecord.RxRateClass1 != '') {
                xml+= '<ubs:RxRateClass1>'+enrollmentRecord.RxRateClass1+'</ubs:RxRateClass1>';
            }
            if(enrollmentRecord.RxRateClass2 != '') {
                xml+= '<ubs:RxRateClass2>'+enrollmentRecord.RxRateClass2+'</ubs:RxRateClass2>';
            }
            
            if( enrollmentRecord.RxTerm1 != null) {
                xml+= '<ubs:RxTerm1>'+enrollmentRecord.RxTerm1+'</ubs:RxTerm1>';
            }
            if( enrollmentRecord.RxTerm2 != null) {
            	xml+= '<ubs:RxTerm2>'+enrollmentRecord.RxTerm2+'</ubs:RxTerm2>';
        	}	
            if( enrollmentRecord.SalesCommission != null) {
                xml+= '<ubs:SalesCommission>'+ enrollmentRecord.SalesCommission+'</ubs:SalesCommission>';
            }
            if( enrollmentRecord.SalesCommissionUOM != null) {
                xml+= '<ubs:SalesCommissionUOM>'+ enrollmentRecord.SalesCommissionUOM+'</ubs:SalesCommissionUOM>';
            }
            
            if( enrollmentRecord.SalespersonName != '') {
                xml+= '<ubs:SalespersonName>'+ enrollmentRecord.SalespersonName+'</ubs:SalespersonName>';
            }
            if( enrollmentRecord.SalespersonName2 != '') {
                xml+= '<ubs:SalespersonName2>'+ enrollmentRecord.SalespersonName2+'</ubs:SalespersonName2>';
            }
            if( enrollmentRecord.SvcAddress1 != null) {
                xml+= '<ubs:SvcAddress1>'+enrollmentRecord.SvcAddress1 +'</ubs:SvcAddress1>';
            }
            if( enrollmentRecord.SvcCity != null) {
                xml+= '<ubs:SvcCity>'+enrollmentRecord.SvcCity+'</ubs:SvcCity>';
            }                
            if( enrollmentRecord.SvcGlobalTaxSettings != null) {
                xml+= '<ubs:SvcGlobalTaxSettings>'+enrollmentRecord.SvcGlobalTaxSettings+'</ubs:SvcGlobalTaxSettings>';
            }
            if(enrollmentRecord.SvcIncludeCityTax != null) {
                xml+= '<ubs:SvcIncludeCityTax>'+enrollmentRecord.SvcIncludeCityTax +'</ubs:SvcIncludeCityTax>';
            }
            if(enrollmentRecord.SvcIncludeCountyTax != null) {
                xml+= '<ubs:SvcIncludeCountyTax>'+enrollmentRecord.SvcIncludeCountyTax +'</ubs:SvcIncludeCountyTax>';
            }
            if(enrollmentRecord.SvcIncludeGRTTax != null) {
                xml+= '<ubs:SvcIncludeGRTTax>'+enrollmentRecord.SvcIncludeGRTTax +'</ubs:SvcIncludeGRTTax>';
            }
            if(enrollmentRecord.SvcIncludeMTATax != null) {
                xml+= '<ubs:SvcIncludeMTATax>'+enrollmentRecord.SvcIncludeMTATax +'</ubs:SvcIncludeMTATax>';
            }
            if(enrollmentRecord.SvcIncludeOtherTax != null) {
                xml+= '<ubs:SvcIncludeOtherTax>'+enrollmentRecord.SvcIncludeOtherTax +'</ubs:SvcIncludeOtherTax>';
            }
            if(enrollmentRecord.SvcIncludeSPDTax != null) {
                xml+= '<ubs:SvcIncludeSPDTax>'+enrollmentRecord.SvcIncludeSPDTax +'</ubs:SvcIncludeSPDTax>';
            }
            if(enrollmentRecord.SvcIncludeStateTax != null) {
                xml+= '<ubs:SvcIncludeStateTax>'+enrollmentRecord.SvcIncludeStateTax +'</ubs:SvcIncludeStateTax>';
            }
            if( enrollmentRecord.SvcState != null) {
                xml+= '<ubs:SvcState>'+enrollmentRecord.SvcState+'</ubs:SvcState>';
            }
            if( enrollmentRecord.SvcTaxablePercentage != null) {
                xml+= '<ubs:SvcTaxablePercentage>'+enrollmentRecord.SvcTaxablePercentage+'</ubs:SvcTaxablePercentage>';
            }
            if( enrollmentRecord.SvcZip != null) {
                xml+= '<ubs:SvcZip>'+enrollmentRecord.SvcZip+'</ubs:SvcZip>';
            }
            if( enrollmentRecord.TaxablePercentage != null) {
                xml+= '<ubs:TaxablePercentage>'+enrollmentRecord.TaxablePercentage+'</ubs:TaxablePercentage>';
            }
            if(enrollmentRecord.UtilityAccountNumber != '') {
                xml+= '<ubs:UtilityAccountNumber>'+enrollmentRecord.UtilityAccountNumber+'</ubs:UtilityAccountNumber>';
            }
            if(enrollmentRecord.UtilityDunsNumber != '') {
                xml+= '<ubs:UtilityDunsNumber>'+enrollmentRecord.UtilityDunsNumber+'</ubs:UtilityDunsNumber>';
            }
            if(enrollmentRecord.RecordType != '') {
                xml+= '<ubs:RecordType>'+enrollmentRecord.RecordType+'</ubs:RecordType>';
            }
            
            xml+= '</tem:EnrollmentRecord>';
            xml+= '</tem:CreateEnrollment>';
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
                res = http.send(req);
                String response = res.getBody();
                Integer code = res.getStatusCode();
                String result;
                System.debug('Response Body - ' + response);
                if (res.getStatusCode() == 200 || res.getStatusCode() == 201) {
                    System.debug('UbEnrollment Callout Successed');
                    result = 'Success';
                    
                }
                else
                    result = 'Fail';
                
                xml = xml.replace(usrName, '**REMOVED**').replace(pass, '**REMOVED**').replace(accessToken, '**REMOVED**');
                string emailXML = xml + '\n\n\nResponse XML\n\n' + response;
                
                responseObj = new Wrapper_UbEnrollmentResponse(response,code, result, emailXML, xml);
                
                // Send XML email
                
                
                System.Debug('emailXML: -' + emailXML);
                System.debug('Status Code: ' + code);
                System.debug('API response: ' + response);              
                
            }catch(System.Exception ex)
            {
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
                responseObj = new Wrapper_UbEnrollmentResponse('Error - FAILED TO GET RESPONSE' + '\n\n\nException Message\n\n' + ex.getMessage(),code, result, emailXML, xml);
            }
            System.debug('215 responseObj'+responseObj);
            
            if(Integer.valueof(responseObj.statusCode) == 200 || Integer.valueof(responseObj.statusCode) == 201){
                if (responseObj.Status == 'Failure')
                {
                    enrollmentRecord.uaeRecord.Status__c = 'Enrollment Request Failed';
                    anyFailed = true;
                }
                else
                    enrollmentRecord.uaeRecord.Status__c = 'Enrollment Request Accepted';  
            }
            else{
                enrollmentRecord.uaeRecord.Status__c = 'Enrollment Request Failed';
                anyFailed = true;
            }
            
            System.Debug('emailXML: ' + responseObj.emailXML);
            
            sentUAEList.add(enrollmentRecord.uaeRecord);
            sentEnrollmentList.add(enrollmentRecord.enrollmentId);
            requestBodyList.add(responseObj.requestXML);
            respBodyList.add(responseObj.strBody);
            statusCodeList.add(Integer.valueOf(responseObj.statusCode));
            resultAPIlist.add(responseObj.result);
            emailXMLlist.add(responseObj.emailXML);
            respStatusList.add(responseObj.Status);
            respErrorCodeList.add(responseObj.ErrorCode);
            respErrorMessageList.add(responseObj.ErrorMessage);
            respAdditionalInfoList.add(responseObj.AdditionalInfo);
        }
          }
          }
    public void finish(Database.BatchableContext BC) {
        InsertIntegrationLog intLog = new InsertIntegrationLog(requestBodyList,respBodyList, statusCodeList, sentEnrollmentList, endpoint, 'POST', sentUAEList, respAdditionalInfoList, respStatusList,respErrorCodeList,respErrorMessageList);
        System.enqueueJob(intLog);
        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'admin@decima.one'];             
        Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage>();
        for (Integer i = 0; i < emailXMLlist.size(); i++){
            Messaging.SingleEmailMessage message = SendUBEnrollmentBody.sendUBEnrollmentBody(emailXMLlist[i], resultAPIlist[i], statusCodeList[i], 'Enrollment', owea[0].Id);
            messages.add(message);
        }
        Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
        
    }
    
    
}