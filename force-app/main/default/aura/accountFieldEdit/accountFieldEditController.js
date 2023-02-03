({
    doInit : function(component, event, helper) {
        component.set("v.spinner", true);
        var opts = [
                { value: "Residual", label: "Residual"}, 
                { value: "Upfront - Contract Acceptance", label: "Upfront - Contract Acceptance" },
                { value: "Upfront - Enrollment Acceptance", label: "Upfront - Enrollment Acceptance" }
            ];
            component.set('v.options', opts);

        
        var switchOpts = [
            { value: "On-Cycle", label: "On-Cycle"}, 
            { value: "Off-Cycle", label: "Off-Cycle" }
        ];
        component.set('v.switchOption', switchOpts);
        
        
        window.setTimeout(
            $A.getCallback(function() {
                
                var oppId = component.get('v.opporRecordId');
                var accId = component.get('v.accountRecordId');
                
                var ConId = '';
                var ConName = '';
                var ConEmail = '';
                
                var action = component.get("c.getContactData");
                action.setParams({  
                    'Id' : oppId,
                    'accId': accId
                });
                
                action.setCallback(this, function(response){
                    var state = response.getState();
                    console.log('account state ==>'+state);
                    var responseData = response.getReturnValue();
                    console.log('account res data ==>'+JSON.stringify(response.getReturnValue()));
                    if(state == 'SUCCESS') {
                        if(responseData[0].conExists == true){
                            ConId = responseData[0].conId;
                            ConName = responseData[0].conName;
                            ConEmail = responseData[0].conEmail;
                            component.set('v.contactId', ConId);
                            component.set('v.contactName', ConName);
                            component.set('v.contactEmail', ConEmail);
                            component.set('v.conExists', true);
                        }else{
                            component.set('v.conExists', false);
                        }
                        
                        
                        
                        component.set('v.accId', responseData[0].accId);
                        component.set('v.accName', responseData[0].accName);
                        component.set('v.accPhone', responseData[0].accPhone);
                        component.set('v.accBillingStreet', responseData[0].accBillingStreet);
                        component.set('v.accBillingState', responseData[0].accBillingState);
                        component.set('v.accBillingPostalCode', responseData[0].accBillingPostalCode);
                        component.set('v.accBillingCountry', responseData[0].accBillingCountry);
                        component.set('v.accBillingCity', responseData[0].accBillingCity);
                        
                        
                        component.set('v.taxExempt', responseData[0].accTaxExempt);
                        if (responseData[0].accTaxExempt) {
                            component.set("v.isShowTaxablePortion", true);
                        }
                        if(responseData[0].accTaxablePortion){
                            component.set('v.taxablePortion', responseData[0].accTaxablePortion);
                        }
                        
                        component.set("v.spinner", false); 
                    }
                });
                $A.enqueueAction(action);
                
                
                var ComData = '';
                var quotesBillType = '';
                var action1 = component.get("c.getOppData");
                action1.setParams({  
                    'Id' : oppId,
                });
                
                action1.setCallback(this, function(response1){
                    var state1 = response1.getState();
                    var responseData = response1.getReturnValue();
                    if(state1 == 'SUCCESS') {
                        console.log('response discount json asdfasdfasdf==>'+JSON.stringify(response1.getReturnValue()));
                        
                        ComData = responseData[0].oppCommission_Type;
                        quotesBillType = responseData[0].quotesBillType;
                        
                        component.set('v.opportunityDiscount', ComData);
                        component.set('v.billType', quotesBillType);
                        
                        component.set('v.broker', responseData[0].BrokerName);
                        component.set('v.oppOwner', responseData[0].ownerName);
                        component.set('v.oppType', responseData[0].Type);
                        
                        component.set('v.oppCommissionDis', responseData[0].Commission_Discount);
                        
                        component.set('v.oppSwitchingType', responseData[0].oppSwitching_Type);
                        //component.find("SwitchingTypeId").set("v.value", responseData[0].oppSwitching_Type);
                        
                        
                        component.set('v.isOppCpmCredit', responseData[0].oppCpmCredit);
                        
                        console.log('get oppCpmCredit ==>'+responseData[0].oppCpmCredit);
                        
                        component.set('v.oppCommissionType', responseData[0].oppCommission_Type);
                        
                         //alert('getoppCommissionType 2100-->'+component.get('v.oppCommissionType'));
                        if (responseData[0].oppCommission_Type != 'Residual') {
                            component.set('v.isCommTypeResidual', true);
                            //component.set('v.oldOppCommTypeResidual', true);
                            //component.set('v.isCommTypeResidual', false);
                            //component.set('v.selectedValue', responseData[0].oppCommission_Type);
                            
                        }
                        component.set('v.selectedValue', responseData[0].oppCommission_Type);
                        component.set('v.selecteValue', responseData[0].oppSwitching_Type);
                        
                    }
                });
                $A.enqueueAction(action1);
                
                
                
                
                var recordId = oppId;
                var action2 = component.get("c.getQuoteSummaryData");
                action2.setParams({ 'recordId' : recordId}); 
                action2.setCallback(this, function(response2) {
                    var state2 = response2.getState();
                    if (state2 === "SUCCESS") {
                        component.set("v.recordResponse", response2.getReturnValue());
                    } else {
                        component.set("v.recordResponse", response2.getReturnValue());
                    }
                });
                $A.enqueueAction(action2);
            }), 3000
        );
        
       // var getoppCommissionType =component.get('v.oppCommissionType');  
       // alert('getoppCommissionType-->'+component.get('v.oppCommissionType'));
       /* if(getoppCommissionType = 'Residual'){
            alert('1');
            var opts = [
                { value: "Residual", label: "Residual"}, 
                { value: "Upfront - Contract Acceptance", label: "Upfront - Contract Acceptance" },
                { value: "Upfront - Enrollment Acceptance", label: "Upfront - Enrollment Acceptance" }
            ];
            component.set('v.options', opts);
        }
        else if(getoppCommissionType = 'Upfront - Contract Acceptance'){
            alert('2');
            var opts = [
                { value: "Upfront - Contract Acceptance", label: "Upfront - Contract Acceptance" },
                { value: "Upfront - Enrollment Acceptance", label: "Upfront - Enrollment Acceptance" },
                { value: "Residual", label: "Residual"}
            ];
            component.set('v.options', opts);
        }
            else if(getoppCommissionType = 'Upfront - Enrollment Acceptance'){
                alert('3');
                var opts = [
                    { value: "Upfront - Enrollment Acceptance", label: "Upfront - Enrollment Acceptance" },
                    { value: "Upfront - Contract Acceptance", label: "Upfront - Contract Acceptance" },
                    { value: "Residual", label: "Residual"}
                ];
                component.set('v.options', opts);
            }
                else{
                    alert('4');
                    var opts = [
                        { value: "Residual", label: "Residual"}, 
                        { value: "Upfront - Contract Acceptance", label: "Upfront - Contract Acceptance" },
                        { value: "Upfront - Enrollment Acceptance", label: "Upfront - Enrollment Acceptance" }
                    ];
                    component.set('v.options', opts);
                }
        */
       
    },
    
    // change option value 
    doChagne: function(component, event, helper) {
        var selected = component.find("mySelect").get("v.value");
        component.set('v.selectedValue', selected);
        component.set('v.oppCommissionType', selected);
    },
    
    // change option value 
    doChagneSwitchingType: function(component, event, helper) {
        var selectedVal = component.find("SwitchingTypeId").get("v.value");
        component.set('v.selectValue', selectedVal);
        component.set('v.oppSwitchingType', selectedVal);
        
    },
    
    // enable edit section
    handleEdit: function(component, event, helper) {
        var editMode = true;
        var viewMode = false;
        
        /*Code updated on 10-12-2021 for remove update on cancel */
        var getaccName = component.get('v.accName');
        component.set('v.oldAccName', getaccName);        
        var getaccPhone = component.get('v.accPhone');
        component.set('v.oldAccPhone', getaccPhone);        
        var getaccContact = component.get('v.contactName');
        component.set('v.oldAccContact', getaccContact);
        var getaccEmail = component.get('v.contactEmail');
        component.set('v.oldAccEmail', getaccEmail);
        var getaccBillingStreet = component.get('v.accBillingStreet');
        component.set('v.oldAccBillingStreet', getaccBillingStreet);
        var getaccBillingState = component.get('v.accBillingState');
        component.set('v.oldAccBillingState', getaccBillingState);
        var getaccBillingPostalCode = component.get('v.accBillingPostalCode');
        component.set('v.oldAccBillingPostalCode', getaccBillingPostalCode);
        var getaccBillingCountry = component.get('v.accBillingCountry');
        component.set('v.oldAccBillingCountry', getaccBillingCountry);
        var getaccBillingCity = component.get('v.accBillingCity');
        component.set('v.oldAccBillingCity', getaccBillingCity);
        var getoppCommTypeResidual = component.get('v.oppCommissionType');
        component.set('v.oldOppCommTypeResidual', getoppCommTypeResidual);
        var getoppSwitchingType = component.get('v.oppSwitchingType');
        component.set('v.oldOppSwitchingType', getoppSwitchingType);
        var getoppCpmcredit = component.get('v.isOppCpmCredit');
        component.set('v.oldOppCpmcredit', getoppCpmcredit);
        var getoppselectedValue = component.get('v.selectedValue');
        component.set('v.oldSelectedValue', getoppselectedValue);
        
        
        
        
        
        
        component.set('v.editMode', editMode);
        component.set('v.viewMode', viewMode);
        component.set('v.isDisableChkbox', true);
        var i;
        for (i = 1; i <= 13; i++) {
            var cmpTarget = component.find('removeClass'+i);
            $A.util.removeClass(cmpTarget, 'editBottomBdr');
        }
        var mode = component.get('v.editMode');
        var compEvents = component.getEvent("buttonDisableEvent");
        if(mode){
            
            var cmpTargetSec1 = component.find('sec_1');
            $A.util.addClass(cmpTargetSec1, 'edit-deal-details');
            var cmpTargetSec2 = component.find('sec_2');
            $A.util.addClass(cmpTargetSec2, 'edit-deal-details');
            
            compEvents.setParams({
                "nextButtonDisableResponse" : true
            });
        } else {
            compEvents.setParams({
                "nextButtonDisableResponse" : false
            });
        }
        compEvents.fire();
    },
    
    onChange1: function(component, event, helper) {
        debugger;
        var inputCmp = component.find("accPhoneId");
        var value = inputCmp.get("v.value");
        if (value.length!=10) {
            inputCmp.setCustomValidity("Phone numbers must be 10 digits and not contain any characters");
        } else {
            inputCmp.setCustomValidity(""); // if there was a custom error before, reset it
        }
        inputCmp.reportValidity(); // Tells lightning:input to show the error right away without needing interaction
        
    }  ,
    onChange2: function(component, event, helper) {
        
        var inputCmp = component.find("contactEmailId");
        var value = inputCmp.get("v.value");
        var regExpEmailformat = "^\w+@[a-zA-Z_]+?\.[a-zA-Z]{2,3}$";   
        
        if (/^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$/.test(value) ) {
            inputCmp.setCustomValidity("");
        } else {
            inputCmp.setCustomValidity("Please Provide Valid Email Address"); // if there was a custom error before, reset it
        }
        inputCmp.reportValidity(); // Tells lightning:input to show the error right away without needing interaction
    }  ,
    
    submitData: function(component, event, helper) {
        component.set('v.spinner', true);
        console.log('In &&%%$$## '  );
        var getAccId = component.get('v.accountRecordId');
        var getOppId = component.get('v.opporRecordId');
        var getConId = component.get('v.contactId');
        
        // Contact Name trim()
        
        var getcontactName = component.get('v.contactName');
        if(getcontactName != null){
            var conName = component.find("contactnameId");
            var conNameVal = conName.get("v.value");
            var conNameRemoveSpace = conNameVal.trim();
            component.set('v.contactName', conNameRemoveSpace); 
        }
        var getConExists = component.get('v.conExists');
        
        /*  // billing address trim()
        var address = component.find("addr");
        var addrVal = address.get("v.value");
        var RemoveSpace3 = addrVal.trim();
		component.set('v.accBillingStreet', RemoveSpace3); 
        component.set('v.accBillingCity', RemoveSpace3); 
        component.set('v.accBillingState', RemoveSpace3); 
        component.set('v.accBillingPostalCode', RemoveSpace3); 
        component.set('v.accBillingCountry', RemoveSpace3); 
        console.log('RemoveSpace3 '+RemoveSpace3);
        */
        
        var getcontactEmail = component.get('v.contactEmail');
        var getaccName = component.get('v.accName');
        
        // account name trim()
        if(getaccName != null){
            var accName = component.find("accNameId");
            var accNameVal = accName.get("v.value");
            var RemoveSpace2 = accNameVal.trim();
            component.set('v.accName', RemoveSpace2);
        }
        
        var getaccPhone = component.get('v.accPhone');
        var getaccBillingStreet = component.get('v.accBillingStreet');
        var getaccBillingPostalCode = component.get('v.accBillingPostalCode');
        var getaccBillingCountry = component.get('v.accBillingCountry');
        var getaccBillingCity = component.get('v.accBillingCity');
        var getaccBillingState = component.get('v.accBillingState');
        var oppCommissionType = component.get('v.oppCommissionType');
        var oppSwitchingType = component.get('v.oppSwitchingType');
        var selectedValue = component.get('v.selectedValue');
        var switchSelectValue = component.get('v.selecteValue');
        
        var isOppCpmCreditChked = component.get('v.isOppCpmCredit');
        
        
        // set validation
        var accPhoneId = component.find("accPhoneId");
        var accPhoneValue;
        if (accPhoneId != null){
            accPhoneValue = accPhoneId.get("v.value");
        }        
        
        var contactEmailId = component.find("contactEmailId");
        var contactEmailValue;
        if (contactEmailId != null){
            contactEmailValue = contactEmailId.get("v.value");
        }
        
        
        var billType = component.get('v.billType');
        
        var getChkbox = component.get('v.taxExempt');
        
        //var getCheckkbox = component.get('v.oppCpmCredit');
        
        var isValidate = true;
        ///var inputfield = event.getSource();
        //var getaccPhone = component.get('v.accPhone');
        //component.set('v.accPhone', getaccPhone); 
        if(getaccPhone.length<10){
            component.set('v.spinner', false);
            return 0;
            getaccPhone = component.get('v.oldAccPhone');
            component.set('v.accPhone', getaccPhone);  
        }
        //email
        
        //var contactEmailIds = component.find("contactEmailId");
        //var contactEmailValue = contactEmailIds.get("v.value");
        var getcontactEmail = component.get('v.contactEmail');
        var isValidate = true;
        var regExpEmailformat = /^([a-zA-Z0-9_\.\-])+\@(([a-zA-Z0-9\-])+\.)+([a-zA-Z0-9]{2,4})+$/;   
        var message = "";
        
        if (getConExists){
            var emailCmp = component.find("contactEmailId"),
                chckvalididty = emailCmp.get("v.validity");
            console.log('emailCmp ' +emailCmp);
            if(!chckvalididty.valid){
                emailCmp.setCustomValidity('Please Provide Valid Email Address');
            }
            var phoneId = component.find("accPhoneId"),
                checkPhoneValididty = phoneId.get("v.validity");
            if(!checkPhoneValididty.valid){
                phoneId.setCustomValidity('Please Provide Valid Phone');
            }
            if(!getcontactEmail.toString().match(regExpEmailformat) && getcontactEmail != null){
                isValidate = false; 
                component.set('v.spinner', false);
                component.set('v.message', "Please Enter a Valid Email Address");
                contactEmailId.reportValidity();
                getcontactEmail.reportValidity();
                return 0;
            } 
            else{
                isValidate = true;
            } 
        }else{
            isValidate = true;
        }
        
        if (billType == 'Dual') {
            if(accPhoneValue.length == 0 && billType == 'Dual'){
                accPhoneId.setCustomValidity();
                isValidate = false; 
            } else {
                isValidate = true;
            }
            if(contactEmailValue.length == 0 && billType == 'Dual'){
                contactEmailId.setCustomValidity();
                isValidate = false; 
            } else {
                isValidate = true;
            }
            accPhoneId.reportValidity();
        }
        
        console.log('isValidate-->'+isValidate);
        /*** Vadiation email***/
        
        if (isValidate) {
            var actionSub = component.get("c.doPostData");
            actionSub.setParams({ 
                'AccId': getAccId,
                'OppId': getOppId,
                'ConId': getConId,
                'contactName': getcontactName,
                'contactEmail': getcontactEmail,
                'accName': getaccName,
                'accPhone': getaccPhone,
                'BillingStreet': getaccBillingStreet,
                'BillingPostalCode': getaccBillingPostalCode,
                'BillingCountry': getaccBillingCountry,
                'BillingCity': getaccBillingCity,
                'BillingState': getaccBillingState,
                'oppCommissionType': selectedValue,
                'oppSwitchingType': switchSelectValue,
                'taxExempt': getChkbox,
                'oppCpmCredit': isOppCpmCreditChked,
                'conExists': getConExists                   
            }); 
            console.log('ConId:'+getConId);
            actionSub.setCallback(this, function(result) {
                component.set('v.spinner', false);
                var stateRes = result.getState();
                console.log('response->'+ result.getState());
                if (stateRes === "SUCCESS"){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Success',
                        message: 'Info updated successfully',
                        duration:' 5000',
                        key: 'info_alt',
                        type: 'success',
                        mode: 'pester'
                    });
                    toastEvent.fire();
                    
                    var editMode = false;
                    var viewMode = true;
                    component.set('v.editMode', editMode);
                    component.set('v.viewMode', viewMode);
                    component.set('v.isDisableChkbox', true);
                    component.set('v.spinner', false);
                    var i;
                    for (i = 1; i <= 13; i++) {
                        var cmpTarget = component.find('removeClass'+i);
                        $A.util.addClass(cmpTarget, 'editBottomBdr');
                    }
                    
                    var mode2 = component.get('v.editMode');
                    var compEvents2 = component.getEvent("buttonDisableEvent");
                    if(mode2){
                        compEvents2.setParams({
                            "nextButtonDisableResponse" : true
                            
                        });
                    } else {
                        var cmpTargetSec1 = component.find('sec_1');
                        $A.util.removeClass(cmpTargetSec1, 'edit-deal-details');
                        var cmpTargetSec2 = component.find('sec_2');
                        $A.util.removeClass(cmpTargetSec2, 'edit-deal-details');
                        
                        compEvents2.setParams({
                            "nextButtonDisableResponse" : false
                        });
                    }
                    
                    compEvents2.fire();
                }
                else{
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Error',
                        message: 'This Broker is not authorized for upfront commission payments. ' ,
                        duration:' 5000',
                        key: 'info_alt',
                        type: 'error',
                        mode: 'pester'
                    });
                    toastEvent.fire();
                }
                
            });
            $A.enqueueAction(actionSub);
        }
        
        doInit(component, event, helper)
    },
    validateEmail : function(component, event, helper) {
        
        var contactEmailIds = component.find("contactEmailId");
        var contactEmailValue = contactEmailIds.get("v.value");
        var getcontactEmail = component.get('v.contactEmail');
        var isValidate = true;
        var val=component.find("contactEmailId").get('v.value');
        var regExpEmailformat = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;   
        
        var regExpEmailformatNot = !/^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;   
        var message = "";
        if(getcontactEmail.toString().match(regExpEmailformat) && getcontactEmail != null){
            console.log('In if getcontactEmail ' + getcontactEmail);
            component.set('v.message', message);
            component.set('v.spinner', false);
            isValidate = true;
        } 
        if(!getcontactEmail.toString().match(regExpEmailformatNot) && getcontactEmail != null){
            console.log('In else contactEmailValue '+contactEmailValue);
            isValidate = false; 
            component.set("v.errors", ["Email address 123: " + val]);
            console.log('Error Set called'); 
            component.set('v.message', "Please Enter a Valid Email Address");
            contactEmailId.reportValidity();
            getcontactEmail.reportValidity();
        } 
    },
    
    cancelChildComponentData: function(component, event, helper) {
        
        var editMode = false;
        var viewMode = true;
        
        /*Code updated on 10-12-2021 for remove update on cancel */
        var getaccName = component.get('v.oldAccName');
        component.set('v.accName', getaccName);        
        var getaccPhone = component.get('v.oldAccPhone');
        component.set('v.accPhone', getaccPhone);        
        var getaccContact = component.get('v.oldAccContact');
        component.set('v.contactName', getaccContact);
        var getaccEmail = component.get('v.oldAccEmail');
        component.set('v.contactEmail', getaccEmail);
        var getaccBillingStreet = component.get('v.oldAccBillingStreet');
        component.set('v.accBillingStreet', getaccBillingStreet);
        var getaccBillingState = component.get('v.oldAccBillingState');
        component.set('v.accBillingState', getaccBillingState);
        var getaccBillingPostalCode = component.get('v.oldAccBillingPostalCode');
        component.set('v.accBillingPostalCode', getaccBillingPostalCode);
        var getaccBillingCountry = component.get('v.oldAccBillingCountry');
        component.set('v.accBillingCountry', getaccBillingCountry);
        var getaccBillingCity = component.get('v.oldAccBillingCity');
        component.set('v.accBillingCity', getaccBillingCity);
        var getoppCommTypeResidual = component.get('v.oldOppCommTypeResidual');
        component.set('v.oppCommissionType', getoppCommTypeResidual);
        var getoppSwitchingType = component.get('v.oldOppSwitchingType');
        component.set('v.oppSwitchingType', getoppSwitchingType);
        var getoppCpmcredit = component.get('v.oldOppCpmcredit');
        component.set('v.isOppCpmCredit', getoppCpmcredit);
        var getoppselectedValue = component.get('v.oldSelectedValue');
        component.set('v.selectedValue', getoppselectedValue);
        
        
        
        
        //console.log('ShaSHANK sINGH ');
        component.set('v.editMode', editMode);
        component.set('v.viewMode', viewMode);
        
        var i;
        for (i = 1; i <= 13; i++) {
            var cmpTarget = component.find('removeClass'+i);
            $A.util.addClass(cmpTarget, 'editBottomBdr');
        }
        
        var mode2 = component.get('v.editMode');
        var compEvents2 = component.getEvent("buttonDisableEvent");
        if(mode2){
            compEvents2.setParams({
                "nextButtonDisableResponse" : true
            });
        } else {
            var cmpTargetSec1 = component.find('sec_1');
            $A.util.removeClass(cmpTargetSec1, 'edit-deal-details');
            var cmpTargetSec2 = component.find('sec_2');
            $A.util.removeClass(cmpTargetSec2, 'edit-deal-details');
            
            compEvents2.setParams({
                "nextButtonDisableResponse" : false
            });
        }
        compEvents2.fire();
        doInit();
        
    },
    
    handleCheckbox: function(component, event, helper) {
        //console.log(event.getSource().get('v.checked'));
        var isChked = event.getSource().get('v.checked');
        component.set('v.taxExempt', isChked);
        
        var isCheckked = event.getSource().get('v.checked');
        component.set('v.oppCpmCredit', isCheckked);
    },
    
    changeOppCpmCredit: function(component, event, helper) {
        var Cmp_Credit_chkboxVal = component.find("Cmp_Credit_chkboxVal");
        var Cmp_Credit_chkboxValds = Cmp_Credit_chkboxVal.get("v.checked");
        component.set('v.isOppCpmCredit', Cmp_Credit_chkboxValds);
    },
    
    acceptOnlynumber: function(component, event, helper) {
        
        var keycode = event.getParams('keyCode');
        console.log(keycode);
        var keycode1 = event.getParams().keyCode;
        console.log(keycode1);
        var keycode2 = event.which;
        console.log(keycode2);
        /* if (!(event.shiftKey == false && (keycode == 46 || keycode == 8 || keycode == 37 || keycode == 39 || (keycode >= 48 && keycode <= 57)))) {
        event.preventDefault();
    }*/
        
        
    },
    
    onChange: function(component, event, helper) {
        var isValidate = true; 
        
        var contactEmailId = component.find("contactEmailId");
        var contactEmailValue = contactEmailId.get("v.value");
        
        var phoneId = component.find("accPhoneId");
        var accPhoneValue = phoneId.get("v.value");
        var str2 = contactEmailValue.trim();
        
        console.log('In contactEmailValue ' +contactEmailValue );
        console.log('In str2 ' +str2 );
        
        
        
        checkPhoneValididty = phoneId.get("v.validity");
        console.log('Phone emailCmp ' +phoneId);
        if(!checkPhoneValididty.valid){
            phoneId.setCustomValidity('Please Provide Valid Phone Number');
            console.log('emailCmp %294 ' +phoneId);   
        }
        
        
        
        var inp = event.getSource();
        var val=inp.get('v.value');
        var  val1=val.replaceAll('[^0-9]', '');
        //var lastChar=val1.slice(-1));
        var lastIndex=val1.length-1;
        console.log('shashank'+val1.length);
        if(val1.charCodeAt(lastIndex)>=48 && val1.charCodeAt(lastIndex)<=57 ){
            isValidate = false; 
            console.log('val1 ** '+val1);
        }
        else{
            component.set('v.accPhone', val1.slice(0,-1));
            console.log('val1 && '+val1);
        }
        
        // ...
    }
    
    
    
})