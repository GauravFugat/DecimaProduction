public class creditProcess_Notifications {
    
    public class values{
        @invocableVariable(required=true)
        public ID recordId;
        @invocableVariable(required=true)
        public String EmaiTemplateName; 
        @invocableVariable
        public boolean creditRiskTeam;
        @invocableVariable
        public boolean includeCreditPremium;
    }
    
    
    @invocableMethod(label = 'credit_Notifications')
    public static void invokeCallConga(List<values> v){
        if(v[0].includeCreditPremium == null){
            v[0].includeCreditPremium = false; 
        }
        List<String> EmailString = new List<String>();
        System.debug('v[0].EmaiTemplateName-->'+v[0].recordId);
        Credit_Check__c cCheck = [SELECT Id,Customer__c, Status__c FROM Credit_Check__c WHERE Id =: v[0].recordId];
        System.debug('cCheck-->>'+cCheck);
        Credit_Check__c cCheckToConsider = [SELECT Id,Name,Credit_Check_Outcome__c,Customer__c, Status__c FROM Credit_Check__c WHERE Status__c ='Active' AND Customer__c =: cCheck.Customer__c LIMIT 1];
        System.debug('cCheckToConsider-->>'+cCheckToConsider);
        Pricing_Request__c pr = [SELECT Id,Opportunity__c,Opportunity__r.Name,Opportunity__r.Owner.Name,Opportunity__r.Owner.Email,Opportunity__r.OwnerId,CreatedDate FROM Pricing_Request__c WHERE Credit_details__c =: cCheckToConsider.Id ORDER BY CreatedDate DESC LIMIT 1];
        List<Price__c> Latestprice;
        Price_Summary__c prSum;
        if(v[0].includeCreditPremium){
            Latestprice = [SELECT Id,CreatedDate FROM Price__c WHERE Opportunity__c =: pr.Opportunity__c AND Latest_Price__c = true ORDER BY CreatedDate DESC LIMIT 1];
            if (Latestprice.size() > 0){
             	prSum = [SELECT Credit_Premium__c FROM Price_Summary__c WHERE Price__c=: Latestprice[0].Id LIMIT 1];                
            }	
            
        }
        Contact con = [SELECT Id FROM Contact WHERE Name = 'Pricing Team'];
        if(v[0].creditRiskTeam == null){
            v[0].creditRiskTeam = false;
        }
        if(v[0].creditRiskTeam){
            Group CreditRiskTeam = [select Id from Group where  Type = 'Queue' AND NAME = 'Credit Risk Team' LIMIT 1];
            List<GroupMember> GroupMembers =  [Select UserOrGroupId  From GroupMember where GroupId =:CreditRiskTeam.Id];
            
            Set<Id> usrIds = new Set<Id>();
            for(GroupMember gm : GroupMembers){
                usrIds.add(gm.UserOrGroupId);
            }
            
            List<User> usrLst = [SELECT Email From User WHERE Id IN: usrIds];
            system.debug('46--usrLst--'+usrLst);
            for(User us : usrLst){
                EmailString.add(us.Email);
            }
        } 
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                
        System.debug('v[0].EmaiTemplateName-->'+v[0].EmaiTemplateName);
        EmailTemplate ET = [SELECT Id,Subject,Body,HtmlValue, Name FROM EmailTemplate WHERE DeveloperName =: v[0].EmaiTemplateName ];
        
        
        String bodyToSet = '';
        if(ET != NULL){
            if(v[0].includeCreditPremium){
                if (Latestprice.size() > 0){                    
                    Opportunity opp = [SELECT Id,Credit_Premium__c,isClosed FROM Opportunity WHERE Id =: pr.Opportunity__c];
                    opp.Credit_Premium__c = String.valueOf(prSum.Credit_Premium__c);
                    if (!opp.isClosed)
                    	update opp;    
                }
                
            }
            
            message.templateid = ET.Id;
            
            
            message.setTargetObjectId(con.Id);
            message.setWhatId(pr.Opportunity__c);
            if(EmailString.size() > 0 && v[0].creditRiskTeam){
                System.debug('67 in if--EmailString.size()--'+EmailString.size());
                message.setToAddresses(EmailString);
            }else{
                System.debug('in else'+pr.Opportunity__r.Owner.Email);
                message.setToAddresses(new List<String>{pr.Opportunity__r.Owner.Email});
            }
            
            Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {message};
            message.setSaveAsActivity(true);
            message.setTreatTargetObjectAsRecipient(false);
            Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
            system.debug('res ' + results);
        }
        
        Messaging.CustomNotification notification = new Messaging.CustomNotification();
                //notification.setBody(message.getHtmlBody().stripHtmlTags());
                notification.setBody(message.getPlainTextBody());
                //notification.setTitle('Credit Details');
                notification.setTitle(cCheckToConsider.Name);	
                notification.setSenderId(Userinfo.getUserId());
                CustomNotificationType type = [SELECT Id FROM CustomNotificationType WHERE DeveloperName = 'Stat_Dates_Update_Of_UA'];
                notification.setNotificationTypeId(type.id);
                notification.setTargetId(pr.Opportunity__c); // target object id
                notification.send(new Set<String> {pr.Opportunity__r.OwnerId });
               system.debug('89--');
        
    }
    
}