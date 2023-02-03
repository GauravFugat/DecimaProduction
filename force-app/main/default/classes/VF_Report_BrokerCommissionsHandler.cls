/*
* @Purpose: Display report for Broker commissions(Handler of VF_Report_BrokerCommissions vf page)
* @Author: Rahul Ghaytadak
* @CreatedDate:2/18/2021
* @Related Code: 
* @Test Class: VF_Report_BrokerCommissionsHandler_Test
* @LastModifiedDate:
* @LastModifiedBy: Rahul Ghaytadak
*/
public class VF_Report_BrokerCommissionsHandler {
    
    //Variable larations
    public Integer countOfRecords {get;set;}
    public String s {get;set;}
    public transient List<Opportunity> allOpportunities {get;set;}
    public transient String currentRecordId {get;set;}
    public transient List<wrapperClass> displayWrapperData {get;set;}
    public transient List<wrapperClass> lstSetController {get;set;}
    
    public static List<wrapperClass> DataForExport{get;set;}
    public static List<wrapperClass> DataForExport1{get;set;}
    public static List<wrapperClass> DataForExport2{get;set;}
    public static List<wrapperClass> DataForExport3{get;set;}
    public static List<wrapperClass> DataForExport4{get;set;}
    public static List<wrapperClass> DataForExport5{get;set;}
    
    public transient List<Utility_Account_Quote__c> SyncQuoteUAQ{get;set;}
    
    Public transient set<Id> QuoteIds{get;set;}
    Public transient set<Id> PriceIds{get;set;}
    Public transient set<Id> ContractIds{get;set;}
    public transient List<Term_Price__c> termPrice{get;set;}
    Public transient map<ID,Utility_Account_Quote__c> UAQMap{get;set;}
    Public transient map<ID,List<Utility_Account_Quote__c>> UAQMapList{get;set;}
    Public transient map<ID,decimal> PriceMap{get;set;}
    Public transient map<ID,decimal> UsageMap{get;set;}
    public transient boolean isExport{get; set;}
    CustomIterable obj;
    
    public static Map<Integer , wrapperClass> wrapperMap {get;set;}
    
