@isTest
public class creditProcess_Notifications_Test {
    public static testMethod void setupMethod(){
     Marketer__c getMarketer = new Marketer__c(name = 'xyz', MarketerDunsNumber__c = 'ten');
        Insert getMarketer;
      
        Experian__c expObj = new Experian__c();
        expObj.Auth_Body__c = 'a';
        expObj.Auth_URL__c ='b';
        expObj.Auto_Search_URL__c='a';
        expObj.Auth_Body__c = 'test';
        expObj.Subcode__c = '01';
        insert expObj;
        
        Account objAcc = new Account(Name = 'Account Test');
        objAcc.RecordTypeId = [SELECT Id, Name, DeveloperName FROM RecordType where DeveloperName = 'Utility'].Id;
        insert objAcc;
        
        Contract objCon = new Contract();
        objCon.ContractTerm = 4;
        objCon.StartDate = system.today().addMonths(-1);
        objCon.AccountId = objAcc.Id;
        //objCon.Status = 'Draft';
        //insert objCon;
        
        Contact objContact = new Contact();
        //objContact.LastName = 'Test Lastname';
        objContact.firstName = 'Pricing';
        objContact.lastName ='Team';
        objContact.AccountId = objAcc.Id;
        objContact.Phone = '1234567890';
        insert objContact;
        
        objAcc.Primary_Contact__c = objContact.Id;
        update objAcc;
        
        Opportunity objOpp = new Opportunity();
        objOpp.AccountId = objAcc.Id;
        objOpp.ContractId = objCon.Id;
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
        Insert objUA;
        
        Pricing_Request__c objPR1 = new Pricing_Request__c();
        objPR1.Opportunity__c = objOpp.Id;
        objPR1.Start_Date__c = System.today();
        objPR1.Record_Created__c = true;
       // objPR.Credit_details__c = creditCheckRecord.Id;
        Insert objPR1;
        
        Credit_Check__c creditCheckRecord = new Credit_Check__c(Customer__c = objAcc.Id,Pricing_Request__c = objPR1.Id, Opportunity__c = objOpp.Id, Status__c = 'Active', Credit_Check_Outcome__C = 'Passed', FSR_Score__c = 19, IP_Score__c = 9);
        Insert creditCheckRecord;
        
        
        Pricing_Request__c objPR = new Pricing_Request__c();
        objPR.Opportunity__c = objOpp.Id;
        objPR.Start_Date__c = System.today();
        objPR.Record_Created__c = true;
        objPR.Credit_details__c = creditCheckRecord.Id;
        Insert objPR;
        
        Utility_Account_Pricing__c objUAP = new Utility_Account_Pricing__c();
        objUAP.Utility_Account__c = objUA.Id;
        objUAP.Pricing_Request__c = objPR.Id;
        objUAP.Start_Date__c = System.today();
        Insert objUAP;  
        
                
        Credit_Check__c creditCheckRecord1 = new Credit_Check__c(Customer__c = objAcc.Id,Pricing_Request__c = objPR.Id, Opportunity__c = objOpp.Id, Status__c = 'Active', Credit_Check_Outcome__C = 'Passed', FSR_Score__c = 19, IP_Score__c = 9);
        Insert creditCheckRecord1;
        
        Price__c price2 = new Price__c();
        price2.Credit__c = true;
        //   price2.Term_Prices__r.Credit_Premium__c = 0;
        price2.P_D__c = true;
        price2.Subject_to_Credit__c = true;
        price2.Pricing_Request__c = objPR.Id;
        price2.Notes__c='Hello';
        //price2.Product_Lookup__c = prodObj.Id;
        price2.Bill_Type__c = 'Dual';
        price2.Latest_Price__c = true;
        price2.Invoice_Billing_Type__c='Summary Billing';
        price2.Treatment__c='Fixed';
        price2.Voluntary_RECs__c= 'Any';
        price2.Voluntary_RECs_percent__c = 100;
        price2.Opportunity__c = objOpp.Id;
        price2.Credit_Detail__c =creditCheckRecord.Id;
        insert price2;
        
        Price_Summary__c priceSum = new Price_Summary__c();
        priceSum.Volume_kWh__c = 4500;
        priceSum.Base_Price__c = 0.1500;
        priceSum.Price__c = price2.Id;
        priceSum.Term_months__c = 12;
        priceSum.Price_x_Vol__c = 1500;
        priceSum.Utility_Count__c = 1;
        priceSum.Cumulative_Volume__c  = 154555;
        priceSum.Load_Factor_Decimal__c = 40;
        priceSum.Month__c = 'Nov' ;
        priceSum.Year__c = 2020;
        priceSum.Tax_x_Volume__c =  10;
        priceSum.POR_x_Volume__c =  10;
        insert priceSum;
        
        User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        System.runAs ( thisUser ) {
            EmailTemplate e = new EmailTemplate (developerName = 'Test', FolderId = UserInfo.getUserId(), TemplateType= 'Text', Name = 'Test');
            e.IsActive = true;
            Insert e;
        }
        
        List<creditProcess_Notifications.values> valList = new List<creditProcess_Notifications.values>();
        creditProcess_Notifications.values val = new creditProcess_Notifications.values();
        val.recordId = creditCheckRecord1.Id;
        val.creditRiskTeam = true;
        val.includeCreditPremium = true;
        val.EmaiTemplateName = 'Test';
        valList.add(val);
        
        Group grp = new Group();
        grp.Type = 'Queue';
        grp.Name = 'Credit Risk Team';
        insert grp;
        
        Group grp1 = new Group();
        grp1.Type = 'Queue';
        grp1.Name = 'Credit Risk Team';
        insert grp1;
        
        /*List<GroupMember> GroupMembers = new List<GroupMember>();
        GroupMember gm = new GroupMember();
        gm.GroupId = grp.Id;
        gm.UserOrGroupId = grp1.Id;
        insert gm;*/
       
        
        Test.startTest();
        creditProcess_Notifications.invokeCallConga(valList);
        Test.stopTest();
    }
}