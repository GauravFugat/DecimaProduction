@isTest
private class PricingSystemIntegration_Test {
    public static String PricingRequest;
    public static String ContentDocumentID;
    public static boolean alignStartDates;
    static{
        Account acc1= new Account();
        acc1.Name = 'Test Acc';
        insert acc1;
        
        Marketer__c getMarketer = new Marketer__c(name = 'xyz', MarketerDunsNumber__c = 'ten');
        Insert getMarketer;
        
        
        HU_Api_Call__c huObj = new HU_Api_Call__c();
        huObj.Call_AWS__c = false;
        huObj.Call_Azure__c = false;
        insert huObj;
        
        Id recordTypeCus = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Customer').getRecordTypeId();
        Account CusAcc= new Account();
        CusAcc.Name = 'Test Acc1';
        CusAcc.RecordTypeId =recordTypeCus;
        insert CusAcc;
        
        Id id1 = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Utility').getRecordTypeId();
        Account acc2= new Account();
        acc2.Name = 'Test Acc1';
        acc2.RecordTypeId =id1;
     
        insert acc2;
        
        
        Contact con = new Contact();
        con.FirstName = 'Con First';
        con.Email = 'ttest@test.com';
        con.LastName = 'Test Last';
        con.AccountId = acc2.Id;
        insert con;
        
        acc2.Primary_Contact__c = con.Id;
        update acc2;
        
        Contract objCon = new Contract();
        objCon.ContractTerm = 4;
        objCon.StartDate = system.today().addMonths(-1);
        objCon.AccountId = acc1.Id;
     
        insert objCon;
        
        Opportunity opp = new Opportunity();
        opp.Name='Test Opp';
        opp.AccountId = CusAcc.id;
        opp.ContractId = objCon.Id;
        opp.CloseDate = system.today().addMonths(1);
        opp.StageName ='New';
        opp.Broker__c = acc2.id;
        opp.ContactId = con.Id;
        opp.Price_Request_Count__c = 2;
        opp.Pricing_Request_Complete__c=true;
        insert opp;
        system.debug('opp======='+opp);
        
        Product2 prodObj = new Product2(Name='Fully Fixed',ProductCode = '0',Product_Id__c = '0');
        insert prodObj;
        
        List<Id> prLst = new List<Id>();
        RecordType rt = [SELECT Id, Name, DeveloperName, SobjectType FROM RecordType where SobjectType = 'Pricing_Request__c' AND DeveloperName = 'Default_Pricing_Request' limit 1];
        Pricing_Request__c pr = new Pricing_Request__c();
        pr.Opportunity__c = opp.Id;
        pr.Notes__c = 'Hello';
        pr.Status__c = 'Complete';
        pr.Bill_Type__c = 'UCB';
        pr.RecordTypeId = rt.Id;
        pr.Product_Lookup__c = prodObj.Id;
        pr.Customer__c = CusAcc.id;
        pr.Voluntary_RECs__c = 'Any';
        pr.Voluntary_RECs_percent__c = 100;
        pr.Mark_to_Market__c = 100;
        pr.Due_Date__c = system.today().addMonths(1);
        pr.Urgent_Request__c = true;
        pr.Pricing_Quote_Comments__c ='test';
        pr.Treatment__c='Fixed';
        pr.Start_Dates__c='Same';
        pr.Record_Created__c = true;
        insert pr; 
        system.debug('pr--'+pr);
        /*pr.Original_Pricing_Request__c= pr.Id;
        update pr;*/
        
         prLst.add(pr.Id);
        system.debug('prLst'+prLst);
        
        Price__c price = new Price__c();
        price.Credit__c = true;
        price.P_D__c = true;
        price.Subject_to_Credit__c = true;
        price.Pricing_Request__c = pr.Id;
        insert price;
        
        Date myDate = date.newInstance(2020,01,17);
        Utility_Account__c ua1 = new Utility_Account__c();
        ua1.Name = '1234567890';
        ua1.Account__c = acc1.Id;
        ua1.Utility__c = acc2.Id;
        insert ua1;
        
        Utility_Account_Pricing__c uapr = new Utility_Account_Pricing__c();
        uapr.Pricing_Request__c = pr.Id;
        uapr.Start_Date__c = myDate;
        uapr.Utility_Account__c = ua1.Id;
        insert uapr;
        
       
         ContentVersion contentVersion = new ContentVersion(
            Title = 'Penguins',
            PathOnClient = 'Penguins.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert contentVersion;    
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        System.debug('documents->'+documents);
        //create ContentDocumentLink  record 
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = pr.id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        insert cdl;
        System.debug('cdl->'+cdl);
    }
    
   	@isTest
     static void testSuccess(){
                
         
		Pricing_Request__c pr1 = [select id, Name from Pricing_Request__c limit 1]; 
        System.debug('pr -->'+pr1);
        ContentDocumentLink ContentDocs = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =: pr1.Id];
        System.debug('ContentDocs -->'+ContentDocs);
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = 'https://smartestenergyus--dev5.my.salesforce.com/services/apexrest/processPriceFile/';
    
		
         String reqBody='{"PricingRequest":"'+pr1.Name+'","ContentDocumentID":"'+ContentDocs.ContentDocumentId+'","alignStartDates":true}';
		
		req.requestBody= Blob.valueOf(reqBody);        
        req.httpMethod = 'POST';
         //Select id,Validate__c from Price_File_Validation__c limit 1
         Price_File_Validation__c pfv = new Price_File_Validation__c();
         pfv.Validate__c = true;
         insert pfv;
         
         RestContext.request = req;
        RestContext.response= res;
        Test.startTest();
        	Test.setMock(HttpCalloutMock.class, new MockHttpResponsePriceSystemIntegration());         
        	PricingSystemIntegration.JsonWrapStatus js = new PricingSystemIntegration.JsonWrapStatus();
        	PricingSystemIntegration.processPriceFile();        	
        Test.stopTest();
    }
    /*
	@isTest
     static void testFail1(){
        
        
		Pricing_Request__c pr1 = [select id, Name from Pricing_Request__c limit 1]; 
        System.debug('pr -->'+pr1);
        ContentDocumentLink ContentDocs = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =: pr1.Id];
        System.debug('ContentDocs -->'+ContentDocs);
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = 'https://smartestenergyus--dev5.my.salesforce.com/services/apexrest/processPriceFile/';
       
          String reqBody='{"PricingRequest":"'+pr1.Name+'","ContentDocumentID":"123","alignStartDates":true}';
		
		req.requestBody= Blob.valueOf(reqBody);   
        req.httpMethod = 'POST';
        
        RestContext.request = req;
        RestContext.response= res;
        Test.startTest();
        	Test.setMock(HttpCalloutMock.class, new MockHttpResponsePriceSystemIntegration()); 
        	PricingSystemIntegration.JsonWrapStatus js = new PricingSystemIntegration.JsonWrapStatus();
        	PricingSystemIntegration.processPriceFile();        	
        Test.stopTest();
    }*/
    /*
   	 @isTest
     static void testFail2(){
             
		Pricing_Request__c pr1 = [select id, Name from Pricing_Request__c limit 1]; 
        System.debug('pr -->'+pr1);
        ContentDocumentLink ContentDocs = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =: pr1.Id];
        System.debug('ContentDocs -->'+ContentDocs);
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = 'https://smartestenergyus--dev5.my.salesforce.com/services/apexrest/processPriceFile/';

         String reqBody='{"PricingRequest":"'+pr1.Name+'","ContentDocumentID":"NULL","alignStartDates":false}';
        		req.requestBody= Blob.valueOf(reqBody); 
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response= res;
        Test.startTest();
        	Test.setMock(HttpCalloutMock.class, new MockHttpResponsePriceSystemIntegration()); 
        	PricingSystemIntegration.JsonWrapStatus js = new PricingSystemIntegration.JsonWrapStatus();
        	PricingSystemIntegration.processPriceFile();        	
        Test.stopTest();
    }
    */
}