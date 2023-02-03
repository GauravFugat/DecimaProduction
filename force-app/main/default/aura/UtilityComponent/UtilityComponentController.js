({
    doInit : function(component, event, helper) {
        var action = component.get("c.GetUtilityAccountRecords");
        action.setParams({  
            'priceId' :component.get("v.prisingReqId")
        });
        action.setCallback(this, function(response) {
            var response1 = response.getReturnValue();
          
         component.set("v.columns",response.getReturnValue());
                  component.set("v.spinner",false);
        });
        $A.enqueueAction(action);
        
    }
})