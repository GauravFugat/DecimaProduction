global class MockCallout implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        String res = '';
        system.debug('req.getEndpoint()>>'+req.getEndpoint());
        if (req.getEndpoint().endsWith('legalcollectionsummaries')) {
            res='{"requestId":"rrt-0f7898a6c30703d75-c-ea-20545-153781152-2","success":true,"results":{"businessHeader":{"bin":"700163758","businessName":"SONY MUSIC ENTERTAINMENT","address":{"street":"550 MADISON AVE FL 6","city":"NEW YORK","state":"NY","zip":"10022","zipExtension":"3211"},"phone":"+12128338000","taxId":"131914734","websiteUrl":"www.sonybmg.com","legalBusinessName":"SONY MUSIC ENTERTAINMENT","dbaNames":["SONY MUSIC ENTERTAINMENT","SONY BMG MUSIC ENTERTAINMENT","SONY HMG MUSIC ENTERTAINMENT"],"customerDisputeIndicator":false},"legalFilingsCollectionsSummary":{"legalCount":38,"legalBalance":1508,"derogatoryLegalCount":2,"bankruptcyIndicator":true,"bankruptcyCount":0,"lienCount":2,"lienBalance":1508,"judgmentCount":0,"judgmentBalance":0,"uccFilingsCount":3,"uccDerogatoryCount":3,"collectionCount":2,"collectionBalance":354},"legalFilingsSummary":{"legalCount":38,"legalBalance":1508,"derogatoryLegalCount":2}}}';
        }
        else if(req.getEndpoint().endsWith('facts')) {
            system.debug('req.getEndpoint()>>'+req.getEndpoint());
            res='{"requestId":"rrt-0f7898a6c30703d75-c-ea-20546-136691396-2","success":true,"results":{"businessHeader":{"bin":"700163758","businessName":"SONY MUSIC ENTERTAINMENT","address":{"street":"550 MADISON AVE FL 6","city":"NEW YORK","state":"NY","zip":"10022","zipExtension":"3211"},"phone":"+12128338000","taxId":"131914734","websiteUrl":"www.sonybmg.com","legalBusinessName":"SONY MUSIC ENTERTAINMENT","dbaNames":["SONY MUSIC ENTERTAINMENT","SONY BMG MUSIC ENTERTAINMENT","SONY HMG MUSIC ENTERTAINMENT"],"customerDisputeIndicator":false},"sicCodes":[{"code":"8999","definition":"SERVICES, NEC"},{"code":"3652","definition":"RECORDS, AUDIO TAPES & DISKS"},{"code":"7389","definition":"BUSINESS SERVICES, NEC"}],"naicsCodes":[{"code":"541990","definition":"All Other Professional, Scientific, and Technical Services"},{"code":"334614","definition":"Software and Other Prerecorded Compact Disc, Tape, and Record Reproducing"},{"code":"512240","definition":"Sound Recording Studios"}],"publicIndicator":false,"nonProfitIndicator":false,"yearsOnFile":33,"stateOfIncorporation":"MI","dateOfIncorporation":"1991-02-28","businessType":"Corporation","employeeSize":null,"employeeSizeCode":null,"salesRevenue":null,"salesSizeCode":null,"fortune1000":{"year":null,"rank":null},"corporateLinkageType":"Headquarters/Parent","executiveInformation":[{"firstName":"DOUGLAS","middleName":"P","lastName":"MORRIS","title":"CHIEF EXECUTIVE OFFICER"},{"firstName":"AFO","middleName":null,"lastName":"VERDE","title":"CHIEF EXECUTIVE OFFICER"},{"firstName":"PATRICK","middleName":null,"lastName":"MOXEY","title":"PRESIDENT"}]}}';
        }
        else if(req.getEndpoint().endsWith('fraudshields')) {
           res = '{"requestId":"rrt-08009e7bdc5fde3e1-c-ea-10309-153468156-4","success":true,"results":{"businessHeader":{"bin":"700163758","businessName":"SONY MUSIC ENTERTAINMENT","address":{"street":"550 MADISON AVE FL 6","city":"NEW YORK","state":"NY","zip":"10022","zipExtension":"3211"},"phone":"+12128338000","taxId":"131914734","websiteUrl":"www.sonybmg.com","legalBusinessName":"SONY MUSIC ENTERTAINMENT","dbaNames":["SONY MUSIC ENTERTAINMENT","SONY BMG MUSIC ENTERTAINMENT","SONY HMG MUSIC ENTERTAINMENT"],"customerDisputeIndicator":false},"matchingBusinessAddress":"Primary Business","activeBusinessIndicator":true,"ofacMatchWarning":{"code":1,"definition":"No Match Found"},"businessVictimStatementIndicator":false,"businessRiskTriggersIndicator":false,"businessRiskTriggersStatement":null,"nameAddressVerificationIndicator":true}}';
        }
        else if(req.getEndpoint().endsWith('search')) {
            res = '{"requestId":"rrt-069d3962f8e2fe8bf-d-ea-25093-155077568-2","comments":null,"success":true,"results":[{"bin":"702401098","reliabilityCode":100,"businessName":"BENIHANA WESTBURY CORP","phone":null,"address":{"street":"920 MERCHANTS CONCOURSE","city":"WESTBURY","state":"NY","zip":"11590","zipExtension":"5199"},"numberOfTradelines":2,"financialStatementIndicator":false,"keyFactsIndicator":true,"inquiryIndicator":false,"bankDataIndicator":false,"governmentDataIndicator":false,"executiveSummaryIndicator":false,"uccIndicator":false,"matchingNameAndAddress":null,"businessGeocode":{"latitudeLongitudeLevel":"Roof Top Level","latitude":40.743996,"longitude":-73.592114,"msaCode":"5380","censusBlkGrpCode":"4","censusTractCode":"304202","cottageIndicator":false,"congressionalDistrictCode":"04","dateLastReported":"2017-11-22"}}]}';
        }
        else if(req.getEndpoint().endsWith('scores/search')) {
            System.debug('******20******');
            res = '{"requestId":"rrt-0179c636db13027e5-c-ea-19264-3751308-6","success":true,"comments":null,"results":{"businessHeader":{"bin":"711655002","businessName":"BASF CATALYSTS LLC","address":{"street":"101 WOOD AVE S","city":"ISELIN","state":"NJ","zip":"08830","zipExtension":"2749"},"phone":"+19732456000","taxId":"000952801","websiteUrl":"engelhard.com","legalBusinessName":null,"dbaNames":["BASF CORP"],"customerDisputeIndicator":false},"commercialScore":{"modelCode":"000224","modelTitle":"INTELLISCORE PLUS V2","customModelCode":"02","score":54,"percentileRanking":53,"recommendedCreditLimitAmount":2227700,"riskClass":{"code":2,"definition":"LOW TO MEDIUM RISK"}},"commercialScoreFactors":[{"code":"033","definition":"NUMBER OF COMMERCIAL ACCOUNTS THAT ARE CURRENT"},{"code":"066","definition":"PERCENT OF DELINQUENT COMMERCIAL ACCOUNTS"},{"code":"025","definition":"BALANCE OF RECENTLY DELIINQUENT COMMERCIAL ACCOUNTS"},{"code":"067","definition":"PERCENT OF SERIOUSLY DELINQUENT COMMERCIAL ACCOUNTS"}],"commercialScoreTrends":[{"quarter":"JAN-MAR","score":57},{"quarter":"OCT-DEC","score":51},{"quarter":"JUL-SEP","score":45},{"quarter":"APR-JUN","score":48}],"fsrScore":{"modelCode":"000223","modelTitle":"FINANCIAL STABILITY RISK","score":66,"percentileRanking":65,"recommendedCreditLimitAmount":null,"riskClass":{"code":1,"definition":"LOW RISK"}},"fsrScoreFactors":[{"code":"004","definition":"RISK ASSOCIATED WITH THE COMPANYS INDUSTRY SECTOR"},{"code":"016","definition":"PERCENT OF COMMERCIAL ACCOUNTS DELINQUENT"},{"code":"011","definition":"PAST COMMERCIAL DEROGATORY BALANCE"},{"code":"005","definition":"NUMBER OF COMMERCIAL DEROGATORY PUBLIC RECORDS"}],"fsrScoreTrends":[{"quarter":"JAN-MAR","score":69},{"quarter":"OCT-DEC","score":34},{"quarter":"JUL-SEP","score":33},{"quarter":"APR-JUN","score":34}],"listOfSimilars":[{"bin":"711655002","reliabilityCode":100,"businessName":"BASF CATALYSTS LLC","phone":"+19732456000","address":{"street":"101 WOOD AVE S","city":"ISELIN","state":"NJ","zip":"08830","zipExtension":"2749"},"numberOfTradelines":71,"financialStatementIndicator":false,"keyFactsIndicator":true,"inquiryIndicator":false,"bankDataIndicator":false,"governmentDataIndicator":false,"executiveSummaryIndicator":true,"uccIndicator":true,"matchingNameAndAddress":null,"businessGeocode":{"latitudeLongitudeLevel":"Roof Top Level","latitude":40.563754,"longitude":-74.328738,"msaCode":"5015","censusBlkGrpCode":"","censusTractCode":"002603","cottageIndicator":false,"congressionalDistrictCode":"06","dateLastReported":"2018-01-31"}}]}}';
        }
        else{
            system.debug('req.getEndpoint()>>'+req.getEndpoint());
            res='{"requestId":"rrt-0f7898a6c30703d75-c-ea-20545-153781152-2","success":true,"results":{"businessHeader":{"bin":"700163758","businessName":"SONY MUSIC ENTERTAINMENT","address":{"street":"550 MADISON AVE FL 6","city":"NEW YORK","state":"NY","zip":"10022","zipExtension":"3211"},"phone":"+12128338000","taxId":"131914734","websiteUrl":"www.sonybmg.com","legalBusinessName":"SONY MUSIC ENTERTAINMENT","dbaNames":["SONY MUSIC ENTERTAINMENT","SONY BMG MUSIC ENTERTAINMENT","SONY HMG MUSIC ENTERTAINMENT"],"customerDisputeIndicator":false},"legalFilingsCollectionsSummary":{"legalCount":38,"legalBalance":1508,"derogatoryLegalCount":2,"bankruptcyIndicator":true,"bankruptcyCount":0,"lienCount":2,"lienBalance":1508,"judgmentCount":0,"judgmentBalance":0,"uccFilingsCount":3,"uccDerogatoryCount":3,"collectionCount":2,"collectionBalance":354},"legalFilingsSummary":{"legalCount":38,"legalBalance":1508,"derogatoryLegalCount":2}}}';
        }
        // Create a fake response
        HttpResponse res1 = new HttpResponse();
        res1.setHeader('Content-Type', 'application/json');
        res1.setBody(res);
        res1.setStatusCode(200);
        return res1;
    }
}