public class Invoke_LiensJudgementsTrends {
    public class wrapper_liensJudgementsTrends{
        @invocableVariable public Boolean fromPorcessBuilder;
        @invocableVariable public Id pricingRequestIds; 
        @invocableVariable public Boolean creditTypMtch;
        @invocableVariable public String prevCredType;
    }
    @invocableMethod
    //@future
    public static void liensJudgementsTrendsInvoke(List<wrapper_liensJudgementsTrends> values){
        System.debug('values-->'+values);
        // Now this apex is called from HUSystemIntegration API so no need to remove it from PB
        //Delete LineJudgementsTrends_Batch,Invoke_LinesJudgementsTrends_Updates as not used now
        Pricing_Request__c pr = [SELECT Id, Name, Bill_Type__c, Customer__c, Credit_Details__c,Credit_Details__r.Credit_Check_Outcome__c,Customer__r.Customer_Credit_Limit__c,Opportunity__c  FROM Pricing_Request__c Where Id =: values[0].pricingRequestIds];
        Credit_Check__c creditDetail = [SELECT Id, Name,Credit_Automation_Fail__c,Credit_Rank_Formula__c FROM Credit_Check__c Where Customer__c =: pr.Customer__c AND (Status__c = 'Active' OR Status__c = 'New') order by CreatedDate DESC limit 1];
        Account accRecord = [SELECT Id,Last_Successful_Experian_Legal_Filings__c FROM Account WHERE Id =: pr.Customer__c ];
        if(pr.Bill_Type__c != 'UCB'){             
            // This will be called once it's HU Completed, so we are creating below log 
            //createCreditLogs.createCreditProcessLog(pr.Customer__c, 'Process Credit from HU Data', 'Action','This invokes the credit journey as it requires credit','' ,'' ,'Success');  
            // Call LineJudgement API
            EXPRN__Exp_Business_Info__c expBusinessInfo = [SELECT Id,EXPRN__Tax_Lien_filings__c,EXPRN__Judgment_filings__c FROM EXPRN__Exp_Business_Info__c Where EXPRN__Account_Name__c =: pr.Customer__c order by CreatedDate desc limit 1];
            Boolean FromPB = false;
            FromPB = values[0].fromPorcessBuilder;
            System.debug('expBusinessInfo-->> '+expBusinessInfo.EXPRN__Tax_Lien_filings__c);
            System.debug('expBusinessInfo-->> '+expBusinessInfo.EXPRN__Judgment_filings__c);
            String DecisionReasonToPopulate = '';
            Integer lineCount = Integer.valueOf(expBusinessInfo.EXPRN__Tax_Lien_filings__c);
            integer judgeMentCount = Integer.valueOf(expBusinessInfo.EXPRN__Judgment_filings__c);
            List<Credit_Check__c> creditDetailToCheck = [SELECT Id,Name,OwnerId,Status__c,Credit_Type__c FROM Credit_Check__c
                                                         WHERE Customer__c =: pr.Customer__c AND (Status__c = 'New' OR Status__c = 'Active') order by CreatedDate DESC Limit 1 ];
            System.debug('creditDetailToCheck==>> '+creditDetailToCheck);
            if(creditDetailToCheck.size() > 0){
                createCreditLogs.createCreditProcessLog(pr.Customer__c, 'Active/New Credit Present ?', 'Decision', 'Credit Check record present on the customer [Status: '+creditDetailToCheck[0].Status__c+' ]',creditDetailToCheck[0].Name,creditDetailToCheck[0].Id,'True');
            }
            //Perform Credit Limit Calculation
            Boolean creditTypeMatch;
            String prevCredType;
            if(FromPB == true){
                creditTypeMatch = creditLimitCalculationsAccount.checkCreditType(pr.Customer__c);
                creditLimitCalculationsAccount.calculateAccCreditLimits(new list<Id>{pr.Id},true);  
            }else{
                creditTypeMatch = values[0].creditTypMtch;
                prevCredType = values[0].prevCredType;
            }
            List<Credit_Check__c> creditDetailToUpdate = [SELECT Id,Name,OwnerId,Status__c,Decision_Reason__c,Credit_Type__c FROM Credit_Check__c
                                                          WHERE Customer__c =: pr.Customer__c AND Status__c = 'Active' order by CreatedDate DESC Limit 1 ];
            Set<Id> AccIds = new Set<Id>();
            List<Utility_Account_Opportunity__c> UAO = [SELECT Id, Utility_Account__r.Utility__c , Opportunity__c, Utility_Account__c, Utility__c FROM Utility_Account_Opportunity__c Where Opportunity__c =: pr.Opportunity__c AND Status__c = 'Priced'];
            for(Utility_Account_Opportunity__c Ua : UAO){
                AccIds.add(Ua.Utility_Account__r.Utility__c );
            }
            if(creditDetailToUpdate.size() == 0){
                creditDetailToUpdate = [SELECT Id,Name,OwnerId,Status__c,Decision_Reason__c,Credit_Type__c FROM Credit_Check__c WHERE Customer__c =: pr.Customer__c AND Status__c = 'New' order by CreatedDate DESC Limit 1 ];
            }
            if(creditDetailToCheck.size() > 0){
                if(creditDetailToCheck[0].Status__c == 'New'){
                    createCreditLogs.createCreditProcessLog(pr.Customer__c, 'Update credit check record status to Active', 'Action', 'Credit Check record updated as Active',creditDetailToUpdate[0].Name,creditDetailToUpdate[0].Id,'True');
                    DecisionReasonToPopulate += 'Update credit check record status to Active';
                }
            }
            if(creditTypeMatch && creditDetailToUpdate.size() > 0 || (!creditTypeMatch && String.isEmpty(prevCredType) ) && creditDetailToUpdate.size() > 0){
                System.debug('In If');
                System.debug('pr.Customer__r.Customer_Credit_Limit__c===='+pr.Customer__r.Customer_Credit_Limit__c);
                System.debug('creditDetail.Credit_Automation_Fail__c====='+creditDetail.Credit_Automation_Fail__c);
                System.debug('pr.Credit_Details__r.Credit_Check_Outcome__c==>> '+pr.Credit_Details__r.Credit_Check_Outcome__c);
                if(pr.Credit_Details__r.Credit_Check_Outcome__c == 'Passed' && pr.Customer__r.Customer_Credit_Limit__c < 40000 && creditDetail.Credit_Automation_Fail__c == false ){
                    createCreditLogs.createCreditProcessLog(pr.Customer__c, 'Credit Outcome - Passed && Credit Limit < 40K ?', 'Decision', 'Credit Limit : $'+pr.Customer__r.Customer_Credit_Limit__c.format(),'','','True');
                    DecisionReasonToPopulate += 'Credit Outcome - Passed && Credit Limit < 40K';
                } 
                else if(pr.Credit_Details__r.Credit_Check_Outcome__c == 'Pending' && pr.Customer__r.Customer_Credit_Limit__c < 40000 && creditDetail.Credit_Automation_Fail__c == false ){
                    System.debug('in If 22');
                    if(lineCount != NULL){
                        if(checkThreshold.checkDate(accRecord.Last_Successful_Experian_Legal_Filings__c)){
                            createCreditLogs.createCreditProcessLog(pr.Customer__c, 'LegalFilingSummaries - Recency Check', 'Decision', 'New data not required [Data retrieved from Experian records]','','','False');
                        }else{
                            createCreditLogs.createCreditProcessLog(pr.Customer__c, 'LegalFilingSummaries - Recency Check', 'Decision', 'Requires new data','','','True');
                        }
                        createCreditLogs.createCreditProcessLog(pr.Customer__c, 'LegalFilingSummaries API Call', 'Action', 'lienCount='+lineCount+', judgmentCount='+judgeMentCount,'','','Success');
                        if( (lineCount + judgeMentCount) > 0 ){
                            creditDetail.Credit_Check_Outcome__c = 'Refer';
                            DecisionReasonToPopulate += 'Credit Outcome - Refer && Credit Limit < 40K && (ineCount + judgeMentCount) > 0 ';
                            pr.Status__c = 'Credit Risk Review';
                            update pr;
                            //Set 'Subject to Credit' checkbox on Price to 'TRUE'
                        }else{ creditDetail.Credit_Check_Outcome__c = 'Passed';
                            DecisionReasonToPopulate += 'Credit Outcome - Passed && Credit Limit < 40K && (ineCount + judgeMentCount) <= 0 ';
                        }
                    }
                }else if(pr.Credit_Details__r.Credit_Check_Outcome__c == 'Failed' && pr.Customer__r.Customer_Credit_Limit__c < 40000 && creditDetail.Credit_Automation_Fail__c == false ){
                    System.debug('in If 33');
                    createCreditLogs.createCreditProcessLog(pr.Customer__c, 'Credit Outcome - Failed && Credit Limit < 40K ?', 'Decision', 'Credit Limit : $'+pr.Customer__r.Customer_Credit_Limit__c.format(),'','','True');            
                    DecisionReasonToPopulate += 'Credit Outcome - Failed && Credit Limit < 40K';
                } else if(pr.Customer__r.Customer_Credit_Limit__c >= 40000 && creditDetail.Credit_Automation_Fail__c == false ){
                    System.debug('in If 44');
                    createCreditLogs.createCreditProcessLog(pr.Customer__c, 'Credit Limit >= 40K ?', 'Decision','Credit Limit : $'+pr.Customer__r.Customer_Credit_Limit__c.format(),'','','True');
                    DecisionReasonToPopulate += 'Credit Outcome - Refer && Credit Limit >= 40K';  creditDetail.Credit_Check_Outcome__c = 'Refer';  pr.Status__c = 'Credit Risk Review';  update pr;
                }
                
                update creditDetail;
                Credit_Check__c creditDetailToPass = [SELECT Id,Name,Credit_Check_Outcome__c FROM Credit_Check__c 
                                                      WHERE Id =:creditDetail.Id ];
                String description;
                if (String.isEmpty(creditLimitCalculationsAccount.prevCreditType))
                	description = 'No previous Credit Type on credit detail record [Previous : '+creditLimitCalculationsAccount.prevCreditType+', New : '+creditLimitCalculationsAccount.nextCreditType+' ]';
                else
                    description = 'Credit Type match on customer and credit detail record [Previous : '+creditLimitCalculationsAccount.prevCreditType+', New : '+creditLimitCalculationsAccount.nextCreditType+' ]';
                createCreditLogs.createCreditProcessLog(pr.Customer__c, 'Active/New Credit Check Present ?', 'Decision', 'Active Credit record already present.',creditDetailToUpdate[0].Name,creditDetailToUpdate[0].Id,'True');
                createCreditLogs.createCreditProcessLog(pr.Customer__c, 'Experian Credit Assessment', 'Decision', 'Credit Outcome :'+creditDetailToPass.Credit_Check_Outcome__c,creditDetailToPass.Name,creditDetailToPass.Id,'Completed');
                createCreditLogs.createCreditProcessLog(pr.Customer__c, 'Credit Type Match OR Previously No Credit Type ?', 'Decision', description,'','','True');
                Account latesAcc = [SELECT Id,Customer_Credit_Limit__c,Customer_Credit_Annual_Volume__c FROM Account
                                    WHERE Id =: pr.Customer__c];
                if(creditDetailToUpdate.size() > 0 && creditDetailToUpdate[0].Status__c == 'Active'){
                    creditDetailToUpdate[0].Credit_Limit__c = latesAcc.Customer_Credit_Limit__c;
                    creditDetailToUpdate[0].Total_Risk_Volume__c = latesAcc.Customer_Credit_Annual_Volume__c;
                    creditDetailToUpdate[0].Send_Experian_Notification__c = true;
                    creditDetailToUpdate[0].Decision_Reason__c = DecisionReasonToPopulate;
                    update creditDetailToUpdate[0];
                }
            }
            else{
                System.debug('In else');
                List<Process_Event__c> peToInsert = new List<Process_Event__c>();
                String description = 'Credit Type does not match on customer and credit detail record [Previous : '+creditLimitCalculationsAccount.prevCreditType+', New : '+creditLimitCalculationsAccount.nextCreditType+' ]';
                peToInsert.add(createCreditLogs.createCreditProcessLogs(pr.Customer__c, 'Credit Type Match ?', 'Decision', description,'','','False'));
                Credit_Check__c newCCRecord = new Credit_Check__c();
                if(creditLimitCalculationsAccount.prevCreditType != null){
                    newCCRecord.Status__c = 'Active';
                    newCCRecord.Credit_Check_Outcome__c  = 'Pending';
                    newCCRecord.Customer__c = pr.Customer__c;
                    newCCRecord.Pricing_Request__c = pr.Id;
                    Insert newCCRecord;
                    newCCRecord = [SELECT Id,Status__c,Name,Credit_Check_Outcome__c,Customer__c FROM Credit_Check__c WHERE Id =: newCCRecord.Id];
                    Credit_Check__c prevCCRecord = [SELECT Id,Name FROM Credit_Check__c WHERE Id =:creditDetailToUpdate[0].Id];
                    peToInsert.add(createCreditLogs.createCreditProcessLogs(pr.Customer__c, 'Expire current Credit record ', 'Action', 'Current Credit record expired',prevCCRecord.Name,prevCCRecord.Id,'Success'));
                    peToInsert.add(createCreditLogs.createCreditProcessLogs(pr.Customer__c, 'Create New Credit record', 'Action', 'New Credit record created',newCCRecord.Name,newCCRecord.Id,'Success'));
                    List<Credit_Check__c> credDetailLst = [SELECT Id  FROM Credit_Check__c
                                                           WHERE Id !=: newCCRecord.Id  AND Customer__c =: newCCRecord.Customer__c];
                    for(Credit_Check__c cdetail : credDetailLst ){
                        cdetail.Status__c = 'Expired';
                        cdetail.Experian_Api_Call_Credit_Assessment__c = false;
                    }
                    if(credDetailLst.size() != 0){
                        update credDetailLst;
                    }
                }else{/*order by CreatedDate DESC*/
                 //Credit_Check__c ccRec = [SELECT Id,Status__c,Name,Credit_Check_Outcome__c,Customer__c FROM Credit_Check__c WHERE Customer__c =: pr.Customer__c AND (Status__c = 'New' OR Status__c = 'Active') order by CreatedDate DESC Limit 1];
                    newCCRecord  = [SELECT Id,Status__c,Name,Credit_Check_Outcome__c,Customer__c FROM Credit_Check__c WHERE Customer__c =: pr.Customer__c AND (Status__c = 'New' OR Status__c = 'Active')  Limit 1];
                   // newCCRecord  = [SELECT Id,Status__c,Name,Credit_Check_Outcome__c,Customer__c FROM Credit_Check__c WHERE Id =:ccRec.Id FOR UPDATE];
                        
                }
                Opportunity Opp = [SELECT Id,Pricing_Request_Complete__c,OwnerId FROM Opportunity where Id =: pr.Opportunity__c];
                String query = 'SELECT Id, Owner.Email, Name FROM Account limit 1';
                try{
                    // commented as it was performing the same process again
                    String prJSON = '['+JSON.serialize(pr)+']';
                    System.debug('prJSON-->> '+prJSON);
                    experianBatch expBatch = new experianBatch();
                    expBatch.cc = newCCRecord;
                    expBatch.creditMatch = false;
                    expBatch.prRequests = prJSON;
                    expBatch.priceRec = null;
                    expBatch.fromInvoke_LiensJudgementsTrends = true;
                    expBatch.prCustId = pr.Customer__c;
                    database.executebatch(expBatch, 1);
                      
                }
                catch(Exception e){
                    System.debug('Error -->> ' + e.getMessage());
                    String description1 = 'Error occured: '+e.getMessage() + '-' + e.getLineNumber();
                    Credit_Check__c ccToUpdate = [SELECT Id,OwnerId,Customer__c,Name FROM Credit_Check__c WHERE Id =: newCCRecord.Id];
                    createCreditLogs.createCreditProcessLog(ccToUpdate.Customer__c, 'Error in batch', 'Action', description1,'','','');
                    if(ccToUpdate.Id != null){
                        ccToUpdate.Status__c = 'New';  update ccToUpdate;
                        Messaging.CustomNotification notification = new Messaging.CustomNotification();
                        notification.setBody(ccToUpdate.Name+' Please check integration logs for more details.');
                        notification.setTitle('Experian credit assessment failed.');	
                        notification.setSenderId(Userinfo.getUserId());
                        CustomNotificationType type = [SELECT Id FROM CustomNotificationType WHERE DeveloperName = 'Desktop_Mobile'];
                        notification.setNotificationTypeId(type.id);
                        notification.setTargetId(ccToUpdate.Id); // target object id
                        notification.send(new Set<String> { ccToUpdate.OwnerId });
                    }
                }
                //Moved this code to experian finish for row locking issue
               /* Account latesAcc = [SELECT Id,Customer_Credit_Limit__c,Customer_Credit_Annual_Volume__c FROM Account WHERE Id =: pr.Customer__c];
                newCCRecord.Credit_Limit__c = latesAcc.Customer_Credit_Limit__c;
                newCCRecord.Total_Risk_Volume__c = latesAcc.Customer_Credit_Annual_Volume__c;
                update newCCRecord; */
                if(peToInsert.size() > 0){
                    insert peToInsert;
                }
            }
        } 
    } 
    public class wrapInv{
        public String inv1 {get;set;}
        public String inv2 {get;set;}
        public String inv3 {get;set;}
        public String inv4 {get;set;}
        public String inv5 {get;set;}
        public String inv6 {get;set;}
        public String inv7 {get;set;}
        public String inv8 {get;set;}
        public String inv9 {get;set;}
        public String inv10 {get;set;}
        public String inv11 {get;set;}
        public String inv12 {get;set;}
        public String inv13 {get;set;}
        public String inv14 {get;set;}
        public String inv15 {get;set;}
    }
}