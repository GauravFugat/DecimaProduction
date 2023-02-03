//Test class - salesRenewal_Test

public class Blend_Extend_Email {
    
    
    @invocableMethod(label = 'sendBlendExtendEmail')
    public static void invokeSendEmail(List<Id> recordId){ 
     		System.debug('recordId[0]--'+recordId[0]);
            Contract contr = [SELECT Id, Opportunity__r.Type FROM Contract WHERE Id =: recordId[0]];
            Contact con = [SELECT Id,Email FROM Contact WHERE Name = 'Pricing Team'];
            
            List<EmailTemplate> lstEmailTemplates = [SELECT Id, Body, Subject from EmailTemplate where DeveloperName = 'Blend_Extend'];
            if(contr.Opportunity__r.Type == 'Blend and Extend'){
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setTemplateId(lstEmailTemplates[0].Id);
               
                mail.setTargetObjectId(con.Id);// Any contact or User id of your record
                mail.setToAddresses(new list<string>{con.Email});
                mail.setSaveAsActivity(true);
                mail.setWhatId(recordId[0]); // Enter your record Id whose merge field you want to add in template
                System.debug('mail->'+mail);
                Messaging.SendEmailResult[] resultMail = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            }
       
        
    }
}