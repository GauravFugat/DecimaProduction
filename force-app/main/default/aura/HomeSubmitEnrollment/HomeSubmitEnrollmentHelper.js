({
	doInitHelper: function(component, event, helper) {
	},
    showSpinner: function (component, event, helper) {
        var spinner = component.find("mySpinner");
        $A.util.removeClass(spinner, "slds-hide");
    },
    hideSpinner: function (component, event, helper) {
        var spinner = component.find("mySpinner");
        $A.util.addClass(spinner, "slds-hide");
    },
    prevselHelp: function(component, event, helper) {
		var prevOpts = component.get("v.selectedOptions");
        component.set("v.prvSelectedOptions",prevOpts);
	},
    buildData : function(component, helper) {
        var data = [];
        var pageNumber = component.get("v.currentPageNumber");
          component.set("v.totalPages", Math.ceil( component.get("v.utilityAccountEnrollments").length/component.get("v.pageSize")));
        var pageSize = component.get("v.pageSize");
        var pixs = pageSize * 35;
        component.set("v.divHeight", pixs);
        var allData = component.get("v.utilityAccountEnrollments"); //component.get("v.BatchData");
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
    
    /* This function generate page list */
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
     sortHelper: function(component, event, sortFieldName) {
        var currentDir = component.get("v.arrowDirection");
        
        if (currentDir == 'arrowdown') {
            // set the arrowDirection attribute for conditionally rendred arrow sign  
            component.set("v.arrowDirection", 'arrowup');
            // set the isAsc flag to true for sort in Assending order.  
            component.set("v.isAsc", true);
        } else {
            component.set("v.arrowDirection", 'arrowdown');
            component.set("v.isAsc", false);
        }
        // call the onLoad function for call server side method with pass sortFieldName 
        this.onLoad(component, event, sortFieldName);
    },
    ValidationMessages: function(component,dataresponse){
       console.log('helper  95->'+JSON.stringify(dataresponse));
        var ValMessage;
         ValMessage+= "Enrollment Request Accepted";
        if(dataresponse.objUAE.Status__c === "Enrollment Request Accepted"){
            ValMessage+= "Enrollment Request Accepted";
        }
        /*else if(dataresponse.invalidDate){
            ValMessage.append('Invalid Date');
        }*/
            /*if(dataresponse.objUAE.Enrollment__r.Contract_Signed_Date__c ==undefined){
                ValMesaage.append('Invalid Contract Signing Date');
        }
                else{
                    ValMessage = 'No Validation';
                }*/
         ValMessage = 'No Validation';
        alert(ValMessage);
        component.set("v.ValidationMessage",ValMessage);
    }
})