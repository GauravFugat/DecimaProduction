/*
* @Purpose: controller of Enrollment Submit component.
* @Author: Aress Dev
* @CreatedDate: 
* @Related Code: 
* @Test Class: ZnalyticsAPI_Test
* @LastModifiedDate:
* @LastModifiedBy: Rahul Ghaytadak
*/
public class SubmitEnrollment { 
    
    public class My1Exception extends Exception {} 
    
    
    public class EnrollmentWrapper{
        @AuraEnabled
        public String Code {get;set;}
        @AuraEnabled
        public String RenewCode {get;set;}
        @AuraEnabled
        public List<Utility_Account_Enrollment__c> UAE {get;set;}
        @AuraEnabled
        public List<Utility_Account_Enrollment__c> UAENotActive {get;set;}
    }
    
    @auraEnabled
    public static EnrollmentWrapper callZnalyticsAPI(Id enrollmentRecId, List<Utility_Account_Enrollment__c> selectedUAEs){
        
        EnrollmentWrapper ew = new EnrollmentWrapper();
        String Code;
        String RenewCode;
        List<Utility_Account_Enrollment__c> UAEListNotActive = [SELECT Id,Utility_Account__r.Name FROM Utility_Account_Enrollment__c
                                                                WHERE Enrollment__c =: enrollmentRecId 
                                                                AND Id IN: selectedUAEs 
                                                                AND Utility_Account__r.Status__c != 'ACT'];
        
        
        List<Utility_Account_Enrollment__c> UAEListActive = [SELECT Id,
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
                                                             WHERE Enrollment__c =: enrollmentRecId 
                                                             AND Id IN: selectedUAEs 
                                                             AND Utility_Account__r.Status__c = 'ACT'];
        
        
        
        
        List<String> Errors = new List<String>();
        if(enrollmentRecId != NULL){
            try{
                //variable Declarations
                string UAEId;
                String accId;
                String conId;
                String contractOppId;
                string OppId;
                String strPhone; 
                String strPhoneAreaCode = '';
                String enrollmentId;
                
                List<Opportunity> oppList;
                list<Utility_Account__c> utilityAccList = new list<Utility_Account__c>();
                list<Utility_Account_Opportunity__c> utilityAccOpportunityList = new list<Utility_Account_Opportunity__c>();
                List<Contact> contactList;
                list<Utility_Account_Enrollment__c> UAEList = new list<Utility_Account_Enrollment__c>();
                List<Id> Uacc = new List<Id>();
                List<Id> utilityIdList = new List<Id>();
                
                List<Enrollment__c> enrollmentList = [SELECT Contract__c, Tax_Exempt__c, Tax_Exempt_Code__c, Tax_Exempt_Certificate_Number__c, Effective_Date__c, Percentage__c, Invoice_Billing_Type__c, Account__r.ZN_CustomerId__c, Account__r.EOS_CustomerNumber__c, Sale_Type__c, Source_System__c, Langauge_Code__c, Customer_Type_Code__c, Company_Name__c, Bill_Format_Code__c, Bill_Type__c,
                                                      Contract_Source_Code__c, Sold_Date__c, Account__c, Contract_Start__c, Contract_Type_Code__c, Contract_Term__c, Name, Id, Rate_Schedule_Name__c, Rate_Amount__c, Contract_Signed_Date__c, Utility_Code__c, Contract__r.Opportunity__c
                                                      FROM Enrollment__c 
                                                      WHERE Id =: enrollmentRecId];
                if(enrollmentList.isEmpty()){
                    Errors.add('Enrollment');
                }
                
                String contractId = enrollmentList[0].Contract__c;
                
                Contract contractList = [SELECT Id, Opportunity_Id__c, AccountId, Pricebook2Id, StartDate, EndDate, BillingStreet, BillingCity, ShippingAddress, BillingState, 
                                         BillingPostalCode, BillingCountry, BillingLatitude, BillingLongitude, BillingGeocodeAccuracy, BillingAddress, 
                                         ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode, ShippingCountry, ShippingLatitude, 
                                         ShippingLongitude, ShippingGeocodeAccuracy, ContractTerm, OwnerId, Status, CompanySignedId, CompanySignedDate, 
                                         CustomerSignedId, CustomerSignedTitle, CustomerSignedDate, SpecialTerms, ActivatedById, ActivatedDate, StatusCode, 
                                         Description, IsDeleted, ContractNumber, LastApprovedDate, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, 
                                         SystemModstamp, LastActivityDate, LastViewedDate, LastReferencedDate, Opportunity__c, Total_Unit_Rate__c, Opportunity__r.Id 
                                         FROM Contract 
                                         WHERE Id =: contractId];
                
                // value sassign to variables
                enrollmentId =  enrollmentList[0].id;
                accId = enrollmentList[0].Account__c;
                conId = enrollmentList[0].Contract__c;
                contractOppId = contractList.Opportunity__r.Id;
                
                //assign the account id to variable
                if(!enrollmentList.isEmpty()){
                    enrollmentId =  enrollmentList[0].id;
                    
                    //query the Utility Account Enrollment Record
                    UAEList = [SELECT Id,Tax_Exempt_Type__c, Name, Bill_Type__c, Program_Code__c,Hold_Transaction__c, Hold_Reason_Code__c, Start_Date__c,SystemModstamp,Rate_Schedule_Name__c, Enrollment__c, Utility_Account__c, Status__c, Utility_Account__r.Commodity__c, Utility_Account__r.Name , Tax_Exempt__c, Tax_Exempt_Code__c, Effective_Date__c, Percentage__c, Tax_Exempt_Certificate_Number__c
                               FROM Utility_Account_Enrollment__c
                               WHERE Enrollment__c =: enrollmentId AND Id IN: selectedUAEs AND Utility_Account__r.Status__c != 'ACT'];
                    if(UAEList.isEmpty()){
                        Errors.add('Utility Account Enrollment');
                    }
                }
                else{
                    Errors.add('Enrollment');
                }
                system.debug('UAEList size '+UAEList.size());
                system.debug('UAEList===='+UAEList);
                //Query Account record
                list<Account> accList = [SELECT Id, Name, BillingCity, BillingState, BillingStreet, BillingPostalCode, BillingCountry   
                                         FROM Account
                                         WHERE Id =: accId];
                
                //assign the account id to variable
                Map<ID, Utility_Account_Enrollment__c> UAUAEMap = new Map<ID, Utility_Account_Enrollment__c>();
                if(!accList.isEmpty()){
                    accId =  accList[0].id;
                    
                    //query the opportunity Record 
                    oppList = [SELECT Id, AccountId, Name, StageName, Amount, Probability, CloseDate, Type, NextStep, LeadSource, IsClosed, IsWon, ForecastCategory,
                               ForecastCategoryName, CampaignId, HasOpportunityLineItem, Pricebook2Id, OwnerId, CreatedDate, CreatedById, LastModifiedDate, 
                               LastModifiedById, SystemModstamp, LastActivityDate, FiscalQuarter, FiscalYear, Fiscal, ContactId, LastViewedDate, LastReferencedDate, 
                               SyncedQuoteId, ContractId, HasOpenActivity, HasOverdueTask, Budget_Confirmed__c, Discovery_Completed__c, ROI_Analysis_Completed__c, 
                               Loss_Reason__c, Broker__c, Start_Date__c, Submit_for_Pricing__c, Urgent_Request__c, 
                               Bill_Type__c, Start_Month__c, Commodity__c, Swing_OLD__c, Send_HU_Email__c, Send_Email__c, Account_Name__c, Voluntary_Renewable_Energy__c, 
                               Tax_Exempt__c, Voluntary_Renewable_Energy_Product__c, Product_Count__c, Swing__c, Utility__c
                               FROM Opportunity 
                               WHERE AccountId =:accId AND Id = : contractOppId
                               LIMIT 1];
                    if(oppList.isEmpty()){
                        // Errors.add('Opportunity');
                    }
                    //oppId = oppList[0].id;
                    //query Utility Account Records
                    for(Utility_Account_Enrollment__c Uae : UAEList)
                    {
                        Uacc.add(Uae.Utility_Account__c);    
                        UAUAEMap.put(Uae.Utility_Account__c, Uae);
                    }
                    
                    utilityAccList = [Select Id, Name, Street__c,Utility__r.Zip_4_Required__c, Label__c, Utility__r.Utility_Code__c, Commodity__c, City__c, State__c, Zip__c, Service_Address__c, Zone__c, Service_Class__c, Label_2__c, Country__c, Utility__c
                                      From Utility_Account__c 
                                      where Id =: Uacc ];
                    if(utilityAccList.isEmpty()){
                        Errors.add('Utility Account');
                    }
                    //Query the UtiltyAccountOpportunity Records
                    Account acc = [SELECT Id,Primary_Contact__c FROM Account WHERE Id =: accId];
                    contactList = [SELECT Id, AccountId, LastName, FirstName, Salutation, MailingGeocodeAccuracy, MailingLongitude, Birthdate,
                                   MailingLatitude, MiddleName, Suffix, Name, MailingStreet, MailingCity, MailingState, MailingPostalCode, 
                                   MailingCountry, MailingAddress, Phone, Fax, MobilePhone, ReportsToId, Email, Title, Department, PhotoUrl, 
                                   Jigsaw, JigsawContactId, Primary_Contact__c FROM Contact
                                   WHERE Id =: acc.Primary_Contact__c];
                    
                    if(!contactList.isEmpty()){
                        if(contactList[0].Phone != '' || contactList[0].Phone != NULL){
                            strPhone = String.valueOf(contactList[0].Phone); 
                            system.debug('strPhone==='+strPhone);
                            if(strPhone != '' && strPhone != NULL){
                                string phoneWithoutFormatting = strPhone.replaceAll('\\D','');
                                if(phoneWithoutFormatting.length() == 10){
                                    strPhoneAreaCode = phoneWithoutFormatting.substring(0, 3);
                                    strPhone = phoneWithoutFormatting.substring(3, 10);
                                }
                                else
                                    strPhone = phoneWithoutFormatting;
                            }
                        }
                    }
                    else{
                        system.debug('Contact List is empty');
                        Errors.add('Contact');
                    }
                }
                else{
                    Errors.add('Account');
                }
                
                // Create String type data for passing into ServiceAddressList Wrapper Class
                List<string> strDatalst = new List<string>();
                
                // Create Boolean type data for passing into ServiceAddressList Wrapper Class
                List<Boolean> boolDatalst = new List<Boolean>();
                boolDatalst.add(false);
                boolDatalst.add(false);
                boolDatalst.add(false);
                boolDatalst.add(false);
                boolDatalst.add(false);
                boolDatalst.add(false);
                boolDatalst.add(false);
                boolDatalst.add(false);
                boolDatalst.add(false);
                
                // Create Integer type data for passing into ServiceAddressList Wrapper Class
                List<integer> intDatalst = new List<integer>();     
                
                
                // DocumentUrl List for Contract Wrapper Class
                list<String> docUrl = new list<String>();
                // Deposit List for Customer Wrapper Class
                List<string> depLst = new List<String>();
                // Volume List for ContractDetailList Wrapper Class
                list<String> volList = new list<String>();
                // MeterList for ServiceAccountList Wrapper Class
                List<String> MeterList = new List<String>();
                // AuthorizedContactList List for ServiceAccountList Wrapper Class
                List<String> authConlst = new List<String>();
                
                // Create List of Wrapper Classes
                List<Wrapper_Znalytics_Enrollment.ContractSegmentDetailList> contrSegDataLst = new List<Wrapper_Znalytics_Enrollment.ContractSegmentDetailList>();
                List<Wrapper_Znalytics_Enrollment.AuthorizedContactPhoneList> authConPhList = new List<Wrapper_Znalytics_Enrollment.AuthorizedContactPhoneList>();
                List<Wrapper_Znalytics_Enrollment.AuthorizedContactEmailList> authConEmail = new List<Wrapper_Znalytics_Enrollment.AuthorizedContactEmailList>();
                List<Wrapper_Znalytics_Enrollment.ContractRateSegmentList> contrRateSegLst = new List<Wrapper_Znalytics_Enrollment.ContractRateSegmentList>();
                List<Wrapper_Znalytics_Enrollment.AuthorizedContactList> authConList = new List<Wrapper_Znalytics_Enrollment.AuthorizedContactList>();
                List<Wrapper_Znalytics_Enrollment.ServiceAccountList> serAcclst = new List<Wrapper_Znalytics_Enrollment.ServiceAccountList>();
                List<Wrapper_Znalytics_Enrollment.BillingAccountList> billAcclist = new List<Wrapper_Znalytics_Enrollment.BillingAccountList>();
                List<Wrapper_Znalytics_Enrollment.Contract> contrLst = new List<Wrapper_Znalytics_Enrollment.Contract>();
                List<Wrapper_Znalytics_Enrollment.ContractDetailList> contrDetList = new List<Wrapper_Znalytics_Enrollment.ContractDetailList>();
                
                Map<String,Wrapper_Znalytics_Enrollment.tempTransaction> UATransMap = new Map<String,Wrapper_Znalytics_Enrollment.tempTransaction>();
                Map<String,Wrapper_Znalytics_Enrollment.taxExemption> UATaxExpt = new Map<String,Wrapper_Znalytics_Enrollment.taxExemption>();
                // Instantiate Constructor
                Wrapper_Znalytics_Enrollment.tempTransaction trans = new Wrapper_Znalytics_Enrollment.tempTransaction('','',False,'','','','',0,null);
                
                // Map for ServiceAddress
                Map<id, Wrapper_Znalytics_Enrollment.ServiceAddress> serviceAddressMap = new Map<id, Wrapper_Znalytics_Enrollment.ServiceAddress> ();
                for(Utility_Account__c UtilAcc : utilityAccList){
                    String zip5 = null;
                    String zip4 = null;
                    
                    try{
                        zip5 = UtilAcc.Zip__c.replaceAll('\\D','').substring(0,5);
                    }catch(Exception e){
                        zip5 = 'NULL';
                    }
                    
                    try{
                        zip4 = UtilAcc.Zip__c.replaceAll('\\D','').substring(5,9);
                    }catch(Exception e){
                        zip4 = 'NULL';
                        if(UtilAcc.Utility__r.Zip_4_Required__c && zip4 == 'NULL'){
                            Errors.add('Zip4 is required for Utility Account : '+UtilAcc.Name);
                            throw new My1Exception('First exception');
                        }
                        
                    }
                    System.debug('Zip4 Checkbox-->'+UtilAcc.Utility__r.Zip_4_Required__c);
                    System.debug('zip4-->'+zip4);
                    
                    System.debug('Errors'+Errors);
                    if(!UtilAcc.Utility__r.Zip_4_Required__c){
                        zip4=null;
                    }
                    
                    Wrapper_Znalytics_Enrollment.ServiceAddress servAddrNew= new Wrapper_Znalytics_Enrollment.ServiceAddress(UtilAcc.Street__c,UtilAcc.City__c,UtilAcc.Country__c,UtilAcc.State__c,zip5,zip4);
                    serviceAddressMap.put(UtilAcc.Id,servAddrNew);
                }
                
                // Instantiate Constructor
                String zip5 = null;
                String zip4 = null;
                
                try{
                    zip5 = utilityAccList[0].Zip__c.replaceAll('\\D','').substring(0,5);
                }catch(Exception e){
                    zip5 = 'NULL';
                }
                
                try{
                    zip4 = utilityAccList[0].Zip__c.replaceAll('\\D','').substring(5,9);
                }catch(Exception e){
                    zip4 = 'NULL';
                    if(utilityAccList[0].Utility__r.Zip_4_Required__c && zip4 == 'NULL'){
                        Errors.add('Zip4 is required for Utility Account : '+utilityAccList[0].Name);
                        throw new My1Exception('First exception');
                    }
                }
                
                
                
                Wrapper_Znalytics_Enrollment.ServiceAddress servAddr= new Wrapper_Znalytics_Enrollment.ServiceAddress(utilityAccList[0].Street__c,utilityAccList[0].City__c,utilityAccList[0].Country__c,utilityAccList[0].State__c,zip5,zip4);
                
                Wrapper_Znalytics_Enrollment.MailAddress mailAddr = new  Wrapper_Znalytics_Enrollment.MailAddress(accList[0].BillingStreet, accList[0].BillingCity,accList[0].BillingState,accList[0].BillingPostalCode,accList[0].BillingCountry); 
                
                Wrapper_Znalytics_Enrollment.LegalAddress legalAddr = new Wrapper_Znalytics_Enrollment.LegalAddress(contactList[0].ReportsToId,accList[0].BillingPostalCode ,accList[0].BillingState,accList[0].BillingCity,accList[0].BillingCountry,accList[0].BillingStreet);  
                
                Wrapper_Znalytics_Enrollment.CustomerIndividual custIndv = new Wrapper_Znalytics_Enrollment.CustomerIndividual( contactList[0].Birthdate,contactList[0].Suffix,contactList[0].LastName,contactList[0].FirstName,contactList[0].Salutation,'',true,true,0,true,'','');
                
                Wrapper_Znalytics_Enrollment.CustomerCommercial custComm = new Wrapper_Znalytics_Enrollment.CustomerCommercial(enrollmentList[0].Company_Name__c); 
                
                Wrapper_Znalytics_Enrollment.ContractSegmentDetailList contrSegData = new Wrapper_Znalytics_Enrollment.ContractSegmentDetailList(0,0);
                contrSegData.RateAmount = enrollmentList[0].Rate_Amount__c;
                contrSegDataLst.add(contrSegData);
                Wrapper_Znalytics_Enrollment.AuthorizedContactEmailList authContEmail = new Wrapper_Znalytics_Enrollment.AuthorizedContactEmailList();
                authConEmail.add(authContEmail);
                
                Wrapper_Znalytics_Enrollment.AuthorizedContactPhoneList authContPhLst = new Wrapper_Znalytics_Enrollment.AuthorizedContactPhoneList(strPhone, strPhoneAreaCode);
                authConPhList.add(authContPhLst);
                
                //contrSegDataLst.add(contrSegData);
                
                Wrapper_Znalytics_Enrollment.Contract contr = new Wrapper_Znalytics_Enrollment.Contract(contractList.Id ,contractList.ContractTerm,enrollmentList[0].Contract_Signed_Date__c,docUrl,contractList.EndDate,contractList.StartDate,contractList.Opportunity_Id__c);
                contrLst.add(contr);
                
                Wrapper_Znalytics_Enrollment.ContractDetailList contrDetLst;
                Map<Id, Wrapper_Znalytics_Enrollment.ContractRateSchedule> contrRateSchMap = new Map<Id, Wrapper_Znalytics_Enrollment.ContractRateSchedule>(); 
                Wrapper_Znalytics_Enrollment.ContractRateSegmentList contrRateSeg = new Wrapper_Znalytics_Enrollment.ContractRateSegmentList(contractList.ContractTerm, contractList.StartDate, contractList.EndDate, '', contrSegDataLst); 
                //    contrRateSegLst.add(contrRateSeg);
                
                Map<String,String> uaNamePricingGroupMap = new Map<String,String>();
                Map<String,String> uaNameRateScheduleMap = new Map<String,String>();
                for(Utility_Account_Enrollment__c uaelistTemp : UAEList){
                    uaNameRateScheduleMap.put(uaelistTemp.Utility_Account__r.Name,uaelistTemp.Rate_Schedule_Name__c);
                    if(uaelistTemp.Hold_Transaction__c == true){
                        Wrapper_Znalytics_Enrollment.tempTransaction transTopass = new Wrapper_Znalytics_Enrollment.tempTransaction(uaelistTemp.Hold_Reason_Code__c,'',uaelistTemp.Hold_Transaction__c,'','','','',0,(Datetime)uaelistTemp.Start_Date__c);
                        UATransMap.put(uaelistTemp.Utility_Account__r.Name,transTopass);
                    }
                    else{
                        Wrapper_Znalytics_Enrollment.tempTransaction transTopass = new Wrapper_Znalytics_Enrollment.tempTransaction('','',false,'','','','',0,null);
                        UATransMap.put(uaelistTemp.Utility_Account__r.Name,transTopass);
                    }
                    
                    
                    String Pricing_GroupToPass = null;
                    if(uaelistTemp.Program_Code__c!=null){
                        List<String> Pricing_Group = uaelistTemp.Program_Code__c.split('/');
                        
                        if(Pricing_Group[0]!=NULL){
                            Pricing_GroupToPass = Pricing_Group[0];
                            uaNamePricingGroupMap.put(uaelistTemp.Utility_Account__r.Name, Pricing_GroupToPass);
                        }
                    }
                    
                    Wrapper_Znalytics_Enrollment.ContractRateSchedule contrRateSch = new Wrapper_Znalytics_Enrollment.ContractRateSchedule(contractList.ContractTerm, contractList.StartDate, contractList.EndDate, uaelistTemp.Rate_Schedule_Name__c,contrRateSegLst);
                    contrRateSchMap.put(uaelistTemp.Utility_Account__r.Id,contrRateSch);    
                    //system.debug('contrRateSchMap======'+contrRateSchMap);
                    contrDetLst = new Wrapper_Znalytics_Enrollment.ContractDetailList(contractList.Opportunity_Id__c  ,contractList.StartDate,contractList.EndDate,enrollmentList[0].Contract_Type_Code__c,contrRateSchMap.get(uaelistTemp.Utility_Account__r.Id),volList,'','','','','',0,'',0,''); 
                    contrDetList.add(contrDetLst);
                }
                
                system.debug('contrRateSchMap======'+contrRateSchMap.size());
                
                Wrapper_Znalytics_Enrollment.AuthorizedContactList authContLst = new Wrapper_Znalytics_Enrollment.AuthorizedContactList( contactList[0].Birthdate,contactList[0].Primary_Contact__c,authConPhList,authConEmail,contactList[0].Salutation,contactList[0].FirstName,contactList[0].LastName,contactList[0].Suffix,'PRM','WRK' );        
                authConList.add(authContLst);
                
                //Wrapper_Znalytics_Enrollment.ServiceAccountList servAddrLst = new Wrapper_Znalytics_Enrollment.ServiceAccountList(trans,strDatalst,boolDatalst,intDatalst,authConlst,MeterList,contrDetList,servAddr);
                
                // Second Instance of AuthorizedContactList Wrapper Class
                List<Wrapper_Znalytics_Enrollment.AuthorizedContactPhoneList> authContaPhList = new List<Wrapper_Znalytics_Enrollment.AuthorizedContactPhoneList>();
                List<Wrapper_Znalytics_Enrollment.AuthorizedContactEmailList> authContEmailList = new List<Wrapper_Znalytics_Enrollment.AuthorizedContactEmailList>();
                List<Wrapper_Znalytics_Enrollment.AuthorizedContactList> authContaList = new List<Wrapper_Znalytics_Enrollment.AuthorizedContactList>();
                
                Wrapper_Znalytics_Enrollment.AuthorizedContactPhoneList authContPhList = new Wrapper_Znalytics_Enrollment.AuthorizedContactPhoneList(strPhone, strPhoneAreaCode);
                authContaPhList.add(authContPhList);
                Wrapper_Znalytics_Enrollment.AuthorizedContactEmailList authContEmailLst = new Wrapper_Znalytics_Enrollment.AuthorizedContactEmailList();
                authContEmailList.add(authContEmailLst);
                Wrapper_Znalytics_Enrollment.AuthorizedContactList authContList = new Wrapper_Znalytics_Enrollment.AuthorizedContactList(  contactList[0].Birthdate,contactList[0].Primary_Contact__c,authConPhList,authConEmail,contactList[0].Salutation,contactList[0].FirstName,contactList[0].LastName,contactList[0].Suffix,'PRM','WRK');        
                authContaList.add(authContList);
                List<Wrapper_Znalytics_Enrollment.ServiceAccountList> serviceAccountList = new List<Wrapper_Znalytics_Enrollment.ServiceAccountList>();
                List<Wrapper_Znalytics_Enrollment.ServiceAccountList> serviceAccountListfinal = new List<Wrapper_Znalytics_Enrollment.ServiceAccountList>();
                // Map for ServiceAccountList
                //new List<Wrapper_Znalytics_Enrollment.ContractDetailList>
                Map<Id, List<Wrapper_Znalytics_Enrollment.ContractDetailList>> ContractDetailListMap2 = new Map<id, List<Wrapper_Znalytics_Enrollment.ContractDetailList>>();
                Map<Id, List<Wrapper_Znalytics_Enrollment.ServiceAccountList>> ServiceAccountListMap = new Map<id, List<Wrapper_Znalytics_Enrollment.ServiceAccountList>> ();
                Map<Id, Wrapper_Znalytics_Enrollment.BillingAccountList> billAccountListMap = new Map<Id, Wrapper_Znalytics_Enrollment.BillingAccountList>(); 
                //for(Utility_Account__c UtilAcc : utilityAccList)
                List<Wrapper_Znalytics_Enrollment.ServiceAccountList> serAcclstTemp = new List<Wrapper_Znalytics_Enrollment.ServiceAccountList>();
                Integer inc = 10000;
                Wrapper_Znalytics_Enrollment.BillingAccountList billAddrLstNew;
                
                // SU:562 Pass UAE level TAX Exempt Fields to the API
                for(Utility_Account_Enrollment__c uaelistTemp : UAEList){
                    if(uaelistTemp.Tax_Exempt__c == true){
                        Wrapper_Znalytics_Enrollment.taxExemption taxExe = new Wrapper_Znalytics_Enrollment.taxExemption();
                        taxExe.effectiveDate = String.valueOf(uaelistTemp.Effective_Date__c);
                        taxExe.taxCertificateNumber = uaelistTemp.Tax_Exempt_Certificate_Number__c;
                        Wrapper_Znalytics_Enrollment.taxExemptionDetailList TEL = new Wrapper_Znalytics_Enrollment.taxExemptionDetailList();
                        TEL.taxExemptCode = uaelistTemp.Tax_Exempt_Code__c;
                        TEL.taxType = '';
                        TEL.taxExemptionAmount = uaelistTemp.Percentage__c;
                        List<Wrapper_Znalytics_Enrollment.taxExemptionDetailList> telList = new List<Wrapper_Znalytics_Enrollment.taxExemptionDetailList>();
                        telList.add(TEL);
                        taxExe.taxExemptionDetailList = telList;
                        UATaxExpt.put(uaelistTemp.Utility_Account__r.Name,taxExe);
                        system.debug('uaelistTemp.Utility_Account__r.Name==>'+uaelistTemp.Utility_Account__r.Name);
                        system.debug('taxExe==>'+taxExe);
                        system.debug('telList==>'+telList);
                    }
                    else{
                        Wrapper_Znalytics_Enrollment.taxExemption taxExe = new Wrapper_Znalytics_Enrollment.taxExemption();
                        system.debug('Tax Exmpt false');
                        taxExe = NULL;
                        UATaxExpt.put(uaelistTemp.Utility_Account__r.Name,taxExe);
                    }
                }
                for(Integer i = 0; i < utilityAccList.size(); i++){
                    serAcclst.clear();
                    strDatalst.clear();
                    strDatalst.add('');
                    strDatalst.add('');
                    strDatalst.add(''); 
                    strDatalst.add(utilityAccList[i].Name );//2019109390
                    strDatalst.add('');
                    strDatalst.add('');
                    strDatalst.add('');
                    strDatalst.add('');
                    strDatalst.add('');
                    strDatalst.add('');
                    strDatalst.add('');
                    strDatalst.add('');
                    strDatalst.add('');
                    strDatalst.add('');
                    strDatalst.add('');
                    strDatalst.add('');
                    strDatalst.add('');
                    strDatalst.add('');
                    strDatalst.add('');
                    strDatalst.add('');
                    //strDatalst.add(enrollmentList[0].Utility_Code__c);
                    strDatalst.add(utilityAccList[i].Utility__r.Utility_Code__c);
                    //strDatalst.add('');
                    if(utilityAccList[i].Commodity__c == 'Electricity'){
                        strDatalst.add('E');
                    }else if(utilityAccList[i].Commodity__c == 'Gas'){
                        strDatalst.add('G');
                    }else{}
                    strDatalst.add('');
                    strDatalst.add('');
                    strDatalst.add('');
                    strDatalst.add('');
                    strDatalst.add('');
                    strDatalst.add('');
                    strDatalst.add('');
                    strDatalst.add('');
                    strDatalst.add('');
                    strDatalst.add('');
                    strDatalst.add('');
                    strDatalst.add('');
                    strDatalst.add('');
                    strDatalst.add('');
                    strDatalst.add('');
                    strDatalst.add('');
                    strDatalst.add('');
                    
                    inc++;
                    intDatalst.add(inc);
                    // contract rate schedule list
                    //contrRateSegLst[0].RateCode = 'Count'+i;
                    contrDetLst = new Wrapper_Znalytics_Enrollment.ContractDetailList(contractList.Opportunity_Id__c ,contractList.StartDate,contractList.EndDate,enrollmentList[0].Contract_Type_Code__c,contrRateSchMap.get(utilityAccList[i].Id),volList,'','','','','',0,'',0,''); 
                    ContractDetailListMap2.put(utilityAccList[i].Id, new List<Wrapper_Znalytics_Enrollment.ContractDetailList> {contrDetLst});
                    contrDetList.add(contrDetLst);
                    
                    //  system.debug('UATaxExpt.get(utilityAccList[i].Name)==>'+UATaxExpt.get(utilityAccList[i].Name)+'utilityAccList[i].Name'+utilityAccList[i].Name);
                                     
                    Wrapper_Znalytics_Enrollment.ServiceAccountList servAccLstNew = new Wrapper_Znalytics_Enrollment.ServiceAccountList(UATransMap.get(utilityAccList[i].Name),strDatalst,utilityAccList[i].Service_Class__c, boolDatalst,intDatalst,authConlst,MeterList,ContractDetailListMap2.get(utilityAccList[i].Id),serviceAddressMap.get(utilityAccList[i].Id), UATaxExpt.get(utilityAccList[i].Name));
                    ServiceAccountListMap.put(utilityAccList[i].Id, new List<Wrapper_Znalytics_Enrollment.ServiceAccountList> {servAccLstNew});
                    serviceAccountList.add(servAccLstNew);
                    if(enrollmentList[0].Invoice_Billing_Type__c != 'Summary Billing'){
                        billAddrLstNew = new Wrapper_Znalytics_Enrollment.BillingAccountList(mailAddr,ServiceAccountListMap.get(utilityAccList[i].Id),enrollmentList[0].Sold_Date__c,authContaList,enrollmentList[0].Contract_Source_Code__c,enrollmentList[0].Bill_Format_Code__c,enrollmentList[0].Bill_Type__c,false,0,inc, '','',0,'',0,false,'','PRT','',0); 
                        billAccountListMap.put(utilityAccList[i].Id,billAddrLstNew);
                        billAccountListMap.get(utilityAccList[i].Id).BillTypeCode = UAUAEMap.get(utilityAccList[i].Id).Bill_Type__c;
                        billAcclist.add(billAccountListMap.get(utilityAccList[i].Id));
                    }
                }
                List<Wrapper_Znalytics_Enrollment.ContractDetailList> contrDetLstfinal = new List<Wrapper_Znalytics_Enrollment.ContractDetailList>();
                for(Wrapper_Znalytics_Enrollment.ServiceAccountList servAcc : serviceAccountList){
                    contrRateSegLst.clear();
                    
                    
                    Wrapper_Znalytics_Enrollment.ContractRateSegmentList contrRateSegnew = new Wrapper_Znalytics_Enrollment.ContractRateSegmentList(contractList.ContractTerm, contractList.StartDate, contractList.EndDate, uaNamePricingGroupMap.get(servAcc.UtilityAccountNumber), contrSegDataLst); 
                    
                    contrRateSegLst.add(contrRateSegnew);
                    
                    Wrapper_Znalytics_Enrollment.ContractRateSchedule contrRateSch = new Wrapper_Znalytics_Enrollment.ContractRateSchedule(contractList.ContractTerm, contractList.StartDate, contractList.EndDate, uaNameRateScheduleMap.get(servAcc.UtilityAccountNumber),new List<Wrapper_Znalytics_Enrollment.ContractRateSegmentList>{contrRateSegnew});
                    
                    Wrapper_Znalytics_Enrollment.ContractDetailList contrDetLstNew = new Wrapper_Znalytics_Enrollment.ContractDetailList(contractList.Opportunity_Id__c ,contractList.StartDate,contractList.EndDate,enrollmentList[0].Contract_Type_Code__c,contrRateSch,volList,'','','','','',0,'',0,''); 
                    
                    
                    
                    contrDetLstfinal.add(contrDetLstNew);
                    servAcc.ContractDetailList[0] = contrDetLstNew;
                    serviceAccountListfinal.add(servAcc);
                    
                }
                
                if(enrollmentList[0].Invoice_Billing_Type__c == 'Summary Billing'){
                    billAcclist.clear();
                    billAddrLstNew  = new Wrapper_Znalytics_Enrollment.BillingAccountList(mailAddr,serviceAccountList,enrollmentList[0].Sold_Date__c,authContaList,enrollmentList[0].Contract_Source_Code__c,enrollmentList[0].Bill_Format_Code__c,enrollmentList[0].Bill_Type__c,false,0,inc, '','',0,'',0,false,'','PRT','',0); 
                    billAddrLstNew.BillTypeCode = enrollmentList[0].Bill_Type__c;
                    billAcclist.add(billAddrLstNew);
                } 
                Wrapper_Znalytics_Enrollment.Customer Cust = new Wrapper_Znalytics_Enrollment.Customer(enrollmentList[0].Langauge_Code__c,
                                                                                                       authConList,
                                                                                                       billAcclist,
                                                                                                       custComm,
                                                                                                       legalAddr,
                                                                                                       custIndv,
                                                                                                       contrLst,
                                                                                                       enrollmentList[0].Account__r.EOS_CustomerNumber__c,
                                                                                                       enrollmentList[0].Customer_Type_Code__c,
                                                                                                       depLst);
                String method = 'POST';
                Boolean CreateParent = false;
                list<String> SaleDetails = new list<String>();
                String LinkToParentCustomerNumber = '';
                String CorrelationId = 'd82aaa15-7842-d55f-b1f6-46fc7c3c185b';//accList[0].id;  
                String ConfirmationNumber = 'ZN83302886';  
                String SourceSystemDetailCode  = 'ZNP';
                list<String> ActivityLog= new list<String>();
                String saleType;
                if(enrollmentList[0].Account__r.EOS_CustomerNumber__c != NULL)
                    saleType = 'ADD BILLING ACCOUNT';
                else
                    saleType = enrollmentList[0].Sale_Type__c;
                Wrapper_Znalytics_Enrollment wrapZnEnr = new Wrapper_Znalytics_Enrollment(saleType, enrollmentList[0].Source_System__c,CreateParent,Cust,SaleDetails,LinkToParentCustomerNumber,CorrelationId,ConfirmationNumber,SourceSystemDetailCode,ActivityLog);
                
                String serialized = JSON.serialize(wrapZnEnr, true);
                string stringBody = serialized.replace('tempTransaction','Transaction');   
                System.debug('stringBody'+stringBody);
                
                //call the httpclass
                HttpRequestClassZnalyticsApi newHttpReq = new HttpRequestClassZnalyticsApi();
                String responseData;
                if(UAEListNotActive.size() > 0){
                    responseData = newHttpReq.doPost(method,stringBody);
                    ew.UAENotActive = UAEListNotActive;
                }
                
                if(UAEListActive.size() > 0){
                    ew.RenewCode =   SubmitEnrollment_RenewalAPI.callRenewalEndpoint(enrollmentRecId, JSON.serialize(selectedUAEs));
                    ew.UAE = UAEListActive;
                    
                }
                system.debug('responseData-->'+responseData);
                OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'admin@decima.one'];
                
                Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                system.debug('' + System.Label.Znalytics_Debug_Email_Address);
                message.toAddresses = new String[System.Label.Znalytics_Debug_Email_Address.split(',')];
                message.subject = 'Znalytics Request Body Initiaited By - ' + UserInfo.getFirstName() + ' ' + UserInfo.getLastName();
                message.setOrgWideEmailAddressId(owea[0].Id);
                message.plainTextBody = stringBody;
                Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {message};
                    Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);  
                Map<String, Object> mapResponse = (Map<String, Object>) JSON.deserializeUntyped(responseData);
                //Map<String, Object> statusMessage = (Map<String, Object>) mapResponse.get('messages');
                Code = String.valueOf(mapResponse.get('code'));
                Integer IntegrationLogCode = Integer.valueOf(mapResponse.get('code'));
                ew.Code = Code;
                InsertIntegrationLog intog = new InsertIntegrationLog(responseData, IntegrationLogCode, enrollmentId, method, selectedUAEs); 
                System.enqueueJob(intog);
            }
            catch(Exception ex){
                //Errors.remove(null);
                
                //SU:539 changed return type to Display Error message when Required Objects fields are missing
                string allstring = string.join(Errors,',');
                System.debug('Errors Size->'+Errors.size());
                ew.Code = 'Required data objects missing : '+allstring+'.';
                ew.RenewCode = '';
                if(UAEListNotActive.size() > 0){
                    return ew;
                }
                else{
                    if(UAEListActive.size() > 0){
                        RenewCode = SubmitEnrollment_RenewalAPI.callRenewalEndpoint(enrollmentRecId, JSON.serialize(selectedUAEs));
                    }
                    return ew;
                }
            }
        }
        
        return ew;
    }
    @auraEnabled
    public static List<UAEListWrapper> getUAEs(Id recordId){
        List<UAEListWrapper> uaeList = new List<UAEListWrapper>();
        List<Utility_Account_Enrollment__c> uaeRecords = [SELECT Id,Tax_Exempt_Type__c,Enrollment__r.Contract__r.Opportunity__r.Type,Enrollment__r.Account__c,Enrollment__r.Contract_Signed_Date__c,Enrollment__r.Contract__r.StartDate,Utility_Account__r.Average_Meter_Read_Date__c, Utility_Account__r.Name, Program_Code__c, Utility_Account__r.Utility__r.Name, Rate_Schedule_Name__c, Status__c, Bill_Type__c, Utility_Account__r.Service_Address__c,Market_Rate_Code__c, Utility_Account__r.Service_Class__c,Start_Date__c,Hold_Reason_Code__c,Hold_Transaction__c,Enrollment__r.Bill_Type__c,Tax_Exempt__c, Tax_Exempt_Code__c, Effective_Date__c, Percentage__c, Tax_Exempt_Certificate_Number__c,Enrollment__r.Taxable_Portion__c,AutoSubmitFlag__c,RateClass__c,Enrollment__r.Tax_Exempt__c,Enrollment__r.Rate_Amount__c FROM Utility_Account_Enrollment__c WHERE Enrollment__c =: recordId];
        System.debug('uaeRecords---->>>>'+uaeRecords[0]);
        List<Account> accLst = [SELECT Id,Name,Primary_Contact__c FROM Account WHERE Id =: uaeRecords[0].Enrollment__r.Account__c];
        Date currentDate = Date.Today();
        boolean StartDateIsValid = false;
        boolean StartDateSet = false;
        boolean ContractSignedDateNotSet = true;
        String errorMsg = '';
          list<id> nationalUtility = new list<id>(); //suhas added
        if(accLst.size() > 0){
            if(accLst[0].Primary_Contact__c == null){
                errorMsg = ' Required data objects missing : Contact. ';
            }
        }
        else{
            errorMsg = ' Required data objects missing : Account. ';
        }
        
        if(uaeRecords[0].Enrollment__r.Contract_Signed_Date__c != null){
            ContractSignedDateNotSet = false;
        }
        
        Date ContractDate =  uaeRecords[0].Enrollment__r.Contract__r.StartDate;
        Integer monthDiff = currentDate.monthsBetween(ContractDate);
        if(monthDiff == 0 || monthDiff == 1 || monthDiff < 0){
            StartDateIsValid = true;
            StartDateSet = true;
            system.debug('--469--');
        }
         for(Utility_Account_Enrollment__c uae: uaeRecords){
                        
            if(StartDateSet == false){
                if(uae.Hold_Transaction__c == true && uae.Hold_Reason_Code__c != NULL && uae.Start_Date__c != NULL ){
                    StartDateIsValid = true;
                }
                else{
                    system.debug('--477--');
                    StartDateIsValid = false;
                    break;
                }
            }
        }
        /*
        for(Utility_Account_Enrollment__c uae: uaeRecords){
            
             if(uae.Utility_Account__r.Utility__r.Name.contains('National Grid') && uae.Bill_Type__c != 'Dual' )
             {
                 nationalUtility.add(uae.Utility_Account__c);
             }
        }  
        System.debug('nationalUtility-->'+nationalUtility);
        Map<Id,String> getProgramCodes = new Map<Id,String>();
        
        if(!nationalUtility.isEmpty())
        {
            
         	getProgramCodes = getProgramCodes(recordId,nationalUtility);
        }
		*/
        Map<Id,Decimal> uaIdEnrollRateAmt = new Map<Id,Decimal>();
        Map<Id,Id> uaeUaMap = new Map<Id,Id>();
        for(Utility_Account_Enrollment__c uae: uaeRecords){
            
            uaIdEnrollRateAmt.put(uae.Utility_Account__c,uae.Enrollment__r.Rate_Amount__c);
            uaeUaMap.put(uae.Utility_Account__c, uae.Id);
            if(uae.Utility_Account__r.Utility__r.Name.contains('National Grid') && uae.Bill_Type__c != 'Dual' )
            {
                // enrollId.add(uae.Enrollment__c);
                nationalUtility.add(uae.Utility_Account__c);
            }
        }  
        
        System.debug('nationalUtility-->'+nationalUtility);
        Map<Id,String> getProgramCodes = new Map<Id,String>();
        
        if(!nationalUtility.isEmpty())
        {
            Id nullId = null;
            getProgramCodes = getProgramCodes(nullId,nationalUtility,uaIdEnrollRateAmt,uaeUaMap);
            System.debug('getProgramCodes1111111-->'+getProgramCodes);
        }
          System.debug('getProgramCodes-->'+getProgramCodes);
        for(Utility_Account_Enrollment__c uae: uaeRecords){
             String markrtrate = '';
            if(getProgramCodes.containskey(uae.Utility_Account__c))
            {
               //  uae.Market_Rate_Code__c= String.valueOf(getProgramCodes.get(uae.Utility_Account__c));
                markrtrate =  String.valueOf(getProgramCodes.get(uae.Utility_Account__c));
                System.debug('markrtrate ->'+markrtrate);
             // markrtrate = String.valueOf(getProgramCodes.get(uae.Utility_Account__c));
            }
            else
            {
               // uae.Market_Rate_Code__c='';
                markrtrate = '';
            }
           //System.debug('markrtrate-->'+uae.Market_Rate_Code__c);
        
            uaeList.add(new UAEListWrapper(false,false,false,false,uae,false,false,false,false,StartDateIsValid,false,false,false,false,false,ContractSignedDateNotSet,errorMsg,false,markrtrate ));
        }
        
        return uaeList;
    }
    
    
    @auraEnabled
    public static List<UAEListWrapper> getDateSortedUAEs(Id recordId, boolean isAsc,String sortField) {
        List<UAEListWrapper> uaeList = new List<UAEListWrapper>();
           list<id> nationalUtility = new list<id>(); //suhas added
     
        String sSoql = 'SELECT Id,Tax_Exempt_Type__c,Enrollment__r.Rate_Amount__c,Enrollment__r.Contract__r.Opportunity__r.Type,Enrollment__r.Account__c,Enrollment__r.Contract_Signed_Date__c,Enrollment__r.Contract__r.StartDate,Utility_Account__r.Average_Meter_Read_Date__c, Utility_Account__r.Name, Program_Code__c, Utility_Account__r.Utility__r.Name, Rate_Schedule_Name__c, Status__c, Bill_Type__c, Utility_Account__r.Service_Address__c, Utility_Account__r.Service_Class__c,Start_Date__c,Hold_Reason_Code__c,Hold_Transaction__c,Enrollment__r.Bill_Type__c,Tax_Exempt__c, Tax_Exempt_Code__c, Effective_Date__c, Percentage__c, Tax_Exempt_Certificate_Number__c FROM Utility_Account_Enrollment__c WHERE Enrollment__c =: recordId order by '+sortField;
        
        if (isAsc) {
            sSoql += ' asc';
        } else {
            sSoql += ' desc';
        }
        List<Utility_Account_Enrollment__c> uaeRecords = Database.query(sSoql);
        
        List<Account> accLst = [SELECT Id,Name,Primary_Contact__c FROM Account WHERE Id =: uaeRecords[0].Enrollment__r.Account__c];
        Date currentDate = Date.Today();
        boolean StartDateIsValid = false;
        boolean StartDateSet = false;
        boolean ContractSignedDateNotSet = true;
        String errorMsg = '';
        
        if(accLst.size() > 0){
            if(accLst[0].Primary_Contact__c == null){
                errorMsg = ' Required data objects missing : Contact. ';
            }
        }
        else{
            errorMsg = ' Required data objects missing : Account. ';
        }
        
        if(uaeRecords[0].Enrollment__r.Contract_Signed_Date__c != null){
            ContractSignedDateNotSet = false;
        }
        
        Date ContractDate =  uaeRecords[0].Enrollment__r.Contract__r.StartDate;
        Integer monthDiff = currentDate.monthsBetween(ContractDate);
        if(monthDiff == 0 || monthDiff == 1 || monthDiff < 0){
            StartDateIsValid = true;
            StartDateSet = true;
            system.debug('--469--');
        }
        
        for(Utility_Account_Enrollment__c uae: uaeRecords){
                        
            if(StartDateSet == false){
                if(uae.Hold_Transaction__c == true && uae.Hold_Reason_Code__c != NULL && uae.Start_Date__c != NULL ){
                    StartDateIsValid = true;
                }
                else{
                    system.debug('--477--');
                    StartDateIsValid = false;
                    break;
                }
            }
        }
        
         Map<Id,Decimal> uaIdEnrollRateAmt = new Map<Id,Decimal>();
        Map<Id,Id> uaeUaMap = new Map<Id,Id>();
        for(Utility_Account_Enrollment__c uae: uaeRecords){
            
            uaIdEnrollRateAmt.put(uae.Utility_Account__c,uae.Enrollment__r.Rate_Amount__c);
            uaeUaMap.put(uae.Utility_Account__c, uae.Id);
            if(uae.Utility_Account__r.Utility__r.Name.contains('National Grid') && uae.Bill_Type__c != 'Dual' )
            {
                // enrollId.add(uae.Enrollment__c);
                nationalUtility.add(uae.Utility_Account__c);
            }
        }  
        
        System.debug('nationalUtility-->'+nationalUtility);
        Map<Id,String> getProgramCodes = new Map<Id,String>();
        
        if(!nationalUtility.isEmpty())
        {
            Id nullId = null;
            getProgramCodes = getProgramCodes(nullId,nationalUtility,uaIdEnrollRateAmt,uaeUaMap);
            System.debug('getProgramCodes1111111-->'+getProgramCodes);
        }
          System.debug('getProgramCodes-->'+getProgramCodes);
     
            
        for(Utility_Account_Enrollment__c uae: uaeRecords){
             String markrtrate = '';
            if(getProgramCodes.containskey(uae.Utility_Account__c))
            {
               // uae.Market_Rate_Code__c= String.valueOf(getProgramCodes.get(uae.Utility_Account__c));
                markrtrate = String.valueOf(getProgramCodes.get(uae.Utility_Account__c));
                // markrtrate = String.valueOf(getProgramCodes.containskey(uae.Utility_Account__c));
            }
            else
            {
                //uae.Market_Rate_Code__c='';
                markrtrate = '';
            }
          // System.debug('markrtrate-->'+uae.Market_Rate_Code__c);

            uaeList.add(new UAEListWrapper(false,false,false,false,uae,false,false,false,false,StartDateIsValid,false,false,false,false,false,ContractSignedDateNotSet,errorMsg,false,markrtrate));
        }
        
        return uaeList;
    }
    
    /* wrapper class */  
    public class UAEListWrapper {
        @AuraEnabled public boolean isChecked {get;set;}
        @AuraEnabled public boolean editRSN {get;set;}
        @AuraEnabled public boolean editStatus {get;set;}
        @AuraEnabled public boolean editPC {get;set;}
        @AuraEnabled public boolean editHoldReasonCode {get;set;}
        @AuraEnabled public boolean editHoldTransaction {get;set;}
        @AuraEnabled public boolean editStartDate {get;set;}
        @AuraEnabled public boolean invalidDate {get;set;}
        @AuraEnabled public boolean StartDateIsValid {get;set;}
        @AuraEnabled public boolean editTEC {get;set;}
        @AuraEnabled public boolean editEffectiveDate {get;set;}
        @AuraEnabled public boolean editPercentage {get;set;}
        @AuraEnabled public boolean editTEC_Number {get;set;}
        @AuraEnabled public boolean editTax_Exempt {get;set;}
        @AuraEnabled public boolean editTET {get;set;}
           
        @AuraEnabled public  Utility_Account_Enrollment__c objUAE{get;set;}
        @AuraEnabled public boolean contractSignedDate {get;set;}
        @AuraEnabled public string errorMsg {get;set;}
        @AuraEnabled public String marketRateCode {get;set;}
        public UAEListWrapper(boolean isChecked, boolean editRSN, boolean editStatus, boolean editPC, Utility_Account_Enrollment__c objUAE,boolean editHoldReasonCode,boolean editHoldTransaction,boolean editStartDate,boolean invalidDate,boolean StartDateIsValid, boolean editTEC,boolean editEffectiveDate,boolean editPercentage,boolean editTEC_Number,boolean editTax_Exempt,boolean contractSignedDate,String errorMsg,Boolean editTET,String marketRateCode){
            this.isChecked = isChecked;
            this.editRSN = editRSN;
            this.editStatus = editStatus;
            this.editPC = editPC;
            this.objUAE = objUAE;
            this.editHoldReasonCode = editHoldReasonCode;
            this.editHoldTransaction = editHoldTransaction;
            this.editStartDate = editStartDate;
            this.invalidDate = invalidDate;
            this.StartDateIsValid = StartDateIsValid;
            this.editTEC = editTEC;
            this.editEffectiveDate = editEffectiveDate;
            this.editPercentage = editPercentage;
            this.editTEC_Number = editTEC_Number;
            this.editTax_Exempt = editTax_Exempt;
            this.contractSignedDate = contractSignedDate;
            this.errorMsg = errorMsg;
            this.editTET = editTET;
            this.marketRateCode =marketRateCode;
        }
    }
    
 /*   @auraEnabled
    public static EnrollmentWrapper submitEnrollment(Id recordId, List<Utility_Account_Enrollment__c> objUAEs){
        //SU:539 changed return type to Display Error message when Required Objects fields are missing
        EnrollmentWrapper ew = SubmitEnrollment.callZnalyticsAPI(recordId, objUAEs);
        system.debug('ew  ' + ew);
        return ew;
    }*/
    
     @auraEnabled
    public static EnrollmentWrapper submitEnrollment(Id recordId, List<Utility_Account_Enrollment__c> objUAEs){
        List<Id> UAENotActiveIdList = new List<Id>();
		List<Id> UAEActiveIdList = new List<Id>();
         system.debug('objUAEs-->'+objUAEs);
        List<Utility_Account_Enrollment__c> objUAEActive = [SELECT Id,
                                                                Utility_Account__r.Name,
                                                                Utility_Account__r.Account__r.Name,
                                                                Market_Rate_Code__c,
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
                                                                Enrollment__r.SalesCommissionUOM__c
                                                                FROM Utility_Account_Enrollment__c
                                                                WHERE Id =: objUAEs 
                                                                AND Utility_Account__r.Status__c = 'Active'
                                                                ];
		
		List<Utility_Account_Enrollment__c> objUAENotActive = [SELECT Id,
                                                                Utility_Account__r.Name,
                                                                Utility_Account__r.Account__r.Utility_Short_Name__c,
                                                                Market_Rate_Code__c,
                                                                Utility_Account__r.Account__r.Name,                                                                
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
                                                                Enrollment__r.SalesCommissionUOM__c
                                                                FROM Utility_Account_Enrollment__c
                                                                WHERE Id =: objUAEs 
                                                                AND Utility_Account__r.Status__c != 'Active'
                                                                ];
        
        System.debug('objUAEs==>>'+objUAEs[0].Market_Rate_Code__c);
        
        for(Utility_Account_Enrollment__c uae : objUAEActive){
                UAEActiveIdList.add(uae.Id);
        }
        
        for(Utility_Account_Enrollment__c uae : objUAENotActive){
                UAENotActiveIdList.add(uae.Id);
        }
        EnrollmentWrapper ew = new EnrollmentWrapper();
        try
        {
            CallUbEnrollmentAPI.callUBAPI(recordId,UAENotActiveIdList);
        	System.debug('objUAENotActive==>>'+objUAENotActive);
            
            CallUbRateClassServiceAPI.callUBRenewal(recordId,UAEActiveIdList);
        	System.debug('objUAEActive==>>'+objUAEActive);
                        
        	ew.Code = '200';
            ew.RenewCode = '200';
            ew.UAENotActive = objUAENotActive;
            ew.UAE = objUAEActive;
        }
        catch(Exception ex){
            ew.code = '500';
            ew.RenewCode = '500';
            ew.UAENotActive = objUAENotActive;
            ew.UAE = objUAEActive;
        }
                
        return ew;
        
       // for(Utility_Account_Enrollment__c uae : objUAEs){
            // CallUbEnrollmentAPI.callUBAPI(recordId,);
       // }
       // 
      // List<Utility_Account_Enrollment__c> objUAEs = [SELECT Id FROM Utility_Account_Enrollment__c WHERE Id =:recordId];
       /* System.debug('SubmitUbEnrollment called');
        System.debug('Enrollment Record Id: ' + recordId);
        System.debug('Selected UAE size: ' + objUAEs.size());
        List<Utility_Account_Enrollment__c> UAEListNotActive = [SELECT Id,
                                                                Utility_Account__r.Name,
                                                                Enrollment__r.Commodity__c,
                                                                Utility_Account__r.Account__r.Name,
                                                                Utility_Account__r.Utility__r.Utility_DUNS__c,
                                                                Start_Date__c,
                                                                AutoSubmitFlag__c,
                                                                RateClass__c,
                                                                Enrollment__r.Rate_Amount__c,
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
                                                                Rate_Schedule_Name__c,
                                                                Utility_Account__r.Street__c,
                                                                Utility_Account__r.Street_2__c,
                                                                Utility_Account__r.City__c,
                                                                Utility_Account__r.State__c,
                                                                Utility_Account__r.Zip__c,
                                                                Program_Code__c,
                                                                Utility_Account__r.Commodity__c,
                                                                Utility_Account__r.Account__r.Marketer_Account_Number__c,
                                                                Utility_Account__r.Account__r.Id,
                                                                Bill_Type__c,
                                                                Enrollment__r.Contract__r.Product__r.Family,
																Utility_Account__r.Account__r.Customer_ID__c,
																Enrollment__r.Contract__r.Commission_Type__c,
																Enrollment__r.Contract__r.Opportunity__r.Commission_Discount__c,
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
                                                                Enrollment__r.SalesCommissionUOM__c
                                                                FROM Utility_Account_Enrollment__c
                                                                WHERE Id IN: objUAEs 
                                                                AND Utility_Account__r.Status__c != 'ACT'
                                                               	];*/
      //  for(Utility_Account_Enrollment__c uae : UAEListNotActive){
       // CallUbEnrollmentAPI.callUBAPI(recordId,uae);
       // }
        // 
       // 
       // 
    }
    /* Created Invocable method for it   
    @auraEnabled
    public static void submitUbEnrollment(Id recordId, List<Utility_Account_Enrollment__c> objUAEs) {
        System.debug('SubmitUbEnrollment called');
        System.debug('Enrollment Record Id: ' + recordId);
        System.debug('Selected UAE size: ' + objUAEs.size());
        
        List<Utility_Account_Enrollment__c> UAEListNotActive = [SELECT Id,
                                                                Utility_Account__r.Name,
                                                                Enrollment__r.Commodity__c,
                                                                Utility_Account__r.Account__r.Name,
                                                                Utility_Account__r.Utility__r.Utility_DUNS__c,
                                                                Enrollment__r.Contract__r.StartDate,
                                                                Enrollment__r.Rate_Amount__c,
                                                                Utility_Account__r.Account__r.phone,
                                                                Utility_Account__r.Utility__r.Bill_Type__c,
                                                                Utility_Account__r.Account__r.BillingStreet,
                                                                Utility_Account__r.Account__r.BillingCity,
                                                                Utility_Account__r.Account__r.BillingState,
                                                                Utility_Account__r.Account__r.BillingPostalCode,
                                                                Utility_Account__r.Account__r.Primary_Contact__r.Email,
                                                                Utility_Account__r.Account__r.Primary_Contact__r.Name,
                                                                Enrollment__r.Contract__r.Opportunity__r.Id,
                                                                Enrollment__r.Contract_Term__c,
                                                                Enrollment__r.Product__c,
                                                                Rate_Schedule_Name__c,
                                                                Utility_Account__r.Street__c,
                                                                Utility_Account__r.Street_2__c,
                                                                Utility_Account__r.City__c,
                                                                Utility_Account__r.State__c,
                                                                Utility_Account__r.Zip__c,
                                                                Program_Code__c,
                                                                Utility_Account__r.Commodity__c,
                                                                Utility_Account__r.Account__r.Marketer_Account_Number__c,
                                                                Utility_Account__r.Account__r.Id
                                                                FROM Utility_Account_Enrollment__c
                                                                WHERE Enrollment__c =: recordId 
                                                                AND Id IN: objUAEs 
                                                                AND Utility_Account__r.Status__c != 'ACT'];
        System.debug('UAEListNotActive' + UAEListNotActive);
        Set<String> recId = new Set<String>();
        List<Wrapper_UbEnrollment.EnrollmentData> enrollmentRecordList = new List<Wrapper_UbEnrollment.EnrollmentData>();
        for (Utility_Account_Enrollment__c uae : UAEListNotActive) {
            Wrapper_UbEnrollment.EnrollmentData enrollmentRecord = new Wrapper_UbEnrollment.EnrollmentData();
            enrollmentRecord.AccountClassName = 'Standard';
            enrollmentRecord.AccountType = 'Residential';
            enrollmentRecord.BillingMethod = 'UtilityRateReady'; //uae.Utility_Account__r.Utility__r.Bill_Type__c;
            enrollmentRecord.Commodity = 'Electric'; // uae.Utility_Account__r.Commodity__c;
            enrollmentRecord.CustomerName = uae.Utility_Account__r.Account__r.Name;
            if(uae.Utility_Account__r.Account__r.Marketer_Account_Number__c == '' || uae.Utility_Account__r.Account__r.Marketer_Account_Number__c == null){
                enrollmentRecord.MarketerAccountNumber = '';
                recId.add(uae.Utility_Account__r.Account__r.Id);
            }else{
                enrollmentRecord.MarketerAccountNumber = uae.Utility_Account__r.Account__r.Marketer_Account_Number__c;
            }   
            enrollmentRecord.MarketerDunsNumber = 'Smartest Energy_Sandbox_Duns';
            enrollmentRecord.RxRateClass1 =  uae.Rate_Schedule_Name__c;
            enrollmentRecord.RateClassStatus = 'ActiveRateClass';
            enrollmentRecord.RateClassName = 'PECHKOxZF7003p76.03720.07273Upp';
            enrollmentRecord.RxRate1 =uae.Enrollment__r.Rate_Amount__c;
            enrollmentRecord.RequestType = 'EnrollmentRequest';
            enrollmentRecord.UtilityAccountNumber = uae.Utility_Account__r.Name;
            enrollmentRecord.UtilityDunsNumber =   uae.Utility_Account__r.Utility__r.Utility_DUNS__c;
            enrollmentRecord.RecordType = 'AddEnrollment';
            
            enrollmentRecord.ContractStart = uae.Enrollment__r.Contract__r.StartDate;
            if((uae.Utility_Account__r.Utility__r.Bill_Type__c).Contains('Dual')){
                enrollmentRecord.BusinessPhone = uae.Utility_Account__r.Account__r.phone;
                enrollmentRecord.BillingEmail = uae.Utility_Account__r.Account__r.Primary_Contact__r.Email;
            }
            enrollmentRecord.BillingAddress1 = uae.Utility_Account__r.Account__r.BillingStreet;
            
            enrollmentRecord.BillingCity = uae.Utility_Account__r.Account__r.BillingCity;
            enrollmentRecord.BillingState = uae.Utility_Account__r.Account__r.BillingState; 
            enrollmentRecord.BillingZip = uae.Utility_Account__r.Account__r.BillingPostalCode;
            enrollmentRecord.ContactName = uae.Utility_Account__r.Account__r.Primary_Contact__r.Name;
            enrollmentRecord.MtrInfo2 = uae.Enrollment__r.Contract__r.Opportunity__r.Id;
            enrollmentRecord.RxTerm1 = Integer.valueOf(uae.Enrollment__r.Contract_Term__c);
            enrollmentRecord.MtrInfo1 = uae.Enrollment__r.Product__c;
            
            enrollmentRecord.SvcAddress1 = uae.Utility_Account__r.Street__c;
            enrollmentRecord.SvcAddress2 = uae.Utility_Account__r.Street_2__c;
            enrollmentRecord.SvcCity = uae.Utility_Account__r.City__c;
            enrollmentRecord.SvcState = uae.Utility_Account__r.State__c;
            enrollmentRecord.SvcZip = uae.Utility_Account__r.Zip__c;
            enrollmentRecord.UtilityRateCode = uae.Program_Code__c;

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

        if(enrollmentRecordList.size()>0 && !enrollmentRecordList.isEmpty()){
            System.debug('EnrollmentRecordList size: ' + enrollmentRecordList.size());
            System.debug('UbEnrollment CreateEnrollment API calling');
            List<Wrapper_UbEnrollmentResponse> enrollmentResponseList = new List<Wrapper_UbEnrollmentResponse>();
            for (Wrapper_UbEnrollment.EnrollmentData enrollmentRecord : enrollmentRecordList) {
                Wrapper_UbEnrollmentResponse enrollmenResponse = CallUbEnrollmentAPI.CreateNewEnrollment(enrollmentRecord);
                if(enrollmenResponse != null){
                    enrollmentResponseList.add(enrollmenResponse);
                }
            }

            System.debug('------ UbEnrollment Response --------');

        }
        
    } */
    
    ////// for UpdateRateClassSchedule
    /*
@auraEnabled
public static void UpdateRateClassSchedule(Id recordId, List<Utility_Account_Enrollment__c> objUAEs) {


List<Utility_Account_Enrollment__c> UAEListNotActive = [SELECT Id,
Utility_Account__r.Name,
Enrollment__r.Commodity__c,
Utility_Account__r.Account__r.Name,
Utility_Account__r.Utility__r.Utility_DUNS__c,
Enrollment__r.Contract__r.StartDate,
Enrollment__r.Rate_Amount__c,
Utility_Account__r.Account__r.phone,
Utility_Account__r.Utility__r.Bill_Type__c,
Utility_Account__r.Account__r.BillingStreet,
Utility_Account__r.Account__r.BillingCity,
Utility_Account__r.Account__r.BillingState,
Utility_Account__r.Account__r.BillingPostalCode,
Utility_Account__r.Account__r.Primary_Contact__r.Email,
Utility_Account__r.Account__r.Primary_Contact__r.Name,
Enrollment__r.Contract__r.Opportunity__r.Id,
Enrollment__r.Contract_Term__c,
Enrollment__r.Product__c,
Rate_Schedule_Name__c,
Utility_Account__r.Street__c,
Utility_Account__r.Street_2__c,
Utility_Account__r.City__c,
Utility_Account__r.State__c,
Utility_Account__r.Zip__c,
Program_Code__c
FROM Utility_Account_Enrollment__c
WHERE Enrollment__c =: recordId 
AND Id IN: objUAEs 
AND Utility_Account__r.Status__c != 'ACT'];
System.debug('UAEListNotActive' + UAEListNotActive);
List<UpdateRateClassSchedule_W1.RateClassIdentifier> RateClassIdentifierList = new List<UpdateRateClassSchedule_W1.RateClassIdentifier>();
List<Wrapper_UbEnrollment.EnrollmentData> enrollmentRecordList = new List<Wrapper_UbEnrollment.EnrollmentData>();
for (Utility_Account_Enrollment__c uae : UAEListNotActive) {
//Wrapper_UbEnrollment.EnrollmentData enrollmentRecord = new Wrapper_UbEnrollment.EnrollmentData();
UpdateRateClassSchedule_W1.RateClassIdentifier rateClassIdentifierRec = new UpdateRateClassSchedule_W1.RateClassIdentifier();
rateClassIdentifierRec.Commodity = uae.Utility_Account__r.Commodity__c;
//enrollmentRecord.Commodity = uae.Enrollment__r.Commodity__c;
enrollmentRecord.CustomerName = uae.Utility_Account__r.Account__r.Name;
enrollmentRecord.UtilityAccountNumber = uae.Utility_Account__r.Name;
enrollmentRecord.UtilityDunsNumber = uae.Utility_Account__r.Utility__r.Utility_DUNS__c;
enrollmentRecord.ContractStart = uae.Enrollment__r.Contract__r.StartDate;
enrollmentRecord.RxRate1 = uae.Enrollment__r.Rate_Amount__c;
if((uae.Utility_Account__r.Utility__r.Bill_Type__c).Contains('Dual')){
enrollmentRecord.BusinessPhone = uae.Utility_Account__r.Account__r.phone;
enrollmentRecord.BillingEmail = uae.Utility_Account__r.Account__r.Primary_Contact__r.Email;
}
enrollmentRecord.BillingAddress1 = uae.Utility_Account__r.Account__r.BillingStreet;
enrollmentRecord.BillingCity = uae.Utility_Account__r.Account__r.BillingCity;
enrollmentRecord.BillingState = uae.Utility_Account__r.Account__r.BillingState; 
enrollmentRecord.BillingZip = uae.Utility_Account__r.Account__r.BillingPostalCode;
enrollmentRecord.ContactName = uae.Utility_Account__r.Account__r.Primary_Contact__r.Name;
enrollmentRecord.MtrInfo2 = uae.Enrollment__r.Contract__r.Opportunity__r.Id;
enrollmentRecord.RxTerm1 = Integer.valueOf(uae.Enrollment__r.Contract_Term__c);
enrollmentRecord.MtrInfo1 = uae.Enrollment__r.Product__c;
enrollmentRecord.BillingMethod = uae.Utility_Account__r.Utility__r.Bill_Type__c;
enrollmentRecord.RxRateClass1 = uae.Rate_Schedule_Name__c;
enrollmentRecord.SvcAddress1 = uae.Utility_Account__r.Street__c;
enrollmentRecord.SvcAddress2 = uae.Utility_Account__r.Street_2__c;
enrollmentRecord.SvcCity = uae.Utility_Account__r.City__c;
enrollmentRecord.SvcState = uae.Utility_Account__r.State__c;
enrollmentRecord.SvcZip = uae.Utility_Account__r.Zip__c;
enrollmentRecord.UtilityRateCode = uae.Program_Code__c;
enrollmentRecordList.add(enrollmentRecord);
System.debug('-------------------EnrollmentRecord: ---------------');
System.debug('MarketerAccountNumber' + enrollmentRecord.MarketerAccountNumber);
System.debug('Commodity: ' + enrollmentRecord.Commodity);
System.debug('CustomerName: ' + enrollmentRecord.CustomerName);
System.debug('UtilityAccountNumber: ' + enrollmentRecord.UtilityAccountNumber);
System.debug('UtilityDunsNumber:' + enrollmentRecord.UtilityDunsNumber);
System.debug('ContractStart: ' + enrollmentRecord.ContractStart);
System.debug('RxRate1: ' + enrollmentRecord.RxRate1);
}


if(enrollmentRecordList.size()>0 && !enrollmentRecordList.isEmpty()){
System.debug('EnrollmentRecordList size: ' + enrollmentRecordList.size());
System.debug('UbEnrollment CreateEnrollment API calling');
List<Wrapper_UbEnrollment.EnrollmentReturnTypeOfEnrollmentKey> enrollmentResponseList = CallUbEnrollmentAPI.CreateNewEnrollment(enrollmentRecordList);
System.debug('------ UbEnrollment Response --------');
for (Wrapper_UbEnrollment.EnrollmentReturnTypeOfEnrollmentKey enrollmentResponse : enrollmentResponseList) {
System.debug(enrollmentResponse);
System.debug('Integration logs: -----------------');
Set<String> keys = new Set<String>();
//enrollmentResponse.outputHttpHeaders_x = new Map<String, String>();
System.debug('');


}
// Generate Integration logs 
}

}


//
*/
    
    @auraEnabled
    public static String saveUAE(List<Utility_Account_Enrollment__c> objUAE){
        String response ='';
        if(Utility_Account_Enrollment__c.sObjectType.getDescribe().isUpdateable()){
            update objUAE;
            response = 'success';
        }
        else
            response = 'Insufficient Access!';
        return response;
    }
    
    
    @auraEnabled	
    public static Map<Id,String> getProgramCodes(Id enrollmentId, List<Id> UAs, Map<Id,Decimal> uaIdEnrollRateAmt, Map<Id,Id> uaeUaMap){
       // Enrollment__c eRecord = [SELECT Id, Rate_Amount__c FROM Enrollment__c WHERE Id =: enrollmentId];
       // List<Utility_Account__c> UAList = [SELECT Id, Zone__c, Commodity__c,Service_Class__c,Market_Rate_Code__c FROM Utility_Account__c WHERE Id IN : UAs];
      //System.debug('UAList-->'+UAList);
        //Map<Id,List<Program_Code__c>> UAPMap = new Map<Id,List<Program_Code__c>>();
        Map<Id,String> UAPMap = new Map<Id,String>();
        Set<Decimal> rates = new Set<Decimal>(); 
        if(uaIdEnrollRateAmt.keySet().size()>0) {
            for(Id uaID : uaIdEnrollRateAmt.keySet()) {
                if(uaIdEnrollRateAmt.get(uaID) != null) {
                    rates.add(uaIdEnrollRateAmt.get(uaID));
                }
            }
        }
        
        List<Program_Code__c> programCodes = [SELECT Id, Commodity__c, Program_Number__c, Pricing_Group__c, Effective_Date__c, Termination_Date__c, Rate__c, ISO_Zone__c,Service_Class__c 
                                              FROM Program_Code__c
                                              where Effective_Date__c < TODAY and 
                                                    Rate__c IN:rates and 
                                                    Termination_Date__c = null and 
                                                    Service_Class__c != null];
        System.debug('250 Programcodes -->'+programCodes);
        //List<Utility_Account__c> UAList1 = new List<Utility_Account__c>();    
        Integer UAcount=0; 
        Integer PCcount =0;
        List<Utility_Account_Enrollment__c> UAEList = new List<Utility_Account_Enrollment__c>();
        
        for(Utility_Account__c ua: [SELECT Id, Zone__c, Commodity__c,Service_Class__c,Market_Rate_Code__c 
                                    FROM Utility_Account__c 
                                    WHERE Id IN : UAs and Service_Class__c != null]){ //UAList
                                        //System.debug('count UA -->'+UAcount++);
            for(Program_Code__c pc: programCodes){
                  //System.debug('count PC -->'+PCcount++);
                //if(/*pc.ISO_Zone__c == ua.Zone__c && */pc.Rate__c == eRecord.Rate_Amount__c && pc.Termination_Date__c == NULL && ua.Commodity__c.startsWith(pc.Commodity__c)){
             
                //if(pc.Effective_Date__c < system.today() && pc.Rate__c == uaIdEnrollRateAmt.get(ua.Id) && pc.Termination_Date__c == NULL && ua.Commodity__c.startsWith(pc.Commodity__c)){           
                if(pc.Rate__c == uaIdEnrollRateAmt.get(ua.Id) && ua.Commodity__c.startsWith(pc.Commodity__c)){               
                    //if (pc.Service_Class__c != null){
                   if (!pc.Service_Class__c.contains('|')){     
                    if (pc.Service_Class__c.contains(ua.Service_Class__c)){
                            if(!UAPMap.containsKey(ua.Id)){                                    
                                //ua.Market_Rate_Code__c = pc.Pricing_Group__c + pc.Program_Number__c;   
                                Utility_Account_Enrollment__c uae = new Utility_Account_Enrollment__c();
                                uae.Market_Rate_Code__c = pc.Pricing_Group__c + pc.Program_Number__c; 
                                uae.Id = uaeUaMap.get(ua.Id);
                                //UAList1.add(ua);
                                UAEList.add(uae);
                                UAPMap.put(ua.Id,uae.Market_Rate_Code__c);                                    
                            }   
                        }
                    
                   }else{
                            List<String> serviceClassList = pc.Service_Class__c.split('\\|');                            
                            for(String sc: serviceClassList){
                                if (sc == ua.Service_Class__c){
                                 
                                    if(!UAPMap.containsKey(ua.Id)){
                                     Utility_Account_Enrollment__c uae = new Utility_Account_Enrollment__c();
                                        uae.Market_Rate_Code__c = pc.Pricing_Group__c + pc.Program_Number__c; 
                                         uae.Id = uaeUaMap.get(ua.Id);
                                        UAEList.add(uae);
                                        UAPMap.put(ua.Id,uae.Market_Rate_Code__c);                                        
                                       
                                    }
                                }
                            }
                   }
                    
                                                  
                    //}
                    
                }
            }
        }
        /*if(UAList1!=null){
            update UAList1;
        }*/
        if(UAEList!=null){
            update UAEList;
        }

        system.debug('UAPMap ' + UAPMap.Values());
        return UAPMap;
    } 
        
    /*public static Map<Id,String> getProgramCodes(Id enrollmentId, List<Id> UAs){
        Enrollment__c eRecord = [SELECT Id, Rate_Amount__c FROM Enrollment__c WHERE Id =: enrollmentId];
        List<Utility_Account__c> UAList = [SELECT Id, Zone__c, Commodity__c,Service_Class__c,Market_Rate_Code__c FROM Utility_Account__c WHERE Id IN : UAs];
      System.debug('UAList-->'+UAList);
        //Map<Id,List<Program_Code__c>> UAPMap = new Map<Id,List<Program_Code__c>>();
        Map<Id,String> UAPMap = new Map<Id,String>();
        List<Program_Code__c> programCodes = [SELECT Id, Commodity__c, Program_Number__c, Pricing_Group__c, Effective_Date__c, Termination_Date__c, Rate__c, ISO_Zone__c,Service_Class__c FROM Program_Code__c];
        List<Utility_Account__c> UAList1 = new List<Utility_Account__c>();
 System.debug('programCodes.size-->'+programCodes.size());
         System.debug('UAList.size-->'+UAList.size());
        for(Utility_Account__c ua: UAList){
            for(Program_Code__c pc: programCodes){
                //if(/*pc.ISO_Zone__c == ua.Zone__c && pc.Rate__c == eRecord.Rate_Amount__c && pc.Termination_Date__c == NULL && ua.Commodity__c.startsWith(pc.Commodity__c)){
                
                if(pc.Effective_Date__c < system.today() && pc.Rate__c == eRecord.Rate_Amount__c && pc.Termination_Date__c == NULL && ua.Commodity__c.startsWith(pc.Commodity__c)){
                    System.Debug('PC-->' + pc.Id);
                    if (pc.Service_Class__c != null){
                        if (!pc.Service_Class__c.contains('|')){
                            if (pc.Service_Class__c == ua.Service_Class__c){
                                if(!UAPMap.containsKey(ua.Id)){                                    
                                    ua.Market_Rate_Code__c = pc.Pricing_Group__c + pc.Program_Number__c;                                    
                                    UAList1.add(ua);
                                    UAPMap.put(ua.Id,ua.Market_Rate_Code__c);                                    
                                }                                
                            }
                        }else{
                            List<String> serviceClassList = pc.Service_Class__c.split('\\|');                            
                            for(String sc: serviceClassList){
                                if (sc == ua.Service_Class__c){
                                    if(!UAPMap.containsKey(ua.Id)){
                                        ua.Market_Rate_Code__c = pc.Pricing_Group__c + pc.Program_Number__c;                                        
                                        UAList1.add(ua);
                                        UAPMap.put(ua.Id,ua.Market_Rate_Code__c);                                        
                                    }
                                }
                            }
                        }
                    }
                    
                }
            }
        }
        if(UAList1!=null){
            update UAList1;
        }
        system.debug('UAPMap ' + UAPMap.Values());
        return UAPMap;
    } */
    @AuraEnabled        
    public static List<String> getHoldReasonPicValIntoList(){
        //List<String> pickListValuesList = new List<String>();
        List<String> optionlist = new List<String>(); 
        Schema.DescribeFieldResult fieldResult = Utility_Account_Enrollment__c.Hold_Reason_Code__c.getDescribe();
        List<Schema.PicklistEntry> picklistValues = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry pv : picklistValues) {
            optionlist.add(pv.getValue());
        }
        return optionlist;
    } 
       public class UAField{
        @AuraEnabled public String ITS_Tag{get; set;}
        @AuraEnabled public String ITS_Tag_Future{get; set;}
        @AuraEnabled public String apacity_Tag{get; set;}
        @AuraEnabled public String apacity_Tag_Future{get; set;}
        @AuraEnabled public String apacity_Tag_Future1{get; set;}
        @AuraEnabled public String apacity_Tag_Future2{get; set;}
        @AuraEnabled public String apacity_Tag_Future3{get; set;}
    }
}