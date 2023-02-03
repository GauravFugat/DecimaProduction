/* 
* @Purpose: This class is calling Call_Create_Price_Summary apex asynchronously.
**This class is used in Run Price Summary Process Builder.
* @Author: Akanksha Pandharkame
* @CreatedDate: 01/01/2020
* @Related Code: 
* @Test Class: Create_Price_Summary_Test
* @LastModifiedDate:
* @LastModifiedBy:
*/
public class Create_Price_Summary_Asynchronous {
    
    @invocableMethod(Label='Create_Price_Summary_Asynchronous')
    public static void getTermPriceAsync(List<Id> priceId){
        getTermPrice2(priceId);
    }
    
    //@future
    public static void getTermPrice2(List<Id> priceId1){
        System.debug('priceId1->'+priceId1);
         List<Term_Price__c> termpriceLst =[SELECT Id, Term__c, Volume__c,Utility__c, Base_Price__c,Tax_x_Volume__c, POR_x_Volume__c,Profile_On_Peak__c,	Profile_Off_Peak__c,
                                           Price_x_Vol__c,Cumulative_Volume__c, Load_Factor_Decimal__c, Month__c, Load_Factor_x_Volume__c, Year__c, Utility_Account_Opportunity__c,
                                           Utility_Account_Opportunity__r.Status__c,Utility_Account_Opportunity__r.Start_Date__c,Annual_Usage__c, Annual_Usage_x_UAR__c,Utility_Account_Opportunity__r.Utility_Account__c
                                           FROM Term_Price__c where Price__r.Id IN : priceId1 AND Utility_Account_Opportunity__r.Status__c = 'Priced'];
     
        System.debug('Size->'+termpriceLst.size());
        if(!termpriceLst.isEmpty()){
            Call_Create_Price_Summary.getTermPriceRecords(priceId1, termpriceLst);
        }
    }
    
    public static List<Price_Summary__c> returnGetTermPrice2(List<Id> priceId1){
        System.debug('price Id ->'+priceId1);
        List<Price_Summary__c> pr_Sum_lst = new List<Price_Summary__c>();
        List<Term_Price__c> termpriceLst =[SELECT Id, Term__c, Volume__c,Utility__c, Base_Price__c,Tax_x_Volume__c, POR_x_Volume__c,Profile_On_Peak__c,	Profile_Off_Peak__c,
                                           Price_x_Vol__c,Cumulative_Volume__c, Load_Factor_Decimal__c, Month__c, Load_Factor_x_Volume__c, Year__c, Utility_Account_Opportunity__c,
                                           Utility_Account_Opportunity__r.Status__c,Utility_Account_Opportunity__r.Start_Date__c,Annual_Usage__c, Annual_Usage_x_UAR__c,Utility_Account_Opportunity__r.Utility_Account__c
                                           FROM Term_Price__c where Price__r.Id IN : priceId1 AND Utility_Account_Opportunity__r.Status__c = 'Priced'];
     
        System.debug('termpriceLst-->'+termpriceLst.size());
        if(!termpriceLst.isEmpty()){
            pr_Sum_lst.addAll(Call_Create_Price_Summary.returnPriceSummaryRecords(priceId1, termpriceLst));
        }
        return pr_Sum_lst;
    }
}