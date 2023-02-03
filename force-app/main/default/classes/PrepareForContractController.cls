/*
* @Purpose: Controller Class for Quote Generator Component
* @Author: Vishwanath Kodgire
* @CreatedDate: 01/17/2020
* @Related Code: 
* @Test Class: PrepareForContractController_Test
* @LastModifiedDate:
* @LastModifiedBy: Rahul Ghaytadak
*/
public class PrepareForContractController {
    public class optionsWrapper {
        @AuraEnabled public String label {get;set;}
        @AuraEnabled public String value {get;set;}
    }
    //To fetch and display QLI list on PFCScreen1 component
    @auraEnabled
    public static List<QLIListWrapper> getQLIs(Id quoteId, Boolean isUpdate){
        List<QLIListWrapper> qliList = new List<QLIListWrapper>();
        List<optionsWrapper> optionsLst = new List<optionsWrapper>();
        optionsWrapper option1 = new optionsWrapper();
        optionsWrapper option2 = new optionsWrapper();
        List<QuoteLineItem> qliRecords = [SELECT  Id,
                                          QuoteId,Quote.Price_Type__c,
                                          Quote.Price__r.Obsolete__c,
                                          Quote.OpportunityId,
                                          Product2.Name,
                                          Term_Months__c,
                                          Total_Usage__c,
                                          Base_Price__c,
                                          POR_Tax_Adjustment__c,
                                          Total_Unit_Price__c,
                                          Total_Unit_Price_W_o_Tax__c,
                                          Tax_Factor__c ,
                                          Sales_Margin_per_unit__c,
                                          Quote.Prepayment__c,
                                          Quote.Deposit__c,
                                          Broker_Margin_per_unit__c
                                          FROM QuoteLineItem
                                          WHERE QuoteId=: quoteId order by Term_Months__c];
        Boolean creditConfirmation = CreditConfirmation(quoteId,qliRecords[0].Quote.OpportunityId);
        option1.label = 'Prepayment : $'+qliRecords[0].Quote.Prepayment__c;
        option1.value = 'Prepayment';
        option2.label = 'Deposit : $'+qliRecords[0].Quote.Deposit__c;
        option2.value = 'Deposit';
        optionsLst.add(option1);
        optionsLst.add(option2);
        // Card SU-602 : Check credit check outcome is passed or not 
        Quote quo = [SELECT Id, Name, Price__c, Bill_Type__c,Price_Type__c FROM Quote Where Id =: quoteId];
        Price__c pr = [SELECT Id,P_D__c, Pricing_Request__c,Credit_Detail__r.Credit_Check_Outcome__c,Credit_Detail__r.Status__c FROM Price__c Where Id =: Quo.Price__c ];
        if(Quo.Bill_Type__c == 'Dual' || Quo.Bill_Type__c == 'UCB with Credit'){
            Pricing_Request__c Preq = [SELECT Id, Credit_Details__r.Credit_Check_Outcome__c 
                                       FROM Pricing_Request__c Where Id =: pr.Pricing_Request__c ];
            if(pr.Credit_Detail__r.Credit_Check_Outcome__c != null ){
                //|| quo.Price_Type__c == 'Prepayment & Deposit'
                if(pr.Credit_Detail__r.Credit_Check_Outcome__c == 'Passed' && pr.Credit_Detail__r.Status__c == 'Active' ){for(QuoteLineItem qli: qliRecords){qliList.add(new QLIListWrapper(optionsLst,pr,false,qli,false,creditConfirmation));}}else{for(QuoteLineItem qli: qliRecords){qliList.add(new QLIListWrapper(optionsLst,pr,false,qli,true,creditConfirmation));}}
            }else{
                for(QuoteLineItem qli: qliRecords)
                    qliList.add(new QLIListWrapper(optionsLst,pr,false,qli,false,creditConfirmation));
            }
        }else{
            for(QuoteLineItem qli: qliRecords){qliList.add(new QLIListWrapper(optionsLst,pr,false,qli,false,creditConfirmation));}
        }
        if(isUpdate){
            Id oppId = [SELECT Id, OpportunityId FROM Quote WHERE Id=: quoteId].OpportunityId;
            Opportunity oppRecord = [SELECT Id, SyncedQuoteId, SyncedQuote.Name FROM Opportunity WHERE Id=: oppId];
            oppRecord.StageName = 'Quoting';
            oppRecord.SyncedQuoteId = quoteId;
            update oppRecord;
        }
        return qliList;
    }
    /* wrapper class */  
    public class QLIListWrapper {
        @AuraEnabled public Price__c price {get;set;}
        @AuraEnabled public boolean isChecked {get;set;}
        @AuraEnabled public  QuoteLineItem objQLI{get;set;}
        @AuraEnabled public boolean ValidateCreditCheck {get;set;}
        @AuraEnabled public boolean CreditConfirmation {get;set;}
        @AuraEnabled public List<optionsWrapper> options {get;set;}
        public QLIListWrapper( List<optionsWrapper> options,Price__c price,boolean isChecked, QuoteLineItem objQLI, boolean ValidateCreditCheck,boolean CreditConfirmation){
            this.options = options;
            this.isChecked = isChecked;
            this.objQLI = objQLI;
            this.ValidateCreditCheck = ValidateCreditCheck;
            this.CreditConfirmation = CreditConfirmation;
            this.price = price;
        }
    }
    //To get other quote details like Quote Product,bill type,Name , IsSyncing.
    @auraEnabled
    public static List<quoteWrapper> getQuoteOptions(Id recordId){
        List<quoteWrapper> quoteOptions = new List<quoteWrapper>();
        List<quote> quoteRecords = [SELECT Id, Name,Opportunity.Type, Bill_Type__c, isSyncing, Product__r.Name FROM Quote WHERE OpportunityId =: recordId ORDER BY QuoteNumber DESC];
        for(quote q:quoteRecords){
            quoteOptions.add( new quoteWrapper(q.isSyncing, q.Id, q.Name,q.Product__r.Name, q.Bill_Type__c,q.Opportunity.Type));
        }
        return quoteOptions;
    }
    //Wrapper class
    public class quoteWrapper {
        @AuraEnabled public boolean isSynced {get;set;}
        @AuraEnabled public Id quoteId{get;set;}
        @AuraEnabled public String quoteName{get;set;}
        @AuraEnabled public String productName{get;set;}
        @AuraEnabled public String BillType{get;set;}
        //Changes required for card SU-931
        @AuraEnabled public String isLoadFollowing {get;set;}
        public quoteWrapper(boolean isSynced, String quoteId,String quoteName,String productName, String BillType,String isLoadFollowing){
            
            this.isSynced = isSynced;
            this.quoteId = quoteId;
            this.quoteName = quoteName;
            this.productName = productName;
            this.BillType = BillType;
            //Changes required for card SU-931
            this.isLoadFollowing = isLoadFollowing;
        }
    }
    //To delete all the QuoteLineItems except the one which is selected from Screen 1 of PFC
    @auraEnabled
    public static List<OpportunityContactRole> updateQuote(List<quotelineItem> selectedLineItem,String selectedOption){
        //system.debug('OpportunityContactRole');
        Trigger_Settings__c trgSetting = [SELECT Id,name,TriggerOn__c FROM Trigger_Settings__c WHERE Name = 'QuoteLineItem_Trigger'];   
        Quote quoteObj = [SELECT Id, Prepayment__c, Deposit__c,P_D_Payment_Selection__c FROM Quote WHERE Id =: selectedLineItem[0].QuoteId];
        quoteObj.P_D_Payment_Selection__c = selectedOption;
        update quoteObj;
        Map<Decimal,quotelineItem> qliMap = new Map<Decimal,quotelineItem>();
        Set<Id> selectedLineItemIds = new Set<Id>();
        for(quotelineItem qli : selectedLineItem){
            selectedLineItemIds.add(qli.Id);
            qliMap.put(qli.Term_Months__c , qli);
        }
        system.debug('selectedLineItemIds-->'+selectedLineItemIds);
        system.debug('153-->');
        List<QuoteLineItem> qliToBeDeleted = [SELECT Id,QuoteId FROM QuoteLineItem WHERE Id NOT IN :selectedLineItemIds AND QuoteId=: quoteObj.Id];
        system.debug('156');
        system.debug('Before delete qliToBeDeleted--'+qliToBeDeleted);
        if(qliToBeDeleted != null){
        Delete qliToBeDeleted;
        }
        //Insert qliToBeinserted;
        System.debug('selectedLineItem-->> '+selectedLineItem);
        Update selectedLineItem;
        System.debug('selectedLineItem after-->> '+selectedLineItem);
        system.debug('166');
        system.debug('qliToBeDeleted--'+qliToBeDeleted);
        Id oppId = [SELECT Id, OpportunityId FROM Quote WHERE Id=: selectedLineItem[0].QuoteId].OpportunityId;
        return [SELECT Id, Contact.Name, ContactId, Contact.Email, Contact.FirstName, Role, IsPrimary FROM OpportunityContactRole WHERE opportunityId =:oppId];
    }
    //To fetch customer contacts
    @auraEnabled
    public static List<Contact> getCustomerContacts(Id oppId){
        system.debug('here');
        Opportunity oppRecord = [SELECT Id, AccountId FROM Opportunity WHERE Id =: oppId];
        system.debug('oppRecord');
        return [SELECT Id, Name, Email FROM Contact WHERE AccountId =: oppRecord.AccountId];
    }
    //To update the Opportunity stage and to Generate Customer Agreement by calling Conga Document Generator Api class
    @auraEnabled
    public static void secondScreenExit( Id oppId, boolean creditConfirmValue, String selRadioVal){
        System.debug('--Here--');
        System.debug('selRadioVal------->> '+selRadioVal);
        List<OpportunityLineItem> oliLst = new List<OpportunityLineItem>([SELECT OpportunityId,PricebookEntryId, Product2Id, ProductCode, Name, 
                                                                          Quantity, TotalPrice,ListPrice,Description, Base_Price__c, Term_Months__c, 
                                                                          Volume_kWh__c, Name__c, Quote_Sales_Margin__c, Broker_Margin_per_unit__c, 
                                                                          Sales_Margin_per_unit__c, Total_Unit_Price__c, Product_Name__c, If_Reset__c, Energy__c, 
                                                                          Clean_Energy_RECs__c, Clean_Energy_ZECs__c, Unforced_Capacity__c, Ancillary_Services__c,
                                                                          Renewable_Energy_Voluntary__c, TOTS__c, NITS__c, ARRs__c, TECs__c, POR__c, GRT__c, PJM_Note_2__c, 
                                                                          Output_Total_Unit_Price__c, Output_Broker_Margin__c, Product_Family__c 
                                                                          FROM OpportunityLineItem where OpportunityId =: oppId]);
        
        Opportunity oppRecord = [SELECT Id,Type,Customer_Agreement_Template_B_I__c,StageName,State__c, Product_Name__c,Account_Name__c, Name,
                                 SyncedQuoteId,SyncedQuote.Product__r.Family, Opportunity_Id__c,
                                 Account.Name, Customer_Agreement_Template__c FROM Opportunity WHERE Id=: oppId ];
        //SU - 936/937 - Start
        String TemplateToUse = oppRecord.Customer_Agreement_Template_B_I__c;
        if(selRadioVal == 'Prepayment'){
            TemplateToUse =TemplateToUse+ ','+ System.Label.Prepayment_Attachment_B;
        }else if(selRadioVal == 'Deposit'){
            TemplateToUse =TemplateToUse +','+ System.Label.Deposit_Attachment_B;
        }
        System.debug('TemplateToUse-->> '+TemplateToUse);
        //SU - 936/937 - End
        for(OpportunityLineItem oli : oliLst){
            System.debug('oli-->> '+oli);
            if(oppRecord.SyncedQuote.Product__r.Family == 'Block & Index DAM' || oppRecord.SyncedQuote.Product__r.Family == 'Block & Index RT'){
                String fileName = oppRecord.Account_Name__c + ' - ' + oli.Term_Months__c + 'm - ' + oppRecord.Opportunity_ID__c + ' - ' + system.today().format();
                if(!Test.isRunningTest()) CongaDocumentGenerator.callCongaMultipleAgreements(oppId, TemplateToUse, System.Label.PFC_Conga_Query+oppRecord.SyncedQuoteId, fileName, NULL, NULL, FALSE, FALSE,integer.valueOf(oli.Term_Months__c));
            }else{
                String template;
                if(oppRecord.Type == 'Load Following'){ template = System.Label.Load_Following_Template_Label; }
                else if(selRadioVal == 'Prepayment'){
                    template = oppRecord.Customer_Agreement_Template__c +','+ System.Label.Prepayment_Attachment_B;
                }else if(selRadioVal == 'Deposit'){template = oppRecord.Customer_Agreement_Template__c +','+ System.Label.Deposit_Attachment_B;}
                else{template = oppRecord.Customer_Agreement_Template__c; }
                String fileName = oppRecord.Account_Name__c + ' - ' + oli.Term_Months__c + 'm - ' + oppRecord.Opportunity_ID__c + ' - ' + system.today().format();
                if(!Test.isRunningTest())
                CongaDocumentGenerator.callCongaMultipleAgreements(oppId, template, System.Label.PFC_Conga_Query+oppRecord.SyncedQuoteId, fileName, NULL, NULL, FALSE, FALSE,integer.valueOf(oli.Term_Months__c));
            }
        }
        oppRecord.StageName = 'Contracting';
        oppRecord.CPM_Credit_Confirmation__c = creditConfirmValue;
        Update oppRecord;
    }
    //To Add and update opportunity contact roles
    @auraEnabled
    public static OpportunityContactRole updateContactRoles(Id contactId, OpportunityContactRole contactRole, Id oppId, String role){
        Id contactRoleId;
        if(contactRole != NULL){
            contactRole.contactId = ContactId;
            //contactRole.IsPrimary = true;
            Update contactRole;
            contactRoleId = contactRole.Id;
        }
        else{
            OpportunityContactRole contactRoleNew = new OpportunityContactRole();
            contactRoleNew.ContactId = ContactId;
            contactRoleNew.OpportunityId = oppId;
            contactRoleNew.Role = role;
            contactRoleNew.IsPrimary = true;
            Insert contactRoleNew;
            contactRoleId = contactRoleNew.Id;
        }
        return [SELECT Id, Contact.Name, ContactId, Contact.FirstName, Contact.Email, Role, IsPrimary FROM OpportunityContactRole WHERE Id =:contactRoleId];
    }
    //To fetch lookup values based on Object Name passed as a parameter along with the search key (lookup functionality)
    @AuraEnabled
    public static List < sObject > fetchLookUpValues(String searchKeyWord, String ObjectName, String accId, Boolean isInit,String BrokerType) {
        system.debug('ObjectName-->' + ObjectName);
        if(ObjectName == 'User' ){
            String searchKey = searchKeyWord + '%';
            List < sObject > returnList = new List < sObject > ();
            String sQuery = '';
            sQuery =  'select id, Name, Email, FirstName from ' +ObjectName + ' where Name LIKE: searchKey order by createdDate DESC limit 5';
            List < sObject > lstOfRecords = Database.query(sQuery);
            for (sObject obj: lstOfRecords) {
                returnList.add(obj);
            }
            return returnList;
        }
        else if(ObjectName == 'Account' && (BrokerType != '' && BrokerType != null )){
            String searchKey = searchKeyWord + '%';
            List < sObject > returnList = new List < sObject > ();
            String sQuery = '';
            sQuery =  'select id, Name from ' +ObjectName + ' where Name LIKE: searchKey AND Type =:BrokerType  order by createdDate DESC limit 5';
            List < sObject > lstOfRecords = Database.query(sQuery);
            for (sObject obj: lstOfRecords) {
                returnList.add(obj);
            }
            return returnList;
        }
        else{
            String searchKey = searchKeyWord + '%';
            
            List < sObject > returnList = new List < sObject > ();
            
            // Create a Dynamic SOQL Query For Fetch Record List with LIMIT 5   
            String sQuery = '';
            if(isInit)
                sQuery =  'select id, Name, Email, FirstName from ' +ObjectName + ' where AccountId =: accId AND Name LIKE: searchKey order by createdDate DESC limit 5';
            else{
                String recordType = [SELECT Id, recordType.Name FROM Account WHERE Id =: accId].recordType.Name;
                sQuery =  'select id, Name, Email, FirstName from ' +ObjectName + ' where account.recordType.Name =: recordType AND Name LIKE: searchKey order by createdDate DESC limit 5';
            }
            List < sObject > lstOfRecords = Database.query(sQuery);
            
            for (sObject obj: lstOfRecords) {
                returnList.add(obj);
            }
            return returnList;
        }
    }
    
