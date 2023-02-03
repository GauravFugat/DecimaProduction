/*
* @Purpose: Controller Class for Quote Generator Component
* @Author: Vishwanath Kodgire
* @CreatedDate: 01/17/2020
* @Related Code: 
* @Test Class: Create_Quote_Controller_Test
* @LastModifiedDate:
* @LastModifiedBy: Rahul Ghaytadak
*/

public class Create_Quote_Controller {
    
    @AuraEnabled
    public static boolean oppDateClosedWon(Id oppId){
        Opportunity opp = [select StageName from Opportunity where Id =: oppId];
        system.debug('opp stage-->'+opp.StageName);
        if(opp.StageName =='Closed Won'){
            system.debug('Inside If');
            return true;
        }else{
            system.debug('Inside Else');
            return  false;
        }
    }
    
    //Fetch Utility Accounts and create a accountListWrapper and return the list to component.
    @AuraEnabled 
    public static List<accountListWrapper> fetchAccountWrapper(Id oppId, String sortType,String sortField, Boolean isInit,Id priceIdToPass){  
        system.debug('isinit' + isInit);
        system.debug('priceIdToPass' + priceIdToPass);
        map<Id,Double> basePriceMap = new map<Id,Double>();
        map<Id,Double> basePriceWithCreditMap = new map<Id,Double>();
        List<accountListWrapper> lstaccountListWrapper = new List<accountListWrapper>();
        // query account records and create 'accountListWrapper' class instance for each record. 
        if(isInit){
            List<Price__c> price = [SELECT Id, Opportunity__r.StageName FROM Price__c WHERE Opportunity__c =: oppId AND CreatedDate = TODAY ORDER BY CreatedDate DESC];
            if(price.isEmpty() == false) {
                if (price[0].Opportunity__r.StageName == 'Closed Won') {
                    // Query syncing quote here and pass its price: Added for SU-902
                    List<Quote> syncingQuote = [SELECT Id, Price__c FROM Quote WHERE OpportunityId =: oppId AND IsSyncing = true AND Price__c != null  ORDER BY CreatedDate DESC ];
                    System.debug('Syncing Quote is ===' + syncingQuote);
                    if (syncingQuote.isEmpty() == false) {
                        updateUAOWithSelectedPrice(syncingQuote[0].Price__c, oppId);     
                    }
                }else{
                    updateUAOWithSelectedPrice(price[0].Id, oppId);   
                }
            }
        }
        String query =  'SELECT Id, Name, Utility_Account__r.Load_Factor_Display__c, Utility_Account__r.Utility__c , Utility_Account__r.Utility__r.Name,Start_Date__c,Twelve_Month_Price__c, Utility_Account__c, Opportunity__c,Opportunity__r.Start_Date__c, Status__c,Utility_Account__r.Annual_Usage_kWh__c,Utility_Account__r.Name, Utility_Account__r.Load_Factor__c FROM Utility_Account_Opportunity__c where Opportunity__c =: oppId ORDER BY '  +sortField +' '+ sortType;
        system.debug('query ' + query);
        List<Utility_Account_Opportunity__c> UAOs = Database.query(query);
        List<Term_Price__c> tpList = [SELECT Id,Base_Price__c, Base_Price_with_Credit_Premium__c , Utility_Account_Opportunity__c, Term__c, Name FROM Term_Price__c Where Utility_Account_Opportunity__c IN: [SELECT Id FROM Utility_Account_Opportunity__c where Opportunity__c =: oppId] AND Term__c = '12' AND Price__c =: priceIdToPass];
        system.debug('tpList==>'+tpList);
        for(Term_Price__c tp : tpList){
            basePriceMap.put(tp.Utility_Account_Opportunity__c,tp.Base_Price__c);
            basePriceWithCreditMap.put(tp.Utility_Account_Opportunity__c,tp.Base_Price_with_Credit_Premium__c);
        }
        System.debug('basePriceMap->'+basePriceMap);
        System.debug('basePriceWithCreditMap->'+basePriceWithCreditMap);
        for(Utility_Account_Opportunity__c acc : UAOs){
            system.debug('acc.Id'+acc.Id+'basePriceMap.get(acc.Id)'+basePriceMap.get(acc.Id)+'basePriceWithCreditMap.get(acc.Id)'+basePriceWithCreditMap.get(acc.Id));
            if(acc.Status__c == 'Priced - Excluded')
                lstaccountListWrapper.add(new accountListWrapper(false,acc,basePriceMap.get(acc.Id),basePriceWithCreditMap.get(acc.Id)));
            if(acc.Status__c == 'Not Priced')
                lstaccountListWrapper.add(new accountListWrapper(false,acc,basePriceMap.get(acc.Id),basePriceWithCreditMap.get(acc.Id)));
            if(acc.Status__c == NULL)
                lstaccountListWrapper.add(new accountListWrapper(false,acc,basePriceMap.get(acc.Id),basePriceWithCreditMap.get(acc.Id)));
            else if(acc.Status__c == 'Priced')
                lstaccountListWrapper.add(new accountListWrapper(true,acc,basePriceMap.get(acc.Id),basePriceWithCreditMap.get(acc.Id)));
        } 
        return lstaccountListWrapper; 
    }
    /* wrapper class */  
    public class accountListWrapper {
        @AuraEnabled public boolean isChecked {get;set;}
        @AuraEnabled public  Utility_Account_Opportunity__c objAccount{get;set;}
        @AuraEnabled public  Double BasePrice{get;set;}
        @AuraEnabled public  Double BasePriceWithCredit{get;set;}
        @AuraEnabled public String BillType {get;set;}
        public accountListWrapper(boolean isChecked, Utility_Account_Opportunity__c objAccount,Double BasePrice,Double BasePriceWithCredit){
            this.isChecked = isChecked;
            this.objAccount = objAccount;
            this.BasePrice = BasePrice;
            this.BasePriceWithCredit = BasePriceWithCredit;
            this.BillType =  BillType;
        }
        public accountListWrapper() {
        }
    }
    
