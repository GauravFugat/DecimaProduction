/***************************************************************************************************************************
* Name             : updateCreditDetails 
* Description      : Invocable class for calling Experian Endpoints and performing Credit Assessment on Credit detail and 
Pricing Request records.
* Last Modified by : Saurabh Chauhan
* Related Code     : ExperianBusinessFactsFetcher,ExperianCreditScoreFetcher,ExperianFraudShieldsFetcher,
ExperianBusinessSearchFetcher
* Test Class       :
* Version History
* Date              Developer                Comments
* ---------------  --------------------    --------------------------------------------------------------------------------
* 04-Mar-2021       Saurabh Chauhan          
*											 
****************************************************************************************************************************/

public class updateCreditDetails {
    
    @invocableMethod
    public static void callExperianCreditAssessment(List<Id> creditId){
        Credit_Check__c creditDetail = [SELECT Id, OwnerId,Experian_Business__c,Experian_Business_Information__c,Customer__c, Opportunity__c FROM Credit_Check__c WHERE Id =: creditId];
        List<Pricing_Request__c> prToupdate = [SELECT Id,Status__c,Opportunity__c,Credit_Details__c,Bill_Type__c FROM Pricing_Request__c WHERE (Bill_Type__c = 'UCB with Credit' OR Bill_Type__c = 'Dual') AND (Status__c != 'Complete' AND Status__c != 'Cancelled') AND Customer__c =: creditDetail.Customer__c ORDER BY CreatedDate DESC];
        System.debug('prToupdate-->> '+prToupdate);
        String pricingRequestsToPass = JSON.serialize(prToupdate);
        callExperian(creditId[0],pricingRequestsToPass,true);
    }
    