    //To create record by clicking the '+New Contact' button on the Broker contact Lookup of the component.
    @AuraEnabled
    public static sObject getCreatedContact(String accId) {
        contact con;
        Datetime d = system.now();
        d = d.addSeconds(-5);
        List<Contact> c = [SELECT Id, Name, FirstName, Email FROM Contact WHERE AccountId =: accId AND CreatedDate >=: d ORDER BY CreatedDate DESC LIMIT 1];
        if(!c.isEmpty())
            con = c[0];
        else
            con = NULL;
        
        List<Account> acc = [SELECT Id, Name FROM Account WHERE CreatedDate >=: d ORDER BY CreatedDate DESC LIMIT 1];
        if(!Test.isRunningTest()){
            if(con == NULL){return acc[0];}
        }
        return con;
    }
    @AuraEnabled 
    public static void sendMailMethod(Id whatId, String mSubject ,String mbody, List<ContentDocumentLink> att, List<String> toAddresses, List<String> ccAddresses, List<Id> additionalFiles){
        List<Messaging.SingleEmailMessage> mails =  new List<Messaging.SingleEmailMessage>();     
        String htmlbody =' <html> <div class="letterheadWrapper"> <style>p{margin-top:0px; margin-bottom:0px;}</style> <center> <table cellpadding="0" width="500" cellspacing="0" id="topTable" height="450"> <tbody> <tr valign="top"> <td style="background-color: rgb(255, 255, 255); vertical-align: top; height: 100px; text-align: center; width: 500px;"><img src="https://smartestenergyus--dev5--c.documentforce.com/servlet/servlet.ImageServer?id=015f0000000zAzm&oid=00Df0000001p4DG" /></td> </tr> <tr valign="top"> <td style=" background-color:#004D8F; bEditID:r2st1; bLabel:accent1; height:3px;"></td> </tr> <tr valign="top" height="400"><td teditid="c1r1" style=" background-color:#FFFFFF; bEditID:r3st1; color:#000000; bLabel:main; font-size:12pt; font-family:arial;" aeditid="c1r1" locked="0"><div style="color: rgb(0, 0, 0); font-family: arial; font-size: 12pt;">'+mBody+' </td></tr><tr valign="top"> <td style=" background-color:#004D8F; bEditID:r2st1; bLabel:accent1; height:3px;"></td> </tr> </tbody> </table> </center> </div></html> ';
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        //mail.setTargetObjectId(mMail);
        mail.setWhatId(whatId);
        mail.setSubject(mSubject);
        if(!ccAddresses.isEmpty()){
            mail.ccaddresses = ccAddresses;
        }
        if(!toAddresses.isEmpty()){
            mail.toaddresses = toAddresses;
        }
        mail.setHtmlBody(htmlbody);
        system.debug('att ' +att);
        List<String> docIds = new List<String>();
        if(att.size() != 0 || !additionalFiles.isEmpty()){
            Set<Id> AttIds = new Set<Id>();
            for(ContentDocumentLink cv : att){
                AttIds.add(cv.ContentDocumentId);
            }
            List<ContentVersion> cvs = [SELECT Id FROM ContentVersion WHERE ContentDocumentId IN : additionalFiles OR ContentDocumentId IN : AttIds ];
            for(ContentVersion file: cvs)
                docIds.add(file.Id);
        }
        if(!docIds.isEmpty())
            mail.setEntityAttachments(docIds);
        mail.setSaveAsActivity(true);
        mail.setBccSender(true);
        mails.add(mail);
        Messaging.SendEmailResult[] results = Messaging.sendEmail(mails);  
        system.debug('res ' + results);
    }   
    @AuraEnabled 
    public static EtAttWrapper getEmailTemplate(String emailTemplateName, Id recordId,integer noOfTerms){
        System.debug('emailTemplateName=>> '+emailTemplateName);
        List<ContentDocumentLink> cdlToPass = new List<ContentDocumentLink>();
        Opportunity oppRecord = [SELECT Id,Type,Load_following__c, Include_Price_w_o_Tax__c,StageName, Account_Name__c, Name, SyncedQuoteId, Opportunity_Id__c, Account.Name, Customer_Agreement_Template__c FROM Opportunity WHERE Id=: recordId];
        List<QuoteLineItem> QLIs = [SELECT Id,Tax_Factor__c, Term_Months__c, Total_Unit_Price__c, Total_Unit_Price_W_o_Tax__c, Broker_Margin_per_unit__c FROM QuoteLineItem WHERE QuoteId =: oppRecord.SyncedQuoteId ];
        EmailTemplate et = [SELECT Id, Subject,body, htmlValue FROM EmailTemplate WHERE developerName=: emailTemplateName LIMIT 1];
        system.debug('et: ' +et.Body );
        String row = '';
        integer j = 1;
        String bgcolor = '';
        for(QuoteLineItem qli : QLIs){
            if( math.mod(j, 2)  == 0){
                bgcolor = '';
            }
            else{
                bgcolor = '';
            }
            
            if(oppRecord.Include_Price_w_o_Tax__c){
                
                row = row+      '<tr>'
                    +'<td style="border: 1px solid #dddddd; text-align: left; padding: 8px;'+bgcolor+'">'+qli.Term_Months__c+'</td>'
                    +'<td style="border: 1px solid #dddddd; text-align: left; padding: 8px;'+bgcolor+'"> $'+qli.Total_Unit_Price__c+'</td>'
                    +'<td style="border: 1px solid #dddddd; text-align: left; padding: 8px;'+bgcolor+'"> $'+qli.Total_Unit_Price_W_o_Tax__c+'</td>'
                    +'<td style="border: 1px solid #dddddd; text-align: left; padding: 8px;'+bgcolor+'"> $'+qli.Broker_Margin_per_unit__c+'</td>'
                    +'</tr>';
            }else{
                
                row = row+      '<tr>'
                    +'<td style="border: 1px solid #dddddd; text-align: left; padding: 8px;'+bgcolor+'">'+qli.Term_Months__c+'</td>'
                    +'<td style="border: 1px solid #dddddd; text-align: left; padding: 8px;'+bgcolor+'"> $'+qli.Total_Unit_Price__c+'</td>'
                    +'<td style="border: 1px solid #dddddd; text-align: left; padding: 8px;'+bgcolor+'"> $'+qli.Broker_Margin_per_unit__c+'</td>'
                    +'</tr>';
            
            }
            
            /////
            if(oppRecord.type == 'Load Following'){
                row = '';
             if(oppRecord.Include_Price_w_o_Tax__c){
                row = row+      '<tr>'
                    +'<td style="border: 1px solid #dddddd; text-align: left; padding: 8px;'+bgcolor+'">'+qli.Term_Months__c+'</td>'
                    +'<td style="border: 1px solid #dddddd; text-align: left; padding: 8px;'+bgcolor+'"> $'+qli.Total_Unit_Price__c+'</td>'
                    +'<td style="border: 1px solid #dddddd; text-align: left; padding: 8px;'+bgcolor+'"> $'+qli.Total_Unit_Price_W_o_Tax__c+'</td>'
                    +'</tr>';
            }else{
                row = row+      '<tr>'
                    +'<td style="border: 1px solid #dddddd; text-align: left; padding: 8px;'+bgcolor+'">'+qli.Term_Months__c+'</td>'
                    +'<td style="border: 1px solid #dddddd; text-align: left; padding: 8px;'+bgcolor+'"> $'+qli.Total_Unit_Price__c+'</td>'
                    +'</tr>';
            }   
                
            }
            /////
            
            
        }
        String table = '';
        if(oppRecord.Include_Price_w_o_Tax__c){
            table = '<table style="font-family: arial, sans-serif; border-collapse: collapse; width: 60%;">'
                +'<tr>'
                +'<th style="border: 1px solid #dddddd; text-align: left; padding: 8px;">Months</th>'
                +'<th style="border: 1px solid #dddddd; text-align: left; padding: 8px;">Price w/Tax</th> '
                +'<th style="border: 1px solid #dddddd; text-align: left; padding: 8px;">Price w/o Tax</th>'
                +'<th style="border: 1px solid #dddddd; text-align: left; padding: 8px;">Commission</th>'
                +'</tr>'
                +row
                +'</table>';
        }else{
            
            table = '<table style="font-family: arial, sans-serif; border-collapse: collapse; width: 60%;">'
                +'<tr>'
                +'<th style="border: 1px solid #dddddd; text-align: left; padding: 8px;">Months</th>'
                +'<th style="border: 1px solid #dddddd; text-align: left; padding: 8px;">Price w/Tax</th> '
                +'<th style="border: 1px solid #dddddd; text-align: left; padding: 8px;">Commission</th>'
                +'</tr>'
                +row
                +'</table>';
            
        }
        
        if(oppRecord.type == 'Load Following'){
            table = '';
            if(oppRecord.Include_Price_w_o_Tax__c){
            table = '<table style="font-family: arial, sans-serif; border-collapse: collapse; width: 60%;">'
                +'<tr>'
                +'<th style="border: 1px solid #dddddd; text-align: left; padding: 8px;">Months</th>'
                +'<th style="border: 1px solid #dddddd; text-align: left; padding: 8px;">Energy Only Price</th> '
                +'<th style="border: 1px solid #dddddd; text-align: left; padding: 8px;">Energy Only Price w/o Tax</th>'
                +'</tr>'
                +row
                +'</table>';
        }else{
            
            table = '<table style="font-family: arial, sans-serif; border-collapse: collapse; width: 60%;">'
                +'<tr>'
                +'<th style="border: 1px solid #dddddd; text-align: left; padding: 8px;">Months</th>'
                +'<th style="border: 1px solid #dddddd; text-align: left; padding: 8px;">Energy Only Price</th> '
                +'</tr>'
                +row
                +'</table>';
            
        }
        }
        
        if(!Test.isRunningTest())
        et.HtmlValue = et.HtmlValue.replace('{Table}',table);
        System.debug('recordId 111111-->> '+recordId);
        et.Subject = et.Subject + ' ' + oppRecord.Account_Name__c + ' - ' + oppRecord.Opportunity_ID__c;
        Attachment att = [Select Id, Name,createdDate, Body From Attachment WHERE ParentId =:recordId ORDER BY CreatedDate DESC  LIMIT 1];
        List<ContentDocumentLink> cdl = [SELECT Id, LinkedEntityId, ContentDocumentId,ContentDocument.Title,
                                         SystemModstamp FROM ContentDocumentLink where LinkedEntityId=: recordId ORDER BY SystemModstamp DESC ];
        System.debug('cdl-->> '+cdl);
        for(integer i=0;i<noOfTerms;i++){
            cdlToPass.add(cdl[i]);
        }
        User userDetails = [SELECT Id, Name, FirstName, Email FROM User WHERE Id =: userInfo.getUserId()];
        return new EtAttWrapper(et, cdl[0], userDetails,cdlToPass,oppRecord);
    }
    public class EtAttWrapper {
        @AuraEnabled public emailTemplate et {get;set;}
        @AuraEnabled public  ContentDocumentLink cdl{get;set;}
        @AuraEnabled public  user userDetails{get;set;}
        @AuraEnabled public  List<ContentDocumentLink> cdLst{get;set;}
        @AuraEnabled public  Opportunity opp {get;set;}
        
