/* Test class : BulkContractRateUpdater_Controller_Test
*/
public class BulkContractRateUpdater_Controller {
    
    public class Wrapper_CSVFileRecord {
        public String contractNumber      {get;set;}
        public String Rate_Change         {get;set;}
        public String Rate_Change_Reason  {get;set;}
        public String Rate_Effective_Date {get;set;}
        
    }
    
    @AuraEnabled
    public static string createRateData(String docId){
        Batch_Log__c bl = new Batch_Log__c();
        List<Contract_Rate__c> contractRateToInsert = new List<Contract_Rate__c>();
        String returnresponse ='';
        List<List<String>> CSVinputvalues = new List<List<String>>();
        List<Wrapper_CSVFileRecord> wrapperCSVrecordList = new   List<Wrapper_CSVFileRecord>();
        Set<String> contractNumber = new Set<String>(); 
        Map<String,Id> contractNumberIdMap = new Map<String,Id>();
        ContentVersion cv = [SELECT VersionData FROM ContentVersion WHERE ContentDocumentId = :docId AND IsLatest = true];
        String fileData =cv.VersionData.toString();
        System.debug('fileData==>> '+fileData);
        List<String> csvFileLines = new List<String>(fileData.split('[\\r\\n]+'));
        System.debug('csvFileLines==>> '+csvFileLines.size());
        Integer recordLines = (csvFileLines.size()) - 1;
        System.debug('csvContents'+cv);
        
        try{
            for(Integer i=1; i<csvFileLines.size(); i++ ){
                System.debug('Base_Class_Uploader.columns_Splitter(csvFileLines[i])-->'+Base_Class_Uploader.columns_Splitter(csvFileLines[i]));
                List<String> inputvalues1 = Base_Class_Uploader.columns_Splitter(csvFileLines[i]);
                CSVinputvalues.add(inputvalues1);
            }
            
            for(List<String> filterInputList : CSVinputvalues ){
                Wrapper_CSVFileRecord CSVrecord = new Wrapper_CSVFileRecord();
                CSVrecord.contractNumber = filterInputList[0];
                CSVrecord.Rate_Change = filterInputList[1];
                CSVrecord.Rate_Change_Reason = filterInputList[2];
                CSVrecord.Rate_Effective_Date = filterInputList[3];
                if(filterInputList[0].length() != 8){
                    returnresponse = 'Contract number should be 8 digits';
                }
                contractNumber.add(filterInputList[0]);
                wrapperCSVrecordList.add(CSVrecord);
            }
            
            bl.RecordTypeId = Schema.Sobjecttype.Batch_Log__c.getRecordTypeInfosByName().get('Bulk Contract Rate Updater Rec Type').getRecordTypeId();
            bl.Created_Records_Count__c = Integer.valueOf(csvFileLines.size()) - 1;
            if(returnresponse==''){
                insert bl;
            }
            
            ContentDocumentLink contentDocumentLink = new ContentDocumentLink();
            contentDocumentLink.ContentDocumentId = docId;
            contentDocumentLink.LinkedEntityId = bl.Id;
            contentDocumentLink.ShareType = 'I'; // Inferred permission
            contentDocumentLink.Visibility = 'AllUsers';
            Insert contentDocumentLink;
            
            List<Contract> contractsList = [SELECT Id,ContractNumber FROM Contract WHERE ContractNumber IN : contractNumber];
            System.debug('contractsList'+contractsList.size());
            for(Contract con : contractsList){
                contractNumberIdMap.put(con.ContractNumber,con.Id);
            }
            
            for(Wrapper_CSVFileRecord CSVrec : wrapperCSVrecordList){
                Contract_Rate__c crNew = new Contract_Rate__c();
                crNew.Total_Unit_Rate__c = Decimal.valueOf(CSVrec.Rate_Change);
                crNew.Rate_Change_Reason__c = CSVrec.Rate_Change_Reason;
                crNew.Effective_From_Date__c = Date.valueOf(CSVrec.Rate_Effective_Date);
                if(contractNumberIdMap.get(CSVrec.contractNumber) !=null){
                    crNew.Contract__c = contractNumberIdMap.get(CSVrec.contractNumber);    
                }else{
                    returnresponse = 'Contract Numner '+CSVrec.contractNumber+ ' Doesnot exist';
                }
                crNew.batch_log__c = bl.Id;
                contractRateToInsert.add(crNew);
            }
            System.debug('returnresponse');
            if(contractRateToInsert.size()>0 && returnresponse == ''){
                insert contractRateToInsert;
            }
        }catch(Exception e){
            bl.Created_Records_Count__c = 0;
            if(bl.Id != null){
                update bl;
            }
            System.debug('Error message'+e.getMessage() +' Line no -- '+e.getLineNumber());
            if(returnresponse == ''){
                returnresponse = e.getMessage();
            }
        }
        return returnresponse;
    }
    
    //To Display the batch log data on load of component
    // recTypeId is used to differentiate batch log recors that are shown in "Bulk Contract Rate Updater" and "Report Scheduler"
    @auraEnabled
    public static List<Batch_Log__c> getData(){
        Id recTypeId = Schema.Sobjecttype.Batch_Log__c.getRecordTypeInfosByName().get('Bulk Contract Rate Updater Rec Type').getRecordTypeId();
        return [SELECT Id, Name,CreatedDate, CreatedById,CreatedBy.Name,Owner.Name,Created_Records_Count__c, Completed_Date__c, Exception__c, Run_Type__c, Start_Date__c, Status__c FROM Batch_Log__c WHERE RecordTypeId =:recTypeId ORDER BY Completed_Date__c DESC ];
    }
}