// Test class for BulkContractRateUpdater_Controller
@IsTest
public class BulkContractRateUpdater_Controller_Test {
    @IsTest
    public static void testSetup(){
        StaticResource sr1 = [select Id, body from StaticResource where name='Contract_Rate_File'];
        ContentVersion cv = new ContentVersion();
        cv.PathOnClient = String.valueOf(sr1.body); 
        //cv.ContentBodyId =sr1.Id;
        cv.Title = 'Test';
        cv.VersionData = sr1.body;
        insert cv; 
        ContentDocument cd  = [SELECT Id from ContentDocument LImit 1];
        Test.startTest();
        BulkContractRateUpdater_Controller.createRateData(cd.Id);
        BulkContractRateUpdater_Controller.getData();
        Test.stopTest();
    }
}