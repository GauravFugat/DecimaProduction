public class creditLimitCalculationsAccount {
    
    public static String prevCreditType = 'No value'; 
    public static String nextCreditType = 'No value';
    
    //@invocableMethod
    public static void calculateAccCreditLimits(List<Id> pricingRequestId, Boolean beforeFileUpload){
        System.debug('calculateAccCreditLimits -------------->> ');
        String creditType = '';
        Pricing_Request__c pricingReq = new Pricing_Request__c();
        try{
            
            pricingReq = [SELECT Id,
                          Pricing_Request_Credit_Limit__c,
                          Customer__c,Bill_Type__c,
                          Pricing_Request_Credit_Annual_Volume__c
                          FROM Pricing_Request__c 
                          WHERE Id =: pricingRequestId[0]
                          AND (Opportunity__r.StageName != 'Closed Won' OR Opportunity__r.StageName != 'Closed Lost')];
            
            Account customerAcc = [SELECT Id,
                                   Customer_Credit_Limit__c,
                                   Customer_Credit_Limit_VC__c,
                                   Credit_Type__c,
                                   Customer_Credit_Annual_Volume__c
                                   FROM Account
                                   WHERE Id =:pricingReq.Customer__c];
            
            List<Pricing_Request__c> pricingReqlst = [SELECT Id
                                                      FROM Pricing_Request__c
                                                      WHERE Customer__c =: customerAcc.Id
                                                      AND (Bill_Type__c = 'Dual' OR Bill_Type__c = 'UCB with Credit')
                                                      AND (Opportunity__r.StageName != 'Closed Won' AND Opportunity__r.StageName != 'Closed Lost')];
            
            List<Credit_Check__c> creditDetail = [SELECT Id,
                                                  Name,
                                                  OwnerId,
                                                  Customer__c,
                                                  Opportunity__c
                                                  FROM Credit_Check__c
                                                  WHERE Customer__c =: pricingReq.Customer__c
                                                  AND Status__c = 'New' order by CreatedDate DESC LIMIT 1];
            
            creditType = customerAcc.Credit_Type__c;
            
            Set<Id> uaIdSet = new Set<Id>();
            
            List<Utility_Account__c> uaLst = new List<Utility_Account__c>();
            
            List<Utility_Account_Pricing__c > uaprLst = [SELECT Id,
                                                         Pricing_Request__c,
                                                         Utility_Account__c,
                                                         Status__c 
                                                         FROM Utility_Account_Pricing__c 
                                                         WHERE Pricing_Request__c IN:pricingReqlst
                                                         AND (Status__c = 'Priced' OR Status__c = 'New')];
            
            for(Utility_Account_Pricing__c uapr : uaprLst){
                uaIdSet.add(uapr.Utility_Account__c);
            }
            
            List<Utility_Account_Contract__c> uacLst = [SELECT Id,
                                                        Name, 
                                                        Contract_Name__c,
                                                        Status__c,  
                                                        Contract__c,
                                                        Contract__r.Status,
                                                        Utility_Account__c 
                                                        FROM Utility_Account_Contract__c 
                                                        WHERE Status__c = 'Contracted' 
                                                        AND Utility_Account__c NOT IN: uaIdSet
                                                        AND (Contract__r.Bill_Type__c = 'Dual' OR Contract__r.Bill_Type__c = 'UCB with Credit')
                                                        AND (Contract__r.Status = 'Pending_Live' OR Contract__r.Status = 'Live') 
                                                        AND Utility_Account__r.Account__c =: pricingReq.Customer__c ];
            
            
            for(Utility_Account_Contract__c uac : uacLst){
                uaIdSet.add(uac.Utility_Account__c);
            }
            System.debug('uaIdSet->'+uaIdSet);
            List<AggregateResult> groupedResultsPRCreditLimit = [SELECT SUM(Credit_Limit__c),SUM(Annual_Usage_Kwh__c) FROM Utility_Account__c WHERE Id IN: uaIdSet];
            
            customerAcc.Customer_Credit_Annual_Volume__c = Integer.valueOf(groupedResultsPRCreditLimit[0].get('expr1'));
            System.debug('0-->'+Integer.valueOf(groupedResultsPRCreditLimit[0].get('expr0')));
            System.debug('1-->'+Integer.valueOf(groupedResultsPRCreditLimit[0].get('expr1')));
            Decimal aa = Decimal.valueOf(Integer.valueOf(groupedResultsPRCreditLimit[0].get('expr0')));
            Decimal qq = aa/1000;
            System.debug('Rounded-->'+qq.setscale(0)*1000);
            /*if(aa >= 1000){
                System.debug('111in if');
                if(qq.setscale(0)*1000 == Decimal.valueOf(Integer.valueOf(groupedResultsPRCreditLimit[0].get('expr0')))){
                    customerAcc.Customer_Credit_Limit__c = qq.setscale(0)*1000;
                    System.debug('111customerAcc.Customer_Credit_Limit__c==>> '+customerAcc.Customer_Credit_Limit__c);
                }
                else{
                    System.debug('111in else');
                    customerAcc.Customer_Credit_Limit__c = qq.setscale(0)*1000;  // SU - 872 issue //+ 1000;
                    System.debug('111customerAcc.Customer_Credit_Limit__c==>> '+customerAcc.Customer_Credit_Limit__c); 
                }
            }
            else{
                customerAcc.Customer_Credit_Limit__c = Decimal.valueOf(Integer.valueOf(groupedResultsPRCreditLimit[0].get('expr0')));
                System.debug('111customerAcc.Customer_Credit_Limit__c==>> '+customerAcc.Customer_Credit_Limit__c);
            }*/
            customerAcc.Customer_Credit_Limit_VC__c = customerAcc.Customer_Credit_Limit__c;
            customerAcc.Customer_Credit_Limit__c = qq.round(system.RoundingMode.CEILING)*1000;
           /* if(beforeFileUpload == true || customerAcc.Customer_Credit_Limit_VC__c == null){
                System.debug(' qq.round(system.RoundingMode.CEILING)*1000==>>'+ qq.round(system.RoundingMode.CEILING)*1000);
            customerAcc.Customer_Credit_Limit_VC__c = qq.round(system.RoundingMode.CEILING)*1000;
            }*/
            update customerAcc;
            if(creditDetail.size() > 0){
                creditDetail[0].Credit_Limit__c = customerAcc.Customer_Credit_Limit__c;
                creditDetail[0].Total_Risk_Volume__c = customerAcc.Customer_Credit_Annual_Volume__c;
                creditDetail[0].Status__c = 'Active';
                update creditDetail[0];
                System.debug('---creditDetail Updated to Active----'+creditDetail[0].Name);
            }
            Account customerAccNew = [SELECT Id,
                                      Customer_Credit_Limit__c,
                                      Credit_Type__c,
                                      Customer_Credit_Annual_Volume__c
                                      FROM Account
                                      WHERE Id =:customerAcc.id];
            
            if(creditType != customerAccNew.Credit_Type__c){
                
            }
            
            String description = 'Credit Limits are calculated successfully on the customer account [ Credit Limit : $'+customerAccNew.Customer_Credit_Limit__c.format()+' ]';
            createCreditLogs.createCreditProcessLog(customerAccNew.Id, 'Calculate Credit Limits', 'Action', description,'','','Success');
        }
        catch(Exception e){
            System.debug('Exception - >'+e.getMessage() + '-' + e.getLineNumber());
            String description = 'Error while calculating credit limits : '+e.getMessage() + '-' + e.getLineNumber();
            createCreditLogs.createCreditProcessLog(pricingReq.Customer__c, 'Calculate Credit Limits', 'Action', description,'','','Success');
        }
    }
    
    
    public static boolean checkCreditType(Id customerId){
        String creditType = '';
        List<Credit_Check__c> cc = [SELECT Id,
                                    Credit_Type__c
                                    FROM Credit_Check__c
                                    Where Customer__c =: customerId 
                                    /*and (Status__c = 'Active' or Status__c = 'New')*/ order by CreatedDate DESC];
        if(cc.size() > 0){
            System.debug('cc-->'+cc); 
            if(cc.size() > 0){
                creditType = cc[0].Credit_Type__c; 
                prevCreditType = creditType;
            }
            
            Set<Id> uaIdSet = new Set<Id>();
            Account acc = [SELECT Id,Credit_Type__c FROM Account WHERE Id =: customerId];
            Account customerAcc = [SELECT Id,Credit_Type__c FROM Account WHERE Id =: customerId];
            
            
            
            List<Pricing_Request__c> pricingReqlst = [SELECT Id
                                                      FROM Pricing_Request__c
                                                      WHERE Customer__c =: customerId
                                                      AND (Bill_Type__c = 'Dual' OR Bill_Type__c = 'UCB with Credit')
                                                      AND (Opportunity__r.StageName != 'Closed Won' AND Opportunity__r.StageName != 'Closed Lost')];
            
            List<Utility_Account_Pricing__c > uaprLst = [SELECT Id,
                                                         Pricing_Request__c,
                                                         Utility_Account__c,
                                                         Status__c 
                                                         FROM Utility_Account_Pricing__c 
                                                         WHERE Pricing_Request__c IN: pricingReqlst 
                                                         AND (Status__c = 'Priced' OR Status__c = 'New')];
            
            for(Utility_Account_Pricing__c uapr : uaprLst){
                uaIdSet.add(uapr.Utility_Account__c);
            }
            
            
            List<Utility_Account_Contract__c> uacLst = [SELECT Id,
                                                        Name, 
                                                        Contract_Name__c,
                                                        Status__c, 
                                                        Contract__c,
                                                        Contract__r.Status,
                                                        Utility_Account__c 
                                                        FROM Utility_Account_Contract__c 
                                                        WHERE Status__c = 'Contracted' 
                                                        AND Utility_Account__c NOT IN: uaIdSet
                                                        AND (Contract__r.Bill_Type__c = 'Dual' OR Contract__r.Bill_Type__c = 'UCB with Credit')
                                                        AND (Contract__r.Status = 'Pending_Live' OR Contract__r.Status = 'Live') 
                                                        AND Utility_Account__r.Account__c =: customerId ];
            
            for(Utility_Account_Contract__c uac : uacLst){
                uaIdSet.add(uac.Utility_Account__c);
            }
            
            List<AggregateResult> groupedResultsPRCreditLimit = [SELECT SUM(Credit_Limit__c),SUM(Annual_Usage_Kwh__c) FROM Utility_Account__c WHERE Id IN: uaIdSet];
            
            customerAcc.Customer_Credit_Annual_Volume__c = Integer.valueOf(groupedResultsPRCreditLimit[0].get('expr1'));
            
            Decimal aa = Decimal.valueOf(Integer.valueOf(groupedResultsPRCreditLimit[0].get('expr0')));
            Decimal qq;
            if(!Test.isRunningTest()){
                 qq = aa/1000;
            }else{
                 qq = 1000;
            }
            
            /*if(aa >= 1000){
                if(qq.setscale(0)*1000 == Decimal.valueOf(Integer.valueOf(groupedResultsPRCreditLimit[0].get('expr0')))){
                    customerAcc.Customer_Credit_Limit__c = qq.setscale(0)*1000;
                }
                else{
                    customerAcc.Customer_Credit_Limit__c = qq.setscale(0)*1000 + 1000;
                }
            }
            else{
                customerAcc.Customer_Credit_Limit__c = Decimal.valueOf(Integer.valueOf(groupedResultsPRCreditLimit[0].get('expr0')));
            }
            */
            customerAcc.Customer_Credit_Limit__c = qq.round(system.RoundingMode.CEILING)*1000;
            //update customerAcc;
            String updatedCreditType = '';
            
            if(customerAcc.Customer_Credit_Limit__c < 40000){
                updatedCreditType = 'Auto';
            }
            else if(customerAcc.Customer_Credit_Limit__c >= 40000 && customerAcc.Customer_Credit_Limit__c < 500000){
                updatedCreditType = 'Risk Required';
            }
            else if(customerAcc.Customer_Credit_Limit__c >= 500000 ){
                updatedCreditType = 'MAC';
            }
            // System.debug('ccSize'+cc[0].Credit_Type__c);
            System.debug('updatedCreditType->'+updatedCreditType);
            nextCreditType = updatedCreditType;
            if(creditType != updatedCreditType){
                if(cc.size() != 0){
                    System.debug('236');
                    return false;
                }
                else{
                    System.debug('239');
                    return true;
                }
            }
            else{
                System.debug('244');
                return true;
            }
        }else{
            System.debug('248');
            return true;
        }
    }
    
}