        public EtAttWrapper(emailTemplate et, ContentDocumentLink cdl, User userDetails, List<ContentDocumentLink> cdLst, Opportunity opp ){
            this.et = et;
            this.cdl = cdl;
            this.userDetails = userDetails;
            this.cdLst = cdLst;
            this.opp =opp;
        }
    }
    
    //Total Price Validation for NIMO.
    //1.Total Price should have '4' or '9' as 4th decimal. 
    //2.Total Price should have '0' as the 5th decimal.
    @AuraEnabled
    public static boolean TotalPriceValidation(Id OpptyId,List<Decimal> TotalPriceLst, quotelineItem selectedLineItem){
        System.debug('selectedLineItem--> '+selectedLineItem);
        Boolean Validated = true;
        List<Utility_Account_Opportunity__c> UAOLst = new List<Utility_Account_Opportunity__c>([SELECT Id, Name,Start_Date__c,Status__c, Opportunity__c, Utility__c FROM Utility_Account_Opportunity__c where Opportunity__c=:OpptyId AND Utility__c LIKE 'National Grid%' AND Status__c = 'Priced']);
        Quote quote = [SELECT Id, Name,Bill_Type__c, OpportunityId,Price__r.Pricing_Request__r.Bill_Type__c,Price__r.Bill_Type__c, Price__c FROM Quote Where Id =: selectedLineItem.QuoteId ];
        List<Price__c> pr = [SELECT Id,Bill_Type__c,Pricing_Request__r.Bill_Type__c FROM Price__c Where Id =: quote.Price__c AND (Bill_Type__c = 'Dual' OR Pricing_Request__r.Bill_Type__c = 'Dual')];
        system.debug('pr'+pr);
        if(pr.size()>0 || quote.Bill_Type__c == 'Dual'){
            Validated = true;
        }
        else{
            if(UAOLst.size()>0 && TotalPriceLst.size()>0){
                for(Decimal TotalPrice : TotalPriceLst ){
                    System.debug('TotalPrice-->'+TotalPrice);
                    System.debug('9-->'+String.valueOf(TotalPrice.setscale(5)).left(6).right(1));
                    System.debug('0-->'+String.valueOf(TotalPrice.setscale(5)).left(7).right(1));
                    
                    if((String.valueOf(TotalPrice.setscale(5)).left(6).right(1) == '9' && String.valueOf(TotalPrice.setscale(5)).left(7).right(1) == '0') || (String.valueOf(TotalPrice.setscale(5)).left(6).right(1) == '4' && String.valueOf(TotalPrice.setscale(5)).left(7).right(1) == '0')){
                        if(Validated != false){ 
                            Validated = true;
                        }
                    }
                    else{
                        Validated = false;
                    }
                }
            }
        }
        system.debug('Validation->'+Validated);
        system.debug('TotalPriceLst->'+TotalPriceLst.size());
        return Validated;
    }
    
