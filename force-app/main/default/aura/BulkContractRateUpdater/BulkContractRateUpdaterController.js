({
    doInit : function(cmp, event, helper) {
        var action2 = cmp.get("c.getData");
        action2.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS"){
                cmp.set('v.BatchData', response.getReturnValue());
                console.log('response-->> '+JSON.stringify(response.getReturnValue()));
                cmp.set("v.PaginationList",response.getReturnValue());
                cmp.set("v.totalRecordsCount", response.getReturnValue().length);
                var a = cmp.get('c.sortByCD');
                $A.enqueueAction(a);
                
            }
        });
        $A.enqueueAction(action2); 
        cmp.set('v.showSpinner', false);
    },
    
    handleFilesChange: function(component, event, helper) {
        var fileName = 'No File Selected..';
        var ext;
        component.set('v.showSpinner', true);
        if (event.getSource().get("v.files").length > 0) {
            fileName = event.getSource().get("v.files")[0]['name'];
            ext = fileName.substring(fileName.length-3,fileName.length);
        }
        component.set("v.fileName", fileName);
        if(ext=='csv'){
            var fileInput = component.find("file").get("v.files");
            var file = fileInput[0];
            if (file) {
                var reader = new FileReader();
                reader.readAsText(file, "UTF-8");
                //alert('reader');
                reader.onload = function (evt) {
                    var csv = evt.target.result;
                    //alert('csv'+csv);
                    window.setTimeout($A.getCallback(function(){
                        helper.FetchData(component,csv);
                    }), 10);
                }
                reader.onerror = function (evt) {
                }
            }
        }
        else {
            component.set("v.errorMessage",'Kindly select a CSV file.');
            component.set('v.showSpinner', false);
        }
    },
    
    onNext : function(component, event, helper) {        
        var pageNumber = component.get("v.currentPageNumber");
        component.set("v.currentPageNumber", pageNumber+1);
        helper.buildData(component, helper);
    },
    
    onPrev : function(component, event, helper) {        
        var pageNumber = component.get("v.currentPageNumber");
        component.set("v.currentPageNumber", pageNumber-1);
        helper.buildData(component, helper);
    },
    
    changePageSize: function(component, event, helper) {
        component.set("v.currentPageNumber", 1);
        helper.buildData(component,helper);
    },
    
    onFirst : function(component, event, helper) {        
        component.set("v.currentPageNumber", 1);
        helper.buildData(component, helper);
    },
    
    onLast : function(component, event, helper) {        
        component.set("v.currentPageNumber", component.get("v.totalPages"));
        helper.buildData(component, helper);
    },
    
    sortByBatchID: function(component, event, helper) {
        var currentOrder = component.get("v.sortAsc"),
            currentList = component.get("v.BatchData");
        currentOrder = !currentOrder;
        currentList.sort(function(a,b) {
            var t1 = a.Name == b.Name, t2 = a.Name < b.Name;
            return t1? 0: (currentOrder?-1:1)*(t2?1:-1);
        });
        component.set("v.selectedTabsoft", "CD");
        if(currentOrder)
            component.set("v.arrowDirection", "arrowup");
        else
            component.set("v.arrowDirection", "arrowdown");
        component.set("v.sortAsc", currentOrder);
        component.set("v.BatchData", currentList);
        helper.buildData(component, helper);
    },
    
    processMe : function(component, event, helper) {
        component.set("v.currentPageNumber", parseInt(event.target.value));
        helper.buildData(component, helper);
    },
    
    sortByCD: function(component, event, helper) {
        var currentOrder = component.get("v.sortAsc"),
            currentList = component.get("v.BatchData");
        currentOrder = !currentOrder;
        currentList.sort(function(a,b) {
            var t1 = a.CreatedDate == b.CreatedDate, t2 = a.CreatedDate > b.CreatedDate;
            return t1? 0: (currentOrder?-1:1)*(t2?1:-1);
        });
        component.set("v.selectedTabsoft", "CD");
        if(!currentOrder){
            component.set("v.arrowDirection", "arrowup");
        }
        else{
            component.set("v.arrowDirection", "arrowdown");
        }
        component.set("v.sortAsc", currentOrder);
        component.set("v.BatchData", currentList);
        helper.buildData(component, helper);
    },
    
    handleUpload: function (component, event, helper) {
        // Get the list of uploaded files
        var uploadedFiles = event.getParam("files");
        
        // To get the file name
        uploadedFiles.forEach(file => file.documentId);
        var docId = uploadedFiles[0].documentId;
        helper.ProcessData(component,docId);
    },   
})