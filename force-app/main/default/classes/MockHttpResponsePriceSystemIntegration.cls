@isTest
global class MockHttpResponsePriceSystemIntegration implements HttpCalloutMock {

    
    global HttpResponse respond(HttpRequest req){
        HttpResponse res1 = new HttpResponse();
        res1.setHeader('Content-Type', 'application/json');
        res1.setbody('{"Text" : "Success"}');
        res1.setStatusCode(200);
        return res1;
    }
}