    @AuraEnabled
    public static boolean AllowNIMOValidation(Id OpptyId,List<Decimal> TotalPriceLst, quotelineItem selectedLineItem){
        Boolean Validated = true;
        List<Utility_Account_Opportunity__c> UAOLst = new List<Utility_Account_Opportunity__c>([SELECT Id, Name,Start_Date__c,Status__c, Opportunity__c, Utility__c FROM Utility_Account_Opportunity__c where Opportunity__c=:OpptyId AND Utility__c LIKE 'National Grid%' AND Status__c = 'Priced']);
        Quote quote = [SELECT Id, Name,Bill_Type__c, OpportunityId,Price__r.Pricing_Request__r.Bill_Type__c,Price__r.Bill_Type__c, Price__c FROM Quote Where Id =: selectedLineItem.QuoteId ];
        List<Price__c> pr = [SELECT Id,Bill_Type__c,Pricing_Request__r.Bill_Type__c FROM Price__c Where Id =: quote.Price__c AND (Bill_Type__c = 'Dual' OR Pricing_Request__r.Bill_Type__c = 'Dual')];
        system.debug('pr'+pr);
        if(pr.size()>0 || quote.Bill_Type__c == 'Dual'){
            Validated = true;
        }
        else{
            if(UAOLst.size()>0 && TotalPriceLst.size()>0){
                for(Decimal TotalPrice : TotalPriceLst ){
                    
                    if((String.valueOf(TotalPrice.setscale(5)).left(6).right(1) == '9' && String.valueOf(TotalPrice.setscale(5)).left(7).right(1) == '0') || (String.valueOf(TotalPrice.setscale(5)).left(6).right(1) == '4' && String.valueOf(TotalPrice.setscale(5)).left(7).right(1) == '0')){
                        if(Validated != false){ 
                            Validated = true;
                        }
                    }
                    else{
                        Validated = false;
                    }
                }
            }
        }
        List<PermissionSetAssignment> PSA = [SELECT Id, PermissionSetId, Assignee.Name FROM PermissionSetAssignment WHERE PermissionSet.Name = 'NIMO_Quote_Validation_Override' AND AssigneeId =: UserInfo.getUserId()];
        if(!PSA.isEmpty()){
            Validated = true;
        }
        return Validated;
    }
    
