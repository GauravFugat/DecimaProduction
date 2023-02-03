public class Wrapper_UbEnrollmentResponse {
	public String AdditionalInfo;
    public String ErrorCode;
    public String ErrorMessage;
    public String Status;
    public String MarketarAccountNumberResp;
    public String strBody;
   // public String requestBody;
    public Integer statusCode;
    public String substr;
    public String emailXML;
    public String emailXML2;
    public String requestXML;
    Public String result;
    public String result2;
    Public String faultString;
    public Wrapper_UbEnrollmentResponse(String response, Integer code, String result, String emailXML, String requestXML) {
        try{
            if (code == 200 || code == 201)
            {
                if (response.indexOf('<a:faultstring>') != -1)
                    faultString = response.substring(response.indexOf('<a:faultstring>') + 15, response.indexOf('</a:faultstring>'));
                if (response.indexOf('<a:AdditionalInfo>') != -1)
                    AdditionalInfo = response.substring(response.indexOf('<a:AdditionalInfo>') + 18, response.indexOf('</a:AdditionalInfo>'));
                if (response.indexOf('<a:ErrorCode>') != -1)
                    ErrorCode = response.substring(response.indexOf('<a:ErrorCode>') + 13, response.indexOf('</a:ErrorCode>'));
                if (response.indexOf('<a:ErrorMessage>') != -1)
                    ErrorMessage = response.substring(response.indexOf('<a:ErrorMessage>') + 16, response.indexOf('</a:ErrorMessage>'));
                if (response.indexOf('<a:Status>') != -1)
                    Status = response.substring(response.indexOf('<a:Status>') + 10 , response.indexOf('</a:Status>'));
                //MarketarAccountNumberResp = response.substring(response.indexOf('Marketer Account Number : '), response.indexOf('. See the AdditionalInfo'));
                //substr = response.substringBetween('Marketer Account Number : ', '. See the AdditionalInfo');
            
            }
        }catch(Exception ex){
            System.Debug('Response Parsing Exception - ' + ex.getMessage());
        }
        
        strBody = response;
        statusCode = code;
        this.result = result;
        this.emailXML = emailXML;
        this.requestXML = requestXML;
        this.emailXML2 = emailXML;
        this.result2 = result;
    	
    }
	/*public Wrapper_UbEnrollmentResponse(String response, String request) {
        AdditionalInfo = response.substring(response.indexOf('<a:AdditionalInfo>'), response.indexOf('</a:AdditionalInfo>'));
        ErrorCode = response.substring(response.indexOf('<a:ErrorCode>'), response.indexOf('</a:ErrorCode>'));
        ErrorMessage = response.substring(response.indexOf('<a:ErrorMessage>'), response.indexOf('</a:ErrorMessage>'));
        Status = response.substring(response.indexOf('<a:Status>'), response.indexOf('</a:Status>'));
        MarketarAccountNumberResp = response.substring(response.indexOf('Marketer Account Number : '), response.indexOf('. See the AdditionalInfo'));
        //substr = response.substringBetween('Marketer Account Number : ', '. See the AdditionalInfo');
        requestBody = request;
    } */     
}