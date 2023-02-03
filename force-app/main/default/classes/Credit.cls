public class Credit {
    //public static void createCreditDetail(String Opp, Boolean creditRequired, List<Pricing_Request__c> PricingRequest, String optionSelected, Credit_Check__c newCCRecord, Boolean callFromLoop){
   public static void createCreditDetail(List<Credit_Check__c> creditDetailLst,Opportunity getAccId, Boolean creditRequired, List<Pricing_Request__c> PricingRequest, String optionSelected, Credit_Check__c newCCRecord, Boolean callFromLoop){

        //Opportunity getAccId = [Select Id,Type,Name,OwnerId,AccountId,Existing_Contract__c from Opportunity where Id=:Opp];	
      //  List<Credit_Check__c> creditDetailLst = [SELECT Id,Pricing_Request_Status__c, Opportunity__c FROM Credit_Check__c where Customer__c =: getAccId.AccountId AND Status__c = 'Active'];
        if(callFromLoop == false){
            List<Process_Event__c> peToInsert = new List<Process_Event__c>();
            String StatusToSet = 'New';
            if(creditDetailLst.size()==0){	
                creditDetailLst = [SELECT Id, Name, Pricing_Request_Status__c, Opportunity__c FROM Credit_Check__c where Customer__c =: getAccId.AccountId AND Status__c = 'New'];	
            }
            System.debug('creditRequired->'+creditRequired);	
            System.debug('creditDetailLst->'+creditDetailLst);	
            if(creditRequired){
                if (optionSelected != 'Refresh')
                    peToInsert.add(createCreditLogs.createCreditProcessLogs(getAccId.AccountId, 'Pricing Request(s) requires Credit', 'Decision', 'New Pricing requests inserted',getAccId.Name,getAccId.Id,'True'));	
            }
            System.debug('creditRequired-->> '+creditRequired);
            if(creditDetailLst.size()==0 && creditRequired == true && optionSelected != 'Refresh'){        //Check if Credit Needed and if there is an existing Credit record ?	
                newCCRecord.Credit_Check_Outcome__c  = 'Pending';	
                newCCRecord.Customer__c = getAccId.AccountId;
                Insert newCCRecord;            
                newCCRecord = [SELECT Id,Name FROM Credit_Check__c WHERE Id =: newCCRecord.Id];	
                peToInsert.add(createCreditLogs.createCreditProcessLogs(getAccId.AccountId, 'Active/New Credit Present ?', 'Decision', 'New Credit record created , as no active credit record was present for the Customer.',newCCRecord.Name,newCCRecord.Id,'False'));	            
            }
            if(peToInsert.size() > 0){
                upsert peToInsert;
            }
        }
        if(callFromLoop == true){
            System.debug('in callFromLoop true');
            List<Process_Event__c> peToInsert = new List<Process_Event__c>();
            if(creditDetailLst.size() != 0 && creditRequired == true){
                newCCRecord = creditDetailLst[0];
            }
            if(creditRequired){
                System.debug('Credit Required');
                if(newCCRecord.Id == null){
                    newCCRecord.Credit_Check_Outcome__c  = 'Pending';
                    newCCRecord.Customer__c = getAccId.AccountId;
                    if(Test.isRunningTest()){
                        newCCRecord.Experian_Api_Call_Credit_Assessment__c = false;
                    }else{
                        newCCRecord.Experian_Api_Call_Credit_Assessment__c = true;
                    }
                    Insert newCCRecord;
                    peToInsert.add(createCreditLogs.createCreditProcessLogs(getAccId.AccountId, 'Active/New Credit Present ?', 'Decision', 'New Credit record created , as no active credit record was present for the Customer.',newCCRecord.Name,newCCRecord.Id,'False'));
                }
                else{
                   // newCCRecord = [SELECT Id,Name FROM Credit_Check__c WHERE Id =: newCCRecord.Id];
                    if(creditDetailLst.size() != 0){
                        //Comment/Changes related with card SU-865
                        peToInsert.add(createCreditLogs.createCreditProcessLogs(getAccId.AccountId, 'Active/New Credit Present ?', 'Decision', 'Active Credit record already present.',newCCRecord.Name,newCCRecord.Id,'True'));
                    }
                    if (optionSelected != 'Refresh'){
                        if(Test.isRunningTest()){
                            newCCRecord.Experian_Api_Call_Credit_Assessment__c = false;
                        }else{
                            System.debug('in else to update record');
                            newCCRecord.Experian_Api_Call_Credit_Assessment__c = true;
                        }
                        update newCCRecord;
                    }else{
                        System.debug('in else');
                        //List<Pricing_Request__c> prLst = [SELECT Id,Bill_Type__c,Name,Credit_Details__c  FROM Pricing_Request__c WHERE Id IN : PricingRequest];
                        List<Pricing_Request__c> prUpdate = new List<Pricing_Request__c>();
                        for(Pricing_Request__c p : PricingRequest){
                            System.debug('p-->> '+p);
                            System.debug('p.Bill_Type__c--<>> '+p.Bill_Type__c);
                            System.debug(' newCCRecord.Id--<<>> '+ newCCRecord.Id);
                            Group PORgr = [select Id from Group where  Type = 'Queue' AND NAME = 'Pricing Team' limit 1];
                            if(p.Bill_Type__c  != 'UCB'){
                                p.Credit_Details__c = newCCRecord.Id;
                                p.OwnerId = PORgr.Id;
                                prUpdate.add(p);
                            }
                        }
                        System.debug('prUpdate-->> '+prUpdate);
                        update prUpdate;
                        //update newCCRecord;
                        peToInsert.add(createCreditLogs.createCreditProcessLogs(getAccId.AccountId, 'Perform Credit Assessment', 'Decision', 'No action taken due to price refresh',getAccId.Name,getAccId.Id,'False'));
                    }
                }
                System.debug('peToInsert-->' + peToInsert);
                if(peToInsert.size() > 0){
                    upsert peToInsert;
                }
            }            
        }
    }
}