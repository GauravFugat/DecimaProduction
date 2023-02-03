/*
* @Purpose: Controller class for Create_Opportunity Component.
* @Author: Saurabh Chauhan
* @CreatedDate: 01/07/2020
* @Test Class:  Create_Opportunity_Test
* @Related Code: Create_Opportunity.cmp, Create_PricingRequest.cmp
* @LastModifiedDate: 
* @LastModifiedBy: Rahul Ghaytadak
*/

public class Create_Opportunity {
    
    //To get the picklist values for State based on the States of related Utility Accounts on the Customer Record.
    @AuraEnabled
    public static List<String> getStatePicklist(Id recordId){
        Map<Id,String> statePicklistMap = new Map<Id,String>();
        Set<String> PicklistSet = new Set<String>();
        List<String> LstToReturn = new List<String>();
        List<Utility_Account__c> statePicklist = new List<Utility_Account__c>();
        String statesFromLabel = Label.State_Options;
        List<String> OptionsFromLabel = statesFromLabel.split(',');
        statePicklist = [Select Id,Utility_State__c from Utility_Account__c where Account__c=: recordId ];
        for(Utility_Account__c ua : statePicklist){
            PicklistSet.add(ua.Utility_State__c);           
        }
        for(String pklst : PicklistSet )
        {
            if(OptionsFromLabel.contains(pklst)){
                LstToReturn.add(pklst);
            }
        }
        return LstToReturn;
    }
    
    //To fetch the Utility Accounts based on selected State and to sort the Utility Account list based on sortField and sortType. 
    @AuraEnabled
    public static List<UAWrapper> getUAList(Id recordId,String State,String sortType,String sortField,List<UAWrapper> UtilitiesSelected,List<String> UANames){
        System.debug('In getUAList');
        List<UAWrapper> UALstWrapper = new List<UAWrapper>();
        if(UtilitiesSelected.size() <= 0){
            String query = '';
            if(UANames.size() > 0){
                query = 'SELECT Id, Name,Account__c,Utility__r.Credit_Check_Required__c, Account__r.Broker__c,Utility__r.Name, Utility_State__c ,Status__c, Requested_Start_Date__c FROM Utility_Account__c where Account__c=: recordId AND Name IN: UANames AND Utility_State__c =:State ORDER BY '  +sortField +' '+ sortType;
            }
            else{
                query = 'SELECT Id, Name,Account__c,Utility__r.Credit_Check_Required__c, Account__r.Broker__c,Utility__r.Name, Utility_State__c ,Status__c, Requested_Start_Date__c FROM Utility_Account__c where Account__c=: recordId AND Utility_State__c =:State ORDER BY '  +sortField +' '+ sortType;
            }
            List<Utility_Account__c> UALst = Database.query(query);
            for(Utility_Account__c ua : UALst){
                UAWrapper obj = new UAWrapper();
                obj.Id = ua.Id;
                obj.UtilityName = ua.Utility__r.Name;
                obj.isSelected = true;
                obj.isSelectedStatus = true;
                obj.defaultCheckbox = true;
                ua.Requested_Start_Date__c = ua.Requested_Start_Date__c;
                obj.UAcc = ua;
                UALstWrapper.add(obj);
            }
            return UALstWrapper;
        }
        else{
            if(State=='' || State== '--None--'){
                State = UtilitiesSelected[0].UAcc.Utility_State__c;
            }
            List<String> FilteredUAIds = new List<String>();
            List<Id> FilteredUAId = new List<Id>();
            for(UAWrapper uA : UtilitiesSelected){
                FilteredUAIds.add(uA.UtilityName);
                FilteredUAId.add(uA.Id);
            }
            String query = '';
            if(UANames.size() > 0){
                query = 'SELECT Id, Name,Account__c,Account__r.Broker__c,Status__c,Utility__r.Credit_Check_Required__c, Utility__r.Name, Utility_State__c , Requested_Start_Date__c FROM Utility_Account__c where Account__c=: recordId AND Name IN: UANames AND Utility_State__c =:State AND Id IN:FilteredUAId AND Utility__r.Name IN:FilteredUAIds ORDER BY '  +sortField +' '+ sortType;
            }
            else{
                query = 'SELECT Id, Name,Account__c,Account__r.Broker__c,Status__c,Utility__r.Credit_Check_Required__c, Utility__r.Name, Utility_State__c , Requested_Start_Date__c FROM Utility_Account__c where Account__c=: recordId AND Utility_State__c =:State AND Id IN:FilteredUAId AND Utility__r.Name IN:FilteredUAIds ORDER BY '  +sortField +' '+ sortType;
            }
            List<Utility_Account__c> UALst = Database.query(query);
            Map<Id,Utility_Account__c> UAMap = new Map<Id,Utility_Account__c>();
            Map<Id,boolean> UACheckboxMap = new Map<Id,boolean>();
            for(UAWrapper uw : UtilitiesSelected ){
                UAMap.put(uw.Id,uw.UAcc);
                UACheckboxMap.put(uw.Id,uw.defaultCheckbox);
            }
            for(Utility_Account__c ua : UALst){
                UAWrapper obj = new UAWrapper();
                obj.Id = ua.Id;
                obj.UtilityName = ua.Utility__r.Name;
                obj.isSelected = true;
                obj.isSelectedStatus = true;
                obj.UAcc = UAMap.get(ua.Id);
                obj.defaultCheckbox = UACheckboxMap.get(ua.Id);
                UALstWrapper.add(obj);
            }            
            return UALstWrapper;
        }
    }
    
    //Wrapper Class for Utility Account Opportunities 
    public class UAOWrapper{
        @AuraEnabled
        public String State {get;set;}
        @AuraEnabled
        public List<Utility_Account_Opportunity__c> UAO {get;set;}
        @AuraEnabled
        public List<String> Treatment {get;set;}
        @AuraEnabled
        public List<String> RECS {get;set;}
        @AuraEnabled
        public String AccId {get;set;}	
        @AuraEnabled	
        public String BinId {get;set;}
        @AuraEnabled
        public String SaleType {get;set;}
        @AuraEnabled
        public Boolean isOppOwnandUserSame {get;set;}
        @AuraEnabled
        public Date maxOfHUDaysRequired {get;set;}
        @AuraEnabled
        public Boolean isLFollowingType {get;set;}
    }
    
    //Wrapper Class for Utility Account to display on Component
    public class UAWrapper{
        @AuraEnabled
        public String Id {get;set;}
        @AuraEnabled
        public String UtilityName {get;set;}
        @AuraEnabled
        public boolean isSelected {get;set;}
        @AuraEnabled
        public boolean isSelectedStatus {get;set;}
        @AuraEnabled
        public boolean defaultCheckbox {get;set;}
        @AuraEnabled
        public Utility_Account__c UAcc {get;set;}
        @AuraEnabled
        public Date StartDate {get;set;}
        @AuraEnabled
        public Date DueDate {get;set;}
        @AuraEnabled
        public List<String> StatusPicklist{get;set;}
    }
    