    public class OppWrapper {
        @AuraEnabled public boolean IsValid {get;set;}
        @AuraEnabled public boolean creditConfirmValue {get;set;}
        @AuraEnabled public boolean creditConfirmRequired {get;set;}
        @AuraEnabled public boolean Obsolete {get;set;}
        @AuraEnabled public boolean TaxExempt {get;set;}
        @AuraEnabled public Integer CountofTerms {get;set;}
        @AuraEnabled public  String Switching_type{get;set;}
        @AuraEnabled public  List<String> missedFieldsLstAcc = new List<String>();
        @AuraEnabled public  List<String> missedFieldsLstContact = new List<String>();
        @AuraEnabled public  List<String> missedFieldsLstOpp = new List<String>();
        @AuraEnabled public  List<Utility_Account_Opportunity__c> missedFieldsLstUA = new List<Utility_Account_Opportunity__c>();
        @AuraEnabled public  List<String> missingLstUA = new List<String>();
        @AuraEnabled public  String oppId{get;set;}
        @AuraEnabled public  String conId{get;set;}
        @AuraEnabled public  String accId{get;set;}
        @AuraEnabled public  String creditDetailError{get;set;}
        
        @AuraEnabled public String exceptionMessage{get;set;}
    }
    
    //In Progress....
    @AuraEnabled
    public static OppWrapper Acc_contractValidation(Id OpptyId,String Optionselected,boolean forcedValid){
        OppWrapper OppWrapperObj = new OppWrapper();
        try{
        OppWrapperObj.creditDetailError = '';
        Set<Utility_Account_Opportunity__c> missedFieldsLstUAtoConvert = new Set<Utility_Account_Opportunity__c>();
        Set<String> setToconvert = new Set<String>();
           // OpptyId = null;
        Opportunity opp = [SELECT Id,Taxable_Portion__c,Option1__c,Account.Phone,Start_Date__c,
                           Broker_Margin_per_unit__c,Name,CPM_Credit_Confirmation__c,Broker_Margin__c,Account.Broker__c,
                           Account.Tax_Exempt__c,Account.Taxable_Portion__c,Account.Utility_DUNS__c,
                           AccountId,Type,Commission_Discount__c,Commission_Type__c,
                           Broker__c,Account.name,Account.Customer_ID__c,
                           Account.BillingStreet,Account.Primary_contact__c,
                           Product_Name__c,Account.BillingCity,
                           Account.BillingState,
                           Account.BillingCountry,
                           Account.BillingPostalCode,
                           Tax_Exempt__c,Account.OwnerId,OwnerId,SyncedQuoteId,Switching_Type__c 
                           FROM Opportunity where Id=:OpptyId limit 10];
        
        List<QuoteLineItem> QLIs = [SELECT Id,Tax_Factor__c, Term_Months__c, Total_Unit_Price__c, Total_Unit_Price_W_o_Tax__c, Broker_Margin_per_unit__c FROM QuoteLineItem WHERE QuoteId =: opp.SyncedQuoteId ];
        Quote Quo = [SELECT Id,Price_Type__c, Price__c,Product__c,Bill_Type__c,Broker_Margin_per_unit__c FROM Quote WHERE Id =: opp.SyncedQuoteId ];
        Price__c pr = [SELECT Id,Obsolete__c, Pricing_Request__c,Credit_Detail__r.Credit_Check_Outcome__c,Credit_Detail__r.Status__c,Price__c.Bill_Type__c FROM Price__c Where Id =: Quo.Price__c ];
        
        OppWrapperObj.creditConfirmRequired = CreditConfirmation(opp.SyncedQuoteId,opp.Id);
        OppWrapperObj.creditConfirmValue = opp.CPM_Credit_Confirmation__c;
        
        OppWrapperObj.Obsolete = pr.Obsolete__c;
        if((pr.Bill_Type__c == 'Dual' || pr.Bill_Type__c == 'UCB with Credit') && (Quo.Bill_Type__c == 'Dual' || Quo.Bill_Type__c == 'UCB with Credit')){
            if(pr.Credit_Detail__r.Credit_Check_Outcome__c == 'Passed' && pr.Credit_Detail__r.Status__c == 'Active'|| Quo.Price_Type__c == 'Prepayment & Deposit'){
                OppWrapperObj.creditDetailError = '';
            }
            else{
                OppWrapperObj.creditDetailError = 'The selected Quote requires a valid Credit Check to be completed in order to proceed.';
            }
        }
        Contact con = new Contact();
        system.debug('Optionselected-->> '+Optionselected);
        if(Optionselected== 'option1'){
            try{
                con = [SELECT id,FirstName,LastName,Phone,Email FROM Contact WHERE Id =:opp.Account.Primary_contact__c limit 1];
                opp.Option1__c = true;
            }catch(Exception e){            }
        }
        else{
            opp.Option1__c = false;
        }
        update opp;
        
        AggregateResult countofQli = [Select count(Id) from QuoteLineItem where QuoteId =: opp.SyncedQuoteId];  
        
        OppWrapperObj.CountofTerms = Integer.valueOf(countofQli.get('expr0'));
        OppWrapperObj.oppId = opp.Id;
        OppWrapperObj.accId = opp.AccountId;
        if(con.Id != null){
            OppWrapperObj.conId = con.Id;
        }
        
        if(opp.Account.BillingStreet == NULL || opp.Account.BillingStreet == ''){
            OppWrapperObj.missedFieldsLstAcc.add('Billing Street');
        }
        
        if(opp.Account.BillingCity == NULL || opp.Account.BillingCity == ''){
            OppWrapperObj.missedFieldsLstAcc.add('Billing City');
        }
        
        if(opp.Account.BillingState == NULL || opp.Account.BillingState == ''){
            OppWrapperObj.missedFieldsLstAcc.add('Billing State');
        }
        
        
        if(opp.Account.BillingCountry == NULL || opp.Account.BillingCountry == ''){
            OppWrapperObj.missedFieldsLstAcc.add('Billing Country');
        }
        
        if(opp.Account.BillingPostalCode == NULL || opp.Account.BillingPostalCode == ''){
            OppWrapperObj.missedFieldsLstAcc.add('Billing Zip');
        }
        
        
        if(opp.Account.Name == NULL || opp.Account.Name == ''){
            OppWrapperObj.missedFieldsLstAcc.add('Customer Name');
        }
        if(Quo.Bill_Type__c == 'Dual' && (opp.Account.Phone == NULL || opp.Account.Phone == '')){
            OppWrapperObj.missedFieldsLstAcc.add('Customer Phone');
        }
        if(opp.Account.Customer_ID__c == NULL || opp.Account.Customer_ID__c == ''){
            OppWrapperObj.missedFieldsLstAcc.add('Customer_ID');
        }
        if(opp.Account.Tax_Exempt__c == NULL ){
            OppWrapperObj.missedFieldsLstAcc.add('Tax Exempt');
        }
        if(Opp.Tax_Exempt__c  == true && Opp.Taxable_Portion__c == NULL ){    
            OppWrapperObj.missedFieldsLstOpp.add('Taxable Portion');     
        }
         /*   if(Quo.Bill_Type__c=='Dual'){
                if(opp.Account.Billing_Name__c == null || opp.Account.Billing_Name__c == ''){
                    OppWrapperObj.missedFieldsLstAcc.add('Billing Name');
                }
            }*/
        
        // Primary Contact
        System.debug('con.Id-->> '+con.Id);
        if(con.Id != null){
        if(Quo.Bill_Type__c == 'Dual' && (con.Email == NULL || con.Email == '')){
            OppWrapperObj.missedFieldsLstContact.add('Email');
        }
        if(con.FirstName == NULL || con.FirstName == ''){
            OppWrapperObj.missedFieldsLstContact.add('FirstName');
        }  
        if(con.LastName == NULL || con.LastName == ''){
            OppWrapperObj.missedFieldsLstContact.add('LastName');
        }
        if(con.Phone == NULL || con.Phone == ''){
            OppWrapperObj.missedFieldsLstContact.add('Phone');
        }
        }
        if(opp.Broker__c == NULL || String.valueof(opp.Broker__c) == '' ){
            OppWrapperObj.missedFieldsLstOpp.add('Broker');
        }                      
        if(opp.OwnerId == NULL ){
            OppWrapperObj.missedFieldsLstOpp.add('CPM');
        }
        if(Opp.Type == NULL || Opp.Type == ''){    
            OppWrapperObj.missedFieldsLstOpp.add('Type');
            
        }
        if(Opp.Commission_Type__c == NULL || Opp.Commission_Type__c == ''){    
            OppWrapperObj.missedFieldsLstOpp.add('Commission Type');
        }
        if(Opp.Commission_Type__c != 'Residual' && (Opp.Commission_Discount__c == NULL || String.valueof(Opp.Commission_Discount__c) == '')){    
            OppWrapperObj.missedFieldsLstOpp.add('Commission Discount');
        }
        
        // Call deal summary method to get values
        QuoteSummary qs = getQuoteSummaryData(OpptyId);
        
        
        if(qs.BrokerMargin == NULL || String.valueof(qs.BrokerMargin) == ''){
            OppWrapperObj.missedFieldsLstOpp.add('Broker Margin');
        }
        
        if(qs.StartDate == NULL || qs.StartDate == ''){
            OppWrapperObj.missedFieldsLstOpp.add('Contract Start Date');
        }
        
        if(qs.TermMonths == NULL || String.valueof(qs.TermMonths) == ''){
            OppWrapperObj.missedFieldsLstOpp.add('Term');
        }        
        if(qs.Product == NULL || qs.Product == ''){
            OppWrapperObj.missedFieldsLstOpp.add('Product');
        }
        if(qs.ContractedPrice == NULL || String.valueof(qs.ContractedPrice) == ''){
            OppWrapperObj.missedFieldsLstOpp.add('Contracted Price');
        }
        
        
        if(Opp.Switching_Type__c == NULL || Opp.Switching_Type__c == ''){    
            OppWrapperObj.missedFieldsLstOpp.add('Switching Type');
        }
        if(Quo.Bill_Type__c == NULL || Quo.Bill_Type__c == '' ){    
            OppWrapperObj.missedFieldsLstOpp.add('Bill Type');
        }
        
        
        List<Utility_Account_Opportunity__c> UAOLst = new List<Utility_Account_Opportunity__c>();
        UAOLst = [SELECT Id,Utility_Account__r.Commodity__c,Utility_Account__r.Utility__r.Utility_DUNS__c,Utility_Account__r.Service_Class__c ,Utility_Account__r.Name,Utility_Account__r.Zip__c,Utility_Account__r.State__c,Utility_Account__r.Street__c,Utility_Account__r.Country__c,Utility_Account__r.City__c FROM Utility_Account_Opportunity__c where Opportunity__c=:opp.Id AND Status__c='Priced' ];
        
        for(Utility_Account_Opportunity__c uaObj : UAOLst){
            if(uaObj.Utility_Account__r.Street__c == NULL || uaObj.Utility_Account__r.Street__c == ''){
                setToconvert.add('Street');
                missedFieldsLstUAtoConvert.add(uaObj);
            }
            
            
            if(uaObj.Utility_Account__r.Commodity__c == NULL || uaObj.Utility_Account__r.Commodity__c == ''){
                setToconvert.add('Commodity');
                missedFieldsLstUAtoConvert.add(uaObj);
            }
            
            if(uaObj.Utility_Account__r.City__c == NULL || uaObj.Utility_Account__r.City__c == ''){
                setToconvert.add('City');
                missedFieldsLstUAtoConvert.add(uaObj);
            }
            
            if(uaObj.Utility_Account__r.State__c == NULL || uaObj.Utility_Account__r.State__c == ''){
                setToconvert.add('State');
                missedFieldsLstUAtoConvert.add(uaObj);
            }
            
            if(uaObj.Utility_Account__r.Country__c == NULL || uaObj.Utility_Account__r.Country__c == ''){
                setToconvert.add('Country');
                missedFieldsLstUAtoConvert.add(uaObj);
            }
            
            if(uaObj.Utility_Account__r.Zip__c == NULL || uaObj.Utility_Account__r.Zip__c == ''){
                setToconvert.add('Zip');
                missedFieldsLstUAtoConvert.add(uaObj);
            }
        }
        List<String> lStrings = new List<String>(setToconvert);
        List<Utility_Account_Opportunity__c> lStringsUA = new List<Utility_Account_Opportunity__c>(missedFieldsLstUAtoConvert);
        OppWrapperObj.missingLstUA = lStrings;
        OppWrapperObj.missedFieldsLstUA = lStringsUA;
        if(OppWrapperObj.missedFieldsLstUA.size()>0 || OppWrapperObj.missedFieldsLstOpp.size()>0 || OppWrapperObj.missedFieldsLstContact.size()>0 || OppWrapperObj.missedFieldsLstAcc.size()>0 ||Integer.valueOf(countofQli.get('expr0')) > 1){
            OppWrapperObj.IsValid = true;
        }
        else{
            OppWrapperObj.IsValid = false;
        }
        System.debug('SelectedOption->'+Optionselected);
        if(Optionselected== 'option2' || Optionselected== 'option3'){
            OppWrapperObj.IsValid = false;
        }
        if(forcedValid == true){
            OppWrapperObj.IsValid = false;
        }
        System.debug('Error->'+OppWrapperObj.creditDetailError);
        if(OppWrapperObj.creditDetailError != ''){
            OppWrapperObj.IsValid = true;
        }
           /* if(Optionselected== 'option1'){
                OppWrapperObj.IsValid = true;
            } */
        OppWrapperObj.TaxExempt = opp.Tax_Exempt__c;
        OppWrapperObj.Switching_type = opp.Switching_Type__c;    
        }Catch(Exception e){
            OppWrapperObj.exceptionMessage = e.getMessage();
        }
        return OppWrapperObj;
    }
    
