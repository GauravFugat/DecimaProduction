/*
* @Purpose: Test class of VF_Report_BrokerCommissionsHandler.
* @Author: Rahul Ghaytadak
* @CreatedDate:2/23/2021
* @Related Code: 
* @LastModifiedDate:
* @LastModifiedBy: Rahul Ghaytadak
*/
@isTest
public class VF_Report_BrokerCommissionsHandler_Test {
     @isTest(SeeAllData=true)
    public static void TestMethod2(){
        ApexPages.StandardSetController controller;
        VF_Report_BrokerCommissionsHandler vf= new VF_Report_BrokerCommissionsHandler();
        vf.getexport();
        vf.previous();
    }
}