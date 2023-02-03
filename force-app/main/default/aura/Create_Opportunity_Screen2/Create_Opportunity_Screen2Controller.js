({
    doInit: function(component, event, helper) {
         if(component.get("v.loadFollowing") == true){
            var annualVol = component.get("v.AnnualVolumekWh") * (component.get("v.LoadFollowingPercent")/100) ;
             console.log('annualVol not ceil-->> '+annualVol);
             annualVol=Math.round(annualVol);
             console.log('annualVol ceil-->> '+annualVol);
            if(component.find("ExpectedAnnualVolume").get("v.value")!=''){
                component.find("ExpectedAnnualVolume").set("v.value",annualVol);
            }
        }else{
            if(component.find("ExpectedAnnualVolume").get("v.value")!=''){
                component.find("ExpectedAnnualVolume").set("v.value",component.get("v.AnnualVolumekWh"));
            }
        }
        
        component.set("v.selectedBrokerAccount",component.get("v.BrokerAcc"));
        console.log('selectedBrokerContact->'+JSON.stringify(component.get("v.selectedBrokerContact")));
        component.set("v.spinner", true);
        console.log('UALSt in Child - >'+JSON.stringify(component.get("v.selectedContacts")));
        // alert('salesRenew--'+component.get("v.salesRenew"));
        // alert('BillTypeSalesRenew--'+component.get("v.BillTypeSalesRenew"));
        //Get SaleTypePicklist
        var UAList = component.get("v.selectedContacts");
        console.log('2nd Screen Selected Acc-->'+UAList.length);
        if(component.get("v.BlendAndExtend")){
            component.find("selectSaleType").set("v.value",'Blend and Extend')
        }
        
        if(component.get("v.selectedSaleType") == 'Renewal'){
            //alert("With Renewal");
            component.find("selectSaleType").set("v.value",'Renewal')
        }
        //alert(component.get("v.loadFollowing"));
        if(component.get("v.loadFollowing") == true){
            //alert("In If");
            component.find("selectSaleType").set("v.value",'Load Following')
        }
        var action = component.get("c.SaleType");
        
        var opts=[];
        action.setCallback(this, function(a) {
            console.log('Sale Type--'+JSON.stringify(a.getReturnValue()));
            component.set("v.SaleType", a.getReturnValue());
            
        });
        
        
        $A.enqueueAction(action); 
        
        //Get ProductFamily Picklist
        var action2 = component.get("c.ProductFamily");
        
        var opts=[];
        action2.setCallback(this, function(a) {
            console.log(JSON.stringify(a.getReturnValue()));
            component.set("v.ProductFamily", a.getReturnValue());
            var ProductFamily = a.getReturnValue();
            console.log('ProductFamily-->'+a.getReturnValue());
            window.setTimeout(
                $A.getCallback( function() {
                    // Now set our preferred value
                    // component.find("ProductFamily").set("v.value", ProductFamily[0]);
                }),0);
        });
        $A.enqueueAction(action2); 
        
        //Get Product Picklist
        var selectedFamily = '';
        var action = component.get("c.GetProducts");
        var products = [];
        action.setParams({  
            'ProductFamily' : 'Fixed',
            'State' : component.get("v.State"),
        });
        
        action.setCallback(this, function(a) {
            console.log(JSON.stringify(a.getReturnValue()));
            products = a.getReturnValue();
            var listOfProd = [];
            for ( var key in products ) {
                listOfProd.push({value:products[key].Name, key:products[key].Id});
            }
            component.set("v.Product", listOfProd);
            component.set("v.spinner", false);
            // component.find("selectProduct").set("v.value", products[0]);
        });
        $A.enqueueAction(action); 
        
        
    },
    showInvoiceBillingType: function(component, event, helper) {
        var selectedBillType = '';
        if(selectedBillType === "Dual")
            component.set("v.showInvoiceBillingType", true);
        else
            component.set("v.showInvoiceBillingType", false);
    },
    CPRcheck: function(component, event, helper) {
        var CPR = component.find("CPR").get("v.value");
        if(CPR==true){
            component.set("v.CreatePricingRequest",false);    
        }
        
        
    },
    
    CreatePricingRequest : function(component, event, helper) {
        //alert('<------CreatePricingRequest------>');
        var CPR = component.get("v.CreatePricingRequest");
        var ExpectedAnnualVolumeVar = 0;
        if(component.find("ExpectedAnnualVolume").get("v.value")!=''){
            ExpectedAnnualVolumeVar = component.find("ExpectedAnnualVolume").get("v.value");
        }
        var BrokerMarginVar = 0;
        var NameSuffixVar = '';
        if(component.find("BrokerMargin").get("v.value")!=''){
            BrokerMarginVar = component.find("BrokerMargin").get("v.value");
        }
        if(component.find("NameSuffix").get("v.value")!=''){
            NameSuffixVar = component.find("NameSuffix").get("v.value");
        }
        if(CPR==true){
            console.log('Opp and PR');
            
            var PricingRequest = {
                SwitchingType:component.find("selectSwitchingType").get("v.value"),
                SaleType:component.find("selectSaleType").get("v.value"),
                BrokerMargin:BrokerMarginVar,
                NameSuffix:NameSuffixVar,
                ExpectedAnnualVolume:ExpectedAnnualVolumeVar
            };
            // alert('if');
            helper.CreateOpportunityAndPR(component, event, helper,PricingRequest);
        }else{
            console.log('Opp only');
            var PricingRequest = {
                SwitchingType:component.find("selectSwitchingType").get("v.value"),
                SaleType:component.find("selectSaleType").get("v.value"),
                BrokerMargin:BrokerMarginVar,
                NameSuffix:NameSuffixVar,
                ExpectedAnnualVolume:ExpectedAnnualVolumeVar
            };
            //alert('else');
            helper.CreateOpportunityAndPR(component, event, helper,PricingRequest);
        }
        
    },
    
    onProductFamilyChange : function(component, event, helper) {
        component.set("v.spinner", true);
        var selectedFamily = component.find("ProductFamily").get("v.value");
        var action = component.get("c.GetProducts");
        var products = [];
        
        action.setParams({  
            'ProductFamily' : selectedFamily,
            'State' : component.get("v.State")
        });
        
        action.setCallback(this, function(a) {
            /*console.log(JSON.stringify(a.getReturnValue()));
            
            products = a.getReturnValue();
            
            
            component.set("v.Product",products);
            component.find("selectProduct").set("v.value", products[0]);
            component.set("v.spinner", false);*/
            console.log(JSON.stringify(a.getReturnValue()));
            products = a.getReturnValue();
            var listOfProd = [];
            for ( var key in products ) {
                listOfProd.push({value:products[key].Name, key:products[key].Id});
            }
            component.set("v.Product", listOfProd);
            component.set("v.spinner", false);
            component.find("selectProduct").set("v.value", products[0]);
            
        });
        $A.enqueueAction(action); 
        
    },
    handlePrevious:function(component,event,helper){
        var event = component.getEvent("cmpEvent"); 
        
        //set the response value inside eventResponse of componentEvent attribute   
        event.setParams({
            "eventResponse" : true
        }); 
        
        //fire the event    
        event.fire();
    },
    
    handleComponentEvent:function(component,event,helper){
        
        /*var response = event.getParam("recordByEvent");
        console.log('User ->'+JSON.stringify(response));
        component.set("v.selectedUserId",response);*/
    },
    editAccount : function(component, event, helper) {
        component.set("v.selectedAccountId",component.get("v.selectedBrokerAccount").Id);
        // alert(JSON.stringify(component.get("v.selectedBrokerAccount")));
    },
    editCPMUser : function(component, event, helper) {
        component.get("v.SelectedCPM").Id;
        component.set("v.selectedUserId",component.get("v.SelectedCPM"));
        var forOpen = component.find("slds-has-error");
        $A.util.removeClass(forOpen, 'slds-has-error');
        //alert(JSON.stringify(component.get("v.SelectedCPM")));
    },
    dueDatechange : function(component, event, helper) {
        
        var DueDate = component.find("dueDate").get("v.value");
        console.log('DueDate-->'+DueDate);
        if(typeof DueDate!='undefined' || DueDate!='' || DueDate!=null){
            component.set("v.duedateValidation",false);
            
        }
    },
    
    handleComponentEvent : function(component, event, helper) {
        // alert('Inside parent event method');
        var valueFromChild = event.getParam("showNext");
        // alert('childvalue : '+valueFromChild);
        component.set("v.IsDisabledNextLookup", valueFromChild);
    },
    onChange : function(component, event, helper) {
        // alert('IsDisabledNextLookup--'+component.get("v.IsDisabledNextLookup"))
        var ExpectedAnnualVolume = component.find("ExpectedAnnualVolume").get("v.value");
        var selectedLookUpRecords = component.get("v.selectedLookUpRecords");
        console.log('selectedLookUpRecords--'+selectedLookUpRecords);
        if(ExpectedAnnualVolume <= 0  ){
            // var vaildationFailReason = "The Field Expected Business Volume should be greater than 0";
            component.set("v.IsDisabledNext",false);
        }
        else{
            // var vaildationFailReason = " ";
            component.set("v.IsDisabledNext", true);
        }
    }
    
})