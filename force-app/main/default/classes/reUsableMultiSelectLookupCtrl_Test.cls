@isTest
public class reUsableMultiSelectLookupCtrl_Test {
    public static testMethod void setupMethod(){
        //String searchKeyWord, String ObjectName, List<sObject> ExcludeitemsList, Id parentAccountId, String screenName,String ParentObjectFieldName, String ParentObjectId
        List<sObject> ExcludeitemsList = new List<sObject>();
        
        
        Account objAcc = new Account(Name = 'Account Test');
        objAcc.RecordTypeId = [SELECT Id, Name, DeveloperName FROM RecordType where DeveloperName = 'Customer'].Id;
        insert objAcc;
        
        Contact objContact = new Contact();
        objContact.LastName = 'Test Lastname';
        objContact.AccountId = objAcc.Id;
        objContact.Phone='';
        objContact.Email = 'test123@test.com';
        insert objContact;
        
        Contract objCon = new Contract();
        objCon.ContractTerm = 4;
        objCon.StartDate = system.today().addMonths(-1);
        objCon.AccountId = objAcc.Id;
        //objCon.Status = 'Live';
        insert objCon;
        
        ExcludeitemsList.add(objCon);

        Test.startTest();
        reUsableMultiSelectLookupCtrl.fetchLookUpValues('','Contact',ExcludeitemsList,null,null,'AccountId',objAcc.Id);
        reUsableMultiSelectLookupCtrl.fetchLookUpValues('','Contact',ExcludeitemsList,null,null,'AccountId','');
        reUsableMultiSelectLookupCtrl.fetchLookUpValues('','Contact',ExcludeitemsList,null,null,'','');
        reUsableMultiSelectLookupCtrl.fetchLookUpValues('Test','Contact',ExcludeitemsList,null,null,'','');
        Test.stopTest();
        
    }
}