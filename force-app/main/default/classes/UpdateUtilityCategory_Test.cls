/*
* @Purpose: Test class for UpdateUtilityCategory Apex.
* @Author:  Tushar Shinde
* @CreatedDate: 07/07/2021
*/
@isTest
public class UpdateUtilityCategory_Test {
 	 @isTest(seeAllData=true)
    public static void updateUtility(){
        String u = userInfo.getUserId();
        Account objAcc = new Account(Name = 'Account Test');
        objAcc.RecordTypeId = [SELECT Id, Name, DeveloperName FROM RecordType where DeveloperName = 'Utility'].Id;
        insert objAcc;
        
        Contact objContact = new Contact();
        objContact.LastName = 'Test Lastname';
        objContact.AccountId = objAcc.Id;
        objContact.Phone = '1234567890';
        insert objContact;
        
        objAcc.Primary_Contact__c = objContact.Id;
        update objAcc;
        
        Opportunity objOpp = new Opportunity();
        objOpp.AccountId = objAcc.Id;
        //objOpp.ContractId = objCon.Id;
        objOpp.Name = 'Oppo Test';
        objOpp.StageName = 'New';
        objOpp.CloseDate = system.today().addMonths(1);
        objOpp.Broker__c = objAcc.id;
        objOpp.ContactId = objContact.Id;
        insert objOpp;
        
        Utility_Account__c objUA = new Utility_Account__c();
        objUA.Account__c = objAcc.Id;
        objUA.Name = '1234567890';
        objUA.Utility__c = objAcc.Id;
        objUA.Street__c = 'Street';
        objUA.City__c = 'City';
        objUA.State__c = 'NY';
        objUA.Country__c = 'US';
        objUA.Zip__c = '123456';
        insert objUA;
        
        Enrollment__c objEN = new Enrollment__c();
        // objEN.Contract__c = objCon.Id;
        objEn.Account__c = objAcc.Id;
        objEn.Start_Date_Category__c = 'Single Start Date';
        objEn.Utility_Category__c = 'Single Utility';
        insert objEN;
        
        Utility_Account_Enrollment__c objUAE = new Utility_Account_Enrollment__c();
        objUAE.Enrollment__c = objEN.Id;
        objUAE.Utility_Account__c = objUA.Id;
        insert objUAE;
        
        List<Id>enrolIds = new List<Id>();
        enrolIds.add(objEN.Id);
        test.startTest();
        UpdateUtilityCategory.upUtilCategory(enrolIds);
        test.stopTest();
        
    }
}