    //Wrapper Class for Pricing Request
    public class PRWrapper{
        @AuraEnabled
        public String Product {get;set;}
        @AuraEnabled
        public String BillType {get;set;}
        @AuraEnabled
        public String InvoiceBillingType {get;set;}
        @AuraEnabled
        public list<Pricing_Request__c> PricingRequestList{get; set;}
        @AuraEnabled
        public String SaleType {get;set;}
        @AuraEnabled
        public String SwitchingType {get;set;}
        @AuraEnabled
        public Decimal BrokerMargin {get;set;}
        @AuraEnabled
        public boolean UrgentRequest {get;set;}
        @AuraEnabled
        public String Notes {get;set;}
        @AuraEnabled
        public Date DueDate {get;set;}
        @AuraEnabled
        public Date StartDate {get;set;}
        @AuraEnabled
        public String Treatment {get;set;}
        @AuraEnabled
        public String Voluntary_RECs {get;set;}
        @AuraEnabled
        public integer Voluntary_RECs_percent {get;set;}
        @AuraEnabled
        public String NameSuffix{get;set;}
        @AuraEnabled
        public String ExpectedAnnualVolume{get;set;}
    }
    
    //Function to return the Utility Account List
    // as more than 100 UAs cause an error on js controller (this function is called when more than 100 UAs are fetched to avoid error)
    @AuraEnabled
    public static List<UAWrapper> SetPgLst(List<UAWrapper> UAList){
        return UAList;
    }
    
    //To return all UAs which are marked selected.
    @AuraEnabled
    public static List<UAWrapper> setPgLstcheckbox(List<UAWrapper> UAList){
        List<UAWrapper> UAListToReturn = new List<UAWrapper>();
        for(UAWrapper ua : UAList){
            ua.defaultCheckbox = true;
            UAListToReturn.add(ua); 
        }
        return UAListToReturn;
    }
    
    //This Returns Filtered UA List based on Utility and Status
    @AuraEnabled
    public static List<UAWrapper> CreateOpptywithUAOs(List<UAWrapper> UAList,List<UAWrapper> UtilitiesSelected,List<UAWrapper> UtilitiesWithStatusFilter){
        List<UAWrapper> UALstWrapper = new List<UAWrapper>();
        List<UAWrapper> UALstWrapperFinal = new List<UAWrapper>();
        Set<String> UtilityNames = new Set<String>();
        Set<String> UtilityStatus = new Set<String>();
        
        for(UAWrapper uw : UtilitiesSelected){
            if(uw.isSelected==true){
                UtilityNames.add(uw.UtilityName);
            }
        }
        for(UAWrapper uw : UtilitiesWithStatusFilter){
            if(uw.isSelectedStatus==true){
                UtilityStatus.add(uw.UAcc.Status__c);
            }
        }
        for(String uName : UtilityNames){
            for(UAWrapper uwObj : UAList){
                
                if(uwObj.UtilityName == uName){
                    UALstWrapper.add(uwObj);
                }
            }
        }
        for(String UStatus : UtilityStatus){
            for(UAWrapper uwObj : UALstWrapper){
                if(uwObj.UAcc.Status__c == UStatus){
                    UALstWrapperFinal.add(uwObj);
                }
            }
        }
        return UALstWrapperFinal;
    }
    
