//ZnalyticsAPI_Test
public class SubmitEnrollment_RenewalAPI {
    
    public class RenewalWrapper{
        public Integer contractTerm{get;set;}
        public String contractSignedDate{get;set;}
        public list<contractDetails> contractDetails{get;set;}
        public String renewalDateOptionCode{get;set;}
        public String saleDetails{get;set;}
        public String previousContractNumber{get;set;}
        public String documentUrl{get;set;}
        public String customerNumber{get;set;}
    }
    public class contractSegmentDetailList{
        public Integer ContractSegmentDetailId{get;set;}
        public Decimal rateAmount{get;set;}
    }
    public class contractRateSegmentList{
        public list<contractSegmentDetailList> contractSegmentDetailList{get;set;}
    }
    public class contractRateSchedule{
        public String rateChangeEffectiveDate{get;set;}
        public String utilityRateCode{get;set;}
        public String rateChangeScheduledDate{get;set;}
        public String rolloverRateScheduleName{get;set;}
        public list<contractRateSegmentList> contractRateSegmentList{get;set;}
        public String rateScheduleName{get;set;}
    }
    public class contractDetails{
        public String commissionTypeCode{get;set;}
        public String salesAgencyCode{get;set;}
        public String salesAgent{get;set;}
        public Integer brokerFee{get;set;}
        public String salesAgentCode{get;set;}
        public Integer channelFee{get;set;}
        public String salesChannelCode{get;set;}
        public String contractEndDate{get;set;}
        public String salesChannelPartnerCode{get;set;}
        public String contractStartDate{get;set;}
        public String volumes{get;set;}
        public String utilityAccountNumber{get;set;}
        public contractRateSchedule contractRateSchedule{get;set;}
        public String contractNumber{get;set;}
    }
    
    
    public static String callRenewalEndpoint(Id enrollmentId,String selectedUAEsString){
        List<Utility_Account_Enrollment__c> selectedUAEs = new List<Utility_Account_Enrollment__c>();
        selectedUAEs = (List<Utility_Account_Enrollment__c>) System.JSON.deserialize(selectedUAEsString, List<Utility_Account_Enrollment__c>.class);
        
        List<Utility_Account_Enrollment__c> UAEList = [SELECT Id,
                                                       Tax_Exempt_Type__c,
                                                       Name,
                                                       Bill_Type__c,
                                                       Program_Code__c,
                                                       Hold_Transaction__c,
                                                       Hold_Reason_Code__c,
                                                       Start_Date__c,
                                                       SystemModstamp,
                                                       Rate_Schedule_Name__c,
                                                       Enrollment__c,
                                                       Utility_Account__c,
                                                       Status__c,
                                                       Utility_Account__r.Commodity__c,
                                                       Utility_Account__r.Name ,
                                                       Tax_Exempt__c,
                                                       Tax_Exempt_Code__c,
                                                       Effective_Date__c,
                                                       Percentage__c,
                                                       Tax_Exempt_Certificate_Number__c
                                                       FROM Utility_Account_Enrollment__c
                                                       WHERE Enrollment__c =: enrollmentId AND Id IN: selectedUAEs AND Utility_Account__r.Status__c = 'ACT'];
        
        List<Enrollment__c> enrollmentList = [SELECT Contract__c, Tax_Exempt__c, Tax_Exempt_Code__c, Tax_Exempt_Certificate_Number__c, Effective_Date__c, Percentage__c, Invoice_Billing_Type__c, Account__r.ZN_CustomerId__c, Account__r.EOS_CustomerNumber__c, Sale_Type__c, Source_System__c, Langauge_Code__c, Customer_Type_Code__c, Company_Name__c, Bill_Format_Code__c, Bill_Type__c,
                                              Contract_Source_Code__c, Sold_Date__c, Account__c, Contract_Start__c, Contract_Type_Code__c, Contract_Term__c, Name, Id, Rate_Schedule_Name__c, 
                                              Rate_Amount__c, Contract_Signed_Date__c, Utility_Code__c, Contract__r.Opportunity__c
                                              FROM Enrollment__c 
                                              WHERE Id =: enrollmentId];
        
        String contractId = enrollmentList[0].Contract__c;
        System.debug('contractId==>>'+contractId);
        Contract contractList = [SELECT Id, Opportunity_Id__c, AccountId, Pricebook2Id, StartDate, EndDate, BillingStreet, BillingCity, ShippingAddress, BillingState, 
                                 BillingPostalCode, BillingCountry, BillingLatitude, BillingLongitude, BillingGeocodeAccuracy, BillingAddress, 
                                 ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode, ShippingCountry, ShippingLatitude, 
                                 ShippingLongitude, ShippingGeocodeAccuracy, ContractTerm, OwnerId, Status, CompanySignedId, CompanySignedDate, 
                                 CustomerSignedId, CustomerSignedTitle, CustomerSignedDate, SpecialTerms, ActivatedById, ActivatedDate, StatusCode, 
                                 Description, IsDeleted, ContractNumber, LastApprovedDate, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, 
                                 SystemModstamp, LastActivityDate, LastViewedDate, LastReferencedDate, Opportunity__c, Total_Unit_Rate__c, Opportunity__r.Id,Opportunity__r.Existing_Contract__r.Opportunity_Id__c 
                                 FROM Contract 
                                 WHERE Id =: contractId];
        
        UAEList = [SELECT Id,Enrollment__r.Rate_Amount__c,Enrollment__r.Contract__r.Opportunity_ID__c,Enrollment__r.Contract__r.StartDate,Enrollment__r.Contract__r.EndDate,Tax_Exempt_Type__c, Name, Bill_Type__c, Program_Code__c,Hold_Transaction__c, Hold_Reason_Code__c, Start_Date__c,SystemModstamp,Rate_Schedule_Name__c, Enrollment__c, Utility_Account__c, Status__c, Utility_Account__r.Commodity__c, Utility_Account__r.Name , Tax_Exempt__c, Tax_Exempt_Code__c, Effective_Date__c, Percentage__c, Tax_Exempt_Certificate_Number__c
                   FROM Utility_Account_Enrollment__c
                   WHERE Enrollment__c =: enrollmentId AND Id IN: selectedUAEs AND Utility_Account__r.Status__c = 'ACT'];
        
        System.debug('UAELst->'+UAEList);
        RenewalWrapper renewWrapper = new RenewalWrapper();
        renewWrapper.contractTerm = contractList.ContractTerm;
        renewWrapper.contractSignedDate = String.valueOf(contractList.CompanySignedDate);
        renewWrapper.renewalDateOptionCode = 'CCED';
        renewWrapper.previousContractNumber = contractList.Opportunity__r.Existing_Contract__r.Opportunity_Id__c;
        renewWrapper.customerNumber = enrollmentList[0].Account__r.EOS_CustomerNumber__c;
        
        List<contractDetails> contractDetailsLst = new List<contractDetails>();
        contractRateSchedule crs = new contractRateSchedule();
        List<contractRateSegmentList> crSegmentLst = new List<contractRateSegmentList>();
        List<contractSegmentDetailList> crSegmentDetailLst = new List<contractSegmentDetailList>();
        contractRateSegmentList contractRateSegmentListObj = new contractRateSegmentList();
        
        for(Utility_Account_Enrollment__c uae : UAEList ){
            contractDetails cd = new contractDetails();
            cd.contractNumber = '';
            cd.utilityAccountNumber = uae.Utility_Account__r.Name;
            cd.contractStartDate = String.valueOf(uae.Enrollment__r.Contract__r.StartDate);
            cd.contractEndDate = String.valueOf(uae.Enrollment__r.Contract__r.EndDate);
            cd.channelFee = 0;
            cd.brokerFee = 0;
            cd.salesChannelPartnerCode = String.valueOf(1018);
            cd.volumes = null;
            cd.contractNumber = uae.Enrollment__r.Contract__r.Opportunity_ID__c;
            
            
            crs.rateScheduleName = uae.Rate_Schedule_Name__c;
            
            System.debug('crs->'+crs);
            
            
            
            contractSegmentDetailList contractSegmentDetailListObj = new contractSegmentDetailList();
            contractSegmentDetailListObj.ContractSegmentDetailId = 0;
            contractSegmentDetailListObj.rateAmount = uae.Enrollment__r.Rate_Amount__c ;
            if(crSegmentDetailLst.size() == 0){
                crSegmentDetailLst.add(contractSegmentDetailListObj);
                System.debug('crSegmentDetailLst->'+crSegmentDetailLst);
            }
            
            
            
            contractRateSegmentListObj.contractSegmentDetailList = crSegmentDetailLst;
            if(crSegmentLst.size() == 0){
                crSegmentLst.add(contractRateSegmentListObj);
            }
            System.debug('crSegmentLst->'+crSegmentLst);
            crs.contractRateSegmentList = crSegmentLst;
            cd.contractRateSchedule = crs;
            contractDetailsLst.add(cd);
            
        }
        System.debug('contractDetailsLst->'+contractDetailsLst);
        renewWrapper.contractDetails = contractDetailsLst;
        System.debug('JSON->'+JSON.serialize(renewWrapper));
        
        HttpRequestClassZnalyticsApi newHttpReq = new HttpRequestClassZnalyticsApi();
        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'admin@decima.one'];
        