    //Populate the Select Price picklist on Quote Generator 1st Screen based on Price Age , Day of Week(Monday).
    //display Older Prices for the users included in Permission set 'QuoteGenerator_ShowAllPrices'.
    @AuraEnabled 
    public static List<priceWrapper> getPrice(Id oppId){     
        List<priceWrapper> prices = new List<priceWrapper>();
        Datetime dt = System.now();
        List<Price__c> priceRecord = new List<Price__c>();
        List<PermissionSetAssignment> PSA = [SELECT Id, PermissionSetId, Assignee.Name FROM PermissionSetAssignment WHERE PermissionSet.Name = 'QuoteGenerator_ShowAllPrices' AND AssigneeId =: UserInfo.getUserId()];
        if(!PSA.isEmpty()){
            priceRecord  = [SELECT id,Credit_Detail__r.Status__c,Name,P_D__c, Subject_to_Credit__c , Credit__c,Pricing_Request__r.Name,Product_Lookup__r.Name,Product_Lookup__r.family,CreatedDate,Credit_Detail__r.Credit_Check_Outcome__c FROM Price__c WHERE Opportunity__c =: oppId AND Pricing_Request__c != NULL AND Obsolete__c = false ORDER BY CreatedDate DESC ];
        }
        else{
            String day = dt.format('EEEE');
            if(day != 'Monday')
                priceRecord  = [SELECT id,Credit_Detail__r.Status__c,Name,P_D__c,Subject_to_Credit__c, Credit__c,Pricing_Request__r.Name,Product_Lookup__r.Name,Product_Lookup__r.family,CreatedDate,Credit_Detail__r.Credit_Check_Outcome__c FROM Price__c WHERE Opportunity__c =: oppId AND Pricing_Request__c != NULL AND ( createdDate = TODAY OR CreatedDate = YESTERDAY) AND Obsolete__c = false ORDER BY CreatedDate DESC];
            else{
                Date d = Date.valueOf(dt.addDays(-3));
                priceRecord = [SELECT id,Credit_Detail__r.Status__c,Name,P_D__c,Subject_to_Credit__c, Credit__c,Pricing_Request__r.Name,Product_Lookup__r.Name,Product_Lookup__r.family,CreatedDate,Credit_Detail__r.Credit_Check_Outcome__c FROM Price__c WHERE Opportunity__c =: oppId AND Pricing_Request__c != NULL AND ( createdDate = TODAY OR CreatedDate =: d) AND Obsolete__c = false ORDER BY CreatedDate DESC];
            }
        }
        System.debug('priceRecord[0].Id-->> '+!priceRecord.isEmpty());
        Boolean isCreditExp = false;
        if(!priceRecord.isEmpty()){
            Price__c price = [SELECT id,Credit_Detail__r.Status__c FROM Price__c WHERE  id  =: priceRecord[0].Id Limit 1];
            System.debug('price----'+price);
            System.debug('price.Credit_Detail__r.Status__c==>> '+price.Credit_Detail__r.Status__c);
            
            if(price.Credit_Detail__r.Status__c == 'Expired'){
                isCreditExp = true;
            }
            
        }
        Date todayDate = System.today();
        string td = todayDate.format();
        for(Price__c p: priceRecord){
            Date d = Date.valueOf(p.CreatedDate);
            string createDate = d.format();
            boolean failed = false;
            Integer PriceAge = d.daysBetween(todayDate);
            boolean TwoDaysOld = false;
            if(p.Credit_Detail__r.Credit_Check_Outcome__c == 'Failed'){
                failed = true;
            }
            if(PriceAge > = 2 ){
                TwoDaysOld = true;
            }
            if(createDate == td)
                prices.add(new priceWrapper(p.Credit_Detail__r.Credit_Check_Outcome__c,failed,p.Subject_to_Credit__c, p.P_D__c,p.Credit__c, true, p.Id, p.Pricing_Request__r.Name, createDate,p.Product_Lookup__r.Name,p.Product_Lookup__r.family,TwoDaysOld,isCreditExp ));
            else
                prices.add(new priceWrapper(p.Credit_Detail__r.Credit_Check_Outcome__c,failed,p.Subject_to_Credit__c, p.P_D__c,p.Credit__c,false, p.Id, p.Pricing_Request__r.Name, createDate,p.Product_Lookup__r.Name,p.Product_Lookup__r.family,TwoDaysOld,isCreditExp ));
        }
        return prices;
    }
    
    //Wrapper class
    public class priceWrapper {
        @AuraEnabled public boolean isLatest {get;set;}
        @AuraEnabled public Id priceId{get;set;}
        @AuraEnabled public String priceName{get;set;}
        @AuraEnabled public string createdDate{get;set;}
        @AuraEnabled public string productName{get;set;}
        @AuraEnabled public string productfamily{get;set;}
        @AuraEnabled public boolean TwoDaysOld {get;set;}
        @AuraEnabled public boolean PDValue {get;set;}
        @AuraEnabled public boolean CreditValue {get;set;}
        @AuraEnabled public boolean SubjectToCredit {get;set;}
        @AuraEnabled public boolean FailedCredit {get;set;}
        @AuraEnabled public string outcome{get;set;}
        @AuraEnabled public boolean isCreditExp {get;set;}
        public priceWrapper(string outcome,boolean FailedCredit,boolean SubjectToCredit,boolean PDValue,boolean CreditValue,boolean isLatest, String priceId,String priceName, string createdDate,string productName,String productfamily,boolean TwoDaysOld,boolean isCreditExp){
            this.outcome = outcome;
            this.SubjectToCredit = SubjectToCredit;
            this.PDValue = PDValue;
            this.CreditValue = CreditValue;
            this.isLatest = isLatest;
            this.priceId = priceId;
            this.priceName = priceName;
            this.createdDate = createdDate;
            this.productName = productName;
            this.productfamily = productfamily;
            this.TwoDaysOld = TwoDaysOld;
            this.FailedCredit = FailedCredit;
            this.isCreditExp = isCreditExp;
        }
    }
    