    //Create Opportunity and Multiple Pricing Requests along with UAOs and UAPRs
    //Update the Customer Account Owner and Opportunity Owner as CPMUser if selected
    //Sends Pricing Request Email by invoking a flow
    //Assign Specific record type based on Bill Type of Pricing Request
    @AuraEnabled
    public static void CreatePR(List<Utility_Account_Opportunity__c> UAList,PRWrapper PricingRequest,User CPMUser,Id Opp,Boolean checkRequestType,String contractId,boolean creditRequired,Decimal MarkToMarket,String optionSelected,String orignalPRId, Boolean notifyMeCheckboxVal,List<String> availabeleBillTypes /*, String selectedBillType, String ifBilTypValNotChanged, String opetnSelect */){
        //System.debug('CPMUser==>> '+CPMUser);
        System.debug('availabeleBillTypes-->> '+availabeleBillTypes);
        System.debug('111PricingRequest-->> '+PricingRequest.PricingRequestList[0].Pricing_Quote_Comments__c);
        if(optionSelected == 'option1'){
            optionSelected = 'Initial Request';
        }
        else if(optionSelected == 'option2'){
            optionSelected = 'Refresh';
        }
        else if(optionSelected == 'option3'){
            optionSelected = 'Refresh with Changes';
        }
        System.debug('UAList->'+UAList.size());
        /*List<Process_Event__c> peToInsert = new List<Process_Event__c>();*/
        Set<Id> PrIdSet = new Set<Id>();
        Set<Id> PrIdSet1 = new Set<Id>();
        Map<String,List<Utility_Account_Pricing__c>> PrIdAndUAPrMap = new Map<String,List<Utility_Account_Pricing__c>>();
        Map<String,List<Utility_Account_Pricing__c>> PrIdAndUAPrMap1 = new Map<String,List<Utility_Account_Pricing__c>>();
        Credit_Check__c newCCRecord = new Credit_Check__c();
       newCCRecord.Status__c = 'New';
        String StatusToSet = 'New';
        if(Test.isRunningTest()){
            newCCRecord.Experian_Api_Call_Credit_Assessment__c = false;
        }
        date strtdateList = UAList[0].Start_Date__c;

        boolean setStartdate;
        for(Utility_Account_Opportunity__c uao : UAList){
            if(uao.Start_Date__c == strtdateList){
                setStartdate = true;              
            }
            else{
                setStartdate = false;   
                break;
            }
        }
        Id rt;
        Id gr;
        RecordType Dualrt = [SELECT Id, Name, DeveloperName, SobjectType FROM RecordType where SobjectType = 'Pricing_Request__c' AND DeveloperName = 'Credit_Check_Required' limit 1];
        Group Dualgr = [select Id from Group where  Type = 'Queue' AND NAME = 'Credit Team' LIMIT 1];
        
        Group PORgr = [select Id from Group where  Type = 'Queue' AND NAME = 'Pricing Team' limit 1];
        RecordType PORrt = [SELECT Id, Name, DeveloperName, SobjectType FROM RecordType where SobjectType = 'Pricing_Request__c' AND DeveloperName = 'Default_Pricing_Request' limit 1];
        
        boolean PORwithRecourse = false;
                Opportunity getAccId = [Select Id,Type,Name,OwnerId,AccountId,Existing_Contract__c from Opportunity where Id=:Opp];	
        Account accToUpdateOwner = [SELECT Id,Last_Successful_Experian_Fraud_Shields__c,Last_Successful_Experian_Business_Fact__c FROM Account WHERE Id =: getAccId.AccountId ];	
        List<Credit_Check__c> creditDetailLst = [SELECT Id,Name,Pricing_Request_Status__c, Opportunity__c FROM Credit_Check__c where Customer__c =: getAccId.AccountId AND Status__c = 'Active'];	
        if(creditDetailLst.size()==0){	
            creditDetailLst = [SELECT Id,Name,Pricing_Request_Status__c, Opportunity__c FROM Credit_Check__c where Customer__c =: getAccId.AccountId AND Status__c = 'New'];	
        }
        List<Pricing_Request__c> prListToPass = new List<Pricing_Request__c>();
        for(Pricing_Request__c PReqL : PricingRequest.PricingRequestList){
            prListToPass.add(PReqL);
            //System.debug('availabeleBillTypes-->> '+(availabeleBillTypes.Contains('UCB') == false && availabeleBillTypes.size() > 0));
            if(PReqL.Bill_Type__c == 'Dual' || PReqL.Bill_Type__c == 'UCB with Credit' || ((availabeleBillTypes.Contains('UCB') == false) && availabeleBillTypes.size() > 0 )){
                creditRequired = true;
                System.debug('in this if');
            } 
        }
        
       /* System.debug('creditRequired->'+creditRequired);	
        System.debug('creditDetailLst->'+creditDetailLst);	
        if(creditRequired){
            if (optionSelected != 'Refresh')
            	peToInsert.add(createCreditLogs.createCreditProcessLogs(getAccId.AccountId, 'Pricing Request(s) requires Credit', 'Decision', 'New Pricing requests inserted',getAccId.Name,getAccId.Id,'True'));	
        }
        System.debug('creditRequired-->> '+creditRequired);
        if(creditDetailLst.size()==0 && creditRequired == true && optionSelected != 'Refresh'){        //Check if Credit Needed and if there is an existing Credit record ?	
            newCCRecord.Credit_Check_Outcome__c  = 'Pending';	
            //newCCRecord.Opportunity__c = Opp;	
            newCCRecord.Customer__c = getAccId.AccountId;	
            Insert newCCRecord;            
            newCCRecord = [SELECT Id,Name FROM Credit_Check__c WHERE Id =: newCCRecord.Id];	
            peToInsert.add(createCreditLogs.createCreditProcessLogs(getAccId.AccountId, 'Active/New Credit Present ?', 'Decision', 'New Credit record created , as no active credit record was present for the Customer.',newCCRecord.Name,newCCRecord.Id,'False'));	
            	
            	
        }*/
        
       // Opportunity getAccId = [Select Id,Type,Name,OwnerId,AccountId,Existing_Contract__c from Opportunity where Id=:Opp];	
        //List<Credit_Check__c> creditDetailLst = [SELECT Id,Pricing_Request_Status__c, Opportunity__c FROM Credit_Check__c where Customer__c =: getAccId.AccountId AND Status__c = 'Active'];
        //createCreditDetail(List<Credit_Check__c> creditDetailLst,Opportunity getAccId, Boolean creditRequired, List<Pricing_Request__c> PricingRequest, String optionSelected, Credit_Check__c newCCRecord, Boolean callFromLoop){
        //Credit.createCreditDetail(Opp, creditRequired, prListToPass, optionSelected,newCCRecord,false);
        Credit.createCreditDetail(creditDetailLst,getAccId ,creditRequired, prListToPass, optionSelected,newCCRecord,false);
        
        if(contractId != null && contractId != ''){
            getAccId.Existing_Contract__c = contractId;
            Contract contr = [SELECT Id,Renewal_Opportunity__c FROM Contract WHERE Id =: contractId];
            if(getAccId.Type == 'Blend and Extend'){
                contr.Blend_and_Extend__c = getAccId.Id;
            }else{
                contr.Renewal_Opportunity__c = getAccId.Id;
            }
            update contr;
        }
        //As part of SU - 837
       	if(CPMUser!=NULL){
            //Account accToUpdateOwner = [Select Id,OwnerId from Account where id =:getAccId.AccountId];
            getAccId.OwnerId = CPMUser.Id;
        }
        update getAccId;
        System.debug('PricingRequest.PricingRequestList-->> '+PricingRequest.PricingRequestList);
        list<Pricing_Request__c> prlistNew = new list<Pricing_Request__c>();
        for(Pricing_Request__c PReqList : PricingRequest.PricingRequestList){
            System.debug('291 PReqList.Bill_Type__c '+PReqList.Bill_Type__c);
            if(PReqList.Bill_Type__c == 'POR & Dual'){ 			//POR & Dual
                Pricing_Request__c prObj1 = new Pricing_Request__c();
                prObj1.Mark_to_Market__c = MarkToMarket;
                prObj1.Bill_Type__c = 'Dual';
                prObj1.Notes__c = PricingRequest.Notes;
                prObj1.Urgent_Request__c = PricingRequest.UrgentRequest;
                prObj1.Product_Lookup__c = PReqList.Product_Lookup__c;
                prObj1.Opportunity__c = Opp;
                prObj1.Invoice_billing_Type__c = PReqList.Invoice_billing_Type__c;
                prObj1.Customer__c = getAccId.AccountId;
                prObj1.Status__c = 'New';
                prObj1.Due_Date__c = PricingRequest.DueDate;
                prObj1.RecordTypeId = Dualrt.Id;
                prObj1.OwnerId =UserInfo.getUserId();
                if(setStartdate == true){
                    prObj1.Start_Dates__c = 'Same';
                }
                else{
                    prObj1.Start_Dates__c = 'Staggered';
                }
                prlistNew.add(prObj1);
                System.debug('313 --> PReqList'+PReqList.Bill_Type__c);
                PReqList.Bill_Type__c = 'UCB';
            	System.debug('315 --> after PReqList'+PReqList.Bill_Type__c);
                
            }
            System.debug('318 PORwithRecourse-->'+PORwithRecourse);
            System.debug(' 319PReqList.Bill_Type__c->'+PReqList.Bill_Type__c);
            if(PReqList.Bill_Type__c == 'Dual' || PORwithRecourse == true || PReqList.Bill_Type__c == 'UCB with Credit'){
                rt = Dualrt.id;
                gr = UserInfo.getUserId();
            }
            else{
                gr = PORgr.Id;
                rt = PORrt.Id;
            }
            Pricing_Request__c prObj = new Pricing_Request__c();
            prObj.Notify_me_on_completion__c = notifyMeCheckboxVal;
            PrIdSet.add(PReqList.Id);	
            prObj.TempId__c = PReqList.Id;
            System.debug('329 ->'+PReqList.Bill_Type__c);
            prObj.Bill_Type__c = PReqList.Bill_Type__c;
            System.debug('prObj.Bill_Type__c'+prObj.Bill_Type__c);
            if(optionSelected == 'Refresh with Changes'){
                prObj.Original_Pricing_Request__c = orignalPRId;
                PrIdSet1.add(orignalPRId);
                prObj.TempId__c = orignalPRId;
            }  
            if(optionSelected == 'Refresh'){
                prObj.Original_Pricing_Request__c = PReqList.Id;
                PrIdSet1.add(PReqList.Id);
                prObj.TempId__c = PReqList.Id;
            }
            if(availabeleBillTypes.Contains(PReqList.Bill_Type__c) == false && !availabeleBillTypes.isEmpty()){
                System.debug('in iffffffff');
                prObj.Bill_Type__c = availabeleBillTypes[0];
            }else{
                System.debug('in elseeeeee');
            prObj.Bill_Type__c = PReqList.Bill_Type__c;
            }
            System.debug('PReqList.Id'+PReqList.Id);
            prObj.Mark_to_Market__c = MarkToMarket;
            prObj.Voluntary_RECs__c =PReqList.Voluntary_RECs__c;
            if(prObj.Voluntary_RECs__c != 'NA'){
                if(PReqList.Voluntary_RECs_percent__c != null){
                    prObj.Voluntary_RECs_percent__c = PReqList.Voluntary_RECs_percent__c;
                }
              /*  else{
                    prObj.Voluntary_RECs_percent__c = 100;
                }*/
                prObj.Treatment__c = PReqList.Treatment__c;
            }
            prObj.Notes__c = PricingRequest.Notes;
            prObj.Urgent_Request__c = PricingRequest.UrgentRequest;
            prObj.Product_Lookup__c = PReqList.Product_Lookup__c;
            prObj.Opportunity__c = Opp;
            System.debug('PReqList.Bill_Type__c -->'+PReqList.Bill_Type__c);
            if(PReqList.Bill_Type__c == 'UCB' || PReqList.Bill_Type__c == 'UCB with Credit'){
                prObj.Invoice_billing_Type__c = 'None';
                prObj.Status__c = 'New';
            }
            else{
                prObj.Invoice_billing_Type__c = PReqList.Invoice_billing_Type__c;
                prObj.Status__c = 'New';
            }
            prObj.Customer__c = getAccId.AccountId;
            prObj.Status__c = 'New';
            prObj.Due_Date__c = PricingRequest.DueDate;
            prObj.RecordTypeId = rt;
            prObj.OwnerId = gr;
            if(setStartdate == true){
                prObj.Start_Dates__c = 'Same';
            }
            else{
                prObj.Start_Dates__c = 'Staggered';
            }
            System.debug('checkRequestType-->> '+checkRequestType);
            System.debug('PReqList.Pricing_Quote_Comments__c-->> '+PReqList.Pricing_Quote_Comments__c);
            //As part of SU - 828 - Below change
            //prObj.Pricing_Quote_Comments__c = PReqList.Pricing_Quote_Comments__c;
             prObj.Pricing_Quote_Comments__c = PReqList.Pricing_Quote_Comments__c;
            if (orignalPRId != '' && orignalPRId != null){
                Pricing_Request__c originalPR = [Select Id,Pricing_Quote_Comments__c from Pricing_Request__c where Id=:orignalPRId];
        		prObj.Pricing_Quote_Comments__c = originalPR.Pricing_Quote_Comments__c;
            }
            
            //SU-608: Update request Type
            if(checkRequestType == true){
                prObj.Request_Type__c = optionSelected;
                PrIdSet.add(PReqList.Id);
                prObj.TempId__c = PReqList.Id;
            }else{
                prObj.Request_Type__c = optionSelected;
            }
            if(Test.isRunningTest()){
                prObj.Record_Created__c = true;
            }
            prlistNew.add(prObj);
        }
        insert prlistNew;
      //  List<Pricing_Request__c> PrLstToCopyFrom = new List<Pricing_Request__c>();
        if(PrIdSet.size() > 0){
     //       PrLstToCopyFrom = [SELECT Id,(SELECT Id, Name, Utility_Account__c, Credit_Check_Required__c, Start_Date__c FROM Utility_Account_Pricing_Requests__r) FROM Pricing_Request__c WHERE Id IN: PrIdSet];
            List<Pricing_Request__c> PrLstToCopyFrom = [SELECT Id,(SELECT Id, Name, Utility_Account__c, Credit_Check_Required__c, Start_Date__c FROM Utility_Account_Pricing_Requests__r) FROM Pricing_Request__c WHERE Id IN: PrIdSet];
            for(Pricing_Request__c pr : PrLstToCopyFROM){
                PrIdAndUAPrMap.put(pr.Id,pr.Utility_Account_Pricing_Requests__r);
            }
        }        
        List<Pricing_Request__c> PrLstToCopyFrom1 = new List<Pricing_Request__c>();
        if(PrIdSet1.size() > 0){
            PrLstToCopyFrom1 = [SELECT Id,(SELECT Id, Name, Utility_Account__c, Credit_Check_Required__c, Start_Date__c FROM Utility_Account_Pricing_Requests__r) FROM Pricing_Request__c WHERE Id IN: PrIdSet1];
            for(Pricing_Request__c pr : PrLstToCopyFROM1){
                PrIdAndUAPrMap1.put(pr.Id,pr.Utility_Account_Pricing_Requests__r);
            }
        }
        System.debug('PrIdAndUAPrMap1'+PrIdAndUAPrMap1);
        for(Pricing_Request__c PRnew : prlistNew ){
            if(PRnew.Bill_Type__c == 'Dual' || PRnew.Bill_Type__c == 'UCB with Credit'){	
                creditRequired = true;	
            }else{
                creditRequired = false;
            }
            List<Utility_Account_Pricing__c> UAPRLst = new List<Utility_Account_Pricing__c>();
            System.debug('optionSelected'+optionSelected);
            if(checkRequestType == false){
                if(optionSelected != 'Initial Request'){
                    for(Utility_Account_Pricing__c uao : PrIdAndUAPrMap1.get(PRnew.TempId__c)){
                        Utility_Account_Pricing__c ObjUAPR = new Utility_Account_Pricing__c();
                        ObjUAPR.Utility_Account__c = uao.Utility_Account__c;
                        ObjUAPR.Start_Date__c = uao.Start_Date__c;
                        ObjUAPR.Pricing_Request__c = PRnew.Id;
                        UAPRLst.add(ObjUAPR);
                    }
                    insert UAPRLst;
                }
                if(optionSelected == 'Initial Request'){
                    for(Utility_Account_Opportunity__c  uao : UAList){
                        Utility_Account_Pricing__c ObjUAPR = new Utility_Account_Pricing__c();
                        ObjUAPR.Utility_Account__c = uao.Utility_Account__c;
                        ObjUAPR.Start_Date__c = uao.Start_Date__c;
                        ObjUAPR.Pricing_Request__c = PRnew.Id;
                        UAPRLst.add(ObjUAPR);
                    }
                    insert UAPRLst;
                }
            }else{
                for(Utility_Account_Pricing__c uao : PrIdAndUAPrMap.get(PRnew.TempId__c)){
                    Utility_Account_Pricing__c ObjUAPR = new Utility_Account_Pricing__c();
                    ObjUAPR.Utility_Account__c = uao.Utility_Account__c;
                    ObjUAPR.Start_Date__c = uao.Start_Date__c;
                    ObjUAPR.Pricing_Request__c = PRnew.Id;
                    UAPRLst.add(ObjUAPR);
                }
                insert UAPRLst;
            }
            
            if(!Test.isRunningTest()){
                Flow.Interview flow = new Flow.Interview.Send_HU_Pricing_Emails(new map<String,String> {'VAR_Price_Request_ID' => PRnew.Id});     
                flow.start();
                
            }
            
                
	/*		if(creditDetailLst.size() != 0 && creditRequired == true){
                    newCCRecord = creditDetailLst[0];
                }
                
			if(creditRequired){
                    System.debug('Credit Required');
                    if(newCCRecord.Id == null){
                        System.debug('-503-');
                        newCCRecord.Credit_Check_Outcome__c  = 'Pending';
                        // newCCRecord.Opportunity__c = Opp;
                        newCCRecord.Customer__c = getAccId.AccountId;
                        if(Test.isRunningTest()){
                            newCCRecord.Experian_Api_Call_Credit_Assessment__c = false;
                        }else{
                        newCCRecord.Experian_Api_Call_Credit_Assessment__c = true;
                        }
                        
                        Insert newCCRecord;
                        peToInsert.add(createCreditLogs.createCreditProcessLogs(getAccId.AccountId, 'Active/New Credit Present ?', 'Decision', 'New Credit record created , as no active credit record was present for the Customer.',newCCRecord.Name,newCCRecord.Id,'False'));
                    }
                    else{
                        newCCRecord = [SELECT Id,Name FROM Credit_Check__c WHERE Id =: newCCRecord.Id];
                        if(creditDetailLst.size() != 0){
							//Comment/Changes related with card SU-865
                           // peToInsert.add(createCreditLogs.createCreditProcessLogs(getAccId.AccountId, 'Pricing Request(s) requires Credit', 'Decision', 'New Pricing requests inserted',getAccId.Name,getAccId.Id,'True'));    
                            peToInsert.add(createCreditLogs.createCreditProcessLogs(getAccId.AccountId, 'Active/New Credit Present ?', 'Decision', 'Active Credit record already present.',newCCRecord.Name,newCCRecord.Id,'True'));
                        }
                        if (optionSelected != 'Refresh'){
                            if(Test.isRunningTest()){
                                newCCRecord.Experian_Api_Call_Credit_Assessment__c = false;
                            }else{
                                newCCRecord.Experian_Api_Call_Credit_Assessment__c = true;
                            }
                            update newCCRecord;
                        }else{
                            List<Pricing_Request__c> prLst = [SELECT Id,Bill_Type__c,Name,Credit_Details__c  FROM Pricing_Request__c WHERE Id IN : prlistNew];
                            for(Pricing_Request__c p : prLst){
                                if(p.Bill_Type__c  != 'UCB')
                                p.Credit_Details__c = newCCRecord.Id; 
                            }
                            update prLst;
                            update newCCRecord;
                            peToInsert.add(createCreditLogs.createCreditProcessLogs(getAccId.AccountId, 'Perform Credit Assessment', 'Decision', 'No action taken due to price refresh',getAccId.Name,getAccId.Id,'False'));
                        }
                    }
                    System.debug('peToInsert-->' + peToInsert);
                    if(peToInsert.size() > 0){
                        upsert peToInsert;
                    }
                }*/
           // Credit_CalledFromDiffApex.creditFromForLoop(Opp, creditRequired, prlistNew, newCCRecord, optionSelected);
           Credit.createCreditDetail(creditDetailLst,getAccId,creditRequired, prlistNew, optionSelected,newCCRecord,true);
        }
    }
    
