@isTest
public class creditRiskProcess_Test {
    @isTest
    public static void setupMethod(){
        Marketer__c getMarketer = new Marketer__c(name = 'xyz', MarketerDunsNumber__c = 'ten');
        Insert getMarketer;
        HU_Api_Call__c huObj = new HU_Api_Call__c();
        huObj.Call_AWS__c = false;
        huObj.Call_Azure__c = false;
        insert huObj;
        Account acc1= new Account();
        acc1.Name = 'Test Acc';
        insert acc1;
        
        Id id1 = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Utility').getRecordTypeId();
        Account acc2= new Account();
        acc2.Name = 'Test Acc1';
        acc2.RecordTypeId =id1;
        //acc2.Utility_Account_Number_Prefix__c  = 'TST';
        insert acc2;
        
        Id recordTypeCus = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Customer').getRecordTypeId();
        Account CusAcc= new Account();
        CusAcc.Name = 'Test Acc1';
        CusAcc.RecordTypeId =recordTypeCus;
        CusAcc.Customer_Credit_Limit__c = 7500;
        CusAcc.Customer_Credit_Annual_Volume__c =600000;
        insert CusAcc;
        
        Contact con = new Contact();
        con.FirstName = 'Con First';
        con.LastName = 'Test Last';
        con.AccountId = acc2.Id;
        insert con;
        
        acc2.Primary_Contact__c = con.Id;
        update acc2;
        
        Contract objCon = new Contract();
        objCon.ContractTerm = 4;
        objCon.StartDate = system.today().addMonths(-1);
        objCon.AccountId = acc1.Id;
        //objCon.Status = 'Draft';
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
        insert opp;
        
        Product2 prodObj = new Product2(Name='Fully Fixed',ProductCode = '0',Product_Id__c = '0');
        insert prodObj;
        
        Pricing_Request__c pr = new Pricing_Request__c();
        pr.Opportunity__c = opp.Id;
        pr.Notes__c = 'Hello';
        pr.Status__c = 'Complete';
        pr.Bill_Type__c = 'Dual';
        pr.Product_Lookup__c = prodObj.Id;
        pr.Customer__c = CusAcc.id;
        pr.Voluntary_RECs__c = 'Any';
        pr.Voluntary_RECs_percent__c = 100;
        pr.Record_Created__c = true;
        insert pr;
        
        
        
        Credit_Check__c cc = new Credit_Check__c();
        cc.Pricing_Request__c = pr.Id;
        cc.Customer__c = CusAcc.id;
        cc.Status__c = 'Active';
        cc.FSR_Score__c=10;
        cc.Credit_Limit__c = 500000;
        cc.IP_Score__c=6;
        cc.Opportunity__c =opp.Id;
        cc.Credit_Limit__c = 7500;
        cc.Credit_Check_Outcome__c = 'Passed';
        cc.Credit_Premium_Type__c ='S2';
        insert cc;
        
        Credit_Check__c cc1 = new Credit_Check__c();
        cc1.Pricing_Request__c = pr.Id;
        cc1.Customer__c = CusAcc.id;
        cc1.Status__c = 'Active';
        cc1.FSR_Score__c=10;
        cc1.IP_Score__c=6;
        cc1.Credit_Limit__c = 500000;
        cc1.Opportunity__c =opp.Id;
        cc1.Credit_Limit__c = 7500;
        cc1.Credit_Check_Outcome__c = 'Passed';
        cc1.Credit_Premium_Type__c ='Custom';
        cc1.Custom_Credit_Premium__c=1000;
        insert cc1;
        
        
        Credit_Check__c cc2 = new Credit_Check__c();
        cc2.Pricing_Request__c = pr.Id;
        cc2.Customer__c = CusAcc.id;
        cc2.Status__c = 'Active';
        cc2.FSR_Score__c=100;
        cc2.IP_Score__c=100;
        cc2.Opportunity__c =opp.Id;
        cc2.Credit_Limit__c = 500000;
        cc2.Credit_Check_Outcome__c = 'Passed';
        cc2.Credit_Premium_Type__c ='S2';
       // cc2.Credit_Rank_Formula__c='S2';
        insert cc2;
        System.debug('109cc2-->'+cc2);
        
        Credit_Check__c cc3 = new Credit_Check__c();
        cc3.Pricing_Request__c = pr.Id;
        cc3.Customer__c = CusAcc.id;
        cc3.Status__c = 'Active';
        cc3.FSR_Score__c=90;
        cc3.IP_Score__c=90;
        cc3.Opportunity__c =opp.Id;
        cc3.Credit_Limit__c = 50000;
        cc3.Credit_Check_Outcome__c = 'Refer';
        cc3.Credit_Premium_Type__c ='S7';
       // cc2.Credit_Rank_Formula__c='S2';
        insert cc3;
        
         Credit_Check__c cc4 = new Credit_Check__c();
        cc4.Pricing_Request__c = pr.Id;
        cc4.Customer__c = CusAcc.id;
        cc4.Status__c = 'Active';
        cc4.FSR_Score__c=90;
        cc4.IP_Score__c=90;
        cc4.Opportunity__c =opp.Id;
        cc4.Credit_Limit__c = 50000;
        cc4.Credit_Check_Outcome__c = 'Refer';
        cc4.Credit_Premium_Type__c ='S1';
       // cc2.Credit_Rank_Formula__c='S2';
        insert cc4;
        
        List<Price__c> prlst1 = new List<Price__c>();
        Price__c price1 = new Price__c();
        price1.Credit__c = true;
    //    price1.Term_Prices__r.Credit_Premium__c = 0;
        price1.P_D__c = true;
        price1.Subject_to_Credit__c = true;
        price1.Pricing_Request__c = pr.Id;
        price1.Notes__c='Hello';
        price1.Product_Lookup__c = prodObj.Id;
        price1.Bill_Type__c = 'Dual';
        price1.Invoice_Billing_Type__c='Summary Billing';
        price1.Treatment__c='Fixed';
        price1.Voluntary_RECs__c= 'Any';
        price1.Voluntary_RECs_percent__c = 100;
        price1.Opportunity__c = opp.Id;
        price1.Credit_Detail__c =cc1.Id;
        prlst1.add(price1);
        insert prlst1;
        
        List<Price__c> prlst2 = new List<Price__c>();
        Price__c price2 = new Price__c();
        price2.Credit__c = true;
     //   price2.Term_Prices__r.Credit_Premium__c = 0;
        price2.P_D__c = true;
        price2.Subject_to_Credit__c = true;
        price2.Pricing_Request__c = pr.Id;
        price2.Notes__c='Hello';
        price2.Product_Lookup__c = prodObj.Id;
        price2.Bill_Type__c = 'Dual';
        price2.Invoice_Billing_Type__c='Summary Billing';
        price2.Treatment__c='Fixed';
        price2.Voluntary_RECs__c= 'Any';
        price2.Voluntary_RECs_percent__c = 100;
        price2.Opportunity__c = opp.Id;
        price2.Credit_Detail__c =cc2.Id;
        prlst2.add(price2);
        insert prlst2;
        
        List<Price__c> prlst3 = new List<Price__c>();
        Price__c price3 = new Price__c();
        price3.Credit__c = true;
        price3.P_D__c = true;
        price3.Subject_to_Credit__c = true;
        price3.Pricing_Request__c = pr.Id;
        price3.Notes__c='Hello';
        price3.Product_Lookup__c = prodObj.Id;
        price3.Bill_Type__c = 'Dual';
        price3.Invoice_Billing_Type__c='Summary Billing';
        price3.Treatment__c='Fixed';
        price3.Voluntary_RECs__c= 'Any';
        price3.Voluntary_RECs_percent__c = 100;
        price3.Opportunity__c = opp.Id;
        price3.Credit_Detail__c =cc.Id;
        prlst3.add(price3);
        insert price3;
        
        List<Price__c> prlst4 = new List<Price__c>();
        Price__c price4 = new Price__c();
        price4.Credit__c = false;
        price4.P_D__c = true;
        price4.Subject_to_Credit__c = true;
        price4.Pricing_Request__c = pr.Id;
        price4.Notes__c='Hello';
        price4.Product_Lookup__c = prodObj.Id;
        price4.Bill_Type__c = 'Dual';
        price4.Invoice_Billing_Type__c='Summary Billing';
        price4.Treatment__c='Fixed';
        price4.Voluntary_RECs__c= 'Any';
        price4.Voluntary_RECs_percent__c = 100;
        price4.Opportunity__c = opp.Id;
        price4.Credit_Detail__c =cc3.Id;
        prlst4.add(price4);
        insert prlst4;
        
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
        

        Utility_Account__c ua = new Utility_Account__c();
        ua.Name = '1234567891';
        ua.Account__c = acc1.Id;
        ua.Utility__c = acc2.Id;
        ua.Street__c ='street 43';
        ua.City__c ='Test';
        ua.State__c = 'NY';
        ua.zip__c ='343438';
        ua.Country__c = 'US';
        //ua.Service_Address__c = '';
        ua.Zone__c = 'E';
        insert ua;
        
        Utility_Account_Opportunity__c uao = new Utility_Account_Opportunity__c();
        uao.Opportunity__c = opp.Id;
        uao.Utility_Account__c = ua1.Id;
        uao.Start_Date__c = myDate;
        uao.Status__c = 'Priced';
        insert uao;
        
        List<Id> accIds = new List<Id>();
        accIds.add(CusAcc.Id);
        
        List<Term_Price__c> tp = new List<Term_price__c>();
        for(Integer i=0; i<36;i++){
            Term_Price__c tp1 = new Term_Price__c();
            tp1.Price__c = price1.Id;
            tp1.Cumulative_Volume__c = 2500;
            tp1.Base_Price__c = 1.555;
            tp1.Term__c = string.valueOf(i +1);
            tp1.Credit_Premium__c = 0;
            tp1.Utility__c = acc1.Id;
            tp1.Volume__c = 5;
            tp1.Utility_Account_Opportunity__c = uao.Id;
            tp1.Opportunity__c = opp.Id;
            tp.add(tp1);
        }
        insert tp;
        
        List<Term_Price__c> tp1 = new List<Term_price__c>();
        for(Integer i=0; i<36;i++){
            Term_Price__c tp2 = new Term_Price__c();
            tp2.Price__c = price2.Id;
            tp2.Cumulative_Volume__c = 2500;
            tp2.Base_Price__c = 1.555;
            tp2.Term__c = string.valueOf(i +1);
            tp2.Utility__c = acc2.Id;
            tp2.Credit_Premium__c = 0;
            tp2.Volume__c = 5;
            tp2.Utility_Account_Opportunity__c = uao.Id;
            tp2.Opportunity__c = opp.Id;
            tp1.add(tp2);
        }
        insert tp1;
        
         List<Term_Price__c> tp2= new List<Term_price__c>();
        for(Integer i=0; i<36;i++){
            Term_Price__c tp3 = new Term_Price__c();
            tp3.Price__c = price3.Id;
            tp3.Cumulative_Volume__c = 2500;
            tp3.Base_Price__c = 1.555;
            tp3.Term__c = string.valueOf(i +1);
            tp3.Utility__c = acc2.Id;
            tp3.Credit_Premium__c = 0;
            tp3.Volume__c = 5;
            tp3.Utility_Account_Opportunity__c = uao.Id;
            tp3.Opportunity__c = opp.Id;
            tp2.add(tp3);
        }
        insert tp2;
        
        creditRiskProcess.dataWrap dw = new creditRiskProcess.dataWrap();
        dw.datEWrap1 = 'Test';
        dw.datEWrap2 = 'Test';
        dw.datEWrap3 = 'Test';
        dw.datEWrap4 = 'Test';
        dw.datEWrap5 = 'Test';
        dw.datEWrap6 = 'Test';
        dw.datEWrap7 = 'Test';
        dw.datEWrap8 = 'Test';
        dw.datEWrap9 = 'Test';
       dw.datEWrap10 = 'Test';
        dw.datEWrap11 = 'Test';
        dw.datEWrap12 = 'Test';
        dw.datEWrap13 = 'Test';
        dw.datEWrap14 = 'Test';
        dw.datEWrap15 = 'Test';
        dw.datEWrap16 = 'Test';
        dw.datEWrap17 = 'Test';
        dw.datEWrap18 = 'Test';
        dw.datEWrap19 = 'Test';
        dw.datEWrap20 = 'Test';
        dw.datEWrap21 = 'Test';
        dw.datEWrap22 = 'Test';

        //creditRiskProcess.DataWrapper dataWrapObj = new creditRiskProcess.DataWrapper();
       List<creditRiskProcess.DataWrapper> lstdataWrapObj = new List<creditRiskProcess.DataWrapper>();
        creditRiskProcess.DataWrapper dataWrapObj = new creditRiskProcess.DataWrapper();
       dataWrapObj.recordID = cc.Id;
       dataWrapObj.fromPB = true;
        lstdataWrapObj.add(dataWrapObj);
        
        test.startTest();
        creditRiskProcess.InvokeCreditRiskProcess(lstdataWrapObj);
        creditRiskProcess.process(cc.Id);
        creditRiskProcess.process(cc1.Id);
        creditRiskProcess.process(cc2.Id);
        creditRiskProcess.process(cc3.Id);
         creditRiskProcess.process(cc4.Id);
     /*   price.Credit__c = false;
        update price;
        
        creditRiskProcess.process(cc.Id);
        creditRiskProcess.process(cc1.Id);
        creditRiskProcess.process(cc2.Id);
        creditRiskProcess.clonePriceRecord(price1.Id,false,1);
        creditRiskProcess.clonePriceRecord(price.Id,true,1);
        creditRiskProcess.clonePriceRecord(price2.Id,false,1);*/
        test.stopTest();
        
    }
	