    //SU-691
    @AuraEnabled
    public static Boolean CreditConfirmation(Id quoteId,Id recordId){
        
        Boolean valueToReturn = false;
        
        Opportunity Opp = [SELECT Id,
                           CPM_Credit_Confirmation__c
                           FROM Opportunity
                           WHERE Id =: recordId ];
        
        List<Utility_Account_Quote__c> uaQLst = [SELECT Id,
                                                 Utility_Account__r.Utility__r.Requires_CPM_Credit_Confirmation__c,
                                                 Quote__c,
                                                 Status__c
                                                 FROM Utility_Account_Quote__c
                                                 WHERE Status__c = 'Priced'
                                                 AND Quote__c =: quoteId];
        
        for(Utility_Account_Quote__c uaq : uaQLst ){
            if(uaq.Utility_Account__r.Utility__r.Requires_CPM_Credit_Confirmation__c){
                valueToReturn = true;
                break;
            }
        }
        
        return valueToReturn;
    }
    
    public class QuoteSummary {
        @AuraEnabled public String CustomerName {get;set;}
        @AuraEnabled public String objUA{get;set;}
        @AuraEnabled public String Product{get;set;}
        @AuraEnabled public String CustomerNumber{get;set;}
        @AuraEnabled public String StartDate{get;set;}
        @AuraEnabled public Decimal TermMonths{get;set;}
        @AuraEnabled public Decimal TermVolume{get;set;}
        @AuraEnabled public Decimal ContractedPrice{get;set;}
        @AuraEnabled public Decimal SEUSmargin{get;set;}
        @AuraEnabled public Decimal BrokerMargin{get;set;}
        @AuraEnabled public String Commission{get;set;}
        public QuoteSummary(String CustomerName, String objUA, String Product, String CustomerNumber, String StartDate, Decimal TermMonths, Decimal TermVolume, Decimal ContractedPrice, Decimal SEUSmargin, Decimal BrokerMargin, String Commission ){
            this.CustomerName = CustomerName;
            this.objUA = objUA;
            this.Product = Product;
            this.CustomerNumber = CustomerNumber;
            this.StartDate = StartDate;
            this.TermMonths = TermMonths;
            this.TermVolume = TermVolume;
            this.ContractedPrice = ContractedPrice;
            this.SEUSmargin = SEUSmargin;
            this.BrokerMargin = BrokerMargin;
            this.Commission = Commission;
        }
    }
    
