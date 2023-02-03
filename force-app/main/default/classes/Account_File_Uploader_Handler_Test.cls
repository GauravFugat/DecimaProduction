/***************************************************************************************************************************
* Name:        Account_File_Uploader_Handler_Test 
* Description: Test class of Account_File_Uploader_Handler class.
* 
* Version History
* Date             Developer               Comments
* ---------------  --------------------    --------------------------------------------------------------------------------
* 2019-11-04       Aress Dev  				To testing the functionality of class.   
* 2022-12-01       Suhas P.			To test the functionality of class.   
****************************************************************************************************************************/
@IsTest
public class Account_File_Uploader_Handler_Test {
    public static testMethod void setupMethod(){
        
        Account_File_Uploader_Handler.systemDuplicate wrappersysDupRecord =new Account_File_Uploader_Handler.systemDuplicate();
        wrappersysDupRecord.UtilityAccountNumber ='Test';
        wrappersysDupRecord.UtilityName ='Test1';
        wrappersysDupRecord.AccountName ='Test2';
        
        Account_File_Uploader_Handler.Wrapper_CSVFileRecord wrapperCSVRecord = new Account_File_Uploader_Handler.Wrapper_CSVFileRecord();
        wrapperCSVRecord.UtilityAccountNumber = '1234567890';
        wrapperCSVRecord.Utility = 'Utility';
        wrapperCSVRecord.StartDate = '12-1-2022';
        wrapperCSVRecord.Street ='street';
        wrapperCSVRecord.Street2 = 'street2';
        wrapperCSVRecord.City = 'Frazeyburg';
        wrapperCSVRecord.State = 'OH';
        wrapperCSVRecord.Zip = '43811';
        wrapperCSVRecord.Country = 'US';
        
        Id id1 = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Utility').getRecordTypeId();
        Account acc1= new Account();
        acc1.Name = 'Aress Utility';
        acc1.RecordTypeId = id1;
        acc1.Utility_Account_Number_Prefix__c  = 'TST';
        insert acc1;
        
        StaticResource sr = [select body from StaticResource where name='acc_file_upload_test'];
        blob csvfile = sr.body;
        List<String> errorLog1 = new List<String>();
        errorLog1.add('error 1');
        errorLog1.add('error 2');
        
        try{
            Base_Class_Uploader.createUploadLog(acc1.Id, errorLog1,'Account');
            Boolean isnum = Base_Class_Uploader.isNumeric('s');
            Boolean isDate = Base_Class_Uploader.isDate('21/02/2019');
            Account_File_Uploader_Handler.insertData(csvfile,acc1.Id,'file.csv');
            
        }catch(Exception e){}
        
    }     
    
    public static testMethod void setupMethod1(){
        
        Id id1 = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Utility').getRecordTypeId();
        Account acc1= new Account();
        acc1.Name = 'Aress Utility';
        acc1.Utility_Account_Number_Length__c  = 10;
        acc1.RecordTypeId = id1;
        insert acc1;
        
        // To test correct data by inserting csv file with correct data 
        StaticResource sr1 = [select body from StaticResource where name='acc_file_upload_test'];
        blob csvfile1 = sr1.body;
        
        StaticResource sr2 = [select body from StaticResource where name='acc_file_upload_test_2'];
        blob csvfile2 = sr2.body;
        
        List<String> errorLog = new List<String>();
        test.startTest();
        try{
            Base_Class_Uploader.createUploadLog(acc1.Id, errorLog,'Account');
            Boolean isnum = Base_Class_Uploader.isNumeric('s');
            Boolean isDate = Base_Class_Uploader.isDate('21/02/2019');
            Account_File_Uploader_Handler.insertData(csvfile1,acc1.Id,'file.csv'); 
            Account_File_Uploader_Handler.insertData(csvfile2,acc1.Id,'file.csv');
            
        }catch(Exception e){}
        test.stopTest();
    }
    
}