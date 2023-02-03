@isTest
public class ReportSchedularController_Test {
    
    @testSetup static void setupM() {
    APXTConga4__Conga_Merge_Query__c cquery = new APXTConga4__Conga_Merge_Query__c();
        cquery.APXTConga4__Name__c = 'Drops';
        insert cquery;
        
        APXTConga4__Conga_Template__c cTemplate = new APXTConga4__Conga_Template__c();
        cTemplate.APXTConga4__Name__c = 'Drops';
        insert cTemplate;
        
        Report_Schedular__c rs = new Report_Schedular__c();
        rs.Name = 'Drops';
        rs.Send_Internally__c = true;
        rs.Report_Name__c = 'Drops';
        rs.Date_of_month__c = '1';
        rs.Day_of_week__c = 'MON';
        rs.Time__c = '21:38:46';
        rs.Days__c = 'Weekly';
        insert rs;

Report_Schedular__c rs2 = new Report_Schedular__c();
        rs2.Name = 'Dropws';
        rs2.Send_Internally__c = false;
        rs2.Report_Name__c = 'Dropws';
        rs2.Date_of_month__c = '1';
        rs2.Day_of_week__c = 'MON';
        rs2.Time__c = '21:38:46';
        rs2.Days__c = 'Weekly';
        insert rs2;        
            
            
        Account objAcc = new Account(Name = 'Account Test',Reports_Subscription__c = true,Phone = '1234567890');
        objAcc.RecordTypeId = [SELECT Id, Name, DeveloperName FROM RecordType where DeveloperName = 'Utility'].Id;
        insert objAcc;
        
        
        Contact objContact = new Contact();
        objContact.Subscribed_Reports__c = 'Dropped Meter';
        objContact.LastName = 'Test Lastname';
        objContact.AccountId = objAcc.Id;
        objContact.Phone = '1234567890';
        objContact.Email = 'test123@test.com';
        insert objContact;
        
        Contract objCon = new Contract();
        objCon.ContractTerm = 4;
        objCon.StartDate = system.today().addMonths(-1);
        objCon.AccountId = objAcc.Id;
        //objCon.Status = 'Draft';
        insert objCon;
        
        Utility_Account__c objUA = new Utility_Account__c();
        objUA.Account__c = objAcc.Id;
        objUA.Name = '1234567890';
        objUA.Utility__c = objAcc.Id;
        objUA.Street__c = 'Street';
        objUA.City__c = 'City';
        objUA.State__c = 'NY';
        objUA.Country__c = 'US';
        objUA.Zip__c = '123456';
        //objUA.Status__c='DACC';
        objUA.Status__c='Requested';
        insert objUA;
        
        Enrollment__c objEN = new Enrollment__c();
        objEN.Contract__c = objCon.Id;
        objEn.Account__c = objAcc.Id;
        objEN.Start_Date_Category__c = 'Single Start Date';
        objEN.Primary_Utility__c = objAcc.Id;
        objEN.Utility_Category__c = 'Single Utility';

        insert objEN;
        
        Utility_Account_Enrollment__c objUAE = new Utility_Account_Enrollment__c();
        objUAE.Enrollment__c = objEN.Id;
        objUAE.Utility_Account__c = objUA.Id;
        objUAE.Program_Code__c = 'AB/120';
        insert objUAE;
       
        
         Blob b = Blob.valueOf('Test Data');
        Attachment attachment = new Attachment();
        attachment.ParentId = objContact.Id;
        attachment.Name = 'Test Attachment for Parent';
        attachment.Body = b;
        Insert attachment;
        
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Penguins',
            PathOnClient = 'Penguins.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert contentVersion;    
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
        //create ContentDocumentLink  record 
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = objContact.id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        insert cdl;
        
        
        MockHttpResponseGeneratorConga MRGC = new MockHttpResponseGeneratorConga();
        MRGC.attId = attachment.Id;
        Test.setMock(HttpCalloutMock.class, MRGC);
       
        List<String> toadds = new List<String>();
        toadds.add('test@test.com');
        List<String> ccAdds = new List<String>();
        ccAdds.add('test@test123.com');
        List<Id> addFiles = new List<Id>();
        addFiles.add(cdl.Id);
    }
    
//     @isTest(SeeAllData='true')
    @isTest
    public static void setupMethod(){
        
        Attachment att = [Select Id,ParentId,Name, Body From Attachment limit 1];
        Report_Schedular__c rs1 = [SELECT Id, Name,Toggle1__c,Send_Internally__c, Date_of_month__c,Report_Scheduled__c FROM Report_Schedular__c limit 1];
        delete rs1;
        Report_Schedular__c rs = new Report_Schedular__c();
        rs.Name = 'Drops';
        rs.Send_Internally__c = true;
        rs.Report_Name__c = 'Drops';
        rs.Date_of_month__c = '1';
        rs.Day_of_week__c = 'MON';
        rs.Time__c = '21:38:46';
        rs.Days__c = 'Weekly';
        insert rs;
        MockHttpResponseGeneratorConga MRGC = new MockHttpResponseGeneratorConga();
        MRGC.attId = att.Id;
        Test.setMock(HttpCalloutMock.class, MRGC);
       
        test.startTest();
        ReportSchedularController.scheduleReport(RS);
        ReportSchedularController.getData();
        BrokerReportSenderBatch brep = new BrokerReportSenderBatch(); 
        brep.reportName = 'Drops';
        brep.batchRunType = 'Manual';
        database.executebatch(brep, 200);
        ReportSchedularController.getReportSchedulars();
        ReportSchedularController.toggleOff('Drops');
        ReportSchedularController.updateReport(RS);
        ReportSchedularController.toggleOff('Drops');
        ReportSchedularController.deleteReportSched(RS);
      test.stopTest();
    }
    
