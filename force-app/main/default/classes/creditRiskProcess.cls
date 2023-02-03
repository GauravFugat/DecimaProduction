public class creditRiskProcess {
    public class DataWrapper {
        @InvocableVariable(label='Record ID' required=true)
        public String recordID;
        @InvocableVariable(label='fromPB' required=true)
        public boolean fromPB;
    }
    @invocableMethod(Label='creditRiskProcess')
    public static void InvokeCreditRiskProcess(List<DataWrapper> dataWrapper){
        if(dataWrapper[0].fromPB){
            process(dataWrapper[0].recordID);
        }
    }
    public static void process(Id creditDetailId){
        System.debug('process');
        Map<Id,List<Term_Price__c>> priceAndTermMap = new Map<Id,List<Term_Price__c>>();
        Map<Id,List<Price_Summary__c>> priceAndPriceSummaryMap = new Map<Id,List<Price_Summary__c>>();
        List<Term_Price__c> termPriceLstToUpdate = new List<Term_Price__c>();
        List<Price_Summary__c> priceSummaryLstToUpdate = new List<Price_Summary__c>();
        Set<Id> pricingReqIds = new Set<Id>();
        Credit_Check__c cc = [SELECT Id,
                              Credit_Check_Outcome__c,
                              Credit_Type__c,
                              Credit_Rank_Formula__c,
                              Credit_Premium_Type__c,
                              Custom_Credit_Premium__c
                              FROM Credit_Check__c 
                              WHERE Id =: creditDetailId];
        System.debug('cc-->'+cc);
        
        List<Price__c> tmpprLst = new List<Price__c>();
                tmpprLst = [SELECT Id,
                         Product__c,
                         Price_Type__c,
                         Notes__c,
                         Pricing_Request__c,
                         Bill_Type__c,
                         Invoice_Billing_Type__c,
                         Voluntary_RECs__c,
                         Treatment__c,
                         Voluntary_RECs_percent__c,
                         P_D__c,
                         CreatedDate,
                         Credit__c,
                         Subject_to_Credit__c,
                         Prepayment_Amount__c,
                         Deposit_Amount__c,
                         Credit_Detail__c,
                         Opportunity__c,
                         Opportunity__r.isClosed,
                         Opportunity__r.OwnerId,
                         (SELECT Id FROM Price_Summaries__r),
                         (SELECT Id, Name,Utility__r.S1__c,Utility__r.S2__c,Utility__r.S3__c,Utility__r.S4__c,Utility__r.S5__c,Utility__r.S6__c,Utility__r.S7__c, Base_Price__c, Price__c, Term__c, Volume__c, Cumulative_Volume__c, Load_Factor_Decimal__c, Load_Factor__c, Load_Factor_x_Volume__c, Month__c, Opportunity__c, POR__c, POR_x_Volume__c, Price_x_Vol__c, Tax__c, Tax_x_Volume__c, Temp__c, UAO_Status__c, Utility_Account_Opportunity__c, Utility__c, Year__c, Profile_Off_Peak__c, Profile_On_Peak__c, Term_New__c, Credit_Premium__c, Base_Price_with_Credit_Premium__c, Base_Price_with_Credit_x_Volume__c, Annual_Usage__c, Annual_Usage_x_UAR__c, Include_in_Price_Summary__c FROM Term_Prices__r)
                         FROM Price__c WHERE Credit_Detail__c =: creditDetailId];
                
       	List<Price__c> prLst = new List<Price__c>();
        for(Price__c pr : tmpprLst){
         	if (!pr.Opportunity__r.isClosed)
                prLst.add(pr);
        }
        if(cc.Credit_Check_Outcome__c == 'Passed' && (cc.Credit_Type__c == 'Auto' || cc.Credit_Type__c == 'Risk Required' || cc.Credit_Type__c == 'MAC' )){
            if(cc.Credit_Premium_Type__c != 'Custom' && cc.Credit_Premium_Type__c != '' && cc.Credit_Premium_Type__c != null){                
                system.debug('prLst-->'+prLst);
               // system.debug('prLst-->'+prLst.size());
                Set<Id> PriceIds = new Set<Id>();
                List<Price__c> prLstToInsert = new List<Price__c>();
                List<Term_Price__c> termPriceLst = new List<Term_Price__c>();
                for(Price__c pr : prLst){
                    PriceIds.add(pr.Id);
                    priceAndTermMap.put(pr.Id,pr.Term_Prices__r);
                    priceAndPriceSummaryMap.put(pr.id,pr.price_summaries__r);
                    termPriceLst.addAll(priceAndTermMap.get(pr.Id));
                }
                System.debug('prLst-->'+prLst);
                List<Price_Summary__c> pr_Sum_lst = new List<Price_Summary__c>();
                Set<Price_Summary__c> pr_Sum_lstToDeleteSet = new Set<Price_Summary__c>();
                integer i = 1;
                boolean sendOnce = false;
                boolean sendOnce1 = false;
                boolean sendOnce2 = false;
                boolean sendOnce3 = false;
                for(Price__c price : prLst){
                    pricingReqIds.add(price.Pricing_Request__c);
                   // pr_Sum_lst.addAll(Create_Price_Summary_Asynchronous.returnGetTermPrice2(new List<Id>{price.Id}));
                   // pr_Sum_lstToDeleteSet.addAll(priceAndPriceSummaryMap.get(price.Id));
                    System.debug('131price.Credit__c '+price.Credit__c );
                    System.debug('132 price.Subject_to_Credit__c'+ price.Subject_to_Credit__c);
                    System.debug('133price.CreatedDate.date()'+price.CreatedDate.date());
                    System.debug('134cc.Credit_Type__c'+cc.Credit_Type__c);
                    System.debug('135price.Term_Prices__r[0].Credit_Premium__c'+price.Term_Prices__r[0].Credit_Premium__c);
                    System.debug('136cc.Credit_Rank_Formula__c'+cc.Credit_Rank_Formula__c);
                    System.debug('137cc.Credit_Premium_Type__c-'+cc.Credit_Premium_Type__c);
                    System.debug('169price.CreatedDate.date()'+price.CreatedDate.date());
                    if(price.Credit__c == true && price.Subject_to_Credit__c == true && cc.Credit_Rank_Formula__c != cc.Credit_Premium_Type__c && price.CreatedDate.date() == System.today() ){
                        clonePriceRecord(price.Id,true,i);
                        price.Latest_Price__c = false;
                        System.debug('---142---'); 
                        if(sendOnce2 == false){
                            Messaging.CustomNotification notification = new Messaging.CustomNotification();
                            notification.setBody('A new price is available for quoting including credit premium');
                            notification.setTitle('Credit Risk Review');	
                            notification.setSenderId(Userinfo.getUserId());
                            CustomNotificationType type = [SELECT Id FROM CustomNotificationType WHERE DeveloperName = 'Stat_Dates_Update_Of_UA'];
                            notification.setNotificationTypeId(type.id);
                            notification.setTargetId(prLst[0].Opportunity__r.Id); // target object id
                            notification.send(new Set<String> { prLst[0].Opportunity__r.OwnerId });
                            sendOnce2 = true;
                        }                        
                    }                 
                    else if(price.Credit__c == true && price.Subject_to_Credit__c == true && price.CreatedDate.date() == System.today() && (cc.Credit_Type__c == 'MAC' || cc.Credit_Type__c == 'Risk Required') && (price.Term_Prices__r[0].Credit_Premium__c == 0 || price.Term_Prices__r[0].Credit_Premium__c == null)){
                        clonePriceRecord(price.Id,true,i); price.Latest_Price__c = false;
                        System.debug('---157---');
                        if(sendOnce3 == false){
                            Messaging.CustomNotification notification = new Messaging.CustomNotification();
                            notification.setBody('A new price is available for quoting including credit premium');
                            notification.setTitle('Credit Risk Review');	
                            notification.setSenderId(Userinfo.getUserId());
                            CustomNotificationType type = [SELECT Id FROM CustomNotificationType WHERE DeveloperName = 'Stat_Dates_Update_Of_UA'];
                            notification.setNotificationTypeId(type.id);
                            notification.setTargetId(prLst[0].Opportunity__r.Id); // target object id
                            notification.send(new Set<String> { prLst[0].Opportunity__r.OwnerId });
                            sendOnce3 = true;
                        }
                    }
                    else if(sendOnce == false && price.Credit__c == true && price.Subject_to_Credit__c == true && cc.Credit_Rank_Formula__c != cc.Credit_Premium_Type__c && price.CreatedDate.date() < System.today()){
                        Messaging.CustomNotification notification = new Messaging.CustomNotification();
                        notification.setBody('Credit has passed but they must re-submit a pricing request/refresh to be obtain valid prices including credit premium');
                        notification.setTitle('Credit Risk Review');	
                        notification.setSenderId(Userinfo.getUserId());
                        CustomNotificationType type = [SELECT Id FROM CustomNotificationType WHERE DeveloperName = 'Stat_Dates_Update_Of_UA'];
                        notification.setNotificationTypeId(type.id);
                        notification.setTargetId(prLst[0].Opportunity__c); // target object id
                        notification.send(new Set<String> { prLst[0].Opportunity__r.OwnerId });
                        sendOnce = true; price.Obsolete__c = true;
                    }
                    else if(sendOnce1 == false && price.Credit__c == true && price.Subject_to_Credit__c == true && price.CreatedDate.date() < System.today() && (cc.Credit_Type__c == 'MAC' || cc.Credit_Type__c == 'Risk Required') && (price.Term_Prices__r[0].Credit_Premium__c == 0 || price.Term_Prices__r[0].Credit_Premium__c == null)){
                        Messaging.CustomNotification notification = new Messaging.CustomNotification();
                        notification.setBody('Credit has passed but they must re-submit a pricing request/refresh to be obtain prices including credit premium');
                        notification.setTitle('Credit Risk Review');	
                        notification.setSenderId(Userinfo.getUserId());
                        CustomNotificationType type = [SELECT Id FROM CustomNotificationType WHERE DeveloperName = 'Stat_Dates_Update_Of_UA'];
                        notification.setNotificationTypeId(type.id);
                        notification.setTargetId(prLst[0].Opportunity__c); // target object id
                        notification.send(new Set<String> { prLst[0].Opportunity__r.OwnerId });
                        sendOnce1 = true; price.Obsolete__c = true;
                    }
                    i++;
                }
                List<Pricing_Request__c> prReqLst = new List<Pricing_Request__c>();
                prReqLst = [SELECT Id FROM Pricing_Request__c WHERE Id IN: pricingReqIds];
                for(Pricing_Request__c prReq : prReqLst){
                    prReq.Status__c = 'Complete';
                }
                update prLst;
                update prReqLst;
                
            }
            else if(cc.Credit_Premium_Type__c == 'Custom'){
                
                Set<Id> PriceIds = new Set<Id>();
                List<Price__c> prLstToInsert = new List<Price__c>();
                List<Term_Price__c> termPriceLst = new List<Term_Price__c>();
                for(Price__c pr : prLst){
                    PriceIds.add(pr.Id);
                    priceAndTermMap.put(pr.Id,pr.Term_Prices__r);
                    priceAndPriceSummaryMap.put(pr.id,pr.price_summaries__r);
                    termPriceLst.addAll(priceAndTermMap.get(pr.Id));
                }
                Boolean creditPremiumApplied = true;
                if (prLst != null && prLst.size() > 0){
                    if(prLst[0].Term_Prices__r[0].Credit_Premium__c == 0 || prLst[0].Term_Prices__r[0].Credit_Premium__c == null ){
                        creditPremiumApplied = false;
                    }
                }
                List<Price_Summary__c> pr_Sum_lst = new List<Price_Summary__c>();
                Set<Price_Summary__c> pr_Sum_lstToDeleteSet = new Set<Price_Summary__c>();
                integer i = 1;
                boolean sendOnce = false;
                boolean sendOnce1 = false;
                boolean sendOnce2 = false;
                for(Price__c price : prLst){
                    pricingReqIds.add(price.Pricing_Request__c);
                   // pr_Sum_lst.addAll(Create_Price_Summary_Asynchronous.returnGetTermPrice2(new List<Id>{price.Id}));
                  //  pr_Sum_lstToDeleteSet.addAll(priceAndPriceSummaryMap.get(price.Id));
                    if(price.Credit__c == true && price.Subject_to_Credit__c == true && price.CreatedDate.date() == System.today() && creditPremiumApplied == false){
                        clonePriceRecord(price.Id,true,i);
                        price.Latest_Price__c = false;
                        System.debug('---282---');
                        if(sendOnce2 == false){
                            Messaging.CustomNotification notification = new Messaging.CustomNotification();
                            notification.setBody('A new price is available for quoting including credit premium');
                            notification.setTitle('Credit Risk Review');	
                            notification.setSenderId(Userinfo.getUserId());
                            CustomNotificationType type = [SELECT Id FROM CustomNotificationType WHERE DeveloperName = 'Stat_Dates_Update_Of_UA'];
                            notification.setNotificationTypeId(type.id);
                            notification.setTargetId(prLst[0].Opportunity__r.Id); // target object id
                            notification.send(new Set<String> { prLst[0].Opportunity__r.OwnerId });
                            sendOnce2 = true;
                        }
                    }
                    else if(sendOnce1 == false && price.Credit__c == true && price.Subject_to_Credit__c == true && price.CreatedDate.date() < System.today() && creditPremiumApplied == false){
                       System.debug('---299---');
                        Messaging.CustomNotification notification = new Messaging.CustomNotification();
                        notification.setBody('Credit has passed but they must re-submit a pricing request/refresh to be obtain prices including credit premium');
                        notification.setTitle('Credit Risk Review (Custom Credit)');	
                        notification.setSenderId(Userinfo.getUserId());
                        CustomNotificationType type = [SELECT Id FROM CustomNotificationType WHERE DeveloperName = 'Stat_Dates_Update_Of_UA'];
                        notification.setNotificationTypeId(type.id);
                        notification.setTargetId(prLst[0].Opportunity__c); // target object id
                        notification.send(new Set<String> { prLst[0].Opportunity__r.OwnerId });
                        sendOnce1 = true;
                        price.Obsolete__c = true;
                        System.debug('---310---');
                    }
                    i++;
                }
                
                creditProcess_Notifications.values val = new creditProcess_Notifications.values();
                val.EmaiTemplateName = 'Greater_than_40k_Credit_Limit_Credit_Type_Risk_Required_OR_MAC_Passed';
                val.recordId = cc.Id;
                val.includeCreditPremium = true;
                if(!test.isRunningTest()){
                    creditProcess_Notifications.invokeCallConga(new List<creditProcess_Notifications.values>{val});
                }
                //List<Price__c> priceLst = [SELECT Id FROM Price__c where Credit_Detail__c =: prLst[0].Credit_Detail__c];
                
                List<Pricing_Request__c> prReqLst = new List<Pricing_Request__c>();
                prReqLst = [SELECT Id FROM Pricing_Request__c WHERE Id IN: pricingReqIds];
                for(Pricing_Request__c prReq : prReqLst){
                    prReq.Status__c = 'Complete';
                }
               // List<Price_Summary__c> pr_Sum_lstToDelete = new List<Price_Summary__c>(pr_Sum_lstToDeleteSet);
               // delete pr_Sum_lstToDelete;
              //  insert pr_Sum_lst;
                update prLst;
                System.debug('prReqLst->'+prReqLst);
                update prReqLst;
            }
        }
    }
    //@future
    public static void clonePriceRecord(Id priceId,boolean notify,Integer size){
        System.debug('clonePriceRecord');
        List<Price__c> prLstToUpdate = new List<Price__c>();
        List<Price__c> prLst = [SELECT Id,
                                Product_Lookup__c,
                                Price_Type__c,
                                Notes__c,
                                Pricing_Request__c,
                                Bill_Type__c,
                                Invoice_Billing_Type__c,
                                Voluntary_RECs__c,
                                Treatment__c,
                                Voluntary_RECs_percent__c,
                                P_D__c,
                                Opportunity__r.OwnerId,
                                Opportunity__r.Id,
                                Credit__c,
                                Subject_to_Credit__c,
                                Prepayment_Amount__c,
                                Deposit_Amount__c,
                                Credit_Detail__c,
                                Opportunity__c,
                                (SELECT Id FROM Price_Summaries__r),
                                (SELECT Id, Name,Utility__r.S1__c,Utility__r.S2__c,Utility__r.S3__c,Utility__r.S4__c,Utility__r.S5__c,Utility__r.S6__c,Utility__r.S7__c, Base_Price__c, Price__c, Term__c, Volume__c, Cumulative_Volume__c, Load_Factor_Decimal__c, Load_Factor__c, Load_Factor_x_Volume__c, Month__c, Opportunity__c, POR__c, POR_x_Volume__c, Price_x_Vol__c, Tax__c, Tax_x_Volume__c, Temp__c, UAO_Status__c, Utility_Account_Opportunity__c, Utility__c, Year__c, Profile_Off_Peak__c, Profile_On_Peak__c, Term_New__c, Credit_Premium__c, Base_Price_with_Credit_Premium__c, Base_Price_with_Credit_x_Volume__c, Annual_Usage__c, Annual_Usage_x_UAR__c, Include_in_Price_Summary__c FROM Term_Prices__r)
                                FROM Price__c WHERE Id =: priceId];
        Credit_Check__c cc = [SELECT Id,Credit_Premium__c,Credit_Premium_Type__c,Custom_Credit_Premium__c FROM Credit_Check__c WHERE Id =: prLst[0].Credit_Detail__c];
        //List<Price__c> priceLstNew = [SELECT Id,Latest_Price__c FROM Price__c WHERE Opportunity__c =: prLst[0].Opportunity__c AND Id !=: priceId];
        List<Price__c> priceLstNew = [SELECT Id,Latest_Price__c FROM Price__c WHERE Pricing_Request__c =: prLst[0].Pricing_Request__c AND Id !=: priceId];
        for(Price__c priceObj : priceLstNew){
            priceObj.Latest_Price__c = false;
        }
        prLst[0].Obsolete__c = true;
        prLst[0].Latest_Price__c = false;
        prLstToUpdate.add(prLst[0]);
        prLstToUpdate.addAll(priceLstNew);
        update prLstToUpdate;
        prLst[0].Id = null;
        prLst[0].Latest_Price__c = true;
        prLst[0].Subject_to_credit__c = false;
        prLst[0].Obsolete__c = false;
        insert prLst[0];
        List<Term_Price__c> tpLst = [SELECT Id,Name,Utility_Account_Opportunity__r.Status__c,Utility_Account_Opportunity__r.Start_Date__c,Utility_Account_Opportunity__r.Utility_Account__c,Utility__r.S1__c,Utility__r.S2__c,Utility__r.S3__c,Utility__r.S4__c,Utility__r.S5__c,Utility__r.S6__c,Utility__r.S7__c, Base_Price__c, Price__c, Term__c, Volume__c, Cumulative_Volume__c, Load_Factor_Decimal__c, Load_Factor__c, Load_Factor_x_Volume__c, Month__c, Opportunity__c, POR__c, POR_x_Volume__c, Price_x_Vol__c, Tax__c, Tax_x_Volume__c, Temp__c, UAO_Status__c, Utility_Account_Opportunity__c, Utility__c, Year__c, Profile_Off_Peak__c, Profile_On_Peak__c, Term_New__c, Credit_Premium__c, Base_Price_with_Credit_Premium__c, Base_Price_with_Credit_x_Volume__c, Annual_Usage__c, Annual_Usage_x_UAR__c, Include_in_Price_Summary__c FROM Term_Price__c WHERE Price__c =: priceId]; 
        for(Term_Price__c tp : tpLst){
            tp.Id = null;
            tp.Price__c = prLst[0].Id;
            if(cc.Credit_Premium_Type__c == 'S1'){
                tp.Credit_Premium__c = tp.Utility__r.S1__c;
            }
            else if(cc.Credit_Premium_Type__c == 'S2'){
                tp.Credit_Premium__c = tp.Utility__r.S2__c;
            }
            else if(cc.Credit_Premium_Type__c == 'S3'){
                tp.Credit_Premium__c = tp.Utility__r.S3__c;
            }
            else if(cc.Credit_Premium_Type__c == 'S4'){
                tp.Credit_Premium__c = tp.Utility__r.S4__c;
            }
            else if(cc.Credit_Premium_Type__c == 'S5'){
                tp.Credit_Premium__c = tp.Utility__r.S5__c;
            }
            else if(cc.Credit_Premium_Type__c == 'S6'){
                tp.Credit_Premium__c = tp.Utility__r.S6__c;
            }
            else if(cc.Credit_Premium_Type__c == 'S7'){
                tp.Credit_Premium__c = tp.Utility__r.S7__c;
            }
            else if(cc.Credit_Premium_Type__c == 'Custom'){
                tp.Credit_Premium__c = cc.Custom_Credit_Premium__c;
            }
        }
        insert tpLst;
        Call_Create_Price_Summary.getTermPriceRecords(new List<Id>{prLst[0].Id}, tpLst);
        
    }
    
    public class dataWrap{
        public String datEWrap1 {get;set;}
        public String datEWrap2 {get;set;}
        public String datEWrap3 {get;set;}
        public String datEWrap4 {get;set;}
        public String datEWrap5 {get;set;}
        public String datEWrap6 {get;set;}
        public String datEWrap7 {get;set;}
        public String datEWrap8 {get;set;}
        public String datEWrap9 {get;set;}
        public String datEWrap10 {get;set;}
        public String datEWrap11 {get;set;}
        public String datEWrap12 {get;set;}
        public String datEWrap13 {get;set;}
        public String datEWrap14 {get;set;}
        public String datEWrap15 {get;set;}
        public String datEWrap16 {get;set;}
        public String datEWrap17 {get;set;}
        public String datEWrap18 {get;set;}
        public String datEWrap19 {get;set;}
        public String datEWrap20 {get;set;}
        public String datEWrap21 {get;set;}
        public String datEWrap22 {get;set;}
    }
}