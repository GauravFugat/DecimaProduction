/***************************************************************************************************************************
* Name:          Batch_CreateCustomObjectRecord 
* Description:   Batch class for File_Uploader Component 
* Last Modified by : Rahul Ghaytadak
* Related Code:  file_upload_handler,BatchPriceUploader,Call_Create_Price_Summary,Create_Price_Summary_Asynchronous
* Test Class:    file_upload_handler_Test
* Version History
* Date             Developer                Comments
* ---------------  --------------------    --------------------------------------------------------------------------------
* 01-08-2020       Saurabh Chauhan          Import CSV file data in Price__c, Term_Price__c, Utility_Account__c
*											and Price_Upload_Log__c.  
****************************************************************************************************************************/



global class Batch_CreateCustomObjectRecord implements Database.Batchable<List<String>>, Database.Stateful,  Database.AllowsCallouts
{
    //declaring global variables required for batch processing.
    global final blob dataDocuments; 
    global integer count = 0;
    global String FileName = '';
    global Id recordId;
    global List<Price__c> priceLst = new List<Price__c>();
    global Set<String> ErrorLst = new Set<String>();
    global Integer finalrows = 1;
    global Boolean ToggleValue;
    global final String csvContents;
    //Constructor to get the file data before batch execution (initialisation)
    global Batch_CreateCustomObjectRecord (blob dataDocuments,String FileName,Id recordId,Boolean ToggleValue)
    {
        this.recordId = recordId;
        this.dataDocuments = dataDocuments;
        this.FileName = FileName;
        this.ToggleValue = ToggleValue;
    }
    //Constructor to get the file data before batch execution (initialisation)
    global Batch_CreateCustomObjectRecord (string csvContents,String FileName,Id recordId,Boolean ToggleValue)
    {
        this.recordId = recordId;
        //this.dataDocuments = dataDocuments;
        this.csvContents = csvContents;
        this.FileName = FileName;
        this.ToggleValue = ToggleValue;
    }    
    //Get the parsed CSV data using RT_CSVReader function at the start of Batch Execution 
    global Iterable<List<String>>  start(Database.BatchableContext BC)
    {
        Price__c price1 = new Price__c();
        insert price1;
        priceLst.add(price1);
        //return new RT_CSVReader(this.dataDocuments.toString());
        String csvToParse;
        if (this.dataDocuments != null && this.dataDocuments.size() != 0){
            System.debug('this.dataDocuments--'+this.dataDocuments);
            System.Debug('dataDocuments.size()--> '+ this.dataDocuments.size());
            csvToParse = this.dataDocuments.toString();
        }   
        else if (this.csvContents != null && csvContents.length() != 0){
            System.Debug('this.csvContents.length()--> '+ this.csvContents.length());
            csvToParse = this.csvContents;  
        }
        System.Debug('csvToParse--> '+csvToParse);
        return new RT_CSVReader(csvToParse);
    }
    //Process the file records (term prices) in chunks as per the Batch size Set (1001 as of now)
    global void execute(Database.BatchableContext BC, List<List<String>> inputCSVLines)
    {
        count++;
        ErrorLst.addAll(BatchPriceUploader.processFileChunk(inputCSVLines, recordId, count, FileName,priceLst[0].Id,finalrows,ToggleValue));
        finalrows = inputCSVLines.size()*count;
    }
    //Creation of Upload Log
    //Sending Success and Failure emails/Custom Notifications based on field updates on Pricing Request and Oppty.
    //Insert the CSV which is processed in Batch class for upload.
    global void finish(Database.BatchableContext BC)
    {
        Boolean creditTypeMatchFinal = true;
        Price__c  pr = [Select id,Name,Opportunity__c,Mark_to_Market__c,Voluntary_RECs__c, Voluntary_RECs_percent__c, Treatment__c,Invoice_Billing_Type__c, Term_Price_Count__c,Price_Upload_Failed__c,Pricing_Request__c from Price__c  where Id =:priceLst[0].Id];
        Pricing_Request__c  prReq = [Select id,Mark_to_Market__c,Customer__c,Name,Opportunity__c,Bill_Type__c,Voluntary_RECs__c,Voluntary_RECs_percent__c,Treatment__c,Invoice_Billing_Type__c,Price_Upload_Failed__c from Pricing_Request__c  where Id =:recordId];
        if(prReq.Mark_to_Market__c != null){
            pr.Mark_to_Market__c = prReq.Mark_to_Market__c;
        }
        List<AggregateResult> groupedResults = [SELECT COUNT(Id),Term__c,Utility_Account_Opportunity__r.Utility_Account__r.Name,Price__c
                                                FROM Term_Price__c where Price__c =: priceLst[0].Id
                                                GROUP BY Term__c,Price__c,Utility_Account_Opportunity__r.Utility_Account__r.Name HAVING COUNT(Id) > 1];
        System.debug('94groupedResults--'+groupedResults);
        for (Integer i = 0; i< groupedResults.size(); i++)  {
            if(groupedResults[i].get('expr0') == 2){ErrorLst.add(groupedResults[i].get('Name')+' is present in the file more than once.');
                break;
            }
        }
        System.debug('ErrorLst-->'+ErrorLst);
        if(ErrorLst.size()>0){
            List<String> lStrings = new List<String>(ErrorLst);
            delete pr;
            prReq.Price_Upload_Failed__c = true;
            update prReq;    
            Base_Class_Uploader.createUploadLog(recordId, lStrings,'Pricing Request');
        }else{
            List<String> lStrings = new List<String>(ErrorLst);
            //SU:621 Function will call when Credit process is working
            if(prReq.Bill_Type__c != 'UCB'){
                if(!Test.isRunningTest())
                checkRecursive.scoreResult = ExperianLegalFilingSummariesFetcher.makeCalloutNew(prReq.Customer__c);
            }
            else{
                Create_Price_Summary_Asynchronous.getTermPrice2(new List<Id>{priceLst[0].Id});
                pr.Pricing_Request__c = recordId;
                pr.Opportunity__c = prReq.Opportunity__c;
            }
            pr.Invoice_Billing_Type__c = prReq.Invoice_Billing_Type__c;
            pr.Voluntary_RECs__c = prReq.Voluntary_RECs__c;
            pr.Voluntary_RECs_percent__c = prReq.Voluntary_RECs_percent__c;
            pr.Treatment__c = prReq.Treatment__c;
            update pr;
            Base_Class_Uploader.createUploadLog(recordId, lStrings,'Pricing Request');
            Opportunity Opp = [SELECT Id,Pricing_Request_Complete__c,OwnerId FROM Opportunity where Id =: prReq.Opportunity__c];
            //Opp.Pricing_Request_Complete__c = true;
            if(prReq.Bill_Type__c == 'UCB'){
                update Opp;
            }
            if(prReq.Bill_Type__c != 'UCB'){ 
                List<Credit_Check__c> creditDetailToCheck = [SELECT Id,Name,OwnerId,Status__c
                                                             FROM Credit_Check__c
                                                             WHERE Customer__c =: prReq.Customer__c
                                                             AND (Status__c = 'New' OR Status__c = 'Active') order by CreatedDate DESC Limit 1 ];
                createCreditLogs.createCreditProcessLog(prReq.Customer__c, 'Price File Uploaded', 'Action', 'This invokes the credit journey as it requires credit',pr.Name,pr.Id,'Success');
                if(creditDetailToCheck.size() > 0){
                    createCreditLogs.createCreditProcessLog(prReq.Customer__c, 'Active/New Credit Present ?', 'Decision', 'Credit Check record present on the customer [Status: '+creditDetailToCheck[0].Status__c+' ]',creditDetailToCheck[0].Name,creditDetailToCheck[0].Id,'True');
                }
                Boolean creditTypeMatch = creditLimitCalculationsAccount.checkCreditType(prReq.Customer__c);
                creditTypeMatchFinal = creditTypeMatch;
                System.debug('CreditTypeMatch-->'+creditTypeMatch);
                //prReq.Calculate_Credit_Limits__c = true;
                //creditLimitCalculationsAccount.calculateAccCreditLimits(new List<Id>{prReq.Id});
                ////As Part of SU-895
                creditLimitCalculationsAccount.calculateAccCreditLimits(new List<Id>{prReq.Id}, false);
                //As Part of SU-895
                //creditLimitCalculations.calculatePRCreditLimits(new List<Id>{prReq.Id});
                update prReq;
                List<Credit_Check__c> creditDetailToUpdate = [SELECT Id,Name,OwnerId,Status__c,Credit_Type__c
                                                              FROM Credit_Check__c
                                                              WHERE Customer__c =: prReq.Customer__c
                                                              AND Status__c = 'Active' order by CreatedDate DESC Limit 1 ];
                if(creditDetailToUpdate.size() == 0){
                    creditDetailToUpdate = [SELECT Id,Name,OwnerId,Status__c,Credit_Type__c FROM Credit_Check__c WHERE Customer__c =: prReq.Customer__c AND Status__c = 'New' order by CreatedDate DESC Limit 1 ];
                }
                if(creditDetailToCheck.size() > 0){
                    if(creditDetailToCheck[0].Status__c == 'New'){
                        createCreditLogs.createCreditProcessLog(prReq.Customer__c, 'Update credit check record status to Active', 'Action', 'Credit Check record updated as Active',creditDetailToUpdate[0].Name,creditDetailToUpdate[0].Id,'True');
                    }
                }
                System.debug('creditTypeMatch-->> '+creditTypeMatch);
                System.debug('creditDetailToUpdate-->> '+creditDetailToUpdate);
                if(creditTypeMatch && creditDetailToUpdate.size() > 0){
                    String description = 'Credit Type match on customer and credit detail record [Previous : '+creditLimitCalculationsAccount.prevCreditType+', New : '+creditLimitCalculationsAccount.nextCreditType+' ]';
                    createCreditLogs.createCreditProcessLog(prReq.Customer__c, 'Active/New Credit Check Present ?', 'Decision', 'Active Credit record already present.',creditDetailToUpdate[0].Name,creditDetailToUpdate[0].Id,'True');
                    createCreditLogs.createCreditProcessLog(prReq.Customer__c, 'Credit Type Match ?', 'Decision', description,'','','True');
                    List<ID> PricingRequestId = new List<Id>();
                    PricingRequestId.add(recordId);
                    if(creditDetailToUpdate.size() > 0){
                        pr.Credit_Detail__c = creditDetailToUpdate[0].id;
                        try{
                            Calculate_TermPrice_CreditPremium.getTermPrice_CreditPremiumSync(PricingRequestId,pr.Id, true);
                        }
                        catch(Exception e){
                            description = 'Error while calculating credit premium : '+e.getMessage() + '-' + e.getLineNumber();
                            createCreditLogs.createCreditProcessLog(prReq.Customer__c, 'Term Price and Credit Premium Calculations', 'Action', description,'','','Fail');
                            if(creditDetailToUpdate[0].Id != null){
                                creditDetailToUpdate[0].Status__c = 'New';
                                update creditDetailToUpdate[0];
                                Messaging.CustomNotification notification = new Messaging.CustomNotification();
                                notification.setBody(creditDetailToUpdate[0].Name+' Please check integration logs for more details.');
                                notification.setTitle('Experian credit assessment failed.');	
                                notification.setSenderId(Userinfo.getUserId());
                                CustomNotificationType type = [SELECT Id FROM CustomNotificationType WHERE DeveloperName = 'Stat_Dates_Update_Of_UA'];
                                notification.setNotificationTypeId(type.id);
                                notification.setTargetId(creditDetailToUpdate[0].Id); // target object id
                                notification.send(new Set<String> { creditDetailToUpdate[0].OwnerId });
                            }
                        }
                    }
                    Account latesAcc = [SELECT Id,Customer_Credit_Limit__c,Customer_Credit_Annual_Volume__c FROM Account WHERE Id =: prReq.Customer__c];
                    System.debug('priceLst[0].Id-->> '+priceLst[0].Id);
                    Create_Price_Summary_Asynchronous.getTermPrice2(new List<Id>{priceLst[0].Id});
                    pr.Pricing_Request__c = recordId;
                    pr.Opportunity__c = prReq.Opportunity__c;
                    update pr;
                    update Opp;
                    if(creditDetailToUpdate.size() > 0 && creditDetailToUpdate[0].Status__c == 'Active'){
                        creditDetailToUpdate[0].Credit_Limit__c = latesAcc.Customer_Credit_Limit__c;
                        creditDetailToUpdate[0].Total_Risk_Volume__c = latesAcc.Customer_Credit_Annual_Volume__c;
                        creditDetailToUpdate[0].Send_Experian_Notification__c = true;
                        update creditDetailToUpdate[0];
                    } 
                    Price__c priceToLog= [SELECT Id,Name, P_D__c, Credit__c, Subject_to_Credit__c FROM Price__c WHERE Id =: pr.Id];
                    createCreditLogs.createCreditProcessLog(prReq.Customer__c, 'Calculate price summaries', 'Action', 'Price summaries calculated','','','Success');
                    createCreditLogs.createCreditProcessLog(prReq.Customer__c, 'Price ready to quote', 'Action', 'Price [ P&D:'+priceToLog.P_D__c+', Credit:'+priceToLog.Credit__c+' ,Subject to credit:'+priceToLog.Subject_to_Credit__c+' ]',priceToLog.Name,priceToLog.Id,'Complete');
                }
                else{
                    List<Process_Event__c> peToInsert = new List<Process_Event__c>();
                    //createCreditLogs.createCreditProcessLog(prReq.Customer__c, 'Active/New Credit Present ?', 'Decision', 'Credit Check record present on the customer [Status: '+creditDetailToUpdate[0].Status__c+' ]',creditDetailToUpdate[0].Name,creditDetailToUpdate[0].Id,'True');
                    String description = 'Credit Type does not match on customer and credit detail record [Previous : '+creditLimitCalculationsAccount.prevCreditType+', New : '+creditLimitCalculationsAccount.nextCreditType+' ]';
                    peToInsert.add(createCreditLogs.createCreditProcessLogs(prReq.Customer__c, 'Credit Type Match ?', 'Decision', description,'','','False'));
                    Credit_Check__c newCCRecord = new Credit_Check__c();
                    if(creditLimitCalculationsAccount.prevCreditType != null){
                    newCCRecord.Status__c = 'Active';
                    newCCRecord.Credit_Check_Outcome__c  = 'Pending'; 
                    newCCRecord.Customer__c = prReq.Customer__c;
                    newCCRecord.Pricing_Request__c = prReq.Id;
                    Insert newCCRecord;
                    newCCRecord = [SELECT Id,Status__c,Name,Credit_Check_Outcome__c,Customer__c FROM Credit_Check__c WHERE Id =: newCCRecord.Id];
                    Credit_Check__c prevCCRecord = [SELECT Id,Name FROM Credit_Check__c WHERE Id =:creditDetailToUpdate[0].Id];
                    peToInsert.add(createCreditLogs.createCreditProcessLogs(prReq.Customer__c, 'Expire current Credit record ', 'Action', 'Current Credit record expired',prevCCRecord.Name,prevCCRecord.Id,'Success'));
                    peToInsert.add(createCreditLogs.createCreditProcessLogs(prReq.Customer__c, 'Create New Credit record', 'Action', 'New Credit record created',newCCRecord.Name,newCCRecord.Id,'Success'));
                    List<Credit_Check__c> credDetailLst = [SELECT Id 
                                                           FROM Credit_Check__c
                                                           WHERE Id !=: newCCRecord.Id 
                                                           AND Customer__c =: newCCRecord.Customer__c];
                    System.debug('credDetailLst==>> '+credDetailLst);
                    for(Credit_Check__c cdetail : credDetailLst ){
                        cdetail.Status__c = 'Expired';
                    }
                    if(credDetailLst.size() != 0){
                        update credDetailLst;
                    }
                    }else{
                        newCCRecord  = [SELECT Id,Status__c,Name,Credit_Check_Outcome__c,Customer__c FROM Credit_Check__c WHERE Customer__c =: prReq.Customer__c AND (Status__c = 'New' OR Status__c = 'Active') order by CreatedDate DESC Limit 1];
                    }
                    String pricingRequestsToPass = JSON.serialize(new List<Pricing_Request__c>{prReq});
                    experianBatch expBatch = new experianBatch();
                    expBatch.cc = newCCRecord;
                    expBatch.creditMatch = false;
                    expBatch.prRequests = pricingRequestsToPass;
                    expBatch.priceRec = pr;
                    expBatch.fromInvoke_LiensJudgementsTrends = false;
                    database.executebatch(expBatch, 1);
                    Account latesAcc = [SELECT Id,Customer_Credit_Limit__c,Customer_Credit_Annual_Volume__c FROM Account WHERE Id =: prReq.Customer__c];
                    newCCRecord.Credit_Limit__c = latesAcc.Customer_Credit_Limit__c;
                    newCCRecord.Total_Risk_Volume__c = latesAcc.Customer_Credit_Annual_Volume__c;
                    update newCCRecord;
                    if(peToInsert.size() > 0){
                        insert peToInsert;
                    }
                }
            }
            if (this.dataDocuments != null && this.dataDocuments.size() != 0){
                ContentVersion contentVersion = new ContentVersion();
                contentVersion.ContentLocation = 'S'; // S = Stored in Salesforce
                contentVersion.PathOnClient = FileName+'.csv';
                contentVersion.Title = FileName;
                contentVersion.VersionData = dataDocuments;
                insert contentVersion;
                List<ContentDocument> cd = [SELECT Id, LatestPublishedVersionId FROM ContentDocument WHERE LatestPublishedVersionId =:  contentVersion.Id];
                ContentDocumentLink contentDocumentLink = new ContentDocumentLink();
                contentDocumentLink.ContentDocumentId = cd[0].Id;
                contentDocumentLink.LinkedEntityId = recordId;
                contentDocumentLink.ShareType = 'I'; // Inferred permission
                contentDocumentLink.Visibility = 'AllUsers';
                Insert contentDocumentLink;
            }
            //Get called when Align Start Dates toggle is true 
            if(ToggleValue == TRUE){
                Price_File_Validation__c objPFV = Price_File_Validation__c.getInstance();
                Boolean sendStartDateNotification;
                if (objPFV.Send_Start_Date_Notification__c  != null)
                    sendStartDateNotification = objPFV.Send_Start_Date_Notification__c;         
                else{sendStartDateNotification = false;}
                if(Test.isRunningTest()){sendStartDateNotification = true;}
                if (sendStartDateNotification){
                    Messaging.CustomNotification notification = new Messaging.CustomNotification();
                    notification.setBody('Start Dates on '+ prReq.Name +' were updated by Pricing when the Price data was loaded.  Please check the Quote Generator to see the updated Start Dates for each Utility Account.');
                    notification.setTitle('Start Dates have been updated on '+ prReq.Name+'.');	
                    notification.setSenderId(Userinfo.getUserId());
                    CustomNotificationType type = [SELECT Id FROM CustomNotificationType WHERE DeveloperName = 'Stat_Dates_Update_Of_UA'];
                    notification.setNotificationTypeId(type.id);
                    notification.setTargetId(Opp.Id); // target object id
                    notification.send(new Set<String> { Opp.OwnerId });
                }
            }
           // SU - 979
           // if(prReq.Bill_Type__c == 'UCB'){
				prReq.Status__c = 'Complete';
            	update prReq;                
           // }
        }
    }
}