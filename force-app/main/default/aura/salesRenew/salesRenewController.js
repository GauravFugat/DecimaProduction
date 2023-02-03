({
	doInit : function(component, event, helper) {
        console.log('default broker --'+component.get("v.BillTypeSalesRenew"));
        var action = component.get("c.getUAs");
        action.setParams({  
            'recordId' : component.get("v.recordId"),
            'isLoadFollowing' : false
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS"){
                if(response.getReturnValue().length > 0){
                    console.log('selectedContacts-->'+JSON.stringify(response.getReturnValue()));
                    component.set("v.selectedContacts",response.getReturnValue());
                    component.set("v.brokerId",response.getReturnValue()[0].broker.Id);
                    component.set("v.CustomerId",response.getReturnValue()[0].CustomerId);
                    component.set("v.productId",response.getReturnValue()[0].productId);
                    component.set("v.State",response.getReturnValue()[0].State);
                    component.set("v.selectedBrokerContact",response.getReturnValue()[0].selectedCon);
                    component.set("v.PricingListToPass",response.getReturnValue()[0].prToPass);
                    component.set("v.BrokerMargin",response.getReturnValue()[0].selectedContract.Opportunity__r.Broker_Margin_per_unit__c);
                    component.set("v.existingContract",response.getReturnValue()[0].selectedContract);
                    component.set("v.salesRenew",true);
                    console.log('25--'+typeof response.getReturnValue()[0].selectedContract.Bill_Type__c);
                    if(typeof response.getReturnValue()[0].selectedContract.Bill_Type__c  != 'undefined'){
                         component.set("v.BillTypeSalesRenew",response.getReturnValue()[0].selectedContract.Bill_Type__c);
                    }
                    //this
                    component.set("v.AnnualVolumekWh",response.getReturnValue()[0].AnnualVolumekWh);
                   // component.set("v.BillTypeSalesRenew",response.getReturnValue()[0].selectedContract.Bill_Type__c);
                    if(typeof response.getReturnValue()[0].selectedContract.Renewal_Opportunity__c == 'undefined'){
                        console.log('--here--');
                        component.set("v.showScreen",true);
                    }
                    else{
                        component.set("v.showScreen",false);
                        component.set("v.spinner",false);
                    }
                }
                else{
                    $A.get("e.force:closeQuickAction").fire();
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "We hit a snag!",
                        "type" : "error",
                        "message": "Utility accounts missing"
                    });
                    toastEvent.fire();
                }
            }
        });
        $A.enqueueAction(action); 
		
	},
    
    closeWarningModel: function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },
})