    //Update utility Account Status and Start Date based on selected Price records and its related UAPR's start dates 
    @AuraEnabled
    public static void updateUAOWithSelectedPrice(Id priceId, Id oppId){     
        Set<String> UAOs = new Set<String>();
        List<Term_Price__c> termPriceRecords = [SELECT Id, Utility_Account_Opportunity__c FROM Term_Price__c where Price__r.Id =: priceId ];
        List<Price_Summary__c> PriceSummary = [SELECT Id, Price__c, Term_months__c, Base_Price__c FROM Price_Summary__c WHERE Price__c =: priceId AND Term_months__c = 12 limit 1];
        Price__c p = [Select Id,Pricing_Request__c From Price__c where Id =:priceId ];
        Map<String,Date> UADateMap = new Map<String,Date>();
        for(Utility_Account_Pricing__c uapr:[SELECT Id,Utility_Account__r.Name,Start_Date__c from Utility_Account_Pricing__c where Pricing_Request__c=:p.Pricing_Request__c] ){
            UADateMap.put(uapr.Utility_Account__r.Name,uapr.Start_Date__c);
        }
        System.debug('Start Dates->'+UADateMap.values());
        For(Term_Price__c tp: termPriceRecords )
            UAOs.add(tp.Utility_Account_Opportunity__c);
        List<Utility_Account_Opportunity__c> UAORecords = [Select Id,Name,Utility_Account__r.name, Status__c,Start_Date__c FROM Utility_Account_Opportunity__c WHERE Opportunity__c =: oppId];
        for(Utility_Account_Opportunity__c acc : UAORecords ){
            if(UAOs.contains(acc.Id)){
                acc.Status__c = 'Priced';
                System.debug('Start Dates->'+UADateMap.get(acc.Utility_Account__r.name));
                acc.Start_Date__c = UADateMap.get(acc.Utility_Account__r.name);
            }else{
                acc.Status__c = 'Not Priced';
            }
            if(PriceSummary.size() > 0 && acc.Status__c == 'Priced'){
                acc.Twelve_Month_Price__c = PriceSummary[0].Base_Price__c;     
            }
        }
        Update UAORecords;
    }
    
    //Create Price Summaries based on the Priced UAOs and selected Price.
    @AuraEnabled 
    public static Boolean updateExcludedUAO(List<Utility_Account_Opportunity__c> UAOList, List<Utility_Account_Opportunity__c> incUAOList, Id oppId,Id ChangedPriceId ){ 
        Boolean isItCreditPR;
        System.debug('oppId-->> '+oppId);
        Price__c price = [SELECT Id, Pricing_Request__c FROM Price__c WHERE Id =: ChangedPriceId];
        Pricing_Request__c pr = [SELECT Bill_Type__c FROM Pricing_Request__c WHERE Id =: price.Pricing_Request__c ];
        if(pr.Bill_Type__c == 'Dual' || pr.Bill_Type__c == 'UCB with Credit'){
            isItCreditPR = true;
        }else if(pr.Bill_Type__c == 'UCB'){
            isItCreditPR = false;
        }
        List<Utility_Account_Opportunity__c> lstUAOUpdated = new List<Utility_Account_Opportunity__c>();
        for(Utility_Account_Opportunity__c acc : UAOList ){
            acc.Status__c = 'Priced - Excluded';
            lstUAOUpdated.add(acc);
        } 
        for(Utility_Account_Opportunity__c acc : incUAOList ){
            if(acc.Status__c == 'Priced - Excluded')
                acc.Status__c = 'Priced';
            lstUAOUpdated.add(acc);
        } 
        update lstUAOUpdated; 
        
        List<Price_Summary__c> psRecords = [SELECT Id, Term_months__c, Base_Price__c, Cumulative_Volume__c FROM Price_Summary__c WHERE Price__c =: ChangedPriceId ];
        if(!psRecords.isEmpty())
            Delete psRecords;
        Create_Price_Summary.getTermPrice(new List<Id>{ChangedPriceId});
        
        return isItCreditPR;
    }
    
