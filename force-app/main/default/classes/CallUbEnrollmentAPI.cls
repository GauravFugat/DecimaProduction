public class CallUbEnrollmentAPI {
 //   @future(callout=true)
    public static void callUBAPI(String recordId,List<String> uaeId){
        
        // List<Utility_Account_Enrollment__c> objUAEs = [SELECT Id FROM Utility_Account_Enrollment__c WHERE Enrollment__c =:recordId];
        System.debug('SubmitUbEnrollment called');
        System.debug('Enrollment Record Id: ' + recordId);
        // System.debug('Selected UAE size: ' + objUAEs.size());
        List<Utility_Account_Enrollment__c> UAEListNotActive = [SELECT Id,
                                                                Utility_Account__r.Name,
                                                                Market_Rate_Code__c,
                                                                Utility_Account__r.Utility__r.Utility_Short_Name__c,
                                                                Utility_Account__r.Account__r.Name,
                                                                Utility_Account__r.Utility__r.Utility_DUNS__c,
                                                                Start_Date__c,
                                                                AutoSubmitFlag__c,
                                                                RateClass__c,
                                                                Enrollment__r.Rate_Amount__c,
                                                                Enrollment__r.Broker_Name__c,
                                                                Enrollment__r.Broker_Margin__c,
                                                                Utility_Account__r.Account__r.phone,
                                                                Utility_Account__r.Utility__r.Bill_Type__c,
                                                                Utility_Account__r.Account__r.BillingStreet,
                                                                Utility_Account__r.Account__r.BillingCity,
                                                                Utility_Account__r.Account__r.BillingState,
                                                                Utility_Account__r.Account__r.BillingPostalCode,
                                                                Utility_Account__r.Account__r.Primary_Contact__r.Email,
                                                                Utility_Account__r.Account__r.Primary_Contact__r.Name,
                                                                Enrollment__r.Contract__r.Opportunity__r.Opportunity_ID__c,
                                                                Enrollment__r.Contract_Term__c,
                                                                Enrollment__r.Product__c,
                                                                Enrollment__r.Bill_Type__c,
                                                                Rate_Schedule_Name__c,
                                                                Utility_Account__r.Street__c,
                                                                Utility_Account__r.Street_2__c,
                                                                Utility_Account__r.City__c,
                                                                Utility_Account__r.State__c,
                                                                Utility_Account__r.Zip__c,
                                                                Utility_Account__r.Zone__c,
                                                                Program_Code__c,
                                                                Utility_Account__r.Commodity__c,
                                                                Utility_Account__r.Account__r.Id,
                                                                Bill_Type__c,
                                                                Enrollment__r.Contract__r.Product__r.Family,
                                                                Utility_Account__r.Account__r.Customer_ID__c,
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
                                                                Enrollment__r.GlobalTaxSettings__c,
                                                                Enrollment__r.IncludeCityTax__c,
                                                                Enrollment__r.IncludeCountyTax__c,
                                                                Enrollment__r.IncludeStateTax__c,
                                                                Enrollment__r.IncludeMTATax__c,
                                                                Enrollment__r.IncludeSPDTax__c,
                                                                Enrollment__r.IncludeGRTTax__c,
                                                                Enrollment__r.IncludeOtherTax__c,
                                                                Enrollment__r.SvcGlobalTaxSettings__c,
                                                                Enrollment__r.SvcIncludeCityTax__c,
                                                                Enrollment__r.SvcIncludeCountyTax__c,
                                                                Enrollment__r.SvcIncludeStateTax__c,
                                                                Enrollment__r.SvcIncludeMTATax__c,
                                                                Enrollment__r.SvcIncludeSPDTax__c,
                                                                Enrollment__r.SvcIncludeGRTTax__c,
                                                                Enrollment__r.SvcIncludeOtherTax__c,
                                                                Enrollment__r.SalesCommissionUOM__c,
                                                                Enrollment__r.Treatment__c,
                                                                Enrollment__r.Voluntary_RECs__c,
                                                                Enrollment__r.Voluntary_RECs_percent__c,
                                                                Enrollment__c
                                                                FROM Utility_Account_Enrollment__c
                                                                WHERE Id =: uaeId 
                                                                AND Utility_Account__r.Status__c != 'Active'
                                                               ];
        System.debug('UAEListNotActive' + UAEListNotActive);
        List<Wrapper_UbEnrollment.EnrollmentData> enrollmentRecordList = new List<Wrapper_UbEnrollment.EnrollmentData>();
        
        List<String> emailXMLlist = new List<String>();
        List<String> resultAPIlist = new List<String>();
        
        for (Utility_Account_Enrollment__c uae : UAEListNotActive) {
            
            Wrapper_UbEnrollment.EnrollmentData enrollmentRecord = new Wrapper_UbEnrollment.EnrollmentData();
            enrollmentRecord.uaeRecord = uae;
            enrollmentRecord.enrollmentId = uae.Enrollment__c;
            enrollmentRecord.uaeId = uae.Id;
            enrollmentRecord.AccountClassName = 'Standard';
            enrollmentRecord.AccountType = uae.Enrollment__r.Contract_Source_Code__c; // 'Residential';///
            enrollmentRecord.BillingMethod =  uae.Bill_Type__c; //'UtilityRateReady'; 
            enrollmentRecord.Commodity =  uae.Utility_Account__r.Commodity__c;          //'Electric'; ///
            System.debug('Utility_Account__r.Commodity__c'+uae.Utility_Account__r.Commodity__c);
            enrollmentRecord.CustomerName = uae.Utility_Account__r.Account__r.Name;
            enrollmentRecord.MarketerAccountNumber = uae.Utility_Account__r.Name;
            
            //Retrieve Marketer details
            Marketer__c objMarketer = Marketer__c.getall().values();
            String marketerDunsNumber = null;
            if (objMarketer.MarketerDunsNumber__c != null)
                marketerDunsNumber = objMarketer.MarketerDunsNumber__c;         
            else
                marketerDunsNumber = 'Smartest Energy_Sandbox_Duns';
            enrollmentRecord.MarketerDunsNumber = marketerDunsNumber;
            
            String historicalData = null;
            if (objMarketer.HistoricalData__c != null)
                historicalData = String.valueof(objMarketer.HistoricalData__c);
            else
                historicalData = 'SummaryUsage';
            
            enrollmentRecord.HistoricalData = historicalData;
            
            Integer rolloverContractTerm;
            if (objMarketer.Rollover_Contract_Term__c != null)
                rolloverContractTerm = Integer.valueof(objMarketer.Rollover_Contract_Term__c);
            else
                rolloverContractTerm = 12;
            
            Decimal rolloverBrokerMargin;
            if (objMarketer.Broker_Margin_Rollover_Limit__c != null){
                if (uae.Enrollment__r.Broker_Margin__c > objMarketer.Broker_Margin_Rollover_Limit__c)
                	rolloverBrokerMargin = objMarketer.Broker_Margin_Rollover_Limit__c;    
                else
                    rolloverBrokerMargin = uae.Enrollment__r.Broker_Margin__c;
            }
            //////////////////////
            enrollmentRecord.RxRateClass1 = uae.RateClass__c;
            enrollmentRecord.AutoSubmitFlag = uae.AutoSubmitFlag__c; 
            
            //////////////////////////////////////////
            
            // Tax Details
            enrollmentRecord.TaxablePercentage = uae.Enrollment__r.Taxable_Portion__c;//Updated
            enrollmentRecord.GlobalTaxSettings = uae.Enrollment__r.GlobalTaxSettings__c;
            enrollmentRecord.SvcGlobalTaxSettings = uae.Enrollment__r.SvcGlobalTaxSettings__c;
            enrollmentRecord.IncludeCityTax = uae.Enrollment__r.IncludeCityTax__c;
            enrollmentRecord.IncludeCountyTax = uae.Enrollment__r.IncludeCountyTax__c;
            enrollmentRecord.IncludeStateTax = uae.Enrollment__r.IncludeStateTax__c;
            enrollmentRecord.IncludeMTATax = uae.Enrollment__r.IncludeMTATax__c;
            enrollmentRecord.IncludeSPDTax = uae.Enrollment__r.IncludeSPDTax__c;
            enrollmentRecord.IncludeGRTTax = uae.Enrollment__r.IncludeGRTTax__c;
            enrollmentRecord.IncludeOtherTax = uae.Enrollment__r.IncludeOtherTax__c;
            enrollmentRecord.SvcIncludeCityTax = uae.Enrollment__r.SvcIncludeCityTax__c;
            enrollmentRecord.SvcIncludeCountyTax = uae.Enrollment__r.SvcIncludeCountyTax__c;
            enrollmentRecord.SvcIncludeStateTax = uae.Enrollment__r.SvcIncludeStateTax__c;
            enrollmentRecord.SvcIncludeMTATax = uae.Enrollment__r.SvcIncludeMTATax__c;
            enrollmentRecord.SvcIncludeSPDTax = uae.Enrollment__r.SvcIncludeSPDTax__c;
            enrollmentRecord.SvcIncludeGRTTax = uae.Enrollment__r.SvcIncludeGRTTax__c;
            enrollmentRecord.SvcIncludeOtherTax = uae.Enrollment__r.SvcIncludeOtherTax__c;
            enrollmentRecord.SvcTaxablePercentage = uae.Enrollment__r.Taxable_Portion__c;
            
            enrollmentRecord.RxRate1 = uae.Enrollment__r.Rate_Amount__c;
            enrollmentRecord.RequestType = uae.Enrollment__r.Request_Type__c;              //'EnrollmentRequest'; ///
            enrollmentRecord.UtilityAccountNumber = uae.Utility_Account__r.Name;
            enrollmentRecord.UtilityDunsNumber = uae.Utility_Account__r.Utility__r.Utility_DUNS__c;
            enrollmentRecord.RecordType = uae.Enrollment__r.Record_Type__c;                //'AddEnrollment';  ///
            enrollmentRecord.CusInfo1 = uae.Utility_Account__r.Account__r.Customer_ID__c; ///
            enrollmentRecord.CusInfo2 = uae.Enrollment__r.Commission_Type__c; ///
            enrollmentRecord.CusInfo3 =  String.valueOf(uae.Enrollment__r.Commission_Discount__c); ///
            enrollmentRecord.SalespersonName = uae.Enrollment__r.Contract__r.Opportunity__r.Broker__r.Name; ///
            enrollmentRecord.SalesCommission = uae.Enrollment__r.Contract__r.Opportunity__r.Broker_Margin_per_unit__c; ///
            enrollmentRecord.SalespersonName2 = uae.Enrollment__r.Contract__r.Opportunity__r.Owner.Name; ///
            enrollmentRecord.Rx1RateInfo1 = uae.Enrollment__r.Product__c;
            enrollmentRecord.Rx1RateInfo2 = uae.Enrollment__r.Opportunity_Id__c;
            enrollmentRecord.Rx1RateInfo3 = uae.Enrollment__r.Commission_Type__c;
            enrollmentRecord.Rx1RateInfo4 = String.valueOf(uae.Enrollment__r.Commission_Discount__c);
            
            enrollmentRecord.Rx2RateInfo1 = 'Rollover';
            enrollmentRecord.Rx2RateInfo2 = uae.Enrollment__r.Opportunity_Id__c;
            enrollmentRecord.Rx2RateInfo3 = uae.Enrollment__r.Commission_Type__c;
            enrollmentRecord.Rx2RateInfo4 = String.valueOf(uae.Enrollment__r.Commission_Discount__c);
            
            system.debug(enrollmentRecord.Rx1RateInfo2);
            //changes made by suhas for SU 797
            enrollmentRecord.ContractStart = system.today();
            System.debug('ContractStart: ' + enrollmentRecord.ContractStart); 
            System.debug('uae.Utility_Account__r.Utility__r.Utility_Short_Name__c--'+uae.Utility_Account__r.Utility__r.Utility_Short_Name__c);
            System.debug('uae.Utility_Account__r.Zone__c--'+uae.Utility_Account__r.Zone__c);
            
            enrollmentRecord.RxRateClass2 = uae.Utility_Account__r.Utility__r.Utility_Short_Name__c+ '|' +uae.Utility_Account__r.Zone__c+ '|' +'Rollover';
             System.debug('RxRateClass2: ' + enrollmentRecord.RxRateClass2);
            enrollmentRecord.RxEffective2 = uae.Start_Date__c.addMonths(Integer.valueOf(uae.Enrollment__r.Contract_Term__c)).addDays(1);
             System.debug('RxEffective2: ' + enrollmentRecord.RxEffective2);
            //changes made by suhas for SU 797 (Ended)
            enrollmentRecord.RxEffective1 = uae.Start_Date__c;
            //enrollmentRecord.ContractStart = enrollmentRecord.ContractStart.addHours(5);
            if (uae.Enrollment__r.Bill_Type__c == 'UCB')
            	enrollmentRecord.MarketerRateCode1 =uae.Market_Rate_Code__c;
            System.debug('MarketerRateCode1: ' + enrollmentRecord.MarketerRateCode1);
            if (!test.isRunningTest()){
                if(uae.Bill_Type__c == 'Dual'){
                    enrollmentRecord.BusinessPhone = uae.Utility_Account__r.Account__r.phone;
                    enrollmentRecord.BillingEmail = uae.Utility_Account__r.Account__r.Primary_Contact__r.Email;
                }
            }
            
            enrollmentRecord.BillingAddress1 = uae.Utility_Account__r.Account__r.BillingStreet;
            
            enrollmentRecord.BillingCity = uae.Utility_Account__r.Account__r.BillingCity;
            enrollmentRecord.BillingState = uae.Utility_Account__r.Account__r.BillingState; 
            enrollmentRecord.BillingZip = uae.Utility_Account__r.Account__r.BillingPostalCode;
            enrollmentRecord.ContactName = uae.Utility_Account__r.Account__r.Primary_Contact__r.Name;
            enrollmentRecord.MtrInfo2 = uae.Enrollment__r.Contract__r.Opportunity__r.Opportunity_ID__c;
            enrollmentRecord.RxTerm1 = Integer.valueOf(uae.Enrollment__r.Contract_Term__c);
            enrollmentRecord.RxTerm2 = rolloverContractTerm;
            enrollmentRecord.MtrInfo1 = uae.Enrollment__r.Product__c;
            enrollmentRecord.SalesCommissionUOM = uae.Enrollment__r.SalesCommissionUOM__c;
            enrollmentRecord.SvcAddress1 = uae.Utility_Account__r.Street__c;
            enrollmentRecord.SvcAddress2 = uae.Utility_Account__r.Street_2__c;
            enrollmentRecord.SvcCity = uae.Utility_Account__r.City__c;
            enrollmentRecord.SvcState = uae.Utility_Account__r.State__c;
            enrollmentRecord.SvcZip = uae.Utility_Account__r.Zip__c;
            enrollmentRecord.UtilityRateCode = uae.Program_Code__c;
            enrollmentRecord.LocationName = uae.Utility_Account__r.Account__r.Name;
            // Voluntary RECs
            String volRecs = uae.Enrollment__r.Voluntary_RECs__c;
            if (String.isNotBlank(uae.Enrollment__r.Treatment__c))
                volRecs += '|' + uae.Enrollment__r.Treatment__c;
            if (uae.Enrollment__r.Voluntary_RECs_percent__c != null)
                volRecs += '|' + uae.Enrollment__r.Voluntary_RECs_percent__c + '%';
            enrollmentRecord.MtrInfo3 = volRecs;
            
            enrollmentRecord.Rx1RateInfo5 = uae.Enrollment__r.Broker_Name__c + '|' + uae.Enrollment__r.Broker_Margin__c + '|' + uae.Bill_Type__c + '|' + volRecs;
            
            enrollmentRecord.Rx2RateInfo5 = uae.Enrollment__r.Broker_Name__c + '|' + rolloverBrokerMargin + '|' + uae.Bill_Type__c + '|' + volRecs;
            
            enrollmentRecordList.add(enrollmentRecord);
            
            
            System.debug('-------------------enrollmentRecordList-----------------------');
            System.debug('BillingMethod: ' + enrollmentRecord.BillingMethod);
            System.debug('Commodity: ' + enrollmentRecord.Commodity);
            System.debug('CustomerName: ' + enrollmentRecord.CustomerName);
            System.debug('MarketerAccountNumber' + enrollmentRecord.MarketerAccountNumber);
            System.debug('RxRateClass1: ' + enrollmentRecord.RxRateClass1);
            System.debug('RxRate1: ' + enrollmentRecord.RxRate1);
            System.debug('UtilityAccountNumber: ' + enrollmentRecord.UtilityAccountNumber);
            System.debug('UtilityDunsNumber:' + enrollmentRecord.UtilityDunsNumber);            
        }
        
        //List<Integration_Log__c> intLogList = new List<Integration_Log__c>();
        List<Utility_Account_Enrollment__c> sentUAEList = new List<Utility_Account_Enrollment__c>();
        List<String> sentEnrollmentList = new List<String>();
        List<String> requestBodyList = new List<String>();
        List<String> respBodyList = new List<String>();
        List<Integer> statusCodeList = new List<Integer>();
        List<String> respStatusList = new List<String>();
        List<String> respErrorCodeList = new List<String>();
        List<String> respErrorMessageList = new List<String>();
        List<String> respAdditionalInfoList = new List<String>();
        
        NamedCredential namedCred;
        
        //query the endpoint from the named credentials
        namedCred = [SELECT DeveloperName, 
                     Endpoint 
                     FROM NamedCredential
                     WHERE DeveloperName =:'UbEnrollment'];
        String endpoint;
        if (namedCred.Endpoint != null || namedCred.Endpoint != '')
            endpoint = namedCred.Endpoint;            
        else
            endpoint = 'https://se-eaus-dev-us-intg-apim-001.azure-api.net/enrollmentservice';
        
        if(enrollmentRecordList.size()>0 && !enrollmentRecordList.isEmpty()){
            
            System.debug('EnrollmentRecordList size: ' + enrollmentRecordList.size());
            System.debug('UbEnrollment CreateEnrollment API calling');
            
            
            CallUbEnrollmentAPIBatch ubBatchObject = new CallUbEnrollmentAPIBatch(enrollmentRecordList,endpoint); 
            Id batchId = Database.executeBatch(ubBatchObject,1);
            system.debug('batchId-->'+batchId);
            system.debug('myBatchObject-->'+ubBatchObject);
        }
    }    
}