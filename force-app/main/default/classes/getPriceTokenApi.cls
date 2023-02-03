public class getPriceTokenApi {
 
    public static String token()
    {
        String todaysdate=String.valueOf(DateTime.now());
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        PageReference ref = new PageReference('https://contoso.com/');
        String Endpoint=System.Label.get_Price_Token_Access_Token_URL;
        
        request.setEndpoint(Endpoint);
        request.setMethod('POST');
        request.setHeader('Content-Type','application/x-www-form-urlencoded');
        Map<String, String> params = new Map<String, String>();
        params.put('client_id',System.Label.get_Price_Token_Client_Id);
       	params.put('client_secret', System.Label.get_Price_Token_Client_Secret);
        params.put('scope', System.Label.get_Price_Token_Scope);
       	params.put('grant_type', 'client_credentials');
        ref.getParameters().putAll(params);
        Url finalUrl = new Url(ref.getUrl());
      
        request.setBody(finalUrl.getQuery());
        
        

        HTTPResponse response = http.send(request);
        System.debug('reponse-->' + response.getBody());
     	
        Map<String, object> m = (Map<String, object>) JSON.deserializeUntyped(response.getBody());
		System.debug('access -->'+String.valueOf(m.get('access_token')));
        String access_token = String.valueOf(m.get('access_token'));
        return access_token;
    }
    
    
    
	
    
}