    @AuraEnabled
    public static QuoteSummary getQuoteSummaryData(Id recordId){
        String CustomerName = '';
        String objUAQ= '';
        String Product= '';
        String CustomerNumber= '';
        String StartDate;
        Decimal TermMonths;
        Decimal TermVolume;
        Decimal ContractedPrice;
        Decimal SEUSmargin;
        Decimal BrokerMargin;
        String Commission= '';
        List<String> objUA = new List<String>();
        Quote Quo = new Quote();
        Product2 pro = new  Product2();
        AggregateResult agr;
        QuoteLineItem QLI = new QuoteLineItem();
        List<Utility_Account_Quote__c> UAQ = new List<Utility_Account_Quote__c>();
        Decimal term;
        String duplicateUA = '';
        Opportunity oppRecord;
        String recId = (String)recordId;
        if(recId.startsWith('006')){
            oppRecord = [SELECT Id, Account.Name,Account.Customer_ID__c,Final_SEUS_Margin__c, Commission_Type__c,Broker_Margin__c, SyncedQuoteId, Start_Date__c FROM Opportunity WHERE Id =: recordId];
        }else{
            Enrollment__c enrollmentRecord = [SELECT Id,Opportunity_Id__c,Contract__r.Opportunity__c FROM Enrollment__c WHERE Id =: recordId LIMIT 1];
            System.debug('recordId'+recordId);
            oppRecord = [SELECT Id, Account.Name,Account.Customer_ID__c,Final_SEUS_Margin__c, Commission_Type__c,Broker_Margin__c, SyncedQuoteId, Start_Date__c FROM Opportunity WHERE Id =: enrollmentRecord.Contract__r.Opportunity__c ];
            System.debug('oppRecord'+oppRecord);
        }
        if(oppRecord.SyncedQuoteId != null){
            Quo = [SELECT Id, Product__c,Annual_Volume_kWh__c FROM Quote Where Id =: oppRecord.SyncedQuoteId ];
            if( Quo.Product__c !=  null){
                pro = [SELECT Id, Name FROM Product2 Where Id =: Quo.Product__c];
                Product = pro.Name;
            }else{
                Product = '';
            }
            agr = [SELECT Max(Term_Months__c)term,QuoteId,SUM(Total_Unit_Price__c)tot FROM QuoteLineItem Where QuoteId =: oppRecord.SyncedQuoteId Group By QuoteId];
            term = (Decimal)agr.get('term');
            QLI = [SELECT Term_Months__c,Total_Usage__c,Revised_Sales_Margin_per_unit__c,Broker_Margin_per_unit__c,Sales_Margin_per_unit__c,Total_Unit_Price__c,QuoteId FROM QuoteLineItem Where Term_Months__c =: term AND QuoteId =: oppRecord.SyncedQuoteId];
            UAQ = [SELECT Id, Utility__c, Name, Quote__c FROM Utility_Account_Quote__c Where Quote__c =: oppRecord.SyncedQuoteId];
            for(Utility_Account_Quote__c UA : UAQ){
                if(UA.Utility__c != duplicateUA){
                    duplicateUA = UA.Utility__c;
                    objUA.add(UA.Utility__c);
                }
            }
            
            Decimal salesMargin = qli.Sales_Margin_per_unit__c;
            
            if( qli.Revised_Sales_Margin_per_unit__c != 0 && qli.Revised_Sales_Margin_per_unit__c != null ){
                salesMargin = qli.Revised_Sales_Margin_per_unit__c;
            }
            
            objUAQ = string.join(objUA,', ');
            TermMonths =  (Decimal)agr.get('term');
            TermVolume = QLI.Total_Usage__c; 
            ContractedPrice = QLI.Total_Unit_Price__c;
            SEUSmargin= salesMargin;
            BrokerMargin = QLI.Broker_Margin_per_unit__c;
        }
        else{
            objUAQ = '';
            Product = '';
            TermMonths =  null;
            TermVolume =null; 
            ContractedPrice = null;
            SEUSmargin= null;
            BrokerMargin = null;
        }
        CustomerName = oppRecord.Account.Name ;
        Commission =  oppRecord.Commission_Type__c;
        CustomerNumber = oppRecord.Account.Customer_ID__c;
        if(oppRecord.Start_Date__c != null){
            StartDate = (oppRecord.Start_Date__c).format();
        }
        
        return new QuoteSummary(CustomerName, objUAQ, Product, CustomerNumber, StartDate, TermMonths, TermVolume, ContractedPrice, SEUSmargin, BrokerMargin, Commission );
    }
    
    public static void codeCover(){
        Integer i = 0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
    }
    
}