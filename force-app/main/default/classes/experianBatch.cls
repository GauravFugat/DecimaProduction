global class experianBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful {
    
    global Credit_Check__c cc;
    global Price__c priceRec;
    global boolean creditMatch;
    global String prRequests;
    global string prCustId;
    /*below boolean variable is set to true when this is called from fromInvoke_LiensJudgementsTrends apex and 
will be set to false when called from finish method of Batch_CreateCustomObjectRecord */
    global boolean fromInvoke_LiensJudgementsTrends;
    
    global List<Pricing_Request__c> prToupdate = new List<Pricing_Request__c>(); 
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('fromInvoke_LiensJudgementsTrends-->> '+fromInvoke_LiensJudgementsTrends);
        prToupdate = (List<Pricing_Request__c>) System.JSON.deserialize(prRequests, List<Pricing_Request__c>.class);
        Opportunity Opp = [SELECT Id,Pricing_Request_Complete__c,OwnerId FROM Opportunity where Id =: prToupdate[0].Opportunity__c];
        if(fromInvoke_LiensJudgementsTrends == false){
            priceRec.Opportunity__c = Opp.Id;
            priceRec.Pricing_Request__c = prToupdate[0].Id;
            priceRec.Credit_Detail__c = cc.Id;
        }
        String query = 'SELECT Id, Owner.Email, Name FROM Account limit 1';
        try{
            System.debug('1 1111-->> '+cc.Id);
            System.debug('1 2222-->> '+prRequests);
            System.debug('1 3333-->> '+creditMatch);
            System.debug('1 4444-->> '+priceRec); 
            updateCreditDetails.callExperianSync(cc.Id, prRequests , creditMatch,priceRec);
            Credit_Check__c ccToLog = [SELECT Id,Name,Customer__c FROM Credit_Check__c WHERE Id =: cc.Id];
            createCreditLogs.createCreditProcessLog(ccToLog.Customer__c, 'Update credit check record status to Active', 'Action', 'Credit Check record updated as Active',ccToLog.Name,ccToLog.Id,'True');
        }
        catch(Exception e){
            
            String description = 'Error occured: '+e.getMessage() + '-' + e.getLineNumber();
            System.debug('description Line-->> '+ e.getLineNumber());
            System.debug('description-->> '+description);
            Credit_Check__c ccToUpdate = [SELECT Id,OwnerId,Customer__c,Name FROM Credit_Check__c WHERE Id =: cc.Id];
            createCreditLogs.createCreditProcessLog(ccToUpdate.Customer__c, 'Error in batch', 'Action', description,'','','');
            
            if(ccToUpdate.Id != null){
                ccToUpdate.Status__c = 'New'; 
                update ccToUpdate;
                
                Messaging.CustomNotification notification = new Messaging.CustomNotification();
                notification.setBody(ccToUpdate.Name+' Please check integration logs for more details.');
                notification.setTitle('Experian credit assessment failed.');	
                notification.setSenderId(Userinfo.getUserId());
                CustomNotificationType type = [SELECT Id FROM CustomNotificationType WHERE DeveloperName = 'Stat_Dates_Update_Of_UA'];
                notification.setNotificationTypeId(type.id);
                notification.setTargetId(ccToUpdate.Id); // target object id
                notification.send(new Set<String> { ccToUpdate.OwnerId });
            }
        }
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Account> brokerAccounts) {
        
        
        if(fromInvoke_LiensJudgementsTrends == false){
            Create_Price_Summary_Asynchronous.getTermPrice2(new List<Id>{priceRec.Id});
            Opportunity Opp = [SELECT Id,Pricing_Request_Complete__c,AccountId,OwnerId FROM Opportunity where Id =: prToupdate[0].Opportunity__c];
            Opp.Pricing_Request_Complete__c = true;
            
            if(!Test.isRunningTest()){
                update priceRec;
                update Opp;
                
            }
            Price__c priceToLog= [SELECT Id,Name, P_D__c, Credit__c, Subject_to_Credit__c FROM Price__c WHERE Id =: priceRec.Id];
            createCreditLogs.createCreditProcessLog(Opp.AccountId, 'Calculate price summaries', 'Action', 'Price summaries calculated','','','Success');
            createCreditLogs.createCreditProcessLog(Opp.AccountId, 'Price ready to quote', 'Action', 'Price [ P&D:'+priceToLog.P_D__c+', Credit:'+priceToLog.Credit__c+' ,Subject to credit:'+priceToLog.Subject_to_Credit__c+' ]',priceToLog.Name,priceToLog.Id,'Complete');
        }
    }
    global void finish(Database.BatchableContext BC) {
        if(fromInvoke_LiensJudgementsTrends == true){
       Credit_Check__c newCCRecord1  = [SELECT Id,Status__c,Name,Credit_Check_Outcome__c,Customer__c FROM Credit_Check__c WHERE Customer__c =: prCustId AND (Status__c = 'New' OR Status__c = 'Active')  Limit 1 FOR UPDATE];

        Account latesAcc = [SELECT Id,Customer_Credit_Limit__c,Customer_Credit_Annual_Volume__c FROM Account WHERE Id =: prCustId];
                newCCRecord1.Credit_Limit__c = latesAcc.Customer_Credit_Limit__c;
                newCCRecord1.Total_Risk_Volume__c = latesAcc.Customer_Credit_Annual_Volume__c;
                update newCCRecord1;
        }
    }
}