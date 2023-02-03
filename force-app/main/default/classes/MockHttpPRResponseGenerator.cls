@isTest
global class MockHttpPRResponseGenerator implements HttpCalloutMock {

    // Implement this interface method
    global HTTPResponse respond(HTTPRequest request) {
        // Create a fake response
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"access_token" : "test","commonParameters": { "productId": "BI DAM Fixed", "recsType": "Any","voluntaryRecsPercentage": 30,"billType": "UCB","customerName": "Postman TEST","priceRequest": "PR-PTEST","dueDate": 1643673600000,"marketToMarket": 1000,"contractId": "CONTR_ID_1","customerId": "CUST_ID_1"},"salesforceParameters": {"originalRequest": "PR-PTEST1","status": "HU Requested","requestType": "Initial Request","isUrgent": false,"numberOfAccounts": 5,"expectedAnnualVolume": 100000,"notes": "some notes", "comments": "some comments","treatment": "None","startDates": "Same","cpm": "some CPM"},"accounts": [{"accountNumber": "ACC123","utility": "COMED","startDate": 1643673600000},{"accountNumber": "BCC123","utility": "COMED","startDate": 1643673600000}]}');
        response.setStatusCode(200);
        return response;
    }
}