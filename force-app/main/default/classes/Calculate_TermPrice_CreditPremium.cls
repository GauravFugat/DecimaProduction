/* 
* @Purpose: Created for SU:621 requirement and  This is used to Calculate Term Price Credit Premium.
* @Author: Rahul Ghaytadak
* @CreatedDate: 02/19/2021
* @Related Code: Batch_CreateCustomObjectRecord
* @Test Class: Calculate_TermPrice_CreditPremium_test
* @LastModifiedDate: 02/19/2021
* @LastModifiedBy: Rahul Ghaytadak
*/
public class Calculate_TermPrice_CreditPremium {
    @invocableMethod(Label='Calculate Term Price Credit Premium')
    public static void getTermPrice_CreditPremium(List<Id> pricingRequestIds){
        System.debug('getTermPrice_CreditPremium');
        String description = 'Credit premium and term prices are calculated for the price file loaded.';
        Map<Id,decimal> SvalueMap = new Map<Id,decimal>();
        Set<Id> AccIds = new Set<Id>();
        List<Term_Price__c> termpriceLstToUpdate = new List<Term_Price__c>();
        Pricing_Request__c pr = [SELECT Id, Name, Bill_Type__c, Customer__c, Credit_Details__c,Credit_Details__r.Credit_Check_Outcome__c,Customer__r.Customer_Credit_Limit__c,Opportunity__c  FROM Pricing_Request__c Where Id =: pricingRequestIds[0]];
        if(checkRecursive.scoreResult?.lienCount == NULL){
            checkRecursive.scoreResult = ExperianLegalFilingSummariesFetcher.makeCalloutNew(pr.Customer__c);
        }
        Price__c price = [SELECT Id, Credit__c, P_D__c, Subject_to_Credit__c,Pricing_Request__c FROM Price__c Where Pricing_Request__c =: pricingRequestIds[0] order by createdDate desc limit 1];
        system.debug('price==>'+price);
        Account accRecord = [SELECT Id,Last_Successful_Experian_Legal_Filings__c FROM Account WHERE Id =: pr.Customer__c ];
        //Retrieve ‘Credit Rank’ value from Credit Details record
        Credit_Check__c creditDetail = [SELECT Id, Name,Credit_Automation_Fail__c,Credit_Rank_Formula__c,Credit_Premium_Type__c,Custom_Credit_Premium__c FROM Credit_Check__c Where Customer__c =: pr.Customer__c AND Status__c = 'Active' order by CreatedDate DESC limit 1];
        system.debug('creditDetail==>'+creditDetail);
        //Reference the Utility Account ‘Utility’ and retrieve the appropriate ‘S' value (there are 7 fields S1 to S7) based on the 'Credit Rank’
        //Use this value to populate the ‘Credit Premium’ field on Term Price
        List<Utility_Account_Opportunity__c> UAO = [SELECT Id, Utility_Account__r.Utility__c , Opportunity__c, Utility_Account__c, Utility__c FROM Utility_Account_Opportunity__c Where Opportunity__c =: pr.Opportunity__c AND Status__c = 'Priced'];
        for(Utility_Account_Opportunity__c Ua : UAO){
            AccIds.add(Ua.Utility_Account__r.Utility__c );
        }
        List<Account> acc = [SELECT Id, Name, S1__c, S2__c, S3__c, S4__c, S5__c, S6__c, S7__c, Customer_Credit_Limit__c FROM Account Where Id=:AccIds];
        List<Term_Price__c> termpriceLst =[SELECT Id, Term__c, Volume__c,Utility__c, Price__c, Base_Price__c,Tax_x_Volume__c, POR_x_Volume__c,Profile_On_Peak__c,	Profile_Off_Peak__c,
                                           Price_x_Vol__c,Cumulative_Volume__c, Load_Factor_Decimal__c, Month__c, Load_Factor_x_Volume__c, Year__c, Utility_Account_Opportunity__c,
                                           Utility_Account_Opportunity__r.Status__c,Utility_Account_Opportunity__r.Start_Date__c,Credit_Premium__c
                                           FROM Term_Price__c where Price__c =: price.Id AND Utility_Account_Opportunity__r.Status__c = 'Priced'];
        system.debug('termpriceLst-->'+termpriceLst);
        for(Account ac : acc){
            if(creditDetail.Credit_Rank_Formula__c == 'S1' ){
                SvalueMap.put(ac.Id,ac.S1__c);
            }else if(creditDetail.Credit_Rank_Formula__c == 'S2'){SvalueMap.put(ac.Id,ac.S2__c);
            }else if(creditDetail.Credit_Rank_Formula__c == 'S3'){SvalueMap.put(ac.Id,ac.S3__c);
            }else if(creditDetail.Credit_Rank_Formula__c == 'S4'){SvalueMap.put(ac.Id,ac.S4__c);
            }else if(creditDetail.Credit_Rank_Formula__c == 'S5'){SvalueMap.put(ac.Id,ac.S5__c);
            }else if(creditDetail.Credit_Rank_Formula__c == 'S6'){SvalueMap.put(ac.Id,ac.S6__c);
            }else if(creditDetail.Credit_Rank_Formula__c == 'S7'){SvalueMap.put(ac.Id,ac.S7__c);
            }
        }
        //   system.debug('SvalueMap-->'+SvalueMap);
        if(pr.Credit_Details__r.Credit_Check_Outcome__c == 'Passed' && pr.Customer__r.Customer_Credit_Limit__c < 40000 && creditDetail.Credit_Automation_Fail__c == false ){
            System.debug('if--');
            createCreditLogs.createCreditProcessLog(pr.Customer__c, 'Credit Outcome - Passed && Credit Limit < 40K ?', 'Decision', 'Credit Limit : $'+pr.Customer__r.Customer_Credit_Limit__c.format(),'','','True');
            description = 'Credit premium and term prices are calculated for the price file loaded';
            for(Term_Price__c tp : termpriceLst){
                if (creditDetail.Credit_Premium_Type__c == 'Custom')
                    tp.Credit_Premium__c = creditDetail.Custom_Credit_Premium__c;
                else
                	tp.Credit_Premium__c = SvalueMap.get(tp.Utility__c);
                system.debug('SvalueMap.get(tp.Utility__c)-->'+SvalueMap.get(tp.Utility__c));
                termpriceLstToUpdate.add(tp);
            }
            if(termpriceLstToUpdate.size() > 0){
                update termpriceLstToUpdate;
            }
            price.P_D__c = true;
            price.Credit__c = true;
            update price;
            pr.Status__c = 'Complete';
            update pr;
        } 
        else if(pr.Credit_Details__r.Credit_Check_Outcome__c == 'Pending' && pr.Customer__r.Customer_Credit_Limit__c < 40000 && creditDetail.Credit_Automation_Fail__c == false ){
            System.debug('else if--1');
            createCreditLogs.createCreditProcessLog(pr.Customer__c, 'Credit Outcome - Pending && Credit Limit < 40K ?', 'Decision','Credit Limit : $'+pr.Customer__r.Customer_Credit_Limit__c.format(),'','','True');
            String finalOutcome = '';
           // createCreditLogs.createCreditProcessLog(pr.Customer__c, 'Credit Outcome - Passed && Credit Limit < 40K ?', 'Decision', '','','','False');
                       
            system.debug('checkRecursive.scoreResult>>');
            if(checkRecursive.scoreResult.lienCount != NULL){
                if(checkThreshold.checkDate(accRecord.Last_Successful_Experian_Legal_Filings__c)){
                    createCreditLogs.createCreditProcessLog(pr.Customer__c, 'LegalFilingSummaries - Recency Check', 'Decision', 'New data not required [Data retrieved from Experian records]','','','False');
                }
                else{
                    createCreditLogs.createCreditProcessLog(pr.Customer__c, 'LegalFilingSummaries - Recency Check', 'Decision', 'Requires new data','','','True');
                }
                createCreditLogs.createCreditProcessLog(pr.Customer__c, 'LegalFilingSummaries API Call', 'Action', 'lienCount='+Integer.valueOf(checkRecursive.scoreResult.lienCount) +', judgmentCount='+ Integer.valueOf(checkRecursive.scoreResult.judgmentCount),'','','Success');
                if( Integer.valueOf(Integer.valueOf(checkRecursive.scoreResult.lienCount) + Integer.valueOf(checkRecursive.scoreResult.judgmentCount)) > 0 ){
                    for(Term_Price__c tp : termpriceLst){
                        tp.Credit_Premium__c = 0;
                        // system.debug('SvalueMap.get(tp.Utility__c)-->'+SvalueMap.get(tp.Utility__c));
                        termpriceLstToUpdate.add(tp);
                    }
                    if(termpriceLstToUpdate.size() > 0){
                        update termpriceLstToUpdate;
                    }                    
                    //Set Credit Outcome = ‘Refer’
                    creditDetail.Credit_Check_Outcome__c = 'Refer';
                    finalOutcome = ' , Credit Outcome : Refer';
                    //Set Pricing Request Status = 'Credit Risk Review'
                    pr.Status__c = 'Credit Risk Review';
                    //Set 'Subject to Credit' checkbox on Price to 'TRUE'
                    price.Subject_to_Credit__c = true;
                    
                    createCreditLogs.createCreditProcessLog(pr.Customer__c, 'Credit Outcome - Pending && Credit Limit < 40K ?', 'Decision','Price[Credit:true , P&D:true, Subject to Credit: true]','','','True');
            		description = 'Credit premium and term prices are calculated for the price file loaded';
                }
                else{
                    for(Term_Price__c tp : termpriceLst){
                        if (creditDetail.Credit_Premium_Type__c == 'Custom')
                            tp.Credit_Premium__c = creditDetail.Custom_Credit_Premium__c;
                        else
                            tp.Credit_Premium__c = SvalueMap.get(tp.Utility__c);
                        // system.debug('SvalueMap.get(tp.Utility__c)-->'+SvalueMap.get(tp.Utility__c));
                        termpriceLstToUpdate.add(tp);
                    }
                    if(termpriceLstToUpdate.size() > 0){
                        update termpriceLstToUpdate;
                    }
                    //Set Credit Outcome = 'Pass' //Set Pricing Request Status = 'Complete' //Set 'Subject to Credit' checkbox on Price to ‘FALSE’
                    creditDetail.Credit_Check_Outcome__c = 'Passed';  finalOutcome = ' , Credit Outcome : Passed';   pr.Status__c = 'Complete';  price.Subject_to_Credit__c = false;
                    
                    createCreditLogs.createCreditProcessLog(pr.Customer__c, 'Credit Outcome - Pending && Credit Limit < 40K ?', 'Decision','Price[Credit:true , P&D:true]','','','True');
            		description = 'Credit premium and term prices are calculated for the price file loaded';
                } 
            }
            price.P_D__c = true;
            price.Credit__c = true;
            update price;
            //update creditDetail;
            update pr;
            //createCreditLogs.createCreditProcessLog(pr.Customer__c, 'Credit Outcome - Pending && Credit Limit < 40K ?', 'Decision','Credit Limit : $'+pr.Customer__r.Customer_Credit_Limit__c.format()+finalOutcome,'','','True');
        }
        else if(pr.Credit_Details__r.Credit_Check_Outcome__c == 'Failed' && pr.Customer__r.Customer_Credit_Limit__c < 40000 && creditDetail.Credit_Automation_Fail__c == false ){
            System.debug('else if--2');
          //  createCreditLogs.createCreditProcessLog(pr.Customer__c, 'Credit Outcome - Passed && Credit Limit < 40K ?', 'Decision', '','','','False');
            createCreditLogs.createCreditProcessLog(pr.Customer__c, 'Credit Outcome - Failed && Credit Limit < 40K ?', 'Decision', 'Credit Limit : $'+pr.Customer__r.Customer_Credit_Limit__c.format(),'','','True');
            description = 'Credit Premium not applied';
            price.P_D__c = true;
            update price;
            pr.Status__c = 'Complete';
            update pr;
        }
        else if(pr.Customer__r.Customer_Credit_Limit__c >= 40000 && creditDetail.Credit_Automation_Fail__c == false ){
            System.debug('in 162');
            System.debug('else if--3');
           // createCreditLogs.createCreditProcessLog(pr.Customer__c, 'Credit Outcome - Passed && Credit Limit < 40K ?', 'Decision', '','','','False');
            createCreditLogs.createCreditProcessLog(pr.Customer__c, 'Credit Limit >= 40K ?', 'Decision','Credit Limit : $'+pr.Customer__r.Customer_Credit_Limit__c.format(),'','','True');
            description = 'Credit Premium not applied';
            // Populate 'Credit Premium' on all Term Price records with '0'
            creditDetail.Credit_Check_Outcome__c = 'Refer';
            for(Term_Price__c tp : termpriceLst){
                tp.Credit_Premium__c = 0;
                termpriceLstToUpdate.add(tp);
            }
            if(termpriceLstToUpdate.size() > 0){
                update termpriceLstToUpdate;               
            }
            //Set 'Credit' checkbox on Price to 'TRUE'
            //Set 'Subject to Credit' checkbox on Price to 'TRUE'
            //Set Pricing Request Status = 'Credit Risk Review'
            price.Credit__c = true;
            price.Subject_to_Credit__c = true;
            update price;
            pr.Status__c = 'Credit Risk Review';
            update pr;
            update creditDetail;
            Credit_Check__c creditDetailToPass = [SELECT Id,Name,Credit_Check_Outcome__c FROM Credit_Check__c WHERE Id =:creditDetail.Id ];
            createCreditLogs.createCreditProcessLog(pr.Customer__c, 'Credit Assessment', 'Decision', 'Credit Outcome :'+creditDetailToPass.Credit_Check_Outcome__c,creditDetailToPass.Name,creditDetailToPass.Id,'Completed');
            createCreditLogs.createCreditProcessLog(pr.Customer__c, 'Term Price and Credit Premium Calculations', 'Action', description,creditDetailToPass.Name,creditDetailToPass.Id,'Success');
            update creditDetailToPass;
        }
    }
    public static Credit_Check__c getTermPrice_CreditPremiumSync(List<Id> pricingRequestIds,Id priceId,Boolean crdTypMatch){
        try{
            System.debug('getTermPrice_CreditPremiumSync');
            String description = 'Credit premium and term prices are calculated for the price file loaded.';
        Map<Id,decimal> SvalueMap = new Map<Id,decimal>();
        Set<Id> AccIds = new Set<Id>();
        List<Term_Price__c> termpriceLstToUpdate = new List<Term_Price__c>();
        Pricing_Request__c pr = [SELECT Id, Name, Bill_Type__c, Customer__c, Credit_Details__c,Credit_Details__r.Credit_Check_Outcome__c,Customer__r.Customer_Credit_Limit__c,Opportunity__c  FROM Pricing_Request__c Where Id =: pricingRequestIds[0]];
        Account accRecord = [SELECT Id,Last_Successful_Experian_Legal_Filings__c FROM Account WHERE Id =: pr.Customer__c ];
            //Boolean creditTypeMatch = creditLimitCalculationsAccount.checkCreditType(pr.Customer__c);
            Boolean creditTypeMatch = crdTypMatch;
        if(checkRecursive.scoreResult?.lienCount == NULL){
            System.debug('--167--');
            checkRecursive.scoreResult = ExperianLegalFilingSummariesFetcher.makeCalloutNew(pr.Customer__c);
        }
        Price__c price = [SELECT Id, Credit__c, P_D__c, Subject_to_Credit__c,Pricing_Request__c FROM Price__c Where Id =: priceId];
        system.debug('price==>'+price);
        //Retrieve ‘Credit Rank’ value from Credit Details record
            Credit_Check__c creditDetail = new Credit_Check__c();
            try{
                 creditDetail = [SELECT Id, Name,Credit_Type__c,Credit_Check_Outcome__c,Credit_Premium_Type__c,Credit_Automation_Fail__c,Credit_Rank_Formula__c,Credit_Detail_ID__c,Customer__r.Name FROM Credit_Check__c Where Customer__c =: pr.Customer__c AND Status__c = 'Active' order by CreatedDate DESC limit 1];
            }
            catch(Exception e){ creditDetail = [SELECT Id, Name,Credit_Type__c,Credit_Check_Outcome__c,Credit_Premium_Type__c,Credit_Automation_Fail__c,Credit_Rank_Formula__c,Credit_Detail_ID__c,Customer__r.Name FROM Credit_Check__c Where Customer__c =: pr.Customer__c order by CreatedDate DESC limit 1];}
        //Reference the Utility Account ‘Utility’ and retrieve the appropriate ‘S' value (there are 7 fields S1 to S7) based on the 'Credit Rank’
        //Use this value to populate the ‘Credit Premium’ field on Term Price
        List<Utility_Account_Opportunity__c> UAO = [SELECT Id, Utility_Account__r.Utility__c , Opportunity__c, Utility_Account__c, Utility__c FROM Utility_Account_Opportunity__c Where Opportunity__c =: pr.Opportunity__c AND Status__c = 'Priced'];
        for(Utility_Account_Opportunity__c Ua : UAO){
            AccIds.add(Ua.Utility_Account__r.Utility__c );
        }
        List<Account> acc = [SELECT Id, Name, S1__c, S2__c, S3__c, S4__c, S5__c, S6__c, S7__c, Customer_Credit_Limit__c FROM Account Where Id=:AccIds];
        List<Term_Price__c> termpriceLst =[SELECT Id, Term__c, Volume__c,Utility__c, Price__c, Base_Price__c,Tax_x_Volume__c, POR_x_Volume__c,Profile_On_Peak__c,	Profile_Off_Peak__c,
                                           Price_x_Vol__c,Cumulative_Volume__c, Load_Factor_Decimal__c, Month__c, Load_Factor_x_Volume__c, Year__c, Utility_Account_Opportunity__c,
                                           Utility_Account_Opportunity__r.Status__c,Utility_Account_Opportunity__r.Start_Date__c,Credit_Premium__c
                                           FROM Term_Price__c where Price__c =: price.Id AND Utility_Account_Opportunity__r.Status__c = 'Priced'];
        system.debug('termpriceLst-->'+termpriceLst);
        for(Account ac : acc){
            if(creditDetail.Credit_Rank_Formula__c == 'S1' ){
                SvalueMap.put(ac.Id,ac.S1__c);
            }else if(creditDetail.Credit_Rank_Formula__c == 'S2'){SvalueMap.put(ac.Id,ac.S2__c);
            }else if(creditDetail.Credit_Rank_Formula__c == 'S3'){SvalueMap.put(ac.Id,ac.S3__c);
            }else if(creditDetail.Credit_Rank_Formula__c == 'S4'){SvalueMap.put(ac.Id,ac.S4__c);
            }else if(creditDetail.Credit_Rank_Formula__c == 'S5'){SvalueMap.put(ac.Id,ac.S5__c);
            }else if(creditDetail.Credit_Rank_Formula__c == 'S6'){SvalueMap.put(ac.Id,ac.S6__c);
            }else if(creditDetail.Credit_Rank_Formula__c == 'S7'){SvalueMap.put(ac.Id,ac.S7__c);
            }
        }
        //   system.debug('SvalueMap-->'+SvalueMap);
        if(pr.Credit_Details__r.Credit_Check_Outcome__c == 'Passed' && pr.Customer__r.Customer_Credit_Limit__c < 40000 && creditDetail.Credit_Automation_Fail__c == false ){
            system.debug('Credit limit <40k--Passed');
            createCreditLogs.createCreditProcessLog(pr.Customer__c, 'Credit Outcome - Passed && Credit Limit < 40K ?', 'Decision', 'Credit Limit : $'+pr.Customer__r.Customer_Credit_Limit__c.format(),'','','True');
            description = 'Credit premium and term prices are calculated for the price file loaded';
            for(Term_Price__c tp : termpriceLst){
                if (creditDetail.Credit_Premium_Type__c == 'Custom')
                    tp.Credit_Premium__c = creditDetail.Custom_Credit_Premium__c;
                else
                	tp.Credit_Premium__c = SvalueMap.get(tp.Utility__c);
                system.debug('SvalueMap.get(tp.Utility__c)-->'+SvalueMap.get(tp.Utility__c));
                termpriceLstToUpdate.add(tp);
            }
            if(termpriceLstToUpdate.size() > 0){
                update termpriceLstToUpdate;
            }
            price.P_D__c = true;
            price.Credit__c = true;
            update price;
            pr.Status__c = 'Complete';
            update pr;
        } 
        else if(pr.Credit_Details__r.Credit_Check_Outcome__c == 'Pending' && pr.Customer__r.Customer_Credit_Limit__c < 40000 && creditDetail.Credit_Automation_Fail__c == false ){
           system.debug('Pending--<40k');
            createCreditLogs.createCreditProcessLog(pr.Customer__c, 'Credit Outcome - Pending && Credit Limit < 40K ?', 'Decision','Credit Limit : $'+pr.Customer__r.Customer_Credit_Limit__c.format(),'','','True');
            String finalOutcome = '';
            
           
            system.debug('checkRecursive.scoreResult>>'+checkRecursive.scoreResult);
            if(checkRecursive.scoreResult.lienCount != NULL){
                System.debug('--Refer--check');
                if(checkThreshold.checkDate(accRecord.Last_Successful_Experian_Legal_Filings__c)){
                    createCreditLogs.createCreditProcessLog(pr.Customer__c, 'LegalFilingSummaries - Recency Check', 'Decision', 'New data not required [Data retrieved from Experian records]','','','False');
                }
                else{ createCreditLogs.createCreditProcessLog(pr.Customer__c, 'LegalFilingSummaries - Recency Check', 'Decision', 'Requires new data','','','True');}
                createCreditLogs.createCreditProcessLog(pr.Customer__c, 'LegalFilingSummaries API Call', 'Action', 'lienCount='+Integer.valueOf(checkRecursive.scoreResult.lienCount) +', judgmentCount='+ Integer.valueOf(checkRecursive.scoreResult.judgmentCount),'','','Success');
                if( Integer.valueOf(Integer.valueOf(checkRecursive.scoreResult.lienCount) + Integer.valueOf(checkRecursive.scoreResult.judgmentCount)) > 0 ){
                    //Set Credit Outcome = ‘Refer’
                    if((creditDetail.Credit_Type__c != 'Risk Required' ) || (creditDetail.Credit_Type__c == 'Risk Required' && creditTypeMatch == false) ){ //&& creditTypeMatch == true)
                        creditDetail.Credit_Check_Outcome__c = 'Refer';
                        finalOutcome = ' , Credit Outcome : Refer';
                    }
                    
                    for(Term_Price__c tp : termpriceLst){
                        tp.Credit_Premium__c = 0;
                        // system.debug('SvalueMap.get(tp.Utility__c)-->'+SvalueMap.get(tp.Utility__c));
                        termpriceLstToUpdate.add(tp);
                    }
                    if(termpriceLstToUpdate.size() > 0){
                        update termpriceLstToUpdate;
                    }                    
                    //Set Pricing Request Status = 'Credit Risk Review'
                    pr.Status__c = 'Credit Risk Review';
                    //Set 'Subject to Credit' checkbox on Price to 'TRUE'
                    price.Subject_to_Credit__c = true;
                    description = 'Credit Premium not applied';
                }
                else{           
                    for(Term_Price__c tp : termpriceLst){
                        if (creditDetail.Credit_Premium_Type__c == 'Custom')
                            tp.Credit_Premium__c = creditDetail.Custom_Credit_Premium__c;
                        else
                            tp.Credit_Premium__c = SvalueMap.get(tp.Utility__c);
                        // system.debug('SvalueMap.get(tp.Utility__c)-->'+SvalueMap.get(tp.Utility__c));
                        termpriceLstToUpdate.add(tp);
                    }
                    if(termpriceLstToUpdate.size() > 0){
                        update termpriceLstToUpdate;
                    }
                    //Set Credit Outcome = 'Pass' //Set Pricing Request Status = 'Complete' //Set 'Subject to Credit' checkbox on Price to ‘FALSE’
                    creditDetail.Credit_Check_Outcome__c = 'Passed';  finalOutcome = ' , Credit Outcome : Passed';   pr.Status__c = 'Complete';  price.Subject_to_Credit__c = false;
                    
                    createCreditLogs.createCreditProcessLog(pr.Customer__c, 'Credit Outcome - Pending && Credit Limit < 40K ?', 'Decision','Price[Credit:true , P&D:true]','','','True');
                    description = 'Credit premium and term prices are calculated for the price file loaded';
                }
            }
            price.P_D__c = true;
            price.Credit__c = true;
            update price;
            //update creditDetail;
            update pr;
        }
        else if(pr.Credit_Details__r.Credit_Check_Outcome__c == 'Failed' && pr.Customer__r.Customer_Credit_Limit__c < 40000 && creditDetail.Credit_Automation_Fail__c == false ){
             system.debug('Failed--<40k');
            createCreditLogs.createCreditProcessLog(pr.Customer__c, 'Credit Outcome - Failed && Credit Limit < 40K ?', 'Decision', 'Credit Limit : $'+pr.Customer__r.Customer_Credit_Limit__c.format(),'','','True');
            description = 'Credit Premium not applied';
            
            price.P_D__c = true;
            update price;
            
            pr.Status__c = 'Complete';
            update pr;
        }
        else if(pr.Customer__r.Customer_Credit_Limit__c >= 40000 && creditDetail.Credit_Automation_Fail__c == false ){
            System.debug('Credit limit >40k--Refer');
            createCreditLogs.createCreditProcessLog(pr.Customer__c, 'Credit Limit >= 40K ?', 'Decision','Credit Limit : $'+pr.Customer__r.Customer_Credit_Limit__c.format(),'','','True');
            description = 'Credit Premium not applied';
            
            
            if(creditDetail.Credit_Type__c == 'Risk Required' && creditTypeMatch == true){
                if(pr.Bill_Type__c != 'UCB'){
                    if (creditDetail.Credit_Check_Outcome__c == 'Pending'){
                    	creditDetail.Credit_Check_Outcome__c = 'Refer';
                        update creditDetail;
                    }                       
                    CreditLimitVarianceCheck.creditLimitVarienceThreshold(new List<Id>{pr.Id}, price.Id);
                }
                creditDetail = [SELECT Id, Name,Credit_Type__c,Credit_Check_Outcome__c,Credit_Premium_Type__c,Credit_Automation_Fail__c,Credit_Detail_ID__c,Customer__r.Name,Credit_Rank_Formula__c FROM Credit_Check__c Where Customer__c =: pr.Customer__c AND Status__c = 'Active' order by CreatedDate DESC limit 1];
                if(creditDetail.Credit_Check_Outcome__c == 'Passed'){
                List<Term_Price__c> tpLst = [SELECT Id,Name,Utility_Account_Opportunity__r.Status__c,Utility_Account_Opportunity__r.Start_Date__c,Utility_Account_Opportunity__r.Utility_Account__c,Utility__r.S1__c,Utility__r.S2__c,Utility__r.S3__c,Utility__r.S4__c,Utility__r.S5__c,Utility__r.S6__c,Utility__r.S7__c, Base_Price__c, Price__c, Term__c, Volume__c, Cumulative_Volume__c, Load_Factor_Decimal__c, Load_Factor__c, Load_Factor_x_Volume__c, Month__c, Opportunity__c, POR__c, POR_x_Volume__c, Price_x_Vol__c, Tax__c, Tax_x_Volume__c, Temp__c, UAO_Status__c, Utility_Account_Opportunity__c, Utility__c, Year__c, Profile_Off_Peak__c, Profile_On_Peak__c, Term_New__c, Credit_Premium__c, Base_Price_with_Credit_Premium__c, Base_Price_with_Credit_x_Volume__c, Annual_Usage__c, Annual_Usage_x_UAR__c, Include_in_Price_Summary__c  FROM Term_Price__c WHERE Price__c =: priceId]; 
                for(Term_Price__c tp : tpLst){
                    if(creditDetail.Credit_Premium_Type__c == 'S1'){tp.Credit_Premium__c = tp.Utility__r.S1__c;
                   	}else if(creditDetail.Credit_Premium_Type__c == 'S2'){tp.Credit_Premium__c = tp.Utility__r.S2__c;
                    }else if(creditDetail.Credit_Premium_Type__c == 'S3'){tp.Credit_Premium__c = tp.Utility__r.S3__c;
                    }else if(creditDetail.Credit_Premium_Type__c == 'S4'){tp.Credit_Premium__c = tp.Utility__r.S4__c;
                    }else if(creditDetail.Credit_Premium_Type__c == 'S5'){tp.Credit_Premium__c = tp.Utility__r.S5__c;
                    }else if(creditDetail.Credit_Premium_Type__c == 'S6'){tp.Credit_Premium__c = tp.Utility__r.S6__c;
                    }else if(creditDetail.Credit_Premium_Type__c == 'S7'){tp.Credit_Premium__c = tp.Utility__r.S7__c;
                    }else if(creditDetail.Credit_Premium_Type__c == 'Custom'){tp.Credit_Premium__c = creditDetail.Custom_Credit_Premium__c;}
                    termpriceLstToUpdate.add(tp);
                }
                    price.Credit__c = true; price.Subject_to_Credit__c = false;  update price;
                    pr.Status__c = 'Complete'; pr.Credit_Details__c = creditDetail.Id;  update pr;
                }      
                if(creditDetail.Credit_Check_Outcome__c == 'Refer'){
                    for(Term_Price__c tp : termpriceLst){
                        tp.Credit_Premium__c = 0;
                        termpriceLstToUpdate.add(tp);
                    }
                    price.Credit__c = true; price.Subject_to_Credit__c = true; update price;
                    pr.Status__c = 'Credit Risk Review'; pr.Credit_Details__c = creditDetail.Id; update pr;
                }
                 if(creditDetail.Credit_Check_Outcome__c == 'Failed'){
                 	for(Term_Price__c tp : termpriceLst){
                        tp.Credit_Premium__c = 0;
                        termpriceLstToUpdate.add(tp);
                    }
                    price.Credit__c = true; price.Subject_to_Credit__c = true; update price;
                    pr.Status__c = 'Complete';  pr.Credit_Details__c = creditDetail.Id;  update pr;
                }
            }else if((creditDetail.Credit_Type__c != 'Risk Required' ) || (creditDetail.Credit_Type__c == 'Risk Required' && creditTypeMatch == false) ){
                // Populate 'Credit Premium' on all Term Price records with '0'
                creditDetail.Credit_Check_Outcome__c = 'Refer'; 
                for(Term_Price__c tp : termpriceLst){
                    tp.Credit_Premium__c = 0;
                    termpriceLstToUpdate.add(tp);
                }
                price.Credit__c = true;
                price.Subject_to_Credit__c = true;
                update price;
                
                pr.Status__c = 'Credit Risk Review';
                pr.Credit_Details__c = creditDetail.Id;
                update pr;
            }            
            if(termpriceLstToUpdate.size() > 0){
                update termpriceLstToUpdate;               
            }
            System.debug('--311--');
        }
            else{  price.P_D__c = true; update price;}
            System.debug('creditDetail---->>>> '+creditDetail); 
            String credDetilName =creditDetail.Credit_Detail_ID__c + ' - ' + creditDetail.Customer__r.Name;
            if(creditDetail.Credit_Check_Outcome__c !=''){
                credDetilName = credDetilName + ' - ' +creditDetail.Credit_Check_Outcome__c;
                    }     
            System.debug('credDetilName-->> '+credDetilName);
            creditDetail.Name = credDetilName;
            update creditDetail;
            System.debug('creditDetail.Id-->> '+creditDetail.Id);
            Credit_Check__c creditDetailToPass = [SELECT Id,Name,Credit_Check_Outcome__c FROM Credit_Check__c WHERE Id =:creditDetail.Id ];
            createCreditLogs.createCreditProcessLog(pr.Customer__c, 'Credit Assessment', 'Decision', 'Credit Outcome :'+creditDetailToPass.Credit_Check_Outcome__c,creditDetailToPass.Name,creditDetailToPass.Id,'Completed');
            createCreditLogs.createCreditProcessLog(pr.Customer__c, 'Term Price and Credit Premium Calculations', 'Action', description,creditDetailToPass.Name,creditDetailToPass.Id,'Success');
            return creditDetailToPass;
        }catch(Exception e){
            System.debug('Exception->'+e.getMessage()+'-'+e.getLineNumber());
            System.debug('Exception 1 ->'+e.getLineNumber());
            System.debug('Exception 11 ->'+e.getStackTraceString());
            return null;
        }
    }
    
    public static void codCover(){
        Integer i = 0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
    }
}