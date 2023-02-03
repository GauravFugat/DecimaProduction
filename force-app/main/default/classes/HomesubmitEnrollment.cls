/*
* @Purpose: controller of HomesubmitEnrollment component.
* @Author: Aress Dev
* @Test Class: HomeSubmitEnrollment_Test
* @LastModifiedBy: Tushar Shinde
*/

public class HomesubmitEnrollment {
    
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
        
        @AuraEnabled public Utility_Account_Enrollment__c objUAE{get;set;}
        @AuraEnabled public List<String> userOptions{get;set;}
        
        @AuraEnabled public boolean contractSignedDate {get;set;}
        @AuraEnabled public string errorMsg {get;set;}
        
        @AuraEnabled public boolean checkCurrentSortOrder{get;set;}
        @AuraEnabled public string MarketRateCode {get;set;}
        
        @AuraEnabled public boolean isNationalGridandNullMarketRate {get;set;}
    }
    
    /*This function is used 
1. on load of component 
2. onFilterChange function in js */
    @auraEnabled
    public static List<UAEListWrapper> getFilteredUAEs(String enrollemtStatus, Boolean isDoinIt,String selectedGroup){  
        Id userId = UserInfo.getUserId();
        User usr = [SELECT Id,Name,Selected_Options_1__c,My_Utility_Groups__c FROM User WHERE Id =: userId];
        String userGroups = usr.My_Utility_Groups__c;
        System.debug('userGroups-->> '+userGroups);
        List<String> usrOpts = usr.Selected_Options_1__c.split(','); 
        List<UAEListWrapper> uaesToReturn = new List<UAEListWrapper>();
        List<Utility_Account_Enrollment__c> uaeRecords = new List<Utility_Account_Enrollment__c>();
        list<String> uaeIds = new list<String>();
        // List<String> getProgramCodes = new List<String>();
        Map<Id,String> getProgramCodes = new Map<Id,String>();
        String sQuery = 'SELECT Id,Duplicate_Detected__c,Utility_Account__r.Utility__r.Rate_Code_Required__c,Enrollment__r.Account__c,Enrollment__r.ProductId__c,Auto_Submitted_Date__c ,Enrollment__r.Broker_Id__c,Enrollment__r.Account__r.Primary_Contact__c,RateClass__c,AutoSubmitFlag__c,Enrollment__r.Taxable_Portion__c,Contract_Start__c,Bill_Type__c,Utility_Account__r.Service_Class__c,Status__c,Utility_Account__r.Service_Address__c,Utility_Account__r.Market_Rate_Code__c,Utility_Account__r.Status__c,Enrollment__r.Name,Enrollment__r.Account__r.Customer_ID__c,Enrollment__r.Contract__r.ContractNumber,Enrollment__r.Contract_Signed_Date__c,Enrollment__r.Bill_Type__c,Enrollment__r.Product__c,Enrollment__r.Account__r.Name,Utility_Account__r.Utility__r.Name,Utility_Account__r.Name, Enrollment__r.Contract__r.StartDate,Enrollment__r.Contract_Term__c,Enrollment__r.Rate_Amount__c, Tax_Exempt__c,Enrollment__r.Sale_Type__c,Utility_Account__r.Average_Meter_Read_Date__c,Enrollment__r.Broker_Name__c,Enrollment__r.Contract__r.Opportunity__r.Account.Owner.Name,Market_Rate_Code__c FROM Utility_Account_Enrollment__c';
        if(enrollemtStatus == 'defaultUAEs'){
            sQuery += ' WHERE (Status__c = \'Enrollment Request Pending\' OR Status__c = \'Enrollment Request Failed\')';
        }else if(enrollemtStatus == 'acceptedUAEs'){
            sQuery += ' WHERE Status__c = \'Enrollment Request Accepted\'';
        }else if(enrollemtStatus == 'pendingUAEs'){
            sQuery += ' WHERE Status__c = \'Enrollment Request Pending\'';
        }else if(enrollemtStatus == 'failedUAEs'){
            sQuery += ' WHERE Status__c = \'Enrollment Request Failed\'';
        }else if(enrollemtStatus == 'submittedUAEs'){
            if(sQuery.contains('WHERE')){
                sQuery += ' AND (Status__c = \'Enrollment Request Submitted\')';
            }else{
                sQuery += ' WHERE (Status__c = \'Enrollment Request Submitted\')';
            }
        } 
        if(enrollemtStatus == 'defaultUAEs'){
            sQuery += ' AND (Ready_for_Enrollment__c = true)';
            // System.debug('sQuery-->> '+sQuery);
        }
        // On load isDoinIt will be true and we are setting selectedGroup = 'myGroups' which is default value for groups
        if(isDoinIt == true){
            selectedGroup = 'myGroups';
        }
        // below code will check the group filter value to work in cobination with status filter
        // if myGroups is the value for group filter the group will vary depend on user groups, else we are checking for other values like Group A,B,C or All
        if(selectedGroup == 'myGroups'){
            if(userGroups.contains('Group A') && !userGroups.contains('Group B') && !userGroups.contains('Group C')){
                if(sQuery.contains('WHERE')){
                    sQuery += ' AND (Utility_Account__r.Utility__r.Group__c includes (\'Group A\')) ';
                }else{
                    sQuery += ' WHERE (Utility_Account__r.Utility__r.Group__c includes (\'Group A\')) ';
                }
                
            }else if((!userGroups.contains('Group A') && userGroups.contains('Group B') && !userGroups.contains('Group C'))){
                if(sQuery.contains('WHERE')){
                    sQuery += ' AND (Utility_Account__r.Utility__r.Group__c includes (\'Group B\')) ';
                }else{
                    sQuery += ' WHERE (Utility_Account__r.Utility__r.Group__c includes (\'Group B\')) ';   
                }
            }else if((!userGroups.contains('Group A') && !userGroups.contains('Group B') && userGroups.contains('Group C'))){
                if(sQuery.contains('WHERE')){
                    sQuery += ' AND (Utility_Account__r.Utility__r.Group__c includes (\'Group C\')) ';
                }else{
                    sQuery += ' WHERE (Utility_Account__r.Utility__r.Group__c includes (\'Group C\')) ';   
                }
            }else if((userGroups.contains('Group A') && userGroups.contains('Group B') && !userGroups.contains('Group C'))){
                //System.debug('in els if A , B');
                if(sQuery.contains('WHERE')){
                    sQuery += ' AND (Utility_Account__r.Utility__r.Group__c includes (\'Group A\',\'Group B\'))';
                    // sQuery += ' AND (Utility_Account__r.Utility__r.Group__c = \'Group A\' OR Utility_Account__r.Utility__r.Group__c = \'Group B\')';
                }else{
                    sQuery += ' WHERE (Utility_Account__r.Utility__r.Group__c includes (\'Group A\',\'Group B\'))';    
                }
            }else if((userGroups.contains('Group A') && !userGroups.contains('Group B') && userGroups.contains('Group C'))){
                if(sQuery.contains('WHERE')){
                    sQuery += ' AND (Utility_Account__r.Utility__r.Group__c includes (\'Group A\',\'Group C\')) ';
                }else{
                    sQuery += ' WHERE (Utility_Account__r.Utility__r.Group__c includes (\'Group A\',\'Group C\')) ';
                }
            }else if((!userGroups.contains('Group A') && userGroups.contains('Group B') && userGroups.contains('Group C'))){
                if(sQuery.contains('WHERE')){
                    sQuery += ' AND (Utility_Account__r.Utility__r.Group__c includes (\'Group B\',\'Group C\')) ';
                }else{
                    sQuery += ' WHERE (Utility_Account__r.Utility__r.Group__c includes (\'Group B\',\'Group C\')) ';
                    
                }
            }else if((userGroups.contains('Group A') && userGroups.contains('Group B') && userGroups.contains('Group C'))){
                if(sQuery.contains('WHERE')){     
                    sQuery += ' AND (Utility_Account__r.Utility__r.Group__c includes (\'Group A\',\'Group B\',\'Group C\')) ';
                }else{
                    sQuery += ' WHERE (Utility_Account__r.Utility__r.Group__c includes (\'Group A\',\'Group B\',\'Group C\')) ';
                    
                }
            }
        }else if(selectedGroup == 'groupA'){
            if(sQuery.contains('WHERE')){
                sQuery += ' AND (Utility_Account__r.Utility__r.Group__c includes (\'Group A\')) ';
            }else{
                sQuery += ' WHERE (Utility_Account__r.Utility__r.Group__c includes (\'Group A\')) '; 
            }
        }else if(selectedGroup == 'groupB'){
            if(sQuery.contains('WHERE')){
                sQuery += ' AND (Utility_Account__r.Utility__r.Group__c includes (\'Group B\')) ';
            }else{
                sQuery += ' WHERE (Utility_Account__r.Utility__r.Group__c includes (\'Group B\')) ';    
            }
        }else if(selectedGroup == 'groupC'){
            if(sQuery.contains('WHERE')){
                sQuery += ' AND (Utility_Account__r.Utility__r.Group__c includes (\'Group C\')) ';
            }else{
                sQuery += ' WHERE (Utility_Account__r.Utility__r.Group__c includes (\'Group C\')) ';    
            }
        }
        
        System.debug('sQuery-----> '+sQuery );
        // sQuery += ' LIMIT 30';
        
        //Final query after all above operation will be queried below
       
        uaeRecords = Database.query(sQuery + ' limit 200');
        
        Map<Id,Decimal> uaIdEnrollRateAmt = new Map<Id,Decimal>();
        Map<Id,Id> uaeUaMap = new Map<Id,Id>();
        for(Utility_Account_Enrollment__c uae: uaeRecords){
            
            uaIdEnrollRateAmt.put(uae.Utility_Account__c,uae.Enrollment__r.Rate_Amount__c);
            uaeUaMap.put(uae.Utility_Account__c, uae.Id);
            //if(uae.Utility_Account__r.Utility__r.Name.contains('National Grid') && uae.Bill_Type__c != 'Dual' )
            if(uae.Utility_Account__r.Utility__r.Rate_Code_Required__c && uae.Bill_Type__c != 'Dual' )
                
            {
                // enrollId.add(uae.Enrollment__c);
                uaeIds.add(uae.Id);
            }
        }  
        
        System.debug('uaeIds-->'+uaeIds);
        //Map<Id,String> getProgramCodes = new Map<Id,String>();
        
        if(!uaeIds.isEmpty())
        {
            getProgramCodes = getProgramCodes(uaeIds,uaIdEnrollRateAmt,uaeUaMap);
            System.debug('getProgramCodes1111111-->'+getProgramCodes);
        }
        System.debug('getProgramCodes-->'+getProgramCodes);
        
        String sQuery1 = 'SELECT Current_Order__c FROM sortOrderCustomSetting__c WHERE Name__c = \'Sort Order\'';
        //Boolean currentSort = socs.Current_Order__c;
        sortOrderCustomSetting__c socs = Database.query(sQuery1);
        
        // create instances of UAEListWrapper to return
        String errorMsg = '';
        
        for(Utility_Account_Enrollment__c uae : uaeRecords){
            UAEListWrapper uaew = new UAEListWrapper();
            if(uae.Enrollment__r.Account__c == null){
                errorMsg = ' Required data objects missing : Account. ';
            }else if(uae.Enrollment__r.Account__r.Primary_Contact__c == null){
                errorMsg = ' Required data objects missing : Contact. ';
            }else{
                errorMsg = '';
            }
            if(getProgramCodes.containskey(uae.Utility_Account__c)){
                uaew.MarketRateCode= String.valueOf(getProgramCodes.get(uae.Utility_Account__c));
                System.debug('uaew.MarketRateCode -->> '+uaew.MarketRateCode);
            }
            else{
                uaew.MarketRateCode='';
            }
            
            if(uae.Utility_Account__r.Utility__r.Rate_Code_Required__c && uae.Market_Rate_Code__c == null){
                System.debug('in if');
                uaew.isNationalGridandNullMarketRate = true;
            }else{
                System.debug('in else');
                uaew.isNationalGridandNullMarketRate = false;
            }
            
            uaew.errorMsg = errorMsg;
            uaew.checkCurrentSortOrder = socs.Current_Order__c;
            uaew.userOptions = usrOpts;
            uaew.objUAE = uae;
            uaesToReturn.add(uaew);
        }
        
        System.debug('uaesToReturn-->> '+uaesToReturn.size());
        System.debug('uaesToReturn-->> '+uaesToReturn);
        return uaesToReturn;
    }
    
    @auraEnabled	
    public static Map<Id,String> getProgramCodes(List<Id> UAs, Map<Id,Decimal> uaIdEnrollRateAmt, Map<Id,Id> uaeUaMap){
        System.debug('UAs-->> '+UAs);
        Map<Id,String> UAERateMap = new Map<Id,String>();
        Set<Id> utilityId = new Set<Id>();
        Map<Id,String> UAPMap = new Map<Id,String>();
        List<Utility_Account_Enrollment__c> UAEList = new List<Utility_Account_Enrollment__c>();
        List<Utility_Account_Enrollment__c> uaeList1 = [SELECT Id,
                                                        Program_Code_Key__c,
                                                        Utility_Account__c,
                                                        Utility_Account__r.Utility__c,
                                                        Utility_Account__r.Commodity__c,
                                                        Utility_Account__r.Utility__r.Rate_Code_Format__c,
                                                        Enrollment__c,
                                                        Enrollment__r.Rate_Amount__c
                                                        FROM Utility_Account_Enrollment__c 
                                                        WHERE Id IN : UAs];
        
        //Add Program Code key to List of String
        List<String> UAEProgCodeKeys = new List<String>();
        for(Utility_Account_Enrollment__c uaes : uaeList1){
            //UAERateMap.put(uaes.Utility_Account__r.Id,uaes.Utility_Account__r.Utility__r.Rate_Code_Format__c);
            //utilityId.add(uaes.Utility_Account__r.Utility__c);
            System.debug('uaes.Program_Code_Key__c-->> '+uaes.Program_Code_Key__c);
            UAEProgCodeKeys.add(uaes.Program_Code_Key__c);
        }
        System.debug('uaeList1-->>  '+ uaeList1);
        System.debug('UAEProgCodeKeys-->> '+UAEProgCodeKeys);
        
        //Get Program Codes filtered on Key on Profram Code =  Program Code key on Utility which we added in UAEProgCodeKeys list
        List<Program_Code__c> programCodes1 = [SELECT Id, Commodity__c, Program_Number__c, Pricing_Group__c,Key__c, 
                                               Effective_Date__c, Termination_Date__c, Rate__c, ISO_Zone__c,Service_Class__c 
                                               FROM Program_Code__c
                                               where Effective_Date__c < TODAY and 
                                               Key__c IN : UAEProgCodeKeys and
                                               Termination_Date__c = null];
        //Key__c IN : UAEProgCodeKeys and
        System.debug('programCodes1-->> '+programCodes1);
        
        // Add Program Code key and Create Program Code number and add to map
        Map<String,String> mapkeyPCNum = new Map<String,String>();
        for(Program_Code__c pc :  programCodes1){
            mapkeyPCNum.put(pc.Key__c,pc.Pricing_Group__c + pc.Program_Number__c);
        }
        
        // Update the UAE and add the values to UAPMap to Return
        for(Utility_Account_Enrollment__c uae : uaeList1){
            //if PC and 
            if(mapkeyPCNum.containsKey(uae.Program_Code_Key__c)){
                Utility_Account_Enrollment__c uae1 = new Utility_Account_Enrollment__c();
                uae1.Market_Rate_Code__c =mapkeyPCNum.get(uae.Program_Code_Key__c);  //pc.Pricing_Group__c + pc.Program_Number__c; 
                uae1.Id = uae.Id;//uaeUaMap.get(uae.Utility_Account__c);
                //UAList1.add(ua);
                if(!UAEList.contains(uae1))
                    UAEList.add(uae1);
                UAPMap.put(uae.Id,uae1.Market_Rate_Code__c);  
            }
        }
        if(UAEList!=null){
            update UAEList;
        }
        System.debug('UAPMap-->> '+UAPMap);
        return UAPMap;   
    }
    
    /*     Map<Id,String> UAPMap = new Map<Id,String>();
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
Integer UAcount=0; 
Integer PCcount =0;
List<Utility_Account_Enrollment__c> UAEList = new List<Utility_Account_Enrollment__c>();

for(Utility_Account__c ua: [SELECT Id, Zone__c, Commodity__c,Service_Class__c,Market_Rate_Code__c 
FROM Utility_Account__c 
WHERE Id IN : UAs and Service_Class__c != null]){ 
for(Program_Code__c pc: programCodes){        
if(pc.Rate__c == uaIdEnrollRateAmt.get(ua.Id) && ua.Commodity__c.startsWith(pc.Commodity__c)){  // and here for iso and ....             
if (!pc.Service_Class__c.contains('|')){     
if (pc.Service_Class__c.contains(ua.Service_Class__c)){
if(!UAPMap.containsKey(ua.Id)){                                    
Utility_Account_Enrollment__c uae = new Utility_Account_Enrollment__c();
uae.Market_Rate_Code__c = pc.Pricing_Group__c + pc.Program_Number__c; 
uae.Id = uaeUaMap.get(ua.Id);
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
}
}
}

if(UAEList!=null){
update UAEList;
}
return UAPMap; 
} */
    
    /*This function is used 
1. onGroupChange function in js */
    @auraEnabled
    public static List<UAEListWrapper> getGroupedUAEs(String selectedGroup, String selectedFilter){ 
        System.debug('selectedGroup--> '+ selectedGroup);
        System.debug('selectedFilter--> '+ selectedFilter);
        list<String> uaeIds = new list<String>();
        // List<String> getProgramCodes = new List<String>();
        Map<Id,String> getProgramCodes = new Map<Id,String>();
        List<UAEListWrapper> uaesToReturn = new List<UAEListWrapper>();
        List<Utility_Account_Enrollment__c> uaeRecords = new List<Utility_Account_Enrollment__c>();
        String sQuery = 'SELECT Id,Auto_Submitted_Date__c,Duplicate_Detected__c,Utility_Account__r.Utility__r.Rate_Code_Required__c,Enrollment__r.Account__c,Enrollment__r.Account__r.Primary_Contact__c,RateClass__c,AutoSubmitFlag__c,Enrollment__r.Taxable_Portion__c,Contract_Start__c,Bill_Type__c,Utility_Account__r.Service_Class__c,Utility_Account__r.Service_Address__c,Utility_Account__r.Market_Rate_Code__c,Status__c,Utility_Account__r.Status__c,Enrollment__r.Name,Enrollment__r.Account__r.Customer_ID__c,Enrollment__r.Contract__r.ContractNumber,Enrollment__r.Contract_Signed_Date__c,Enrollment__r.Bill_Type__c,Enrollment__r.Product__c,Enrollment__r.Account__r.Name,Utility_Account__r.Utility__r.Name,Utility_Account__r.Name, Enrollment__r.Contract__r.StartDate,Enrollment__r.Contract_Term__c,Enrollment__r.Rate_Amount__c, Tax_Exempt__c,Enrollment__r.Sale_Type__c,Utility_Account__r.Average_Meter_Read_Date__c,Enrollment__r.Broker_Name__c,Enrollment__r.Contract__r.Opportunity__r.Account.Owner.Name FROM Utility_Account_Enrollment__c';
        // get user groups 
        Id userId = UserInfo.getUserId();
        User usr = [SELECT My_Utility_Groups__c FROM User WHERE Id =: userId];
        String userGroups = usr.My_Utility_Groups__c;
        
        // if selectd group is myGroups then below logic else groupA,groupB,groupC or all
        if(selectedGroup == 'myGroups'){
            if(userGroups.contains('Group A') && !userGroups.contains('Group B') && !userGroups.contains('Group C')){
                sQuery += ' WHERE (Utility_Account__r.Utility__r.Group__c includes (\'Group A\')) ';
            }else if((!userGroups.contains('Group A') && userGroups.contains('Group B') && !userGroups.contains('Group C'))){
                sQuery += ' WHERE (Utility_Account__r.Utility__r.Group__c includes (\'Group B\')) ';
            }else if((!userGroups.contains('Group A') && !userGroups.contains('Group B') && userGroups.contains('Group C'))){
                sQuery += ' WHERE (Utility_Account__r.Utility__r.Group__c includes (\'Group C\')) ';
            }else if((userGroups.contains('Group A') && userGroups.contains('Group B') && !userGroups.contains('Group C'))){
                sQuery += ' WHERE (Utility_Account__r.Utility__r.Group__c includes (\'Group A\',\'Group B\')) ';
            }else if((userGroups.contains('Group A') && !userGroups.contains('Group B') && userGroups.contains('Group C'))){
                sQuery += ' WHERE (Utility_Account__r.Utility__r.Group__c includes (\'Group A\',\'Group C\')) ';
            }else if((!userGroups.contains('Group A') && userGroups.contains('Group B') && userGroups.contains('Group C'))){
                sQuery += ' WHERE (Utility_Account__r.Utility__r.Group__c includes (\'Group B\',\'Group C\')) ';
            }else if((userGroups.contains('Group A') && userGroups.contains('Group B') && userGroups.contains('Group C'))){
                sQuery += ' WHERE (Utility_Account__r.Utility__r.Group__c includes (\'Group A\',\'Group B\',\'Group C\')) ';
            }
            
        }else if(selectedGroup == 'groupA'){
            sQuery += ' WHERE (Utility_Account__r.Utility__r.Group__c includes (\'Group A\')) ';
        }else if(selectedGroup == 'groupB'){
            sQuery += ' WHERE (Utility_Account__r.Utility__r.Group__c includes (\'Group B\')) ';
        }else if(selectedGroup == 'groupC'){
            sQuery += ' WHERE (Utility_Account__r.Utility__r.Group__c includes (\'Group C\')) ';
        }
        // Below is for filter and group combination working
        if(selectedFilter == 'defaultUAEs'){
            if(sQuery.contains('WHERE')){
                sQuery += ' AND (Status__c = \'Enrollment Request Pending\' OR Status__c = \'Enrollment Request Failed\')';
            }else{
                sQuery += ' WHERE (Status__c = \'Enrollment Request Pending\' OR Status__c = \'Enrollment Request Failed\')';    
            }
        }
        else if(selectedFilter == 'acceptedUAEs'){
            if(sQuery.contains('WHERE')){
                sQuery += ' AND (Status__c = \'Enrollment Request Accepted\')';
            }else{
                sQuery += ' WHERE (Status__c = \'Enrollment Request Accepted\')';
            }
            
        }
        else if(selectedFilter == 'pendingUAEs'){
            if(sQuery.contains('WHERE')){
                sQuery += ' AND (Status__c = \'Enrollment Request Pending\')'; 
            }else{
                sQuery += ' WHERE (Status__c = \'Enrollment Request Pending\')';
            }
        }
        else if(selectedFilter == 'failedUAEs'){
            if(sQuery.contains('WHERE')){
                sQuery += ' AND (Status__c = \'Enrollment Request Failed\')';
            }else{
                sQuery += ' WHERE (Status__c = \'Enrollment Request Failed\')';
            }
        }
        else if(selectedFilter == 'submittedUAEs'){
            if(sQuery.contains('WHERE')){
                sQuery += ' AND (Status__c = \'Enrollment Request Submitted\')';
            }else{
                sQuery += ' WHERE (Status__c = \'Enrollment Request Submitted\')';
            }
        }
        if(selectedFilter == 'defaultUAEs'){
            if(sQuery.contains('WHERE')){
                sQuery += ' AND (Ready_for_Enrollment__c = true)';
            }else{
                sQuery += ' WHERE (Ready_for_Enrollment__c = true)';  
            }
            System.debug('sQuery-->> '+sQuery);
        }
        System.debug('sQuery1111-->> '+sQuery);
        
        //Final query after all above operation will be queried below
        uaeRecords = Database.query(sQuery + ' limit 200');
        
        Map<Id,Decimal> uaIdEnrollRateAmt = new Map<Id,Decimal>();
        Map<Id,Id> uaeUaMap = new Map<Id,Id>();
        
        for(Utility_Account_Enrollment__c uae: uaeRecords){
            uaIdEnrollRateAmt.put(uae.Utility_Account__c,uae.Enrollment__r.Rate_Amount__c);
            uaeUaMap.put(uae.Utility_Account__c,uae.Id);
            //if(uae.Utility_Account__r.Utility__r.Name.contains('National Grid') && uae.Bill_Type__c != 'Dual' )
            if(uae.Utility_Account__r.Utility__r.Rate_Code_Required__c && uae.Bill_Type__c != 'Dual' )
            {
                uaeIds.add(uae.Id);
            }
        }  
        
        System.debug('uaeIds-->'+uaeIds);
        
        if(!uaeIds.isEmpty())
        {            
            getProgramCodes = getProgramCodes(uaeIds,uaIdEnrollRateAmt,uaeUaMap);
            System.debug('getProgramCodes1111111-->'+getProgramCodes);
        }
        System.debug('getProgramCodes-->'+getProgramCodes);
        
        // create instances of UAEListWrapper to return
        String errorMsg = '';
        for(Utility_Account_Enrollment__c uae : uaeRecords){
            UAEListWrapper uaew = new UAEListWrapper();
            if(uae.Enrollment__r.Account__c == null){
                errorMsg = ' Required data objects missing : Account. ';
            }else if(uae.Enrollment__r.Account__r.Primary_Contact__c == null){
                errorMsg = ' Required data objects missing : Contact. ';
            }else{
                errorMsg = '';
            }
            if(getProgramCodes.containskey(uae.Utility_Account__c)){
                uaew.MarketRateCode= String.valueOf(getProgramCodes.get(uae.Utility_Account__c));
                System.debug('uaew.MarketRateCode -->> '+uaew.MarketRateCode);
            }
            else{
                uaew.MarketRateCode='';
            }
            if(uae.Utility_Account__r.Utility__r.Rate_Code_Required__c && uae.Market_Rate_Code__c == null){
                System.debug('in if');
                uaew.isNationalGridandNullMarketRate = true;
            }else{
                System.debug('in else');
                uaew.isNationalGridandNullMarketRate = false;
            }
            
            uaew.errorMsg = errorMsg;
            uaew.objUAE = uae;
            uaesToReturn.add(uaew);
        } 
        return uaesToReturn;
    }
    
    @auraEnabled
    public static List<UAEListWrapper> getStartDateUAEs(String selectedGroup, String selectedFilter, string fromDate1, string toDate1,list<string>selecteValues, string columnNameAndDataType, string dateColumnName, list<string> allFilters){ 
        string columnName ='';
        string dataTypeOfColumn ='';
        if(columnNameAndDataType != null)
        {
            list<string> splitData =columnNameAndDataType.split(',');
            if(splitData.size()>1){
                columnName = splitData.get(0);
                dataTypeOfColumn = splitData.get(1);
            }
            else{
                columnName = columnNameAndDataType;
            }
        }
		
        // Date fromDate = Date.valueOf(fromDate1);
        //    Date toDate = Date.valueOf(toDate1);
        System.debug('selectedGroup--> '+ selectedGroup);
        System.debug('selectedFilter--> '+ selectedFilter);
        list<String> uaeIds = new list<String>();
        // List<String> getProgramCodes = new List<String>();
        Map<Id,String> getProgramCodes = new Map<Id,String>();
        List<UAEListWrapper> uaesToReturn = new List<UAEListWrapper>();
        List<Utility_Account_Enrollment__c> uaeRecords = new List<Utility_Account_Enrollment__c>();
        String sQuery = 'SELECT Id,Auto_Submitted_Date__c,Duplicate_Detected__c,Utility_Account__r.Utility__r.Rate_Code_Required__c,Enrollment__r.Account__c,Enrollment__r.Account__r.Primary_Contact__c,RateClass__c,AutoSubmitFlag__c,Enrollment__r.Taxable_Portion__c,Contract_Start__c,Bill_Type__c,Utility_Account__r.Service_Class__c,Utility_Account__r.Service_Address__c,Utility_Account__r.Market_Rate_Code__c,Status__c,Utility_Account__r.Status__c,Enrollment__r.Name,Enrollment__r.Account__r.Customer_ID__c,Enrollment__r.Contract__r.ContractNumber,Enrollment__r.Contract_Signed_Date__c,Enrollment__r.Bill_Type__c,Enrollment__r.Product__c,Enrollment__r.Account__r.Name,Utility_Account__r.Utility__r.Name,Utility_Account__r.Name, Enrollment__r.Contract__r.StartDate,Enrollment__r.Contract_Term__c,Enrollment__r.Rate_Amount__c, Tax_Exempt__c,Enrollment__r.Sale_Type__c,Utility_Account__r.Average_Meter_Read_Date__c,Enrollment__r.Broker_Name__c,Enrollment__r.Contract__r.Opportunity__r.Account.Owner.Name,Market_Rate_Code__c FROM Utility_Account_Enrollment__c';
        // get user groups
        Id userId = UserInfo.getUserId();
        User usr = [SELECT My_Utility_Groups__c FROM User WHERE Id =: userId];
        String userGroups = usr.My_Utility_Groups__c;
        
        // if selectd group is myGroups then below logic else groupA,groupB,groupC or all
        if(selectedGroup == 'myGroups'){
            if(userGroups.contains('Group A') && !userGroups.contains('Group B') && !userGroups.contains('Group C')){
                sQuery += ' WHERE (Utility_Account__r.Utility__r.Group__c includes (\'Group A\')) ';
            }else if((!userGroups.contains('Group A') && userGroups.contains('Group B') && !userGroups.contains('Group C'))){
                sQuery += ' WHERE (Utility_Account__r.Utility__r.Group__c includes (\'Group B\')) ';
            }else if((!userGroups.contains('Group A') && !userGroups.contains('Group B') && userGroups.contains('Group C'))){
                sQuery += ' WHERE (Utility_Account__r.Utility__r.Group__c includes (\'Group C\')) ';
            }else if((userGroups.contains('Group A') && userGroups.contains('Group B') && !userGroups.contains('Group C'))){
                sQuery += ' WHERE (Utility_Account__r.Utility__r.Group__c includes (\'Group A\',\'Group B\')) ';
            }else if((userGroups.contains('Group A') && !userGroups.contains('Group B') && userGroups.contains('Group C'))){
                sQuery += ' WHERE (Utility_Account__r.Utility__r.Group__c includes (\'Group A\',\'Group C\')) ';
            }else if((!userGroups.contains('Group A') && userGroups.contains('Group B') && userGroups.contains('Group C'))){
                sQuery += ' WHERE (Utility_Account__r.Utility__r.Group__c includes (\'Group B\',\'Group C\')) ';
            }else if((userGroups.contains('Group A') && userGroups.contains('Group B') && userGroups.contains('Group C'))){
                sQuery += ' WHERE (Utility_Account__r.Utility__r.Group__c includes (\'Group A\',\'Group B\',\'Group C\')) ';
            }
            
        }else if(selectedGroup == 'groupA'){
            sQuery += ' WHERE (Utility_Account__r.Utility__r.Group__c includes (\'Group A\')) ';
        }else if(selectedGroup == 'groupB'){
            sQuery += ' WHERE (Utility_Account__r.Utility__r.Group__c includes (\'Group B\')) ';
        }else if(selectedGroup == 'groupC'){
            sQuery += ' WHERE (Utility_Account__r.Utility__r.Group__c includes (\'Group C\')) ';
        }
        // Below is for filter and group combination working
        if(selectedFilter == 'defaultUAEs'){
            if(sQuery.contains('WHERE')){
                sQuery += ' AND (Status__c = \'Enrollment Request Pending\' OR Status__c = \'Enrollment Request Failed\')';
            }else{
                sQuery += ' WHERE (Status__c = \'Enrollment Request Pending\' OR Status__c = \'Enrollment Request Failed\')';    
            }
        }
        else if(selectedFilter == 'acceptedUAEs'){
            if(sQuery.contains('WHERE')){
                sQuery += ' AND (Status__c = \'Enrollment Request Accepted\')';
            }else{
                sQuery += ' WHERE (Status__c = \'Enrollment Request Accepted\')';
            }
            
        }
        else if(selectedFilter == 'pendingUAEs'){
            if(sQuery.contains('WHERE')){
                sQuery += ' AND (Status__c = \'Enrollment Request Pending\')'; 
            }else{
                sQuery += ' WHERE (Status__c = \'Enrollment Request Pending\')';
            }
        }
        else if(selectedFilter == 'failedUAEs'){
            if(sQuery.contains('WHERE')){
                sQuery += ' AND (Status__c = \'Enrollment Request Failed\')';
            }else{
                sQuery += ' WHERE (Status__c = \'Enrollment Request Failed\')';
            }
        }
        else if(selectedFilter == 'submittedUAEs'){
            if(sQuery.contains('WHERE')){
                sQuery += ' AND (Status__c = \'Enrollment Request Submitted\')';
            }else{
                sQuery += ' WHERE (Status__c = \'Enrollment Request Submitted\')';
            }
        }
        if(selectedFilter == 'defaultUAEs'){
            if(sQuery.contains('WHERE')){
                sQuery += ' AND (Ready_for_Enrollment__c = true)';
            }else{
                sQuery += ' WHERE (Ready_for_Enrollment__c = true)';  
            }
            System.debug('sQuery-->> '+sQuery);
        }
        System.debug('sQuery1111-->> '+sQuery);
        
        //Below is for startDateFilter
        
        if(fromDate1 != null && toDate1 != null && !string.isBlank(fromDate1) && !string.isBlank(toDate1)){
            date fromDate = date.valueOf(fromDate1);
            date toDate=   date.valueOf(toDate1);
            
            string dateOne =string.valueOf(Date.newInstance(fromDate.year(), fromDate.month(), fromDate.day())) ; 
            string dateTwo =string.valueOf(Date.newInstance(toDate.year(), toDate.month(), toDate.day())) ;
            system.debug('dates =>'+dateOne+ dateTwo);
            if(sQuery.contains('WHERE')){
                sQuery += ' AND '+dateColumnName+' >= '+dateOne+' AND '+dateColumnName+' <= '+dateTwo;
            }else{
                sQuery += ' WHERE'+dateColumnName+' >= '+dateOne+' AND '+dateColumnName+' <= '+dateTwo;
            }
        }else if(String.isNotBlank(fromDate1) && (toDate1 == null || string.isBlank(toDate1)) ){
            date fromDate = date.valueOf(fromDate1);
            string dateOne =string.valueOf(Date.newInstance(fromDate.year(), fromDate.month(), fromDate.day())) ; 
            if(sQuery.contains('WHERE')){
                
                sQuery += ' AND '+dateColumnName+' >= '+dateOne;
            }else{
                sQuery += ' WHERE '+dateColumnName+' >= '+dateOne;
            }
        }else if((fromDate1 == null || string.isBlank(fromDate1)) && String.isNotBlank(toDate1) ){
            date toDate=date.valueOf(toDate1);
            string dateTwo =string.valueOf(Date.newInstance(toDate.year(), toDate.month(), toDate.day())) ; 
            if(sQuery.contains('WHERE')){
                sQuery += ' AND '+dateColumnName+' <= '+dateTwo;
            }else{
                sQuery += ' WHERE '+dateColumnName+' <= '+dateTwo;
            }
        }
        
        //excel Like Filter
        
           
            if(!allFilters.isEmpty()){
                for(string element : allFilters){
                    if(element != null || string.isNotBlank(element) ){
                        if(!element.contains('in ()')){
                            if(sQuery.contains('WHERE')){   
                                sQuery += ' AND '+element;
                                
                            }else{
                                sQuery += ' WHERE '+element;
                            }
                        }
                    }
                }
            }
        
        system.debug('selecteValues=>'+selecteValues);
        system.debug('columnName=>'+columnName);
        String sQueryTemp = '';
        system.debug('selecteValues=>'+selecteValues);
        list<string> whereList = new list<string>();
        String allWhereList = '(';
        if(!selecteValues.isEmpty() && (columnName != null || string.isNotBlank(columnName)) && string.isNotBlank(dataTypeOfColumn)){
            if(dataTypeOfColumn =='string'){
                for(string str : selecteValues){
                    string temp ='\''+str+'\'';
                    whereList.add(temp);
                    allWhereList += temp+','; 
                }
                allWhereList = allWhereList.removeEnd(',');
                allWhereList += ')';
                system.debug('whereList size=>'+whereList.size());            
                if(sQuery.contains('WHERE')){
                    string sQuery1 = ' AND '+columnName+' IN ' +allWhereList;
                    system.debug('allWhereList=>'+allWhereList);
                    system.debug('sQuery1=>'+ sQuery1);
                    //sQuery += sQuery1;
                    sQueryTemp= sQuery1;
                }else{
                    string sQuery1 = ' WHERE '+columnName+' IN  ' +allWhereList;
                    //sQuery += sQuery1;
                    sQueryTemp= sQuery1;
                }
            }
            else if(dataTypeOfColumn =='boolean'){
                if(selecteValues.size() == 1){
                    if(sQuery.contains('WHERE')){
                        sQuery += ' AND '+columnName+' = '+boolean.valueOf(selecteValues.get(0));
                    }else{
                        sQuery += ' WHERE '+columnName+' = '+boolean.valueOf(selecteValues.get(0));
                    }
                }
            }
            else if(dataTypeOfColumn =='integer'){
                
                if(sQuery.contains('WHERE')){
                        sQuery += ' AND '+columnName+' IN '+selecteValues;
                    }else{
                        sQuery += ' WHERE '+columnName+' IN '+selecteValues;
                    }
            }
        }
       
        sQueryTemp = sQueryTemp.replace(', ...', '');
        system.debug('sQueryTemp replaced=>'+ sQueryTemp);
        
        //Final query after all above operation will be queried below
        String str = sQuery+sQueryTemp;
        system.debug('query='+ str);
        uaeRecords = Database.query(sQuery+sQueryTemp + ' limit 200');
        
        Map<Id,Decimal> uaIdEnrollRateAmt = new Map<Id,Decimal>();
        Map<Id,Id> uaeUaMap = new Map<Id,Id>();
        
        for(Utility_Account_Enrollment__c uae: uaeRecords){
            uaIdEnrollRateAmt.put(uae.Utility_Account__c,uae.Enrollment__r.Rate_Amount__c);
            uaeUaMap.put(uae.Utility_Account__c,uae.Id);
            //if(uae.Utility_Account__r.Utility__r.Name.contains('National Grid') && uae.Bill_Type__c != 'Dual' )
            if(uae.Utility_Account__r.Utility__r.Rate_Code_Required__c && uae.Bill_Type__c != 'Dual' )
            {
                uaeIds.add(uae.Id);
            }
        }  
        
        System.debug('uaeIds-->'+uaeIds);
        
        if(!uaeIds.isEmpty())
        {            
            getProgramCodes = getProgramCodes(uaeIds,uaIdEnrollRateAmt,uaeUaMap);
            System.debug('getProgramCodes1111111-->'+getProgramCodes);
        }
        System.debug('getProgramCodes-->'+getProgramCodes);
        
        // create instances of UAEListWrapper to return
        String errorMsg = '';
        for(Utility_Account_Enrollment__c uae : uaeRecords){
            UAEListWrapper uaew = new UAEListWrapper();
            if(uae.Enrollment__r.Account__c == null){
                errorMsg = ' Required data objects missing : Account. ';
            }else if(uae.Enrollment__r.Account__r.Primary_Contact__c == null){
                errorMsg = ' Required data objects missing : Contact. ';
            }else{
                errorMsg = '';
            }
            if(getProgramCodes.containskey(uae.Utility_Account__c)){
                uaew.MarketRateCode= String.valueOf(getProgramCodes.get(uae.Utility_Account__c));
                System.debug('uaew.MarketRateCode -->> '+uaew.MarketRateCode);
            }
            else{
                uaew.MarketRateCode='';
            }
            if(uae.Utility_Account__r.Utility__r.Rate_Code_Required__c && uae.Market_Rate_Code__c == null){
                System.debug('in if');
                uaew.isNationalGridandNullMarketRate = true;
            }else{
                
                uaew.isNationalGridandNullMarketRate = false;
            }
            
            uaew.errorMsg = errorMsg;
            uaew.objUAE = uae;
            uaesToReturn.add(uaew);
        } 
        return uaesToReturn;
    }
    /*This function is used 
1. handleSaveOptionChange function in js */
    @auraEnabled
    public static void SaveSelectedOptions(List<String> options){
        //Get the selected values in column selector and update the user with those values
        System.debug('options--->>>>> '+options.size());
        string stringOptions = string.join(options,',');
        System.debug('stringOptions==>> '+stringOptions);
        Id userId = UserInfo.getUserId();
        User usr = [SELECT Selected_Options_1__c FROM User WHERE Id =: userId];
        // usr.Selected_Options__c = stringOptions;
        usr.Selected_Options_1__c =stringOptions;
        update usr;
        System.debug('usr-->> '+usr);
        System.debug('options--->>> '+options);
    }   
    
    @auraEnabled
    public static EnrollmentWrapper submitEnrollment(Id recordId, List<Utility_Account_Enrollment__c> objUAEs, Boolean currentSortOrder){
        List<Id> UAENotActiveIdList = new List<Id>();
        List<Id> UAEActiveIdList = new List<Id>();
        system.debug('objUAEs-->'+objUAEs);
        System.debug('currentSortOrder-->> '+currentSortOrder);
        List<Utility_Account_Enrollment__c> objUAEActive = [SELECT Id,
                                                            Utility_Account__r.Name,
                                                            Utility_Account__r.Account__r.Name,
                                                            Utility_Account__r.Market_Rate_Code__c,
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
                                                               Utility_Account__r.Market_Rate_Code__c,
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
        
        System.debug('objUAEs==>>'+objUAEs[0].Utility_Account__r.Market_Rate_Code__c);
        List<Utility_Account_Enrollment__c> uaeToUpdate = new List<Utility_Account_Enrollment__c>();
        for(Utility_Account_Enrollment__c uae : objUAEActive){
            UAEActiveIdList.add(uae.Id);
            uae.Enrollment_Submitted_By__c = UserInfo.getUserId();
            uae.Enrollment_Submitted__c = DateTime.now();
            uae.Status__c = 'Enrollment Request Submitted';
            uaeToUpdate.add(uae);
        }
        
        System.debug('objUAENotActive-->> '+objUAENotActive);
        for(Utility_Account_Enrollment__c uae : objUAENotActive){
            UAENotActiveIdList.add(uae.Id);
            uae.Enrollment_Submitted_By__c = UserInfo.getUserId();
            uae.Enrollment_Submitted__c = DateTime.now();
            uae.Status__c = 'Enrollment Request Submitted';
            uaeToUpdate.add(uae);
        }
        if(uaeToUpdate != null){
            update uaeToUpdate;
            System.debug('--------------------in it-------------');
        }
        
        sortOrderCustomSetting__c socs = [SELECT Current_Order__c FROM sortOrderCustomSetting__c WHERE Name__c = 'Sort Order'];
        socs.Current_Order__c = !currentSortOrder;
        update socs;
        
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
            //System.debug('ex-->> '+ex.getMessage());
            ew.code = '500';
            ew.RenewCode = '500';
            ew.UAENotActive = objUAENotActive;
            ew.UAE = objUAEActive;
        }
        
        return ew;
        
    }
    
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
}