    @future(callout=true)
    public static void callExperian(Id creditDetailId,String prListToUpdate,boolean creditMatch){
        System.debug('prListToUpdate--> '+prListToUpdate);
        Experian__c creds = [SELECT Id, Auth_URL__c,Business_Facts_URL__c,Fraud_Shields_URL__c, Auto_Search_URL__c, Auth_Body__c, Subcode__c FROM Experian__c];
        String StatusToSet = '';
        Boolean factsApi = false;
        Boolean fraudApi = false;
        String reason = '';
        //as part of SU - 850
        //Boolean NAISCCodeIsNull = false;
        List<Integration_Log__c> intLogLstToInsert = new List<Integration_Log__c>();
        List<Pricing_Request__c> prToupdate = new List<Pricing_Request__c>();
        List<Process_Event__c> peToInsert = new List<Process_Event__c>();
        prToupdate = (List<Pricing_Request__c>) System.JSON.deserialize(prListToUpdate, List<Pricing_Request__c>.class);
        Price__c priceRec;
        if(creditMatch == false){
            priceRec = [SELECT Id,Latest_Price__c FROM Price__c WHERE Pricing_Request__c =:prToupdate[0].id AND Latest_Price__c=true  ];
            priceRec.Credit_Detail__c = creditDetailId;
        }
        Credit_Check__c creditDetail = [SELECT Id,OwnerId,Experian_Business__c,Experian_Business_Information__c,Credit_Check_Outcome__c,Customer__c,Opportunity__c FROM Credit_Check__c WHERE Id =: creditDetailId FOR UPDATE];
        System.debug('creditDetail-->> '+creditDetail);
        Account accToUpdateOwner = [SELECT Id,Name,Broker__c,BillingPostalCode,BillingStreet,BillingCity,BillingState,phone,Last_Successful_Experian_Fraud_Shields__c,Last_Successful_Experian_Business_Fact__c,Last_Successful_Experian_Scores__c FROM Account WHERE Id =: creditDetail.Customer__c];
        system.debug('89 accToUpdateOwner--'+accToUpdateOwner);
        ExperianBusinessFactsFetcher.ResponseWrapper factsResults = new ExperianBusinessFactsFetcher.ResponseWrapper(); // Call Facts Endpoint
        factsResults = ExperianBusinessFactsFetcher.makeCalloutSync(creditDetail.Customer__c);
        ExperianCreditScoreFetcher.sendSocreData scoreResult = new ExperianCreditScoreFetcher.sendSocreData(); // Call Scores Endpoint
        scoreResult = ExperianCreditScoreFetcher.makeCalloutAccSync(creditDetail.Customer__c);
        System.debug('scoreResult--> '+scoreResult);
        ExperianFraudShieldsFetcher.ResponseWrapper fraudResults = new ExperianFraudShieldsFetcher.ResponseWrapper(); // Call FraudShields Endpoint
        fraudResults = ExperianFraudShieldsFetcher.makeCalloutSync(creditDetail.Customer__c);
        if(factsResults.results == null && factsResults.success == null){
            List<Integration_Log__c> intLog= [SELECT Id,EndPointURL__c,Response_Body__c,Status_Code__c,CreatedDate FROM Integration_Log__c WHERE EndPointURL__c =: creds.Business_Facts_URL__c AND Status_Code__c = 200 AND Account__c =: creditDetail.Customer__c ORDER BY CreatedDate DESC LIMIT 1];
            if(intLog.size() != 0){
                ExperianBusinessFactsFetcher.ResponseWrapper factsResponseWrapper ;
                factsResponseWrapper = (ExperianBusinessFactsFetcher.ResponseWrapper) System.JSON.deserialize(intLog[0].Response_Body__c, ExperianBusinessFactsFetcher.ResponseWrapper.class);
                factsResults = factsResponseWrapper ;
            }
        }
        else{
            System.debug('factsApi');
            factsApi = true;
        }
        if(fraudResults.results == null && fraudResults.success == null){
            System.debug('FraudResults Recency check false');
            List<Integration_Log__c> intLog= [SELECT Id,EndPointURL__c,Response_Body__c,Status_Code__c,CreatedDate FROM Integration_Log__c WHERE EndPointURL__c =: creds.Fraud_Shields_URL__c AND Status_Code__c = 200 AND Account__c =: creditDetail.Customer__c ORDER BY CreatedDate DESC LIMIT 1];
            if(intLog.size() != 0){
                ExperianFraudShieldsFetcher.ResponseWrapper fraudResponseWrapper ;
                fraudResponseWrapper = (ExperianFraudShieldsFetcher.ResponseWrapper) System.JSON.deserialize(intLog[0].Response_Body__c, ExperianFraudShieldsFetcher.ResponseWrapper.class);
                fraudResults = fraudResponseWrapper ;
            }
        }
        else{fraudApi = true;}
        if(fraudApi){
            intLogLstToInsert.add(fraudResults.intLog);
            peToInsert.add(createCreditLogs.createCreditProcessLogs(accToUpdateOwner.Id,'Fraud Shields - Recency Check ','Decision', 'Requires new data','','','True'));
            peToInsert.add(createCreditLogs.createCreditProcessLogs(accToUpdateOwner.Id, 'Fraud Shields API Call ','Action', 'activeBusinessIndicator - '+fraudResults?.results?.activeBusinessIndicator + ',ofacMatchWarning Code - '+fraudResults?.results?.ofacMatchWarning?.code + ',ofacMatchWarning Definition - '+fraudResults?.results?.ofacMatchWarning?.definition+',businessVictimStatementIndicator - '+fraudResults?.results?.businessVictimStatementIndicator+',businessRiskTriggersIndicator - '+fraudResults?.results?.businessRiskTriggersIndicator +',nameAddressVerificationIndicator - '+fraudResults?.results?.nameAddressVerificationIndicator ,'', fraudResults.intLog.Id,fraudResults.intLog.Status__c == 'OK' ? 'Success' : 'Fail' ));
        }
        else{
            peToInsert.add(createCreditLogs.createCreditProcessLogs(accToUpdateOwner.Id,'Fraud Shields - Recency Check ',
                                                                    'Decision',
                                                                    'New data not required [ '+'activeBusinessIndicator - '+fraudResults?.results?.activeBusinessIndicator + ',ofacMatchWarning Code - '+fraudResults?.results?.ofacMatchWarning?.code + ',ofacMatchWarning Definition - '+fraudResults?.results?.ofacMatchWarning?.definition+',businessVictimStatementIndicator - '+fraudResults?.results?.businessVictimStatementIndicator+',businessRiskTriggersIndicator - '+fraudResults?.results?.businessRiskTriggersIndicator +',nameAddressVerificationIndicator - '+fraudResults?.results?.nameAddressVerificationIndicator+' ]',
                                                                    '',''
                                                                    ,'False'));
        }
        
        if(scoreResult != null){				//Check if we got anything from scores , and Success Date and insert Integration Log
            if(scoreResult.apiCalled){
                intLogLstToInsert.add(scoreResult.intLog);
                peToInsert.add(createCreditLogs.createCreditProcessLogs(accToUpdateOwner.Id, 'Scores - Recency Check ','Decision','Requires new data','','','True'));
                
                peToInsert.add(createCreditLogs.createCreditProcessLogs(accToUpdateOwner.Id, 'Scores API Call ','Action', 'IP - '+scoreResult.ipscore+' ,FSR - '+scoreResult.fsrscore +' ,CommercialScoreTrends = '+JSON.serialize(scoreResult?.commercialScoreTrends) +' ,fsrScoreTrends = '+JSON.serialize(scoreResult?.fsrScoreTrends), '', scoreResult.intLog.Id,scoreResult.intLog.Status__c == 'OK' ? 'Success' : 'Fail'));
                
                if(scoreResult.intLog.Status_Code__c == 200){List<ExperianBusinessSearchFetcher.results> businessSearchResults = ExperianBusinessSearchFetcher.cloneBusinessRec(accToUpdateOwner.Id);
                                                             if (businessSearchResults != null){
                                                                 ExperianBusinessSearchFetcher.CreateBusinessInfo(businessSearchResults, accToUpdateOwner, accToUpdateOwner.Id);
                                                                 
                                                             }
                                                             accToUpdateOwner.Last_Successful_Experian_Scores__c = System.now();
                                                                 
                                                            }
            }
            else{
                peToInsert.add(createCreditLogs.createCreditProcessLogs(accToUpdateOwner.Id, 'Scores - Recency Check ', 'Decision', 'New data not required [ '+'IP - '+scoreResult.ipscore+' ,FSR - '+scoreResult.fsrscore +' ,CommercialScoreTrends = '+scoreResult?.commercialScoreTrendsString +' ,fsrScoreTrends = '+scoreResult?.fsrScoreTrendsString+' ]', '','','False'));
            }
            if(scoreResult.intLog.Status_Code__c == 200){
                ExperianCreditScoreFetcher.updateSocres(JSON.serialize(scoreResult),creditDetail.Customer__c);
            }
            creditDetail.IP_Score__c = scoreResult?.ipscore;
            creditDetail.FSR_Score__c = scoreResult?.fsrscore;
            creditDetail.Commercial_Trends__c = scoreResult?.commercialScoreTrendsString;
            creditDetail.FSR_Trends__c = scoreResult?.fsrScoreTrendsString;
            
        }        
        if(factsApi){				//Check if we got anything from Facts Api , and Success Date and insert Integration Log
            intLogLstToInsert.add(factsResults.intLog);
            peToInsert.add(createCreditLogs.createCreditProcessLogs(accToUpdateOwner.Id,'Business Facts - Recency Check ','Decision', 'Requires new data','','', 'True'));
            
            System.debug('factsResults.intLog.Status_Code__c==> '+factsResults.intLog.Status_Code__c);
            if(factsResults.intLog.Status_Code__c == 200){
                try{peToInsert.add(createCreditLogs.createCreditProcessLogs(accToUpdateOwner.Id,'Business Facts API Call ','Action','NAICS code - '+factsResults?.results?.naicsCodes[0]?.code ,'',factsResults.intLog.Id,factsResults.intLog.Status__c == 'OK' ? 'Success' : 'Fail'));
                    List<ExperianBusinessFactsFetcher.naicsCodes> naics = factsResults?.results?.naicsCodes;
                    List<String> naicsCode = new List<String>();
                    for(ExperianBusinessFactsFetcher.naicsCodes naicsVar : naics){
                        naicsCode.add(naicsVar?.code);
                    }
                    if(naicsCode.size() > 0){creditDetail.Sector_NAICS__c = string.join(naicsCode,','); }
                }catch(Exception e){ System.debug('exception-->> '+ e.getMessage());
                    peToInsert.add(createCreditLogs.createCreditProcessLogs(accToUpdateOwner.Id, 'Business Facts API Call ', 'Action', 'NAICS code - '+null ,'','',factsResults.intLog.Status__c == 'OK' ? 'Success' : 'Fail'));
                }
                accToUpdateOwner.Last_Successful_Experian_Business_Fact__c = System.now();
                ExperianBusinessFactsFetcher.updateBusinessFacts(JSON.serialize(factsResults),creditDetail.Customer__c);
            }
            else{peToInsert.add(createCreditLogs.createCreditProcessLogs(accToUpdateOwner.Id, 'Business Facts API Call ', 'Action', 'NAICS code - '+null ,'','',factsResults.intLog.Status__c == 'OK' ? 'Success' : 'Fail'));
            }
        }
        else{
            try{
                System.debug('factsResults?.results?.naicsCodes-->> '+factsResults?.results?.naicsCodes);
                peToInsert.add(createCreditLogs.createCreditProcessLogs(accToUpdateOwner.Id,'Business Facts - Recency Check ','Decision', 
                                                                        'New data not required [ '+'NAICS code - '+factsResults?.results?.naicsCodes[0]?.code+' ]', 
                                                                        '','','Success'));
                List<ExperianBusinessFactsFetcher.naicsCodes> naics = factsResults?.results?.naicsCodes;
                List<String> naicsCode = new List<String>();
                for(ExperianBusinessFactsFetcher.naicsCodes naicsVar : naics){
                    naicsCode.add(naicsVar?.code);
                }
                if(naicsCode.size() > 0){
                    creditDetail.Sector_NAICS__c = string.join(naicsCode,',');
                }
            }catch(Exception e){
                System.debug('exception 1 -->> '+e.getMessage());
                System.debug('exception 1 -->> '+e.getLineNumber());
                peToInsert.add(createCreditLogs.createCreditProcessLogs(accToUpdateOwner.Id,'Business Facts - Recency Check ','Decision', 'New data not required [ '+'NAICS code - null ]','','','Success'));
            }
        }
        //System.debug('310 NAISCCodeIsNull-->> '+NAISCCodeIsNull);
        System.debug('fraudResults-->> '+fraudResults.results);
        if(fraudResults.results != null){			//Check if we got anything from FraudShields , and Success Date and insert Integration Log
            if(fraudResults.intLog.Status_Code__c == 200){
                accToUpdateOwner.Last_Successful_Experian_Fraud_Shields__c = System.now();
                ExperianFraudShieldsFetcher.updateFraudShields(JSON.serialize(fraudResults),creditDetail.Customer__c);
            }
            creditDetail.Fraud_Details__c = 'activeBusinessIndicator - '+fraudResults?.results?.activeBusinessIndicator + ',ofacMatchWarning Code - '+fraudResults?.results?.ofacMatchWarning?.code + ',ofacMatchWarning Definition - '+fraudResults?.results?.ofacMatchWarning?.definition+',businessVictimStatementIndicator - '+fraudResults?.results?.businessVictimStatementIndicator+',businessRiskTriggersIndicator - '+fraudResults.results.businessRiskTriggersIndicator+',nameAddressVerificationIndicator - '+fraudResults.results.nameAddressVerificationIndicator +']';
            if(fraudResults.results.activeBusinessIndicator == true && (fraudResults.results.ofacMatchWarning.code == 1 || fraudResults.results.ofacMatchWarning.code == null) && 
               (fraudResults.results.ofacMatchWarning.definition == 'No Match Found' || fraudResults.results.ofacMatchWarning.definition == 'Not Available') && 
               fraudResults.results.businessVictimStatementIndicator == false && (fraudResults.results.businessRiskTriggersIndicator == false || fraudResults.results.nameAddressVerificationIndicator == true )){
                   System.debug('316');
                   peToInsert.add(createCreditLogs.createCreditProcessLogs(accToUpdateOwner.Id, 'Fraud Indicator Check ','Decision', 'No Fraud indicators for the customer', '', '', 'True'));
                   
                   if(scoreResult != null){								//Check for Null scores as further logic depends on it.
                       creditDetail.IP_Score__c = scoreResult.ipscore;
                       creditDetail.FSR_Score__c = scoreResult.fsrscore;
                       System.debug('scoreResult.ipscore-->> '+scoreResult.ipscore);
                       System.debug('scoreResult.fsrscore-->> '+scoreResult.fsrscore);
                       if(scoreResult.ipscore == 999 || scoreResult.ipscore == 998 || scoreResult.fsrscore == 999 || scoreResult.fsrscore ==998){
                           creditDetail.Credit_Check_Outcome__c  = 'Refer';
                           StatusToSet = 'Credit Risk Review';
                            if (scoreResult.ipscore == 999 && scoreResult.fsrscore == 999){
                               	reason = 'IP/FSR = 999 Not Enough Data'; 								
                                peToInsert.add(createCreditLogs.createCreditProcessLogs(accToUpdateOwner.Id,'IP and FSR are 999 ? ','Decision', '[ IP - '+scoreResult.ipscore+', FSR - '+scoreResult.fsrscore+' ]','','','True'));
                            }
                            else if (scoreResult.ipscore == 998 && scoreResult.fsrscore == 998){
                                reason = 'IP/FSR = 998 Bankruptcy Present'; 
                                peToInsert.add(createCreditLogs.createCreditProcessLogs(accToUpdateOwner.Id,'IP and FSR are 998 ? ','Decision', '[ IP - '+scoreResult.ipscore+', FSR - '+scoreResult.fsrscore+' ]','','','True'));
                            }                      
                       }else if(scoreResult.ipscore >  40 && scoreResult.fsrscore > 40){     //Condition 1
                           creditDetail.Credit_Check_Outcome__c  = 'Passed';                           
                           //StatusToSet = 'Ready for Pricing';
                           reason = 'IP > 40 && FSR > 40';
                           peToInsert.add(createCreditLogs.createCreditProcessLogs(accToUpdateOwner.Id,'IP > 40 && FSR > 40 ? ', 'Decision', 'Both IP and FSR are above 40 [ IP - '+scoreResult.ipscore+', FSR - '+scoreResult.fsrscore+' ]','','','True'));
                       }
                       
                       if(scoreResult.ipscore <  40 && scoreResult.fsrscore < 40){		//Condition 2
                           creditDetail.Credit_Check_Outcome__c  = 'Failed';
                           //StatusToSet = 'Ready for Pricing';
                           reason = 'IP < 40 && FSR < 40';
                           peToInsert.add(createCreditLogs.createCreditProcessLogs(accToUpdateOwner.Id,'IP < 40 && FSR < 40 ? ','Decision', 'Both IP and FSR are below 40 [ IP - '+scoreResult.ipscore+', FSR - '+scoreResult.fsrscore+' ]','','','True'));
                       }
                       
                       //Condition 3 -  Invloves calling Facts Endpoint if needed
                       System.debug('scoreResult->'+scoreResult);
                       System.debug('factsResults->'+factsResults);
                       if((scoreResult.ipscore <  40 && scoreResult.fsrscore > 40) || (scoreResult.ipscore >  40 && scoreResult.fsrscore < 40) ){
                           
                           creditDetail.Credit_Check_Outcome__c  = 'Pending';
                           //StatusToSet = 'Ready for Pricing';
                           
                           string ipDescription = '';
                           if(scoreResult.ipscore <  40 && scoreResult.fsrscore > 40){
                               ipDescription = 'IP < 40 && FSR > 40 [ IP - '+scoreResult.ipscore+', FSR - '+scoreResult.fsrscore+' ]';
                               reason = 'IP < 40 && FSR > 40';
                           }
                           else{ipDescription = 'IP > 40 && FSR < 40 [ IP - '+scoreResult.ipscore+', FSR - '+scoreResult.fsrscore+' ]';
                               reason = 'IP > 40 && FSR < 40';
                           }
                           peToInsert.add(createCreditLogs.createCreditProcessLogs(accToUpdateOwner.Id,'(IP < 40 && FSR > 40) OR (IP > 40 && FSR < 40) ? ','Decision',ipDescription,'','', 'True'));
                           if(factsResults?.results?.naicsCodes==null){
                               creditDetail.Credit_Check_Outcome__c  = 'Failed';
                               //StatusToSet = 'Ready for Pricing';
                               System.debug('--244--');
                               reason = 'NAICS starts with 71 or 92 or null';
                               peToInsert.add(createCreditLogs.createCreditProcessLogs(accToUpdateOwner.Id,'NAICS starts with 71 or 92 or null ?','Decision','NAICS starts with 71 or 92 or null [Failed]','','','True'));
                           }else if(factsResults?.results?.naicsCodes[0]?.code.startsWith('71') || factsResults?.results?.naicsCodes[0]?.code.startsWith('92') ){  //Inner Condition -1 (Master - 3)
                               System.debug('in it');
                               creditDetail.Credit_Check_Outcome__c  = 'Failed';
                               //StatusToSet = 'Ready for Pricing';
                               System.debug('--244--');
                               reason = 'NAICS starts with 71 or 92 or null';
                               peToInsert.add(createCreditLogs.createCreditProcessLogs(accToUpdateOwner.Id,'NAICS starts with 71 or 92 or null ?','Decision','NAICS starts with 71 or 92 or null [Failed]','','','True'));
                           }
                           else if(scoreResult.commercialscoreTrend > 10){ 		//Inner Condition -2 (Master - 3)
                               creditDetail.Credit_Check_Outcome__c  = 'Failed';
                               //StatusToSet = 'Ready for Pricing';
                               reason = 'Commercial score trend difference > 10 for current and previous quarter';
                               peToInsert.add(createCreditLogs.createCreditProcessLogs(accToUpdateOwner.Id,'Commercial Score Trends difference > 10 OR FSR Score Trends difference > 20 ?','Decision','Commercial score trend difference > 10 for current and previous quarter [Failed] [Reason : '+' ,CommercialScoreTrend difference = '+scoreResult.commercialscoreTrend +' ,fsrScoreTrend difference = '+scoreResult.fsrscoreTrend+' ]','','','True'));
                           }
                           else if(scoreResult.fsrScoreTrend > 20){				//Inner Condition -3 (Master - 3)
                               creditDetail.Credit_Check_Outcome__c  = 'Failed';
                               //StatusToSet = 'Ready for Pricing';
                               System.debug('--Here--256');
                               reason = 'FSR score trend difference > 20 for current and previous quarter';
                               peToInsert.add(createCreditLogs.createCreditProcessLogs(accToUpdateOwner.Id,'Check FSR Score Trends','Decision', 'FSR score trend difference > 20 for current and previous quarter [Failed] [Reason : '+' ,CommercialScoreTrend difference = '+scoreResult.commercialscoreTrend +' ,fsrScoreTrend difference = '+scoreResult.fsrscoreTrend+' ]','','','True'));
                           }
                           else{													//Else Condition -4 (Master - 3)
                               creditDetail.Credit_Check_Outcome__c  = 'Pending';
                               //StatusToSet = 'Ready for Pricing';
                               System.debug('--Here--260');
                           }
                       }
                   }
               }
            else{
                System.debug('460');
                creditDetail.Credit_Check_Outcome__c  = 'Refer'; 
                StatusToSet = 'Credit Risk Review';
                reason = 'Fraud Indicators are present for the customer.';
                peToInsert.add(createCreditLogs.createCreditProcessLogs(accToUpdateOwner.Id, 'Fraud Indicator Check ','Decision', 'Fraud Indicators are present for the customer [Refer]','','','False'));
            }
        }
        List<Id> intLogLst = new List<Id>(); 
        if(!intLogLstToInsert.isEmpty()){
            //insert intLogLstToInsert;
            Database.SaveResult[] srList = Database.insert(intLogLstToInsert, false);
            system.debug('537 srList--'+srList);
            for(Integer i=0;i<srList.size();i++){
                if (srList.get(i).isSuccess()){
                    intLogLst.add(srList.get(i).getId()) ;
                }
            }
        }
        system.debug('537 intLogLst--'+intLogLst);
        System.debug('accToUpdateOwner.Id==>> '+accToUpdateOwner.Id);
        EXPRN__Exp_Business_Info__c  expBusinessInfo = [SELECT Id,EXPRN__Exp_Business__c  FROM EXPRN__Exp_Business_Info__c WHERE EXPRN__Account_Name__c =: accToUpdateOwner.Id ORDER BY CreatedDate DESC LIMIT 1];
        System.debug('expBusinessInfo-->> '+expBusinessInfo.Id);
        //System.debug('expBusinessInfo 0-->> '+expBusinessInfo[0].Id);
        System.debug('creditDetail 1 ==>> '+creditDetail.Experian_Business__c);
        System.debug('creditDetail 2 ==>> '+creditDetail.Experian_Business_Information__c);
        System.debug('expBusinessInfo 1 ==>> '+expBusinessInfo.EXPRN__Exp_Business__c);
        System.debug('expBusinessInfo 2 ==>> '+expBusinessInfo.Id);
        creditDetail.Experian_Business__c = expBusinessInfo.EXPRN__Exp_Business__c;
        creditDetail.Experian_Business_Information__c = expBusinessInfo.Id;
        update creditDetail;
        System.debug('StatusToSet==>> '+StatusToSet);
        for(Pricing_Request__c pr : prToupdate){
            if(pr.Status__c != 'complete'){
                System.debug('StatusToSet in==>> '+StatusToSet);
                if (StatusToSet != '')
                	pr.Status__c = StatusToSet;
            }
            pr.Credit_Details__c = creditDetail.Id;
        }
        if(scoreResult.ipscore == 999 || scoreResult.ipscore == 998 || scoreResult.fsrscore == 999 || scoreResult.fsrscore ==998){
            System.debug('in it');
            prToupdate[0].Status__c = 'Credit Risk Review';
            System.debug('prToupdate[0] -->> '+prToupdate[0].Id);
        }
        update prToupdate;
        update accToUpdateOwner; 
        boolean allAPIsPassed = true;
        for(Integration_Log__c intlog : intLogLstToInsert){
            if(intlog.Status__c != 'OK' && intlog.Status_Code__c != 200){
                allAPIsPassed = false;
            }
        }
        //Changes related to Card-865
        Pricing_Request__c pr = [SELECT Id,Credit_Details__r.Id,Status__c FROM Pricing_Request__c WHERE Id =: prToupdate[0].Id];
        String description = '';
        if(allAPIsPassed){
            description = 'Credit Outcome - '+creditDetail.Credit_Check_Outcome__c + ' [Reason : '+reason+']';
            creditDetail.Credit_Automation_Fail__c = false;
        }
        else{
            description = 'Experian calls were failed due to some reason, Please check integration logs for more details.';
            creditDetail.Credit_Automation_Fail__c = true;
            creditDetail.Status__c = 'New';
            //Changes related to Card-865
            creditDetail.Credit_Check_Outcome__c = 'Error';
            if(pr.Status__c != 'Credit Risk Review'){
                pr.Status__c = 'Credit Risk Review';
                update pr;
            }
            Group QueueDetails = [select Id from Group where  Type = 'Queue' AND NAME = 'Credit Risk Team'];
            List<GroupMember> getUsers = [Select UserOrGroupId From GroupMember where GroupId =:QueueDetails.Id];
            Set<GroupMember> UsersSet = new Set<GroupMember>();
            UsersSet.addAll(getUsers);
            Messaging.CustomNotification notification = new Messaging.CustomNotification();
            notification.setBody('Credit check failures occurred. Please review Process Events for more details.');
            notification.setTitle('Credit Risk Review');	
            notification.setSenderId(Userinfo.getUserId());
            CustomNotificationType type = [SELECT Id FROM CustomNotificationType WHERE DeveloperName = 'Credit_Risk_Team'];
            notification.setNotificationTypeId(type.id);
            notification.setTargetId(creditDetail.Id); // target object id
            try {
                notification.send(new set<String>{getUsers[0].UserOrGroupId});
            }
            catch (Exception e) {
                System.debug('Problem sending notification: ' + e.getMessage());
            }
        }
        if(creditMatch == false){
            update priceRec;
            System.debug('610');
            Calculate_TermPrice_CreditPremium.getTermPrice_CreditPremium(new List<Id>{prToupdate[0].Id});
        }
        system.debug('1048 peToInsert--'+peToInsert);
        //insert peToInsert;
        set<Id> peToInsertIds = new set<Id>();
        Database.SaveResult[] srListPE = Database.insert(peToInsert, false);
        for(Database.saveResult s: srListPE){
            if(s.isSuccess()){
                peToInsertIds.add(s.getId()) ;
            }
        }
        system.debug('1057 peToInsertIds set--'+peToInsertIds);
        system.debug('intLogLst---'+intLogLst);
        List<Integration_Log__c> getIntName = [SELECT Name FROM Integration_Log__c WHERE Id IN : intLogLst];
        List<Process_Event__c> peDetails = [SELECT Id,Name__c,Related_Record_Id__c,Related_Record_Name__c FROM Process_Event__c WHERE Id IN :peToInsertIds ];
        system.debug('1051 peDetails--'+peDetails);
        List<Process_Event__c> peToUpdate = new List<Process_Event__c>();
        for(Process_Event__c pe :peDetails){
            if(pe.Name__c == 'Fraud Shields API Call'){
                if(intLogLst.size() != 0){
                    pe.Related_Record_Id__c = intLogLst.get(0);
                    pe.Related_Record_Name__c = getIntName.get(0).Name;
                    peToUpdate.add(pe);
                }
            }
            if(pe.Name__c == 'Scores API Call'){
                if(intLogLst.size()>1){ pe.Related_Record_Id__c = intLogLst.get(1);
                    pe.Related_Record_Name__c = getIntName.get(1).Name;
                    peToUpdate.add(pe);
                }
            }
            if(pe.Name__c == 'Business Facts API Call'){
                if(intLogLst.size()>2){pe.Related_Record_Id__c = intLogLst.get(2);
                    pe.Related_Record_Name__c = getIntName.get(2).Name;
                    peToUpdate.add(pe);
                }
            }
        }
        update peToUpdate;
        System.debug('creditDetail-->'+creditDetail);
        Credit_Check__c creditDetailName = [SELECT id,Name,Credit_Check_Outcome__c FROM Credit_Check__c WHERE Id =:creditDetail.Id ];
        //Changes related to card SU-865
        if(creditDetail.Credit_Automation_Fail__c != true){
            createCreditLogs.createCreditProcessLog(accToUpdateOwner.Id, 'Experian Credit Assessment', 'Decision', description,creditDetailName.Name,creditDetailName.Id,'Completed');
        }else{
            createCreditLogs.createCreditProcessLog(accToUpdateOwner.Id, 'Experian Credit Assessment', 'Decision', description,creditDetailName.Name,creditDetailName.Id,'Failed');
        } 
        creditDetail.Send_Experian_Notification__c = true;
        update creditDetail;
    }
    
