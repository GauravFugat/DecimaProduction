public class checkThreshold {
    
    public static boolean checkDate(DateTime dt2){
        boolean returnValue = true;
        if(dt2 != null){
            Experian_Recency_Threshold__c expThreshold = [SELECT Id, No_of_days__c FROM Experian_Recency_Threshold__c];
            
            Long dt1Long = System.now().getTime();
            Long dt2Long = dt2.getTime();
            Long milliseconds = dt1Long - dt2Long;
            Long seconds = milliseconds / 1000;
            Long minutes = seconds / 60;
            Long hours = minutes / 60;
            
            if(expThreshold.No_of_days__c > hours){
                returnValue = false;
            }
        }
        return returnValue;
    }
    
}