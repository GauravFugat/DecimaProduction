public class PrepareForContractAura {
    
    @AuraEnabled
    public static List<wrapperSetupForOpp> getOppData(String Id) {
        system.debug('**PrepareForContractAura');
        List<wrapperSetupForOpp> setDataOpp = new List<wrapperSetupForOpp>();
        wrapperSetupForOpp wrapperObjOpp = new wrapperSetupForOpp();
        Opportunity oppData = [select Id, SyncedQuoteId, OwnerId,Broker_Margin__c,Broker__c, Commission_Type__c, Broker__r.name, Owner.name, Type, Commission_Discount__c, Switching_Type__c, CPM_Credit_Confirmation__c from Opportunity where ID=:Id limit 1] ;
        Quote quoteData = new Quote();
        if (oppData.SyncedQuoteId != null)
        	quoteData = [select Id, Bill_Type__c from Quote where Id=:oppData.SyncedQuoteId limit 1] ;
        
        wrapperObjOpp.oppId = oppData.Id;
        wrapperObjOpp.oppCommission_Type = oppData.Commission_Type__c;

        wrapperObjOpp.oppSwitching_Type = oppData.Switching_Type__c != null ? oppData.Switching_Type__c : 'On-Cycle';
        wrapperObjOpp.oppCpmCredit = oppData.CPM_Credit_Confirmation__c == true ? true : false;
        

        wrapperObjOpp.BrokerName = oppData.Broker__r.name;
        wrapperObjOpp.Commission_Discount = oppData.Commission_Discount__c;
        wrapperObjOpp.ownerName = oppData.Owner.name;
        wrapperObjOpp.Type = oppData.Type;
        //
        if(oppData.Broker_Margin__c == NULL  ){
            wrapperObjOpp.missedFieldsLstOpp.add('Broker & Margin');
             system.debug('In wrapperObjOpp 24'+wrapperObjOpp.BrokerMargin);
        }
        
        if(oppData.OwnerId == NULL ){
            wrapperObjOpp.missedFieldsLstOpp.add('Owner');
             system.debug('In wrapperObjOpp 28'+wrapperObjOpp.BrokerMargin);
        }
        wrapperObjOpp.ownerId =oppData.OwnerId;
        wrapperObjOpp.BrokerMargin = oppData.Broker_Margin__c;
        system.debug('In wrapperObjOpp '+wrapperObjOpp.BrokerMargin);
        //
        
        wrapperObjOpp.quotesBillType = quoteData.Bill_Type__c;
        setDataOpp.add(wrapperObjOpp);
        return setDataOpp;
    }
    
   
	@AuraEnabled
    public static List<wrapperSetup> getContactData (String Id, String accId){
       
        Contact contactData = new contact();
        List<wrapperSetup> setData = new List<wrapperSetup>();
        
        wrapperSetup wrapperObj=new wrapperSetup();
       	
        Opportunity  oppData = [select Id, Account.Primary_Contact__c, ContactId from Opportunity where ID=:Id limit 1] ;
        
        if (oppData.Account.Primary_Contact__c != null){
            contactData = [select Id, name,email from Contact where Id =:oppData.Account.Primary_Contact__c];
	        system.debug('get contactData ==>'+contactData);
            wrapperObj.conId = contactData.Id;
            wrapperObj.conName = contactData.name;
            wrapperObj.conEmail = contactData.email;
            wrapperObj.conExists = true;
        }else{
            wrapperObj.conExists = false;
        }
        
        Account accData = [select id, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, name, phone, Tax_Exempt__c, Taxable_Portion__c  from account where Id =:accId];
        system.debug('get accData ==>'+accData);
                
        wrapperObj.accId = accData.id;
        wrapperObj.accName = accData.name;
        wrapperObj.accPhone = String.valueOf(accData.phone);
        wrapperObj.accBillingStreet = accData.BillingStreet;
        wrapperObj.accBillingCity = accData.BillingCity;
        wrapperObj.accBillingState = accData.BillingState;
        wrapperObj.accBillingPostalCode = accData.BillingPostalCode;
        wrapperObj.accBillingCountry = accData.BillingCountry;
        
        wrapperObj.accTaxExempt = accData.Tax_Exempt__c;
        
        wrapperObj.accTaxablePortion = accData.Taxable_Portion__c != null ? accData.Taxable_Portion__c : 0.00;
        
        setData.add(wrapperObj);
        system.debug('get setData ==>'+setData);
        return setData;
    }
    
    
    public class wrapperSetupForOpp {
        @AuraEnabled
        public String oppId {get; set;}
        @AuraEnabled
        public String oppCommission_Type {get; set;}
        @AuraEnabled
        public String oppSwitching_Type {get; set;}
        @AuraEnabled
        public Boolean oppCpmCredit {get; set;}
        @AuraEnabled
        public String quotesBillType {get; set;}
        @AuraEnabled
        public String BrokerName {get; set;}
        @AuraEnabled
        public Decimal Commission_Discount {get; set;}
        @AuraEnabled
        public String Type {get; set;}
        @AuraEnabled
        public String ownerName {get; set;}
        // last modified : 11-oct-2021
        @AuraEnabled public  List<String> missedFieldsLstOpp = new List<String>();
         @AuraEnabled
        public String ownerId {get; set;}
         @AuraEnabled
        public Decimal BrokerMargin {get; set;}
        
        //
    }
    
    public class wrapperSetup {
        @AuraEnabled
        public Boolean conExists {get; set;}
        @AuraEnabled
        public String conId {get; set;}
        @AuraEnabled
        public String conName {get; set;}
        @AuraEnabled
        public String conEmail {get; set;}
        @AuraEnabled
        public String accId {get; set;}
        @AuraEnabled
        public String accName {get; set;}
        @AuraEnabled
        public String accPhone {get; set;}
        @AuraEnabled
        public String accBillingStreet {get; set;}
        @AuraEnabled
        public String accBillingCity {get; set;}
        @AuraEnabled
        public String accBillingState {get; set;}
        @AuraEnabled
        public String accBillingPostalCode {get; set;}
        @AuraEnabled
        public String accBillingCountry {get; set;}
        @AuraEnabled
        public Boolean accTaxExempt {get; set;}
        @AuraEnabled
        public Double accTaxablePortion {get; set;}
    }
    
    
    @AuraEnabled
    public static QuoteSummary getQuoteSummaryData(Id recordId){
        system.debug('recordId=>'+recordId);
        String CustomerName = '';
        String objUAQ= '';
        String Product= '';
        String CustomerNumber= '';
        String StartDate;
        String Switching;
        Boolean Cpm;
        Decimal TermMonths;
        Decimal TermVolume;
        Decimal ContractedPrice;
        Decimal SEUSmargin;
        Decimal BrokerMargin;
        String Commission= '';
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
           oppRecord = [SELECT Id, Account.Name,Account.Customer_ID__c,Final_SEUS_Margin__c, Commission_Type__c, Switching_Type__c, CPM_Credit_Confirmation__c, Broker_Margin__c, SyncedQuoteId, Start_Date__c FROM Opportunity WHERE Id =: recordId];
        }else{
            Enrollment__c enrollmentRecord = [SELECT Id,Opportunity_Id__c,Contract__r.Opportunity__c FROM Enrollment__c WHERE Id =: recordId LIMIT 1];
        System.debug('recordId'+recordId);
         oppRecord = [SELECT Id, Account.Name,Account.Customer_ID__c,Final_SEUS_Margin__c, Commission_Type__c, Switching_Type__c, CPM_Credit_Confirmation__c, Broker_Margin__c, SyncedQuoteId, Start_Date__c FROM Opportunity WHERE Id =: enrollmentRecord.Contract__r.Opportunity__c ];
		 System.debug('oppRecord'+oppRecord);
        }
        if(oppRecord.SyncedQuoteId != null){
            Quo = [SELECT Id, Product__c,Annual_Volume_kWh__c FROM Quote Where Id =: oppRecord.SyncedQuoteId ];
            if( Quo.Product__c !=  null){
                pro = [SELECT Id, Name FROM Product2 Where Id =: Quo.Product__c];
                Product = pro.Name;
            }else{
                Product = '';
            }
            agr = [SELECT Max(Term_Months__c)term,QuoteId,SUM(Total_Unit_Price__c)tot FROM QuoteLineItem Where QuoteId =: oppRecord.SyncedQuoteId Group By QuoteId];
            term = (Decimal)agr.get('term');
            QLI = [SELECT Term_Months__c,Total_Usage__c,Revised_Sales_Margin_per_unit__c,Broker_Margin_per_unit__c,Sales_Margin_per_unit__c,Total_Unit_Price__c,QuoteId FROM QuoteLineItem Where Term_Months__c =: term AND QuoteId =: oppRecord.SyncedQuoteId];
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
            TermVolume = QLI.Total_Usage__c; 
            ContractedPrice = QLI.Total_Unit_Price__c;
            SEUSmargin= salesMargin;
            BrokerMargin = QLI.Broker_Margin_per_unit__c;
        }
        else{
            objUAQ = '';
            Product = '';
            TermMonths =  null;
            TermVolume =null; 
            ContractedPrice = null;
            SEUSmargin= null;
            BrokerMargin = null;
        }
        CustomerName = oppRecord.Account.Name ;
        Commission =  oppRecord.Commission_Type__c;
        Switching =  oppRecord.Switching_Type__c;
        Cpm = oppRecord.CPM_Credit_Confirmation__c;
        CustomerNumber = oppRecord.Account.Customer_ID__c;
        if(oppRecord.Start_Date__c != null){
            StartDate = (oppRecord.Start_Date__c).format();
        }
        
        //system.debug('get summry ==>'+new QuoteSummary(CustomerName, objUAQ, Product, CustomerNumber, StartDate, TermMonths, TermVolume, ContractedPrice, SEUSmargin, BrokerMargin, Commission ));
        QuoteSummary obj = new QuoteSummary(CustomerName, objUAQ, Product, CustomerNumber, StartDate, TermMonths, TermVolume, ContractedPrice, SEUSmargin, BrokerMargin, Commission );
        system.debug('get summry obj ==>'+obj);
        return obj;
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
        public QuoteSummary(String CustomerName, String objUA, String Product, String CustomerNumber, String StartDate, Decimal TermMonths, Decimal TermVolume, Decimal ContractedPrice, Decimal SEUSmargin, Decimal BrokerMargin, String Commission ){
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
        }
    }
    
    
    // submit data into DB
    @AuraEnabled
    public static String doPostData(String AccId, 
                                    String OppId, 
                                    String ConId, 
                                    String contactName, 
                                    String contactEmail, 
                                    String accName, 
                                    String accPhone, 
                                    String BillingStreet, 
                                    String BillingPostalCode, 
                                    String BillingCountry, 
                                    String BillingCity, 
                                    String BillingState, 
                                    String oppCommissionType,
                                    String oppSwitchingType,
                                    Boolean oppCpmCredit,
                                    Boolean taxExempt,
                                   	Boolean conExists) {
        
       	Account updateAcc = new Account(
        									BillingStreet = BillingStreet,
            								BillingCity = BillingCity,
											BillingState = BillingState,
											BillingPostalCode = BillingPostalCode,
											BillingCountry = BillingCountry,
											name = accName,
											phone = accPhone,
            								Tax_Exempt__c = taxExempt,
											Id = AccId
        								);
        system.debug('get acc value ==>'+updateAcc);
        update updateAcc;
        
                                        System.Debug('ConId-->' + ConId);                                          
        if (conExists != false){
            System.Debug('Contact Code Executed');    
            String fName;
            String LName;
            if (contactName.contains(' ')){
                List<String> res = contactName.split(' ', 2);
                System.debug(res);   
                fName = res[0] != null ? res[0] : '';
                LName = res[1] != null ? res[1] : '';
            }
            else{
                LName = contactName;    
            }
            
            try{
                Contact updateCon = new Contact(
                    FirstName = fName,
                    LastName = LName,
                    email = contactEmail,
                    Id = ConId
                );
                update updateCon;               
            }catch(DmlException e) {
                System.debug('The following exception has occurred: ' + e.getMessage());
            }
            
            
        }         
                                        try{                  
                                            Opportunity updateOpp = new Opportunity(
                                                Commission_Type__c = oppCommissionType,
                                                Switching_Type__c = oppSwitchingType,
                                                CPM_Credit_Confirmation__c = oppCpmCredit,
                                                Id = OppId
                                            );
                                            update updateOpp;   } 
                                        catch(DmlException e) {
                                            System.debug('The following exception has occurred: ' + e.getMessage());
                                        }
        return 'Data successfully updated';
    }
}