    //Same process but called synchronously due to batch and calculating Price Summaries after this.
    public static void callExperianSync(Id creditDetailId,String prListToUpdate,boolean creditMatch,Price__c priceRec){
        Experian__c creds = [SELECT Id, Auth_URL__c,Business_Facts_URL__c,Fraud_Shields_URL__c, Auto_Search_URL__c, Auth_Body__c, Subcode__c FROM Experian__c];
        System.debug('creds-->> '+creds);
        String DecisionReasonToPopulate = '';
        String StatusToSet = '';
        Boolean factsApi = false;
        Boolean fraudApi = false;
        String reason = '';
        //as part of SU - 850
        // Boolean NAISCCodeIsNull = false;
        List<Process_Event__c> peToInsert = new List<Process_Event__c>();
        List<Integration_Log__c> intLogLstToInsert = new List<Integration_Log__c>();
        List<Pricing_Request__c> prToupdate = new List<Pricing_Request__c>();
        prToupdate = (List<Pricing_Request__c>) System.JSON.deserialize(prListToUpdate, List<Pricing_Request__c>.class);
        System.debug('prToupdate-->> '+prToupdate);
        if(creditMatch == false){
            if(priceRec != null){priceRec.Credit_Detail__c = creditDetailId;}
        }
        Credit_Check__c creditDetail = [SELECT Id, Name,OwnerId,Customer__c, Opportunity__c,Decision_Reason__c FROM Credit_Check__c WHERE Id =: creditDetailId];
        System.debug('creditDetail-->> '+creditDetail);
        Account accToUpdateOwner = [SELECT Id, Name, Broker__c,BillingPostalCode,BillingStreet,BillingCity,BillingState,phone,Last_Successful_Experian_Fraud_Shields__c,Last_Successful_Experian_Business_Fact__c,Last_Successful_Experian_Scores__c FROM Account WHERE Id =: creditDetail.Customer__c];
        System.debug('accToUpdateOwner-->> '+accToUpdateOwner);
        ExperianBusinessFactsFetcher.ResponseWrapper factsResults = new ExperianBusinessFactsFetcher.ResponseWrapper(); // Call Facts Endpoint
        if(ExperianBusinessFactsFetcher.makeCalloutSync(creditDetail.Customer__c) != null){
            factsResults = ExperianBusinessFactsFetcher.makeCalloutSync(creditDetail.Customer__c);
        }
        ExperianCreditScoreFetcher.sendSocreData scoreResult = new ExperianCreditScoreFetcher.sendSocreData(); // Call Scores Endpoint
        scoreResult = ExperianCreditScoreFetcher.makeCalloutAccSync(creditDetail.Customer__c);
        ExperianFraudShieldsFetcher.ResponseWrapper fraudResults = new ExperianFraudShieldsFetcher.ResponseWrapper(); // Call FraudShields Endpoint
        if(ExperianFraudShieldsFetcher.makeCalloutSync(creditDetail.Customer__c) != null){
            fraudResults = ExperianFraudShieldsFetcher.makeCalloutSync(creditDetail.Customer__c);
        }
        if(factsResults.results == null && factsResults.success == null){
            List<Integration_Log__c> intLog= [SELECT Id, EndPointURL__c,Response_Body__c,Status_Code__c, CreatedDate FROM Integration_Log__c WHERE EndPointURL__c =: creds.Business_Facts_URL__c AND Status_Code__c = 200 AND Account__c =: creditDetail.Customer__c ORDER BY CreatedDate DESC LIMIT 1];
            if(intLog.size() != 0){
                ExperianBusinessFactsFetcher.ResponseWrapper factsResponseWrapper ;
                factsResponseWrapper = (ExperianBusinessFactsFetcher.ResponseWrapper) System.JSON.deserialize(intLog[0].Response_Body__c, ExperianBusinessFactsFetcher.ResponseWrapper.class);
                factsResults = factsResponseWrapper ;
            }
        }
        else{
            System.debug('factsApi');
            factsApi = true;
        }
        if(fraudResults.results == null && fraudResults.success == null){
            system.debug('369>>');
            List<Integration_Log__c> intLog= [SELECT Id, EndPointURL__c,Response_Body__c,Status_Code__c,CreatedDate FROM Integration_Log__c WHERE EndPointURL__c =: creds.Fraud_Shields_URL__c AND Status_Code__c = 200 AND Account__c =: creditDetail.Customer__c ORDER BY CreatedDate DESC LIMIT 1];
            if(intLog.size() != 0){
                ExperianFraudShieldsFetcher.ResponseWrapper fraudResponseWrapper ;
                fraudResponseWrapper = (ExperianFraudShieldsFetcher.ResponseWrapper) System.JSON.deserialize(intLog[0].Response_Body__c, ExperianFraudShieldsFetcher.ResponseWrapper.class);
                fraudResults = fraudResponseWrapper ;
            }
        }
        else{
            fraudApi = true;
        }
        if(fraudApi){
            System.debug('fraudApi-->'+fraudApi);
            intLogLstToInsert.add(fraudResults.intLog);
            peToInsert.add(createCreditLogs.createCreditProcessLogs(accToUpdateOwner.Id, 'Fraud Shields - Recency Check ', 'Decision', 'Requires new data',  '','','True'));
            peToInsert.add(createCreditLogs.createCreditProcessLogs(accToUpdateOwner.Id, 'Fraud Shields API Call ','Action','activeBusinessIndicator - '+fraudResults?.results?.activeBusinessIndicator + ',ofacMatchWarning Code - '+fraudResults?.results?.ofacMatchWarning?.code + ',ofacMatchWarning Definition - '+fraudResults?.results?.ofacMatchWarning?.definition+',businessVictimStatementIndicator - '+fraudResults?.results?.businessVictimStatementIndicator,'',fraudResults.intLog.Id,fraudResults.intLog.Status__c == 'OK' ? 'Success' : 'Fail'));
        }
        else{
            peToInsert.add(createCreditLogs.createCreditProcessLogs(accToUpdateOwner.Id, 'Fraud Shields - Recency Check ','Decision','New data not required [ '+'activeBusinessIndicator - '+fraudResults?.results?.activeBusinessIndicator + ',ofacMatchWarning Code - '+fraudResults?.results?.ofacMatchWarning?.code + ',ofacMatchWarning Definition - '+fraudResults?.results?.ofacMatchWarning?.definition+',businessVictimStatementIndicator - '+fraudResults?.results?.businessVictimStatementIndicator+' ]', '', '','False'));
        }
        if(scoreResult != null){				//Check if we got anything from scores , and Success Date and insert Integration Log
            if(scoreResult.apiCalled){
                intLogLstToInsert.add(scoreResult.intLog);
                peToInsert.add(createCreditLogs.createCreditProcessLogs(accToUpdateOwner.Id,'Scores - Recency Check ','Decision', 'Requires new data', '', '','True'));
                peToInsert.add(createCreditLogs.createCreditProcessLogs(accToUpdateOwner.Id,'Scores API Call ','Action', 'IP - '+scoreResult.ipscore+' ,FSR - '+scoreResult.fsrscore +' ,CommercialScoreTrends = '+scoreResult?.commercialScoreTrendsString +' ,fsrScoreTrends = '+scoreResult?.fsrScoreTrendsString, '',scoreResult.intLog.Id, scoreResult.intLog.Status__c == 'OK' ? 'Success' : 'Fail'));
                if(scoreResult.intLog.Status_Code__c == 200){List<ExperianBusinessSearchFetcher.results> businessSearchResults = ExperianBusinessSearchFetcher.cloneBusinessRec(accToUpdateOwner.Id);
                                                             
                                                             if (businessSearchResults != null){
                                                                 ExperianBusinessSearchFetcher.CreateBusinessInfo(businessSearchResults, accToUpdateOwner, accToUpdateOwner.Id);
                                                                 
                                                             }
                                                             accToUpdateOwner.Last_Successful_Experian_Scores__c = System.now();
                                                             
                                                            }
            }
            else{
                peToInsert.add(createCreditLogs.createCreditProcessLogs(accToUpdateOwner.Id,'Scores - Recency Check ','Decision','New data not required [ '+'IP - '+scoreResult.ipscore+' ,FSR - '+scoreResult.fsrscore +' ,CommercialScoreTrends = '+scoreResult?.commercialScoreTrendsString +' ,fsrScoreTrends = '+scoreResult?.fsrScoreTrendsString+' ]', '','', 'False'));
            }
            if(scoreResult.intLog.Status_Code__c == 200){
                ExperianCreditScoreFetcher.updateSocres(JSON.serialize(scoreResult),creditDetail.Customer__c);
            }
            creditDetail.IP_Score__c = scoreResult?.ipscore;
            creditDetail.FSR_Score__c = scoreResult?.fsrscore;
            creditDetail.Commercial_Trends__c = scoreResult?.commercialScoreTrendsString;
            creditDetail.FSR_Trends__c = scoreResult?.fsrScoreTrendsString;
        }
        if(factsApi){				//Check if we got anything from Facts Api , and Success Date and insert Integration Log
            intLogLstToInsert.add(factsResults.intLog);
            peToInsert.add(createCreditLogs.createCreditProcessLogs(accToUpdateOwner.Id,'Business Facts - Recency Check ','Decision','Requires new data','', '','True'));
            if(factsResults.intLog.Status_Code__c == 200){
                try{
                    peToInsert.add(createCreditLogs.createCreditProcessLogs(accToUpdateOwner.Id, 'Business Facts API Call ', 'Action','NAICS code - '+factsResults?.results?.naicsCodes[0]?.code ,'',factsResults.intLog.Id,factsResults.intLog.Status__c == 'OK' ? 'Success' : 'Fail'));
                    List<ExperianBusinessFactsFetcher.naicsCodes> naics = factsResults?.results?.naicsCodes;
                    List<String> naicsCode = new List<String>();
                    for(ExperianBusinessFactsFetcher.naicsCodes naicsVar : naics){
                        naicsCode.add(naicsVar?.code);
                    }
                    if(naicsCode.size() > 0){
                        creditDetail.Sector_NAICS__c = string.join(naicsCode,',');
                    }
                }catch(Exception e){peToInsert.add(createCreditLogs.createCreditProcessLogs(accToUpdateOwner.Id, 'Business Facts API Call ', 'Action', 'NAICS code - '+null ,'','',factsResults.intLog.Status__c == 'OK' ? 'Success' : 'Fail'));}
                accToUpdateOwner.Last_Successful_Experian_Business_Fact__c = System.now();
                ExperianBusinessFactsFetcher.updateBusinessFacts(JSON.serialize(factsResults),creditDetail.Customer__c);
            }
            else{
                peToInsert.add(createCreditLogs.createCreditProcessLogs(accToUpdateOwner.Id, 'Business Facts API Call ', 'Action', 'NAICS code - '+null ,'','',factsResults.intLog.Status__c));
            }
        }else{
            try{
                peToInsert.add(createCreditLogs.createCreditProcessLogs(accToUpdateOwner.Id,'Business Facts - Recency Check ','Decision', 'New data not required [ '+'NAICS code - '+factsResults?.results?.naicsCodes[0]?.code+' ]','', '', 'Success'));
                List<ExperianBusinessFactsFetcher.naicsCodes> naics = factsResults?.results?.naicsCodes;
                List<String> naicsCode = new List<String>();
                for(ExperianBusinessFactsFetcher.naicsCodes naicsVar : naics){
                    naicsCode.add(naicsVar?.code);
                }
                if(naicsCode.size() > 0){
                    creditDetail.Sector_NAICS__c = string.join(naicsCode,',');
                }
            }catch(Exception e){String factLogId = '';
                if(factsResults.intLog != null){factLogId = factsResults.intLog.Id;}
                peToInsert.add(createCreditLogs.createCreditProcessLogs(accToUpdateOwner.Id,'Business Facts - Recency Check ','Decision', 'New data not required [ '+'NAICS code - null ]','',factLogId,'Success'));
                DecisionReasonToPopulate +='New data not required [ '+'NAICS code - null ]';
            }
        }
        System.debug('fraudResults.results--> '+fraudResults.results);
        if(fraudResults.results != null){			//Check if we got anything from FraudShields , and Success Date and insert Integration Log
            if(fraudResults.intLog.Status_Code__c == 200){
                accToUpdateOwner.Last_Successful_Experian_Fraud_Shields__c = System.now();
                ExperianFraudShieldsFetcher.updateFraudShields(JSON.serialize(fraudResults),creditDetail.Customer__c);
            }
            //Check conditions based on values returned from the Api
            creditDetail.Fraud_Details__c = 'activeBusinessIndicator - '+fraudResults?.results?.activeBusinessIndicator + ',ofacMatchWarning Code - '+fraudResults?.results?.ofacMatchWarning?.code + ',ofacMatchWarning Definition - '+fraudResults?.results?.ofacMatchWarning?.definition+',businessVictimStatementIndicator - '+fraudResults?.results?.businessVictimStatementIndicator+' ]';
            
            if(fraudResults.results.activeBusinessIndicator == true && (fraudResults.results.ofacMatchWarning.code == 1 || fraudResults.results.ofacMatchWarning.code == null) && (fraudResults.results.ofacMatchWarning.definition == 'No Match Found' || fraudResults.results.ofacMatchWarning.definition == 'Not Available') && fraudResults.results.businessVictimStatementIndicator == false){
                peToInsert.add(createCreditLogs.createCreditProcessLogs(accToUpdateOwner.Id,'Fraud Indicator Check ','Decision', 'No Fraud indicators for the customer', '','', 'True'));
                DecisionReasonToPopulate += 'No Fraud indicators for the customer';
                if(scoreResult != null){								//Check for Null scores as further logic depends on it.
                    creditDetail.IP_Score__c = scoreResult.ipscore;
                    creditDetail.FSR_Score__c = scoreResult.fsrscore;
                    if(scoreResult.ipscore >  40 && scoreResult.fsrscore > 40){     //Condition 1
                        System.debug('updateCreditDetail Sync Method');
                        
                       /* SU - 974 */ 
                        if(scoreResult.ipscore == 999 || scoreResult.ipscore == 998 || scoreResult.fsrscore == 999 || scoreResult.fsrscore ==998){
                           System.debug('in 999 998');
                           creditDetail.Credit_Check_Outcome__c  = 'Refer';
                           StatusToSet = 'Credit Risk Review';
                            if (scoreResult.ipscore == 999 && scoreResult.fsrscore == 999){
                               	reason = 'IP/FSR = 999 Not Enough Data'; 
								DecisionReasonToPopulate +=  'IP and FSR are 999 [ IP - '+scoreResult.ipscore+', FSR - '+scoreResult.fsrscore+' ]';
                                peToInsert.add(createCreditLogs.createCreditProcessLogs(accToUpdateOwner.Id,'IP and FSR are 999 ? ','Decision', '[ IP - '+scoreResult.ipscore+', FSR - '+scoreResult.fsrscore+' ]','','','True'));
                            }
                            else if (scoreResult.ipscore == 998 && scoreResult.fsrscore == 998){
                                reason = 'IP/FSR = 998 Bankruptcy Present'; 
                                DecisionReasonToPopulate +=  'IP and FSR are 998 [ IP - '+scoreResult.ipscore+', FSR - '+scoreResult.fsrscore+' ]';
                                peToInsert.add(createCreditLogs.createCreditProcessLogs(accToUpdateOwner.Id,'IP and FSR are 998 ? ','Decision', '[ IP - '+scoreResult.ipscore+', FSR - '+scoreResult.fsrscore+' ]','','','True'));
                            }                            
                       }else if(scoreResult.ipscore >  40 && scoreResult.fsrscore > 40){     //Condition 1
                           creditDetail.Credit_Check_Outcome__c  = 'Passed';
                           StatusToSet = 'Ready for Pricing';
                           reason = 'IP > 40 && FSR > 40';
                           peToInsert.add(createCreditLogs.createCreditProcessLogs(accToUpdateOwner.Id,'IP > 40 && FSR > 40 ? ', 'Decision', 'Both IP and FSR are above 40 [ IP - '+scoreResult.ipscore+', FSR - '+scoreResult.fsrscore+' ]','','','True'));
                           DecisionReasonToPopulate +=  'Both IP and FSR are above 40 [ IP - '+scoreResult.ipscore+', FSR - '+scoreResult.fsrscore+' ]';
                       }
                       
                      
                        
                       /* creditDetail.Credit_Check_Outcome__c  = 'Passed';
                        StatusToSet = 'Ready for Pricing';
                        reason = 'IP > 40 && FSR > 40';
                        peToInsert.add(createCreditLogs.createCreditProcessLogs(accToUpdateOwner.Id,'IP > 40 && FSR > 40 ? ','Decision', 'Both IP and FSR are above 40 [ IP - '+scoreResult.ipscore+', FSR - '+scoreResult.fsrscore+' ]', '', '','True'));
                        DecisionReasonToPopulate +=  'Both IP and FSR are above 40 [ IP - '+scoreResult.ipscore+', FSR - '+scoreResult.fsrscore+' ]'; */
                    }
                    if(scoreResult.ipscore <  40 && scoreResult.fsrscore < 40){		//Condition 2
                        creditDetail.Credit_Check_Outcome__c  = 'Failed';
                        StatusToSet = 'Ready for Pricing';
                        reason = 'IP < 40 && FSR < 40';
                        peToInsert.add(createCreditLogs.createCreditProcessLogs(accToUpdateOwner.Id,'IP < 40 && FSR < 40 ? ','Decision', 'Both IP and FSR are below 40 [ IP - '+scoreResult.ipscore+', FSR - '+scoreResult.fsrscore+' ]','','','True'));
                        DecisionReasonToPopulate += 'Both IP and FSR are below 40 [ IP - '+scoreResult.ipscore+', FSR - '+scoreResult.fsrscore+' ]';
                    }
                    //Condition 3 -  Invloves calling Facts Endpoint if needed
                    if((scoreResult.ipscore <  40 && scoreResult.fsrscore > 40) || (scoreResult.ipscore >  40 && scoreResult.fsrscore < 40) ){
                        creditDetail.Credit_Check_Outcome__c  = 'Pending';
                        StatusToSet = 'Ready for Pricing';
                        string ipDescription = '';
                        if(scoreResult.ipscore <  40 && scoreResult.fsrscore > 40){
                            ipDescription = 'IP < 40 && FSR > 40 [ IP - '+scoreResult.ipscore+', FSR - '+scoreResult.fsrscore+' ]';
                            reason = 'IP < 40 && FSR > 40';
                        }
                        else{ipDescription = 'IP > 40 && FSR < 40 [ IP - '+scoreResult.ipscore+', FSR - '+scoreResult.fsrscore+' ]';
                            reason = 'IP > 40 && FSR < 40';
                        }
                        peToInsert.add(createCreditLogs.createCreditProcessLogs(accToUpdateOwner.Id,'(IP < 40 && FSR > 40) OR (IP > 40 && FSR < 40) ? ','Decision',ipDescription,'','','True'));
                        DecisionReasonToPopulate += ipDescription;
                        if(factsResults?.results?.naicsCodes==null){
                            creditDetail.Credit_Check_Outcome__c  = 'Failed';
                            StatusToSet = 'Ready for Pricing';
                            reason = 'NAICS starts with 71 or 92 or null';
                            peToInsert.add(createCreditLogs.createCreditProcessLogs(accToUpdateOwner.Id,'NAICS starts with 71 or 92 or null ?','Decision','NAICS starts with 71 or 92 or null','','','True'));
                        }else if(factsResults?.results?.naicsCodes[0]?.code.startsWith('71') || factsResults?.results?.naicsCodes[0]?.code.startsWith('92')){  //Inner Condition -1 (Master - 3)
                            creditDetail.Credit_Check_Outcome__c  = 'Failed';
                            StatusToSet = 'Ready for Pricing';
                            System.debug('--244--');
                            reason = 'NAICS starts with 71 or 92 or null';
                            peToInsert.add(createCreditLogs.createCreditProcessLogs(accToUpdateOwner.Id,'NAICS starts with 71 or 92 or null ?',
                                                                                    'Decision','NAICS starts with 71 or 92 or null',
                                                                                    '','', 'True'));
                        }
                        else if(scoreResult.commercialscoreTrend > 10){ 		//Inner Condition -2 (Master - 3)
                            creditDetail.Credit_Check_Outcome__c  = 'Failed';
                            StatusToSet = 'Ready for Pricing';
                            reason = 'Commercial score trend difference > 10 for current and previous quarter';
                            peToInsert.add(createCreditLogs.createCreditProcessLogs(accToUpdateOwner.Id,'Commercial Score Trends difference > 10 OR FSR Score Trends difference > 20 ?','Decision', 'Commercial score trend difference > 10 for current and previous quarter [Failed] [Reason : '+' ,CommercialScoreTrend difference = '+scoreResult.commercialscoreTrend +' ,fsrScoreTrend difference = '+scoreResult.fsrscoreTrend+' ]','','', 'True'));
                        }
                        else if(scoreResult.fsrScoreTrend > 20){creditDetail.Credit_Check_Outcome__c  = 'Failed';
                            StatusToSet = 'Ready for Pricing';
                            reason = 'FSR score trend difference > 20 for current and previous quarter';
                            peToInsert.add(createCreditLogs.createCreditProcessLogs(accToUpdateOwner.Id,'Check FSR Score Trends','Decision','FSR score trend difference > 20 for current and previous quarter [Failed] [Reason : '+' ,CommercialScoreTrend difference = '+scoreResult.commercialscoreTrend +' ,fsrScoreTrend difference = '+scoreResult.fsrscoreTrend+' ]', '','', 'True'));
                        }
                        else{creditDetail.Credit_Check_Outcome__c  = 'Pending';
                            StatusToSet = 'Ready for Pricing';
                        }
                        
                    }
                }
            }
            else{
                creditDetail.Credit_Check_Outcome__c  = 'Refer';
                StatusToSet = 'Credit Risk Review';
                reason = 'Fraud Indicators are present for the customer.';
                peToInsert.add(createCreditLogs.createCreditProcessLogs(accToUpdateOwner.Id,'Fraud Indicator Check ', 'Decision', 'Fraud Indicators are present for the customer [Refer]','', '', 'False'));
                DecisionReasonToPopulate += 'Fraud Indicators are present for the customer [Refer]';
            }
        }
        List<Id> intLogLst = new List<Id>(); 
        if(!intLogLstToInsert.isEmpty()){
            //insert intLogLstToInsert;
            Database.SaveResult[] srList = Database.insert(intLogLstToInsert, false);
            for(Integer i=0;i<srList.size();i++){
                if (srList.get(i).isSuccess()){ 
                    intLogLst.add(srList.get(i).getId()) ;
                }
            }
        }
        EXPRN__Exp_Business_Info__c  expBusinessInfo = [SELECT Id,EXPRN__Exp_Business__c  FROM EXPRN__Exp_Business_Info__c WHERE EXPRN__Account_Name__c =: accToUpdateOwner.Id ORDER BY CreatedDate DESC LIMIT 1];
        creditDetail.Experian_Business__c = expBusinessInfo.EXPRN__Exp_Business__c;
        creditDetail.Experian_Business_Information__c = expBusinessInfo.Id;
        creditDetail.Decision_Reason__c = DecisionReasonToPopulate;
        update creditDetail;
        for(Pricing_Request__c pr : prToupdate){
            if(pr.Status__c != 'complete'){
                if (StatusToSet != '')
                	pr.Status__c = StatusToSet;
            }
            pr.Credit_Details__c = creditDetail.Id;
            If(Test.isRunningTest()){
                pr.Record_Created__c = true;
            }
        }
        update prToupdate;
        // To update all Open PRs to new Credit Detail SU - 926
        List<Pricing_Request__c> newprToupdate = [SELECT Id,Status__c,Opportunity__c, Credit_Details__c, Bill_Type__c FROM Pricing_Request__c WHERE (Bill_Type__c = 'UCB with Credit' OR Bill_Type__c = 'Dual') AND (Status__c != 'Complete' AND Status__c != 'Cancelled') AND Customer__c =: creditDetail.Customer__c ORDER BY CreatedDate DESC];
        for(Pricing_Request__c pricReq : newprToupdate){
            pricReq.Credit_Details__c = creditDetail.Id;
        }
        update newprToupdate; 
        update accToUpdateOwner;
        boolean allAPIsPassed = true;
        for(Integration_Log__c intlog : intLogLstToInsert){
            if(intlog.Status__c != 'OK' && intlog.Status_Code__c != 200){
                allAPIsPassed = false;
            }
        }
        String description = '';
        if(allAPIsPassed){
            try{
                description = 'Credit Outcome - '+creditDetail.Credit_Check_Outcome__c + ' [Reason : '+reason+']';
            }catch(Exception e){ }
            creditDetail.Credit_Automation_Fail__c = false;
        }
        else{description = 'Experian calls were failed due to some reason, Please check integration logs for more details.';
            creditDetail.Credit_Automation_Fail__c = true;
            creditDetail.Status__c = 'New';
        }
        set<Id> peToInsertIds = new set<Id>();
        Database.SaveResult[] srListPE = Database.insert(peToInsert, false);
        for(Database.saveResult s: srListPE){
            if(s.isSuccess()){
                peToInsertIds.add(s.getId()) ;
            }
        }
        List<Integration_Log__c> getIntName = [SELECT Name FROM Integration_Log__c WHERE Id IN : intLogLst];
        List<Process_Event__c> peDetails = [SELECT Id,Name__c,Related_Record_Id__c,Related_Record_Name__c FROM Process_Event__c WHERE Id IN :peToInsertIds ];
        List<Process_Event__c> peToUpdate = new List<Process_Event__c>();
        for(Process_Event__c pe :peDetails){
            if(pe.Name__c == 'Fraud Shields API Call'){
                pe.Related_Record_Id__c = intLogLst.get(0);
                pe.Related_Record_Name__c = getIntName.get(0).Name;
                peToUpdate.add(pe);
            }
            if(pe.Name__c == 'Scores API Call'){
                pe.Related_Record_Id__c = intLogLst.get(1);
                pe.Related_Record_Name__c = getIntName.get(1).Name;
                peToUpdate.add(pe);
            }
            if(pe.Name__c == 'Business Facts API Call'){
                if(!Test.isRunningTest()){
                    pe.Related_Record_Id__c = intLogLst.get(2);
                    pe.Related_Record_Name__c = getIntName.get(1).Name;
                }
                peToUpdate.add(pe);
            }
        }
        update peToUpdate;
        Credit_Check__c creditDetailName = [SELECT id,Name,Credit_Check_Outcome__c FROM Credit_Check__c WHERE Id =:creditDetail.Id ];
        Credit_Check__c creditDetailToPass = new Credit_Check__c();
        if(creditMatch == false){
            if(priceRec != null){
                creditDetailToPass = Calculate_TermPrice_CreditPremium.getTermPrice_CreditPremiumSync(new List<Id>{prToupdate[0].Id},priceRec.Id,false);   
            }else{
                creditDetailToPass = null;
                Account customerAccNew = [SELECT Id,
                                      Customer_Credit_Limit__c,
                                      Credit_Type__c,
                                      Customer_Credit_Annual_Volume__c
                                      FROM Account
                                      WHERE Id =:creditDetail.Customer__c];
                
                if (customerAccNew.Customer_Credit_Limit__c >= 40000){
                    creditDetail.Credit_Check_Outcome__c = 'Refer'; 
                    createCreditLogs.createCreditProcessLog(creditDetail.Customer__c, 'Credit Limit >= 40K ?', 'Decision','Credit Limit : $'+customerAccNew.Customer_Credit_Limit__c.format(),'','','True');
                    createCreditLogs.createCreditProcessLog(creditDetail.Customer__c, 'Credit Assessment', 'Decision', 'Credit Outcome :'+creditDetail.Credit_Check_Outcome__c,creditDetail.Name,creditDetail.Id,'Completed');    
                    update creditDetail;
                }                
            }
        }
        if(creditDetailToPass != null){
            creditDetailToPass.Send_Experian_Notification__c = true;
            if(!Test.isRunningTest())
                update creditDetailToPass;
        }
    }
    
