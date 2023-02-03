({
    doInit : function(component, event, helper) {
        component.set("v.spinner", true);
        
        var action1 = component.get("c.statePicklistValues");
        action1.setCallback(this,function(response){
            var state = response.getState();
            console.log("state-->> "+state);
            if(state== 'SUCCESS'){
                console.log('pick vals-->> '+response.getReturnValue());
                component.set("v.stateList",response.getReturnValue());
            }
        });
        $A.enqueueAction(action1);
        
        console.log('BillType->'+JSON.stringify(component.get("v.BillType")));
        var brokerId = component.get("v.recordId");
        component.set("v.brId",brokerId);    
        var action = component.get("c.initMethod");
        var val = component.get("v.recordId");
        var IdtoPass;
        if(val == undefined){
            IdtoPass = component.get("v.accountIdtoPass2")
        }else{
            IdtoPass = component.get("v.recordId")
        }
        action.setParams({
            "Accid": IdtoPass
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            var returnResponse = response.getReturnValue();
            if (state === "SUCCESS") {
                component.set("v.accRec", returnResponse);
                //console.log("vv-->> "+returnResponse.BillingState.length);
                //console.log('===>>> '+component.get("v.stateList").includes(returnResponse.BillingState));
                if(returnResponse.BillingState == undefined  || returnResponse.BillingState.length != 2 && component.get("v.stateList").includes(returnResponse.BillingState) == false){
                    component.set("v.invalidState",true);
                    component.set("v.inclass",'color');
                    component.set("v.setValidationMsg",'The State value must be a valid 2 letter abbreviation');
                }
                component.set("v.spinner", false);
            }
        });
        $A.enqueueAction(action);
        
    },
    nextScreen : function(component, event, helper) {
        
        component.set("v.spinner", true);
        var accrec = component.get("v.accRec");
        
        var action = component.get("c.makeCallout");
        
        action.setParams({
            "accRec": component.get("v.accRec"),
            "geo":component.get("v.geo"),
            "comment":component.get("v.comment"),
            "txtId":component.get("v.txtId")
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            var returnResponse = response.getReturnValue();
            
            //alert(JSON.stringify(returnResponse));
            component.set("v.resultList",returnResponse);
            if (state === "SUCCESS") {
                
                var msg = 'No Records found.';
                if(returnResponse.length > 0){
                    msg = 'Record found successfully.';
                }
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": msg
                });
                //toastEvent.fire();
                component.set("v.firstscreen", false);
                // component.set("v.secondscreen", false);
                var resultLst = component.get("v.resultList");
                
                var reliableBusinessExists = true;
                
                for(var i=0;i<resultLst.length;i++){
                    if(resultLst[i].reliabilityCode >= 100){
                        reliableBusinessExists = false;
                        break;
                    }
                    
                }
                component.set("v.noReliableBusiness",reliableBusinessExists);
                
                if(resultLst.length == 1 && resultLst[0].reliabilityCode >= 100){
                    component.find("checkContact").set("v.value", true);
                    var a = component.get('c.CreateAccount1');
                    $A.enqueueAction(a);
                    
                }
                
                
                
            }else if (state === "INCOMPLETE") {
                component.set("v.spinner", false);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "OFFLINE!",
                    "message": "You are in offline."
                });
                toastEvent.fire();
            }else if (state === "ERROR") {
                component.set("v.spinner", false);
                var errors = response.getError();
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "ERROR!",
                    "type" : "error",
                    "message": returnResponse.respError 
                    //"message": "No Records found!"
                });
                toastEvent.fire();
            }else {
                component.set("v.spinner", false);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "UNKOWN!",
                    "message": "Unknown error."
                });
                toastEvent.fire();
            }
            component.set("v.spinner", false);
        });
        
        $A.enqueueAction(action);
        
        
    },
    
    previousScreen : function(component, event, helper){
        component.set("v.firstscreen", true);
        component.set("v.secondscreen", false);
        component.set("v.disablednocheck",true);
        
    },
    
    
    CreateAccount1 : function(component, event, helper){
        component.set("v.spinner", true);
        console.log('here----');
        var checkvalue = component.find("checkContact");
        var selectedContacts = [];
        if(!Array.isArray(checkvalue)){
            if (checkvalue.get("v.value") == true) {
                selectedContacts.push(checkvalue.get("v.errors"));
            }
        }
        else{
            for (var i = 0; i < checkvalue.length; i++) {
                if(checkvalue[i].get("v.value") == true){
                    selectedContacts.push(checkvalue[i].get("v.errors"));
                }
            }
        }
        console.log('selectedContacts-->'+selectedContacts);
        var action = component.get("c.CreateAccount");
        action.setParams({
            "AccResult":selectedContacts,
            "accRec": component.get("v.accRec"),
            "Acccid" : component.get("v.brId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.spinner", false);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "type" : "success",
                    "message": "Record has been inserted successfully."
                });
                toastEvent.fire();
                if(component.get("v.showHeader") == true){
                    $A.get("e.force:closeQuickAction").fire();
                }
                else{
                    component.set("v.binId",'1');
                    component.set("v.showHeader1",false);
                    component.set("v.showBinWarning",false);
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    callCancel : function(component, event, helper){
        $A.get("e.force:closeQuickAction").fire();
    },
    
    /* checkboxSelect : function(component, event, helper){
       //component.set("v.checkboxvalue",false);
        var index = event.getSource().get("v.text");
        var checkvalue = component.find("checkContact").get("v.value");
       alert('checkValue 175'+checkvalue);
        if(checkvalue==true)
        {
            component.set("v.secondscreen",false);
        }
        else{
            component.set("v.secondscreen",true);
        }
        console.log('index-->'+index);
        console.log('chek-->'+checkvalue[index].get("v.value"));
        
        if(Array.isArray(checkvalue)){
             for (var i = 0; i < checkvalue.length; i++) {
            if(checkvalue[i].get("v.value") == true){
                    checkvalue[i].set("v.value",false);
            }
            }
        }
        checkvalue[index].set("v.value",true);
    },*/
    
    checkboxSelect : function(component, event, helper){
        console.log('198');
        component.set("v.secondscreen",false);
        component.set("v.disablednocheck",false);
        
        var index = event.getSource().get("v.text");
        var checkvalue = component.find("checkContact");
        console.log('checkvalue-->'+checkvalue);
       // var checkvalue1 = component.find("checkContact").get("v.value");
        console.log('index-->'+index);
        //console.log('chek-->'+checkvalue[index]);
        console.log('checkvalue 1--'+checkvalue1);
        //console.log('checkvalue is Array--'+Array.isArray(checkvalue));
        //console.log('checkvalue.length--'+checkvalue.length);
        //alert('checkValue 205');
        if(Array.isArray(checkvalue)){
            for (var i = 0; i < checkvalue.length; i++) {
                //console.log('in for loop');
                if(checkvalue[i].get("v.value") == true){
                  //  console.log('in if');
                    checkvalue[i].set("v.value",false);
                  //  alert('checkValue 211');
                    
                }
              
                
            }
        }
        checkvalue[index].set("v.value",true);
        
    },
    
    closeModal : function(component, event, helper){
        if(component.get("v.showHeader") == true){
            $A.get("e.force:closeQuickAction").fire();
        }
        else{
            var billType = ['UCB'];
            component.set("v.BillType",billType);
            var PRLst = [];
            var PRtoSet = [];
            PRLst = component.get("v.StorePRList");
            
            for(var i=0;i<PRLst.length;i++){
                PRLst[i].Bill_Type__c = 'UCB';
                PRtoSet.push(PRLst[i]);
            }
            component.set("v.StorePRList",PRtoSet);
            component.set("v.showHeader1",false);
            component.set("v.showBinWarning",false);
        }
    },
    
    onStateChange : function(component, event, helper){
        //alert('vv==>> '+component.find('accState').get("v.value"));
        var state = component.find('accState').get("v.value");
        if(state.length !=2 && component.get("v.stateList").includes(state) == false){
            component.set("v.invalidState",true);
            component.set("v.inclass",'color');
            component.set("v.setValidationMsg",'The State value must be a valid 2 letter abbreviation');
        }else if(state.length ==2 && component.get("v.stateList").includes(state)){
            component.set("v.invalidState",false);
            component.set("v.setValidationMsg",'');
            component.set("v.inclass",'');
        }
    }
})