  //  @isTest(SeeAllData='true')
    @isTest
    public static void setupMethod2(){
        
       Attachment att = [Select Id,ParentId,Name, Body From Attachment limit 1];
        Account acct = [Select Id,name FROM Account limit 1];
        Map<Account, Attachment> accRepMaptopass = new Map<Account,Attachment>(); 
        accRepMaptopass.put(acct,att);
     Report_Schedular__c rs = new Report_Schedular__c();
        rs.Name = 'Broker Enrollment Report';
        rs.Send_Internally__c = false;
        rs.Report_Name__c = 'Broker Enrollment Report';
        rs.Date_of_month__c = '1';
        rs.Day_of_week__c = 'MON';
        rs.Time__c = '21:38:46';
        rs.Days__c = 'Weekly';
        insert rs;
        
        
       
        ReportSchedularController.scheduleReport(RS);
        ReportSchedularController.getData();
        BrokerReportSenderBatch brep = new BrokerReportSenderBatch(); 
        brep.reportName = 'Broker Enrollment Report';
        brep.batchRunType = 'Manual';
        brep.accRepMap = accRepMaptopass;
        database.executebatch(brep, 200);
        ReportSchedularController.getReportSchedulars();
        ReportSchedularController.toggleOff('Broker Enrollment Report');
        ReportSchedularController.updateReport(RS);
        ReportSchedularController.toggleOff2('Broker Enrollment Report');
        ReportSchedularController.deleteReportSched(RS);
        
    }
 
    
 /*   @isTest(SeeAllData='true')
    public static void setupMethod3(){
    
        BrokerReportSenderBatch brep = new BrokerReportSenderBatch(); 
        brep.reportName = 'Enrollment Rejections';
        brep.batchRunType = 'Manual';
        database.executebatch(brep, 200);
        
        
    }
    @isTest(SeeAllData='true')
    public static void setupMethod4(){
    
        BrokerReportSenderBatch brep = new BrokerReportSenderBatch(); 
        brep.reportName = 'Future Agreements Report';
        brep.batchRunType = 'Manual';
        database.executebatch(brep, 200);
        
        
    }*/
}