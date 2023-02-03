({
    doInit : function(component, event, helper) { 
        //console.log('incustom lookup');
        //console.log('{!v.listOfSearchRecords}----'+component.get("v.listOfSearchRecords"));
        if(component.get("v.objectAPIName") == 'Account' || (JSON.stringify(component.get("v.selectedRecord")) != '{}' && component.get("v.objectAPIName") == 'Contact')
        || component.get("v.objectAPIName") == 'Opportunity' ||  component.get("v.objectAPIName") == 'Contract'){
            var getSelectRecord = component.get("v.selectedRecord");
            console.log('selected record is ==' + JSON.stringify(component.get("v.selectedRecord")));
           // console.log('getSelectRecord--'+getSelectRecord);
            // call the event   
            var compEvent = component.getEvent("oSelectedRecordEvent");
            // set the Selected sObject Record to the event attribute.  
            compEvent.setParams({"recordByEvent" : getSelectRecord });  
            // fire the event  
            compEvent.fire();
        }

        if (component.get("v.objectAPIName") == 'Opportunity' ||  component.get("v.objectAPIName") == 'Contract') {
            component.set("v.readOnlyCustomLookup", true);
        }
    },
    onfocus : function(component,event,helper){
        $A.util.addClass(component.find("mySpinner"), "slds-show");
        var forOpen = component.find("searchRes");
        $A.util.addClass(forOpen, 'slds-is-open');
        $A.util.removeClass(forOpen, 'slds-is-close');
        // Get Default 5 Records order by createdDate DESC  
        var getInputkeyWord = '';
        helper.searchHelper(component,event,getInputkeyWord,true);
    },
    onblur : function(component,event,helper){       
        component.set("v.listOfSearchRecords", null );
        var forclose = component.find("searchRes");
        $A.util.addClass(forclose, 'slds-is-close');
        $A.util.removeClass(forclose, 'slds-is-open');
    },
    keyPressController : function(component, event, helper) {
        // get the search Input keyword   
        var getInputkeyWord = component.get("v.SearchKeyWord");
        // check if getInputKeyWord size id more then 0 then open the lookup result List and 
        // call the helper 
        // else close the lookup result List part.   
        if( getInputkeyWord.length > 0 ){
            var forOpen = component.find("searchRes");
            $A.util.addClass(forOpen, 'slds-is-open');
            $A.util.removeClass(forOpen, 'slds-is-close');
            helper.searchHelper(component,event,getInputkeyWord,false);
        }
        else{  
            component.set("v.listOfSearchRecords", null ); 
            var forclose = component.find("searchRes");
            $A.util.addClass(forclose, 'slds-is-close');
            $A.util.removeClass(forclose, 'slds-is-open');
        }
    },
    
    // function for clear the Record Selaction 
    clear :function(component,event,heplper){
        var pillTarget = component.find("lookup-pill");
        var lookUpTarget = component.find("lookupField"); 
        
        $A.util.addClass(pillTarget, 'slds-hide');
        $A.util.removeClass(pillTarget, 'slds-show');
        
        $A.util.addClass(lookUpTarget, 'slds-show');
        $A.util.removeClass(lookUpTarget, 'slds-hide');
        
        component.set("v.SearchKeyWord",null);
        component.set("v.listOfSearchRecords", null );
        component.set("v.selectedRecord", {} );   
    },
    
    // This function call when the end User Select any record from the result list.   
    handleComponentEvent : function(component, event, helper) {
        //alert('In');
        component.set("v.SearchKeyWord",null);
        // get the selected Account record from the COMPONETN event
        var selectedItems = component.get("v.selectedRecord");	
        //alert('selectedItems'+JSON.stringify(selectedItems));
        var selectedAccountGetFromEvent = event.getParam("recordByEvent");
        //console.log('selectedAccountGetFromEvent==>'+selectedAccountGetFromEvent);
        //selectedItems.push(selectedAccountGetFromEvent);  //Event giving an issue
        
        //Changes made for the card SU-877 by Suhas
        //component.set("v.selectedRecord" , selectedItems);
        component.set("v.selectedRecord" , selectedAccountGetFromEvent); 
        
        var forclose = component.find("lookup-pill");
        $A.util.addClass(forclose, 'slds-show');
        $A.util.removeClass(forclose, 'slds-hide');
        
        var forclose = component.find("searchRes");
        $A.util.addClass(forclose, 'slds-is-close');
        $A.util.removeClass(forclose, 'slds-is-open');
        
        var lookUpTarget = component.find("lookupField");
        $A.util.addClass(lookUpTarget, 'slds-hide');
        $A.util.removeClass(lookUpTarget, 'slds-show');  
        
    },
    AddNewContact :function(component, event, helper) {
        var recordEvent = $A.get("e.force:createRecord");
        var LOOKUP = 'LOOKUP'; 
        recordEvent.setParams({
            "entityApiName": "Contact",
            "defaultFieldValues":{
                "AccountId": component.get("v.accId")
            },
            "panelOnDestroyCallback": function(event) {
                helper.getContact(component, event, helper);
            },
            "navigationLocation":LOOKUP,
        });
        recordEvent.fire();
    },
    
    AddNewAccount :function(component, event, helper) {
        var recordEvent = $A.get("e.force:createRecord");
        var LOOKUP = 'LOOKUP'; 
        var brokertype = '';
        var recordtype = $A.get("$Label.c.Broker_Record_Type");
        brokertype = component.get("v.BrokerType");
        if(brokertype == 'Customer'){
            recordtype = $A.get("$Label.c.Customer_Record_Type");
        }
        recordEvent.setParams({
            "entityApiName": "Account",
            "recordTypeId":recordtype,
            "defaultFieldValues":{
                
            },
            "panelOnDestroyCallback": function(event) {
                helper.getContact(component, event, helper);
            },
            "navigationLocation":LOOKUP,
        });
        recordEvent.fire();
    },
})