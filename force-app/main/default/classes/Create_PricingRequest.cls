/*
* @Purpose: Controller class for Create_PricingRequest Component.
* @Author: Saurabh Chauhan
* @CreatedDate: 01/07/2020
* @Test Class:  Create_PricingRequest_Test
* @Related Code: Create_PricingRequest1.cmp, Create_PricingRequest.cmp
* @LastModifiedDate: 
* @LastModifiedBy:Rahul Ghaytadak
*/

//To get the picklist values for State based on the States of related Utility Accounts on the Customer Record.
public class Create_PricingRequest {
    @AuraEnabled
    public static List<String> getStatePicklist(Id recordId){
        List<String> LstToReturn = new List<String>();
        Opportunity Opp = [Select Id,State__c from Opportunity where Id =:recordId]; 
        LstToReturn.add(Opp.State__c);
        return LstToReturn;
    }
    
    public class QuoteWrapper{
        @AuraEnabled
        public Date QuoteDate  {get;set;}
        @AuraEnabled
        public String opTyp    {get;set;}
    }
    //getQuoteEndDate
    @AuraEnabled
    public static List<QuoteWrapper> getQuoteEndDate(String recordId, String oppRecId){
        // If PR is created from Load Following Compoment on Contract we will get recordId which is contract recird Id
        // If PR is Created from Load following Opportunity we will get oppRecId which is Opportunity Id (recordId which is contract recird Id is null in this case) 
        System.debug('recordId'+recordId);
        System.debug('oppRecId-->> '+oppRecId); 
        List<QuoteWrapper> qWrap = new List<QuoteWrapper>();
        String OpportType;
        Date endDt;
        if(recordId != null){
        Contract contract = [SELECT Id,Opportunity__r.Type, EndDate FROM Contract WHERE Id=: recordId];
            endDt = contract.EndDate;
            OpportType = 'Yes';
            /*if(contract.Opportunity__r.Type == 'Load Following'){
                OpportType = 'Yes';
            }else{
                OpportType = 'No';
            } */
        }else{
        Opportunity oppr = [SELECT Id,Type,Existing_Contract__r.EndDate FROM Opportunity WHERE Id =: oppRecId];
           endDt = oppr.Existing_Contract__r.EndDate;
            if(oppr.Type == 'Load Following'){
                OpportType = 'Yes';
            }else{
                OpportType = 'No';
            }
        //Contract contract = [SELECT Id, EndDate FROM Contract WHERE Id=: recordId];
        }
        
        //System.debug('contract-->> '+contract);
        
        QuoteWrapper qw =new QuoteWrapper();
        qw.QuoteDate = endDt; //Date.valueOf(contract.EndDate);
        qw.opTyp = OpportType;
        qWrap.add(qw);
        System.debug('qWrap-->> '+qWrap);
        return qWrap;
        
    }
    
