global class CreatePricingRequestAPI {
    global static  List<commonParameters> commonParametersList = new List<commonParameters>();
   	global static  List<salesforceParameters> salesforceParametersList = new List<salesforceParameters>();
    global static List<accounts> accountsList = new List<accounts>();
	global static Map<String, Object> JsonParserMap = new Map<String, Object>();
    global static String ENDPOINT = System.Label.createPriceRequestBaseURL;
    Static String commonParameters = 'commonParameters';
    Static String salesforceParameters = 'salesforceParameters';
    Static String accounts =  'accounts';
    public static string responseBody;
    public static string requestBody;
    public static string result;
    public static Integer statusCode;
    global static Id PriceReqId;
    
    @invocableMethod(label='CreatePricingCallout')
    global static void makePostCallout(List<Id> PriceRequestId)
    {     
        Scope_Integration__c ScopeApi = [Select Callout__c from Scope_Integration__c limit 1];
                
        for (Id prId : PriceRequestId)
        {
            if (ScopeApi.Callout__c == true){            
                // we are sending first Pricing Request ID here as per existing logic assuming only on pricing request will be updated at a time 
                if(System.IsBatch() == false && System.isFuture() == false){ 
                    sendRequestBody(prId);
                }
            }else{
                InsertPricingReqIntegrationLog intLog = new InsertPricingReqIntegrationLog('Callout disabled in Custom Settings - [Scope Integration - Callout]','Callout disabled in Custom Settings - [Scope Integration - Callout]', 0,prId, 'Callout disabled in Custom Settings - [Scope Integration - Callout]', 'POST', '');
                System.enqueueJob(intLog);
            }
        }
        
    }

    private static String fetchRequestBody(Id PriceReqId) {
        List <Pricing_Request__c> pro = new List <Pricing_Request__c>();
        pro = [SELECT Product_Id__c,Request_Type__c,Voluntary_RECs__c,Voluntary_RECs_percent__c,Bill_Type__c,Customer__r.Name, Name,Due_Date__c,Mark_to_Market__c,
               Opportunity_ID__c, Customer__r.Customer_ID__c, Original_Pricing_Request__r.Name, Status__c, Urgent_Request__c, No_of_Utility_Accounts__c,
               Expected_Annual_Volume__c, Notes__c, Pricing_Quote_Comments__c, Treatment__c, Start_Dates__c, CPM__c,
               (select id,Utility_Account__r.Name, Utility_Account__r.Utility__r.Pricing_Name__c, Start_Date__c from Utility_Account_Pricing_Requests__r)
               FROM Pricing_Request__c where Id = :PriceReqId] ;
        system.debug('pro--------------->'+pro);
        System.debug('\n-----pricing request are ==' +  pro[0].Utility_Account_Pricing_Requests__r);
        DateTime DueDateTime,StartDateTime;
        Date DueDate,StartDate;
        Long DueDateEPOCH, StartDateEPOCH;
        commonParameters commonParametersTemp = new commonParameters();	
       	salesforceParameters salesforceParametersTemp = new salesforceParameters();
       //	accounts accountTemp = new  accounts();
        for(Pricing_Request__c  p : pro )       
        {            
            commonParameterstemp.productId=p.Product_Id__c;           
            if(p.Voluntary_RECs__c.equals('NA')){
                commonParameterstemp.recsType = NULL;
            }else{
                commonParameterstemp.recsType=p.Voluntary_RECs__c; 
            }
            if(p.Voluntary_RECs_percent__c != NULL){
                commonParameterstemp.voluntaryRecsPercentage = p.Voluntary_RECs_percent__c;
            }else{
                commonParameterstemp.voluntaryRecsPercentage = 0;
            }
            
            commonParameterstemp.billType = p.Bill_Type__c;
            commonParameterstemp.customerName = p.Customer__r.Name;
            commonParameterstemp.priceRequest = p.name;
            DueDate = p.Due_Date__c;
            DueDateTime  = datetime.newInstance(DueDate.year(), DueDate.month(),DueDate.day());
            DueDateEPOCH = DueDateTime.getTime();
            commonParameterstemp.dueDate = DueDateEPOCH;
            if(p.Mark_to_Market__c != NULL){
                commonParameterstemp.marketToMarket = Integer.valueOf(p.Mark_to_Market__c);
            }else{
                commonParameterstemp.marketToMarket = 0;
            }
            commonParameterstemp.contractId = p.Opportunity_ID__c;
            commonParameterstemp.customerId = p.Customer__r.Customer_ID__c;
            commonParametersList.add(commonParameterstemp);
            if(p.Original_Pricing_Request__r.Name != NULL){
                 salesforceParametersTemp.originalRequest = p.Original_Pricing_Request__r.Name;
            }else{
                salesforceParametersTemp.originalRequest = '';
            }
            salesforceParametersTemp.status = p.Status__c;
            salesforceParametersTemp.requestType = p.Request_Type__c;
            salesforceParametersTemp.isUrgent = p.Urgent_Request__c;
            salesforceParametersTemp.numberOfAccounts = p.No_of_Utility_Accounts__c;
            salesforceParametersTemp.expectedAnnualVolume = p.Expected_Annual_Volume__c;
            if(p.Notes__c != NULL ){
                salesforceParametersTemp.notes =p.Notes__c;
            }else{
                salesforceParametersTemp.notes = '';
            }
            if(p.Pricing_Quote_Comments__c != NULL ){
                salesforceParametersTemp.pricingQuoteComments = p.Pricing_Quote_Comments__c;                
            }else{
                salesforceParametersTemp.pricingQuoteComments = '';
            }            
            if(p.Treatment__c == NULL)
            {
                salesforceParametersTemp.treatment = 'None';
            }else{
                salesforceParametersTemp.treatment = p.Treatment__c;
            }
            salesforceParametersTemp.startDates= p.Start_Dates__c;
            salesforceParametersTemp.cpm = p.CPM__c;
            salesforceParametersTemp.linkedDocumentId = PriceReqId;
            salesforceParametersList.add(salesforceParametersTemp);
			System.debug('\n-----pricing request are ==' +  p.Utility_Account_Pricing_Requests__r);
            for(Utility_Account_Pricing__c u: p.Utility_Account_Pricing_Requests__r){ 
                 accounts accountTemp = new  accounts();
                accountTemp.accountNumber = u.Utility_Account__r.Name;
                accountTemp.utility = u.Utility_Account__r.Utility__r.Pricing_Name__c;  
                StartDate = u.Start_Date__c;
           	 	StartDateTime  = datetime.newInstance(StartDate.year(), StartDate.month(),StartDate.day());
            	StartDateEPOCH = StartDateTime.getTime();
                accountTemp.startDate = StartDateEPOCH;
                accountsList.add(accountTemp);  
            }                
        } 
        JsonParserMap.put(commonParameters, commonParametersList[0]);
        JsonParserMap.put(salesforceParameters, salesforceParametersList[0]);
        JsonParserMap.put(accounts, accountsList);        
        string jsondata = json.serialize(JsonParserMap);
        //String reqBody=jsondata.replace('\\','');
        return jsondata;
    }
        
    @future (callout = true)
    global static void sendRequestBody( Id PriceReqId){
        String jsondata = fetchRequestBody(PriceReqId); 
        Http  h = new Http();
        HttpRequest request = new HttpRequest();
        request.setMethod('POST');
        string bearerToken = getPriceTokenApi.token();
        request.setHeader('Authorization', 'Bearer '+bearerToken);
        request.setHeader('Accept', '*/*');
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Ocp-Apim-Subscription-Key',System.Label.create_price_Ocp_Apim_Subscription_Key);
        request.setEndpoint(ENDPOINT);              
        System.debug('jsondata -->'+jsondata);
        request.setBody(jsondata);
        request.setTimeout(120000);
       	HttpResponse response = h.send(request);           
        responseBody =  response.getBody();          
        result = response.getStatus();
        statusCode = response.getStatusCode();
        requestBody = request.getBody();       
        InsertPricingReqIntegrationLog intLog = new InsertPricingReqIntegrationLog(requestBody,responseBody, statusCode,PriceReqId, ENDPOINT, 'POST',result );
        System.enqueueJob(intLog);
        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where DisplayName = 'SmartestEnergy Support'];             
        Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage message = SendEmailGeneric.sendEmailBodyJson(responseBody,requestBody, result, statusCode, 'Pricing', owea[0].Id);
        messages.add(message);
        Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
   	 }
    /*public static Messaging.SingleEmailMessage sendPricingRequestBodyJson(String json, string request,string result, Integer code, String serviceEndpoint, Id oweaId){
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        system.debug('label' + System.Label.Pricing_Integration_Email_Addresses );
        message.toAddresses = new String[System.Label.Pricing_Integration_Email_Addresses .split(',')];
        System.debug('message.toAddresses-->>'+message.toAddresses);
        message.subject = 'Result = ' + result + ' - Status Code = ' + code +' - SCOPE - ' + serviceEndpoint + '- Request Body Initiaited By - ' + UserInfo.getFirstName() + ' ' + UserInfo.getLastName();
        message.setOrgWideEmailAddressId(oweaId);
        message.plainTextBody = 'Response : \n\n'+json+'\n\n Request : \n'+request ;
        return message;
        //Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {message};
          //  Messaging.SendEmailResult[] results = Messaging.sendEmail(messages); 
    }*/
	global class JsonParser{
		global commonParameters commonParameters{get;set;}
		global list<accounts> accounts{get;set;}
		global salesforceParameters salesforceParameters{get;set;}
	}
	global class salesforceParameters{
		global String requestType{get;set;}
		global Boolean isUrgent{get;set;}
		global String status{get;set;}
		global Decimal numberOfAccounts{get;set;}
		global String originalRequest{get;set;}
		global Decimal expectedAnnualVolume{get;set;}
		global String treatment{get;set;}
		global String startDates{get;set;}
		global String pricingQuoteComments{get;set;}
		global String cpm{get;set;}
		global String notes{get;set;}
        global String linkedDocumentId{get;set;}
	}
	global class commonParameters{
		global Integer marketToMarket{get;set;}
		global Long dueDate{get;set;}
		global String priceRequest{get;set;}
		global String contractId{get;set;}
		global String customerName{get;set;}
		global String customerId{get;set;}
		global String billType{get;set;}
		global String recsType{get;set;}
		global Decimal voluntaryRecsPercentage{get;set;}
		global String productId{get;set;}
	}
	global class accounts{
		global String accountNumber{get;set;}
		global Long startDate{get;set;}
		global String utility{get;set;}
    }	
}