public class contractTermination {
    
    
    @AuraEnabled
    public static string insertData(Blob strfromlex,Id recordId, String FileName){
        Try{
            String fileData =strfromlex.toString();
            List<String> csvFileLines = new List<String>(fileData.split('\n'));
            List<String> inputvalues = new List<String>();
            Map<String,Utility_Account_Contract__c> uaNameAndUacMap = new Map<String,Utility_Account_Contract__c>();
            List<Utility_Account_Contract__c> UACLstToUpdate = new List<Utility_Account_Contract__c>();
            List<Utility_Account_Contract__c> UACLst = new List<Utility_Account_Contract__c>();
            List<Utility_Account_Contract__c> UACLstToCheck = new List<Utility_Account_Contract__c>();
            String errorMsg = '';
            
            Contract contractObj = [SELECT Id, Status FROM Contract WHERE Id =: recordId];
            if(contractObj.Status == 'Pending_Live' || contractObj.Status == 'Live'){
                UACLst = [SELECT Id,
                          Name,
                          Utility_Account__r.Name,
                          Utility_Account__r.Status__c,
                          Damage_Fee__c,
                          Invoice_Payment__c, 
                          Status__c
                          FROM Utility_Account_Contract__c
                          WHERE Contract__c =: recordId];
                
                for(Utility_Account_Contract__c uac : UACLst ){
                    uaNameAndUacMap.put(uac.Utility_Account__r.Name,uac);
                }
                
                for(Integer i=1, j=csvFileLines.size(); i<j; i++ ){
                    inputvalues = Base_Class_Uploader.columns_Splitter(csvFileLines[i]);
                    System.debug('-->'+uaNameAndUacMap.get(inputvalues[0]).Status__c);
                    if(uaNameAndUacMap.get(inputvalues[0]).Utility_Account__r.Status__c != 'DACC'){
                        errorMsg = 'Utility Account not in Drop Accepted stage.';
                    }
                    
                    if(uaNameAndUacMap.get(inputvalues[0]).Status__c != 'Contracted'){
                        errorMsg = 'Utility Account Contracts are not Contracted';
                    }
                    
                    uaNameAndUacMap.get(inputvalues[0]).Status__c = 'Terminated';
                    uaNameAndUacMap.get(inputvalues[0]).Damage_Fee__c = Decimal.valueOf(inputvalues[1]);
                    uaNameAndUacMap.get(inputvalues[0]).Invoice_Payment__c = inputvalues[2];
                    
                    UACLstToUpdate.add(uaNameAndUacMap.get(inputvalues[0]));
                }
            }
            else{
                errorMsg = 'Contract is Expired.';
            }
            
            if(errorMsg == ''){
                update UACLstToUpdate;
                
				UACLstToCheck = [SELECT Id,
                          Name,
                          Utility_Account__r.Name,
                          Utility_Account__r.Status__c,
                          Damage_Fee__c,
                          Invoice_Payment__c, 
                          Status__c
                          FROM Utility_Account_Contract__c
                          WHERE Contract__c =: recordId AND Status__c = 'Terminated'];
                
                if(UACLst.size() == UACLstToCheck.size()){
                    contractObj.Status = 'Terminated';
                }
                update contractObj;
                
                Contact con = [SELECT Id,Email FROM Contact WHERE Name = 'Pricing Team'];
                
                List<EmailTemplate> lstEmailTemplates = [SELECT Id, Body, Subject from EmailTemplate where DeveloperName = 'Contract_Termination'];
                
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setTemplateId(lstEmailTemplates[0].Id);
                mail.setSaveAsActivity(false);
                mail.setTargetObjectId(con.Id);// Any contact or User id of your record
                mail.setToAddresses(new list<string>{con.Email});
                mail.setSaveAsActivity(true);
                mail.setWhatId(contractObj.id); // Enter your record Id whose merge field you want to add in template
                Messaging.SendEmailResult[] resultMail = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                
                
                
            }
            return errorMsg;
        }Catch(Exception e){
            return e.getMessage();
        }
    }
    
}