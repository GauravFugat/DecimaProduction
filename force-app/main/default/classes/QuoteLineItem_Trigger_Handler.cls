/* 
* @Purpose: Handler class of QuoteLineItem_Trigger .
* @Author: Saurabh Chauhan
* @CreatedDate: 09/08/2020
* @Related Code: QuoteLineItem_Trigger, RecursiveTriggerHandler
* @Test Class: QuoteLineItem_Trigger_Handler_Test
* @LastModifiedDate: 12/08/2020
* @LastModifiedBy: Saurabh Chauhan
*/


public class QuoteLineItem_Trigger_Handler {

    public static void QLIupdate(Set<Id> QuoteIds ){
         List<QuoteLineItem> QLI_ListToUpdate = new List<QuoteLineItem>();
         Map<Id,List<QuoteLineItem>> QuoteIdQLIMap = new Map<Id,List<QuoteLineItem>>();
         List<Quote> QLIlst = [Select Id , (Select id,QuoteId,UnitPrice,Term_Months__c,Revised_Sales_Margin_per_unit__c,Quote_Sales_Margin__c,Sales_Margin_per_unit__c,Total_Usage__c from QuoteLineItems ORDER BY Term_Months__c ) from Quote where Id IN:QuoteIds];
        for(Quote q : QLIlst ){
            if(!QuoteIdQLIMap.containskey(q.Id)){
                QuoteIdQLIMap.put(q.Id,q.QuoteLineItems);
            }
        }
        
        if(!QuoteIdQLIMap.isEmpty()){
            for(Id quoteId : QuoteIdQLIMap.keyset()){
                integer i = 0;
                List<QuoteLineItem> QliLstTocheck = QuoteIdQLIMap.get(quoteId);
                for(QuoteLineItem qli : QliLstTocheck){
                    
                    Decimal salesMargin = qli.Sales_Margin_per_unit__c;
                    
                    if( qli.Revised_Sales_Margin_per_unit__c != 0 && qli.Revised_Sales_Margin_per_unit__c != null ){
                        salesMargin = qli.Revised_Sales_Margin_per_unit__c;
                    }
                    
                    if(qli.Term_Months__c == 12){
                        qli.UnitPrice = qli.Total_Usage__c * salesMargin;
                        if(qli.Id!=QliLstTocheck[0].Id){
                           QliLstTocheck[0].UnitPrice = 0;                           
                        }else
                            i++;
                    }
                    else{
                        qli.UnitPrice = 0;
                        if(i==0){
                            System.debug(qli.Total_Usage__c +'-->'+salesMargin);
                           qli.UnitPrice = qli.Total_Usage__c * salesMargin;
                            System.debug('qli.UnitPrice->'+qli.UnitPrice);
                           i++; 
                        }
                    }
                   
                    QLI_ListToUpdate.add(qli);
                }
            }
        }
        update QLI_ListToUpdate;
    }
}