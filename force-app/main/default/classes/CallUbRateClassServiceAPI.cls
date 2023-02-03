public class CallUbRateClassServiceAPI {
    //@future(callout=true)
    public static void callUBRenewal(String recordId,List<String> uaeId){
        
        // List<Utility_Account_Enrollment__c> objUAEs = [SELECT Id FROM Utility_Account_Enrollment__c WHERE Enrollment__c =:recordId];
        System.debug('SubmitUbRenewal called');
        System.debug('Enrollment Record Id: ' + recordId);
        // System.debug('Selected UAE size: ' + objUAEs.size());
        List<Utility_Account_Enrollment__c> UAEListActive = [SELECT Id,
                                                             Utility_Account__r.Name,
                                                             Utility_Account__r.Account__r.Name,
                                                             Utility_Account__r.Utility__r.Utility_Short_Name__c,                                                             
                                                             Utility_Account__r.Utility__r.Utility_Code__c,
                                                             Utility_Account__r.Zone__c,
                                                             Start_Date__c,                                                                
                                                             RateClass__c,
                                                             Category__c,
                                                             Rate_Type__c,
                                                             Enrollment__r.Rate_Amount__c,
                                                             Enrollment__r.Broker_Name__c,
                                                             Enrollment__r.Broker_Margin__c,                                                                
                                                             Enrollment__r.Contract__r.Opportunity__r.Opportunity_ID__c,
                                                             Enrollment__r.Contract_Term__c,
                                                             Enrollment__r.Product__c,   
                                                             Utility_Account__r.Commodity__c,
                                                             Utility_Account__r.Account__r.Id,
                                                             Enrollment__r.Bill_Type__c,
                                                             Bill_Type__c,
                                                             Enrollment__r.Contract__r.Product__r.Family,
                                                             Utility_Account__r.Account__r.Customer_ID__c,
                                                             Enrollment__r.Contract_Start__c,
                                                             Enrollment__r.Commission_Type__c,
                                                             Enrollment__r.Commission_Discount__c,
                                                             Enrollment__r.Contract__r.Opportunity__r.Broker__r.Name,
                                                             Enrollment__r.Contract__r.Opportunity__r.Broker_Margin_per_unit__c,
                                                             Enrollment__r.Contract__r.Opportunity__r.Owner.Name,
                                                             Enrollment__r.Contract_Source_Code__c,
                                                             Enrollment__r.Request_Type__c,
                                                             Enrollment__r.Record_Type__c,
                                                             Enrollment__r.Taxable_Portion__c,
                                                             Enrollment__r.Opportunity_ID__c,
                                                             Enrollment__r.Tax_Exempt__c,
                                                             Enrollment__r.Tax_Exempt_Exception__c,
                                                             Enrollment__r.SalesCommissionUOM__c,
                                                             Enrollment__r.Treatment__c,
                                                             Enrollment__r.Voluntary_RECs__c,
                                                             Enrollment__r.Voluntary_RECs_percent__c,
                                                             Enrollment__c,
                                                             Program_Code__c
                                                             FROM Utility_Account_Enrollment__c
                                                             WHERE Id =: uaeId 
                                                             AND Utility_Account__r.Status__c = 'Active'
                                                             //AND (NOT (Utility_Account__r.Utility__r.Utility_Code__c = 'NAGNYE' AND Enrollment__r.Bill_Type__c = 'UCB'))
                                                            ];
        System.debug('UAEListActive' + UAEListActive);
        //List<Wrapper_UbEnrollment.EnrollmentData> enrollmentRecordList = new List<Wrapper_UbEnrollment.EnrollmentData>();
        List<UB_RateClassService.RateClassIdentifier> RateClassIdentifierList = new List<UB_RateClassService.RateClassIdentifier>();
        List<UB_RateClassService.RateClassSchedule> RateClassScheduleList = new List<UB_RateClassService.RateClassSchedule>();
        
        List<String> emailXMLlist = new List<String>();
        List<String> resultAPIlist = new List<String>();
        
        for (Utility_Account_Enrollment__c uae : UAEListActive) {
            
            //Wrapper_UbEnrollment.EnrollmentData enrollmentRecord = new Wrapper_UbEnrollment.EnrollmentData();
            UB_RateClassService.RateClassIdentifier rateClassIdentifier = new UB_RateClassService.RateClassIdentifier();
            rateClassIdentifier.uaeRecord = uae;
            rateClassIdentifier.enrollmentId = uae.Enrollment__c;
            rateClassIdentifier.uaeId = uae.Id;
            rateClassIdentifier.Commodity = uae.Utility_Account__r.Commodity__c;
            rateClassIdentifier.MarketerAccountNumber = uae.Utility_Account__r.Name;
            rateClassIdentifier.UtilityAccountNumber = uae.Utility_Account__r.Name;
            RateClassIdentifierList.add(rateClassIdentifier);
            
            UB_RateClassService.RateClassSchedule rateClassSchedule = new UB_RateClassService.RateClassSchedule();
            rateClassSchedule.Category = uae.Category__c;
            rateClassSchedule.ContractStartDate = uae.Start_Date__c;
            rateClassSchedule.ContractTerm = Integer.valueOf(uae.Enrollment__r.Contract_Term__c);
            rateClassSchedule.ContractTerm1 = 12;
            rateClassSchedule.ContractStartDate1 = uae.Start_Date__c.addMonths(rateClassSchedule.ContractTerm1).addDays(1);
            System.debug('rateClassSchedule.ContractStartDate1' + rateClassSchedule.ContractStartDate1);
            rateClassSchedule.ContractTermUOM = 'Months';
            if (uae.Category__c == 'Fixed'){
                rateClassSchedule.Rate = uae.Enrollment__r.Rate_Amount__c;                
            }else if (uae.Category__c == 'Undefined'){
                if (!(uae.Enrollment__r.Bill_Type__c == 'UCB' && uae.Utility_Account__r.Utility__r.Utility_Code__c == 'NAGNYE'))
                {
                    rateClassSchedule.LinkedClass = uae.RateClass__c;
                    rateClassSchedule.Adder1 = uae.Enrollment__r.Rate_Amount__c;
                }else{                    
                    rateClassSchedule.Rate = uae.Enrollment__r.Rate_Amount__c; 
                }
				
            }
            System.Debug('LinkedClass--->'+rateClassSchedule.LinkedClass);
            rateClassSchedule.LinkedClass1 = uae.Utility_Account__r.Utility__r.Utility_Short_Name__c+ '|' +uae.Utility_Account__r.Zone__c+ '|' +'Rollover';
            System.debug('rateClassSchedule.LinkedClass1' + rateClassSchedule.LinkedClass1);
            rateClassSchedule.RateEffectiveDate = uae.Start_Date__c;
            rateClassSchedule.RateEffectiveDate1 = uae.Start_Date__c.addMonths(rateClassSchedule.ContractTerm1).addDays(1);
             System.debug('rateClassSchedule.RateEffectiveDate1' + rateClassSchedule.RateEffectiveDate1);
            rateClassSchedule.RateType = uae.Rate_Type__c;            
            rateClassSchedule.Info1 = uae.Enrollment__r.Product__c;
            rateClassSchedule.Info2 = uae.Enrollment__r.Opportunity_Id__c;
            rateClassSchedule.Info3 = uae.Enrollment__r.Commission_Type__c;
            rateClassSchedule.Info4 = String.valueOf(uae.Enrollment__r.Commission_Discount__c);
            // Voluntary RECs
            String volRecs = uae.Enrollment__r.Voluntary_RECs__c;
            if (String.isNotBlank(uae.Enrollment__r.Treatment__c))
                volRecs += '|' + uae.Enrollment__r.Treatment__c;
            if (uae.Enrollment__r.Voluntary_RECs_percent__c != null)
                volRecs += '|' + uae.Enrollment__r.Voluntary_RECs_percent__c + '%';
            
            Marketer__c objMarketer = Marketer__c.getall().values();
            Decimal rolloverBrokerMargin;
            if (objMarketer.Broker_Margin_Rollover_Limit__c != null){
                if (uae.Enrollment__r.Broker_Margin__c > objMarketer.Broker_Margin_Rollover_Limit__c)
                	rolloverBrokerMargin = objMarketer.Broker_Margin_Rollover_Limit__c;    
                else
                    rolloverBrokerMargin = uae.Enrollment__r.Broker_Margin__c;
            }
            rateClassSchedule.Info5 = uae.Enrollment__r.Broker_Name__c + '|' + uae.Enrollment__r.Broker_Margin__c + '|' + uae.Bill_Type__c + '|' + volRecs;
            rateClassSchedule.Info5_1 = uae.Enrollment__r.Broker_Name__c + '|' + rolloverBrokerMargin + '|' + uae.Bill_Type__c + '|' + volRecs;
            RateClassScheduleList.add(rateClassSchedule);
            

        }
        
    
        NamedCredential namedCred;
        
        //query the endpoint from the named credentials
        namedCred = [SELECT DeveloperName, 
                     Endpoint 
                     FROM NamedCredential
                     WHERE DeveloperName =:'UbRateClassService'];
        String endpoint;
        if (namedCred.Endpoint != null || namedCred.Endpoint != '')
            endpoint = namedCred.Endpoint;            
        else
            endpoint = 'https://se-eaus-dev-us-intg-apim-001.azure-api.net/rateclassservice';
        //String endpoint = 'https://demoutilibill.eccircle.com/UbSystemServices/UbSystemServices.EnrollmentLibrary.UbEnrollmentRequest.svc';
        
        if(RateClassIdentifierList.size()>0 && !RateClassIdentifierList.isEmpty()){
            CallUbRateClassServiceAPIBatch callUbRateBatchObject1 = new CallUbRateClassServiceAPIBatch(RateClassIdentifierList,RateClassScheduleList,endpoint); 
            Id batchId = Database.executeBatch(callUbRateBatchObject1,1);
            system.debug('batchId-->'+batchId);
            
            
        }
    }
    
}