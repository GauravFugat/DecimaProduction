({
    FetchData : function (component,jsonstr){
        var fname = component.get("v.fileName");
        var action = component.get("c.insertData");
        action.setParams({
            "strfromlex" : jsonstr,
            "FileName"  : fname
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {  
                var rtnValue = response.getReturnValue();
                if(rtnValue.length >0){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Error',
                        message: rtnValue,
                        duration:'5000',
                        key: 'info_alt',
                        type: 'error'
                    });
                    toastEvent.fire();
                    $A.get('e.force:refreshView').fire();
                }//If there is no error in csv file simply show success message
                else{
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Success',
                        message: 'File Uploaded Successfully.',
                        duration:'5000',
                        key: 'info_alt',
                        type: 'success'
                    });
                    toastEvent.fire();
                }
                $A.get('e.force:refreshView').fire();
                
                component.set('v.showSpinner', false);
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Error',
                        message:'There were failures while file upload, please check related records.',
                        duration:' 5000',
                        key: 'info_alt',
                        type: 'error',
                        mode: 'pester'
                    });
                    toastEvent.fire();
                    
                    component.set('v.showSpinner', false);
                    var json = JSON.stringify(errors); 
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                    errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        }); 
        $A.enqueueAction(action);    
    },
    
    buildData : function(component, helper) {
        var data = [];
        var pageNumber = component.get("v.currentPageNumber");
        component.set("v.totalPages", Math.ceil( component.get("v.BatchData").length/component.get("v.pageSize")));
        var pageSize = component.get("v.pageSize");
        var allData = component.get("v.BatchData");
        var x = (pageNumber-1)*pageSize;
        
        //creating data-table data
        for(; x<(pageNumber)*pageSize; x++){
            if(allData[x]){
                data.push(allData[x]);
            }
        }
        component.set("v.PaginationList", data);
        
        helper.generatePageList(component, pageNumber);
    },
    
    /*
     * this function generate page list
     * */
    generatePageList : function(component, pageNumber){
        pageNumber = parseInt(pageNumber);
        var pageList = [];
        var totalPages = component.get("v.totalPages");
        if(totalPages > 1){
            if(totalPages <= 10){
                var counter = 2;
                for(; counter < (totalPages); counter++){
                    pageList.push(counter);
                } 
            } else{
                if(pageNumber < 5){
                    pageList.push(2, 3, 4, 5, 6);
                } else{
                    if(pageNumber>(totalPages-5)){
                        pageList.push(totalPages-5, totalPages-4, totalPages-3, totalPages-2, totalPages-1);
                    } else{
                        pageList.push(pageNumber-2, pageNumber-1, pageNumber, pageNumber+1, pageNumber+2);
                    }
                }
            }
        }
        component.set("v.pageList", pageList);
        component.set('v.showSpinner', false);
    },
    
    ProcessData : function (component, docId){
        console.log(docId);
        //alert("docID : " + docId);
        component.set('v.showSpinner', true);
        var action = component.get("c.createRateData");
        action.setParams({
            "docId" : docId,
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {  
                
                var rtnValue = response.getReturnValue();
                
                if(rtnValue.length !=''){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Error',
                        message: rtnValue,
                        duration:'5000',
                        key: 'info_alt',
                        type: 'error'
                    });
                    toastEvent.fire();
                    $A.get('e.force:refreshView').fire();
                }//If there is no error in csv file simply show success message
                else{
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'File Uploaded Successfully.',
                        message: 'File Uploaded Successfully.',
                        duration:'5000',
                        key: 'info_alt',
                        type: 'success'
                    });
                    toastEvent.fire();
                }
                $A.get('e.force:refreshView').fire();
                component.set('v.showSpinner', false);
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Error',
                        message:'There were failures while file upload, please check related records.',
                        duration:' 5000',
                        key: 'info_alt',
                        type: 'error',
                    });
                    toastEvent.fire();
                    
                    component.set('v.showSpinner', false);
                    $A.get('e.force:refreshView').fire();
                    var json = JSON.stringify(errors); 
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                    errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        }); 
        $A.enqueueAction(action);    
        
    }
})