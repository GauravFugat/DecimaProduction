({
    doInit : function(component, event, helper) {
        var action = component.get("c.getDetails");
        action.setParams({ 'oppId' : component.get("v.recordId")}); 
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('7-->'+JSON.stringify(response.getReturnValue()));  
                console.log('8-->'+response.getReturnValue().isLoadFollowing);
                component.set("v.isLoadFollowing",response.getReturnValue().isLoadFollowing);
                component.set("v.isFinalMargin",response.getReturnValue().isFinalMargin);
                component.set("v.recordResponse", response.getReturnValue().contr);
                component.set("v.utilities", response.getReturnValue().utilities);
            }
        });
        $A.enqueueAction(action);
    }
})