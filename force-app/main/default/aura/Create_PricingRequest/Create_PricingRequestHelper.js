({
    CreateOpportunityAndPR : function(component,event,helper,PricingRequestList){
        console.log('PricingRequestList'+(JSON.stringify(PricingRequestList)));
       //alert('4'); 
        component.set("v.spinner",true);
        var UAList = component.get("v.selectedContacts");
        var CPMUser = component.get("v.selectedUserId");
        var EditStartDates = component.get("v.chkboxvalue");
        //  alert(component.get("v.selectedContacts"));
        console.log('creditRequired--->>> '+ component.get("v.creditRequired"));
        var action = component.get("c.CreatePR");
        var markToMarket = null;
        if(component.get("v.selectedSaleType") == 'Blend and Extend'){
            markToMarket = component.find('MarkToMarket').get("v.value");
        }
        action.setParams({  
            'UAList' : UAList,
            'PricingRequest' : PricingRequestList,
            'Opp' : component.get("v.recordId"),
            'CPMUser':CPMUser,
            'checkRequestType' : component.get("v.RequestTypevalue"),
            'contractId': component.get("v.contractId"),
            'creditRequired': component.get("v.creditRequired"),
            'MarkToMarket': markToMarket,
            'optionSelected' : component.get("v.selectedOption"),
            'orignalPRId' : component.get("v.PricingRequestId"),
            'notifyMeCheckboxVal': component.get("v.NotifyMeBoolean"),
            'availabeleBillTypes' : component.get("v.availabeleBillType")
           // 'selectedBillType' : component.get("v.bilTypValueaftChange"),
           // 'ifBilTypValNotChanged' : component.get("v.ifBilTypValNotChanged"),
           // 'opetnSelect' : component.get("v.opetnSelect"),
        });
        action.setCallback(this, function(response) {
            
            var state = response.getState();
            if (state === "SUCCESS"){
                $A.get('e.force:refreshView').fire();
                var chek = component.get("v.NewOppId");  
                if(typeof chek == 'undefined'){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Congratulations!",
                        "type" : "success", 
                        "message": "Pricing Request has been Created"
                    });
                    toastEvent.fire();
                }
                else{
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        type:'success',
                        title:'Congratulations',
                        message: 'This is a required message',
                        messageTemplate: '{1} {0} created!',
                        messageTemplateData: ['record', {
                            url: '/'+component.get("v.NewOppId"),
                            label: 'Opportunity',
                        }
                                             ]
                    });
                    toastEvent.fire();
                    if(component.get("v.fromSplitOpp") == 'fromSplitOpp'){
                        component.set("v.spinner",false); 
                        component.set("v.showScreen2",false);
                        if(component.get("v.checkLength") == 0){
                            component.set("v.showScreen3",true);
                        }else{
                            component.set("v.showScreen1",true);
                        }
                        component.set("v.showScreen4",false); 
                    }
                }
                var fromOppScreen2 = component.get("v.fromOppScreen2");
                if(fromOppScreen2){
                    var urlEvent = $A.get("e.force:navigateToURL");
                    urlEvent.setParams({
                        "url": '/'+ component.get("v.accIdfromSC2")
                    });
                    if(component.get("v.contractId") == null){
                      urlEvent.fire();
                    }else{
                        $A.get("e.force:closeQuickAction").fire();
                    }
                }else{
                    if(component.get("v.fromSplitOpp") != 'fromSplitOpp'){
                        $A.get("e.force:closeQuickAction").fire();
                    }
                }
            }
            else{
                var ermsg = component.get("v.Errmsg");
                component.set("v.spinner",false);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "We hit a snag!",
                    "type" : "error",
                    "message": ermsg
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
    },
    getProductFamily:function(component,event,helper,State){
        var selectedFamily = component.find("ProductFamily").get("v.value");
        var action = component.get("c.GetProducts");
        var products = [];
        action.setParams({  
            'ProductFamily' : 'Fixed',
            'State' : State,
            'recordId' :component.get("v.recordId")
            //'saleTypLoadFollow': component.get("v.saleTypLoadFollow")
        });
        action.setCallback(this, function(a) {
            products = a.getReturnValue();
            var listOfProd = [];
            for ( var key in products ) {
                listOfProd.push(products[key]);
            }
            var listofPR = component.get("v.StorePRList");
            if(!$A.util.isEmpty(products)){
                listofPR[0].Product_Lookup__c = listOfProd[0].Id;
            }
            listofPR[0].picklistValues = listOfProd;
            component.set("v.StorePRList", listofPR);
            component.set("v.spinner", false);
        });
        $A.enqueueAction(action); 
    },
    toggleAction : function(component, event, secId) {
        var acc = component.find(secId);
        for(var cmp in acc) {
            $A.util.toggleClass(acc[cmp], 'slds-show');  
            if(component.get("v.chkboxvalue") == false){
                $A.util.toggleClass(acc[cmp], 'slds-hide'); 
            }
        }
    },
    toggleActionA : function(component, event, secId) {
        var acc = component.find(secId);
        for(var cmp in acc) {
            $A.util.toggleClass(acc[cmp], 'slds-show');
            if(component.get("v.dontcollapse") == true)
                $A.util.toggleClass(acc[cmp], 'slds-hide'); 
        }
        component.set("v.dontcollapse",true);
        var collapse = component.get("v.collapse");
       if(collapse == true){
            //component.set("v.collapse",false); 
        }
        else if(collapse == false){
           // component.set("v.collapse",true);
        } 
    },
    addChangeRequest: function(component, event) {
    },
    addChangeRequestRecord: function(component, event) {
       // alert('in helper');
        /*if(component.get("v.selectedOption") == 'option3'){
            var StorePRList = component.get("v.StorePRList");
                
                StorePRList.push({
                    'sobjectType': 'Pricing_Request__c',
                    'Product_Lookup__c': StorePRList[0].Product_Lookup__c,
                    'Bill_Type__c':StorePRList[0].Bill_Type__c,
                    'Invoice_Billing_Type__c':StorePRList[0].Invoice_Billing_Type__c,
                    'picklistValues': StorePRList[0].picklistValues,
                    'RECSpicklist' : StorePRList[0].RECSpicklist,
                    'Treatmentpicklst' : StorePRList[0].Treatmentpicklst,
                    'Voluntary_RECs_percent__c' : StorePRList[0].Voluntary_RECs_percent__c,
                    'Treatment__c' : StorePRList[0].Treatment__c,
                    'Voluntary_RECs__c' : StorePRList[0].Voluntary_RECs__c,
                    'duplicate':'no'
                });
                
                component.set("v.StorePRList", StorePRList);
            
             
        }else{*/
      // alert('(component.get("v.VoluntaryRECs").length'+(component.get("v.VoluntaryRECs").length));
       //alert(JSON.stringify(component.get("v.PricingListToPass")));
        if(component.get("v.VoluntaryRECs").length == 0 ){
            var actionOne = component.get("c.GetUAOsandState");
            actionOne.setParams({  
                'recordId' :component.get("v.recordId"),
                'ProductName' : 'Fully Fixed'
            });
            actionOne.setCallback(this, function(ab) {
                var result = ab.getReturnValue();
                component.set("v.Treatment",result.Treatment);
                component.set("v.VoluntaryRECs",result.RECS);
                var StorePRList = component.get("v.StorePRList");
                StorePRList.push({
                    'sobjectType': 'Pricing_Request__c',
                    'Product_Lookup__c': component.get("v.DefaultProductLookup"),
                    'Bill_Type__c':'UCB',
                    'Invoice_Billing_Type__c':'Summary Billing',
                    'picklistValues': component.get("v.DefaultProduct"),
                    'RECSpicklist' : component.get("v.VoluntaryRECs"),
                    'Treatmentpicklst' : component.get("v.Treatment"),
                    'Voluntary_RECs_percent__c' : 100,
                    'Family' : 'Fixed',
                    'duplicate':'no'
                });
                component.set("v.StorePRList", StorePRList);
                var a = component.get('c.showInvoiceBillingTypeA');
                $A.enqueueAction(a);
            });
            $A.enqueueAction(actionOne);
        }
        else{
           // alert('JSON.stringify(component.get("v.PricingListToPass"))'+JSON.stringify(component.get("v.StorePRList")));
            if(JSON.stringify(component.get("v.PricingListToPass")) != '{}'){
            component.set("v.ProductFamily",component.get("v.PricingListToPass").prodFamily);
                component.set("v.DefaultProductLookup",component.get("v.PricingListToPass").DefaultProductLookup);
                component.set("v.BillTypeVal",component.get("v.PricingListToPass").BillTypeVal);
                component.set("v.DefaultProduct",component.get("v.PricingListToPass").DefaultProduct);
				component.set("v.VoluntaryRECs",component.get("v.PricingListToPass").VoluntaryRECs);
                component.set("v.InitRECs",component.get("v.PricingListToPass").VoluntaryRECs);
        		component.set("v.Treatment",component.get("v.PricingListToPass").Treatment);
                component.set("v.InitTreatment",component.get("v.PricingListToPass").Treatment);
            }
             var invBillingTyp ='';
            
          //  let invBillingTyp ;
            if(component.get("v.selectedOption") == 'option1'){
                invBillingTyp = 'Summary Billing';
            }else{
                invBillingTyp = "None";
            }
            
            var billTp ='';
            if(component.get("v.selectedOption") == 'option3'){
                billTp = component.get("v.StorePRList")[0].Bill_Type__c;
            }else{
                
            }
            
            var StorePRList = component.get("v.StorePRList");
            StorePRList.push({
                'sobjectType': 'Pricing_Request__c',
                'Product_Lookup__c': component.get("v.DefaultProductLookup"),
                'Bill_Type__c':component.get("v.BillTypeVal"),
                'Invoice_Billing_Type__c':invBillingTyp, //'Summary Billing',
                'picklistValues': component.get("v.DefaultProduct"),
                'RECSpicklist' : component.get("v.InitRECs"),
                'Treatmentpicklst' : component.get("v.InitTreatment"),
                'Voluntary_RECs_percent__c' : StorePRList[0].Voluntary_RECs_percent__c,
                'Voluntary_RECs__c' : StorePRList[0].Voluntary_RECs__c,
                'Family' : 'Fixed',
                'Treatment__c' : StorePRList[0].Treatment__c,
                'duplicate':'no'
            });
            //alert('StorePRList::::'+StorePRList.length);
            component.set("v.StorePRList", StorePRList);
           // component.set("v.StorePRList1", StorePRList);
            var a = component.get('c.showInvoiceBillingTypeA ');
            $A.enqueueAction(a);
           /* var b = component.get('c.getStorePRList ');
            $A.enqueueAction(b); */
           // alert('240'+JSON.stringify(component.get("v.StorePRList")));
        }
        
    },
    getDefaultProducts : function(component, event){
        //retrive Products
        var action3 = component.get("c.GetProducts");
        var products = [];
        var selectedFamily = 'Fixed';
        action3.setParams({  
            'ProductFamily' : selectedFamily,
            'State' : 'OH',
            'recordId' : null //component.get("v.recordId")
            //'saleTypLoadFollow': false //component.get("v.saleTypLoadFollow")
        });
        action3.setCallback(this, function(a) {
            products = a.getReturnValue();
            var listOfProd = [];
            for ( var key in products ) {
                listOfProd.push(products[key]);
            }
            component.set("v.DefaultProduct", listOfProd);
            var listofPR = component.get("v.StorePRList");
            //var index = event.getSource().get("v.name");
            if(!$A.util.isEmpty(products)){
                listofPR[0].Product_Lookup__c = listOfProd[0].Id;
                component.set("v.DefaultProductLookup", listOfProd[0].Id);
            }
            listofPR[0].picklistValues = listOfProd;
            component.set("v.StorePRList", listofPR);
        });
        $A.enqueueAction(action3); 
    },
    fetchPickListValueBT: function(component) {	
        var actionAct = component.get("c.getselectOption");
        actionAct.setParams({
            "objectType": "Pricing_Request__c",
            "fieldName": "Bill_Type__c"
        });
        actionAct.setCallback(this, function(response) {
            var state = response.getState();
            var actsRelatedHOP = [];
            var list = response.getReturnValue();
            component.set("v.BillType", list);
        });
        
        $A.enqueueAction(actionAct);
    },
    fetchPickListValueIBT: function(component) {	
        
        var actionAct = component.get("c.getselectOption");
        actionAct.setParams({
            "objectType": "Pricing_Request__c",
            "fieldName": "Invoice_Billing_Type__c"
        });
        
        actionAct.setCallback(this, function(response) {
            
            var state = response.getState(); 
            var list = response.getReturnValue();
            
            
            
        });
        
        $A.enqueueAction(actionAct);
    },
    
    setVoluntaryPicklists: function(component, event, helper, productId,index) {
        component.set("v.spinner", true);
        var StorePRList = component.get("v.StorePRList");
        var action = component.get("c.getPicklists");
        
        action.setParams({  
            'recordId' :component.get("v.recordId"),
            'SelectedProduct' : productId
        });
        action.setCallback(this, function(a) {
            var result = a.getReturnValue();
            
            StorePRList[index].RECSpicklist = result.RECS;
            StorePRList[index].Treatmentpicklst = result.Treatment; 
            StorePRList[index].Voluntary_RECs_percent__c = 100;
            // if(index != 0){
            StorePRList[index].Voluntary_RECs__c = result.RECS[0];
            // }
            
            StorePRList[index].Treatment__c = result.Treatment[0];
            
            if(component.get("v.setTreatment") == false){
                component.set("v.InitTreatment",result.Treatment);
                component.set("v.InitRECs",result.RECS);
                component.set("v.setTreatment",true);
            }
            component.set("v.StorePRList",StorePRList);
            var a = component.get('c.showInvoiceBillingTypeB');
                $A.enqueueAction(a);
            component.set("v.spinner", false); 
        });
        $A.enqueueAction(action);
        
    },
    getExistingPR :function(component, event){
        var action = component.get("c.getExistingPR");
        action.setParams({  
            'Opp' : component.get("v.recordId"),
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS"){
                var list = response.getReturnValue();
                if(list.length == 0){
                    component.set("v.totalRecordsCount", 0);  
                }
                for (var i = 0; i < list.length; i++) {
                    list[i].isChecked = false;
                }
                component.set("v.existingPRList",list);
                if(list.length > 0){
                    var selectOption = 'option2';
                    component.set("v.selectedOption",selectOption);
                    component.set("v.RequestTypevalue",true); 
                    //component.set("v.selectedBillTypeNew",selectOption)
                }
                else{
                    
                }
            }
            else{
                var ermsg = component.get("v.Errmsg");
                component.set("v.spinner",false);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "We hit a snag!",
                    "type" : "error",
                    "message": ermsg
                });
                toastEvent.fire();
                
            }
        });
        $A.enqueueAction(action);
    },
     //Changes 23/06
       toggleHelper : function(component,event) {
    var toggleText = component.find("tooltip");
    $A.util.toggleClass(toggleText, "toggle");
   }
})