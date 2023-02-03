//Test Class: CountUpdateBroker_Test
public class CountAllOPPBrokerClass {
    @invocablemethod
    public static List<String> getCountBroker(List<Id> recordId){
        List<String> count = new List<String>();
        List<String> count1 = new List<String>();
        count1.add('0');
        List<Opportunity> oppLst = [Select Id from Opportunity where (StageName = 'Closed Won' OR StageName = 'Closed Lost') AND Broker__c =: recordId[0]];
        String S = String.valueOf(oppLst.size());
        count.add(S);
        if(oppLst.size()>0){
            system.debug('CountAllOPPBrokerClass If'+count);
            return count; 
        }else{
            system.debug('CountAllOPPBrokerClass else'+count1);
            return count1;
        }
        
    }
}