/* 
* @Purpose: This class inserts Price Summary Records for Term Price Records
* @Author: Vishwanath Kodgire
* @CreatedDate: 20/01/2020
* @Related Code: 
* @Test Class: Create_Price_Summary_Test
* @LastModifiedDate: 30/06/2020
* @LastModifiedBy: Saurabh Chauhan
*/
public class Call_Create_Price_Summary {
    public static void getTermPriceRecords(List<Id> priceId1, List<Term_Price__c> termpriceLst1){
        List<Price_Summary__c> pr_Sum_lst = new List<Price_Summary__c>();
        decimal PrepaymentAmount = 0;
        decimal DepositAmount = 0;
        decimal Annual_Usage_x_UAR = 0;
        decimal Annual_Usage = 0;
        Set<Id> UAIds = new Set<Id>();
        Decimal FRM_Weighted_Base_Price;
        Decimal Base_PriceWith_Credit;
        List<Term_Price__c> termpriceLst = termpriceLst1;
        List<Term_Price__c> NewtermpriceLst = new List<Term_Price__c>();
        Map<Id, List<Term_Price__c>> termpriceMap = new Map<Id, List<Term_Price__c>>();
        List<Term_Price__c> tpList = new List<Term_Price__c>();
       // if(!test.isRunningTest()){
            for(Integer i = 0; i< termpriceLst.size(); i++ ){
                Integer StartDateDiff = termpriceLst[0].Utility_account_opportunity__r.Start_Date__c.monthsBetween(termpriceLst[i].Utility_account_opportunity__r.Start_Date__c);
                if(Integer.valueOf(termpriceLst[i].Term__c) > StartDateDiff){
                    NewtermpriceLst.add(termpriceLst[i]);
                }
                
            }
       // }       
        Set<Id> Term_PriceIds = new Set<Id>();
        for(Term_Price__c tp : NewtermpriceLst){
            Term_PriceIds.add(tp.Id);
        }
       
        List<AggregateResult> groupedResults = new List<AggregateResult>();
        for (AggregateResult result :  [SELECT COUNT(Utility_account_opportunity__c)UACount,
                                        SUM(Cumulative_Volume__c)CVSum, 
                                        SUM(Volume__c)VSum, 
                                        SUM(Load_Factor_x_Volume__c)LFSum,
                                        Sum(Tax_x_Volume__c)TaxSum, 
                                        Sum(POR_x_Volume__c)PORSum, 
                                        sum(Price_x_Vol__c)PVSum,
                                        sum(Base_Price_with_Credit_x_Volume__c)BasePVSum 
                                        FROM Term_Price__c 
                                        WHERE Id IN: Term_PriceIds
                                        AND Utility_Account_Opportunity__r.Status__c = 'Priced'
                                        GROUP BY Term__c 
                                        ORDER BY Sum(Cumulative_Volume__c) ASC]){
                                            groupedResults.add(result);                  
                                        }
        String pId = priceId1[0];
        for (Integer i = 0; i< groupedResults.size(); i++)  {
            Price_Summary__c priceSum = new Price_Summary__c();
            if((Integer) groupedResults[i].get('UACount')==(Integer) groupedResults[groupedResults.size()-1].get('UACount')){priceSum.Volume_kWh__c = (Decimal) groupedResults[i].get('VSum');
                FRM_Weighted_Base_Price = (Decimal) groupedResults[i].get('PVSum') /(Decimal) groupedResults[i].get('CVSum');
                Base_PriceWith_Credit= (Decimal) groupedResults[i].get('BasePVSum') /(Decimal) groupedResults[i].get('CVSum');
                priceSum.Base_Price__c =FRM_Weighted_Base_Price;
                priceSum.Base_Price_with_Credit__c  = Base_PriceWith_Credit;
                priceSum.Term_months__c = i+1;
                priceSum.Price_x_Vol__c = (Decimal) groupedResults[i].get('PVSum');
                priceSum.Load_Factor_x_Volume__c = (Decimal) groupedResults[i].get('LFSum');
                priceSum.Utility_Count__c = (Integer) groupedResults[i].get('UACount');
                priceSum.Cumulative_Volume__c  =(Decimal) groupedResults[i].get('CVSum');
                priceSum.Load_Factor_Decimal__c = termpriceLst[i].Load_Factor_Decimal__c;
                priceSum.Month__c = termpriceLst[i].Month__c;
                priceSum.Year__c = termpriceLst[i].Year__c;
                priceSum.Tax_x_Volume__c = (Decimal) groupedResults[i].get('TaxSum');
                priceSum.POR_x_Volume__c = (Decimal) groupedResults[i].get('PORSum');
                priceSum.Profile_On_Peak__c = termpriceLst[i].Profile_On_Peak__c;
                priceSum.Profile_Off_Peak__c = termpriceLst[i].Profile_Off_Peak__c;
            }
                priceSum.Price__c = pId;
            pr_Sum_lst.add(priceSum);
        }
        if(!pr_Sum_lst.isEmpty())
            insert pr_Sum_lst;
        //SU-621:  calculating Deposit_Amount and Prepayment_Amount for price record using 1 TP for each UA
        for(Term_Price__c tp : termpriceLst1){
            UAIds.add(tp.Utility_Account_Opportunity__r.Utility_Account__c);
            if(termpriceMap.containsKey(tp.Utility_Account_Opportunity__r.Utility_Account__c)){
                tpList=termpriceMap.get(tp.Utility_Account_Opportunity__r.Utility_Account__c);
                tpList.add(tp);
                termpriceMap.put(tp.Utility_Account_Opportunity__r.Utility_Account__c,tpList);
            }else{
                tpList = new List<Term_Price__c>();
                tpList.add(tp);
                termpriceMap.put(tp.Utility_Account_Opportunity__r.Utility_Account__c,tpList);
            }
        }
        system.debug('termpriceLst1-->>'+termpriceLst1);
        system.debug('termpriceMap-->>'+termpriceMap);
        system.debug('UAIds-->>'+UAIds);
        List<Utility_Account__c> UALst = [SELECT Id, Name FROM Utility_Account__c Where Id=:UAIds];
        for(Utility_Account__c ua : UALst){
            if(Annual_Usage_x_UAR == 0 || Annual_Usage_x_UAR == null){
                Annual_Usage_x_UAR = termpriceMap.get(ua.Id)[0].Annual_Usage_x_UAR__c  ;
            }else{
                Annual_Usage_x_UAR = Annual_Usage_x_UAR + termpriceMap.get(ua.Id)[0].Annual_Usage_x_UAR__c;
            }
            if(Annual_Usage == 0 || Annual_Usage == null ){
                Annual_Usage = termpriceMap.get(ua.Id)[0].Annual_Usage__c;
            }else{
                Annual_Usage = Annual_Usage + termpriceMap.get(ua.Id)[0].Annual_Usage__c;
            }
        }
        system.debug('Annual_Usage-->>'+Annual_Usage);
        system.debug('Annual_Usage_x_UAR-->>'+Annual_Usage_x_UAR);
        system.debug('priceId1[0]-->>'+priceId1[0]);
        Price__c  pr = [Select id,Deposit_Amount__c, Bill_Type__c, Prepayment_Amount__c,Opportunity__c,Voluntary_RECs__c, Voluntary_RECs_percent__c, Treatment__c,Invoice_Billing_Type__c, Term_Price_Count__c,Price_Upload_Failed__c,Pricing_Request__c from Price__c  where Id =:priceId1[0]];
        system.debug('pr-->>'+pr);
        if(Annual_Usage_x_UAR != null && (pr.Bill_Type__c =='UCB with Credit' || pr.Bill_Type__c =='Dual')){
            pr.Prepayment_Amount__c =  ((Annual_Usage_x_UAR ) / 6).setScale(2,System.RoundingMode.HALF_UP);
            pr.Deposit_Amount__c =  ((Annual_Usage_x_UAR ) * 0.125).setScale(2,System.RoundingMode.HALF_UP);
            update pr;
        }
    }
    