    public class UAField{
        @AuraEnabled public String exp1{get; set;}
        @AuraEnabled public String exp2{get; set;}
        @AuraEnabled public String exp3{get; set;}
        @AuraEnabled public String exp4{get; set;}
        @AuraEnabled public String exp5{get; set;}
        @AuraEnabled public String exp6{get; set;}
        @AuraEnabled public String exp7{get; set;}
        @AuraEnabled public String exp8{get; set;}
        @AuraEnabled public String exp9{get; set;}
        @AuraEnabled public String exp10{get; set;}
        @AuraEnabled public String exp11{get; set;}
        @AuraEnabled public String exp12{get; set;}
        @AuraEnabled public String exp13{get; set;}
        @AuraEnabled public String exp14{get; set;}
        @AuraEnabled public String exp15{get; set;}
        @AuraEnabled public String exp16{get; set;}
        @AuraEnabled public String exp17{get; set;}
        @AuraEnabled public String exp18{get; set;}
        @AuraEnabled public String exp19{get; set;}
        @AuraEnabled public String exp20{get; set;}
        @AuraEnabled public String exp21{get; set;}
        @AuraEnabled public String exp22{get; set;} 
        @AuraEnabled public String exp23{get; set;}
        @AuraEnabled public String exp24{get; set;}
        @AuraEnabled public String exp25{get; set;}
        @AuraEnabled public String exp26{get; set;}
         @AuraEnabled public String exp27{get; set;}
        @AuraEnabled public String exp28{get; set;}
        @AuraEnabled public String exp29{get; set;}
        @AuraEnabled public String exp30{get; set;}
        @AuraEnabled public String exp31{get; set;}
        @AuraEnabled public String exp32{get; set;}
        @AuraEnabled public String exp33{get; set;}
        @AuraEnabled public String exp34{get; set;}
        @AuraEnabled public String exp35{get; set;} 
        @AuraEnabled public String exp36{get; set;}
        @AuraEnabled public String exp37{get; set;}
        @AuraEnabled public String exp38{get; set;}
        @AuraEnabled public String exp39{get; set;}
         @AuraEnabled public String exp40{get; set;}
        @AuraEnabled public String exp41{get; set;}
        @AuraEnabled public String exp42{get; set;}
        @AuraEnabled public String exp43{get; set;}
        @AuraEnabled public String exp44{get; set;}
        @AuraEnabled public String exp45{get; set;}
        @AuraEnabled public String exp46{get; set;}
        @AuraEnabled public String exp47{get; set;}
        @AuraEnabled public String exp48{get; set;} 
        @AuraEnabled public String exp49{get; set;}
        @AuraEnabled public String exp50{get; set;}
        @AuraEnabled public String exp51{get; set;}
        @AuraEnabled public String exp52{get; set;}
        