    //To fetch the Utility Accounts based on selected State and to sort the Utility Account list based on sortField and sortType. 
    @AuraEnabled
    public static List<UAWrapper> getUAList(Id recordId,String State,String sortType,String sortField,List<UAWrapper> UtilitiesSelected, Id selectPRId, String optionSelected, Boolean fromLodFollowing){
        System.debug('UtilitiesSelected-->> '+UtilitiesSelected);
        System.debug('selectPRId'+selectPRId);
        // as part of Pricing request 
        Map<String,List<Utility_Account_Pricing__c>> PrIdAndUAPrMap1 = new Map<String,List<Utility_Account_Pricing__c>>();
        List<String> UANums = new List<String>();
        List<Id> UANIds = new List<Id>();
        List<Pricing_Request__c> PrLstToCopyFrom1 = new List<Pricing_Request__c>();
        PrLstToCopyFrom1 = [SELECT Id,(SELECT Id, Name, Utility_Account__c, Credit_Check_Required__c, Start_Date__c,Utility_Account__r.Name FROM Utility_Account_Pricing_Requests__r) FROM Pricing_Request__c WHERE Id=: selectPRId];
        for(Pricing_Request__c pr : PrLstToCopyFROM1){
            PrIdAndUAPrMap1.put(pr.Id,pr.Utility_Account_Pricing_Requests__r);
            for(Utility_Account_Pricing__c p : pr.Utility_Account_Pricing_Requests__r){
                UANums.add(p.Name);
                UANIds.add(p.Utility_Account__c);
            }
        }
        // as part of Pricing request 
        List<UAWrapper> UALstWrapper = new List<UAWrapper>();
        if(UtilitiesSelected.size() <= 0){
            String query = 'SELECT Id, Name,Utility_Account__r.Utility__c,Utility__c,Utility_Account__r.Name,Status__c, Start_Date__c, Opportunity__r.Type FROM Utility_Account_Opportunity__c where Opportunity__c=: recordId ORDER BY '  +sortField +' '+ sortType;
            List<Utility_Account_Opportunity__c> UALst = Database.query(query);
            String opTyp = UALst[0].Opportunity__r.Type;
            for(Utility_Account_Opportunity__c ua : UALst){
                UAWrapper obj = new UAWrapper();
                if(optionSelected == 'option3'){
                    if(UALst.size() == UANIds.size()){
                        obj.isSelectedAll = true;
                        obj.lenOfUAsSelected = UANIds.size();
                    }else{
                        System.debug('UANIds.size()'+UANIds.size());
                        obj.isSelectedAll = false; 
                        obj.lenOfUAsSelected = UANIds.size();
                    }
                    if(UANIds.contains(ua.Utility_Account__c)){
                        obj.defaultCheckbox = true;
                        System.debug('In it 111+++');
                        obj.uaIdsrReturn = ua.Utility_Account__c;
                    }
                }else{
                    obj.defaultCheckbox = true;
                    obj.isSelectedAll = true;
                    obj.lenOfUAsSelected = UALst.size();
                }
                obj.Id = ua.Id;
                obj.UtilityName = ua.Utility__c;
                obj.isSelected = true;
                obj.isSelectedStatus = true;
                System.debug('ua'+ua);
                //added
                //if(opTyp=='Load Following'){
                if(fromLodFollowing == true){
                ua.Start_Date__c = null;    
                }
                // end added
                obj.UAcc = ua;
                UALstWrapper.add(obj);
            }
            return UALstWrapper;
        }
        else{
            List<String> FilteredUAIds = new List<String>();
            List<Id> FilteredUAId = new List<Id>();
            for(UAWrapper uA : UtilitiesSelected){
                FilteredUAIds.add(uA.UtilityName);
                FilteredUAId.add(uA.Id);
            }
            String query = 'SELECT Id, Name,Status__c, Utility__c,Utility_Account__r.Utility__c,Utility_Account__r.Name, Start_Date__c,Opportunity__r.Type FROM Utility_Account_Opportunity__c where Opportunity__c=: recordId AND Id IN:FilteredUAId AND Utility__c IN:FilteredUAIds ORDER BY '  +sortField +' '+ sortType;
            List<Utility_Account_Opportunity__c> UALst = Database.query(query);
            String opTyp = UALst[0].Opportunity__r.Type;
            Map<Id,Utility_Account_Opportunity__c> UAMap = new Map<Id,Utility_Account_Opportunity__c>();
            Map<Id,boolean> UACheckboxMap = new Map<Id,boolean>();
            for(UAWrapper uw : UtilitiesSelected ){
                UAMap.put(uw.Id,uw.UAcc);
                UACheckboxMap.put(uw.Id,uw.defaultCheckbox);
            }
            for(Utility_Account_Opportunity__c ua : UALst){
                UAWrapper obj = new UAWrapper();
                obj.Id = ua.Id;
                obj.UtilityName = ua.Utility__c;
                obj.isSelected = true;
                obj.isSelectedStatus = true;
                //added
                //if(opTyp=='Load Following'){
                if(fromLodFollowing == true){
                UAMap.get(ua.Id).Start_Date__c = null;
                }
                // end added
                obj.UAcc = UAMap.get(ua.Id);
                obj.defaultCheckbox = UACheckboxMap.get(ua.Id);
                UALstWrapper.add(obj);
            }
            System.debug('110 UALstWrapper==>> ');
            return UALstWrapper;
        }
    }
    
