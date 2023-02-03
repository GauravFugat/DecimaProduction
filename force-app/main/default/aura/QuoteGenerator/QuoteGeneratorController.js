({
    doInit: function(component, event, helper) {  
         //alert('in doInit');
        

        var action = component.get('c.oppDateClosedWon');
            var opportunityId = component.get("v.recordId");
		console.log('before calling-->'+opportunityId);

        action.setParams({
            "oppId":opportunityId
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log(state);
            if (state === "SUCCESS") {
               component.set('v.isCloseWon',response.getReturnValue())
               console.log('Opp CloseWon true ?',response.getReturnValue())
            }
            
        });
        	
            $A.enqueueAction(action);
          $A.get('e.force:refreshView').fire();

    },
    
    handleEvent : function(component, event, helper){
        //get response value fired from parent
        var response = event.getParam("eventResponse"); 
        //Set the value recieved from the event
        // alert('response----->>>>> '+response);
        component.set("v.eventValue", response);     
    },
    
    gotoScreen2: function(component, event, helper) {
        // alert(component.get("v.selectedstoreVolumn"));
        var allRecords = component.get("v.listOfAllAccounts");
        var excludedRecords = [];
        var includedRecords = [];
        for (var i = 0; i < allRecords.length; i++) {
            if (!allRecords[i].isChecked && allRecords[i].objAccount.Status__c != 'Not Priced') {
                excludedRecords.push(allRecords[i].objAccount);
            }
            if (allRecords[i].isChecked) {
                includedRecords.push(allRecords[i].objAccount);
            }
        }
        if(excludedRecords != null || includedRecords != null )
            helper.updateExcludedUAOs(component, event, helper, excludedRecords, includedRecords );
        component.set("v.screen1", false);
        component.set("v.screen3", false);
        component.set("v.screen2", true);
    },
    gotoScreen1: function(component, event, helper) {
        debugger;
        component.set("v.screen1", true);
        component.set("v.screen2", false);
        component.set("v.screen3", false);
        console.log('toggleVAlue->'+component.get("v.toggleValue")); 
    },
    gotoScreen3: function(component, event, helper) {
        var objCompB = component.find('compB');
        objCompB.getPS();
        
        component.set("v.screen1", false);
        component.set("v.screen2", false);
        component.set("v.screen3", true);
    },
    gotoScreen2From3: function(component, event, helper) {
        component.set("v.screen1", false);
        component.set("v.screen3", false);
        component.set("v.screen2", true);
    },
    confirmation: function(component, event, helper) {
        var checkCmp = component.find("checkbox");
        component.set("v.confirmation", checkCmp.get("v.value"));
    },
    
})