    //Display Price Summaries on Quote Generator second Screen by passing it in a wrapper list and return to component.
    @AuraEnabled 
    public static List<PSListWrapper> getPSRecords( String sortType,String sortField, String recordId,String changedPriceId){
        System.debug('recordId-->> '+recordId);
        List<PSListWrapper> lstPSListWrapper = new List<PSListWrapper>();
        string priceId = Id.valueOf(changedPriceId);
        Opportunity oppRecord = [SELECT Id,Type,Index_Contract__r.EndDate,Start_Date__c,Broker_Margin__c,Final_SEUS_Margin__c FROM Opportunity WHERE Id =: recordId];
        
        String query;
        if(oppRecord.Type !='Load Following'){
            query =  'SELECT Id, Term_months__c, Credit_Premium__c, Base_Price_with_Credit__c , POR_x_Volume__c, Price__c, TAX_x_Volume__c, Base_Price__c, POR_Factor__c, Tax_Factor__c, Cumulative_Volume__c FROM Price_Summary__c WHERE  price__c =:priceId ORDER BY '  +sortField +' '+ sortType;
        }else if(oppRecord.Type =='Load Following'){
            Integer dateDifference = (oppRecord.Start_Date__c).monthsBetween(oppRecord.Index_Contract__r.EndDate);
            System.debug('dateDifference-->> '+dateDifference);
            if(dateDifference < 0){
                dateDifference = dateDifference*-1; 
            }
            query =  'SELECT Id, Term_months__c, Credit_Premium__c, Base_Price_with_Credit__c , POR_x_Volume__c, Price__c, TAX_x_Volume__c, Base_Price__c, POR_Factor__c, Tax_Factor__c, Cumulative_Volume__c FROM Price_Summary__c WHERE  price__c =:priceId AND Term_months__c <= '+dateDifference+ ' ORDER BY '  +sortField +' '+ sortType;
        }

        List<Price_Summary__c> PSs = Database.query(query);
        Decimal brokerMargin = 0.00000;
        Decimal salesMargin = 0.0035;
        Decimal quotebrokerMargin = 0.00000;
        Decimal quotesalesMargin = 0.0035;
        if(oppRecord != NULL)
            if(oppRecord.Broker_Margin__c != NULL)
            quotebrokerMargin = oppRecord.Broker_Margin__c;
        system.debug('pss ' + PSs);
        system.debug('brokerMargin ' + brokerMargin);
        system.debug('oppRecord ' + oppRecord);
        List<Integer> previousTermMonths = new List<Integer>();
        List<Quote> quoteRecordList = [SELECT Id,Broker_Margin_per_unit__c,Default_Broker_Margin__c,Default_Sales_Margin__c , (Select Id, Term_Months__c,Sales_Margin_per_unit__c,Broker_Margin_per_unit__c FROM QuoteLineItems) FROM Quote WHERE OpportunityId=: recordId AND IsSyncing = true LIMIT 1];
        Map<Decimal,QuoteLineItem> termQliMap = new Map<Decimal,QuoteLineItem>();
        if(!quoteRecordList.isEmpty()){
            
            if(quoteRecordList[0].Default_Broker_Margin__c != null){
                quotebrokerMargin = quoteRecordList[0].Default_Broker_Margin__c;
            }
            if(quoteRecordList[0].Default_Sales_Margin__c != null){    
                quotesalesMargin = quoteRecordList[0].Default_Sales_Margin__c;
            }
            
            for(QuoteLineItem qli: quoteRecordList[0].QuoteLineItems ){
                previousTermMonths.add(Integer.valueOf(qli.Term_Months__c));
                termQliMap.put(qli.Term_Months__c,qli);        
            }            
        }else{
            System.debug('else');
            previousTermMonths = new Integer[] {6,12,18,24,30,36,42,48,54,60};  
                }
        system.debug('previousTermMonths ' + previousTermMonths);
        for(Price_Summary__c ps : PSs){
            if ( ps.Term_months__c == 6 && previousTermMonths.contains(6) || ps.Term_months__c == 12 && previousTermMonths.contains(12) || ps.Term_months__c == 18 && previousTermMonths.contains(18) || ps.Term_months__c == 24 && previousTermMonths.contains(24) || ps.Term_months__c == 30 && previousTermMonths.contains(30) || ps.Term_months__c == 36 && previousTermMonths.contains(36) 
                || ps.Term_months__c == 42 && previousTermMonths.contains(42) || ps.Term_months__c == 48 && previousTermMonths.contains(48) || ps.Term_months__c == 54 && previousTermMonths.contains(54) || ps.Term_months__c == 60 && previousTermMonths.contains(60) || previousTermMonths.contains(Integer.valueOf(ps.Term_months__c)) ){
                    if(!quoteRecordList.isEmpty()){
                        lstPSListWrapper.add(new PSListWrapper(quotesalesMargin,quotebrokerMargin,true,ps, termQliMap.get(ps.Term_months__c).Sales_Margin_per_unit__c, termQliMap.get(ps.Term_months__c).Broker_Margin_per_unit__c, 0, 0.0000,ps.Tax_Factor__c,0));
                    }else{
                        lstPSListWrapper.add(new PSListWrapper(quotesalesMargin,quotebrokerMargin,true,ps, quoteSalesMargin, quoteBrokerMargin, 0, 0.0000,ps.Tax_Factor__c,0));
                    }
                }else{
                    lstPSListWrapper.add(new PSListWrapper(quotesalesMargin,quotebrokerMargin,false,ps, quoteSalesMargin, quoteBrokerMargin, 0, 0.0000,ps.Tax_Factor__c,0));
                }
        } 
        return lstPSListWrapper; 
    }
    /* wrapper class */  
    public class PSListWrapper {
        @AuraEnabled public boolean isChecked {get;set;}
        @AuraEnabled public Decimal salesMargin {get;set;}
        @AuraEnabled public Decimal brokerMargin {get;set;}
        @AuraEnabled public Decimal quoteSalesMargin {get;set;}
        @AuraEnabled public Decimal quoteBrokerMargin {get;set;}
        @AuraEnabled public Decimal totalPrice {get;set;}
        @AuraEnabled public Decimal newSalesMargin {get;set;}
        @AuraEnabled public Decimal taxFactor {get;set;}
        @AuraEnabled public Decimal totalriceWithoutTax {get;set;}
        @AuraEnabled public  Price_Summary__c objAccount{get;set;}
        
        public PSListWrapper(Decimal quoteSalesMargin,Decimal quoteBrokerMargin,boolean isChecked, Price_Summary__c objAccount, Decimal salesMargin, Decimal brokerMargin, Decimal totalPrice, Decimal newSalesMargin,Decimal taxFactor,Decimal totalriceWithoutTax  ){
            this.quoteBrokerMargin = quoteBrokerMargin;
            this.quoteSalesMargin = quoteSalesMargin;
            this.isChecked = isChecked;
            this.objAccount = objAccount;
            this.salesMargin = salesMargin;
            this.brokerMargin = brokerMargin;
            this.totalPrice = totalPrice;
            this.newSalesMargin = newSalesMargin;
            this.taxFactor = taxFactor;
            this.totalriceWithoutTax = totalriceWithoutTax;
        }
        public PSListWrapper(){}
    }
    
