/*
* @Purpose: Controller Class for reUsableMultiSelectLookup component
* @Test Class: reUsableMultiSelectLookupCtrl_Test
*/
public class reUsableMultiSelectLookupCtrl {
    @AuraEnabled
    public static List < sObject > fetchLookUpValues(String searchKeyWord, String ObjectName, List<sObject> ExcludeitemsList, Id parentAccountId, String screenName, String ParentObjectFieldName, String ParentObjectId) {
        
        String searchKey = '%' + searchKeyWord + '%';        
        List < sObject > returnList = new List < sObject > ();
        
        List<string> lstExcludeitems = new List<string>();
        for(sObject item : ExcludeitemsList ){
            lstExcludeitems.add(item.id);
        }
        
        // Create a Dynamic SOQL Query For Fetch Record List with LIMIT 5 and exclude already selected records  
        String sQuery; 
        if (String.isNotBlank(ParentObjectFieldName)) {
            if (String.isBlank(ParentObjectId)) {
                return returnList; // Return empty list because parent is not selected  on screen      
            } else {
                sQuery =  'select id, Name from ' +ObjectName + ' where Name LIKE: searchKey AND Id NOT IN : lstExcludeitems ' + 
                    ' AND ' + ParentObjectFieldName + '=:ParentObjectId ' +  ' order by createdDate DESC limit 5';
            }        
        }
        else {
            sQuery =  'select id, Name from ' +ObjectName + ' where Name LIKE: searchKey AND Id NOT IN : lstExcludeitems order by createdDate DESC limit 5';
        }
        System.debug('sQuery-->> '+sQuery);
        List < sObject > lstOfRecords = Database.query(sQuery);
        
        for (sObject obj: lstOfRecords) {
            returnList.add(obj);
        }
        return returnList;
    }
}