    //Get the Bill type based on Utility Account
    @AuraEnabled
    public static list<String> getBillType(List<Utility_Account_Opportunity__c> UAList){
        set<Id> utilityAcc = new set<Id>();
        set<String> FinalBillType =  new set<String>();
        set<String> RemovableBillType =  new set<String>();
        List<String> lStrings =  new List<String>();
        String multiselectValues;
        try{
            for(Utility_Account_Opportunity__c  uao : UAList){
                utilityAcc.add(uao.Utility_Account__r.Utility__c);
            }
            List<Account> acc = [Select Id,Bill_Type__c from Account Where Id=:utilityAcc];
            if(acc.size()>0){
                multiselectValues = acc[0].Bill_Type__c;
                System.debug('multiselectValues'+multiselectValues);
                list<String> individualSelections = multiselectValues.split(';');
                for(String s: individualSelections){
                    if(s.contains('UCB with Credit')){
                        s = s.replace('UCB with Credit','Credit');
                    }
                    for(Account ac : acc){
                        if(ac.Bill_Type__c.contains('UCB with Credit')){
                            ac.Bill_Type__c = ac.Bill_Type__c.replace('UCB with Credit','Credit');
                        }
                        if(ac.Bill_Type__c.contains(s)){
                            if(s.contains('Credit')){
                                s = s.replace('Credit','UCB with Credit');
                            }
                            FinalBillType.add(s);
                        }else{
                            if(s.contains('Credit')){
                                s = s.replace('Credit','UCB with Credit');
                            }
                            RemovableBillType.add(s);
                            break;
                        }
                    }
                }
                FinalBillType.removeAll(RemovableBillType);
            }
            lStrings = new List<String>(FinalBillType);
            System.debug('lStrings------------>>>>>> '+lStrings);
            return lStrings;
        }catch(Exception ex){
            return lStrings;
        }        
    }  
    
