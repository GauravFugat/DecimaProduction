@isTest
public class CountUpdateBroker_Test {
    public static testMethod void setupMethod(){
        Account objAcc = new Account(Name = 'Account Test');
        insert objAcc;
        
        Account objAcc1 = new Account(Name = 'Account Test');
        insert objAcc1;
        
        Contact objContact = new Contact();
        objContact.LastName = 'Test Lastname';
        objContact.AccountId = objAcc.Id;
        objContact.Phone = '1234567890';
        objContact.Email = 'test123@test.com';
        insert objContact;
        
        Opportunity objOpp = new Opportunity();
        objOpp.AccountId = objAcc.Id;
        objOpp.Name = 'Oppo Test';
        objOpp.StageName = 'New';
        objOpp.CloseDate = system.today().addMonths(1);
        objOpp.Broker__c = objAcc.id;
        objOpp.ContactId = objContact.Id;
        objOpp.AccountId=objAcc.Id;
        insert objOpp;
        
        Opportunity objOpp1 = new Opportunity();
        objOpp1.AccountId = objAcc.Id;
        objOpp1.Name = 'Oppo Test';
        objOpp1.StageName = 'Closed Lost';
        objOpp1.Loss_Reason__c = 'Other';
        objOpp1.CloseDate = system.today().addMonths(1);
        objOpp1.Broker__c = objAcc1.id;
        objOpp1.ContactId = objContact.Id;
        objOpp1.AccountId=objAcc1.Id;
        insert objOpp1;
        
        List<Id> recordId = new List<Id>();
        recordId.add(objAcc.ID);
        
         List<Id> recordIds = new List<Id>();
        recordIds.add(objAcc1.ID);
        
        CountUpdateBroker.getCountBroker(recordId);
        CountBrokerClass.getCountBroker(recordId);
        CountAllOPPBrokerClass.getCountBroker(recordIds);
    }
    
}