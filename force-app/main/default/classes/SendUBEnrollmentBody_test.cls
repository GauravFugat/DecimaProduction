@isTest
public class SendUBEnrollmentBody_test {

    public testmethod static void setup(){
        
          List<String> emailXMLlist = new List<String> ();
         List<String> resultList = new List<String> ();
         List<Integer> Codes = new List<Integer>();
        String serviceEndpoint;
       Test.startTest();
         emailXMLlist.add('Test');
         resultList.add('Test1');
         Codes.add(1);
       // SendUBEnrollmentBody ad = new SendUBEnrollmentBody ();
        SendUBEnrollmentBody updater = new SendUBEnrollmentBody (emailXMLlist,resultList,Codes,'Hii');
        // startTest/stopTest block to force async processes to run
              // System.enqueueJob(ad);
        ID jobID = System.enqueueJob(updater);
    }
    
}