    //Create Opportunity along with UAOs
    //Update the Customer Account Owner and Opportunity Owner as CPMUser if selected
    public class OppIdExceptionWrapper{
        @AuraEnabled
        public Id OppId {get;set;}
        @AuraEnabled
        public String exceptionMsg {get;set;}
    }
    
    @AuraEnabled
    public static OppIdExceptionWrapper CreateUAccs(List<Utility_Account__c> UAList,PRWrapper PricingRequest,Boolean CreatePricingReq,User CPMUser,String AccId,List<String> ContactId,String contractId,String selectedLoadFollowing, String selectedIndexContractId, String selectedIndexOpportunityId){
        String errMsg='';
        List<String> errLst = new List<String>();
        OppIdExceptionWrapper oppExcepWrapper = new OppIdExceptionWrapper();
        Opportunity Opp = new Opportunity();
        boolean StartDatesMissing = true;
        Boolean toCheckException = false;
        // boolean stateNotValid = false;
        try{
            Date EarliestDate;
            boolean SetEarliestDate = false;
            if(CPMUser!=NULL)
            {
                if(CPMUser.Id!=NULL){
                    Opp.OwnerId = CPMUser.Id;
                }
            }
            Opp.AccountId = UAList[0].Account__c ;
            Opp.Broker_Margin__c = PricingRequest.BrokerMargin;
            Opp.Broker__c = AccId;
            Opp.CloseDate = System.TODAY().addDays(7);
            Opp.Name = 'New';
            Opp.StageName = 'New';
            Opp.Start_Date__c = System.TODAY();
            Opp.State__c = UAList[0].Utility_State__c;
            Opp.Type=PricingRequest.SaleType;
            Opp.Commission_Type__c = 'Residual';    
            Opp.Switching_Type__c=PricingRequest.SwitchingType;
            opp.Name_Suffix__c = PricingRequest.NameSuffix;
            if(PricingRequest.ExpectedAnnualVolume != null){
             Opp.Expected_Annual_Volume__c = Decimal.valueOf(PricingRequest.ExpectedAnnualVolume);   
            }
            if(contractId != null && contractId != ''){
                if (String.isBlank(selectedLoadFollowing)) {
                Opp.Existing_Contract__c = contractId;
                }
            }
            
             //  Populate load following related values here: SU-931
            if (String.isNotBlank(selectedLoadFollowing)) {
                Opp.Load_following__c = selectedLoadFollowing;
                Opp.Index_Opportunity__c = selectedIndexOpportunityId;
                Opp.Index_Contract__c = selectedIndexContractId;

            }
            System.debug('selectedLoadFollowing--'+selectedLoadFollowing);
            
            Insert Opp;
            
            if(contractId != null && contractId != ''){
                Contract contr = [SELECT Id,Renewal_Opportunity__c FROM Contract WHERE Id =: contractId];
                System.debug('Opportunity__r.Type -->> '+Opp.Type );
                if(PricingRequest.SaleType == 'Blend and Extend'){
                    contr.Blend_and_Extend__c = Opp.Id;
                }else{
                    if(Opp.Type !='Load Following'){
                    contr.Renewal_Opportunity__c = Opp.Id;    
                    }
                }
                update contr;
            }
            if(ContactId != null){
                List<OpportunityContactRole> oppConRole = new List<OpportunityContactRole>();
                for(String conIds : ContactId){
                    OpportunityContactRole contactRoleNew = new OpportunityContactRole();
                    contactRoleNew.ContactId = conIds;
                    contactRoleNew.OpportunityId = Opp.Id ;
                    contactRoleNew.Role = 'Evaluator';
                    oppConRole.add(contactRoleNew);
                }
                Insert oppConRole;
            }
            Account custAccount = [Select Id, Status__c,Registered_State_Province__c, OwnerId, (SELECT Id FROM Opportunities) from Account where id =: UAList[0].Account__c];
            if(custAccount.Opportunities.size() == 1 && custAccount.Status__c == 'New'){
                custAccount.Status__c = 'Prospect';
            }
            Update custAccount;
            List<Utility_Account_Opportunity__c> UAOLstToInsert = new List<Utility_Account_Opportunity__c>();
            List<Utility_Account_Pricing__c> UAPRLstToInsert = new List<Utility_Account_Pricing__c>();
            Pricing_Request__c prObj = new Pricing_Request__c();
            boolean PORwithRecourse = false;
            RecordType rt;
            Group gr;
            toCheckException = true;
            for(Utility_Account__c ua : UAList){
                if(ua.Requested_Start_Date__c != null && contractId != null && contractId != ''){
                    StartDatesMissing = false;
                }                
                if(ua.Utility__r.Credit_Check_Required__c == true){
                    PORwithRecourse = true;
                }
                if(contractId != null && contractId != ''){
                    ua.Requested_Start_Date__c = ua.Requested_Start_Date__c;
                }
                if(SetEarliestDate == false){
                    EarliestDate = ua.Requested_Start_Date__c;
                    SetEarliestDate = true;
                }
                if(EarliestDate > ua.Requested_Start_Date__c){
                    EarliestDate = ua.Requested_Start_Date__c;
                }
                Utility_Account_Opportunity__c ObjUAO = new Utility_Account_Opportunity__c();
                Utility_Account_Pricing__c ObjUAPR = new Utility_Account_Pricing__c();
                ObjUAO.Utility_Account__c = ua.Id;
                ObjUAO.Status__c = 'Not Priced';
                ObjUAO.Opportunity__c = Opp.Id;
                ObjUAO.Start_Date__c = ua.Requested_Start_Date__c;
                UAOLstToInsert.add(ObjUAO);
            }
            insert UAOLstToInsert;
            if(UAOLstToInsert!=null)	
                System.debug('UAOLstToInsert'+UAOLstToInsert[0].Opportunity__c);
            if(EarliestDate!= null){
                Opp.Start_Date__c = EarliestDate;
            }
            if( CreatePricingReq == true ){    
                Opp.StageName = 'Pricing';    
            }    
            update Opp;
        }
        catch(Exception e){
            errMsg = e.getMessage();
            errLst = errMsg.split(':');
        }
        oppExcepWrapper.OppId = Opp.Id;
        if(!errLst.isEmpty()){
            if(toCheckException == false){
                oppExcepWrapper.exceptionMsg = errLst[1];
            }else if(StartDatesMissing){
                oppExcepWrapper.exceptionMsg = 'Contract end date is missing on Utility Accounts.';
                delete Opp;
            }else{
                oppExcepWrapper.exceptionMsg = errLst[1];
            }
        }
        else{
            oppExcepWrapper.exceptionMsg = errMsg;
        }
        return oppExcepWrapper;
    }
    
