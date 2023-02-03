/* 
* @Purpose: This class is used to create Integration Log for Pricing Request (SU-829)
* @Author: Suhas P
* @CreatedDate: 21/04/2022
* @Related Code: 
* @Test Class: 
* @LastModifiedDate:
* @LastModifiedBy:
*/
public class InsertPricingReqIntegrationLog implements Queueable {
    
    public Integer Code;
    public String method;
    public String endpoint;
       //changes made by suhas
    public String prId; 
    public String scopeRequestBody;
    public String scopeResponseBody;
    public String status;
    
    //changes made by suhas for SU-829
    public InsertPricingReqIntegrationLog(String scopeRequestBody,String scopeResponseBody,Integer code,String prId, String endpoint, String method,String status){
        this.scopeRequestBody = scopeRequestBody;
        this.scopeResponseBody = scopeResponseBody;
        this.code =code;
        this.prId = prId;
        this.endpoint = endpoint;
        this.method = method;
        this.status = status;
    }
    
    //insert Integration log for the Pricing Request record when SCOPE API called
    Public void createIntegrationLogPR(String scopeRequestBody, String scopeResponseBody,Integer code,Id prId, String endpoint, String method,String status){
       
        //create new instance of the Integration Log
        system.debug('scopeRequestBody--'+scopeRequestBody);
        system.debug('scopeResponseBody--'+scopeResponseBody);
        Integration_Log__c newIntegrationLog = new Integration_Log__c();
        newIntegrationLog.Request_Type__c =method;
        newIntegrationLog.Request_Body__c = scopeRequestBody;
        newIntegrationLog.Response_Body__c = scopeResponseBody;
        newIntegrationLog.Status_Code__c = code;
        newIntegrationLog.Status__c = status;
        newIntegrationLog.Pricing_Request__c = prId;
        newIntegrationLog.EndPointURL__c = endpoint;
        insert newIntegrationLog;
        system.debug('newIntegrationLog--'+newIntegrationLog);
    }
        
     public void execute(QueueableContext context) {
   
         createIntegrationLogPR(scopeRequestBody,scopeResponseBody, code, prId, endpoint, method,status);
        //CreateMultiEnrollmentIntegrationLog(requestBodyList,responseBodyList,Codes,endpoint,enrollmentIdList,method,sentUAEs,additionalInfoList,statusList,errorCodeList,errorMessageList);    
        
    }
}