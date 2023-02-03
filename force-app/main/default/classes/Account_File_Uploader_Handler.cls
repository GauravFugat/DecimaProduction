/***************************************************************************************************************************
* Name:        file_upload_handler 
* Description: Helper class for Account_File_Uploader Component 
* Related Code:UA_UploadQueue
*
* Version History
* Date             Developer               Comments
* ---------------  --------------------    --------------------------------------------------------------------------------
* 2019-11-07        Aress Dev             	Import CSV file data in Utility_Account__c and Price_Upload_Log__c .
* 2020-13-02  		Aress Dev				De-Duplication and Refactorting
* 2020-20-10  		Saurabh Chauhan			Allow inserting of start dates and upserting of Utility Accounts,
if present on same Account.
****************************************************************************************************************************/
public class Account_File_Uploader_Handler {
    
    public class systemDuplicate {
        public String UtilityAccountNumber {get;set;}
        public String UtilityName {get;set;}
        public String AccountName {get;set;}
    }
    public class Wrapper_CSVFileRecord {
        public String UtilityAccountNumber {get;set;}
        public String Utility {get;set;}
        public String StartDate {get;set;}
        public String Street {get;set;}
        public String Street2 {get;set;}
        public String City {get;set;}
        public String State {get;set;}
        public String Zip {get;set;}
        public String Country {get;set;}
    }
    // To insert csv file data into object fields.
    @AuraEnabled
    public static string insertData(Blob strfromlex,Id recordId, String FileName){
        String returnresponse ='';
        //create log of failure
        Upload_Log__c pul = new Upload_Log__c();
        //incoming file 
        String fileData =strfromlex.toString();
        //error 
        List<String> errList1 = new List<String>();
        //duplicates in CSV File error 
        List<String> duplicateserrList= new List<String>();
        //duplicates in system
        List<systemDuplicate> systemDuplicateList = new   List<systemDuplicate>();
        // To split rows of csv files
        List<String> csvFileLines = new List<String>(fileData.split('[\\r\\n]+'));
        // To check the column size of csv
        String  columnSize ='';
        // To check the file record inserted or not
        Boolean  recordInserted =false;
        //To compare the records
        List< List<String> > cmpString = new List< List<String> >();
        //used  for filter data store
        List<List<String>> CSVinputvalues = new List<List<String>>();
        //to store data into wrapper
        List<Wrapper_CSVFileRecord> wrapperCSVrecordList = new   List<Wrapper_CSVFileRecord>();
        List<Utility_Account__c> utilityAccountsList = new List<Utility_Account__c>();
        List<Utility_Account__c> utilityAccountsList1 = new List<Utility_Account__c>();
        
        try{
            for(Integer i=1; i<csvFileLines.size(); i++ ){
                List<String> inputvalues1 = Base_Class_Uploader.columns_Splitter(csvFileLines[i]);
                if(CSVinputvalues.isEmpty())
                {
                    CSVinputvalues.add(inputvalues1);
                    cmpString.add(inputvalues1);
                }
                else if(!CSVinputvalues.isEmpty() && cmpString.contains(inputvalues1))
                {
                    duplicateserrList.add('Removed Row : '+i +', Duplicate detected having Utility Account- '+ inputvalues1[0]+' is already in the file on Account- '+ inputvalues1[1]);
                    
                }
                else if(!cmpString.contains(inputvalues1))
                {
                    CSVinputvalues.add(inputvalues1);
                    cmpString.add(inputvalues1);
                }
            }
            
            if( CSVinputvalues.size() >0)
            {
                for(List<String> filterInputList : CSVinputvalues )
                {
                    if(filterInputList.size() <= 9)
                    {
                        columnSize= 'Correct File';
                    }
                    else
                    {
                        columnSize= 'Incorrect Coluumns';
                    }
                    Wrapper_CSVFileRecord CSVrecord = new Wrapper_CSVFileRecord();
                    CSVrecord.UtilityAccountNumber =filterInputList[0];
                    CSVrecord.Utility  =filterInputList[1];
                    if(filterInputList.size()>2){
                        CSVrecord.StartDate  =filterInputList[2];
                    }else{
                        CSVrecord.StartDate = '';
                    }
                    if(filterInputList.size()>3){
                        CSVrecord.Street =filterInputList[3];
                    }else{
                        CSVrecord.Street = '';
                    }
                    if(filterInputList.size()>4){
                        CSVrecord.Street2  =filterInputList[4];
                    }else{
                        CSVrecord.Street2 = '';
                    }
                    if(filterInputList.size()>5){
                        CSVrecord.City =filterInputList[5];
                    }else{
                        CSVrecord.City = '';
                    }
                    if(filterInputList.size()>6){
                        CSVrecord.State =filterInputList[6];
                    }else{
                        CSVrecord.State = '';
                    }
                    if(filterInputList.size()>7){
                        CSVrecord.Zip  =filterInputList[7];
                    }else{
                        CSVrecord.Zip = '';
                    }
                    if(filterInputList.size()>8){
                        CSVrecord.Country  =filterInputList[8];
                    }else{
                        CSVrecord.Country = '';
                    }
                    
                    wrapperCSVrecordList.add(CSVrecord);
                }
            }
            
            List<String> UAList12 = new  List<String> ();
            List<String> utilityList = new  List<String> ();
            List<String> UAStartDateList = new  List<String> ();
            List<String> UAStreetList = new  List<String> ();
            List<String> UAStreet2List = new  List<String> ();
            List<String> UACityList = new  List<String> ();
            List<String> UAStateList = new  List<String> ();
            List<String> UAZipList = new  List<String> ();
            List<String> UACountryList = new  List<String> ();
            
            //Store details in related list
            for(Wrapper_CSVFileRecord rec : wrapperCSVrecordList){
                UAList12.add(rec.UtilityAccountNumber);
                utilityList.add(rec.Utility);
                UAStartDateList.add(rec.StartDate);
                UAStreetList.add(rec.Street);
                UAStreet2List.add(rec.Street2);
                UACityList.add(rec.City);
                UAStateList.add(rec.State);
                UAZipList.add(rec.Zip);
                UACountryList.add(rec.Country);
            }
            
            //State Validation
            for(String state :UAStateList ){
                state=state.trim();
                System.debug('state=>> '+state.length());
                if(state.length() > 2)
                {
                    errList1.add('Please enter state in 2-letter format ex.(NY)');
                }
            }
            List<Account> utilities = new    List<Account>();
            if(!utilityList.IsEmpty()){
                utilities =[SELECT Id, Utility_Account_Number_Length__c, Utility_Account_Number_Prefix__c, Name  FROM Account WHERE Name IN:utilityList AND RecordType.Name = 'Utility'];
            }
            
            if(columnSize== 'Correct File'){
                if(!utilities.isEmpty()){
                    for(Integer i=0; i<wrapperCSVrecordList.size(); i++){
                        for(account a: utilities ){
                            if(utilityList[i] == a.Name){
                                if(a.Utility_Account_Number_Prefix__c != NULL){
                                    if(UAList12[i].length() > a.Utility_Account_Number_Length__c || UAList12[i].startsWith(a.Utility_Account_Number_Prefix__c) == false || UAList12[i].length() < a.Utility_Account_Number_Length__c) // for Account Number
                                    {
                                        errList1.add(' Validation has failed for account number '+ UAList12[i] +' for Utility: ' +a.Name + ' , format should be: ' + a.Utility_Account_Number_Prefix__c+' as Prefix with length' +a.Utility_Account_Number_Length__c +'.' );
                                    }
                                    else if(utilityList[i].length() > 80 || utilityList[i].length() < 1 )
                                    {
                                        errList1.add(' Row No. '+ i + '. Please enter valid Utility value.');
                                    }
                                }
                                else{
                                    if(UAList12[i].length() > a.Utility_Account_Number_Length__c || UAList12[i].length() < a.Utility_Account_Number_Length__c) // for Account Number
                                    {
                                        errList1.add(' Validation has failed for account number '+ UAList12[i] +' for Utility ' +a.Name + ' , format should be account number with length  '  +a.Utility_Account_Number_Length__c+ '.'  );
                                        
                                    }
                                    else if( utilityList[i].length() > 80 ||  utilityList[i].length() < 1 )
                                    {
                                        errList1.add(' Row No. '+ i + '. Please enter valid Utility value.');
                                    }
                                }
                            }//if
                        }//for account
                    }//for wrap
                }
            }
            else {
                errList1.add('You are uploading wrong csv file.');
            }
            
            list<Utility_Account__c> UAExistOnSameAcc = [SELECT Id, Name, Utility__r.name FROM Utility_Account__c WHERE Account__c =: recordId AND  Name IN: UAList12 ];
            List<Wrapper_CSVFileRecord> wrapperCSVrecordList1 = new List<Wrapper_CSVFileRecord>();
            Map<String,Wrapper_CSVFileRecord> uaNumwrapCsvMap = new Map<String,Wrapper_CSVFileRecord>();
            Map<String,Utility_Account__c> uaNumUAMap = new Map<String,Utility_Account__c>();
            for(Utility_Account__c ua : UAExistOnSameAcc){
                for(Wrapper_CSVFileRecord rec : wrapperCSVrecordList){
                    if(ua.Name == rec.UtilityAccountNumber && ua.Utility__r.Name == rec.Utility){
                        wrapperCSVrecordList1.add(rec);
                        uaNumwrapCsvMap.put(rec.UtilityAccountNumber,rec);
                        uaNumUAMap.put(ua.Name,ua);
                    }
                }
            }
            list<Utility_Account__c> doesUAExist = [SELECT Id, Name, Account__c,Account__r.name,Utility__r.name FROM Utility_Account__c WHERE Name IN: UAList12 AND Name Not IN:uaNumwrapCsvMap.keyset()];
            if(!doesUAExist.isEmpty())
            {
                for(Utility_Account__c UAAccToCheck : doesUAExist){
                    systemDuplicate duplicate = new systemDuplicate();
                    duplicate.UtilityAccountNumber =UAAccToCheck.Name;                   
                    duplicate.UtilityName =UAAccToCheck.Utility__r.name;
                    duplicate.AccountName =UAAccToCheck.Account__r.name;
                    systemDuplicateList.add(duplicate);
                    
                }
            }
            
            if(errList1.isEmpty()){
                for(Wrapper_CSVFileRecord rec : wrapperCSVrecordList)
                { 
                    if(!systemDuplicateList.isEmpty()){
                        for (systemDuplicate duplicate :  systemDuplicateList)
                        {
                            if(duplicate.UtilityAccountNumber == rec.UtilityAccountNumber && duplicate.UtilityName == rec.Utility)
                            {
                                errList1.add('The file was not loaded because Utility Account- '+rec.UtilityAccountNumber+' is already in the system on Account - '+ duplicate.AccountName );
                                returnresponse = 'A Utility Account is already in the system. Please check the Upload Logs for more details.';
                            }
                        }
                    }
                    // else
                    {
                        Utility_Account__c uaObj = new Utility_Account__c();
                        uaObj.Account__c = recordId;
                        uaObj.Name = rec.UtilityAccountNumber;
                        uaObj.Street__c =rec.Street;
                        uaObj.Street_2__c = rec.Street2;
                        uaObj.City__c = rec.City;
                        uaObj.State__c = rec.State;
                        uaObj.Zip__c = rec.Zip;
                        uaObj.Country__c = rec.Country;
                        if(rec.StartDate !=''){
                            uaObj.Requested_Start_Date__c = Date.valueOf(rec.StartDate);
                        }
                        for(account a: utilities ){
                            if(rec.Utility == a.Name)
                                uaObj.Utility__c = a.id;
                        }
                        if(uaNumwrapCsvMap.get(rec.UtilityAccountNumber) != rec)
                            utilityAccountsList.add(uaObj);
                    }
                    
                }
                if(UAExistOnSameAcc != null){
                    for(Utility_Account__c ua : uaNumUAMap.values()){
                        ua.Street__c = uaNumwrapCsvMap.get(ua.Name).Street;
                        ua.Street_2__c = uaNumwrapCsvMap.get(ua.Name).Street2;
                        ua.City__c = uaNumwrapCsvMap.get(ua.Name).City;
                        ua.State__c = uaNumwrapCsvMap.get(ua.Name).State;
                        ua.Zip__c = uaNumwrapCsvMap.get(ua.Name).Zip;
                        ua.Country__c = uaNumwrapCsvMap.get(ua.Name).Country;
                        if(uaNumwrapCsvMap.get(ua.Name).StartDate!=''){
                            ua.Requested_Start_Date__c = Date.valueOf(uaNumwrapCsvMap.get(ua.Name).StartDate);
                        }
                        utilityAccountsList1.add(ua);
                    }
                }
                //changed 24/12
                if(utilityAccountsList.size() >0 &&  errList1.isEmpty()){
                    insert utilityAccountsList;
                    recordInserted =true;
                }
                if(utilityAccountsList1.size() >0 &&  errList1.isEmpty()){
                    update utilityAccountsList1;
                    recordInserted =true;
                }
                System.debug('utilityList 156--->'+utilityList+'-->SIZE-->'+utilityList.size());
                System.debug('errList1 156--->'+errList1+'-->SIZE-->'+errList1.size());
                System.debug('errList1->'+errList1);
            }
            else
            {
                System.debug('Error Detected');
                System.debug('errList1 156--->'+errList1+'-->SIZE-->'+errList1.size());
                System.debug('errList1->'+errList1);
            }
        }
        catch(exception e){
            System.debug('errList1 156--->'+errList1+'-->SIZE-->'+errList1.size());
            System.debug('Broker Reports Sender Batch Exception: ' + e.getCause() + '--' + e.getLineNumber() + '--' + e.getMessage());
            if(errList1.isEmpty()){
                System.debug('e.getMessage()--->'+e.getMessage()+e.getLineNumber());
                errList1.add(e.getMessage());
            }
            else{
                System.debug('errList1 163--->'+errList1+'-->SIZE-->'+errList1.size());
            }
            System.debug('errList1--->'+errList1+'-->SIZE-->'+errList1.size());
        }
        
        if(!duplicateserrList.isempty() && recordInserted == true){
            errList1.addAll(duplicateserrList);
        }
        
        UA_UploadQueue intog = new UA_UploadQueue(recordId,errList1,strfromlex,FileName);
        System.enqueueJob(intog);
        if(duplicateserrList.isEmpty()  && errList1.size()>0){
            returnresponse = 'Upload Failed, Please check the upload logs for more details.';
        }
        return returnresponse;
    }
    
}