    //Wrapper Class for Utility Account Opportunities 
    public class UAOWrapper{
        @AuraEnabled
        public String State {get;set;}
        @AuraEnabled
        public List<Utility_Account_Pricing__c> UAO {get;set;}
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
        public Utility_Account_Opportunity__c UAcc {get;set;}
        @AuraEnabled
        public Date StartDate {get;set;}
        @AuraEnabled
        public Date DueDate {get;set;}
        @AuraEnabled
        public List<String> StatusPicklist{get;set;}
        @AuraEnabled
        public boolean isSelectedAll {get;set;}
        @AuraEnabled
        public Id uaIdsrReturn {get;set;}
        @AuraEnabled
        public Integer lenOfUAsSelected {get;set;} 
        @AuraEnabled
        public String DateInvalidError {get;set;} 
    }
    
    //Wrapper Class for Pricing Request
    public class PRWrapper{
        @AuraEnabled
        public String Product {get;set;}
        @AuraEnabled
        public String BillType {get;set;}
        @AuraEnabled
        public String SaleType {get;set;}
        @AuraEnabled
        public list<Pricing_Request__c> PricingRequestList{get; set;}
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
    
    //To return all UAs which are marked selected.
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
    
    //Create Multiple Pricing Requests along UAPRs
    //Update the Customer Account Owner and Opportunity Owner as CPMUser if selected
    //Sends Pricing Request Email by invoking a flow
    //Assign Specific record type based on Bill Type of Pricing Request
    @AuraEnabled
    public static void CreatePR(List<Utility_Account_Opportunity__c> UAList,PRWrapper PricingRequest,User CPMUser,Id Opp,Boolean checkRequestType, String contractId, String optionSelected,Id selectPRId, List<Utility_Account_Opportunity__c> selectedContacts1, boolean uaoCheckboxes,List<String> availabeleBillTypes){
        System.debug('selectPRId ==>> '+selectPRId);
        System.debug('Opp-->> '+Opp);
        System.debug('uaIdsrReturn==>> '+selectedContacts1);
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
        
        //++//
        boolean creditRequired = false;
        List<Process_Event__c> peToInsert = new List<Process_Event__c>();
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
        //++//
        
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
        Date EarliestDate;
        boolean SetEarliestDate = false;
        Id rt;
        Id gr;
        RecordType Dualrt = [SELECT Id, Name, DeveloperName, SobjectType FROM RecordType where SobjectType = 'Pricing_Request__c' AND DeveloperName = 'Credit_Check_Required' limit 1];
        //Group Dualgr = [select Id from Group where  Type = 'Queue' AND NAME = 'Credit Team' LIMIT 1];
        
        Group PORgr = [select Id from Group where  Type = 'Queue' AND NAME = 'Pricing Team' limit 1];
        RecordType PORrt = [SELECT Id, Name, DeveloperName, SobjectType FROM RecordType where SobjectType = 'Pricing_Request__c' AND DeveloperName = 'Default_Pricing_Request' limit 1];
        
        boolean PORwithRecourse = false;
        //Opportunity getAccId = [Select Id,OwnerId,AccountId,Start_Date__c from Opportunity where Id=:Opp];
        
        //++//
        Opportunity getAccId = [Select Id,Type,Name,OwnerId,AccountId,Existing_Contract__c from Opportunity where Id=:Opp];	
        Account accToUpdateOwner = [SELECT Id,Last_Successful_Experian_Fraud_Shields__c,Last_Successful_Experian_Business_Fact__c FROM Account WHERE Id =: getAccId.AccountId ];	
        List<Credit_Check__c> creditDetailLst = [SELECT Id,Name,Pricing_Request_Status__c, Opportunity__c FROM Credit_Check__c where Customer__c =: getAccId.AccountId AND Status__c = 'Active'];	
        if(creditDetailLst.size()==0){	
            creditDetailLst = [SELECT Id,Name,Pricing_Request_Status__c, Opportunity__c FROM Credit_Check__c where Customer__c =: getAccId.AccountId AND Status__c = 'New'];	
        }
        
        List<Pricing_Request__c> prListToPass = new List<Pricing_Request__c>();
        for(Pricing_Request__c PReqL : PricingRequest.PricingRequestList){
            prListToPass.add(PReqL);
            if(PReqL.Bill_Type__c == 'Dual' || PReqL.Bill_Type__c == 'UCB with Credit' || (availabeleBillTypes.Contains('UCB') == false)){
                creditRequired = true;
                System.debug('in this if');
            }
        }
        
        System.debug('creditRequired->'+creditRequired);	
        System.debug('creditDetailLst->'+creditDetailLst);	
       /* if(creditRequired){
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
        
        //++//
        
        //Credit.createCreditDetail(Opp, creditRequired, prListToPass, optionSelected,newCCRecord,false);
        Credit.createCreditDetail(creditDetailLst,getAccId ,creditRequired, prListToPass, optionSelected,newCCRecord,false);
        if(CPMUser!=NULL){
            getAccId.OwnerId = CPMUser.Id;
        }
        System.debug('PricingRequest.PricingRequestList==>> '+PricingRequest.PricingRequestList.size());
        //PricingRequest.PricingRequestList[0].remove();
        
        list<Pricing_Request__c> prlistNewToItrate = new list<Pricing_Request__c>();
        if(optionSelected == 'Refresh with Changes'){
        for(Integer i = 0; i<PricingRequest.PricingRequestList.size()-1; i++){
                prlistNewToItrate.add(PricingRequest.PricingRequestList[i]);
            }
        }else{
            prlistNewToItrate = PricingRequest.PricingRequestList;
        }
        
        list<Pricing_Request__c> prlistNew = new list<Pricing_Request__c>();
        for(Pricing_Request__c PReqList : prlistNewToItrate){
            System.debug('PReqList 266 ==>> '+PReqList.Name);
            System.debug('PReqList Bill Type ==>> '+PReqList.Bill_Type__c);
            if(PReqList.Bill_Type__c == 'POR & Dual'){
                Pricing_Request__c prObj1 = new Pricing_Request__c();
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
                PReqList.Bill_Type__c = 'UCB';
            }
            if(PReqList.Bill_Type__c == 'Dual' || PORwithRecourse == true || PReqList.Bill_Type__c == 'UCB with Credit'){
                rt = Dualrt.id;
                //gr = Dualgr.id;
                gr = UserInfo.getUserId();
            }
            else{
                gr = PORgr.Id;
                rt = PORrt.Id;
            }
            
            Pricing_Request__c prObj = new Pricing_Request__c();
            prObj.Bill_Type__c = PReqList.Bill_Type__c;
            prObj.Voluntary_RECs__c =PReqList.Voluntary_RECs__c;
            if(prObj.Voluntary_RECs__c != 'NA'){
                if(PReqList.Voluntary_RECs_percent__c != null){
                    prObj.Voluntary_RECs_percent__c = PReqList.Voluntary_RECs_percent__c;
                }
                else{
                    prObj.Voluntary_RECs_percent__c = 100;
                }
                prObj.Treatment__c = PReqList.Treatment__c;
            }
            prObj.Notes__c = PricingRequest.Notes;
            prObj.Urgent_Request__c = PricingRequest.UrgentRequest;
            prObj.Product_Lookup__c = PReqList.Product_Lookup__c;
            prObj.Opportunity__c = Opp;
            prObj.Invoice_billing_Type__c = PReqList.Invoice_billing_Type__c;
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
            if(PReqList.Bill_Type__c == 'UCB' || PReqList.Bill_Type__c == 'UCB with Credit'){
                prObj.Invoice_billing_Type__c = 'None';
            }
            else{
                prObj.Invoice_billing_Type__c = PReqList.Invoice_billing_Type__c;
            }
            //As part of SU - 828 - Below change
            prObj.Pricing_Quote_Comments__c = PReqList.Pricing_Quote_Comments__c;
            //SU-608: Update request Type
            if(checkRequestType == true){
                prObj.Request_Type__c = optionSelected;
            }else{
                prObj.Request_Type__c = optionSelected;
            }
            prObj.Original_Pricing_Request__c = selectPRId;
            if(Test.isRunningTest()){
                prObj.Record_Created__c = true;
            }
            prlistNew.add(prObj);
            
        }
        insert prlistNew;
        
        List<Utility_Account_Opportunity__c> uaList2 = new List<Utility_Account_Opportunity__c>();
        List<Utility_Account_Opportunity__c> uaList1 = new List<Utility_Account_Opportunity__c>();
        uaList1 = [SELECT Id,Start_Date__c,Utility_Account__c FROM Utility_Account_Opportunity__c WHERE Id IN  : selectedContacts1];
        
        Set<Id> uaoIds = new Set<Id>();
        Set<Id> uaoIds1 = new Set<Id>();
        for(Utility_Account_Opportunity__c uao : uaList1){
            uaoIds.add(uao.Id);
        }
        for(Utility_Account_Opportunity__c uao : uaList){
            uaoIds1.add(uao.Id);
            if(uaoIds.contains(uao.Id)){
                uaList2.add(uao);
            }
        }
        
        List<Utility_Account_Opportunity__c> uaoLst = new List<Utility_Account_Opportunity__c>();
        for(Pricing_Request__c PRnew : prlistNew ){
            //++//
            if(PRnew.Bill_Type__c == 'Dual' || PRnew.Bill_Type__c == 'UCB with Credit' || (availabeleBillTypes.Contains('UCB') == false)){	
                creditRequired = true;	
            }else{
                creditRequired = false;
            }
            //++//
            
            List<Utility_Account_Pricing__c> UAPRLst = new List<Utility_Account_Pricing__c>();
            if(uaoCheckboxes == false && optionSelected == 'Refresh with Changes'){
                for(Utility_Account_Opportunity__c uao : uaList2){
                    Utility_Account_Pricing__c ObjUAPR = new Utility_Account_Pricing__c();
                    ObjUAPR.Utility_Account__c = uao.Utility_Account__c;
                    ObjUAPR.Start_Date__c = uao.Start_Date__c;
                    ObjUAPR.Pricing_Request__c = PRnew.Id;
                    UAPRLst.add(ObjUAPR);
                    uaoLst.add(uao);
                    if(SetEarliestDate == false){
                        EarliestDate = uao.Start_Date__c;
                        SetEarliestDate = true;
                    }
                    if(EarliestDate > uao.Start_Date__c){
                        EarliestDate = uao.Start_Date__c;
                    }
                }
            }else if(uaoCheckboxes == true || optionSelected == 'Initial Request'){
                for(Utility_Account_Opportunity__c uao : uaList){
                    Utility_Account_Pricing__c ObjUAPR = new Utility_Account_Pricing__c();
                    ObjUAPR.Utility_Account__c = uao.Utility_Account__c;
                    ObjUAPR.Start_Date__c = uao.Start_Date__c;
                    ObjUAPR.Pricing_Request__c = PRnew.Id;
                    UAPRLst.add(ObjUAPR);
                    uaoLst.add(uao);
                    if(SetEarliestDate == false){
                        EarliestDate = uao.Start_Date__c;
                        SetEarliestDate = true;
                    }
                    if(EarliestDate > uao.Start_Date__c){
                        EarliestDate = uao.Start_Date__c;
                    }
                }
            }
            insert UAPRLst;
            /* */
            if(contractId != null && contractId != ''){
                getAccId.Existing_Contract__c = contractId;
                if(getAccId.Type != 'Load Following'){
                Contract contr = [SELECT Id,Renewal_Opportunity__c FROM Contract WHERE Id =: contractId];
                contr.Renewal_Opportunity__c = getAccId.Id;
                update contr;
                }
            }
            getAccId.Start_Date__c = EarliestDate;
            update getAccId;
            List<Utility_Account_Opportunity__c> uaoLstToCheck = [SELECT Id,Start_Date__c FROM Utility_Account_Opportunity__c WHERE Start_Date__c = null AND Opportunity__c =: Opp];
            if(uaoLstToCheck.size() > 0){
                update uaoLst;
            }
            if(PRnew.Bill_Type__c  == 'UCB'){
                if(!Test.isRunningTest()){
                Flow.Interview flow = new Flow.Interview.Send_HU_Pricing_Emails(new map<String,String> {'VAR_Price_Request_ID' => PRnew.Id});     
                flow.start();
                }
            }
            
            //++//
     /*       if(creditDetailLst.size() != 0 && creditRequired == true){
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
                } */
        //++//
        
            //Credit.createCreditDetail(Opp, creditRequired, prListToPass, optionSelected,newCCRecord,true);
            Credit.createCreditDetail(creditDetailLst,getAccId,creditRequired, prlistNew, optionSelected,newCCRecord,true);
        }
    }
    
