//SendUBEnrollmentBody_test
public class SendUBEnrollmentBody implements Queueable {
    
    public List<String> emailXMLlist;
    public List<String> resultList;
	public List<Integer> Codes;
    public String serviceEndpoint;
    
    public SendUBEnrollmentBody(List<String> emailXMLlist, List<String> resultList, List<Integer> Codes, String serviceEndpoint){
        this.emailXMLlist = emailXMLlist;
        this.resultList =resultList; 
        this.Codes = Codes;
        this.serviceEndpoint = serviceEndpoint;
        
    }
    //@future(callout=true)
    public static Messaging.SingleEmailMessage sendUBEnrollmentBody(String xml, string result, Integer code, String serviceEndpoint, Id oweaId){
        
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        system.debug('label' + System.Label.UB_Enrollment_Email_Addresses);
        message.toAddresses = new String[System.Label.UB_Enrollment_Email_Addresses.split(',')];
        System.debug('message.toAddresses-->>'+message.toAddresses);
        message.subject = 'Result = ' + result + ' - Status Code = ' + code +' - UB - ' + serviceEndpoint + '- Request Body Initiaited By - ' + UserInfo.getFirstName() + ' ' + UserInfo.getLastName();
        message.setOrgWideEmailAddressId(oweaId);
        message.plainTextBody = xml;
        return message;
        //Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {message};
          //  Messaging.SendEmailResult[] results = Messaging.sendEmail(messages); 
    }
    
    public void execute(QueueableContext context) {
        
        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'admin@decima.one'];
        Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage>();
        for (Integer i = 0; i < emailXMLlist.size(); i++){
            Messaging.SingleEmailMessage message = sendUBEnrollmentBody(emailXMLlist[i],resultList[i],Codes[i], serviceEndpoint, owea[0].Id);
            messages.add(message);
        }
        Messaging.SendEmailResult[] results = Messaging.sendEmail(messages); 
        
    }
    
}