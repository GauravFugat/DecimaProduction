public class creditLimitCalculations {
    
    @invocableMethod
    public static void calculatePRCreditLimits(List<Id> pricingRequestId){
        try{
            System.debug('calculatePRCreditLimits---- '+pricingRequestId);
            Pricing_Request__c pricingReq = [SELECT Id,
                                             Pricing_Request_Credit_Limit__c,
                                             Bill_Type__c,
                                             Pricing_Request_Credit_Annual_Volume__c
                                             FROM Pricing_Request__c
                                             WHERE Id =: pricingRequestId[0]
                                             AND (Opportunity__r.StageName != 'Closed Won' OR Opportunity__r.StageName != 'Closed Lost') ];
            System.debug('pricingReq--- '+pricingReq);
            if(pricingReq.Bill_Type__c == 'Dual' || pricingReq.Bill_Type__c == 'UCB with Credit'){
                List<AggregateResult> groupedResultsPRCreditLimit = [SELECT SUM(Utility_Account__r.Credit_Limit__c ),SUM(Utility_Account__r.Annual_Usage_Kwh__c ) FROM Utility_Account_Pricing__c WHERE Pricing_Request__c =: pricingRequestId AND Status__c ='Priced'];
                
                pricingReq.Pricing_Request_Credit_Annual_Volume__c = Integer.valueOf(groupedResultsPRCreditLimit[0].get('expr1'));
                Decimal aa = Decimal.valueOf(Integer.valueOf(groupedResultsPRCreditLimit[0].get('expr0')))/1000;
                System.debug('aa-->> '+aa);
                pricingReq.Pricing_Request_Credit_Limit__c = aa.round(system.RoundingMode.CEILING)*1000;
                System.debug('pricingReq.Pricing_Request_Credit_Limit__c -->> '+pricingReq.Pricing_Request_Credit_Limit__c);
                /*if(aa >= 1000){
                    Decimal qq = aa/1000;
                    if(qq.setscale(0)*1000 == Decimal.valueOf(Integer.valueOf(groupedResultsPRCreditLimit[0].get('expr0')))){
                        pricingReq.Pricing_Request_Credit_Limit__c = qq.setscale(0)*1000; 
                    }
                    else{
                        pricingReq.Pricing_Request_Credit_Limit__c = qq.setscale(0)*1000; // + 1000; 
                    }
                }
                else{
                    pricingReq.Pricing_Request_Credit_Limit__c = Decimal.valueOf(Integer.valueOf(groupedResultsPRCreditLimit[0].get('expr0')));
                }*/
                
                 
                update pricingReq;
                creditLimitCalculationsAccount.calculateAccCreditLimits(pricingRequestId,true);    
            }
        }catch(Exception e){
            System.debug('Exception - >'+e.getMessage() + '-' + e.getLineNumber());
        }
    }
    
}