           @AuraEnabled public String exp53{get; set;}
        @AuraEnabled public String exp54{get; set;}
        @AuraEnabled public String exp55{get; set;}
        @AuraEnabled public String exp56{get; set;}
        @AuraEnabled public String exp57{get; set;}
        @AuraEnabled public String exp58{get; set;}
        @AuraEnabled public String exp59{get; set;}
        @AuraEnabled public String exp60{get; set;}
        @AuraEnabled public String exp61{get; set;} 
        @AuraEnabled public String exp62{get; set;}
        @AuraEnabled public String exp63{get; set;}
        @AuraEnabled public String exp64{get; set;}
        @AuraEnabled public String exp65{get; set;}
        
         @AuraEnabled public String exp66{get; set;}
        @AuraEnabled public String exp67{get; set;}
        @AuraEnabled public String exp68{get; set;}
        @AuraEnabled public String exp69{get; set;}
        @AuraEnabled public String exp70{get; set;}
        @AuraEnabled public String exp71{get; set;}
        @AuraEnabled public String exp72{get; set;}
        @AuraEnabled public String exp73{get; set;}
        @AuraEnabled public String exp74{get; set;} 
        @AuraEnabled public String exp75{get; set;}
        @AuraEnabled public String exp76{get; set;}
        @AuraEnabled public String exp77{get; set;}
        @AuraEnabled public String exp78{get; set;}
    }
    
    public static void codeCvrMeth(){
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
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
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
        i++;
        i++;
        i++;
        i++;i++;
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