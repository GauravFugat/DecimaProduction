({ 
	updateExcludedUAOs : function(component,event,helper, UAOList, incUAOList){
        console.log('Inside the--');
        var action = component.get("c.updateExcludedUAO");
        action.setParams({  
            'UAOList' : UAOList,
            'incUAOList' : incUAOList,
            'oppId' : component.get("v.recordId"),
            'ChangedPriceId' : component.get("v.selectedPriceId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS"){
                component.set("v.isItCreditPR", response.getReturnValue());
            }
        });
        $A.enqueueAction(action);  
    },
})