public class SendEmailApex {
    public class values{
        @invocableVariable
        public String docId;
        @invocableVariable(required=true)
        public ID recordId;
        @invocableVariable(required=true)
        public String emailTemplateName;
        @invocableVariable(required=true)
        public ID recipientId;
        @invocableVariable
        public Boolean AttachAgreementFromContract;
    }
    
    @invocableMethod(label = 'invokeSendEmail')
    public static void invokeSendEmail(List<values> v){
        List<ID> docIds = new List<ID>();
        if(v[0].docId != NULL){
            if(v[0].docId.contains(','))
                docIds = v[0].docId.split(',');
        }
        if(v[0].AttachAgreementFromContract == False)
            sendEmail(docIds, v[0].emailTemplateName, v[0].recipientId,v[0].recordId );
        else{
            List<Contract> cRecord = [SELECT Id, Opportunity__c, Signed_Agreement__c FROM Contract WHERE Id =: v[0].recordId];
            List<Attachment> signerAgreementAttachment = [Select Name, Body From Attachment Where parentId =: cRecord[0].Signed_Agreement__c ORDER BY CreatedDate Desc LIMIT 1];
            if(!signerAgreementAttachment.isEmpty()){ docIds.add(signerAgreementAttachment[0].Id); }
            sendEmail(docIds, v[0].emailTemplateName, v[0].recipientId, cRecord[0].Opportunity__c );
        }
    }
    public static void sendEmail(List<Id> docIds, String emailTemplateName, Id recipientId, Id recordId){
        //Opportunity oppRecord = [SELECT Id, Broker__r.Primary_Contact__r.FirstName, Broker__r.Primary_Contact__r.Email , Owner.Name, Account.Name FROM Opportunity WHERE Id =: recordId ];
        
        List<Attachment> attachmentRecords = [Select Name, Body From Attachment Where id =: docIds ];
        EmailTemplate ET = [SELECT Id, Name FROM EmailTemplate WHERE DeveloperName =: emailTemplateName LIMIT 1];
        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'customer-services-us@smartestenergy.com'];
         if(ET != NULL){
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message.templateid = ET.Id;
            message.setTargetObjectId(recipientId);
            message.setWhatId(recordId);
            message.setOrgWideEmailAddressId(owea[0].Id);
            system.debug('res owea' + message.getOrgWideEmailAddressId());
            Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {message};
                message.setEntityAttachments(docIds);
            message.setSaveAsActivity(true);
            Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);  
            system.debug('res ' + results);
           //  system.debug('res ' + results[0].isSuccess);
        }
    }
    
    public static void sendEmail(List<Id> docIds, String emailTemplateName, Id recipientId, Id recordId,String ToAddresses, String CCAdresses){
        //Opportunity oppRecord = [SELECT Id, Broker__r.Primary_Contact__r.FirstName, Broker__r.Primary_Contact__r.Email , Owner.Name, Account.Name FROM Opportunity WHERE Id =: recordId ];
        List<String> usrTOEmails = new List<String>();
        List<String> usrCCEmails = new List<String>();
        List<User> usrLst = new List<User>();
        try{
            usrLst = [SELECT Email FROM User WHERE Id IN: ToAddresses.split(',')];
        }catch(Exception e){
            
        }
        if(usrLst.size() > 0){
            for(User us : usrLst){
                usrTOEmails.add(us.Email);
            }
        }
        
        
        for(User us : [SELECT Email FROM User WHERE Id IN: CCAdresses.split(',')]){
            usrCCEmails.add(us.Email);
        }
        
        
        List<Attachment> attachmentRecords = [Select Name, Body From Attachment Where id =: docIds ];
        EmailTemplate ET = [SELECT Id, Name FROM EmailTemplate WHERE DeveloperName =: emailTemplateName LIMIT 1];
         OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'customer-services-us@smartestenergy.com'];
       
        if(ET != NULL){
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message.templateid = ET.Id;
            message.setTargetObjectId(recipientId);
            message.setWhatId(recordId);
             system.debug('res ' + message.getSenderDisplayName());
            if(usrTOEmails.size() > 0){
                message.setToAddresses(usrTOEmails);
            }
              message.setOrgWideEmailAddressId(owea[0].Id);
            system.debug('res owea' + message.getOrgWideEmailAddressId());
            message.setccAddresses(usrCCEmails);
            Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {message};
                message.setEntityAttachments(docIds);
            message.setSaveAsActivity(true);
            if(usrLst.size() > 0){
                message.setTreatTargetObjectAsRecipient(false);
            }
            Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
            system.debug('res ' + results);
        }
    }
}