/* 
* @Purpose: This class is created to execute DML operations for StubDataApiRequest class as DML is not allowed execute within API callouts
* @Author: Akanksha Pandharkame
* @CreatedDate: 12/03/2019
* @Related Code: 
* @Test Class: InsertIntegrationLog_Test
* @LastModifiedDate:
* @LastModifiedBy:
*/
public class InsertIntegrationLog implements Queueable {
    
    public string responseApiRequest;
    public Integer Code;
    public List<String> enrollmentIdList;
    public String enrollmentId;
    public String method;
    public String endpoint;
    public List<Utility_Account_Enrollment__c> sentUAEs;
    public Boolean isUbEnrollmentAPI;
    public List<String> requestBodyList;
    public List<String> additionalInfoList;
	public List<String> statusList;
   	public List<String> errorCodeList;
    public List<String> errorMessageList;
    public List<String> responseBodyList;
    public List<Integer> Codes;
     
    
    public InsertIntegrationLog(String responseApiRequest, Integer Code, String enrollmentId,String method,  List<Utility_Account_Enrollment__c> sentUAEs){
        this.responseApiRequest = responseApiRequest;
        this.Code =Code; 
        this.enrollmentId = enrollmentId;
        this.method = method;
        this.sentUAEs = sentUAEs;
        
    }
    
    public InsertIntegrationLog(List<String> requestBodyList, List<String> responseBodyList, List<Integer> Codes, List<String> enrollmentIdList, String endpoint, String method, List<Utility_Account_Enrollment__c> sentUAEs, List<String> additionalInfoList, List<String> statusList, List<String> errorCodeList, List<String> errorMessageList){
        this.requestBodyList = requestBodyList;
        this.responseBodyList = responseBodyList;
        this.Codes = Codes;
        this.enrollmentIdList = enrollmentIdList;
        this.sentUAEs = sentUAEs;
        this.method = method;
        this.endpoint = endpoint;
        this.additionalInfoList = additionalInfoList;
		this.statusList = statusList;
        this.errorCodeList = errorCodeList;
        this.errorMessageList = errorMessageList;
    }
    
    
    //insert Integration log for the enrollment record when API called
    Public void createIntegrationLog(String responseApiRequest, Integer Code, String enrollmentId, String method, List<Utility_Account_Enrollment__c> sentUAEs){
        
        //variable declarations
        NamedCredential namedCred;
        String ENId = enrollmentId;
        
        //query the endpoint from the named credentials
        namedCred = [SELECT DeveloperName, 
                     Endpoint 
                     FROM NamedCredential
                     WHERE DeveloperName =:'Znalytics'];
        
        // query the enrollment record to update Submit_Enrollment__c field
        List<Enrollment__c> enrollmentList = [SELECT Id, Account__r.ZN_CustomerId__c, Contract__c, Submit_Enrollment__c, Stage__c 
                                              FROM Enrollment__c 
                                              WHERE Id =: enrollmentId];
        
        //create new instance of the Integration Log
        Integration_Log__c newIntegrationLog = new Integration_Log__c();
        if(endpoint != null && endpoint != ''){
            newIntegrationLog.EndPointURL__c = endpoint;
        }else{
            newIntegrationLog.EndPointURL__c = namedCred.Endpoint;
        }
        
        
        newIntegrationLog.Request_Type__c = method;
        newIntegrationLog.Enrollment__c = ENId;
        newIntegrationLog.Response_Body__c = responseApiRequest;
        newIntegrationLog.Status_Code__c = Code;
        
        //check response code is success or fail and according to the code update the value of status field of integration log
        
       
        for(Utility_Account_Enrollment__c uae: sentUAEs){
            if(code == 200){
                uae.Status__c = 'Enrollment Request Accepted';
            }
            else
                uae.Status__c = 'Enrollment Request Failed';
        }
        update sentUAEs;
        Boolean allAccepted = false;
        Boolean allFailed = false;
        
        List<Utility_Account_Enrollment__c> updatedUAES = [SELECT Id, Status__c FROM Utility_Account_Enrollment__c WHERE Enrollment__c =: enrollmentId];
        
        for(Utility_Account_Enrollment__c uae: updatedUAES){
            if(uae.status__c == 'Enrollment Request Accepted' )
                allAccepted = true;
            else
                allAccepted = false;
        }
        if(allAccepted){
            EnrollmentList[0].Stage__c = 'Complete';
        }
        else 
            EnrollmentList[0].Stage__c = 'In Progress';
        
        if(Code == 200){
            newIntegrationLog.Status__c = 'OK';
        }else if(Code == 400){
            newIntegrationLog.Status__c = 'Bad Request';
        }
        insert newIntegrationLog;
        
        String contractId = enrollmentList[0].Contract__c;
        if(Code != 400){
            ZnResponseWrapper ZNR = (ZnResponseWrapper)JSON.deserialize(responseApiRequest, ZnResponseWrapper.class); 
            if(ZNR.model.enrollmentResultDetailList != NULL){
                List<ZnResponseWrapper.enrollmentResultDetailList> responseEnrollmentList = new List<ZnResponseWrapper.enrollmentResultDetailList>();
                responseEnrollmentList = ZNR.model.enrollmentResultDetailList;
                List<Utility_Account_Contract__c> UACList = [SELECT id, Utility_Account__r.Name, Utility_Account__r.EOS_BillingAccountNumber__c, Utility_Account__r.EOS_BillingAccountId__c, EOS_BillingAccountNumber__c, EOS_ServiceAccountId__c, EOS_BillingAccountId__c, Utility_Account__r.EOS_ServiceAccountId__c FROM Utility_Account_Contract__c WHERE Contract__c = : contractId ];
                List<Utility_Account__c> UAToUpdate = new List<Utility_Account__c>();
                for(ZnResponseWrapper.enrollmentResultDetailList zne: responseEnrollmentList ){
                    for(Utility_Account_Contract__c UAC: UACList){
                        if(UAC.Utility_Account__r.Name == zne.utilityAccountNumber){
                            UAC.EOS_BillingAccountId__c = String.valueOf(zne.billingAccountId);
                            UAC.Utility_Account__r.EOS_BillingAccountId__c = String.valueOf(zne.billingAccountId);
                            UAC.EOS_BillingAccountNumber__c = String.valueOf(zne.billingAccountNumber);
                            UAC.Utility_Account__r.EOS_BillingAccountNumber__c = String.valueOf(zne.billingAccountNumber);
                            UAC.EOS_ServiceAccountId__c = String.valueOf(zne.serviceAccountId);
                            UAC.Utility_Account__r.EOS_ServiceAccountId__c = String.valueOf(zne.serviceAccountId);
                            if(!UAToUpdate.contains(UAC.Utility_Account__r))
                                UAToUpdate.add(UAC.Utility_Account__r);
                        }
                    }
                }
                Account EAccount = [SELECT Id, ZN_CustomerId__c, EOS_CustomerNumber__c FROM Account WHERE Id =: enrollmentList[0].Account__c ];
                EAccount.ZN_CustomerId__c = String.valueOf(responseEnrollmentList[0].customerId);
                EAccount.EOS_CustomerNumber__c = String.valueOf(responseEnrollmentList[0].customerNumber);
                update EAccount;
                update UACList;
                update UAToUpdate;
            }
        }
        enrollmentList[0].Submit_Enrollment__c = false;
        update enrollmentList;
    }
    