        String responseData = newHttpReq.doPostRenewal('POST',JSON.serialize(renewWrapper));
        system.debug('*******responseData-->'+responseData);
        
        
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        system.debug('' + System.Label.Znalytics_Debug_Email_Address);
        message.toAddresses = new String[System.Label.Znalytics_Debug_Email_Address.split(',')];
        message.subject = 'Renewal Znalytics Request Body Initiaited By - ' + UserInfo.getFirstName() + ' ' + UserInfo.getLastName();
        message.setOrgWideEmailAddressId(owea[0].Id);
        message.plainTextBody = JSON.serialize(renewWrapper);
        Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {message};
            Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);  
        Map<String, Object> mapResponse = (Map<String, Object>) JSON.deserializeUntyped(responseData);
        //Map<String, Object> statusMessage = (Map<String, Object>) mapResponse.get('messages');
        String Code = String.valueOf(mapResponse.get('code'));
        Integer IntegrationLogCode = Integer.valueOf(mapResponse.get('code'));
        
        InsertIntegrationLog intog = new InsertIntegrationLog(responseData, IntegrationLogCode, enrollmentId, 'POST', UAEList); 
        intog.endpoint = System.Label.Renewal_Endpoint;
        System.enqueueJob(intog);
        return Code;
        
    }
    
}