    //To generate Quote and QLIs along with Utility Account Quote based on terms selected from the 2nd and 3rd Screen of Quote Generator.
    @AuraEnabled 
    public static String generateQuoteAndLineItems(List<PSListWrapper> psRecords, Id recordId, Decimal salesMargin, Decimal brokerMargin, Id selectedPriceId,boolean Capacity,Integer StoreVolumnOfTerm,Decimal AverageLoadFactor,Boolean toggleValue/*Decimal totalPrice*/){     
        System.debug('psRecords-->> '+psRecords);
        System.debug('In Try---');
        try{
            System.debug('In Try');
            List<OpportunityContactRole> evaluatorContact = [SELECT Contact.FirstName,Contact.Id 
                                                             FROM OpportunityContactRole
                                                             WHERE OpportunityId =: recordId
                                                             AND Role = 'Evaluator'];
            
            Contact selectedCon = new Contact();
            String Pricebook2Id = [SELECT id, name FROM pricebook2].Id;
            Price__c selectedPriceRecord = [SELECT Id,Mark_to_Market__c,Invoice_Billing_Type__c,Deposit_Amount__c,Prepayment_Amount__c,Pricing_Request__c,Voluntary_RECs__c, Voluntary_RECs_percent__c, Treatment__c, Bill_Type__c, Product_Lookup__c FROM Price__c WHERE Id =:selectedPriceId ];
            Pricing_Request__c prReq = [SELECT Id, Quoted__c, Pricing_Quote_Comments__c FROM Pricing_Request__c Where Id=: selectedPriceRecord.Pricing_Request__c ];
            prReq.Quoted__c = true;
            update prReq;
            String product2Id = '';
            String PricebookEntryId = '';
            if(selectedPriceRecord.Product_Lookup__c != NULL){
                System.debug('Pricebook2Id-->> '+Pricebook2Id);
                System.debug('selectedPriceRecord==>> '+selectedPriceRecord.Product_Lookup__c);
                PricebookEntry pricebookEntryRecord = [SELECT Id, Product2Id, Pricebook2Id FROM PricebookEntry WHERE Pricebook2Id =: Pricebook2Id AND Product2Id =: selectedPriceRecord.Product_Lookup__c ];
                PricebookEntryId = pricebookEntryRecord.Id;
                product2Id = pricebookEntryRecord.Product2Id;
            }else{
                PricebookEntry pricebookEntryRecord = [SELECT Id, Product2Id, Pricebook2Id FROM PricebookEntry WHERE Pricebook2Id =: Pricebook2Id LIMIT 1 ];
                PricebookEntryId = pricebookEntryRecord.Id;
                product2Id = pricebookEntryRecord.Product2Id;
            }
            System.debug('Try 1');
            Quote newQuoteRecord = new Quote();
            newQuoteRecord.Name = 'New Quote';            
            newQuoteRecord.Default_Sales_Margin__c = salesMargin;
            newQuoteRecord.Default_Broker_Margin__c = brokerMargin;
            newQuoteRecord.Mark_to_Market__c = selectedPriceRecord.Mark_to_Market__c;
            newQuoteRecord.Bill_Type__c = selectedPriceRecord.Bill_Type__c;
            newQuoteRecord.Invoice_Billing_Type__c = selectedPriceRecord.Invoice_Billing_Type__c;
            newQuoteRecord.Price__c = selectedPriceId;
            newQuoteRecord.Voluntary_RECs__c = selectedPriceRecord.Voluntary_RECs__c;
            newQuoteRecord.Voluntary_RECs_percent__c = selectedPriceRecord.Voluntary_RECs_percent__c;
            newQuoteRecord.Treatment__c = selectedPriceRecord.Treatment__c;     
            newQuoteRecord.Pricebook2Id = Pricebook2Id;
            newQuoteRecord.OpportunityId = recordId;
            newQuoteRecord.Product__c = product2Id;
            newQuoteRecord.Average_Load_Factor__c = AverageLoadFactor;
            newQuoteRecord.Pricing_Quote_Comments__c = prReq.Pricing_Quote_Comments__c;
            if(toggleValue == true){
                newQuoteRecord.Prepayment__c = selectedPriceRecord.Prepayment_Amount__c;
                newQuoteRecord.Deposit__c = selectedPriceRecord.Deposit_Amount__c;
                newQuoteRecord.Price_Type__c = 'Prepayment & Deposit';
            }else{
                newQuoteRecord.Price_Type__c = 'Credit';
            }
            if(evaluatorContact.size() > 0){
                selectedCon = [Select Id,Name
                               FROM Contact
                               WHERE Id =: evaluatorContact[0].Contact.Id];  
                
                newQuoteRecord.ContactId = selectedCon.Id;
            }
            insert newQuoteRecord;
            Decimal totalUAQAnualUsageKWH = 0;
            Date EarliestDate;
            boolean SetEarliestDate = false;
            List<Utility_Account_Opportunity__c> UAOs = [SELECT id,Annual_Usage_kWh__c, Utility_Account__c,Start_Date__c,Status__c FROM Utility_Account_Opportunity__c WHERE Opportunity__c =: recordId ];
            List<Utility_Account_Quote__c> UAQInserts = new List<Utility_Account_Quote__c>();
            For(Utility_Account_Opportunity__c UA: UAOs){
                totalUAQAnualUsageKWH = totalUAQAnualUsageKWH + UA.Annual_Usage_kWh__c;
                if(UA.Status__c == 'Priced'){
                    if(SetEarliestDate == false){
                        EarliestDate = UA.Start_Date__c;
                        SetEarliestDate = true;
                    }
                    if(EarliestDate > UA.Start_Date__c){
                        EarliestDate = UA.Start_Date__c;
                    }
                }
                
                Utility_Account_Quote__c UAQ = new Utility_Account_Quote__c();
                UAQ.Quote__c = newQuoteRecord.Id;
                UAQ.Utility_Account__c = UA.Utility_Account__c;
                UAQ.Start_Date__c = UA.Start_Date__c;
                if(UA.Status__c == NULL || UA.Status__c == '')
                    UAQ.Status__c = 'Not Priced';
                else
                    UAQ.Status__c = UA.Status__c;
                UAQ.Annual_Usage_kWh__c = UA.Annual_Usage_kWh__c;
                UAQInserts.add(UAQ);
            }
            newQuoteRecord.Start_Date__c = EarliestDate;
            update newQuoteRecord;
            Insert UAQInserts;
            Opportunity oppRecord = [SELECT Id, SyncedQuoteId,Start_Date__c FROM Opportunity WHERE Id =: recordId];
            oppRecord.SyncedQuoteId = newQuoteRecord.Id;
            oppRecord.StageName = 'Quoting';
            oppRecord.Start_Date__c = EarliestDate;
            Update oppRecord;
            Decimal minSalesMargin = 10000;
            List<QuoteLineItem> newQLIRecords = new List<QuoteLineItem>();
            for(PSListWrapper ps : psRecords){
                
                if(ps.salesMargin < minSalesMargin){
                    minSalesMargin = ps.salesMargin;
                }
                newQuoteRecord.Annual_Volume_kWh__c = totalUAQAnualUsageKWH;
                QuoteLineItem qliRecord = new QuoteLineItem();
                qliRecord.POR_Tax_Adjustment__c = ps.objAccount.POR_Factor__c + ps.objAccount.TAX_Factor__c -1;
                qliRecord.QuoteId = newQuoteRecord.Id;
                qliRecord.PricebookEntryID = pricebookEntryId;
                qliRecord.Product2Id = selectedPriceRecord.Product_Lookup__c;
                qliRecord.Term_Months__c = ps.objAccount.Term_months__c;
                if(toggleValue == true){
                    qliRecord.Base_Price__c = ps.objAccount.Base_Price__c;
                }else{
                    qliRecord.Base_Price__c = ps.objAccount.Base_Price_with_Credit__c;
                    qliRecord.Credit_Premium__c = ps.objAccount.Credit_Premium__c;
                }
                qliRecord.Tax_Factor__c = ps.objAccount.Tax_Factor__c;
                qliRecord.UnitPrice = ps.objAccount.Cumulative_Volume__c * ps.salesMargin;
                qliRecord.Total_Usage__c = ps.objAccount.Cumulative_Volume__c;
                qliRecord.Sales_Margin_per_unit__c = ps.salesMargin;
                qliRecord.Broker_Margin_per_unit__c = ps.brokerMargin;
                qliRecord.Quantity = 1;
                newQLIRecords.add(qliRecord);
                
            }
            if(!newQLIRecords.isEmpty()){
                if(minSalesMargin < 0.001)
                    newQuoteRecord.Low_Margin_Acknowledged__c = True;
                insert newQLIRecords;
                update newQuoteRecord;
            }
            return newQuoteRecord.Id;
        }
        catch(exception e){
            system.debug('Exception ' + e.getLineNumber() + e.getMessage());
            return 'Exception';
        }
    }
    