    @isTest
    public static void sendOnceFalse(){
        Marketer__c getMarketer = new Marketer__c(name = 'xyz', MarketerDunsNumber__c = 'ten');
        Insert getMarketer;
        HU_Api_Call__c huObj = new HU_Api_Call__c();
        huObj.Call_AWS__c = false;
        huObj.Call_Azure__c = false;
        insert huObj;
        Account acc1= new Account();
        acc1.Name = 'Test Acc';
        insert acc1;
        
        Id id1 = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Utility').getRecordTypeId();
        Account acc2= new Account();
        acc2.Name = 'Test Acc1';
        acc2.RecordTypeId =id1;
        //acc2.Utility_Account_Number_Prefix__c  = 'TST';
        insert acc2;
        
        Id recordTypeCus = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Customer').getRecordTypeId();
        Account CusAcc= new Account();
        CusAcc.Name = 'Test Acc1';
        CusAcc.RecordTypeId =recordTypeCus;
        CusAcc.Customer_Credit_Limit__c = 7500;
        CusAcc.Customer_Credit_Annual_Volume__c =600000;
        insert CusAcc;
        
        Contact con = new Contact();
        con.FirstName = 'Con First';
        con.LastName = 'Test Last';
        con.AccountId = acc2.Id;
        insert con;
        
        acc2.Primary_Contact__c = con.Id;
        update acc2;
        
        Contract objCon = new Contract();
        objCon.ContractTerm = 4;
        objCon.StartDate = system.today().addMonths(-1);
        objCon.AccountId = acc1.Id;
        //objCon.Status = 'Draft';
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
        insert opp;
        
        Product2 prodObj = new Product2(Name='Fully Fixed',ProductCode = '0',Product_Id__c = '0');
        insert prodObj;
        
        Pricing_Request__c pr = new Pricing_Request__c();
        pr.Opportunity__c = opp.Id;
        pr.Notes__c = 'Hello';
        pr.Status__c = 'Complete';
        pr.Bill_Type__c = 'Dual';
        pr.Product_Lookup__c = prodObj.Id;
        pr.Customer__c = CusAcc.id;
        pr.Voluntary_RECs__c = 'Any';
        pr.Voluntary_RECs_percent__c = 100;
        pr.Record_Created__c = true;
        insert pr;
        
        Credit_Check__c cc = new Credit_Check__c();
        cc.Pricing_Request__c = pr.Id;
        cc.Customer__c = CusAcc.id;
        cc.Status__c = 'Active';
        cc.FSR_Score__c=10;
        cc.Credit_Limit__c = 500000;
        cc.IP_Score__c=6;
        cc.Opportunity__c =opp.Id;
        cc.Credit_Limit__c = 7500;
        cc.FSR_Score__c=70;
        cc.IP_Score__c=0;
        cc.Credit_Check_Outcome__c = 'Passed';
        cc.Credit_Premium_Type__c ='S2';
        insert cc;
        
        Credit_Check__c cc1 = new Credit_Check__c();
        cc1.Pricing_Request__c = pr.Id;
        cc1.Customer__c = CusAcc.id;
        cc1.Status__c = 'Active';
        cc1.FSR_Score__c=10;
        cc1.IP_Score__c=6;
        cc1.FSR_Score__c=70;
        cc1.IP_Score__c=0;
        cc1.Credit_Limit__c = 500000;
        cc1.Opportunity__c =opp.Id;
        cc1.Credit_Limit__c = 7500;
        cc1.Credit_Check_Outcome__c = 'Passed';
        cc1.Credit_Premium_Type__c ='s1';
        cc1.Custom_Credit_Premium__c=1000;
        insert cc1;
        
        Credit_Check__c cc2 = new Credit_Check__c();
        cc2.Pricing_Request__c = pr.Id;
        cc2.Customer__c = CusAcc.id;
        cc2.Status__c = 'Active';
        cc2.FSR_Score__c=100;
        cc.FSR_Score__c=60;
        cc.IP_Score__c=10;
        cc2.IP_Score__c=100;
        cc2.Opportunity__c =opp.Id;
        cc2.Credit_Limit__c = 500000;
        cc2.Credit_Check_Outcome__c = 'Passed';
        cc2.Credit_Premium_Type__c ='S3';
        insert cc2;
        System.debug('109cc2-->'+cc2);
        
        List<Price__c> prlst1 = new List<Price__c>();
        Price__c price1 = new Price__c();
        price1.Credit__c = true;
        //    price1.Term_Prices__r.Credit_Premium__c = 0;
        price1.P_D__c = true;
        price1.Subject_to_Credit__c = true;
        price1.Pricing_Request__c = pr.Id;
        price1.Notes__c='Hello';
        price1.Product_Lookup__c = prodObj.Id;
        price1.Bill_Type__c = 'Dual';
        price1.Invoice_Billing_Type__c='Summary Billing';
        price1.Treatment__c='Fixed';
        price1.Voluntary_RECs__c= 'Any';
        price1.Voluntary_RECs_percent__c = 100;
        price1.Opportunity__c = opp.Id;
        price1.Credit_Detail__c =cc1.Id;
        prlst1.add(price1);
        insert prlst1;
        
        List<Price__c> prlst2 = new List<Price__c>();
        Price__c price2 = new Price__c();
        price2.Credit__c = true;
        //   price2.Term_Prices__r.Credit_Premium__c = 0;
        price2.P_D__c = true;
        price2.Subject_to_Credit__c = true;
        price2.Pricing_Request__c = pr.Id;
        price2.Notes__c='Hello';
        price2.Product_Lookup__c = prodObj.Id;
        price2.Bill_Type__c = 'Dual';
        price2.Invoice_Billing_Type__c='Summary Billing';
        price2.Treatment__c='Fixed';
        price2.Voluntary_RECs__c= 'Any';
        price2.Voluntary_RECs_percent__c = 100;
        price2.Opportunity__c = opp.Id;
        price2.Credit_Detail__c =cc2.Id;
        prlst2.add(price2);
        insert prlst2;
        
        List<Price__c> prlst3 = new List<Price__c>();
        Price__c price3 = new Price__c();
        price3.Credit__c = true;
        price3.P_D__c = true;
        price3.Subject_to_Credit__c = true;
        price3.Pricing_Request__c = pr.Id;
        price3.Notes__c='Hello';
        price3.Product_Lookup__c = prodObj.Id;
        price3.Bill_Type__c = 'Dual';
        price3.Invoice_Billing_Type__c='Summary Billing';
        price3.Treatment__c='Fixed';
        price3.Voluntary_RECs__c= 'Any';
        price3.Voluntary_RECs_percent__c = 100;
        price3.Opportunity__c = opp.Id;
        price3.Credit_Detail__c =cc.Id;
        prlst3.add(price3);
        insert price3;
        
        Datetime date1 = Datetime.now().addDays(-1);
        Test.setCreatedDate(price1.Id, date1);  
        
        Datetime date2 = Datetime.now().addDays(-1);
        Test.setCreatedDate(price2.Id, date1);  
        
        Datetime date3 = Datetime.now().addDays(-1);
        Test.setCreatedDate(price3.Id, date1);  
        
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
        
        
        Utility_Account__c ua = new Utility_Account__c();
        ua.Name = '1234567891';
        ua.Account__c = acc1.Id;
        ua.Utility__c = acc2.Id;
        ua.Street__c ='street 43';
        ua.City__c ='Test';
        ua.State__c = 'NY';
        ua.zip__c ='343438';
        ua.Country__c = 'US';
        //ua.Service_Address__c = '';
        ua.Zone__c = 'E';
        insert ua;
        
        Utility_Account_Opportunity__c uao = new Utility_Account_Opportunity__c();
        uao.Opportunity__c = opp.Id;
        uao.Utility_Account__c = ua1.Id;
        uao.Start_Date__c = myDate;
        uao.Status__c = 'Priced';
        insert uao;
        
        List<Id> accIds = new List<Id>();
        accIds.add(CusAcc.Id);
        
        List<Term_Price__c> tp = new List<Term_price__c>();
        for(Integer i=0; i<36;i++){
            Term_Price__c tp1 = new Term_Price__c();
            tp1.Price__c = price1.Id;
            tp1.Cumulative_Volume__c = 2500;
            tp1.Base_Price__c = 1.555;
            tp1.Term__c = string.valueOf(i +1);
            tp1.Credit_Premium__c = 0;
            tp1.Utility__c = acc1.Id;
            tp1.Volume__c = 5;
            tp1.Utility_Account_Opportunity__c = uao.Id;
            tp1.Opportunity__c = opp.Id;
            tp.add(tp1);
        }
        insert tp;
        
        List<Term_Price__c> tp1 = new List<Term_price__c>();
        for(Integer i=0; i<36;i++){
            Term_Price__c tp2 = new Term_Price__c();
            tp2.Price__c = price2.Id;
            tp2.Cumulative_Volume__c = 2500;
            tp2.Base_Price__c = 1.555;
            tp2.Term__c = string.valueOf(i +1);
            tp2.Utility__c = acc2.Id;
            tp2.Credit_Premium__c = 0;
            tp2.Volume__c = 5;
            tp2.Utility_Account_Opportunity__c = uao.Id;
            tp2.Opportunity__c = opp.Id;
            tp1.add(tp2);
        }
        insert tp1;
        
        List<Term_Price__c> tp2= new List<Term_price__c>();
        for(Integer i=0; i<36;i++){
            Term_Price__c tp3 = new Term_Price__c();
            tp3.Price__c = price3.Id;
            tp3.Cumulative_Volume__c = 2500;
            tp3.Base_Price__c = 1.555;
            tp3.Term__c = string.valueOf(i +1);
            tp3.Utility__c = acc2.Id;
            tp3.Credit_Premium__c = 0;
            tp3.Volume__c = 5;
            tp3.Utility_Account_Opportunity__c = uao.Id;
            tp3.Opportunity__c = opp.Id;
            tp2.add(tp3);
        }
        insert tp2;
        
        List<creditRiskProcess.DataWrapper> lstdataWrapObj = new List<creditRiskProcess.DataWrapper>();
        creditRiskProcess.DataWrapper dataWrapObj = new creditRiskProcess.DataWrapper();
        dataWrapObj.recordID = cc.Id;
        dataWrapObj.fromPB = true;
        lstdataWrapObj.add(dataWrapObj);
        
        test.startTest();
        creditRiskProcess.process(cc.Id);
        creditRiskProcess.process(cc1.Id);
        creditRiskProcess.process(cc2.Id);
        test.stopTest();
    }
}