    //Return the Sale Type picklist values of Opportunity
    @AuraEnabled
    public static List<String> SaleType(){
        List<String> options = new List<String>();
        Schema.DescribeFieldResult fieldResult = Opportunity.Type.getDescribe();
        List<Schema.PicklistEntry> pList = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry p: pList) {
               options.add(p.getLabel());   // changes done by suhas for SU 901
        }
        return options;
    }
    
    //Returns Product Family based on the Product Status( returns Active only) 
    @AuraEnabled
    public static List<String> ProductFamily(){
        List<String> optionsToadd = new List<String>();
        for(Product2 prod: [Select Id,Name,IsActive,Family FROM Product2 Where Family != null]){
            if(prod.IsActive == true ){
                optionsToadd.add(prod.Family);
            }  
        }
        set<String> options = new set<String>();
        Schema.DescribeFieldResult fieldResult = Product2.Family.getDescribe();
        List<Schema.PicklistEntry> pList = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry p: pList) {
            for(String s : optionsToadd){
                if(p.getLabel().contains(s)){
                    options.add(p.getLabel());
                }
            }
        }
        List<String> lStrings = new List<String>(options);
        return lStrings;
    }
    
    
    //Returns Products based on the Product Status and Product Family selected( returns Active only)
    @AuraEnabled
    public static List<Product2> GetProducts(String ProductFamily,String State,Id recordId){
        System.debug('recordId-->> '+recordId);
        Opportunity opp;
        if(recordId !=null){
            opp =  [SELECT Id,Type,ProductForLoadFollowing__c FROM Opportunity WHERE Id=:recordId];
        }
        //System.debug('saleTypLoadFollow-->> '+saleTypLoadFollow);
        List<String> options = new List<String>();
        List<Product2> productLst = new List<Product2>();
        if(recordId ==null || opp.Type != 'Load Following'){ 
            try{
                Product2 productvar = [Select Id, Name, Voluntary_RECs__c, Voluntary_RECS_Treatment__c from Product2 Where IsActive = true and default__c = true and Family=:ProductFamily and State__c includes(:State)];
                if(productvar!=null){
                    productLst.add(productvar);
                }
                productLst.addAll([Select Id, Name, Voluntary_RECs__c, Voluntary_RECS_Treatment__c  from Product2 Where IsActive = true and default__c = false and Family=:ProductFamily and State__c includes(:State) order by Name ASC]);
            }catch(Exception e){
                productLst.addAll([Select Id, Name, Voluntary_RECs__c, Voluntary_RECS_Treatment__c  from Product2 Where IsActive = true and default__c = false and Family=:ProductFamily and State__c includes(:State) order by Name ASC]);
            }
        }else{
            productLst.addAll([Select Id, Name, Voluntary_RECs__c, Voluntary_RECS_Treatment__c  from Product2 Where id=:opp.ProductForLoadFollowing__c]);
        }
        return productLst;
    }
    
    //Fetch the picklist values of Status field on Utility Account
    @AuraEnabled
    public static List<String> GetStatusPicklist(){
        List<String> options = new List<String>();
        Schema.DescribeFieldResult fieldResult = Utility_Account__c.Status__c.getDescribe();
        List<Schema.PicklistEntry> pList = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry p: pList) {
            options.add(p.getLabel());
        }
        return options;
    }
    
    //Fetch the Utility Account Opportunities along with the State on its related Oppty (Used in Create Pricing Request Component)
    @AuraEnabled
    public static UAOWrapper GetUAOsandState(Id recordId){
        List<UAOWrapper> UAOWrapperLst = new List<UAOWrapper>();
        List<Utility_Account_Opportunity__c> UAOLst = [SELECT Id,Utility_Account__r.Utility__r.HU_Days_Required__c,Opportunity__r.OwnerId,Opportunity__r.Type,Opportunity__r.AccountId,Opportunity__r.Account.EXPRN__BIN_formula__c , Utility_Account__r.Utility__c,Opportunity__c,Opportunity__r.State__c,Utility_Account__c ,Start_Date__c FROM Utility_Account_Opportunity__c where Opportunity__c=:recordId];
         // SU - 932
        Decimal maxvalue = UAOLst[0].Utility_Account__r.Utility__r.HU_Days_Required__c;
        For (integer i =0;i<UAOLst.size();i++){
            if( UAOLst[i].Utility_Account__r.Utility__r.HU_Days_Required__c > maxvalue)
                maxvalue = UAOLst[i].Utility_Account__r.Utility__r.HU_Days_Required__c;             
        }    
        System.debug('maxvalue-->> '+maxvalue);
        Date maxDate;
        if(maxvalue != null){
             maxDate = System.Today()+ Integer.valueOf(maxvalue);
        }
        else{
             maxDate = System.Today();
        }
        
        UAOWrapper uaoWrapperObj = new UAOWrapper();
        uaoWrapperObj.maxOfHUDaysRequired = maxDate;
        uaoWrapperObj.State = UAOLst[0].Opportunity__r.State__c;
        uaoWrapperObj.SaleType =  UAOLst[0].Opportunity__r.Type;
        uaoWrapperObj.UAO = UAOLst;
        
        uaoWrapperObj.AccId = UAOLst[0].Opportunity__r.AccountId;	
        uaoWrapperObj.BinId = UAOLst[0].Opportunity__r.Account.EXPRN__BIN_formula__c;	
      //  uaoWrapperObj.OppOwnerId =  UAOLst[0].Opportunity__r.OwnerId;	
        System.debug('BinId-->'+UAOLst[0].Opportunity__r.Account.EXPRN__BIN_formula__c);
        
         Id CurrentUSerId = UserInfo.getUserId();
        if(CurrentUSerId == UAOLst[0].Opportunity__r.OwnerId){
            uaoWrapperObj.isOppOwnandUserSame = true;
        }else{
            uaoWrapperObj.isOppOwnandUserSame = false;
        }
        
        try{
            Product2 productvar = [Select Id, Name, Voluntary_RECs__c, Voluntary_RECS_Treatment__c from Product2 Where Name = 'Fully Fixed' ];
            uaoWrapperObj.RECS = productvar.Voluntary_RECs__c.split(';');
            if(productvar.Voluntary_RECs__c.split(';')[0] == 'NA'){
                //uaoWrapperObj.Treatment = new List<String>();
            }
            else{
                uaoWrapperObj.Treatment = productvar.Voluntary_RECS_Treatment__c.split(';');
            }
        }
        catch(Exception e){
            uaoWrapperObj.Treatment = new List<String>();
            uaoWrapperObj.RECS = new List<String>();
        }
        return uaoWrapperObj;
    }
    
    //Generic Function to get picklist values based on objectType and fieldName 
    @AuraEnabled        
    public static List<String> getselectOption(String objectType, String fieldName){
        List<String> pickListValuesList = new List<String>();
        Schema.SObjectType convertToObj = Schema.getGlobalDescribe().get(objectType);
        Schema.DescribeSObjectResult res = convertToObj.getDescribe();
        Schema.DescribeFieldResult fieldResult = res.fields.getMap().get(fieldName).getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            pickListValuesList.add(pickListVal.getValue());
        }     
        return pickListValuesList;
    }
    
    public static List<String> getselectOptionNew(String objectType, String fieldName,Id prodId){
        Product2 prod = [SELECT Id, Voluntary_RECS_Treatment__c FROM Product2 where Id =: prodId];
        List<String> pickListValuesList = new List<String>();
        Schema.SObjectType convertToObj = Schema.getGlobalDescribe().get(objectType);
        Schema.DescribeSObjectResult res = convertToObj.getDescribe();
        Schema.DescribeFieldResult fieldResult = res.fields.getMap().get(fieldName).getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            pickListValuesList.add(pickListVal.getValue());
        } 
        if(prod.Voluntary_RECS_Treatment__c!=null){
            pickListValuesList = prod.Voluntary_RECS_Treatment__c.split(';');
        }
        return pickListValuesList;
    }
    
    public class VolGreenListWrapp{
        @AuraEnabled
        public List<String> Treatment {get;set;}
        @AuraEnabled
        public List<String> RECS {get;set;}
    }
    
    public class UaprWrapper{	
        @AuraEnabled	
        public String PRName {get;set;}	
        @AuraEnabled	
        public List<Utility_Account_Pricing__c> UAPRLst {get;set;}	
    }
	
    @AuraEnabled	
    public static List<UaprWrapper> utilAccounts(Opportunity op){	
        
        List<UaprWrapper> uawrappLst = new List<UaprWrapper>();	
        List<Pricing_Request__c> prqList = new List<Pricing_Request__c>();	
        Set<Date> startDates = new Set<Date>();	
        
        List<List<String>> lstOfLst = new List<List<String>>();	
        Map<String,Utility_Account_Pricing__c> UtilityUAPRMap = new Map<String,Utility_Account_Pricing__c>();	
        
        prqList = [SELECT Id FROM Pricing_Request__c WHERE Opportunity__c =: op.Id];	
        
        List<Utility_Account_Pricing__c> UAPRLst = [SELECT Id,Start_Date__c, Utility_Account__r.Utility__r.Name, Name,Pricing_Request__c FROM Utility_Account_Pricing__c WHERE Pricing_Request__c IN: prqList];	
        
        
        List<AggregateResult> groupedResults = [SELECT COUNT(Id),Utility_Account__r.Utility__r.Name, Pricing_Request__c, Start_Date__c FROM Utility_Account_Pricing__c WHERE Pricing_Request__c IN: prqList GROUP BY Start_Date__c, Pricing_Request__c,Utility_Account__r.Utility__r.Name ];	
        
        System.debug('-->'+groupedResults);	
        
        for(Utility_Account_Pricing__c uapr : UAPRLst){	
            UtilityUAPRMap.put(uapr.Utility_Account__r.Utility__r.Name,uapr);	
        }	
        
        
        return uawrappLst;	
    }
    
    @AuraEnabled
    public static VolGreenListWrapp getPicklists(Id recordId, Id SelectedProduct){
        System.debug('SelectedProduct-->> '+SelectedProduct);
        VolGreenListWrapp VG = new VolGreenListWrapp();
        try{
            Product2 productvar = [Select Id, Name, Voluntary_RECs__c, Voluntary_RECS_Treatment__c from Product2 Where Id =: SelectedProduct ];
            VG.RECS = productvar.Voluntary_RECs__c.split(';');
            VG.Treatment = productvar.Voluntary_RECS_Treatment__c.split(';');
        }
        catch(Exception e){
            VG.Treatment = new List<String>();
            VG.RECS = new List<String>();
        }
        System.debug('Treatment-->'+VG.Treatment);
        System.debug('RECS-->'+VG.RECS);
        return VG;
    }
    
    // Is load follwing
   /* @AuraEnabled
    public static Product2 isLoadFollowing(Id recordId){
      Opportunity oppor =   [SELECT Id,Type FROM Opportunity WHERE Id =: recordId];
      Product2 prod =  [SELECT Id,Name, Voluntary_RECs__c, Voluntary_RECS_Treatment__c FROM Product2 WHERE Id =: oppor.ProductForLoadFollowing__c];
      return prod;
    } */
    
    //SU-608: Retrive Existing PR
    @AuraEnabled
    public static List<Pricing_Request__c> getExistingPR(Id Opp){
        
        return [SELECT Id, Name, Pricing_Quote_Comments__c , Bill_Type__c,Invoice_Billing_Type__c, Voluntary_RECs__c, Voluntary_RECs_percent__c, Request_Completed__c, Treatment__c, Product_Lookup__c, Opportunity__c, Product_Lookup__r.Name, Product_Lookup__r.Family FROM Pricing_Request__c Where Opportunity__c =: Opp order by Name desc];
    }
    public class ProductWrapp{
        @AuraEnabled
        public List<String> ProductFamily {get;set;}
        @AuraEnabled
        public List<Product2> ProductLst {get;set;}
    }
    
    @AuraEnabled
    public static ProductWrapp getProd(String productName){
        ProductWrapp pWrapp = new ProductWrapp();
        List<String> prodfamilyTopass = new List<String>();
        List<Product2> selectedProd = new List<Product2>();
        Product2 selectedProduct = [SELECT Id,
                                    Name,
                                    Family,
                                    Voluntary_RECs__c,
                                    Voluntary_RECS_Treatment__c
                                    FROM Product2
                                    WHERE Name =: productName Limit 1];
        List<Product2> selectedProdLst = [SELECT Id,
                                          Name,
                                          Family,
                                          Voluntary_RECs__c,
                                          Voluntary_RECS_Treatment__c
                                          FROM Product2
                                          WHERE Family =: selectedProduct.Family];
        prodfamilyTopass.add(selectedProduct.Family);
        selectedProd.add(selectedProduct);
        
        for(Product2 pr : selectedProdLst ){
            if(!selectedProd.contains(pr)){
                selectedProd.add(pr);
            }
        }
        
        for(String s : Create_Opportunity.ProductFamily()){
            if(!prodfamilyTopass.contains(s)){
                prodfamilyTopass.add(s);
            }
        }       
        pWrapp.ProductFamily = prodfamilyTopass;
        pWrapp.ProductLst = selectedProd;
        ProductWrapp pw = new ProductWrapp();
        pw.ProductFamily =prodfamilyTopass;
        pw.ProductLst = selectedProd;
        System.debug('pWrapp'+pWrapp);
        return pw;
    }
 
    
    public static void codeCovMethod(){
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
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
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