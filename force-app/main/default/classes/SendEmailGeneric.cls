public class SendEmailGeneric {
    public List<String> emailXMLlist;
    public List<String> resultList;
	public List<Integer> Codes;
    public String serviceEndpoint;
    
  
    public static Messaging.SingleEmailMessage sendEmailBodyJson(String response, string request,string result, Integer code, String serviceEndpoint, Id oweaId){
        							
        
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();   
        message.toAddresses = new String[System.Label.Pricing_Integration_Email_Addresses .split(',')];
   
        message.subject = 'Result = ' + result + ' - Status Code = ' + code +' - SCOPE - ' + serviceEndpoint + '- Request Body Initiaited By - ' + UserInfo.getFirstName() + ' ' + UserInfo.getLastName();
        message.setOrgWideEmailAddressId(oweaId);
        if(request != NULL){
        	message.plainTextBody = 'Request : \n\n'+request+'\n\n Response : \n'+response ;    
        }
        
        return message;
    }
}