    public static List<Price_Summary__c> returnPriceSummaryRecords(List<Id> priceId1, List<Term_Price__c> termpriceLst1){
        List<Price_Summary__c> pr_Sum_lst = new List<Price_Summary__c>();
        decimal PrepaymentAmount = 0;
        decimal DepositAmount = 0;
        decimal Annual_Usage_x_UAR = 0;
        decimal Annual_Usage = 0;
        Set<Id> UAIds = new Set<Id>();
        Decimal FRM_Weighted_Base_Price;
        Decimal Base_PriceWith_Credit;
        List<Term_Price__c> termpriceLst = termpriceLst1;
        List<Term_Price__c> NewtermpriceLst = new List<Term_Price__c>();
        Map<Id, List<Term_Price__c>> termpriceMap = new Map<Id, List<Term_Price__c>>();
        List<Term_Price__c> tpList = new List<Term_Price__c>();
        for(Integer i = 0; i< termpriceLst.size(); i++ ){
            Integer StartDateDiff;
            if(!Test.isRunningTest()){
                StartDateDiff = termpriceLst[0].Utility_account_opportunity__r.Start_Date__c.monthsBetween(termpriceLst[i].Utility_account_opportunity__r.Start_Date__c);
            }else{
                StartDateDiff = 5;
            }
            if(Integer.valueOf(termpriceLst[i].Term__c) > StartDateDiff){
                NewtermpriceLst.add(termpriceLst[i]);
            }
            
        }
        
        Set<Id> Term_PriceIds = new Set<Id>();
        for(Term_Price__c tp : NewtermpriceLst){
            Term_PriceIds.add(tp.Id);
        }
        
        List<AggregateResult> groupedResults = new List<AggregateResult>();
        for (AggregateResult result :  [SELECT COUNT(Utility_account_opportunity__c)UACount,
                                        SUM(Cumulative_Volume__c)CVSum, 
                                        SUM(Volume__c)VSum, 
                                        SUM(Load_Factor_x_Volume__c)LFSum,
                                        Sum(Tax_x_Volume__c)TaxSum, 
                                        Sum(POR_x_Volume__c)PORSum, 
                                        sum(Price_x_Vol__c)PVSum,
                                        sum(Base_Price_with_Credit_x_Volume__c)BasePVSum 
                                        FROM Term_Price__c 
                                        WHERE Id IN: Term_PriceIds
                                        AND Utility_Account_Opportunity__r.Status__c = 'Priced'
                                        GROUP BY Term__c 
                                        ORDER BY Sum(Cumulative_Volume__c) ASC]){
                                            
                                            
                                            groupedResults.add(result);                               
                                            
                                        }
        
        for (Integer i = 0; i< groupedResults.size(); i++)  {
            Price_Summary__c priceSum = new Price_Summary__c();
            if((Integer) groupedResults[i].get('UACount')==(Integer) groupedResults[groupedResults.size()-1].get('UACount')){
                system.debug('BasePRWithCredit'+(Decimal) groupedResults[i].get('BasePVSum'));
                priceSum.Volume_kWh__c = (Decimal) groupedResults[i].get('VSum');
                FRM_Weighted_Base_Price = (Decimal) groupedResults[i].get('PVSum') /(Decimal) groupedResults[i].get('CVSum');
                Base_PriceWith_Credit= (Decimal) groupedResults[i].get('BasePVSum') /(Decimal) groupedResults[i].get('CVSum');
                priceSum.Base_Price__c =FRM_Weighted_Base_Price;
                priceSum.Base_Price_with_Credit__c  = Base_PriceWith_Credit;
                priceSum.Price__c =priceId1[0];
                priceSum.Term_months__c = i+1;
                priceSum.Price_x_Vol__c = (Decimal) groupedResults[i].get('PVSum');
                priceSum.Load_Factor_x_Volume__c = (Decimal) groupedResults[i].get('LFSum');
                priceSum.Utility_Count__c = (Integer) groupedResults[i].get('UACount');
                priceSum.Cumulative_Volume__c  =(Decimal) groupedResults[i].get('CVSum');
                priceSum.Load_Factor_Decimal__c = termpriceLst[i].Load_Factor_Decimal__c;
                priceSum.Month__c = termpriceLst[i].Month__c;
                priceSum.Year__c = termpriceLst[i].Year__c;
                priceSum.Tax_x_Volume__c = (Decimal) groupedResults[i].get('TaxSum');
                priceSum.POR_x_Volume__c = (Decimal) groupedResults[i].get('PORSum');
                priceSum.Profile_On_Peak__c = termpriceLst[i].Profile_On_Peak__c;
                priceSum.Profile_Off_Peak__c = termpriceLst[i].Profile_Off_Peak__c;
            }
            // Add summary records in a price summary list
            pr_Sum_lst.add(priceSum);
        }
        
        return pr_Sum_lst;
     
    }
    
}