    public VF_Report_BrokerCommissionsHandler () {
        wrapperMap = new Map<Integer , wrapperClass>();
        lstSetController = new List<wrapperClass>();
        currentRecordId  = ApexPages.CurrentPage().getparameters().get('id');
        allOpportunities = new List<Opportunity>();
        //Retrived all closed Won Opportunity 
        allOpportunities = [SELECT Id,Name,ContractId,StageName,Opportunity_ID__c,SyncedQuote.Price__c, Broker__r.Name, Account.Name, Owner.Name, SyncedQuoteId, AccountId, OwnerId, Commission_Type__c, Broker_Margin_per_unit__c , Start_Date__c FROM Opportunity Where StageName='Closed Won'];
        displayWrapperData = new List<wrapperClass>();
        DataForExport  = new List<wrapperClass>();
        DataForExport1  = new List<wrapperClass>();
        DataForExport2  = new List<wrapperClass>();
        DataForExport3  = new List<wrapperClass>();
        DataForExport4  = new List<wrapperClass>();
        DataForExport5  = new List<wrapperClass>();
        QuoteIds = new set<Id>();
        UAQMap =  new map<ID,Utility_Account_Quote__c>();
        PriceMap = new map<ID,decimal>();
        PriceIds = new set<Id>();
        ContractIds = new set<Id>();
        UsageMap = new map<ID,decimal>();
        
        UAQMapList =  new map<ID,list<Utility_Account_Quote__c>>();
        //Store all Sync Quotes
        for(Opportunity o : allOpportunities){
            if(o.SyncedQuoteId != null){
                QuoteIds.add(o.SyncedQuoteId);
                PriceIds.add(o.SyncedQuote.Price__c);
                ContractIds.add(o.ContractId);
            }
        }
        List<Utility_Account_Quote__c> UAQlst = new List<Utility_Account_Quote__c>();
        
        //Retrive All UAQ related to syc Quotes
        SyncQuoteUAQ = [SELECT Id, Utility_Account__c,Utility_Account__r.Utility__r.Name,Utility_Account__r.Name, Quote__c,Utility__c,Status__c FROM Utility_Account_Quote__c Where Quote__c =: QuoteIds AND Status__c = 'Priced'];
        //Store the UAQ in list related to quote
        for(Utility_Account_Quote__c UAQ : SyncQuoteUAQ ){
            UAQMap.put(UAQ.Quote__c,UAQ);
            if(UAQMapList.containsKey(UAQ.Quote__c)){
                UAQlst=UAQMapList.get(UAQ.Quote__c);
                UAQlst.add(uAQ);
                UAQMapList.put(UAQ.Quote__c,UAQlst);
            }else{
                UAQlst = new List<Utility_Account_Quote__c>();
                UAQlst.add(uAQ);
                UAQMapList.put(UAQ.Quote__c,UAQlst);
            }
        }
        
        /**
        //Retrive '12 term' term prices 
        termPrice = [SELECT Id, Price__c, Utility_Account_Opportunity__r.Utility_Account__c , Cumulative_Volume__c,Term__c FROM Term_Price__c Where Price__c =:PriceIds AND Term__c = '12' ];
        for(Term_Price__c tp : termPrice){
            PriceMap.put(tp.Utility_Account_Opportunity__r.Utility_Account__c, tp.Cumulative_Volume__c); 
        }
        system.debug('termPrice>>'+termPrice); 
        **/
        
        List<Utility_Account_Contract__c> UAClst = new List<Utility_Account_Contract__c>();
        UAClst = [SELECT Id, Utility_Account__c, Annual_Usage_kWh__c FROM Utility_Account_Contract__c Where Contract__c =:ContractIds ];
        for(Utility_Account_Contract__c uac : UAClst){
            UsageMap.put(uac.Utility_Account__c, uac.Annual_Usage_kWh__c ); 
        }
        
        
        
        //   wrapperClass wrap = new wrapperClass();
        for(Opportunity o : allOpportunities){
            if(o.SyncedQuoteId != NULL){
                if(UAQMapList.get(o.SyncedQuoteId) != NULL){
                    for(Utility_Account_Quote__c uaq :  UAQMapList.get(o.SyncedQuoteId)){
                        if(displayWrapperData.size() < 2000){
                            displayWrapperData.add(new wrapperClass(o.Broker__r.Name, o.Account.Name, o.Opportunity_ID__c, o.Owner.Name, o.Commission_Type__c, o.Broker_Margin_per_unit__c, uaq.Utility_Account__r.Name,uaq.Utility_Account__r.Utility__r.Name,Integer.valueOf(UsageMap.get(uaq.Utility_Account__c)),o.Start_Date__c));
                        }
                        DataForExport.add(new wrapperClass(o.Broker__r.Name, o.Account.Name, o.Opportunity_ID__c, o.Owner.Name, o.Commission_Type__c, o.Broker_Margin_per_unit__c, uaq.Utility_Account__r.Name,uaq.Utility_Account__r.Utility__r.Name,Integer.valueOf(UsageMap.get(uaq.Utility_Account__c)),o.Start_Date__c));                        
                    }
                }
            }
        }
        System.debug('displayWrapperData size '+ displayWrapperData.size());
        System.debug('DataForExport size' + DataForExport.size());
        countOfRecords = DataForExport.size();
        if(displayWrapperData.size() >= 20){
            s = 'This report has more results than we can show (up to 2,000 records). Please export the full report for the entire data';
        }
        for(Integer index = 0 ; index < DataForExport.size() ; index++) {
            wrapperMap.put(index, DataForExport[index]);
        }
        obj = new CustomIterable (displayWrapperData); 
        obj.setPageSize = 100;
        next();  
        
        
    }
    
    public Boolean hasNext {
        get 
        {
            return obj.hasNext();
        }
        set;
    }
    
    public Boolean hasPrevious {
        get 
        {
            return obj.hasPrevious();
        }
        set;
    }
    
    public void next() 
    {
        displayWrapperData = obj.next();
    }
    
    public void previous() 
    {
        displayWrapperData = obj.previous();
    }
    // Used method to export report
    public PageReference getexport() {
        VF_Report_BrokerCommissionsHandler vf = new VF_Report_BrokerCommissionsHandler();
        //system.debug('DataForExport>>'+DataForExport.size());
        return new Pagereference('/apex/VFReport_BrokerComissionsExport');
        // isExport= true;
        // return null;
    }
    
    
}