    //fetch Utility Accounts which are not present on opportunity 
    //This is used for 'Add Utility Accounts' button on Quote Generator to add more Utility Accounts to Opportunity as UAOs
    @auraEnabled
    public static List<utilityAccountListWrapper> getUAs(Id recordId){
        List<Utility_Account__c> utilityAccounts = new List<Utility_Account__c>();
        List<utilityAccountListWrapper> lstaccountListWrapper = new List<utilityAccountListWrapper>();
        List<Id> existingUAs = new List<Id>();
        Opportunity oppRecord = [SELECT id,AccountId, Name, State__c,(SELECT Id, utility_Account__c FROM Utility_Account_Opportunities__r) FROM Opportunity WHERE Id =: recordId];
        for(Utility_Account_Opportunity__c UAO : oppRecord.Utility_Account_Opportunities__r){
            existingUAs.add(UAO.utility_Account__c);
        }
        utilityAccounts = [SELECT id, Name, Utility__r.Name, service_address__c, load_factor__c, Annual_Usage_kWh__c, utility_state__c FROM utility_Account__c WHERE utility_state__c =: oppRecord.State__c AND Id NOT IN : existingUAs AND Account__c =: oppRecord.AccountId];
        system.debug('utilityAccounts' + utilityAccounts.size() + utilityAccounts );
        for(Utility_Account__c acc:utilityAccounts )
            lstaccountListWrapper.add(new utilityAccountListWrapper(false,acc));
        return lstaccountListWrapper;
    }
    
    /* wrapper class */  
    public class utilityAccountListWrapper {
        @AuraEnabled public boolean isChecked {get;set;}
        @AuraEnabled public  Utility_Account__c objAccount{get;set;}
        public utilityAccountListWrapper(boolean isChecked, Utility_Account__c objAccount){
            this.isChecked = isChecked;
            this.objAccount = objAccount;
        }
    }
    
    //Save newly added UAs as UAOs added from 'Add Utility Account' Button 
    @auraEnabled
    public static void saveUAs(Id recordId, List<Utility_Account__c> newUAs){
        List<Utility_Account_Opportunity__c> insertUAOs = new List<Utility_Account_Opportunity__c>();
        for(Utility_Account__c UA : newUAs){
            Utility_Account_Opportunity__c UAO = new Utility_Account_Opportunity__c();
            UAO.Opportunity__c = recordId;
            UAO.Utility_Account__c = UA.Id;
            UAO.Start_Date__c = UA.Supply_Start_Date__c;
            UAO.Status__c = 'Not Priced';
            insertUAOs.add(UAO);
        }
        Insert insertUAOs;
    }
    
    //Wrapper class
    public class SelectedPriceWrapper {
        @AuraEnabled public String productName {get;set;}
        @AuraEnabled public String productfamily {get;set;}
        @AuraEnabled public Boolean isCreditCheckExpired {get;set;}
        public SelectedPriceWrapper(String productName,String productfamily, Boolean isCreditCheckExpired){
            this.productName = productName;
            this.productfamily = productfamily; 
            this.isCreditCheckExpired = isCreditCheckExpired;
        }
    }
    
    //Pass selected price with productName and family to Component
    @auraEnabled
    public static SelectedPriceWrapper SelectedPriceName(Id priceId){
        System.debug('priceId====>>>> '+priceId);
        Boolean isCreditCheckExpired = false;
        String ProductName = '';
        String family = '';
        boolean Capacity = false;
        Price__c PriceObj = [SELECT Id,Product_Lookup__r.Name,Product_Lookup__r.family,Credit_Detail__r.Status__c FROM Price__c where id =:priceId];
        System.debug('isCreditCheckExpired-------'+PriceObj.Credit_Detail__r.Status__c);
        if(PriceObj.Credit_Detail__r.Status__c == 'Expired'){
            System.debug('isCreditCheckExpired-------'+PriceObj.Credit_Detail__r.Status__c);
            isCreditCheckExpired = true;
        }
        if(PriceObj.Product_Lookup__r.Name!=NULL){
            ProductName = PriceObj.Product_Lookup__r.Name;
        }
        if(PriceObj.Product_Lookup__r.family!=NULL){
            family = PriceObj.Product_Lookup__r.family;
        }
        return (new SelectedPriceWrapper(ProductName,family,isCreditCheckExpired));
    }
    
