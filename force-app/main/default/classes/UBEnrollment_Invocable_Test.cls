@isTest
public class UBEnrollment_Invocable_Test {
    
    
    @isTest(seeAllData=true)
    public static void submitUbEnrollmentTestmethod(){
        String u = userInfo.getUserId();
        Account objAcc = new Account(Name = 'Account Test');
        objAcc.RecordTypeId = [SELECT Id, Name, DeveloperName FROM RecordType where DeveloperName = 'Utility'].Id;
        objAcc.Bill_Type__c= 'Dual';
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
        objUA.Status__c = 'Never Supplied';
        insert objUA;
        
        Contract objContract = new Contract();
        objContract.ContractTerm = 12;
        objContract.AccountId = objAcc.Id;
        objContract.Opportunity__c = objOpp.Id;
        insert objContract;
        
        Enrollment__c objEN = new Enrollment__c();
        objEN.Contract__c = objContract.Id;
        objEn.Account__c = objAcc.Id;
        insert objEN;
        
        Utility_Account_Enrollment__c objUAE = new Utility_Account_Enrollment__c();
        objUAE.Enrollment__c = objEN.Id;
        objUAE.Utility_Account__c = objUA.Id;
        objUAE.Start_Date__c = system.today();
        insert objUAE;
        
        List<Id> EnrollmentIDs= new List<Id>() ;
        EnrollmentIDs.add(objEN.ID);
        UBEnrollment_Invocable.submitUbEnrollment(EnrollmentIDs);
        
        
        
        //To cover CallUbRateClassServiceAPI class
        Utility_Account__c objUA1 = new Utility_Account__c();
        objUA1.Account__c = objAcc.Id;
        objUA1.Name = '1234567899';
        objUA1.Utility__c = objAcc.Id;
        objUA1.Street__c = 'Street';
        objUA1.City__c = 'City';
        objUA1.State__c = 'NY';
        objUA1.Country__c = 'US';
        objUA1.Zip__c = '123456';
        objUA1.Status__c = 'Active';
        insert objUA1;
        
        Enrollment__c objEN1 = new Enrollment__c();
		objEN.Contract__c = objContract.Id;
        objEn1.Account__c = objAcc.Id;
        insert objEN1;
        
        List<String> uaeList = new List<String>();
        
        Utility_Account_Enrollment__c objUAE1 = new Utility_Account_Enrollment__c();
        objUAE1.Enrollment__c = objEN1.Id;
        objUAE1.Utility_Account__c = objUA1.Id;
        objUAE1.Start_Date__c = system.today();
        uaeList.add(objUAE1.Id);
        insert objUAE1;
        
       // SubmitEnrollment_RenewalAPI.callRenewalEndpoint(objEN.Id,null);
        
        List<Id> EnrollmentIDs1= new List<Id>() ;
        EnrollmentIDs1.add(objEN1.ID);
        UBEnrollment_Invocable.submitUbEnrollment(EnrollmentIDs1);
        
        //Wrapper_UbEnrollmentResponse coverage
        String response = '<a:faultstring> </a:faultstring>';
        Wrapper_UbEnrollmentResponse wrap = new Wrapper_UbEnrollmentResponse(response,200,'Success','Test','Test');
        String response1 = '<a:AdditionalInfo> </a:AdditionalInfo>';
        Wrapper_UbEnrollmentResponse wrap1 = new Wrapper_UbEnrollmentResponse(response1,200,'Success','Test','Test');
        String response2 = '<a:ErrorCode> </a:ErrorCode>';
        Wrapper_UbEnrollmentResponse wrap2 = new Wrapper_UbEnrollmentResponse(response2,200,'Success','Test','Test');
        String response3 = '<a:ErrorMessage> </a:ErrorMessage>';
        Wrapper_UbEnrollmentResponse wrap3 = new Wrapper_UbEnrollmentResponse(response3,200,'Success','Test','Test');
        String response4 = '<a:Status> </a:Status>';
        Wrapper_UbEnrollmentResponse wrap4 = new Wrapper_UbEnrollmentResponse(response4,200,'Success','Test','Test');
        
        
        //Wrapper_UbEnrollment
        Wrapper_UbEnrollment.EnrollmentError ent = new Wrapper_UbEnrollment.EnrollmentError ();
        ent.AdditonalInfo= 'TEst';
        ent.ErrorCode = 400;
        ent.ErrorMessage = 'Failed';
        
        Wrapper_UbEnrollment.EnrollmentReturnTypeOfOperationStatus entStatus = new Wrapper_UbEnrollment.EnrollmentReturnTypeOfOperationStatus ();
        entStatus.AdditionalInfo= 'TEst';
        entStatus.ErrorCode = '400';
        entStatus.ErrorMessage = 'Failed';
        entStatus.Data = '400';
        entStatus.Status = 'Failed';
        //public Wrapper_UbEnrollment.ArrayOfEnrollmentDetails Data;
        Wrapper_UbEnrollment.EnrollmentReturnTypeOfArrayOfEnrollmentDetails entDetails = new Wrapper_UbEnrollment.EnrollmentReturnTypeOfArrayOfEnrollmentDetails ();
        entDetails.AdditionalInfo= 'TEst';
        entDetails.ErrorCode = '400';
        entDetails.ErrorMessage = 'Failed';
        entDetails.Status = 'Failed';
        
        Wrapper_UbEnrollment.EnrollmentDetails enrollDetails = new Wrapper_UbEnrollment.EnrollmentDetails();
        enrollDetails.BillCycleNextDate = DateTime.now();
        enrollDetails.BillCycleType = 1;
        enrollDetails.DisplayName = 'Test';
        enrollDetails.EnrollStatus = 'Test1';
        enrollDetails.EnrollmentCreateDate = DateTime.now();
        enrollDetails.EnrollmentSource = 'Test2';
        enrollDetails.GasSalesCommission = 20.5;
        enrollDetails.GasSalesCommission2 = 11.2;
        enrollDetails.GasSalesCommissionUOM = 'Test3';
        enrollDetails.GasSalesCommissionUOM2 = 'Test4';
        enrollDetails.InboundCustomerId = 5;
        enrollDetails.LocationdDisplayName = 'Test5';
        enrollDetails.PeakLoadCapacity = 25.4;
        enrollDetails.SecondaryAccountClass = 'Test6';
        enrollDetails.StatusMessage = 'Test7';
        enrollDetails.TransmissionEquivalent = 45.5;
        enrollDetails.UtilityName = '1545454';  
        
        
        Wrapper_UbEnrollment.FieldValuePairOfAdditionalFields fivePFil = new Wrapper_UbEnrollment.FieldValuePairOfAdditionalFields();
        fivePFil.FieldName = 'Test00';
        fivePFil.Value = 'Test11';    
        
        
        Wrapper_UbEnrollment.EnrollmentBase enrollBase = new Wrapper_UbEnrollment.EnrollmentBase();
        enrollBase.UtilizationModel = 5;
        enrollBase.UtilityRateCode = 'Te1';
        enrollBase.UtilityLoadProfile = 'Te2';
        enrollBase.UtilityDunsNumber = '4545454';
        enrollBase.UtilityDiscountIndicator = 'Te3';
        enrollBase.UtilityAccountNumber = '154565845';
        enrollBase.UnderUtilizationUsage = 15.55;
        enrollBase.UnderUtilizationUOM = 'Te4';
        enrollBase.UnderUtilizationAmount = 45.2;
        enrollBase.TrueUpCycle = 5;
        enrollBase.Template = true;
        enrollBase.TaxablePercentage = 15.25;
        enrollBase.TaxExemptStatusExpDate = DateTime.now();
        enrollBase.SvcZip = '44';
        enrollBase.SvcTaxablePercentage = 44.22;
        enrollBase.SvcTaxJurisdiction = 'Te5';
        enrollBase.SvcState = 'PA';
        enrollBase.SvcInfo5 = 'Te6';
        enrollBase.SvcInfo4 ='Te6';
        enrollBase.SvcInfo3 = 'Te6';
        enrollBase.SvcInfo2 = 'Te6';
        enrollBase.SvcInfo1 = 'Te6';
        enrollBase.SvcIncludeStateTax = true;
        
        SubmitEnrollment_RenewalAPI.RenewalWrapper renwrap = new SubmitEnrollment_RenewalAPI.RenewalWrapper();
        renwrap.contractTerm = 2;
        renwrap.contractSignedDate = 'Test';
        renwrap.renewalDateOptionCode = 'Test1';
        renwrap.saleDetails = 'Test2';
        renwrap.previousContractNumber = 'Test3';
        renwrap.documentUrl = 'test4';
        renwrap.customerNumber = '123145';
        
        Contract objCon = new Contract();
        objCon.ContractTerm = 4;
        objCon.StartDate = system.today().addMonths(-1);
        objCon.AccountId = objAcc.Id;
        //objCon.Status = 'Live';
        insert objCon;
        
        CallUbRateClassServiceAPI.callUBRenewal(objEN.Id,uaeList); 

        
        SubmitEnrollment_RenewalAPI.contractSegmentDetailList contDet = new SubmitEnrollment_RenewalAPI.contractSegmentDetailList();
		contDet.ContractSegmentDetailId = 5;
        contDet.rateAmount = 14.25;
       // Utility_Account_Enrollment__c uuae = [SELECT Id, Name FROM Utility_Account_Enrollment__c LIMIT 1];
       //String UAEString = '[{"attributes":{"type":"Utility_Account_Enrollment__c","url":"/services/data/v53.0/sobjects/Utility_Account_Enrollment__c/a1017000006C7ctAAC"},"Id":"a1017000006C7ctAAC","IsDeleted":false,"Name":"UAE-00000553","Enrollment__c":"a0z17000002G1zPAAS","Utility_Account__c":"a0J17000004It0tEAC","Rate_Schedule_Name__c":"test","Status__c":"Enrollment Request Pending","Bill_Type__c":"UtilityRateReady","Program_Code__c":"41/820","Start_Date__c":"2021-02-15","Hold_Reason_Code__c":"SCH","Hold_Transaction__c":true,"Effective_Date__c":"2021-01-05","Percentage__c":12,"Tax_Exempt_Certificate_Number__c":"10","Tax_Exempt_Code__c":"99","Tax_Exempt__c":true,"AutoSubmitFlag__c":false,"RateClass__c":"Custom Product","Category__c":"Undefined","Rate_Type__c":"Linked"}]';
       // String UAEString =  '[{"Name":"ABC","Tax_Exempt__c":"1312321","Bill_Type__c":"Enrollment Request Pending"}]';
       // SubmitEnrollment_RenewalAPI.callRenewalEndpoint(objEN.Id,UAEString);
        SubmitEnrollment_RenewalAPI.contractRateSchedule contsch = new SubmitEnrollment_RenewalAPI.contractRateSchedule();
		contsch.rateChangeEffectiveDate = String.valueOf(date.today());
        contsch.rateChangeScheduledDate = String.valueOf(date.today());
        contsch.rateScheduleName = 'Test';
        contsch.rolloverRateScheduleName = 'Test00';
        contsch.utilityRateCode = '10210';
        
        UB_RateClassService.AdditionalCharge add = new UB_RateClassService.AdditionalCharge();
        
        add.Amount='test';
        add.Assignment='test1';
        add.ChargeName='test2';
        add.ChargeType='test';
        add.Condition='test';
        add.Description='test';
        add.EnergyComponent=true;
        add.Taxable=true;
        
        UB_RateClassService.ArrayOfMCPEProfile mcp =new UB_RateClassService.ArrayOfMCPEProfile();
        mcp.MCPEProfile =null;
        
       UB_RateClassService.ArrayOfTier oft = new UB_RateClassService.ArrayOfTier();
        oft.Tier =null;
        
       UB_RateClassService.ArrayOfTDSPChargeProfile tdsp = new UB_RateClassService.ArrayOfTDSPChargeProfile();
        tdsp.TDSPChargeProfile =null;
        
        UB_RateClassService.ArrayOfBlock arr =new UB_RateClassService.ArrayOfBlock();
        arr.Block = null;
        
        UB_RateClassService.RateClassKey ate =new  UB_RateClassService.RateClassKey();
        ate.RateClassCode = 'test';
        ate.RateEffectiveDate = DateTime.now();

        UB_RateClassService.ArrayOfFieldValuePairOfTierFields filp =new UB_RateClassService.ArrayOfFieldValuePairOfTierFields();
        filp.FieldValuePairOfTierFields =null;
        
        UB_RateClassService.RateClass rate = new UB_RateClassService.RateClass();
        rate.Commodity ='test';
        rate.Description = 'test';
        rate.MarketerRateCode ='test';
        rate.RateClassCode ='test';
        rate.URRRateClass=true;
        
        UB_RateClassService.ReturnTypeOfArrayOfstring obj = new  UB_RateClassService.ReturnTypeOfArrayOfstring();
        obj.AdditionalInfo ='test';
            obj.ErrorCode='test';
            obj.ErrorMessage='test';
            obj.Status='test';
        
        UB_RateClassService.ArrayOfAdder add1 =new UB_RateClassService.ArrayOfAdder();
        add1.Adder=null;
        
        UB_RateClassService.ArrayOfFieldValuePairOfAdderFields fill =new UB_RateClassService.ArrayOfFieldValuePairOfAdderFields();
        fill.FieldValuePairOfAdderFields=null;
        
        
        UB_RateClassService.Tier tie = new UB_RateClassService.Tier();
        tie.BaseIndex='test';
        tie.BaseRate= 33.3;
        tie.Cap=22.1;
        tie.Floor=11.1;
        tie.RateType='test';
        tie.TierStart=23.3;
        
        UB_RateClassService.ArrayOfFieldValuePairOfAdditionalChargeFields obj1 =new  UB_RateClassService.ArrayOfFieldValuePairOfAdditionalChargeFields();
        obj1.FieldValuePairOfAdditionalChargeFields=null;
        
        UB_RateClassService.RateClassList ratec = new UB_RateClassService.RateClassList();
        ratec.ClassActive=true;
        ratec.Commodity='test';
        ratec.Description='test';
        ratec.MarketerRateCode='test';
        ratec.RateClassCode='test';
        ratec.RateSubType='test';
        ratec.RateType='test';
        ratec.URRRateClass=true;
        
        UB_RateClassService.ArrayOfFieldValuePairOfBlockFields pair = new UB_RateClassService.ArrayOfFieldValuePairOfBlockFields();
        pair.FieldValuePairOfBlockFields=null;
        
        UB_RateClassService.ArrayOfRateClassList ratecls=new UB_RateClassService.ArrayOfRateClassList();
        ratecls.RateClassList=null;
        
        UB_RateClassService.Adder ad =new UB_RateClassService.Adder();
        ad.AdderName='test';
        ad.AdderType='test';
        ad.Amount='test';
        ad.Condition='test';
        ad.TierOrBlockName='test';
        
        UB_RateClassService.ArrayOfFieldValuePairOfRateClassCommonFields ob =new UB_RateClassService.ArrayOfFieldValuePairOfRateClassCommonFields();
        ob.FieldValuePairOfRateClassCommonFields=null;
        
        UB_RateClassService.ArrayOfNetMeteredRate net = new  UB_RateClassService.ArrayOfNetMeteredRate();
        net.NetMeteredRate=null;
        
        UB_RateClassService.ArrayOfRateClassSchedule sc =new UB_RateClassService.ArrayOfRateClassSchedule();
        sc.RateClassSchedule=null;
        
        UB_RateClassService.ArrayOfFieldValuePairOfRateClassScheduleFields po =new UB_RateClassService.ArrayOfFieldValuePairOfRateClassScheduleFields();
        po.FieldValuePairOfRateClassScheduleFields=null;
        
        UB_RateClassService.Block bc =new UB_RateClassService.Block();
        bc.BlockName='test';
        bc.BlockQuantity=34;
        bc.BlockRate =32;
        bc.Cap=65;
        bc.Floor=90;
        bc.PeakCalendar='test';
        bc.SettlementIndex='test';
        
        UB_RateClassService.FieldValuePairOfBlockFields vc =new UB_RateClassService.FieldValuePairOfBlockFields();
        vc.FieldName='test';
        vc.Value ='test';
        
        UB_RateClassService.ArrayOfItemOfRateClassKey bx =new UB_RateClassService.ArrayOfItemOfRateClassKey();
        bx.ItemOfRateClassKey=null;
        
        UB_RateClassService.ReturnTypeOfArrayOfTDSPChargeProfile rt =new UB_RateClassService.ReturnTypeOfArrayOfTDSPChargeProfile();
        rt.AdditionalInfo ='test';
        rt.ErrorCode='test';
        rt.ErrorMessage='test';
        rt.Status='test';
        
        UB_RateClassService.NetMeteredRate me =new UB_RateClassService.NetMeteredRate();
        me.BaseIndex='test';
        me.BaseRate= 33.3;
        me.Cap=22.1;
        me.Floor=11.1;
        me.RateType='test';
        me.UsageType='test';
        
        UB_RateClassService.MCPEProfile np =new UB_RateClassService.MCPEProfile();
        np.Description='test';
        np.MCPEProfileName='test';
        np.MCPEProfileType='test';
        
          UB_RateClassService.RateClassIdentifier ra =new UB_RateClassService.RateClassIdentifier();
        ra.uaeId ='test';
        ra.Commodity='test';
        ra.MarketerAccountNumber='test';
        ra.MeterId=1234;
        ra.MeterNumber='test';
        ra.RateClassCode='test';
        ra.UtilityAccountNumber='test';
        
        UB_RateClassService.FieldValuePairOfAdderFields ds = new UB_RateClassService.FieldValuePairOfAdderFields();
        ds.FieldName='test';
        ds.Value='test';
        
        UB_RateClassService.FieldValuePairOfRateClassCommonFields qw =new UB_RateClassService.FieldValuePairOfRateClassCommonFields();
         qw.FieldName='test';
        qw.Value='test';
        
        UB_RateClassService.FieldValuePairOfSearchableFields sa =new UB_RateClassService.FieldValuePairOfSearchableFields();
         sa.FieldName='test';
        sa.Value='test';
        
        UB_RateClassService.ReturnTypeOfArrayOfIndexProfile obj3 =new UB_RateClassService.ReturnTypeOfArrayOfIndexProfile();
         obj3.AdditionalInfo ='test';
        obj3.ErrorCode='test';
        obj3.ErrorMessage='test';
        obj3.Status='test';
        
        UB_RateClassService.ReturnTypeOfArrayOfRateClassList obj4 =new  UB_RateClassService.ReturnTypeOfArrayOfRateClassList();
           obj4.AdditionalInfo ='test';
        obj4.ErrorCode='test';
        obj4.ErrorMessage='test';
        obj4.Status='test';  
        
        UB_RateClassService.ReturnTypeOfArrayOfRateClassSchedule obj5 =new UB_RateClassService.ReturnTypeOfArrayOfRateClassSchedule();
        obj5.AdditionalInfo ='test';
        obj5.ErrorCode='test';
        obj5.ErrorMessage='test';
        obj5.Status='test'; 
        
        UB_RateClassService_schemasArrays.ArrayOfstring obj6 =new UB_RateClassService_schemasArrays.ArrayOfstring();
        obj6.string_x =null;
        
        UbEnrollmentSerializat.ArrayOfstring obj7 =new UbEnrollmentSerializat.ArrayOfstring();
        obj7.string_x =null;
        
        UB_RateClassService.RateClassSchedule ratesc =new UB_RateClassService.RateClassSchedule();
	ratesc.Adder1 =12;
	ratesc.Adder1UOM='test';
	ratesc.Adder2=121;
	ratesc.Adder2UOM='test';
	ratesc.Adder3=98;
	ratesc.Adder3UOM='test';
        
        //CallUbRateClassServiceAPI.CreateNewRenewal(ra,ratesc,null);
        
       
    }
}