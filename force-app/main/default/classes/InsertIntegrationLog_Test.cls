/* 
* @Purpose: Test Class for InsertIntegrationLog
* @Author: Akanksha Pandharkame
* @CreatedDate: 12/04/2019
* @Related Code: 
* @Test Class:
* @LastModifiedDate:
* @LastModifiedBy:
*/
@isTest
public class InsertIntegrationLog_Test {
    
    static testmethod void testIntegrationLog(){
        
        Account acc = new Account(NAme='test');
        Insert acc;
        
        Enrollment__c objEn = new Enrollment__c();
        objEn.Account__c = acc.Id;
        insert objEn;
        
        Account acc1 = new Account(NAme='test1');
        acc1.RecordTypeId = [SELECT Id, Name, DeveloperName FROM RecordType where DeveloperName = 'Utility'].Id;
        Insert acc1;
        
        Utility_Account__c uacc =new Utility_Account__c(Name= 'test2');
        uacc.Account__c = acc.Id;
        uacc.Utility__c = acc1.Id;
        insert uacc;
        
        
         
        Utility_Account_Enrollment__c objUAcc = new Utility_Account_Enrollment__c();
        objUAcc.Status__c = 'Enrollment Request Accepted';
        objUAcc.Enrollment__c =objEn.Id;
        objUAcc.Utility_Account__c = uacc.Id;
        insert objUAcc;
        
        List<Utility_Account_Enrollment__c> uaeList =[SELECT Id, Status__c,Utility_Account__c FROM Utility_Account_Enrollment__c WHERE Enrollment__c =:objEn.Id];
        String enId = objEn.Id;
        
        String response = '{"model":{"requestGuid":"b3ad8e43-be7e-4e1d-a190-81ec4651b109","isSucess":true,"enrollmentResultDetailList":[{"isSuccess":true,"customerId":398,"billingAccountId":434,"serviceAccountId":484,"customerProspectId":0,"billingAccountReferenceId":10001,"serviceAccountReferenceId":10001,"linkToBillingAccountNumber":"","enrollmentRequestDetailId":254,"customerNumber":"20-1000177","billingAccountNumber":"30-100000819","utilityAccountNumber":"1234567890"}],"enrollmentWarningList":null},"code":200,"messages":null}';
        
     /*   InsertIntegrationLog objIntLog = new InsertIntegrationLog(response, 200, enId, 'POST', uaeList);
         ID jobID = System.enqueueJob(objIntLog);
        
        InsertIntegrationLog objIntLog2 = new InsertIntegrationLog(response, 400, enId, 'POST', uaeList);
        ID jobID2 = System.enqueueJob(objIntLog2);*/
        
        List<String> lsrequestBody = new List<String>();
        lsrequestBody.add('test');
         lsrequestBody.add('test');
         lsrequestBody.add('test');
        List<String> lsresponseBody = new List<String>();
          lsresponseBody.add('test');
         lsresponseBody.add('test');
         lsresponseBody.add('test');
        List<Integer> lsCode = new List<Integer>();
        lscode.add(200);
        lscode.add(400);
        lscode.add(500);
        List<String> lsadditionalInfo = new List<String>();
        lsadditionalInfo.add('test');
        lsadditionalInfo.add('test');
        lsadditionalInfo.add('test');
        List<String> lsstatus = new List<String> ();
        lsstatus.add('test');
        lsstatus.add('test');
        lsstatus.add('test');
        List<String> lserrorCode = new List<String>();
        lserrorCode.add('test');
        lserrorCode.add('test');
        lserrorCode.add('test');
        List<String> lserrorMessage = new List<String>();
        lserrorMessage.add('test');
        lserrorMessage.add('test');
        lserrorMessage.add('test');
        
        List<String> enIdList = new List<String>();
        enIdList.add(enId);
        enIdList.add(enId);
        enIdList.add(enId);
 
 InsertIntegrationLog objIntLogList = new InsertIntegrationLog(lsrequestBody,lsresponseBody,lscode,enIdList,'test','POST',uaeList,lsadditionalInfo,lsstatus,lserrorCode,lserrorMessage);
        ID jobID3 = System.enqueueJob(objIntLogList);
        
InsertIntegrationLog.CreateMultiEnrollmentIntegrationLog(lsrequestBody,lsresponseBody,lscode,'test',enIdList,'POST',uaeList,lsadditionalInfo,lsstatus,lserrorCode,lserrorMessage);
     InsertIntegrationLog obj =new InsertIntegrationLog(response, 200,enId , 'POST', uaeList);
        obj.createIntegrationLog(response,200,enId,'POST', uaeList);
        
     /*  
       
        InsertIntegrationLog obj1 =new InsertIntegrationLog(response, 400,enId , 'POST', uaeList);
        obj1.createIntegrationLog(response,400,enId,'POST', uaeList);
        
       */ //objIntLogList1.CreateMultiEnrollmentIntegrationLog(lsrequestBody,lsresponseBody,lscode,enId,'test','POST',uaeList,lsadditionalInfo,lsstatus,lserrorCode,lserrorMessage);
         

     
    }
}