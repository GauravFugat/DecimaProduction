({
    doInit : function(component, event, helper) {
        var totalPriceToPass = [];
        var quoteId = component.find("selectQuote").get("v.value");
        var action = component.get("c.getQLIs");
        var oppRecordData = component.get("v.oppRecord");
        let inputText = component.get("v.oppRecord");
        console.log('inputText'+inputText);
        if(inputText != null){
            component.set("v.hasSelectedQLI",false);
        }
        action.setParams({  
            'quoteId' : component.get("v.oppRecord").SyncedQuoteId,
            'isUpdate': false
        });
        action.setCallback(this, function(response) {
            
            var state = response.getState();
            if (state === "SUCCESS"){
                var quoteLineItems = response.getReturnValue();
                component.set("v.showcreditConfirmation",response.getReturnValue()[0].CreditConfirmation);
                for(var i=0; i< quoteLineItems.length; i++){
                    quoteLineItems[i].objQLI.Broker_Margin_per_unit__c = parseFloat(quoteLineItems[i].objQLI.Broker_Margin_per_unit__c).toFixed(5);
                    quoteLineItems[i].objQLI.Sales_Margin_per_unit__c = parseFloat(quoteLineItems[i].objQLI.Sales_Margin_per_unit__c).toFixed(5);
                    totalPriceToPass.push(quoteLineItems[i].objQLI.Total_Unit_Price__c);
                }
                //console.log('quoteLineItems[0].objQLI.Quote.Price_Type__c-->> '+JSON.stringify(quoteLineItems[0].objQLI));
                //alert('11'+quoteLineItems[0].objQLI.Quote.Price_Type__c);
                //alert('valid cred check-->> '+ quoteLineItems[0].ValidateCreditCheck);
                if (quoteLineItems[0].objQLI.Quote.Price_Type__c == 'Prepayment & Deposit')
                	component.set("v.PDTrue", true);
                else
                    component.set("v.PDTrue", false);
                component.set("v.optionsPD", quoteLineItems[0].options);
                component.set("v.ValidateCreditCheck", quoteLineItems[0].ValidateCreditCheck);
                component.set("v.quoteLineItems", quoteLineItems); 
                component.set("v.Obsolete",quoteLineItems[0].objQLI.Quote.Price__r.Obsolete__c);
            }
        });
        $A.enqueueAction(action);  
        var action1 = component.get("c.getQuoteOptions");
        action1.setParams({  
            'recordId' : component.get("v.recordId")
        });
        action1.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS"){
                component.set("v.quoteOptions", response.getReturnValue()); 
                var resp = response.getReturnValue();
                component.set("v.oppType",resp[0].isLoadFollowing);
                resp.forEach(function(item){
                    if(item.isSynced){
                        component.set("v.billType", item.BillType);
                    }
                });
                component.set('v.spinner', false);
            }
            else
                component.set('v.spinner', false);
        });
        $A.enqueueAction(action1); 
        
        /* var action2 = component.get("c.TotalPriceValidation");
        action2.setParams({ 'OpptyId' : component.get("v.recordId"), 'TotalPriceLst' :totalPriceToPass, 'quoteId' :quoteId}); 
        action2.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('20->'+response.getReturnValue());  
                component.set("v.Validated", response.getReturnValue());           
                component.set("v.selectedTabsoft", "Term");
                component.set("v.spinner", false);
            }
        });
        $A.enqueueAction(action2);*/
        
        
        window.setTimeout(
            $A.getCallback(function() {
                console.log('get data ==>'+JSON.stringify(oppRecordData));
            }), 5000
        );
        
    },
    
    overRideNIMOValidation : function(component, event, helper) {
        var action22 = component.get("c.AllowNIMOValidation");
        action22.setParams({ 'OpptyId' : component.get("v.recordId"), 'TotalPriceLst' :totalPrice.toFixed(5), 'selectedLineItem' :selectedLineItem}); 
        action22.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('20->'+response.getReturnValue());  
                component.set("v.showOverRide", response.getReturnValue());           
                
                component.set("v.spinner", false);
            }
        });
        $A.enqueueAction(action22);
    },
    
    onQuoteChange : function(component, event, helper) {  
        component.set("v.spinner", true);
        var quoteId = component.find("selectQuote").get("v.value");
        var quotes = component.get("v.quoteOptions");
        quotes.forEach(function(item){
            if(item.quoteId == quoteId){
                component.set("v.billType", item.BillType);
            }
        });
        var action = component.get("c.getQLIs");
        action.setParams({  
            'quoteId' : quoteId,
            'isUpdate': true
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS"){
                var quoteLineItems = response.getReturnValue();
                component.set("v.showcreditConfirmation",response.getReturnValue()[0].CreditConfirmation);
                $A.get('e.force:refreshView').fire();
                
                for(var i=0; i< quoteLineItems.length; i++){
                    quoteLineItems[i].objQLI.Broker_Margin_per_unit__c = parseFloat(quoteLineItems[i].objQLI.Broker_Margin_per_unit__c).toFixed(5);
                    quoteLineItems[i].objQLI.Sales_Margin_per_unit__c = parseFloat(quoteLineItems[i].objQLI.Sales_Margin_per_unit__c).toFixed(4);
                }
                //component.set("v.ValidateCreditCheck", quoteLineItems[0].ValidateCreditCheck);
                component.set("v.quoteLineItems", quoteLineItems); 
                component.set("v.spinner", false);
            }
            else{
                alert(JSON.stringify(response.getError()));
                component.set('v.spinner', false);
            }
            
        });
        $A.enqueueAction(action); 
    },
    checkboxSelect: function(component, event, helper) {
        
        var quoteLineItems = component.get("v.quoteLineItems");
        var selectedQuoteLineItem = event.getSource().get("v.name");
        var totalPrice = 0;
        var totalPriceToPass = [];
        var selectedLineItem;
        //now
        // component.set("v.spinner", true);
        //component.set("v.ValidateCreditCheck", true);
        
        for(var i=0; i< quoteLineItems.length; i++){
            if(quoteLineItems[i].isChecked){
                selectedLineItem = quoteLineItems[i].objQLI
                console.log('selectedLineItem'+selectedLineItem);
            }
        }
        for(var i=0; i< quoteLineItems.length; i++){
            if(selectedQuoteLineItem == quoteLineItems[i].objQLI.Id ){
                totalPrice = quoteLineItems[i].objQLI.Total_Unit_Price__c;
            }
            if(quoteLineItems[i].isChecked){
                //now
                //component.set("v.spinner", true);
                totalPrice = quoteLineItems[i].objQLI.Total_Unit_Price__c;
                totalPriceToPass.push(totalPrice.toFixed(5));
            }
        }
        component.set("v.spinner", false);
        
        console.log('totalPrice-->'+JSON.stringify(component.get("v.quoteLineItems")));
        
        console.log(' quoteLineItems[0]-->'+ totalPrice.toFixed(5));
        
        var action2 = component.get("c.TotalPriceValidation");
        action2.setParams({ 'OpptyId' : component.get("v.recordId"), 'TotalPriceLst' :totalPriceToPass, 'selectedLineItem' :selectedLineItem}); 
        action2.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('20->'+response.getReturnValue());  
                component.set("v.Validated", response.getReturnValue());           
                component.set("v.selectedTabsoft", "Term");
                var action22 = component.get("c.AllowNIMOValidation");
                action22.setParams({ 'OpptyId' : component.get("v.recordId"), 'TotalPriceLst' :totalPrice.toFixed(5), 'selectedLineItem' :selectedLineItem}); 
                action22.setCallback(this, function(response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        console.log('20->'+response.getReturnValue());  
                        component.set("v.showOverRide", response.getReturnValue());           
                        
                        component.set("v.spinner", false);
                    }
                });
                $A.enqueueAction(action22);
                component.set("v.spinner", false);
            }
        });
        $A.enqueueAction(action2);
        
        
        
        //var selectedQuoteLineItem = event.getSource().get("v.name");
        
        /*for(var i=0; i< quoteLineItems.length; i++){
            if(selectedQuoteLineItem != quoteLineItems[i].objQLI.Id ){
                quoteLineItems[i].isChecked = false;
            }
        }*/
        if(totalPriceToPass.length > 0){
            component.set("v.hasSelectedQLI", true);
        }
        else{
            component.set("v.hasSelectedQLI", false);
        }
        component.set("v.quoteLineItems", quoteLineItems);
        
    },
    calculateTotalPrice: function(component, event, helper) {
        console.log('--here--');
        var totalPrice = 0;
        var totalPriceToPass = [];
        var index = event.target.id;
        var margin = event.target.name;
        var quoteLineItems = component.get("v.quoteLineItems");
        var selectedLineItem;
        for(var i=0; i< quoteLineItems.length; i++){
            if(quoteLineItems[i].isChecked){
                selectedLineItem = quoteLineItems[i].objQLI
                // totalPriceToPass.push(parseFloat(quoteLineItems[i].objQLI.Base_Price__c) + ( (parseFloat(quoteLineItems[i].objQLI.Sales_Margin_per_unit__c) + parseFloat(quoteLineItems[i].objQLI.Broker_Margin_per_unit__c)) * parseFloat(quoteLineItems[i].objQLI.POR_Tax_Adjustment__c)))
                
            }
        }
        if(margin == 'brokerMargin')
            quoteLineItems[index].objQLI.Broker_Margin_per_unit__c = parseFloat(event.target.value).toFixed(5);
        if(margin == 'salesMargin')
            quoteLineItems[index].objQLI.Sales_Margin_per_unit__c = parseFloat(event.target.value).toFixed(5);
        quoteLineItems[index].objQLI.Total_Unit_Price__c = parseFloat(quoteLineItems[index].objQLI.Base_Price__c) + ( (parseFloat(quoteLineItems[index].objQLI.Sales_Margin_per_unit__c) + parseFloat(quoteLineItems[index].objQLI.Broker_Margin_per_unit__c)) * parseFloat(quoteLineItems[index].objQLI.POR_Tax_Adjustment__c));
        quoteLineItems[index].objQLI.Total_Unit_Price_W_o_Tax__c = parseFloat(quoteLineItems[index].objQLI.Total_Unit_Price__c).toFixed(5) / parseFloat(quoteLineItems[index].objQLI.Tax_Factor__c).toFixed(5);
        totalPrice = quoteLineItems[index].objQLI.Total_Unit_Price__c;
        
        
        for(var i=0;i<quoteLineItems.length;i++){
            if(quoteLineItems[i].isChecked){
                totalPriceToPass.push(parseFloat(quoteLineItems[i].objQLI.Base_Price__c) + ( (parseFloat(quoteLineItems[i].objQLI.Sales_Margin_per_unit__c) + parseFloat(quoteLineItems[i].objQLI.Broker_Margin_per_unit__c)) * parseFloat(quoteLineItems[i].objQLI.POR_Tax_Adjustment__c)))
            }
        }
        console.log('totalPrice-->'+totalPrice.toFixed(5));
        var action2 = component.get("c.TotalPriceValidation");
        action2.setParams({ 'OpptyId' : component.get("v.recordId"), 'TotalPriceLst' :totalPriceToPass, 'selectedLineItem' :selectedLineItem}); 
        action2.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('20->'+response.getReturnValue());  
                component.set("v.Validated", response.getReturnValue());           
                component.set("v.selectedTabsoft", "Term");
                component.set("v.spinner", false);
            }
        });
        $A.enqueueAction(action2);
        component.set("v.quoteLineItems", quoteLineItems);
        
    },
    handleNext : function(component, event, helper) {
        //alert('in');
        var selectedLineItem = [];
        var selectedterms = [];
        component.set('v.spinner', true);
        var quoteLineItems = component.get("v.quoteLineItems");
        for(var i=0; i< quoteLineItems.length; i++){
            if(quoteLineItems[i].isChecked){
             
                selectedLineItem.push(quoteLineItems[i].objQLI);
                selectedterms.push(quoteLineItems[i].objQLI.Term_Months__c)
              
            }
        }
        component.set('v.seletedTerm', selectedterms);
       
        
        console.log('--180--selectedLineItem-->'+JSON.stringify(selectedLineItem));
        console.log('--180--selectedLineItem-->'+String(component.get("v.selectedPD")));
        
        /*component.set('v.accountName', component.get("v.oppRecord").Account_Name__c);
        component.set('v.customerName', component.get("v.customerContactrole").Contact.FirstName);*/
        var action1 = component.get("c.updateQuote");
        action1.setParams({  
            'selectedLineItem' : selectedLineItem,
            'selectedOption' : String(component.get("v.selectedPD"))
        });
        action1.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS"){
                console.log('--190--');
                var contactRoles = response.getReturnValue(); 
                for(var i=0; i<contactRoles.length;i++){
                    if(contactRoles[i].Role == 'Decision Maker'){
                        component.set("v.editDM", false);
                        component.set("v.customerContactRole", contactRoles[i]);
                    }
                    if(contactRoles[i].Role == 'Evaluator'){
                        component.set("v.editBroker", false);
                        component.set("v.brokerContactRole", contactRoles[i]);
                    }
                }
                if(component.get("v.customerContactRole") == null || component.get("v.brokerContactRole") == null ){
                    var action = component.get("c.getCustomerContacts");
                    action.setParams({  
                        'oppId' : component.get("v.recordId")
                    });
                    action.setCallback(this, function(response1) {
                        var state = response1.getState();
                        if (state === "SUCCESS"){
                            component.set("v.customerContacts", response1.getReturnValue());
                        }
                    });
                    $A.enqueueAction(action);
                }
                component.set("v.showScreen1", false);
                component.set("v.contactRoles", response.getReturnValue()); 
                
                component.set('v.spinner', false);
            }
            else
                component.set('v.spinner', false);
            
        });
        $A.enqueueAction(action1);
    },
    handleClose : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire() 
    },
    
    goToValidationScreen : function(component, event, helper){  
        console.log('--322--selectedPD-->'+String(component.get("v.selectedPD")));
        component.set('v.spinner', true);
        var Optionselected = '';
        Optionselected = component.find("agreementDelivery").get("v.value");
        
        var action1 = component.get("c.Acc_contractValidation");
        action1.setParams({  
            'OpptyId' : component.get("v.recordId"),
            'Optionselected' : Optionselected
        });
        action1.setCallback(this, function(response1) {
            var state = response1.getState();
            if (state === "SUCCESS" && response1.getReturnValue().exceptionMessage == undefined){
                
                var Opp = response1.getReturnValue();
               // alert('opp-->> '+JSON.stringify(Opp));
                if(Opp.missingLstUA.length > 0){
                    component.set("v.missedFields",Opp.missingLstUA.toString());
                }
                component.set("v.optionSelected",component.find("agreementDelivery").get("v.value"));
                component.set("v.Opp",Opp);
                component.set("v.showValidationScreen",true);
                component.set("v.showScreen1",false);
                component.set("v.showScreen2", false);
                component.set("v.showScreen3", true);
                
            }
            else{
                component.set('v.spinner', false);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "We hit a Snag!",
                    "type" : "error",
                    "message":response1.getReturnValue().exceptionMessage //"This Broker is not authorized for upfront commission payments."
                });
                toastEvent.fire();
            }
            component.set('v.spinner', false);
        });
        $A.enqueueAction(action1);
    },
    
    doRefresh : function(component, event, helper){  
        //alert('22');
        component.set('v.spinner', true);
        var Optionselected = '';
        Optionselected = component.get("v.optionSelected");
        console.log('In');
        var action1 = component.get("c.Acc_contractValidation");
        action1.setParams({  
            'OpptyId' : component.get("v.recordId"),
            'Optionselected' : Optionselected
        });
        console.log('In1');
        action1.setCallback(this, function(response1) {
            var state = response1.getState();
            if (state === "SUCCESS"){
                
                var Opp = response1.getReturnValue();
                console.log('-->',component.get("v.optionSelected"));
                component.set("v.Opp",Opp);
                component.set("v.showValidationScreen",true);
                component.set("v.showScreen1",false);
                component.set("v.showScreen2", false);
                component.set("v.showScreen3", true);
                
            }
            console.log('In11');
            component.set('v.spinner', false);
        });
        $A.enqueueAction(action1);
    },
    
    refresht : function(component, event, helper){  
        component.set('v.spinner', true);
        var Optionselected = '';
        Optionselected = component.get("v.optionSelected");
        
        var action1 = component.get("c.Acc_contractValidation");
        action1.setParams({  
            'OpptyId' : component.get("v.recordId"),
            'Optionselected' : Optionselected,
            'forcedValid' : true
        });
        action1.setCallback(this, function(response1) {
            var state = response1.getState();
            if (state === "SUCCESS"){
                
                var Opp = response1.getReturnValue();
                console.log('-->',component.get("v.optionSelected"));
                component.set("v.Opp",Opp);
                component.set("v.showValidationScreen",true);
                component.set("v.showScreen1",false);
                component.set("v.showScreen2", false);
                component.set("v.showScreen3", true);
                component.set("v.showScreen3", true);
            }
            component.set('v.spinner', false);
        });
        $A.enqueueAction(action1);
    },
    
    
    
    /*********JS for loader spinner screen3**********/
    handleNextScreen2: function(component, event, helper){
        //alert('--422--');
        component.set('v.spinner', true);
       // alert('creditConfirmValue-->> '+component.get("v.creditConfirmValue"));
      //  alert('selRadioVal-->> '+component.get("v.selRadioVal"));
        var action = component.get("c.secondScreenExit");
        action.setParams({  
            'oppId' : component.get("v.recordId"),
            'creditConfirmValue' : component.get("v.creditConfirmValue"),
            'selRadioVal' : component.get("v.selRadioVal")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
           // alert('response->'+ response.getState());
            if (state === "SUCCESS"){
                //alert('444');
                component.set("v.showScreen3", false);
                if(component.get("v.optionSelected") == 'option1'){
                    window.setTimeout(
                        $A.getCallback(function() {
                            var urlEvent = $A.get("e.force:navigateToURL");
                            urlEvent.setParams({
                                "url": "/apex/echosign_dev1__AgreementTemplateProcess?masterId="+component.get("v.recordId")+"&templateId="+$A.get("{!$Label.c.PFC_Adobe_Template_Id}")
                            });
                            urlEvent.fire();
                        }), 30000
                    );
                }
                else if(component.get("v.optionSelected") == 'option2'){
                    window.setTimeout(
                        $A.getCallback(function() {
                            component.set("v.sendEmail", true);
                            //$A.get("e.force:closeQuickAction").fire();
                            component.set('v.spinner', false);
                        }), 30000
                    );
                }
                    else{
                        window.setTimeout(
                            $A.getCallback(function() {
                                $A.get("e.force:closeQuickAction").fire();
                            }), 30000
                        );
                    }     
                
            }
            else
                component.set("v.validationError",response.getError() );
            
        });
        
        $A.enqueueAction(action);  
    },
    
    editContactRole : function(component, event, helper) {
        //now
        //component.set("v.spinner", true);
        
        $A.util.removeClass(component.find("Spinner"), "slds-hide");
        $A.util.addClass(component.find("Spinner"), "slds-show");
        var edit = component.get("v.editBroker");
        edit = !edit;
        if(edit == false){
            helper.updateContactRoleHelper(component,component.get("v.selectedBrokerContact").Id, component.get("v.brokerContactRole"), 'Evaluator' )
        }
        else
            component.set('v.editBroker', edit);
        
    },
    editContactRoleCustomer: function(component, event, helper) {
        //now
        //component.set("v.spinner", true);
        
        $A.util.removeClass(component.find("Spinner"), "slds-hide");
        $A.util.addClass(component.find("Spinner"), "slds-show");
        var edit = component.get("v.editDM");
        edit = !edit;
        if(edit == false){
            helper.updateContactRoleHelper(component,component.get("v.selectedCustomerContact").Id, component.get("v.customerContactRole"), 'Decision Maker' )
        }
        else
            component.set('v.editDM', edit);
        //now
           // component.set("v.spinner", true);
        ;
    },
    sendEmail: function(component, event, helper){
        
        var sendEmailCmp = component.find('sendEmailCmp');
        sendEmailCmp.sendEmail();
    },
    cancelEdit: function(component, event, helper){
        component.set("v.editDM", false);
    },
    cancelEditBroker: function(component, event, helper){
        component.set("v.editBroker", false);
    },
    
    showToolTip : function(c, e, h) {
        c.set("v.tooltip" , true);
        
    },
    
    HideToolTip : function(c,e,h){
        c.set("v.tooltip" , false);
    },
    
    applyCSS: function(cmp, event) {
        event.target.style.color = 'blue';
    },
    
    allowNext : function(component, event, helper) {
        //now
        //component.set("v.spinner", true);
        
        var allowGenQuote = component.find("CPR").get("v.checked");
        component.set("v.Validated",allowGenQuote);
        //now
        //component.set('v.spinner', true);
        
        component.set("v.showOverRideNew",true);
        component.set("v.showOverRide",false);
      //  component.set("v.hasSelectedQLI",false); // This line commented by Suhas
    },
    
    allowNextNew : function(component, event, helper) {
        //now
        //component.set("v.spinner", true);
        console.log('In allow next new function');
        console.log('showOverRideNew value is::' +  component.get("v.showOverRideNew"));
        
        var allowGenQuote = component.find("CPRNew").get("v.checked");
        console.log('allowGenQuote ==' + allowGenQuote);
        //now
        //component.set('v.spinner', true);
        
        component.set("v.Validated",allowGenQuote);
        component.set("v.showOverRideNew",true);
        component.set("v.showOverRide",false);
        component.set("v.hasSelectedQLI",false);
      //now
        //  component.set("v.spinner", true);
        
    },
    
    submitChildComponentData : function(component,helper,event){
        var childComponent = component.find("accountComponnentId");
        //now
        //component.set("v.spinner", true);
        
        childComponent.getScoreMethod();
    },
    
    
    handleParentEvent : function(component, event, helper) {
      //  component.set("v.spinner", true);
        //debugger;
        var response = event.getParam("nextButtonDisableResponse"); 
        console.log('parent com event ==>'+response);        
        component.set("v.eventValue", response); 
        //component.set("v.eventValue", response); 
    },
    
    // When Prepayment or Deposit radiobutton is selected
    handleChange: function (cmp, event) {
        var changeValue = event.getParam("value");
        //alert(cmp.find("radioGroupPD").get("v.value"));
        cmp.set("v.ValidateCreditCheck",true);
        cmp.set("v.selRadioVal",changeValue);
        cmp.set("v.isSelectedPD",true);
        //cmp.set("v.showScreen1",false);
        //if(changeValue != null)
        //alert('change == >> '+changeValue);
    }
    
    
})