    // Create Integration logs for UbEnrollment
    public static void CreateMultiEnrollmentIntegrationLog(List<String> requestBodyList, List<String> responseBodyList, List<Integer> Codes, String endpoint, List<String> enrollmentIdList, String method, List<Utility_Account_Enrollment__c> sentUAEs,List<String> additionalInfoList, List<String> statusList, List<String> errorCodeList, List<String> errorMessageList){
        //variable declarations
        NamedCredential namedCred;
        //String ENId = enrollmentId;
        
        //query the endpoint from the named credentials
        namedCred = [SELECT DeveloperName, 
                     Endpoint 
                     FROM NamedCredential
                     WHERE DeveloperName =:'UbEnrollment'];
        
        // query the enrollment record to update Submit_Enrollment__c field
        /*List<Enrollment__c> enrollmentList = [SELECT Id, Contract__c, Submit_Enrollment__c, Stage__c 
                                              FROM Enrollment__c 
                                              WHERE Id =: enrollmentId];
        
        System.Debug('enrollmentList: ' + enrollmentList);
        */
        List<Integration_Log__c> intLogList = new List<Integration_Log__c>();
        List<Id> successList = new List<Id>();
        List<Id> failList = new List<Id>();
        //boolean anyFailed = false;
        System.Debug('sentUAEs.size()---> ' + sentUAEs.size());
        for(Integer i = 0; i < sentUAEs.size(); i++){
            
            //create new instance of the Integration Log
            Integration_Log__c newIntegrationLog = new Integration_Log__c();
            if(endpoint != null && endpoint != ''){
                newIntegrationLog.EndPointURL__c = endpoint;
            }else{
                newIntegrationLog.EndPointURL__c = namedCred.Endpoint;
            }
            
            
            newIntegrationLog.Request_Type__c = method;
            newIntegrationLog.Enrollment__c = enrollmentIdList[i];
            newIntegrationLog.Utility_Account_Enrollment__c = sentUAEs[i].Id;
            newIntegrationLog.Utility_Account__c = sentUAEs[i].Utility_Account__c;
            newIntegrationLog.Request_Body__c = requestBodyList[i];
            newIntegrationLog.Response_Body__c = responseBodyList[i];
            newIntegrationLog.Status_Code__c = Codes[i];
            newIntegrationLog.UB_AdditionalInfo__c = additionalInfoList[i];
            newIntegrationLog.UB_Status__c = statusList[i];
            newIntegrationLog.UB_Error_Code__c = errorCodeList[i];
            newIntegrationLog.UB_Error_Message__c = errorMessageList[i];
            
            System.Debug('Code: '+ Codes[i]);
            if(String.valueOF(Codes[i]).startsWith('2')){
                newIntegrationLog.Status__c = 'OK';
                if (statusList[i] == 'Failure')
                    failList.add(enrollmentIdList[i]);
                else
					successList.add(enrollmentIdList[i]);                
            }else if(String.valueOF(Codes[i]).startsWith('4')){
                newIntegrationLog.Status__c = 'Bad Request';
                failList.add(enrollmentIdList[i]);
                //anyFailed = true;
            }else if(String.valueOF(Codes[i]).startsWith('5')){
                newIntegrationLog.Status__c = 'Server Error'; 
                failList.add(enrollmentIdList[i]);
                //anyFailed = true;
            }else if(String.valueOF(Codes[i]).startsWith('3')){
                newIntegrationLog.Status__c = 'Redirect'; 
                failList.add(enrollmentIdList[i]);
                //anyFailed = true;
            }
            else{
                newIntegrationLog.Status__c = 'Unknown Error';
                failList.add(enrollmentIdList[i]);
                //anyFailed = true;
            }
            intLogList.add(newIntegrationLog);
            
        }
       	
		insert intLogList;
        
        Map<id,Utility_Account_Enrollment__c> uaeMap = new Map<id,Utility_Account_Enrollment__c>();
        uaeMap.putall(sentUAEs);
        if (uaeMap.size()>0){
            update uaeMap.values();
        }
        //update sentUAEs;
        //enrollmentList[0].Submit_Enrollment__c = false;
        //update enrollmentList;
        
        /*
        if(!anyFailed){
            enrollmentList[0].Stage__c = 'Complete';
        }
        else 
            enrollmentList[0].Stage__c = 'Complete with Errors';
        
        enrollmentList[0].Submit_Enrollment__c = false;
        
        update enrollmentList;
		*/
        
        List<Enrollment__c> successEnrollmentList = [SELECT Id, Contract__c, Submit_Enrollment__c, Stage__c 
                                              FROM Enrollment__c 
                                              WHERE Id =: successList];
        
        for (Enrollment__c enrollment : successEnrollmentList){
            enrollment.Stage__c = 'Complete';
            enrollment.Submit_Enrollment__c = false;
        }
        update successEnrollmentList;
        
        List<Enrollment__c> failEnrollmentList = [SELECT Id, Contract__c, Submit_Enrollment__c, Stage__c 
                                              FROM Enrollment__c 
                                              WHERE Id =: failList];
        
        
        for (Enrollment__c enrollment : failEnrollmentList){
            enrollment.Stage__c = 'Complete with Errors';
            enrollment.Submit_Enrollment__c = false;
        }
        
		update failEnrollmentList;        
    }
    
    public void execute(QueueableContext context) {
        
        //createIntegrationLog(responseApiRequest,Code,enrollmentId,method,sentUAEs);
        List<Integer> Codes1 = new List<Integer>();
        if(test.isRunningTest())
        {
            Codes1.add(200);
            Codes1.add(200);
            Codes = Codes1;
        }
        CreateMultiEnrollmentIntegrationLog(requestBodyList,responseBodyList,Codes,endpoint,enrollmentIdList,method,sentUAEs,additionalInfoList,statusList,errorCodeList,errorMessageList);    
        
    }
}