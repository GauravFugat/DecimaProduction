/*
* @Purpose: HttpCalloutMock for ZnalyticsAPI_Test, to get request parameters.
* @Author: Vishwanath K
* @CreatedDate: 16/09/2020
* @Related Code: 
* @Test Class:
* @LastModifiedDate:
* @LastModifiedBy:
*/
global class MockHttpResponseGeneratorExperian implements HttpCalloutMock {
    // Implement this interface method
    global Id attId;
    global HTTPResponse respond(HTTPRequest req) {
              // Create a fake response
        HttpResponse res1 = new HttpResponse();
        res1.setHeader('Content-Type', 'application/json');
        res1.setBody('{ "requestId": "rrt-016eb1ad317ff5f33-b-ea-19229-6331413-1", "success": true, "comments": "testing", "results": { "businessHeader": { "bin": "796744203", "businessName": "EXPERIAN INFORMATION SOLUTIONS, INC", "address": { "street": "475 ANTON BLVD", "city": "COSTA MESA", "state": "CA", "zip": "92626", "zipExtension": "7037" }, "phone": "+17148307000", "taxId": "133015410", "websiteUrl": "http://www.experian.com", "legalBusinessName": "EXPERIAN INFORMATION SOLUTIONS, INC.", "dbaNames": null, "customerDisputeIndicator": false }, "commercialScore": { "modelCode": "000224", "modelTitle": "INTELLISCORE PLUS V2", "customModelCode": "03", "score": 1, "percentileRanking": 0, "recommendedCreditLimitAmount": 226200, "riskClass": { "code": 5, "definition": "HIGH RISK" } }, "commercialScoreFactors": [ { "code": "029", "definition": "AVERAGE BALANCE OF RECENTLY DELINQUENT COMMERCIAL ACCOUNTS" }, { "code": "050", "definition": "NUMBER OF COMMERCIAL ACCOUNTS WITH HIGH UTILIZATION" }, { "code": "011", "definition": "NUMBER OF COMMERCIAL COLLECTION ACCOUNTS" }, { "code": "055", "definition": "NUMBER OF COMMERCIAL ACCOUNTS WITH NET 1-30 DAYS TERM" } ], "commercialScoreTrends": [ { "quarter": "JAN-MAR", "score": 3 }, { "quarter": "OCT-DEC", "score": 3 }, { "quarter": "JUL-SEP", "score": 7 }, { "quarter": "APR-JUN", "score": 4 } ], "fsrScore": { "modelCode": "000223", "modelTitle": "FINANCIAL STABILITY RISK", "score": 8, "percentileRanking": 7, "recommendedCreditLimitAmount": null, "riskClass": { "code": 4, "definition": "MEDIUM TO HIGH RISK" } }, "fsrScoreFactors": [ { "code": "001", "definition": "NUMBER OF COMMERCIAL COLLECTION ACCOUNTS" }, { "code": "005", "definition": "NUMBER OF COMMERCIAL DEROGATORY PUBLIC RECORDS" }, { "code": "004", "definition": "RISK ASSOCIATED WITH THE COMPANY\'S INDUSTRY SECTOR" }, { "code": "002", "definition": "RISK ASSOCIATED WITH THE BUSINESS TYPE" } ], "fsrScoreTrends": [ { "quarter": "JAN-MAR", "score": 6 }, { "quarter": "OCT-DEC", "score": 8 }, { "quarter": "JUL-SEP", "score": 8 }, { "quarter": "APR-JUN", "score": 7 } ], "listOfSimilars": [ { "bin": "796744203", "reliabilityCode": 100, "businessName": "EXPERIAN INFORMATION SOLUTIONS, INC", "phone": "+17148307000", "address": { "street": "475 ANTON BLVD", "city": "COSTA MESA", "state": "CA", "zip": "92626", "zipExtension": "7037" }, "numberOfTradelines": 50, "financialStatementIndicator": false, "keyFactsIndicator": true, "inquiryIndicator": true, "bankDataIndicator": false, "governmentDataIndicator": false, "executiveSummaryIndicator": true, "uccIndicator": true, "matchingNameAndAddress": null, "businessGeocode": { "latitudeLongitudeLevel": "Roof Top Level", "latitude": 33.690764, "longitude": -117.873551, "msaCode": "5945", "censusBlkGrpCode": "2", "censusTractCode": "063907", "cottageIndicator": false, "congressionalDistrictCode": "48", "dateLastReported": "2018-04-07" } } ] } } ');
        res1.setStatusCode(200);
        return res1;
    }
}