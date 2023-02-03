({
    doInit: function(component, event, helper) { 
        //component.set("v.loadFollowing1",true);
        /*var loadFollowAction = component.get("c.isLoadFollowing");
        loadFollowAction.setParams({"recordId":component.get("v.recordId")});
        loadFollowAction.setCallback(this,function(resp){
            consol.log("resp.getReturnValue-->> "+resp.getReturnValue);
            
            //var respState = resp.getState();
            //if(respState == 'SUCCESS')
           //component.set("v.loadFollowing1",resp.getReturnValue); 
        });
        $A.enqueueAction(loadFollowAction); */
        //component.set("v.createBusinessAcc",false);
        //alert(component.find('selectBillType').get("v.value"));
        console.log('get value -->> '+component.get("v.loadFollowing1"));
        if(component.get("v.loadFollowing1") == true){
            
            var act1 = component.get('c.getToggleButtonValue');
                $A.enqueueAction(act1);
        }
        if(typeof component.get("v.productId") == 'undefined'){
            console.log('If'+ component.get("v.productId"));
            helper.getExistingPR(component, event);
            helper.addChangeRequestRecord(component, event);
            component.set("v.spinner", true);
            //helper.fetchPickListValueBT(component, event);
            helper.fetchPickListValueIBT(component, event);
            var actionOne = component.get("c.GetUAOsandState");
            console.log("reccId"+component.get("v.recordId"));
            actionOne.setParams({  
                'recordId' :component.get("v.recordId")
                
            }); 
            actionOne.setCallback(this, function(a) {
                var result = a.getReturnValue();
              //  alert('OppOwnerId-->> '+result.isOppOwnandUserSame);
                //set max number return from apex
                component.set("v.maxHUDaysRequired",result.maxOfHUDaysRequired);
                component.set("v.isOppOwnandUserSame",result.isOppOwnandUserSame);
                var disableAction = component.get('c.disableElements');
                $A.enqueueAction(disableAction);
                if(result.UAO[0].Opportunity__r.Type == 'Load Following'){
                component.set("v.saleTypLoadFollow",true);
                component.set("v.selectedLoadFollowing","this");
                }
                helper.getProductFamily(component, event, helper,result.State);
                component.set("v.selectedContacts",result.UAO);
                console.log('result.UAO-->> '+result.UAO[0].Opportunity__r.Type);
                
                component.set("v.accIdToPass",result.AccId);
                component.set("v.binId",result.BinId);
                if(component.get("v.selectedSaleType") == null){
                    component.set("v.selectedSaleType",result.SaleType);
                }
                
                //alert(component.get("v.selectedContacts"));
                
                //Get Bill type
                var action3 = component.get("c.getBillType");
                action3.setParams({  
                    'UAList' :component.get("v.selectedContacts"),
                });
                action3.setCallback(this, function(a) {
                    console.log('FinalBillType'+JSON.stringify(a.getReturnValue()));
                    component.set("v.BillType",a.getReturnValue());
                    var BillTypeVal = a.getReturnValue();
                    component.set("v.BillTypeVal",BillTypeVal[0])
                    console.log('FinalBillType'+JSON.stringify(BillTypeVal[0]));
                    component.set("v.availabeleBillType",a.getReturnValue());
                    window.setTimeout(
                        $A.getCallback( function() {
                            component.find("selectBillType").set("v.value", BillTypeVal[0]);
                        }),0);
                    if(BillTypeVal == null || BillTypeVal == ''){
                        component.set("v.NoBillTypeAvailable",true);
                    }
                    
                    if((BillTypeVal[0] == 'Dual' || BillTypeVal[0] == 'UCB with Credit') && result.BinId == null){
                        component.set("v.showBinWarning",true);
                        component.set("v.creditRequired",true);
                    }
                });
                $A.enqueueAction(action3);
                //component.set("v.Treatment",result.Treatment);
                // component.set("v.VoluntaryRECs",result.RECS);
                component.set("v.State",result.State);
            });
            $A.enqueueAction(actionOne); 
            //Get SaleTypePicklist
            
            var action = component.get("c.SaleType");
            
            var opts=[];
            action.setCallback(this, function(a) {
                
                component.set("v.SaleType", a.getReturnValue());
                
            });
            $A.enqueueAction(action); 
            
            //Get ProductFamily Picklist
            var action2 = component.get("c.ProductFamily");

            var opts=[];
            action2.setCallback(this, function(a) {
                
                component.set("v.ProductFamily", a.getReturnValue());
                var ProductFamily = a.getReturnValue();
                console.log('ProductFamily[0] '+ProductFamily[0]);
                window.setTimeout(
                    $A.getCallback( function() {
                        // Now set our preferred value
                        //component.find("ProductFamily").set("v.value", ProductFamily[0]);
                        if(component.get("v.saleTypLoadFollow")){
                            component.find("ProductFamily").set("v.value",'Non-Energy Pass-Through');    
                        }else{
                            component.find("ProductFamily").set("v.value", ProductFamily[0]);
                        }
                        
                    }),0);
            });
            $A.enqueueAction(action2); 
            
            helper.getDefaultProducts(component, event);
            var selectedProducta = '';
            //console.log('productId-->'+component.get("v.productId"));
            if(component.get("v.productId") != null){
                selectedProducta = component.get("v.productId");
                console.log('productId-->'+component.get("v.productId"));
                
            }
            else{
                selectedProducta = $A.get("$Label.c.Default_Product");
                console.log("selectedProducta-->> "+selectedProducta);
                 
            }
            component.set("v.productId",selectedProducta);
            //component.set("v.productId",'01t1700000A4q3XAAR');
            var indexa = 0;    
            helper.setVoluntaryPicklists(component, event, helper,selectedProducta,indexa);
            //component.find("selectProduct").set("v.value",'Fixed Energy with Capacity, Transmission, Ancillary Services and Mandatory RECs Pass Through') 
            //component.find("selectProduct").set("v.value", 'Fixed Energy with Capacity, Transmission, Ancillary Services and Mandatory RECs Pass Through');
        }
        else{
            console.log('Else');
            component.set("v.spinner", true);
            var actionOne1 = component.get("c.GetUAOsandState");
            actionOne1.setParams({  
                'recordId' :component.get("v.recordId")
                
            });
            actionOne1.setCallback(this, function(a) {
                var result = a.getReturnValue();
                component.set("v.selectedContacts",result.UAO);
                component.set("v.binId",result.BinId);
                if(component.get("v.salesRenew") == true){
                    var BillTypeVal = component.get("v.BillTypeSalesRenew");
                    component.set("v.BillTypeVal",BillTypeVal[0]);
                    component.set("v.BillType",BillTypeVal[0]);
                    component.set("v.spinner", false);
                }
                else{
                     var action3 = component.get("c.getBillType");
                action3.setParams({  
                    'UAList' :component.get("v.selectedContacts"),
                });
                action3.setCallback(this, function(a) {
                    console.log('FinalBillType'+JSON.stringify(a.getReturnValue()));
                    component.set("v.BillType",a.getReturnValue());
                    var BillTypeVal = a.getReturnValue();
                    component.set("v.BillTypeVal",BillTypeVal[0])
                    console.log('FinalBillType'+JSON.stringify(BillTypeVal[0]));
                    window.setTimeout(
                        $A.getCallback( function() {
                            component.find("selectBillType").set("v.value", BillTypeVal[0]);
                            component.set("v.spinner", false);
                        }),0);
                    if(BillTypeVal == null || BillTypeVal == ''){
                        component.set("v.NoBillTypeAvailable",true);
                    }
                    if((BillTypeVal[0] == 'Dual' || BillTypeVal[0] == 'UCB with Credit') && component.set("v.binId") == null){
                        component.set("v.showBinWarning",true);
                        
                        component.set("v.creditRequired",true);
                    }
                });
                $A.enqueueAction(action3);
                }
               
            });
            $A.enqueueAction(actionOne1);    
            
            var StorePRList = component.get("v.StorePRList");
            console.log('--Here-- 170--'+JSON.stringify(component.get("v.PricingListToPass").DefaultProduct));
            console.log('--Here-- 171--'+component.get("v.PricingListToPass").DefaultProductLookup);
            StorePRList.push({
                'sobjectType': 'Pricing_Request__c',
                'Product_Lookup__c': component.get("v.PricingListToPass").DefaultProductLookup, //'01t1700000A4q3XAAR', 
                'Bill_Type__c': component.get("v.PricingListToPass").BillTypeVal,
                'Invoice_Billing_Type__c':'Summary Billing',
                'picklistValues': component.get("v.PricingListToPass").DefaultProduct,
                'RECSpicklist' : component.get("v.PricingListToPass").VoluntaryRECs,
                'Treatmentpicklst' : component.get("v.PricingListToPass").Treatment,
                'Voluntary_RECs_percent__c' :component.get("v.PricingListToPass").voluntaryPercent ,
                'duplicate':'no'
            });
            component.set("v.ProductFamily",component.get("v.PricingListToPass").prodFamily);
            component.set("v.DefaultProductLookup",component.get("v.PricingListToPass").DefaultProductLookup);
            component.set("v.BillTypeVal",component.get("v.PricingListToPass").BillTypeVal);
            component.set("v.DefaultProduct",component.get("v.PricingListToPass").DefaultProduct);
            component.set("v.VoluntaryRECs",component.get("v.PricingListToPass").VoluntaryRECs);
            component.set("v.InitRECs",component.get("v.PricingListToPass").VoluntaryRECs);
            component.set("v.Treatment",component.get("v.PricingListToPass").Treatment);
            component.set("v.InitTreatment",component.get("v.PricingListToPass").Treatment);
            console.log('--Here-- 182');
            component.set("v.StorePRList", StorePRList);
            
        }
        
    },
    
    /*  showInvoiceBillingType: function(component, event, helper){
     //alert('1 '+component.find('selectBillType').get("v.value"));
     //alert('2 '+component.find("selectBillType").get("v.value"));
     component.set("v.bilTypValueaftChange",component.find('selectBillType').get("v.value"));
     var selectedProducta = event.getSource().get("v.value");
        var indexa = event.getSource().get("v.name");
        if(selectedProducta.startsWith("01t")){
            helper.setVoluntaryPicklists(component, event, helper,selectedProducta,indexa);
        }else{
            var a = component.get('c.showInvoiceBillingTypeB');
                $A.enqueueAction(a);
         }
}, */
    showInvoiceBillingType: function(component, event, helper) {
        
       // var billtype = component.find("selectBillType").get("v.value");
      //  alert('billtype==>> '+billtype);
        component.set("v.isInvBillTypChanged",true);
        var DuplicateIndexes = [];
        var StorePRList = component.get("v.StorePRList");
        for(var i=0;i<StorePRList.length;i++){
            if(StorePRList[i].Voluntary_RECs_percent__c == null){
                StorePRList[i].Voluntary_RECs_percent__c = 100;
            }
            for(var j=0;j<StorePRList.length;j++){
                if(StorePRList[j].Voluntary_RECs_percent__c == null){
                StorePRList[j].Voluntary_RECs_percent__c = 100;
            }
                if(j!=i){
                    console.log('90-->'+JSON.stringify(StorePRList[j]));
                    console.log('91-->'+JSON.stringify(StorePRList[i]));            
                    if(JSON.stringify(StorePRList[j],["sobjectType","Product_Lookup__c","Bill_Type__c","Invoice_Billing_Type__c","picklistValues","Voluntary_RECs__c","Treatment__c","Voluntary_RECs_percent__c"]) == JSON.stringify(StorePRList[i],["sobjectType","Product_Lookup__c","Bill_Type__c","Invoice_Billing_Type__c","picklistValues","Voluntary_RECs__c","Treatment__c","Voluntary_RECs_percent__c"])){
                        component.set("v.indexVal",j);
                        DuplicateIndexes.push(j);
                    }
                }
                else{
                    component.set("v.duplicateAvailable",false);
                    StorePRList[j].duplicate = 'no';
                }
            }
        }
        for(var k=0;k<DuplicateIndexes.length;k++){
            StorePRList[DuplicateIndexes[k]].duplicate = 'yes';
            component.set("v.duplicateAvailable",true);
        }
        component.set("v.StorePRList",StorePRList);
        component.set("v.indexVal",StorePRList.length);
        var disableAction = component.get('c.disableElements');
        $A.enqueueAction(disableAction);
        var selectedProducta = event.getSource().get("v.value");
        var indexa = event.getSource().get("v.name");
        if(selectedProducta.startsWith("01t")){
            helper.setVoluntaryPicklists(component, event, helper,selectedProducta,indexa);
        }
    }, 
    showInvoiceBillingTypeB: function(component, event, helper) {
        
        component.set("v.isChanged",true);
        var DuplicateIndexes = [];
        var StorePRList = component.get("v.StorePRList");
        for(var i=0;i<StorePRList.length;i++){
            //Dev
            console.log("250-->> "+StorePRList[i].Voluntary_RECs_percent__c);
            if(StorePRList[i].Voluntary_RECs__c != 'NA' && (StorePRList[i].Voluntary_RECs_percent__c =='' || StorePRList[i].Voluntary_RECs_percent__c == null 
                                                            || StorePRList[i].Voluntary_RECs_percent__c >100 || StorePRList[i].Voluntary_RECs_percent__c ==0 || StorePRList[i].Voluntary_RECs_percent__c < 0)){
                component.set("v.disableNext",true);
                console.log('in-->> '+StorePRList[i].Voluntary_RECs__c);
            }else{
                component.set("v.disableNext",false);
            }
            //Dev
            for(var j=0;j<StorePRList.length;j++){
                console.log("258-->> "+StorePRList[j].Voluntary_RECs_percent__c);
                if(StorePRList[j].Voluntary_RECs__c != 'NA' && (StorePRList[i].Voluntary_RECs_percent__c =='' || StorePRList[j].Voluntary_RECs_percent__c == null 
                                                                || StorePRList[j].Voluntary_RECs_percent__c >100 || StorePRList[j].Voluntary_RECs_percent__c ==0 || StorePRList[j].Voluntary_RECs_percent__c < 0)){
                    component.set("v.disableNext",true);
                }else{
                    component.set("v.disableNext",false);
                } 
                if(j!=i){
                    
                    console.log('90-->'+JSON.stringify(StorePRList[j]));
                    console.log('91-->'+JSON.stringify(StorePRList[i]));
                    console.log('Treatment__c'+JSON.stringify(StorePRList[i].Treatment__c));
                    console.log('Voluntary_RECs__c'+StorePRList[i].Voluntary_RECs__c)
                     
                    
                    if(StorePRList[j].Voluntary_RECs__c == 'NA'){
                        StorePRList[j].Voluntary_RECs_percent__c = 100;
                        StorePRList[j].Treatment__c ="undefined";
                        
                    }else{
                        component.set("v.disableNext",true);
                    }
                    if(StorePRList[i].Voluntary_RECs__c == 'NA'){
                        StorePRList[i].Voluntary_RECs_percent__c = 100;
                        StorePRList[i].Treatment__c ="undefined";
                        
                    }else{
                        component.set("v.disableNext",true);
                    }
                    if(JSON.stringify(StorePRList[j],["sobjectType","Product_Lookup__c","Bill_Type__c","Invoice_Billing_Type__c","picklistValues","Voluntary_RECs__c","Treatment__c","Voluntary_RECs_percent__c"]) == JSON.stringify(StorePRList[i],["sobjectType","Product_Lookup__c","Bill_Type__c","Invoice_Billing_Type__c","picklistValues","Voluntary_RECs__c","Treatment__c","Voluntary_RECs_percent__c"])){
                        
                        component.set("v.indexVal",j);
                        DuplicateIndexes.push(j);
                        
                        
                    }
                }
                else{
                    component.set("v.duplicateAvailable",false);
                    StorePRList[j].duplicate = 'no';
                }
                
            }
        }
        for(var k=0;k<DuplicateIndexes.length;k++){
            
            StorePRList[DuplicateIndexes[k]].duplicate = 'yes';
            component.set("v.duplicateAvailable",true);
        }
        component.set("v.StorePRList",StorePRList);
        component.set("v.indexVal",StorePRList.length);
        var disableAction = component.get('c.disableElements');
        $A.enqueueAction(disableAction);
        
        
        var billtype = component.find("selectBillType");
        var billtypeVal = 'UCB';
        
        if(Array.isArray(billtype)){
            //alert('Bind if ==>> '+component.get("v.binId"));
            for (var i = 0; i < billtype.length; i++) {
                
                if ((billtype[i].get("v.value") == 'Dual' || billtype[i].get("v.value") == 'UCB with Credit') && component.get("v.binId") == null ) {
                    billtypeVal = 'Dual';
                    component.set("v.showBinWarning",true);
                    component.set("v.creditRequired",true);
                    break;
                }
                else{
                    if(billtype[i].get("v.value") == 'Dual' || billtype[i].get("v.value") == 'UCB with Credit'){
                        component.set("v.creditRequired",true);
                        break;
                    }
                    component.set("v.showBinWarning",false);
                }
            }
        }
        else{
            //alert('Bind else ==>> '+component.get("v.binId"));
            var billtypeVal = component.find("selectBillType").get("v.value");
            if((billtypeVal == 'Dual' || billtypeVal == 'UCB with Credit') && component.get("v.binId") == null){
                component.set("v.showBinWarning", true);
                
            }
            else{
                if(billtypeVal == 'Dual' || billtypeVal == 'UCB with Credit'){
                    component.set("v.creditRequired",true);
                }
                component.set("v.showBinWarning", false);
            }
        }
        console.log('--180--'+billtypeVal);
    },
    showInvoiceBillingTypeA: function(component, event, helper) {
        var DuplicateIndexes = [];
        var StorePRList = component.get("v.StorePRList");
        console.log('Bii__ >>'+StorePRList[0].Bill_Type__c);
        console.log("StorePRList.length-->> "+StorePRList.length);
        for(var i=0;i<StorePRList.length;i++){
            for(var j=0;j<StorePRList.length;j++){
                if(j!=i){
                    console.log('11'+component.get("v.availabeleBillType").includes("UCB"));
                    console.log('22'+component.get("v.isChanged"));
                    console.log("StorePRList++> "+StorePRList[i].Treatment__c);
                    if(StorePRList[0].Bill_Type__c =="UCB" /*&& (component.get("v.isChanged") == false)*/ && component.get("v.availabeleBillType").includes("UCB") == false ){
                        console.log("INNNNNNN");
                        StorePRList[0].Bill_Type__c = StorePRList[1].Bill_Type__c;
                    }else if ((StorePRList[1].Bill_Type__c =="UCB" /*&& (component.get("v.isChanged") == false)*/ && component.get("v.availabeleBillType").includes("UCB") == false )){
                        StorePRList[1].Bill_Type__c = StorePRList[0].Bill_Type__c;
                    }
                    
                   /* console.log("is--MM "+component.get("v.isInvBillTypChanged"));
                    if(StorePRList[0].Invoice_Billing_Type__c != StorePRList[1].Invoice_Billing_Type__c  && component.get("v.isInvBillTypChanged") ==false){
                        console.log("MMMM");
                       StorePRList[0].Invoice_Billing_Type__c ="Summary Billing"; 
                       StorePRList[1].Invoice_Billing_Type__c ="Summary Billing"; 
                    }else if(StorePRList[1].Invoice_Billing_Type__c = "None" && StorePRList[0].Invoice_Billing_Type__c != "None" && component.get("v.isInvBillTypChanged") ==false){
                       StorePRList[1].Invoice_Billing_Type__c ="Summary Billing"; 
                    } */
                    
                    if(component.get("v.isInvBillTypChanged") ==false){
                        console.log("check");
                    StorePRList[i].Invoice_Billing_Type__c = "Summary Billing";
                    StorePRList[j].Invoice_Billing_Type__c = "Summary Billing";
                    }
                    console.log('90-->'+JSON.stringify(StorePRList[j]));
                    console.log('91-->'+JSON.stringify(StorePRList[i]));
                    if(StorePRList[j].Voluntary_RECs__c == 'NA' && StorePRList[j].Voluntary_RECs_percent__c != null){
                        StorePRList[j].Voluntary_RECs_percent__c = 100;
                    }
                    if(StorePRList[i].Voluntary_RECs__c == 'NA' && StorePRList[i].Voluntary_RECs_percent__c != null){
                        StorePRList[i].Voluntary_RECs_percent__c = 100;
                    }
                    // alert('j '+ JSON.stringify(StorePRList[j]));
                    // alert('i '+ JSON.stringify(StorePRList[i]));
                    if(JSON.stringify(StorePRList[j],["sobjectType","Product_Lookup__c","Bill_Type__c","Invoice_Billing_Type__c","picklistValues","Voluntary_RECs__c","Treatment__c","Voluntary_RECs_percent__c"]) == JSON.stringify(StorePRList[i],["sobjectType","Product_Lookup__c","Bill_Type__c","Invoice_Billing_Type__c","picklistValues","Voluntary_RECs__c","Treatment__c","Voluntary_RECs_percent__c"])){
                        component.set("v.indexVal",j);
                        DuplicateIndexes.push(j);
                    }
                }
                else{
                    console.log("else 366");
                    component.set("v.duplicateAvailable",false);
                    StorePRList[j].duplicate = 'no';
                }
            }
        }
        for(var k=0;k<DuplicateIndexes.length;k++){
            console.log("for 373");
            StorePRList[DuplicateIndexes[k]].duplicate = 'yes';
            component.set("v.duplicateAvailable",true);
        }
        component.set("v.StorePRList",StorePRList);
        component.set("v.indexVal",StorePRList.length);
        var disableAction = component.get('c.disableElements');
        $A.enqueueAction(disableAction);
        var selectedProducta = event.getSource().get("v.value");
        var indexa = event.getSource().get("v.name");
        if(selectedProducta.startsWith("01t")){
            helper.setVoluntaryPicklists(component, event, helper,selectedProducta,indexa);
        }
        var billtype = component.find("selectBillType");
        var billtypeVal = 'UCB';
        if(Array.isArray(billtype)){
            for (var i = 0; i < billtype.length; i++) {
                
                if ((billtype[i].get("v.value") == 'Dual' || billtype[i].get("v.value") == 'UCB with Credit') && component.get("v.binId") == null ) {
                    billtypeVal = 'Dual';
                    component.set("v.showBinWarning",true);
                    component.set("v.creditRequired",true);
                    break;
                }
                else{
                    if(billtype[i].get("v.value") == 'Dual' || billtype[i].get("v.value") == 'UCB with Credit'){
                        component.set("v.creditRequired",true);
                        break;
                    }
                    component.set("v.showBinWarning",false);
                }
            }
        }
        else{
            var billtypeVal = component.find("selectBillType").get("v.value");
            if((billtypeVal == 'Dual' || billtypeVal == 'UCB with Credit') && component.get("v.binId") == null){
                component.set("v.showBinWarning", true);
                
            }
            else{
                if(billtypeVal == 'Dual' || billtypeVal == 'UCB with Credit'){
                    component.set("v.creditRequired",true);
                }
                component.set("v.showBinWarning", false);
            }
        }
        console.log('--180--'+billtypeVal);
    },
    CPRcheck: function(component, event, helper) {
        var CPR = component.find("CPR").get("v.value");
        if(CPR==true){
            component.set("v.CreatePricingRequest",false);    
        }
    },
    
    /*  getStorePRList: function(component, event, helper) {
        var StorePRList11 = [];
        StorePRList11.push(component.get("v.StorePRList"));
        alert('StorePRList11 '+StorePRList11.length);
        component.set("v.StorePRList1", StorePRList11);
        alert('366 '+((component.get("v.StorePRList1")).length));
        //alert('StorePRList : '+StorePRList.length);
    }, */
    
     CreatePricingRequest : function(component, event, helper) {
         
         console.log('CreatePricingRequest--');
         // alert('CreatePricingRequest');
         //component.set("v.createBusinessAcc",false);
         var billtypeVal = 'UCB';
         var RequestType = component.get("v.RequestTypevalue");
         if(RequestType == false){
             var billtype = component.find("selectBillType");
             if(Array.isArray(billtype) && component.get("v.binId") == null){
                 console.log('--Here--210');
                 for (var i = 0; i < billtype.length; i++) {
                     if (billtype[i].get("v.value") == 'Dual' || billtype[i].get("v.value") == 'UCB with Credit' ) {
                         billtypeVal = 'Dual';
                         break;
                     }
                 }
             }
             else{
                 if(component.get("v.binId") == null){
                     var billtypeVal = component.find("selectBillType").get("v.value");
                 }
             }
         }
         else{
             var getExistingPR = component.get("v.existingPRList");
             for(var i=0;i<getExistingPR.length;i++){
                 if( getExistingPR[i].isChecked == true && (getExistingPR[i].Bill_Type__c == 'Dual' || getExistingPR[i].Bill_Type__c == 'UCB with Credit')){
                     billtypeVal = 'Dual';
                     break;
                 }                                
             }
         }
         if((billtypeVal == 'Dual' || billtypeVal == 'UCB with Credit') && component.get("v.binId") == null){
             component.set("v.createBusinessAcc", true);
             component.set("v.creditRequired",true);
         }else{
             
             
             //alert('selectBillType-->> '+component.find("selectBillType").get("v.value"));
             var CPR = component.get("v.CreatePricingRequest");
             var selectedFamily = '';
             var selectedProduct = '';
             var selectedBillType = '';
             var UrgentRequest = false;
             var selectedInvoiceBillingType = "Summary Billing";
             var Notes = '';
             var DueDate =  new Date(2011,10,30);
             var DueDatecheck = component.find("dueDate").get("v.value");
             if(typeof DueDatecheck == 'undefined' || DueDatecheck == null || DueDatecheck == ''){
                 component.set("v.Errmsg",'Required field missing.')
             }
             if(CPR==true){
                 var UrgentRequest =  component.find("UrgentRequest").get("v.checked");
                 var Notes = component.find("Notes").get("v.value");
                 var DueDate = component.find("dueDate").get("v.value");
             }
             var PricingRequestList = [];
             var RequestType = component.get("v.RequestTypevalue");
             console.log('431------------');
             if(component.get("v.selectedOption") == 'option2'){
                 console.log('433------------');
                 RequestType = true;
                 if(RequestType == true){
                     var getExistingPR = component.get("v.existingPRList");
                     var newPRs = [];
                     for (var i = 0; i < getExistingPR.length; i++) {
                         if( getExistingPR[i].isChecked == true){
                             newPRs.push(getExistingPR[i]);
                         }
                     }
                     PricingRequestList = newPRs;
                     console.log('444------------');
                     //12-12
                     component.set("v.PricingRequestId",newPRs[0].Id);
                 }else{
                     PricingRequestList = component.get("v.StorePRList");   
                 }
                 console.log('450------------');
                 var PricingRequest = {
                     PricingRequestList:PricingRequestList,
                     BrokerMargin : 0,
                     UrgentRequest : UrgentRequest,
                     Notes : Notes,
                     DueDate : DueDate
                 };
                 component.set("v.PRequest",PricingRequest);
                 component.set("v.RequestTypevalue",false);
                 //ert('11-->> '+JSON.stringify(PricingRequest));
                 helper.CreateOpportunityAndPR(component, event, helper,PricingRequest);
                 
             }    
             // alert('component.get("v.selectedOption")'+component.get("v.selectedOption"));
             if(component.get("v.selectedOption") != 'option2'){    
                 if(component.get("v.selectedOption") == 'option3'){
                     /*var billTypList = component.get("v.BillTypeValList");
                if(billTypList.includes('Dual')==true){
                    component.set("v.showInvType",true);
                }*/
                 //alert('yy '+ billTypList.includes('Dual'));
                 RequestType = true;
             }else if(component.get("v.selectedOption") == 'option1'){
                 PricingRequestList = component.get("v.StorePRList");   
             }
             if(RequestType == true){
                 var getExistingPR = component.get("v.existingPRList");
                 // alert('getExistingPR'+JSON.stringify(getExistingPR));
                 var newPRs = [];
                 for (var i = 0; i < getExistingPR.length; i++) {
                     if( getExistingPR[i].isChecked == true){
                         // alert('in ');
                         //component.set("v.selectedDefProduct",getExistingPR[i].Product_Lookup__r.Name);
                         newPRs.push(getExistingPR[i]);  
                     }
                 }
                 //As part of SU - 828 - Below change
                 //PricingRequestList = newPRs; 
                 PricingRequestList = component.get("v.StorePRList");
             }else{
                 PricingRequestList = component.get("v.StorePRList"); 
             }
             //alert('THIS -->> '+JSON.stringify(PricingRequestList));
             var PricingRequest = {
                 PricingRequestList:PricingRequestList,
                 BrokerMargin : 0,
                 UrgentRequest : UrgentRequest,
                 Notes : Notes,
                 DueDate : DueDate
             };
             component.set("v.PRequest",PricingRequest);
             if(component.get("v.RequestTypevalue") && component.get("v.selectedOption") == 'option3'){
                 component.set("v.PricingRequestId",newPRs[0].Id);
                 var action = component.get("c.getProd");
                 action.setParams({  
                     'productName' :newPRs[0].Product_Lookup__r.Name,
                 });
                 action.setCallback(this, function(response){
                     var state = response.getState();
                     if(state == 'SUCCESS') {
                         component.set('v.ProdLst', response.getReturnValue());
                         component.set("v.RequestTypevalue",false);
                         var StorePRList = component.get("v.StorePRList");
                         StorePRList.push({
                             'sobjectType': 'Pricing_Request__c',
                             'Product_Lookup__c': newPRs[0].Product_Lookup__c,
                             'Bill_Type__c': newPRs[0].Bill_Type__c,
                             'Invoice_Billing_Type__c':newPRs[0].Invoice_Billing_Type__c,
                             'picklistValues': response.getReturnValue().ProductLst,
                             'RECSpicklist' : component.get("v.InitRECs"),
                             'Treatmentpicklst' : component.get("v.InitTreatment"),
                             'Family' : response.getReturnValue().ProductLst[0].Family,
                             'Voluntary_RECs_percent__c' : newPRs[0].Voluntary_RECs_percent__c,
                             'Voluntary_RECs__c' : newPRs[0].Voluntary_RECs__c,
                             'Treatment__c' : newPRs[0].Treatment__c,
                             'duplicate':'no'
                         });
                         if(component.get("v.isChanged") == false && StorePRList.length > 1){
                             StorePRList.shift();
                         }
                         component.set("v.StorePRList", StorePRList[1]);
                         //component.set("v.StorePRList", StorePRList);
                         //as part of SU - 793 commented below line
                         //component.find("tglbtn").set("v.checked",true);
                         // var a = component.get('c.getToggleButtonValue');
                         //$A.enqueueAction(a);
                     }
                 });
                 $A.enqueueAction(action);
             }else{    
                 //ert(JSON.stringify(PricingRequest));
                 helper.CreateOpportunityAndPR(component, event, helper,PricingRequest);
             }
         }
        }
         
    },
    
    onProductFamilyChange : function(component, event, helper) {
        // var DueDatecheck = component.find("ProductFamily").get("v.value");
        var selectedFamily = event.getSource().get("v.value");
        // alert(selectedFamily);
        //alert('Bill Type '+ component.get(selectBillType));
        component.set("v.spinner", true);
        var action = component.get("c.GetProducts");
        var products = [];
        action.setParams({  
            'ProductFamily' : selectedFamily,
            'State' : component.get("v.State"),
            'recordId' :  null //component.get("v.recordId")
            //'saleTypLoadFollow': false
        });
        action.setCallback(this, function(a) {
            var DuplicateIndexes = [];
            products = a.getReturnValue();
            var listOfProd = [];
            for ( var key in products ) {
                listOfProd.push(products[key]);
            }
            var listofPR = component.get("v.StorePRList");
            var index = event.getSource().get("v.name");
            if(!$A.util.isEmpty(products)){
                listofPR[index].Product_Lookup__c = listOfProd[0].Id;
            }
            listofPR[index].picklistValues = listOfProd;
            component.set("v.StorePRList", listofPR);
            var a = component.get('c.showInvoiceBillingTypeB');
            $A.enqueueAction(a);
            component.set("v.isChanged",false);
            var indexa = event.getSource().get("v.name");
            var selectedProducta = listofPR[indexa].Product_Lookup__c;
            helper.setVoluntaryPicklists(component, event, helper,selectedProducta,indexa);
        });
        $A.enqueueAction(action); 
    },
    handlePrevious:function(component,event,helper){
        var event = component.getEvent("cmpEvent"); 
        event.setParams({
            "eventResponse" : true
        }); 
        //fire the event    
        event.fire();
    },
    handleComponentEvent:function(component,event,helper){
       // alert('in');
        var response = event.getParam("recordByEvent");
        component.set("v.selectedUserId",response);
        var a = component.get('c.panelOne');
        $A.enqueueAction(a);
    },
    getToggleButtonValue:function(component,event,helper){
        //alert('In getToggleButtonValue');
        var checkCmp = component.find("tglbtn").get("v.checked");
        component.set("v.chkboxvalue",checkCmp);
        var CPR = component.get("v.CreatePricingRequest");
        var selectedFamily = '';
        var selectedProduct = '';
        var selectedBillType = '';
        var UrgentRequest = false;
        var Notes = '';
        
        var DueDate =  new Date(2011,10,30);
        var selectedInvoiceBillingType = "Summary Billing";
        
        if(CPR==true){
            var UrgentRequest =  component.find("UrgentRequest").get("v.checked");
            var Notes = component.find("Notes").get("v.value");
            
            var DueDate = component.find("dueDate").get("v.value");
            
        }
        
        
        
        var PricingRequestList = [];
        var RequestType = component.get("v.RequestTypevalue");
        if(RequestType == true){
            var getExistingPR = component.get("v.existingPRList");
            var newPRs = [];
            for (var i = 0; i < getExistingPR.length; i++) {
                if( getExistingPR[i].isChecked == true)
                    newPRs.push(getExistingPR[i]);
            }
            PricingRequestList = newPRs;
        }else{
            PricingRequestList = component.get("v.StorePRList");   
        }   
        
        var PricingRequest = {
            PricingRequestList :PricingRequestList,
            BrokerMargin : 0,
            UrgentRequest : UrgentRequest,
            Notes : Notes,
            DueDate : DueDate
        };
        component.set("v.PRequest",PricingRequest);
        component.set("v.chkboxvalue",checkCmp);
        //helper.toggleAction(component, event, 'panelOne');
        
        
    },
    onCheck : function(component,event,helper){
        //alert('oncheck --> '+ component.find("notifyMe").get("v.checked"));
        var checkValue = component.find("notifyMe").get("v.checked");
        //alert('checkValue-> '+checkValue);
        component.set("v.NotifyMeBoolean",checkValue);
    },
    
    callOnchange : function(component,event,helper){
       // alert('callOnchange');
        component.set("v.dontcollapse",false);
        var CPR = component.get("v.CreatePricingRequest");
        var selectedFamily = '';
        var selectedProduct = '';
        var selectedBillType = '';
        var UrgentRequest = false; 
        var Notes = '';
        
        var DueDate =  new Date(2011,10,30);
        var selectedInvoiceBillingType = "Summary Billing";
        
        if(CPR==true){
            var UrgentRequest =  component.find("UrgentRequest").get("v.checked");
            var Notes = component.find("Notes").get("v.value");
            
            var DueDate = component.find("dueDate").get("v.value");
            
        }
        
        
        
        var PricingRequestList = [];
        var RequestType = component.get("v.RequestTypevalue");
        if(RequestType == true){
            var getExistingPR = component.get("v.existingPRList");
            var newPRs = [];
            for (var i = 0; i < getExistingPR.length; i++) {
                if( getExistingPR[i].isChecked == true){
                    //alert('in loop');
                    //component.set("v.createBusinessAcc",false);
                    newPRs.push(getExistingPR[i]);
                    
                }
                    
            }
            PricingRequestList = newPRs;
        }else{
            PricingRequestList = component.get("v.StorePRList");   
        }   
        
        var PricingRequest = {
            PricingRequestList :PricingRequestList,
            BrokerMargin : 0,
            UrgentRequest : UrgentRequest,
            Notes : Notes,
            DueDate : DueDate
        };
        component.set("v.PRequest",PricingRequest);
        
    },
    
    changeDueDate:function(component,event,helper){
        var DueDatecheck = component.find("dueDate").get("v.value");
        let dateObj = new Date();
        
        var dueDateValid = false;
        
        var dtt = $A.localizationService.formatDate(dateObj, "yyyy-MM-dd");
        
        
        
        //Commented below as part of SU - 932
        /*if(typeof DueDatecheck == 'undefined' || DueDatecheck == null || DueDatecheck == '' || DueDatecheck < dtt){
           // alert('DueDatecheck');
            component.set("v.disabletoggle",true);
        }
        else{
            component.set("v.disabletoggle",false);
        }*/
        //SU - 932
        
        if(DueDatecheck < component.get("v.maxHUDaysRequired") && DueDatecheck >= dtt && component.get("v.selectedOption") =='option1'){
            dueDateValid = false;
            component.set("v.setValidationMsg","The selected Due Date does not allow time for HU data to be obtained for pricing");
            
        }else{
            dueDateValid = true;
            component.set("v.setValidationMsg","");
        }
        
        if(typeof DueDatecheck == 'undefined' || DueDatecheck == null || DueDatecheck == '' || DueDatecheck < dtt || ((DueDatecheck < component.get("v.maxHUDaysRequired")) && component.get("v.selectedOption") =='option1') ){
            //alert('DueDatecheck----------');
            component.set("v.disabletoggle",true);
        }
        else{
            component.set("v.disabletoggle",false);
        }
        
        if(DueDatecheck == null ||  DueDatecheck < dtt){
            dueDateValid = false;
        }
        
        component.set("v.passDueDate",dueDateValid);
        
        console.log('In this');
        var cmpEvent = $A.get("e.c:passDateValidOrNot");
        cmpEvent.setParams({"isDueDateValid" : dueDateValid, "dueDateValidB1":dueDateValid });
        cmpEvent.fire();
        
        // SU -932 end
        var a = component.get('c.callOnchange');
        $A.enqueueAction(a);
    },
    
    panelOne : function(component, event, helper) {
        //component.set("v.dontcollapse",false);
       // alert('panelOne');
        //alert('dontcollapse '+component.get("v.dontcollapse"));
        //component.set("v.dontcollapse",true);
        var collapse = component.get("v.collapse");
        //alert(collapse);
        if(collapse == true){
            component.set("v.collapse",false); 
            
        }
        else{
            
            component.set("v.collapse",true);
        }
        //if(collapse == true)
        helper.toggleActionA(component, event, 'panelOne');
    },
    addRow: function(component, event, helper) {
        // alert('add row');
        helper.addChangeRequestRecord(component, event);
    },
    
    removeRow: function(component, event, helper) {
        //alert('removeRow');
        var DuplicateIndexes = [];
        var StorePRList = component.get("v.StorePRList");
        //alert(JSON.stringify(StorePRList));
        var selectedItem = event.currentTarget;
        var index = selectedItem.dataset.record;
        if(StorePRList.length>1){
          StorePRList.splice(index, 1);  
        }
        //alert(JSON.stringify(StorePRList));
        component.set("v.StorePRList", StorePRList);
        
        var a = component.get('c.showInvoiceBillingTypeB');
        $A.enqueueAction(a);
        component.set("v.isChanged",false);
    },
    
    disableElements: function(component, event, helper) {
        var index = component.find("VoluntaryRECs").get("v.name");
        var selectedValue = component.find("VoluntaryRECs").get("v.value");
        var PRlst = component.get("v.StorePRList");
        
        if(selectedValue == 'NA'){
            PRlst[index].Voluntary_RECs_percent__c = null;
            //PRlst[index].Treatment__c = null;
        }
        if(PRlst[0].Voluntary_RECs__c == 'NA'){
            PRlst[index].Voluntary_RECs_percent__c = null;
            //PRlst[index].Voluntary_RECs_percent__c = "100";
            //  PRlst[index].Treatment__c = 'Fixed';
        }
        component.set("v.StorePRList",PRlst);
    },
    disableElementsA: function(component, event, helper) {
        
        var PRlst = component.get("v.StorePRList");
        var index = event.getSource().get("v.name");
        
        if(PRlst[index].Voluntary_RECs__c != 'NA' && PRlst[index].Voluntary_RECs_percent__c == null){
            PRlst[index].Voluntary_RECs_percent__c = "100";
        }
        if(PRlst[index].Voluntary_RECs__c == 'NA'){
            PRlst[index].Voluntary_RECs_percent__c = null;
        }
        
        component.set("v.StorePRList",PRlst);
        var a = component.get('c.showInvoiceBillingType');
        $A.enqueueAction(a);
    },
    selectAllCheckbox: function(component, event, helper) {
        var selectedHeaderCheck = event.getSource().get("v.value");
        console.log('selectedHeaderCheck-->'+selectedHeaderCheck);
        var existingPRList = component.get("v.existingPRList");
        console.log('existingPRList.length-->'+existingPRList.length);
        var counter = 0;
        for (var i = 0; i < existingPRList.length; i++) {
            if (selectedHeaderCheck == true  ) {
                existingPRList[i].isChecked = true;
                counter++;
                component.set("v.indexValExistPR", counter);
            }
            else {
                existingPRList[i].isChecked = false;
                component.set("v.indexValExistPR", 0);
            }
        }
        component.set("v.existingPRList",existingPRList);
        
        
        for(var i=0;i<existingPRList.length;i++){
            if( existingPRList[i].isChecked == true && ((existingPRList[i].Bill_Type__c == 'Dual' || existingPRList[i].Bill_Type__c == 'UCB with Credit') &&  component.get("v.binId") == null)){
               //&& component.get("v.binId") == null
                component.set("v.showBinWarning",true);
                break;
            }
            else{
                component.set("v.showBinWarning",false);
            }
        }
        
        
        if(component.get("v.indexValExistPR") == 0){
            component.set("v.PRvalueLength", true);
        }else{
            component.set("v.PRvalueLength", false);
        }
    },
    checkboxSelect: function(component, event, helper) {
        var selectedRec = event.getSource().get("v.value");
        console.log('860-binId==>> '+component.get("v.binId"));
        //component.get("v.binId") == null
        var selectedArr = event.getSource().get("v.errors");
        var existingPRList = component.get("v.existingPRList");
        if(component.get("v.selectedOption") == 'option3'){
            // alert('In5555');
            component.set("v.opetnSelect",'3rdSelected');
            for(var i=0;i<existingPRList.length;i++){
                if(selectedArr.Id == existingPRList[i].Id){
                    existingPRList[i].isChecked = true;
                    component.set("v.selectPRId",existingPRList[i].Id);
                }else{
                    existingPRList[i].isChecked = false;
                }
            }
            component.set("v.existingPRList",existingPRList);
        }
        
        //alert(JSON.stringify(selectedArr));
        //added on 17/01/2022 ==>>  && component.get("v.binId") == null
        var billType = event.getSource().get("v.name");
        if(selectedRec == true && (billType == 'Dual' || billType == 'UCB with Credit') && component.get("v.binId") == null){
            component.set("v.showBinWarning",true);
            
        }
        else{
            component.set("v.showBinWarning",false);
            //component.set("v.createBusinessAcc",false);
        }
        console.log('selectedRec-->'+JSON.stringify(selectedRec));
        var existingPRList = component.get("v.existingPRList");
        var getSelectedNumber = component.get("v.indexValExistPR");
        if (selectedRec == true) {
            getSelectedNumber++;
        } 
        else{
            getSelectedNumber--;
            component.find("selectAllId").set("v.value", false);
        }
        component.set("v.indexValExistPR", getSelectedNumber);
        
        // if all checkboxes are checked then set header checkbox with true   
        if (existingPRList.length == component.get("v.indexValExistPR")) {
            component.find("selectAllId").set("v.value", true);
        }else{
            component.find("selectAllId").set("v.value", false);
        }
        if(component.get("v.indexValExistPR") == 0){
            component.set("v.PRvalueLength", true);
        }else{
            component.set("v.PRvalueLength", false);
        }
        if(component.get("v.selectedOption") == 'option3'){
            component.set("v.indexValExistPR", 1);
        }
    },
    getToggleRefreshButtonValue : function(component,event,helper){
        var Optionselected = '';
        Optionselected = component.get("v.selectedOption");
        /*var checkCmp = component.find("tglrefresh").get("v.checked");
        component.set("v.RequestTypevalue",checkCmp);*/
        var existingPRList = component.get("v.existingPRList");
        // if all checkboxes are checked then set header checkbox with true   
        /*  if (existingPRList.length == component.get("v.indexValExistPR")) {
            component.find("selectAllId").set("v.value", true);
        }else{
            component.find("selectAllId").set("v.value", false);
        }*/
        if((Optionselected == 'option3' || Optionselected == 'option2' )){
            component.set("v.PRvalueLength", true);
            component.set("v.RequestTypevalue",true);
        }else{
            component.set("v.PRvalueLength", false);
            component.set("v.RequestTypevalue",false);
        }
        
        var existingPRList = component.get("v.existingPRList");
        
        for(var i=0;i<existingPRList.length;i++){
            existingPRList[i].isChecked = false;
        }   
        component.set("v.existingPRList",existingPRList);
        component.set("v.indexValExistPR", 0);
    },  
    
    //Changes 23/06
    showtooltip : function(component, event, helper) {
       // alert('Event'+JSON.stringify(event.getSource()));
        var target = event.getSource(); 
        var txtVal = target.get("v.alternativeText") ;
        component.set("v.hoverRow", txtVal);
        component.set("v.showModal1", true);
    },
    
    hidetooltip : function(component, event, helper) {
        component.set("v.hoverRow", -1);
    },
    hideModel: function(component, event, helper) {
        component.set("v.showModal1", false);
    },
    showModel: function(component, event, helper) {
        component.set("v.showModal1", true);
    },
    
    
})