    //Total Price Validation for NIMO.
    //1.Total Price should have '4' or '9' as 4th decimal.
    //2.Total Price should have '0' as the 5th decimal.
    @AuraEnabled
    public static boolean TotalPriceValidation(Id OpptyId,List<Decimal> TotalPriceLst,Id selectedPriceId){
        Boolean Validated = true;
        List<Utility_Account_Opportunity__c> UAOLst = new List<Utility_Account_Opportunity__c>([SELECT Id, Name,Start_Date__c,Status__c, Opportunity__c, Utility__c FROM Utility_Account_Opportunity__c where Opportunity__c=:OpptyId AND Utility__c LIKE 'National Grid%' AND Status__c = 'Priced']);
        List<Price__c> pr = [SELECT Id,Bill_Type__c,Pricing_Request__r.Bill_Type__c FROM Price__c Where Id =: selectedPriceId AND (Bill_Type__c = 'Dual' OR Pricing_Request__r.Bill_Type__c = 'Dual')];
        system.debug('pr'+pr);
        if(pr.size()>0){
            Validated = true;
        }
        else{
            if(UAOLst.size()>0 && TotalPriceLst.size()>0){
                for(Decimal TotalPrice : TotalPriceLst ){
                    if((String.valueOf(TotalPrice.setscale(5)).left(6).right(1) == '9' && String.valueOf(TotalPrice.setscale(5)).left(7).right(1) == '0') || (String.valueOf(TotalPrice.setscale(5)).left(6).right(1) == '4' && String.valueOf(TotalPrice.setscale(5)).left(7).right(1) == '0')){
                        if(Validated != false){ 
                            Validated = true;
                        }
                    }else{
                        Validated = false;
                    }
                }
            }
        }
        system.debug('Validation->'+Validated);
        return Validated;
    }
    