    //Return the Sale Type picklist values of Opportunity
    @AuraEnabled
    public static List<String> SaleType(){
        List<String> options = new List<String>();
        Schema.DescribeFieldResult fieldResult = Opportunity.Type.getDescribe();
        List<Schema.PicklistEntry> pList = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry p: pList) {
            options.add(p.getLabel());
        }
        return options;
    }
    
    //Returns Product Family based on the Product Status( returns Active only) 
    @AuraEnabled
    public static List<String> ProductFamily(){
        List<String> options = new List<String>();
        Schema.DescribeFieldResult fieldResult = Product2.Family.getDescribe();
        List<Schema.PicklistEntry> pList = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry p: pList) {
            options.add(p.getLabel());
        }
        return options;
    }
    
    //Returns Products based on the Product Status and Product Family selected( returns Active only)
    @AuraEnabled
    public static List<String> GetProducts(String ProductFamily,String State){
        List<String> options = new List<String>();
        List<Product2> productLst = new List<Product2>([Select Name from Product2 where Family=:ProductFamily and State__c includes(:State)]);
        for(Product2 p : productLst){
            options.add(p.Name);
        }
        return options;
    }
    
    //Fetch the picklist values of Status field on Utility Account
    @AuraEnabled
    public static List<String> GetStatusPicklist(){
        List<String> options = new List<String>();
        Schema.DescribeFieldResult fieldResult = Utility_Account_Opportunity__c.Status__c.getDescribe();
        List<Schema.PicklistEntry> pList = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry p: pList) {
            options.add(p.getLabel());
        }
        return options;
    }
    
    //Get the Bill type based on Utility Account
    @AuraEnabled
    public static list<String> getBillType(List<Utility_Account_Opportunity__c> UAList){
        set<Id> utilityAcc = new set<Id>();
        String multiselectValues;
        set<String> FinalBillType =  new set<String>();
        set<String> RemovableBillType =  new set<String>();
        List<String> lStrings =  new List<String>();
        List<Id> UAOIds = new List<Id>();
        try{
            for(Utility_Account_Opportunity__c  uao : UAList){
                UAOIds.add(uao.Id);
            }
            List<Utility_Account_Opportunity__c> UAOLst = [SELECT Id, Utility_Account__r.Utility__c FROM Utility_Account_Opportunity__c where Id=:UAOIds]; 
            for(Utility_Account_Opportunity__c  uao : UAOLst){
                utilityAcc.add(uao.Utility_Account__r.Utility__c);
            }
            List<Account> acc = [Select Id,Bill_Type__c from Account Where Id=:utilityAcc];
            if(acc.size()>0){
                multiselectValues = acc[0].Bill_Type__c;
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
            System.debug('lStrings==>> '+lStrings);
            return lStrings;
        }
        catch(Exception ex){
            return lStrings;
        }
    }  
}