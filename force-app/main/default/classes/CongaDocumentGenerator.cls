public class CongaDocumentGenerator {
    public class values{
        @invocableVariable(required=true)
        public String congaTemplateId;
        @invocableVariable
        public String congaQuery; 
        @invocableVariable(required=true)
        public String fileName;
        @invocableVariable(required=true)
        public ID recordId;
        @invocableVariable
        public String emailTemplateName;
        @invocableVariable
        public ID recipientId;
        @invocableVariable(required=true)
        public Boolean generateDocumentAndSendEmail;
        @invocableVariable
        public Boolean attachAgreementFromContract;
        @invocableVariable
        public String CC_UserIdList;
        @invocableVariable
        public String To_UserIdList;
    }
    @invocableMethod(label = 'invokeConga')
    public static void invokeCallConga(List<values> v){
        //SU-726
        System.debug('invokeConga');
        if( v[0].emailTemplateName == 'Broker_Deal_Confirmation_HTML'){
            AggregateResult countOfUao = [SELECT COUNT(id) FROM Utility_Account_Opportunity__c WHERE Opportunity__c =: v[0].recordId AND Status__c = 'Priced'];  
            System.debug('Integer.valueOf(countOfUao.getexpr0--' + Integer.valueOf(countOfUao.get('expr0') ));
            if(Integer.valueOf(countOfUao.get('expr0')) > 30){
                v[0].congaTemplateId = v[0].congaTemplateId+','+System.Label.Broker_Confirmation_Template_Id;
            }
        }
        //SU-726(End)
        //////////////////
        System.debug('v[0].congaQuery-->> '+v[0].congaQuery);
        if(v[0].CC_UserIdList != null){
            callConga(v[0].recordId, v[0].congaTemplateId, v[0].congaQuery, v[0].fileName, v[0].emailTemplateName, v[0].recipientId, v[0].generateDocumentAndSendEmail, v[0].attachAgreementFromContract,v[0].To_UserIdList,v[0].CC_UserIdList);
        }else{
            system.debug('v' + v);
            callConga(v[0].recordId, v[0].congaTemplateId, v[0].congaQuery, v[0].fileName, v[0].emailTemplateName, v[0].recipientId, v[0].generateDocumentAndSendEmail, v[0].attachAgreementFromContract);
        }
    }
    @future(callout=true)
    public static void callConga(Id recordId, String templateId, String congaQuery, string fileName, String emailTemplateName, Id recipientId, Boolean generateDocumentAndSendEmail, Boolean attachAgreementFromContract,String ToAddresses, String CCAdresses){
        List<ID> docIds = new List<ID>();
        docIds = callCongaAPI(recordId, templateId, congaQuery, fileName, emailTemplateName, recipientId, generateDocumentAndSendEmail, attachAgreementFromContract);
        if(generateDocumentAndSendEmail){
            if(attachAgreementFromContract == FALSE)
                SendEmailApex.sendEmail(docIds, emailTemplateName, recipientId, recordId,ToAddresses, CCAdresses );
            else{
                List<Contract> cRecord = [SELECT Id, Signed_Agreement__c FROM Contract WHERE Id =: recordId];
                if(cRecord[0].Signed_Agreement__c != NULL){
                    List<Attachment> signerAgreementAttachment = [Select Name, Body From Attachment Where parentId =: cRecord[0].Signed_Agreement__c ORDER BY CreatedDate Desc LIMIT 1];
                    if(!signerAgreementAttachment.isEmpty()){ docIds.add(signerAgreementAttachment[0].Id); }
                    SendEmailApex.sendEmail(docIds, emailTemplateName, recipientId, recordId,ToAddresses, CCAdresses );
                }
            }
        }
    }
    @future(callout=true)
    public static void callConga(Id recordId, String templateId, String congaQuery, string fileName, String emailTemplateName, Id recipientId, Boolean generateDocumentAndSendEmail, Boolean attachAgreementFromContract){
        List<ID> docIds = new List<ID>();
        docIds = callCongaAPI(recordId, templateId, congaQuery, fileName, emailTemplateName, recipientId, generateDocumentAndSendEmail, attachAgreementFromContract);
        if(generateDocumentAndSendEmail){
            if(attachAgreementFromContract == FALSE)
                SendEmailApex.sendEmail(docIds, emailTemplateName, recipientId, recordId );
            else{
                List<Contract> cRecord = [SELECT Id, Signed_Agreement__c FROM Contract WHERE Id =: recordId];
                if(cRecord[0].Signed_Agreement__c != NULL){
                    List<Attachment> signerAgreementAttachment = [Select Name, Body From Attachment Where parentId =: cRecord[0].Signed_Agreement__c ORDER BY CreatedDate Desc LIMIT 1];
                    if(!signerAgreementAttachment.isEmpty()){ docIds.add(signerAgreementAttachment[0].Id); }
                    SendEmailApex.sendEmail(docIds, emailTemplateName, recipientId, recordId );
                }
            }
        }
    } 
    @future(callout=true)
    public static void callCongaMultipleAgreements(Id recordId, String templateId, String congaQuery, string fileName, String emailTemplateName, Id recipientId, Boolean generateDocumentAndSendEmail, Boolean attachAgreementFromContract,Integer term){
       System.debug('emailTemplateName--->>> '+emailTemplateName);
        System.debug('congaQuery-->> '+congaQuery);
        System.debug('templateId-->> '+templateId);
        Opportunity opp = [SELECT Id,Type,Index_Opportunity__c,Index_Contract__c FROM Opportunity WHERE Id =:recordId];
         if(opp.Type == 'Load Following'){
           String enrollQueryId = [SELECT Id, APXTConga4__Name__c FROM APXTConga4__Conga_Merge_Query__c WHERE APXTConga4__Name__c Like'EnrollemtQuery%'].Id;
           String attachATempId = [SELECT Id, APXTConga4__Name__c FROM APXTConga4__Conga_Template__c WHERE APXTConga4__Name__c Like'Attachment A template%'].Id;
            String ContractSignDateQueryId = [SELECT Id, APXTConga4__Name__c FROM APXTConga4__Conga_Merge_Query__c WHERE APXTConga4__Name__c Like'ContractSignDateQuery%'].Id;
            congaQuery = congaQuery + ',' + '[enrollments]'+enrollQueryId+'?pv0='+opp.Index_Opportunity__c + ',' + '[contrs]'+ ContractSignDateQueryId ;//+ '?pv0='+opp.Index_Contract__c ;
             templateId = templateId+','+attachATempId;
             //congaQuery = congaQuery + ',' + '[enrollments]a061700000FOcyRAAT?pv0='+opp.Index_Opportunity__c;
             //templateId = templateId+',a0E17000007OS5AEAW';
         }
        
        String sessId = UserInfo.getSessionId();
        String servUrl = Url.getSalesforceBaseUrl().toExternalForm()+'/services/Soap/u/29.0/'+UserInfo.getOrganizationId();
        congaQuery = congaQuery.replaceAll(' ', '');      
        String ofn = fileName.replaceAll(' ', '%7D%20');
        String url2 = 'https://composer.congamerge.com/composer8/index.html'+
            '?sessionId='+sessId+
            '&serverUrl='+EncodingUtil.urlEncode(servUrl, 'UTF-8')+
            '&id=' + recordId+
            '&QueryId='+ congaQuery+','+'[OppLineItem]'+Label.Conga_Query_Id+'?pv0='+recordId+'~pv1='+term+
            '&TemplateId='+templateId+
            '&OFN=' +EncodingUtil.urlEncode(ofn, 'UTF-8') +
            '&DS7=11'+
            '&DefaultPDF=1&APIMode=1';
        
        System.debug(url2);
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(url2);
        req.setMethod('GET');
        req.setTimeout(120000);
        
        // Send the request, and return a response
        HttpResponse res = http.send(req);
        system.debug('::::'+ res.getStatus() + ' => ' + res.getBody());
        if(!res.getBody().contains('error')){
            Attachment att = [Select Name, Body From Attachment Where id =: res.getBody()];
            att.Name = att.Name.replaceAll('}', '');
            update att;
            ContentVersion contentVersion = new ContentVersion();
            contentVersion.ContentLocation = 'S'; // S = Stored in Salesforce
            contentVersion.PathOnClient = att.Name;
            contentVersion.Title = att.Name;
            contentVersion.VersionData = att.Body;
            insert contentVersion;
            List<ContentDocument> cd = [SELECT Id, LatestPublishedVersionId FROM ContentDocument WHERE LatestPublishedVersionId =:  contentVersion.Id];
            ContentDocumentLink contentDocumentLink = new ContentDocumentLink();
            contentDocumentLink.ContentDocumentId = cd[0].Id;
            contentDocumentLink.LinkedEntityId = recordId;
            contentDocumentLink.ShareType = 'I'; // Inferred permission
            contentDocumentLink.Visibility = 'AllUsers';
            Insert contentDocumentLink;
            List<ID> docIds = new List<ID>();
            docIds.add(att.Id);
            if(generateDocumentAndSendEmail){
                if(attachAgreementFromContract == FALSE)
                    SendEmailApex.sendEmail(docIds, emailTemplateName, recipientId, recordId );
                else{
                    List<Contract> cRecord = [SELECT Id, Signed_Agreement__c FROM Contract WHERE Id =: recordId];
                    if(cRecord[0].Signed_Agreement__c != NULL){
                        List<Attachment> signerAgreementAttachment = [Select Name, Body From Attachment Where parentId =: cRecord[0].Signed_Agreement__c ORDER BY CreatedDate Desc LIMIT 1];
                        if(!signerAgreementAttachment.isEmpty()){ docIds.add(signerAgreementAttachment[0].Id); }
                        SendEmailApex.sendEmail(docIds, emailTemplateName, recipientId, recordId );
                    }
                }
            }
        }
    }
    
    public static List<Id> callCongaAPI(Id recordId, String templateId, String congaQuery, string fileName, String emailTemplateName, Id recipientId, Boolean generateDocumentAndSendEmail, Boolean attachAgreementFromContract){
        List<ID> docIds = new List<ID>();
        String sessId = UserInfo.getSessionId();
        String servUrl = Url.getSalesforceBaseUrl().toExternalForm()+'/services/Soap/u/29.0/'+UserInfo.getOrganizationId();
        congaQuery = congaQuery.replaceAll(' ', '');      
        String ofn = fileName.replaceAll(' ', '%7D%20');
        String url2 = 'https://composer.congamerge.com/composer8/index.html'+
            '?sessionId='+sessId+
            '&serverUrl='+EncodingUtil.urlEncode(servUrl, 'UTF-8')+
            '&id=' + recordId+
            '&QueryId='+ congaQuery+
            '&TemplateId='+templateId+
            '&OFN=' +EncodingUtil.urlEncode(ofn, 'UTF-8') +
            '&DS7=11'+
            '&DefaultPDF=1&APIMode=1';
        
        System.debug('url2-->> '+url2);
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(url2);
        req.setMethod('GET');
        req.setTimeout(120000);
        
        // Send the request, and return a response
        HttpResponse res = http.send(req);
        system.debug('::::'+ res.getStatus() + ' => ' + res.getBody());
        if(!res.getBody().contains('error')){
            Attachment att = [Select Name, Body From Attachment Where id =: res.getBody()];
            att.Name = att.Name.replaceAll('}', '');
            update att;
            ContentVersion contentVersion = new ContentVersion();
            contentVersion.ContentLocation = 'S'; // S = Stored in Salesforce
            contentVersion.PathOnClient = att.Name;
            contentVersion.Title = att.Name;
            contentVersion.VersionData = att.Body;
            insert contentVersion;
            List<ContentDocument> cd = [SELECT Id, LatestPublishedVersionId FROM ContentDocument WHERE LatestPublishedVersionId =:  contentVersion.Id];
            ContentDocumentLink contentDocumentLink = new ContentDocumentLink();
            contentDocumentLink.ContentDocumentId = cd[0].Id;
            contentDocumentLink.LinkedEntityId = recordId;
            contentDocumentLink.ShareType = 'I'; // Inferred permission
            contentDocumentLink.Visibility = 'AllUsers';
            Insert contentDocumentLink;            
            docIds.add(att.Id);
        }
        return docIds;
    }
}