    @AuraEnabled
    public static boolean AllowNIMOValidation(Id OpptyId,List<Decimal> TotalPriceLst,Id selectedPriceId){
        Boolean Validated = true;
        List<Utility_Account_Opportunity__c> UAOLst = new List<Utility_Account_Opportunity__c>([SELECT Id, Name,Start_Date__c,Status__c, Opportunity__c, Utility__c FROM Utility_Account_Opportunity__c where Opportunity__c=:OpptyId AND Utility__c LIKE 'National Grid%' AND Status__c = 'Priced']);
        List<Price__c> pr = [SELECT Id,Bill_Type__c,Pricing_Request__r.Bill_Type__c FROM Price__c Where Id =: selectedPriceId AND (Bill_Type__c = 'Dual' OR Pricing_Request__r.Bill_Type__c = 'Dual')];
        system.debug('pr'+pr);
        if(pr.size()>0){
            Validated = true;
        }else{
            if(UAOLst.size()>0 && TotalPriceLst.size()>0){
                for(Decimal TotalPrice : TotalPriceLst ){
                    if((String.valueOf(TotalPrice.setscale(5)).left(6).right(1) == '9' && String.valueOf(TotalPrice.setscale(5)).left(7).right(1) == '0') || (String.valueOf(TotalPrice.setscale(5)).left(6).right(1) == '4' && String.valueOf(TotalPrice.setscale(5)).left(7).right(1) == '0')){
                        if(Validated != false){ 
                            Validated = true;
                        }
                    }else{
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
    
    //Unused as of now
    @AuraEnabled
    public static boolean updateStartDates(List<accountListWrapper> UAOLst,Id recordId,Id priceId){
        boolean showPklst = true;
        integer counter = 0;
        List<Utility_Account_Opportunity__c> PreviousUAOLst = [Select id,Start_date__c,Status__c from Utility_Account_Opportunity__c where Opportunity__c =: recordId];
        List<Utility_Account_Opportunity__c> UAOLstToUpdate = new List<Utility_Account_Opportunity__c>();
        List<Utility_Account_Opportunity__c> UAOLstToUpdatefinal = new List<Utility_Account_Opportunity__c>();
        Map<Id,Utility_Account_Opportunity__c> UAOMap = new Map<Id,Utility_Account_Opportunity__c>();
        for(Utility_Account_Opportunity__c uao : PreviousUAOLst){
            UAOMap.put(uao.id,uao);
        }
        for(accountListWrapper uaoWrapper : UAOLst){
            Utility_Account_Opportunity__c ObjUao = new Utility_Account_Opportunity__c();
            ObjUao = uaoWrapper.objAccount;
            if(ObjUao.Start_Date__c != UAOMap.get(ObjUao.Id).Start_Date__c){
                UAOLstToUpdate.add(objUao);
            }
        }
        if(UAOLstToUpdate.size()>0){
            update UAOLstToUpdate;
        }
        return showPklst;
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
        Decimal CreditPremium; //added for Su-843
        String VoluntaryRECS='';
        Decimal VoluntaryRECSPercent;
        String VoluntaryRECSTreatment='';
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
            oppRecord = [SELECT Id, Type,Synced_Quote_Start_Date__c, Load_following__c, Account.Name,Account.Customer_ID__c,Final_SEUS_Margin__c, Commission_Type__c,Broker_Margin__c, SyncedQuoteId, Start_Date__c FROM Opportunity WHERE Id =: recordId];
        }else{
            Enrollment__c enrollmentRecord = [SELECT Id,Opportunity_Id__c,Contract__r.Opportunity__c FROM Enrollment__c WHERE Id =: recordId LIMIT 1];
            System.debug('recordId'+recordId);
            oppRecord = [SELECT Id, Type,Synced_Quote_Start_Date__c, Load_following__c, Account.Name,Account.Customer_ID__c,Final_SEUS_Margin__c, Commission_Type__c,Broker_Margin__c, SyncedQuoteId, Start_Date__c FROM Opportunity WHERE Id =: enrollmentRecord.Contract__r.Opportunity__c ];
            System.debug('oppRecord'+oppRecord);
        }
        if(oppRecord.SyncedQuoteId != null){
            Quo = [SELECT Id, Product__c,Annual_Volume_kWh__c,Voluntary_RECs__c,Voluntary_RECs_percent__c,Treatment__c FROM Quote Where Id =: oppRecord.SyncedQuoteId ];
            if( Quo.Product__c !=  null){
                pro = [SELECT Id, Name FROM Product2 Where Id =: Quo.Product__c];
                Product = pro.Name;
            }else{
                Product = '';
            }
            agr = [SELECT Max(Term_Months__c)term,QuoteId,SUM(Total_Unit_Price__c)tot FROM QuoteLineItem Where QuoteId =: oppRecord.SyncedQuoteId Group By QuoteId];
            term = (Decimal)agr.get('term');
            //added Credit_Premium__c in Query
            QLI = [SELECT Term_Months__c,Total_Usage__c,Revised_Sales_Margin_per_unit__c,Broker_Margin_per_unit__c,Sales_Margin_per_unit__c,Total_Unit_Price__c,QuoteId,Credit_Premium__c FROM QuoteLineItem Where Term_Months__c =: term AND QuoteId =: oppRecord.SyncedQuoteId];
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
            VoluntaryRECS =Quo.Voluntary_RECs__c; 
            VoluntaryRECSPercent =Quo.Voluntary_RECs_percent__c;
            VoluntaryRECSTreatment=Quo.Treatment__c; 
            TermVolume = QLI.Total_Usage__c; 
            ContractedPrice = QLI.Total_Unit_Price__c;
            CreditPremium = QLI.Credit_Premium__c;   //added for card SU-834 fro creditPremium
            SEUSmargin= salesMargin;
            BrokerMargin = QLI.Broker_Margin_per_unit__c;
        }else{
            objUAQ = '';
            Product = '';
            TermMonths =  null;
            TermVolume =null; 
            ContractedPrice = null;
            SEUSmargin= null;
            CreditPremium = null;     //added for card SU-834 fro creditPremium
            BrokerMargin = null;
            VoluntaryRECS = '';
            VoluntaryRECSPercent= null;
            VoluntaryRECSTreatment = '';
        }
        CustomerName = oppRecord.Account.Name ;
        Commission =  oppRecord.Commission_Type__c;
        CustomerNumber = oppRecord.Account.Customer_ID__c;
        if(oppRecord.Synced_Quote_Start_Date__c != null){
            StartDate = (oppRecord.Synced_Quote_Start_Date__c).format();
        }else{
            if (!Test.isRunningTest())
                StartDate = (oppRecord.Start_Date__c).format();
        }
        
        System.debug('oppRecord.Type-->> '+oppRecord.Type);
        System.debug('oppRecord.Load_following__c-->> '+oppRecord.Load_following__c);
        // //added CreditPremium for card SU-834 20-5-2022
        return new QuoteSummary(CustomerName, objUAQ, Product, CustomerNumber, StartDate, TermMonths, TermVolume, ContractedPrice, SEUSmargin, BrokerMargin, Commission,CreditPremium,VoluntaryRECS,VoluntaryRECSPercent,VoluntaryRECSTreatment,oppRecord.Type,oppRecord.Load_following__c );
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
        @AuraEnabled public Decimal CreditPremium{get;set;}    // added for card SU-843 to display creditPremium in component
        @AuraEnabled public String VoluntaryRECS{get;set;}
        @AuraEnabled public Decimal VoluntaryRECSPercent{get;set;}
        @AuraEnabled public String VoluntaryRECSTreatment{get;set;}
        @AuraEnabled public String Sale_Type{get;set;}
        @AuraEnabled public String Load_Followingpercent{get;set;}
        
        public QuoteSummary(String CustomerName, String objUA, String Product, String CustomerNumber, String StartDate, Decimal TermMonths, Decimal TermVolume, 
                            Decimal ContractedPrice, Decimal SEUSmargin, Decimal BrokerMargin, String Commission,Decimal CreditPremium ,String VoluntaryRECS,
                            Decimal VoluntaryRECSPercent,String VoluntaryRECSTreatment, String Sale_Type, String Load_Followingpercent ){
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
                                this.CreditPremium = CreditPremium;
                                this.VoluntaryRECS = VoluntaryRECS;
                                this.VoluntaryRECSPercent = VoluntaryRECSPercent;
                                this.VoluntaryRECSTreatment = VoluntaryRECSTreatment;
                                this.Sale_Type = Sale_Type;
                                this.Load_Followingpercent = Load_Followingpercent;                    
                            }
    }
    
    //SU 620 Created method to retrive Price record values
    @AuraEnabled
    public static returnPriceRecord getPriceValues(Id priceId){
        try{
            boolean failedCredit = false;
            Price__c priceRecord  = [SELECT Id,Pricing_Request__r.Bill_Type__c,Name,Credit_Detail__r.Credit_Check_Outcome__c,P_D__c,Subject_to_Credit__c, Credit__c, Prepayment_Amount__c, Deposit_Amount__c FROM Price__c WHERE Id =: priceId ];
            if(priceRecord.Credit_Detail__r.Credit_Check_Outcome__c == 'Failed'){
                failedCredit = true;
            }
            system.debug('priceRecord>>'+priceRecord);
            return new returnPriceRecord(failedCredit,priceRecord.Subject_to_Credit__c,priceRecord.P_D__c, priceRecord.Credit__c,priceRecord.Prepayment_Amount__c,priceRecord.Deposit_Amount__c,priceRecord.Pricing_Request__r.Bill_Type__c);
        }catch(Exception e){
            return new returnPriceRecord(false,false,false,false,0,0,'');
        }
    }
    public class returnPriceRecord{
        @AuraEnabled public Boolean SubjectToCredit {get;set;}
        @AuraEnabled public Boolean PDValue {get;set;}
        @AuraEnabled public Boolean CreditValue{get;set;}
        @AuraEnabled public Boolean FailedCredit{get;set;}
        @AuraEnabled public Decimal Prepayment_Amount {get;set;}
        @AuraEnabled public Decimal Deposit_Amount{get;set;}
        @AuraEnabled public String BillType{get;set;}
        public returnPriceRecord(Boolean FailedCredit,Boolean SubjectToCredit,Boolean PDValue,Boolean CreditValue,Decimal Prepayment_Amount,Decimal Deposit_Amount,String BillType){
            this.SubjectToCredit = SubjectToCredit;
            this.PDValue = PDValue;
            this.CreditValue = CreditValue;
            this.Prepayment_Amount = Prepayment_Amount;
            this.Deposit_Amount = Deposit_Amount;
            this.FailedCredit = FailedCredit;
            this.BillType = BillType;
        }
    }  
}