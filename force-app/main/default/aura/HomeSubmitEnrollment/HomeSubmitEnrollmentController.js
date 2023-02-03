({
    doInit : function(component, event, helper) {
        var dataresponse;
        component.set("v.spinner", true);
        component.set('v.utility', $A.get("{!$Label.c.National_Grid_Utility_Id}"));
         var templist = [];
        var action = component.get("c.getFilteredUAEs");
        action.setParams({  
            "enrollemtStatus" : "defaultUAEs",
            "isDoinIt" : true
        });
        action.setCallback(this,function(response){
            var state = response.getState();
            if (state === "SUCCESS"){
                var resp = response.getReturnValue();
                if(resp == ''){
                    component.set("v.spinner", false); 
                }
                dataresponse = response.getReturnValue();
                component.set("v.totalRecordsCount", response.getReturnValue().length);
                component.set("v.utilityAccountEnrollments", response.getReturnValue());
                component.set('v.BatchData', response.getReturnValue());
                //component.set('v.TotalData', response.getReturnValue());
                templist = response.getReturnValue();
                console.log('v.TotalData :'+ JSON.stringify(component.get('v.TotalData')));
                component.set("v.PaginationList",response.getReturnValue());
                console.log('v.PaginationL-->> '+JSON.stringify(response.getReturnValue()));
                component.set("v.ContractSignedDate", resp[0].contractSignedDate);
                component.set("v.warnMessage", resp[0].errorMsg);
                component.set("v.pageSize",10);
                component.set("v.sortAsc",resp[0].checkCurrentSortOrder);
                var usrOpts = response.getReturnValue()[0].userOptions;
                component.set("v.prvSelectedOptions",usrOpts);
                var elemList =[];
                
                for( var element of templist){
                    elemList.push(element.objUAE);
                }
                console.log('elemList=>'+JSON.stringify(elemList));
                component.set('v.TotalData', elemList);
                if(usrOpts.includes("enrollmentID")){
                    component.set("v.selectedOptBoolean",true);
                }
                if(usrOpts.includes("customerID")){
                    component.set("v.selectedOptBoolean1",true);
                }
                if(usrOpts.includes("contract")){
                    component.set("v.selectedOptBoolean2",true);
                }
                if(usrOpts.includes("contractSignedDate")){
                    component.set("v.selectedOptBoolean3",true);
                }
                if(usrOpts.includes("billType")){
                    component.set("v.selectedOptBoolean4",true);
                }
                if(usrOpts.includes("product")){
                    component.set("v.selectedOptBoolean5",true);
                }
                if(usrOpts.includes("companyName")){
                    component.set("v.selectedOptBoolean6",true);
                }
                if(usrOpts.includes("utility")){
                    component.set("v.selectedOptBoolean7",true);
                }
                if(usrOpts.includes("utilityAccountNumber")){
                    component.set("v.selectedOptBoolean8",true);
                }
                if(usrOpts.includes("contractStart")){
                    component.set("v.selectedOptBoolean9",true);
                }
                if(usrOpts.includes("contractTerm")){
                    component.set("v.selectedOptBoolean10",true);
                }
                if(usrOpts.includes("rateAmount")){
                    component.set("v.selectedOptBoolean11",true);
                }
                if(usrOpts.includes("taxExempt")){
                    component.set("v.selectedOptBoolean12",true);
                }
                if(usrOpts.includes("customerType")){
                    component.set("v.selectedOptBoolean13",true);
                }
                if(usrOpts.includes("avgMeterReadDate")){
                    component.set("v.selectedOptBoolean14",true);
                }
                if(usrOpts.includes("broker")){
                    component.set("v.selectedOptBoolean15",true);
                }
                if(usrOpts.includes("accountOwner")){
                    component.set("v.selectedOptBoolean16",true);
                }
                if(usrOpts.includes("marketRateCode")){
                    component.set("v.selectedOptBoolean17",true);
                }
                if(usrOpts.includes("Status")){
                    component.set("v.selectedOptBoolean18",true);
                }
                if(usrOpts.includes("serviceAddress")){
                    component.set("v.selectedOptBoolean19",true);
                }
                if(usrOpts.includes("serviceClass")){
                    component.set("v.selectedOptBoolean20",true);
                }
                if(usrOpts.includes("taxablePortion")){
                    component.set("v.selectedOptBoolean21",true);
                }
                if(usrOpts.includes("autoSubmitFlag")){
                    component.set("v.selectedOptBoolean22",true);
                }
                if(usrOpts.includes("rateClass")){
                    component.set("v.selectedOptBoolean23",true);
                }
                if(usrOpts.includes("AutoSubmittedDate")){
                    component.set("v.selectedOptBoolean24",true);
                }
                var a = component.get('c.sortByEN');
                $A.enqueueAction(a);
                component.set("v.spinner", false);
                
            }else{
                component.set("v.spinner", false);
                alert('Apex CPU Limit Exceeded');
            }
            helper.ValidationMessages(component,dataresponse);
        });
        $A.enqueueAction(action);
        
        //component.set('v.TotalData', elemList);
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
    processMe : function(component, event, helper) {
        component.set("v.currentPageNumber", parseInt(event.target.value));
        helper.buildData(component, helper);
    },
    changeHeight: function(component, event, helper) {
        //component.set("v.divHeight", "300");
    },
    openModel : function(component, event, helper) {
        component.set("v.openModelBoolean",true);
    }, 
    closeModel : function(component, event, helper) {
        component.set("v.openModelBoolean",false);
        component.set("v.openFilterModal", false);
		component.set("v.dateFilterModal", false);
    }, 
    //below method is not required now
    handleOptionChange : function(component, event, helper) {
        var selectedOptionsList = event.getParam("value");
        component.set("v.selectedOptions",selectedOptionsList);
        component.set("v.prvSelectedOptions",selectedOptionsList);
        if(selectedOptionsList.includes("enrollmentID")){
            component.set("v.selectedOptBoolean",true);
        }else{
            component.set("v.selectedOptBoolean",false);
        }
        if(selectedOptionsList.includes("customerID")){
            component.set("v.selectedOptBoolean1",true);
        }else{
            component.set("v.selectedOptBoolean1",false);
        }
        if(selectedOptionsList.includes("contract")){
            component.set("v.selectedOptBoolean2",true);
        }else{
            component.set("v.selectedOptBoolean2",false);
        }
        if(selectedOptionsList.includes("contractSignedDate")){
            component.set("v.selectedOptBoolean3",true);
        }else{
            component.set("v.selectedOptBoolean3",false);
        }
        if(selectedOptionsList.includes("billType")){
            component.set("v.selectedOptBoolean4",true);
        }else{
            component.set("v.selectedOptBoolean4",false);
        }
        if(selectedOptionsList.includes("product")){
            component.set("v.selectedOptBoolean5",true);
        }else{
            component.set("v.selectedOptBoolean5",false);
        }
        if(selectedOptionsList.includes("companyName")){
            component.set("v.selectedOptBoolean6",true);
        }else{
            component.set("v.selectedOptBoolean6",false);
        }
        if(selectedOptionsList.includes("utility")){
            component.set("v.selectedOptBoolean7",true);
        }else{
            component.set("v.selectedOptBoolean7",false);
        }
        if(selectedOptionsList.includes("utilityAccountNumber")){
            
            component.set("v.selectedOptBoolean8",true);
        }else{
            component.set("v.selectedOptBoolean8",false);
        }
        if(selectedOptionsList.includes("contractStart")){
            component.set("v.selectedOptBoolean9",true);
        }else{
            component.set("v.selectedOptBoolean9",false);
        }
        if(selectedOptionsList.includes("contractTerm")){
            component.set("v.selectedOptBoolean10",true);
        }else{
            component.set("v.selectedOptBoolean10",false);
        }
        if(selectedOptionsList.includes("rateAmount")){
            component.set("v.selectedOptBoolean11",true);
        }else{
            component.set("v.selectedOptBoolean11",false);
        }
        if(selectedOptionsList.includes("taxExempt")){
            component.set("v.selectedOptBoolean12",true);
        }else{
            component.set("v.selectedOptBoolean12",false);
        }
        if(selectedOptionsList.includes("customerType")){
            component.set("v.selectedOptBoolean13",true);
        }else{
            component.set("v.selectedOptBoolean13",false);
        }
        if(selectedOptionsList.includes("avgMeterReadDate")){
            component.set("v.selectedOptBoolean14",true);
        }else{
            component.set("v.selectedOptBoolean14",false);
        }
        if(selectedOptionsList.includes("broker")){
            component.set("v.selectedOptBoolean15",true);
        }else{
            component.set("v.selectedOptBoolean15",false);
        }
        if(selectedOptionsList.includes("accountOwner")){
            component.set("v.selectedOptBoolean16",true);
        }else{
            component.set("v.selectedOptBoolean16",false);
        }
        if(selectedOptionsList.includes("marketRateCode")){
            component.set("v.selectedOptBoolean17",true);
        }else{
            component.set("v.selectedOptBoolean17",false);
        }
        if(selectedOptionsList.includes("Status")){
            component.set("v.selectedOptBoolean18",true);
        }else{
            component.set("v.selectedOptBoolean18",false);
        }
        if(selectedOptionsList.includes("serviceAddress")){
            component.set("v.selectedOptBoolean19",true);
        }else{
            component.set("v.selectedOptBoolean19",false);
        }
        if(selectedOptionsList.includes("serviceClass")){
            component.set("v.selectedOptBoolean20",true);
        }else{
            component.set("v.selectedOptBoolean20",false);
        }
        if(selectedOptionsList.includes("taxablePortion")){
            component.set("v.selectedOptBoolean21",true);
        }else{
            component.set("v.selectedOptBoolean21",false);
        }
        if(selectedOptionsList.includes("autoSubmitFlag")){
            component.set("v.selectedOptBoolean22",true);
        }else{
            component.set("v.selectedOptBoolean22",false);
        }
        if(selectedOptionsList.includes("rateClass")){
            component.set("v.selectedOptBoolean23",true);
        }else{
            component.set("v.selectedOptBoolean23",false);
        }
        if(selectedOptionsList.includes("AutoSubmittedDate")){
            component.set("v.selectedOptBoolean24",true);
        }else{
            component.set("v.selectedOptBoolean24",false);
        }
    },
    handleSaveOptionChange : function(component, event, helper) {
        var selectedOptionsList = component.find('selectOptions').get('v.value');
        component.set("v.selectedOptions",selectedOptionsList);
        component.set("v.prvSelectedOptions",selectedOptionsList);
        if(selectedOptionsList.includes("enrollmentID")){
            component.set("v.selectedOptBoolean",true);
        }else{
            component.set("v.selectedOptBoolean",false);
        }
        if(selectedOptionsList.includes("customerID")){
            component.set("v.selectedOptBoolean1",true);
        }else{
            component.set("v.selectedOptBoolean1",false);
        }
        if(selectedOptionsList.includes("contract")){
            component.set("v.selectedOptBoolean2",true);
        }else{
            component.set("v.selectedOptBoolean2",false);
        }
        if(selectedOptionsList.includes("contractSignedDate")){
            component.set("v.selectedOptBoolean3",true);
        }else{
            component.set("v.selectedOptBoolean3",false);
        }
        if(selectedOptionsList.includes("billType")){
            component.set("v.selectedOptBoolean4",true);
        }else{
            component.set("v.selectedOptBoolean4",false);
        }
        if(selectedOptionsList.includes("product")){
            component.set("v.selectedOptBoolean5",true);
        }else{
            component.set("v.selectedOptBoolean5",false);
        }
        if(selectedOptionsList.includes("companyName")){
            component.set("v.selectedOptBoolean6",true);
        }else{
            component.set("v.selectedOptBoolean6",false);
        }
        if(selectedOptionsList.includes("utility")){
            component.set("v.selectedOptBoolean7",true);
        }else{
            component.set("v.selectedOptBoolean7",false);
        }
        if(selectedOptionsList.includes("utilityAccountNumber")){
            component.set("v.selectedOptBoolean8",true);
        }else{
            component.set("v.selectedOptBoolean8",false);
        }
        if(selectedOptionsList.includes("contractStart")){
            component.set("v.selectedOptBoolean9",true);
        }else{
            component.set("v.selectedOptBoolean9",false);
        }
        if(selectedOptionsList.includes("contractTerm")){
            component.set("v.selectedOptBoolean10",true);
        }else{
            component.set("v.selectedOptBoolean10",false);
        }
        if(selectedOptionsList.includes("rateAmount")){
            component.set("v.selectedOptBoolean11",true);
        }else{
            component.set("v.selectedOptBoolean11",false);
        }
        if(selectedOptionsList.includes("taxExempt")){
            component.set("v.selectedOptBoolean12",true);
        }else{
            component.set("v.selectedOptBoolean12",false);
        }
        if(selectedOptionsList.includes("customerType")){
            component.set("v.selectedOptBoolean13",true);
        }else{
            component.set("v.selectedOptBoolean13",false);
        }
        if(selectedOptionsList.includes("avgMeterReadDate")){
            component.set("v.selectedOptBoolean14",true);
        }else{
            component.set("v.selectedOptBoolean14",false);
        }
        if(selectedOptionsList.includes("broker")){
            component.set("v.selectedOptBoolean15",true);
        }else{
            component.set("v.selectedOptBoolean15",false);
        }
        if(selectedOptionsList.includes("accountOwner")){
            component.set("v.selectedOptBoolean16",true);
        }else{
            component.set("v.selectedOptBoolean16",false);
        }  
        if(selectedOptionsList.includes("marketRateCode")){
            component.set("v.selectedOptBoolean17",true);
        }else{
            component.set("v.selectedOptBoolean17",false);
        }
        if(selectedOptionsList.includes("Status")){
            component.set("v.selectedOptBoolean18",true);
        }else{
            component.set("v.selectedOptBoolean18",false);
        }
        if(selectedOptionsList.includes("serviceAddress")){
            component.set("v.selectedOptBoolean19",true);
        }else{
            component.set("v.selectedOptBoolean19",false);
        }
        if(selectedOptionsList.includes("serviceClass")){
            component.set("v.selectedOptBoolean20",true);
        }else{
            component.set("v.selectedOptBoolean20",false);
        }
        if(selectedOptionsList.includes("taxablePortion")){
            component.set("v.selectedOptBoolean21",true);
        }else{
            component.set("v.selectedOptBoolean21",false);
        }
        if(selectedOptionsList.includes("autoSubmitFlag")){
            component.set("v.selectedOptBoolean22",true);
        }else{
            component.set("v.selectedOptBoolean22",false);
        }
        if(selectedOptionsList.includes("rateClass")){
            component.set("v.selectedOptBoolean23",true);
        }else{
            component.set("v.selectedOptBoolean23",false);
        }
        if(selectedOptionsList.includes("AutoSubmittedDate")){
            component.set("v.selectedOptBoolean24",true);
        }else{
            component.set("v.selectedOptBoolean24",false);
        }
        var action = component.get("c.SaveSelectedOptions");
        action.setParams({  
            "options" : component.get("v.prvSelectedOptions")
        });
        action.setCallback(this,function(response){
            var state = response.getState(); 
        });
        $A.enqueueAction(action);
        
        var action1 = component.get('c.closeModel');
        $A.enqueueAction(action1);
    },
    onFilterChange : function(component, event, helper) {
        helper.showSpinner(component);
        component.set('v.utility', $A.get("{!$Label.c.National_Grid_Utility_Id}"));
        var action = component.get("c.getFilteredUAEs");
        action.setParams({  
            "enrollemtStatus" :component.find('select').get('v.value'),
            "isDoinIt" : false,
            "selectedGroup" : component.find('selectGroup').get('v.value')
        });
        action.setCallback(this,function(response){
            var state = response.getState();
            if (state === "SUCCESS"){
                helper.hideSpinner(component);
                var resp = response.getReturnValue();
                component.set("v.totalRecordsCount", response.getReturnValue().length);
                component.set("v.utilityAccountEnrollments", response.getReturnValue());
                component.set('v.BatchData', response.getReturnValue());
                component.set("v.PaginationList",response.getReturnValue());
                component.set("v.ContractSignedDate", resp[0].contractSignedDate);
                component.set("v.warnMessage", resp[0].errorMsg);
                component.set("v.pageSize", 10);
                component.set("v.hasSelectedUAE",false);
                var a = component.get('c.sortByCD');
                $A.enqueueAction(a);
            }else{
            }
        });
        $A.enqueueAction(action);
        component.set('v.fromDate',null);
        component.set('v.toDate',null);
        component.set('v.selectedDateColumn',null);
        component.set("v.SelectedData",null);
        component.set("v.sQuery",null);
    },
    onGroupChange : function(component, event, helper) {
        helper.showSpinner(component);
        component.set('v.utility', $A.get("{!$Label.c.National_Grid_Utility_Id}"));
        var action = component.get("c.getGroupedUAEs");
        action.setParams({  
            "selectedGroup" :component.find('selectGroup').get('v.value'),
            "selectedFilter":component.find('select').get('v.value') 
        });
        action.setCallback(this,function(response){
            var state = response.getState();
            if (state === "SUCCESS"){
                helper.hideSpinner(component);
                var resp = response.getReturnValue();
                component.set("v.totalRecordsCount", response.getReturnValue().length);
                component.set("v.utilityAccountEnrollments", response.getReturnValue());
                component.set('v.BatchData', response.getReturnValue());
                component.set("v.PaginationList",response.getReturnValue());
                component.set("v.ContractSignedDate", resp[0].contractSignedDate);
                component.set("v.warnMessage", resp[0].errorMsg);
                component.set("v.pageSize", 10);
                component.set("v.hasSelectedUAE",false);
                var a = component.get('c.sortByCD');
                $A.enqueueAction(a);
            }else{
            }
        });
        $A.enqueueAction(action);
        
        component.set('v.fromDate',null);
        component.set('v.toDate',null);
        component.set('v.selectedDateColumn',null);
        component.set("v.SelectedData",null);
        component.set("v.sQuery",null);
    },
    onStartDateFromChange: function(component,event,helper){
        helper.showSpinner(component);
        component.set('v.utility', $A.get("{!$Label.c.National_Grid_Utility_Id}"));
        var action = component.get("c.getStartDateUAEs");
        console.log("in method"+component.find('fromDate').get('v.value'));
        //console.log("in method"+component.find('averageFromDate').get('v.value'));
        action.setParams({  
            "selectedGroup" :component.find('selectGroup').get('v.value'),
            "selectedFilter":component.find('select').get('v.value'),
            "fromDate1" : component.get('v.fromDate'),
            "toDate1" : component.get('v.toDate'),
            "dateColumnName" : component.get('v.selectedDateColumn'),
            "allFilters": component.get('v.sQuery')
        });
        console.log('params set');
        action.setCallback(this,function(response){
            var state = response.getState();
            console.log('state='+state);
            if (state === "SUCCESS"){
                helper.hideSpinner(component);
                var resp = response.getReturnValue();
                component.set("v.totalRecordsCount", response.getReturnValue().length);
                component.set("v.utilityAccountEnrollments", response.getReturnValue());
                component.set('v.BatchData', response.getReturnValue());
                component.set("v.PaginationList",response.getReturnValue());
                component.set("v.ContractSignedDate", resp[0].contractSignedDate);
                component.set("v.warnMessage", resp[0].errorMsg);
                component.set("v.pageSize", 10);
                component.set("v.hasSelectedUAE",false);
                helper.buildData(component, helper);
                console.log('Done')
                // var a = component.get('c.sortByCD');
                // $A.enqueueAction(a);
            }else{
            }
        });
        $A.enqueueAction(action);  
        
    },
    onStartDateToChange: function(component,event,helper){
        helper.showSpinner(component);
        component.set('v.utility', $A.get("{!$Label.c.National_Grid_Utility_Id}"));
        var action = component.get("c.getStartDateUAEs");
        
        action.setParams({  
            "selectedGroup" :component.find('selectGroup').get('v.value'),
            "selectedFilter":component.find('select').get('v.value'),
            "fromDate1" : component.get('v.fromDate'),
            "toDate1" : component.get('v.toDate'),
            "dateColumnName" : component.get('v.selectedDateColumn'),
            "allFilters": component.get('v.sQuery')
        });
        action.setCallback(this,function(response){
            var state = response.getState();
            if (state === "SUCCESS"){
                helper.hideSpinner(component);
                var resp = response.getReturnValue();
                 
                component.set("v.totalRecordsCount", response.getReturnValue().length);
                component.set("v.utilityAccountEnrollments", response.getReturnValue());
                component.set('v.BatchData', response.getReturnValue());
                component.set("v.PaginationList",response.getReturnValue());
                component.set("v.ContractSignedDate", resp[0].contractSignedDate);
                component.set("v.warnMessage", resp[0].errorMsg);
                component.set("v.pageSize", 10);
                component.set("v.hasSelectedUAE",false);
                helper.buildData(component, helper);
                // var a = component.get('c.sortByCD');
                // $A.enqueueAction(a);
            }else{
            }
        });
        $A.enqueueAction(action); 
        
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
        component.set("v.utilityAccountEnrollments", currentList);
        helper.buildData(component, helper);
    },
    handleSubmit: function(component, event, helper) {
        $A.util.removeClass(component.find("Spinner"), "slds-hide");
    },
    handleSubmit11: function(component, event, helper) {
        helper.showSpinner(component);
        var UAE = component.get("v.utilityAccountEnrollments");
        var updatedUAE =[];
        var isInvalid = false;
        var utility = component.get("v.utility");
        var enrollmentBillType = component.get("v.enrollmentBillType");        
        for(var i=0; i<UAE.length;i++){
            if(UAE[i].isChecked){
                updatedUAE.push(UAE[i].objUAE);
            }
        }
        if(!isInvalid){
            component.set("v.errMsg", '');
            component.set("v.selectedUAEs", updatedUAE);
            var action = component.get("c.submitEnrollment");
            action.setParams({ 
                "recordId" : component.get("v.recordId"),
                "objUAEs" : updatedUAE,
                "currentSortOrder" : component.get("v.sortAsc")
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS"){                    
                    helper.hideSpinner(component);
                    component.set("v.code", response.getReturnValue().Code);
                    component.set("v.Renewalcode", response.getReturnValue().RenewCode);
                    component.set("v.selectedUAEsActive", response.getReturnValue().UAE);
                    component.set("v.selectedUAEs", response.getReturnValue().UAENotActive);                    
                    component.set("v.errMsgRequireObjects", '');
                    component.set("v.showResults", true);
                    $A.get('e.force:refreshView').fire();
                    helper.hideSpinner(component);                    
                }
                else if(state === "ERROR"){
                    helper.hideSpinner(component);
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error",
                        "type": 'error',
                        "message": response.getError()
                    });
                    toastEvent.fire();
                }
            }); 
            $A.enqueueAction(action); 
        }
        else{
            helper.hideSpinner(component);
            component.set("v.errMsg", errMsg);
        }
    },
    checkboxSelect: function(component, event, helper) {
        var selectedUAE = event.getSource().get("v.name");
        var UAEs = component.get("v.utilityAccountEnrollments");
        if(UAEs[selectedUAE].objUAE.Hold_Transaction__c || UAEs[selectedUAE].objUAE.Hold_Reason_Code__c != null || UAEs[selectedUAE].objUAE.Start_Date__c != null){
            component.set("v.invalidDate", false);
        }
        else{
            component.set("v.invalidDate", true);
        }
        var checker = false;
        for(var i=0; i<UAEs.length;i++){
            if(UAEs[i].isChecked){
                checker = true;
            }
        }
        component.set("v.isCheckboxSelected",checker)
        component.set("v.hasSelectedUAE",checker);
        component.set("v.ApplyDisable", checker);
        
        var getSelectedNumber = component.get("v.indexValExistPR");
        var selectedRec = event.getSource().get("v.value");
        if (selectedRec == true) {
            getSelectedNumber++;
        } 
        else{
            getSelectedNumber--;
            component.find("selectAllCheckbox").set("v.value", false);
        }
        component.set("v.indexValExistPR", getSelectedNumber);
        
        if (UAEs.length == getSelectedNumber) {
            component.find("selectAllCheckbox").set("v.value", true);
        }else{
            component.find("selectAllCheckbox").set("v.value", false);
        }
    },
    selectAllCheckbox: function(component, event, helper) {
        var selectedHeaderCheck = event.getSource().get("v.value");
        var UAEs = component.get("v.utilityAccountEnrollments");
        for(var i=0; i<UAEs.length;i++){
            if(UAEs[i].objUAE.Status__c != 'Enrollment Request Accepted')
                UAEs[i].isChecked = selectedHeaderCheck;
        }
        var checker = false;
        for(var i=0; i<UAEs.length;i++){
            if(UAEs[i].isChecked){
                checker = true;                
            }
        }
        for(var i=0; i<UAEs.length;i++){
            if(UAEs[i].objUAE.Hold_Transaction__c || UAEs[i].objUAE.Hold_Reason_Code__c != null || UAEs[i].objUAE.Start_Date__c != null){
                
                component.set("v.invalidDate", false);
            }
        }
        component.set("v.hasSelectedUAE",checker);
        component.set("v.ApplyDisable", checker);
        component.set("v.isCheckboxSelected",checker)
        component.set("v.utilityAccountEnrollments",UAEs);
        helper.buildData(component, helper);
    },
    sortByAMRD: function(component, event, helper) {
        var currentOrder = component.get("v.sortAsc"),
            currentList = component.get("v.utilityAccountEnrollments");
        currentOrder = !currentOrder;
        currentList.sort(function(a,b) {
            var t1 = a.objUAE.Utility_Account__r.Average_Meter_Read_Date__c	== b.objUAE.Utility_Account__r.Average_Meter_Read_Date__c, t2 = a.objUAE.Utility_Account__r.Average_Meter_Read_Date__c < b.objUAE.Utility_Account__r.Average_Meter_Read_Date__c;
            return t1? 0: (currentOrder?-1:1)*(t2?1:-1);
        });
        component.set("v.selectedTabsoft", "AMRD");
        if(currentOrder)
            component.set("v.arrowDirection", "arrowup");
        else
            component.set("v.arrowDirection", "arrowdown");
        component.set("v.sortAsc", currentOrder);
        component.set("v.utilityAccountEnrollments", currentList);
        helper.buildData(component, helper);
    },
    sortByBroker: function(component, event, helper) {
        var currentOrder = component.get("v.sortAsc"),
            currentList = component.get("v.utilityAccountEnrollments");
        currentOrder = !currentOrder;
        currentList.sort(function(a,b) {
            var bValue;
            var aValue;
            if(a.objUAE.Enrollment__r.Broker_Name__c == undefined){
                aValue = '';
            }else{
                aValue =a.objUAE.Enrollment__r.Broker_Name__c;
            }
            if(b.objUAE.Enrollment__r.Broker_Name__c == undefined){
                bValue = '';
            }else{
                bValue = b.objUAE.Enrollment__r.Broker_Name__c;
            }
            var t1 = aValue == bValue, t2 = aValue < bValue; 
            return t1? 0: (currentOrder?-1:1)*(t2?1:-1);
        });
        component.set("v.selectedTabsoft", "broker");
        if(currentOrder)
            component.set("v.arrowDirection", "arrowup");
        else
            component.set("v.arrowDirection", "arrowdown");
        component.set("v.sortAsc", currentOrder);
        component.set("v.utilityAccountEnrollments", currentList);
        helper.buildData(component, helper);
    },
    sortByUtility: function(component, event, helper) {
        var currentOrder = component.get("v.sortAsc"),
            currentList = component.get("v.utilityAccountEnrollments");
        currentOrder = !currentOrder;
        currentList.sort(function(a,b) {
            var t1 = a.objUAE.Utility_Account__r.Utility__r.Name == b.objUAE.Utility_Account__r.Utility__r.Name, t2 = a.objUAE.Utility_Account__r.Utility__r.Name < b.objUAE.Utility_Account__r.Utility__r.Name;
            return t1? 0: (currentOrder?-1:1)*(t2?1:-1);
        });
        component.set("v.selectedTabsoft", "Utility");
        if(currentOrder)
            component.set("v.arrowDirection", "arrowup");
        else
            component.set("v.arrowDirection", "arrowdown");
        component.set("v.sortAsc", currentOrder);
        component.set("v.utilityAccountEnrollments", currentList);
        helper.buildData(component, helper);
    },
    sortByBillType : function(component, event, helper) {
        var currentOrder = component.get("v.sortAsc"),
            currentList = component.get("v.utilityAccountEnrollments");
        currentOrder = !currentOrder;
        currentList.sort(function(a,b) {
            var bValue;
            var aValue;
            if(a.objUAE.Bill_Type__c == undefined){
                aValue = '';
            }else{
                aValue =a.objUAE.Bill_Type__c;
            }
            if(b.objUAE.Bill_Type__c == undefined){
                bValue = '';
            }else{
                bValue = b.objUAE.Bill_Type__c;
            }
            var t1 = aValue == bValue, t2 = aValue < bValue; 
            return t1? 0: (currentOrder?-1:1)*(t2?1:-1);
        });
        component.set("v.selectedTabsoft", "BillType");
        if(currentOrder)
            component.set("v.arrowDirection", "arrowup");
        else
            component.set("v.arrowDirection", "arrowdown");
        component.set("v.sortAsc", currentOrder);
        component.set("v.utilityAccountEnrollments", currentList);
        helper.buildData(component, helper);
    },
    sortByCT: function(component, event, helper) {
        var currentOrder = component.get("v.sortAsc"),
            currentList = component.get("v.utilityAccountEnrollments");
        currentOrder = !currentOrder;
        currentList.sort(function(a,b) {
            var t1 = a.objUAE.Enrollment__r.Contract_Term__c == b.objUAE.Enrollment__r.Contract_Term__c, t2 = a.objUAE.Enrollment__r.Contract_Term__c < b.objUAE.Enrollment__r.Contract_Term__c;
            return t1? 0: (currentOrder?-1:1)*(t2?1:-1);
        });
        component.set("v.selectedTabsoft", "contractTerm");
        if(currentOrder)
            component.set("v.arrowDirection", "arrowup");
        else
            component.set("v.arrowDirection", "arrowdown");
        component.set("v.sortAsc", currentOrder);
        component.set("v.utilityAccountEnrollments", currentList);
        helper.buildData(component, helper);
    },
    sortByRateAmmount: function(component, event, helper) {
        var currentOrder = component.get("v.sortAsc"),
            currentList = component.get("v.utilityAccountEnrollments");
        currentOrder = !currentOrder;
        currentList.sort(function(a,b) {
            var t1 = a.objUAE.Enrollment__r.Rate_Amount__c == b.objUAE.Enrollment__r.Rate_Amount__c, t2 = a.objUAE.Enrollment__r.Rate_Amount__c < b.objUAE.Enrollment__r.Rate_Amount__c;
            return t1? 0: (currentOrder?-1:1)*(t2?1:-1);
        });
        component.set("v.selectedTabsoft", "rateAmmount");
        if(currentOrder)
            component.set("v.arrowDirection", "arrowup");
        else
            component.set("v.arrowDirection", "arrowdown");
        component.set("v.sortAsc", currentOrder);
        component.set("v.utilityAccountEnrollments", currentList);
        helper.buildData(component, helper);
    },
    sortByTaxExempt: function(component, event, helper) {
        var currentOrder = component.get("v.sortAsc"),
            currentList = component.get("v.utilityAccountEnrollments");
        currentOrder = !currentOrder;
        currentList.sort(function(a,b) {
            var t1 = a.objUAE.Tax_Exempt__c == b.objUAE.Tax_Exempt__c, t2 = a.objUAE.Tax_Exempt__c < b.objUAE.Tax_Exempt__c;
            return t1? 0: (currentOrder?-1:1)*(t2?1:-1);
        });
        component.set("v.selectedTabsoft", "taxExempt");
        if(currentOrder)
            component.set("v.arrowDirection", "arrowup");
        else
            component.set("v.arrowDirection", "arrowdown");
        component.set("v.sortAsc", currentOrder);
        component.set("v.utilityAccountEnrollments", currentList);
        helper.buildData(component, helper);
    },
    sortByTaxablePortion: function(component, event, helper) {
        var currentOrder = component.get("v.sortAsc"),
            currentList = component.get("v.utilityAccountEnrollments");
        currentOrder = !currentOrder;
        currentList.sort(function(a,b) {
            var bValue;
            var aValue;
            if(a.objUAE.Enrollment__r.Taxable_Portion__c == undefined){
                aValue = '';
            }else{
                aValue =a.objUAE.Enrollment__r.Taxable_Portion__c;
            }
            if(b.objUAE.Enrollment__r.Taxable_Portion__c == undefined){
                bValue = '';
            }else{
                bValue = b.objUAE.Enrollment__r.Taxable_Portion__c;
            }
            var t1 = aValue == bValue, t2 = aValue < bValue; 
            return t1? 0: (currentOrder?-1:1)*(t2?1:-1);
        });
        component.set("v.selectedTabsoft", "taxablePortion");
        if(currentOrder)
            component.set("v.arrowDirection", "arrowup");
        else
            component.set("v.arrowDirection", "arrowdown");
        component.set("v.sortAsc", currentOrder);
        component.set("v.utilityAccountEnrollments", currentList);
        helper.buildData(component, helper);
    },
    sortByAutoSubmitFlag: function(component, event, helper) {
        var currentOrder = component.get("v.sortAsc"),
            currentList = component.get("v.utilityAccountEnrollments");
        currentOrder = !currentOrder;
        currentList.sort(function(a,b) {
            var bValue;
            var aValue;
            if(a.objUAE.Enrollment__r.Taxable_Portion__c == undefined){
                aValue = '';
            }else{
                aValue =a.objUAE.Enrollment__r.Taxable_Portion__c;
            }
            if(b.objUAE.Enrollment__r.Taxable_Portion__c == undefined){
                bValue = '';
            }else{
                bValue = b.objUAE.Enrollment__r.Taxable_Portion__c;
            }
            var t1 = aValue == bValue, t2 = aValue < bValue; 
            return t1? 0: (currentOrder?-1:1)*(t2?1:-1);
        });
        component.set("v.selectedTabsoft", "autoSubmitFlag");
        if(currentOrder)
            component.set("v.arrowDirection", "arrowup");
        else
            component.set("v.arrowDirection", "arrowdown");
        component.set("v.sortAsc", currentOrder);
        component.set("v.utilityAccountEnrollments", currentList);
        helper.buildData(component, helper);
    },
    sortByRateClass: function(component, event, helper) {
        var currentOrder = component.get("v.sortAsc"),
            currentList = component.get("v.utilityAccountEnrollments");
        currentOrder = !currentOrder;
        currentList.sort(function(a,b) {
            var bValue;
            var aValue;
            if(a.objUAE.RateClass__c == undefined){
                aValue = '';
            }else{
                aValue =a.objUAE.RateClass__c;
            }
            if(b.objUAE.RateClass__c == undefined){
                bValue = '';
            }else{
                bValue = b.objUAE.RateClass__c;
            }
            var t1 = aValue == bValue, t2 = aValue < bValue; 
            return t1? 0: (currentOrder?-1:1)*(t2?1:-1);
        });
        component.set("v.selectedTabsoft", "rateClass");
        if(currentOrder)
            component.set("v.arrowDirection", "arrowup");
        else
            component.set("v.arrowDirection", "arrowdown");
        component.set("v.sortAsc", currentOrder);
        component.set("v.utilityAccountEnrollments", currentList);
        helper.buildData(component, helper);
    },
    sortByAccountOwner: function(component, event, helper) {
        var currentOrder = component.get("v.sortAsc"),
            currentList = component.get("v.utilityAccountEnrollments");
        currentOrder = !currentOrder;
        currentList.sort(function(a,b) {
            var bValue;
            var aValue;
            if(a.objUAE.Enrollment__r.Contract__r.Account.Owner.Name == undefined){
                aValue = '';
            }else{
                aValue =a.objUAE.Enrollment__r.Contract__r.Account.Owner.Name;
            }
            if(b.objUAE.Enrollment__r.Contract__r.Account.Owner.Name){
                bValue = '';
            }else{
                bValue = b.objUAE.Enrollment__r.Contract__r.Account.Owner.Name;
            }
            var t1 = aValue == bValue, t2 = aValue < bValue;  
            return t1? 0: (currentOrder?-1:1)*(t2?1:-1);
        });
        component.set("v.selectedTabsoft", "accountOwner");
        if(currentOrder)
            component.set("v.arrowDirection", "arrowup");
        else
            component.set("v.arrowDirection", "arrowdown");
        component.set("v.sortAsc", currentOrder);
        component.set("v.utilityAccountEnrollments", currentList);
        helper.buildData(component, helper);
    },
    sortByCustomerType: function(component, event, helper) {
        var currentOrder = component.get("v.sortAsc"),
            currentList = component.get("v.utilityAccountEnrollments");
        currentOrder = !currentOrder;
        currentList.sort(function(a,b) {
            var bValue;
            var aValue;
            if(a.objUAE.Enrollment__r.Sale_Type__c == undefined){
                aValue = '';
            }else{
                aValue =a.objUAE.Enrollment__r.Sale_Type__c;
            }
            if(b.objUAE.Enrollment__r.Sale_Type__c == undefined){
                bValue = '';
            }else{
                bValue = b.objUAE.Enrollment__r.Sale_Type__c;
            }
            var t1 = aValue == bValue, t2 = aValue < bValue; 
            return t1? 0: (currentOrder?-1:1)*(t2?1:-1);
        });
        component.set("v.selectedTabsoft", "customerType");
        if(currentOrder)
            component.set("v.arrowDirection", "arrowup");
        else
            component.set("v.arrowDirection", "arrowdown");
        component.set("v.sortAsc", currentOrder);
        component.set("v.utilityAccountEnrollments", currentList);
        helper.buildData(component, helper);
    },
    sortByRSN : function(component, event, helper) {
        var currentOrder = component.get("v.sortAsc"),
            currentList = component.get("v.utilityAccountEnrollments");
        currentOrder = !currentOrder;
        currentList.sort(function(a,b) {
            var t1 = a.objUAE.Rate_Schedule_Name__c == b.objUAE.Rate_Schedule_Name__c, t2 = a.objUAE.Rate_Schedule_Name__c < b.objUAE.Rate_Schedule_Name__c;
            return t1? 0: (currentOrder?-1:1)*(t2?1:-1);
        });
        component.set("v.selectedTabsoft", "RSN");
        if(currentOrder)
            component.set("v.arrowDirection", "arrowup");
        else
            component.set("v.arrowDirection", "arrowdown");
        component.set("v.sortAsc", currentOrder);
        component.set("v.utilityAccountEnrollments", currentList);
        helper.buildData(component, helper);
    },
    sortByStatus  : function(component, event, helper) {
        var currentOrder = component.get("v.sortAsc"),
            currentList = component.get("v.utilityAccountEnrollments");
        currentOrder = !currentOrder;
        currentList.sort(function(a,b) {
            var t1 = a.objUAE.Status__c == b.objUAE.Status__c, t2 = a.objUAE.Status__c < b.objUAE.Status__c;
            return t1? 0: (currentOrder?-1:1)*(t2?1:-1);
        });
        component.set("v.selectedTabsoft", "Status");
        if(currentOrder)
            component.set("v.arrowDirection", "arrowup");
        else
            component.set("v.arrowDirection", "arrowdown");
        component.set("v.sortAsc", currentOrder);
        component.set("v.utilityAccountEnrollments", currentList);
        helper.buildData(component, helper);
    },
    sortBySA : function(component, event, helper) {
        var currentOrder = component.get("v.sortAsc"),
            currentList = component.get("v.utilityAccountEnrollments");
        currentOrder = !currentOrder;
        currentList.sort(function(a,b) {
            var t1 = a.objUAE.Utility_Account__r.Service_Address__c == b.objUAE.Utility_Account__r.Service_Address__c, t2 = a.objUAE.Utility_Account__r.Service_Address__c < b.objUAE.Utility_Account__r.Service_Address__c;
            return t1? 0: (currentOrder?-1:1)*(t2?1:-1);
        });
        component.set("v.selectedTabsoft", "SA");
        if(currentOrder)
            component.set("v.arrowDirection", "arrowup");
        else
            component.set("v.arrowDirection", "arrowdown");
        component.set("v.sortAsc", currentOrder);
        component.set("v.utilityAccountEnrollments", currentList);
        helper.buildData(component, helper);
    },
    sortBySC : function(component, event, helper) {
        var currentOrder = component.get("v.sortAsc"),
            currentList = component.get("v.utilityAccountEnrollments");
        currentOrder = !currentOrder;
        currentList.sort(function(a,b) {
            var bValue;
            var aValue;
            if(a.objUAE.Utility_Account__r.Service_Class__c == undefined){
                aValue = '';
            }else{
                aValue =a.objUAE.Utility_Account__r.Service_Class__c;
            }
            if(b.objUAE.Utility_Account__r.Service_Class__c == undefined){
                bValue = '';
            }else{
                bValue = b.objUAE.Utility_Account__r.Service_Class__c;
            }
            var t1 = aValue == bValue, t2 = aValue < bValue; 
            
            return t1? 0: (currentOrder?-1:1)*(t2?1:-1);
        }); 
        component.set("v.selectedTabsoft", "SC");
        if(currentOrder)
            component.set("v.arrowDirection", "arrowup");
        else
            component.set("v.arrowDirection", "arrowdown");
        component.set("v.sortAsc", currentOrder);
        component.set("v.utilityAccountEnrollments", currentList);
        helper.buildData(component, helper); 
    }, 
    sortByContract: function(component, event, helper) {
        var currentOrder = component.get("v.sortAsc"),
            currentList = component.get("v.utilityAccountEnrollments");
        currentOrder = !currentOrder;
        currentList.sort(function(a,b) {
            var bValue;
            var aValue;
            if(a.objUAE.Enrollment__r.Contract__c == undefined){
                aValue = '';
            }else{
                aValue =a.objUAE.Enrollment__r.Contract__c;
            }
            if(b.objUAE.Enrollment__r.Contract__c == undefined){
                bValue = '';
            }else{
                bValue = b.objUAE.Enrollment__r.Contract__c;
            }
            var t1 = aValue == bValue, t2 = aValue < bValue; 
            return t1? 0: (currentOrder?-1:1)*(t2?1:-1);
        });
        component.set("v.selectedTabsoft", "contract");
        if(currentOrder)
            component.set("v.arrowDirection", "arrowup");
        else
            component.set("v.arrowDirection", "arrowdown");
        component.set("v.sortAsc", currentOrder);
        component.set("v.utilityAccountEnrollments", currentList);
        helper.buildData(component, helper);
    },
    sortByCSD : function(component, event, helper) {
        var currentOrder = component.get("v.sortAsc"),
            currentList = component.get("v.utilityAccountEnrollments");
        currentOrder = !currentOrder;
        currentList.sort(function(a,b) {
            var bValue;
            var aValue;
            if(a.objUAE.Enrollment__r.Contract_Signed_Date__c == undefined){
                aValue = '';
            }else{
                aValue =a.objUAE.Enrollment__r.Contract__c;
            }
            if(b.objUAE.Enrollment__r.Contract__c == undefined){
                bValue = '';
            }else{
                bValue = b.objUAE.Enrollment__r.Contract__c;
            }
            var t1 = aValue == bValue, t2 = aValue < bValue; 
            return t1? 0: (currentOrder?-1:1)*(t2?1:-1);
        }); 
        component.set("v.selectedTabsoft", "SD");
        if(currentOrder)
            component.set("v.arrowDirection", "arrowup");
        else
            component.set("v.arrowDirection", "arrowdown");
        component.set("v.sortAsc", currentOrder);
        component.set("v.utilityAccountEnrollments", currentList);
        helper.buildData(component, helper); 
    }, 
    sortByContractStart : function(component, event, helper) {
        var currentOrder = component.get("v.sortAsc"),
            currentList = component.get("v.utilityAccountEnrollments");
        currentOrder = !currentOrder;
        currentList.sort(function(a,b) {
            var bValue;
            var aValue;
            if(a.objUAE.Contract_Start__c == undefined){
                aValue = '';
            }else{
                aValue =a.objUAE.Contract_Start__c;
            }
            if(b.objUAE.Contract_Start__c == undefined){
                bValue = '';
            }else{
                bValue = b.objUAE.Contract_Start__c;
            }
            var t1 = aValue == bValue, t2 = aValue < bValue; 
            return t1? 0: (currentOrder?-1:1)*(t2?1:-1);
        }); 
        component.set("v.selectedTabsoft", "contractStart");
        if(currentOrder)
            component.set("v.arrowDirection", "arrowup");
        else
            component.set("v.arrowDirection", "arrowdown");
        component.set("v.sortAsc", currentOrder);
        component.set("v.utilityAccountEnrollments", currentList);
        helper.buildData(component, helper); 
    }, 
    sortByDate: function(component, event, helper) {
        // set current selected header field on selectedTabsoft attribute.        
        component.set("v.selectedTabsoft", 'SD');
        // call the helper function with pass sortField Name      
        helper.sortHelper(component, event, 'Start_Date__c');
    },
    sortByEN: function(component, event, helper) {
        var currentOrder = component.get("v.sortAsc"),
            currentList = component.get("v.utilityAccountEnrollments");
        currentOrder = !currentOrder;
        currentList.sort(function(a,b) {
            var t1 = a.objUAE.Enrollment__r.Name == b.objUAE.Enrollment__r.Name, t2 = a.objUAE.Enrollment__r.Name < b.objUAE.Enrollment__r.Name;
            return t1? 0: (currentOrder?-1:1)*(t2?1:-1);
        });
        component.set("v.selectedTabsoft", "EN");
        if(currentOrder)
            component.set("v.arrowDirection", "arrowup");
        else
            component.set("v.arrowDirection", "arrowdown");
        component.set("v.sortAsc", currentOrder);
        component.set("v.utilityAccountEnrollments", currentList);
        helper.buildData(component, helper);
    },
    sortByProd: function(component, event, helper) {
        var currentOrder = component.get("v.sortAsc"),
            currentList = component.get("v.utilityAccountEnrollments");
        currentOrder = !currentOrder;
        currentList.sort(function(a,b) {
            var bValue;
            var aValue;
            if(a.objUAE.Enrollment__r.Product__c == undefined){
                aValue = '';
            }else{
                aValue =a.objUAE.Enrollment__r.Product__c;
            }
            if(b.objUAE.Enrollment__r.Product__c == undefined){
                bValue = '';
            }else{
                bValue = b.objUAE.Enrollment__r.Product__c;
            }
            var t1 = aValue == bValue, t2 = aValue < bValue;
            return t1? 0: (currentOrder?-1:1)*(t2?1:-1);
        });
        component.set("v.selectedTabsoft", "prod");
        if(currentOrder)
            component.set("v.arrowDirection", "arrowup");
        else
            component.set("v.arrowDirection", "arrowdown");
        component.set("v.sortAsc", currentOrder);
        component.set("v.utilityAccountEnrollments", currentList);
        helper.buildData(component, helper);
    },
    sortByCompanyName: function(component, event, helper) {
        var currentOrder = component.get("v.sortAsc"),
            currentList = component.get("v.utilityAccountEnrollments");
        currentOrder = !currentOrder;
        currentList.sort(function(a,b) {
            var t1 = a.objUAE.Enrollment__r.Account__c == b.objUAE.Enrollment__r.Account__c, t2 = a.objUAE.Enrollment__r.Account__c < b.objUAE.Enrollment__r.Account__c;
            return t1? 0: (currentOrder?-1:1)*(t2?1:-1);
        });
        component.set("v.selectedTabsoft", "compName");
        if(currentOrder)
            component.set("v.arrowDirection", "arrowup");
        else
            component.set("v.arrowDirection", "arrowdown");
        component.set("v.sortAsc", currentOrder);
        component.set("v.utilityAccountEnrollments", currentList);
        helper.buildData(component, helper);
    },
    sortByUAN: function(component, event, helper) {
        var currentOrder = component.get("v.sortAsc"),
            currentList = component.get("v.utilityAccountEnrollments");
        currentOrder = !currentOrder;
        currentList.sort(function(a,b) {
            var t1 = a.objUAE.Utility_Account__r.Name == b.objUAE.Utility_Account__r.Name, t2 = a.objUAE.Utility_Account__r.Name < b.objUAE.Utility_Account__r.Name;
            return t1? 0: (currentOrder?-1:1)*(t2?1:-1);
        });
        component.set("v.selectedTabsoft", "UAN");
        if(currentOrder)
            component.set("v.arrowDirection", "arrowup");
        else
            component.set("v.arrowDirection", "arrowdown");
        component.set("v.sortAsc", currentOrder);
        component.set("v.utilityAccountEnrollments", currentList);
        helper.buildData(component, helper);
    },
    sortCID: function(component, event, helper) {
        var currentOrder = component.get("v.sortAsc"),
            currentList = component.get("v.utilityAccountEnrollments");
        currentOrder = !currentOrder;
        currentList.sort(function(a,b) {
            var t1 = a.objUAE.Enrollment__r.Account__r.Customer_ID__c == b.objUAE.Enrollment__r.Account__r.Customer_ID__c, t2 = a.objUAE.Enrollment__r.Account__r.Customer_ID__c < b.objUAE.Enrollment__r.Account__r.Customer_ID__c;
            return t1? 0: (currentOrder?-1:1)*(t2?1:-1);
        });
        component.set("v.selectedTabsoft", "custID");
        if(currentOrder)
            component.set("v.arrowDirection", "arrowup");
        else
            component.set("v.arrowDirection", "arrowdown");
        component.set("v.sortAsc", currentOrder);
        component.set("v.utilityAccountEnrollments", currentList);
        helper.buildData(component, helper);
    },
    //We are not sorting by Market rate code
    sortByMRC: function(component, event, helper) {
        var currentOrder = component.get("v.sortAsc"),
            currentList = component.get("v.utilityAccountEnrollments");
        currentOrder = !currentOrder;
        currentList.sort(function(a,b) {
            var t1 = a.objUAE.Utility_Account__r.Market_Rate_Code__c == b.objUAE.Utility_Account__r.Market_Rate_Code__c, t2 = a.objUAE.Utility_Account__r.Market_Rate_Code__c < b.objUAE.Utility_Account__r.Market_Rate_Code__c;
            return t1? 0: (currentOrder?-1:1)*(t2?1:-1);
        });
        component.set("v.selectedTabsoft", "MRC");
        if(currentOrder)
            component.set("v.arrowDirection", "arrowup");
        else
            component.set("v.arrowDirection", "arrowdown");
        component.set("v.sortAsc", currentOrder);
        component.set("v.utilityAccountEnrollments", currentList);
        helper.buildData(component, helper);
    },
    saveStatus: function (component, event, helper) {
        $A.util.removeClass(component.find("RSNSpinner"), "slds-show");
        var index = event.getSource().get("v.name");
        
        var currPage = component.get("v.currentPageNumber");
        var pageSize = component.get("v.pageSize");
        
        if(currPage > 1){
            index = (currPage - 1) * pageSize + index;
        }
        var updatedUAE =[];
        var UAE = component.get("v.utilityAccountEnrollments");
        UAE[index].editStatus = false;
        UAE[index].editPC = false;
        UAE[index].editTEC = false;
        UAE[index].editTET = false;
        UAE[index].editHoldReasonCode = false;
        UAE[index].editHoldTransaction = false;
        UAE[index].editEffectiveDate = false;
        UAE[index].editPercentage = false;
        UAE[index].editTEC_Number = false;
        UAE[index].editTax_Exempt = false;
        
        if(UAE[index].objUAE.Tax_Exempt_Type__c == '--None--'){
            UAE[index].objUAE.Tax_Exempt_Type__c = null;
        }
        
        if(UAE[index].objUAE.Hold_Transaction__c){
            UAE[index].invalidDate = false;
        }
        if(UAE[index].objUAE.Hold_Reason_Code__c != null){
            UAE[index].invalidDate = false;
        }
        
        updatedUAE.push(UAE[index].objUAE);
        component.set("v.PaginationList", UAE);
        var action = component.get("c.saveUAE");
        action.setParams({  
            "objUAE" : updatedUAE
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS"){
                component.set("v.changedCheckbox",false);
                if(response.getReturnValue() != 'success')
                    component.set("v.errorMessage", response.getReturnValue());
                else{
                    
                    component.set("v.utilityAccountEnrollments", UAE);
                }
                $A.util.addClass(component.find("RSNSpinner"), "slds-hide");
                component.set("v.ApplyDisable", false);
                component.find("selectAllCheckbox").set("v.value", false);    
            }
        });
        $A.enqueueAction(action); 
    },
    editStatus: function (component, event, helper) {
        var index = event.getSource().get("v.name");
        var currPage = component.get("v.currentPageNumber");
        var pageSize = component.get("v.pageSize");
        if(currPage > 1){
            index = (currPage - 1) * pageSize + index;
        }
        var UAE = component.get("v.utilityAccountEnrollments");
        UAE[index].editStatus = !UAE[index].editStatus;
        component.set("v.utilityAccountEnrollments", UAE);
        helper.buildData(component, helper);
    },
    
    //Changes 18/05/2022 by Somanshu SU-841
    showtooltip : function(component, event, helper) {
        var target = event.getSource(); 
        console.log('target==>> '+target);
        var txtVal = target.get("v.alternativeText") ;
        //alert('Event'+txtVal);
        console.log('txtVal==>> '+txtVal);
        component.set("v.hoverRow", txtVal);
        component.set("v.showModal1", true);
    },
    hidetooltip : function(component, event, helper) {
        component.set("v.hoverRow", -1);
    },
    openFilterModal :function(component, event, helper){
        console.log("column="+event.getSource().get("v.value"));
        component.set("v.selectedColumn", event.getSource().get("v.value"));
        component.set("v.selectedColumnName", event.getSource().get("v.name"));
        component.set("v.openFilterModal", false);
        console.log('buttonClick')
        component.set("v.openFilterModal", true);
    },
    handleCmpEvent: function(component, event, helper) {
        var selecteValues1 = event.getParam("selectedValues");
        var columnName = component.get("v.selectedColumnName");
        var nameofcol = component.get("v.selectedColumn");
        var selecteValues =[]
        for(var element of  selecteValues1){
            if(typeof element !== 'undefined'){
                var temp = element.split('=');
                if(temp[0] === nameofcol ){
                    var templist = temp[1].split(',');
                    for(var ele of templist){
                       if(ele.includes("'")){
                            var regex = new RegExp("'","g");
                            ele = ele.replace(regex, "\\'");
                            selecteValues.push(ele);
                        }
                        else{
                            selecteValues.push(ele);
                        }
                    }
                } 
            }
            
            
        }
        
        component.set("v.SelectedData",selecteValues1);
        
        
                      
        var templist = columnName.split(",");
        var dataType = templist[1];
        var finalQuery = component.get("v.sQuery");
        var allWhereList ;
        var query;
        if(finalQuery !== null)
        {
            for(var i = 0; i < finalQuery.length; i++ ){
                if(typeof finalQuery[i] !== 'undefined' ){
                    if(finalQuery[i].includes(nameofcol)){
                        delete finalQuery[i];
                    }
                }
            }
        }
        else{
            finalQuery = [];
		}
        
        
        helper.showSpinner(component);
        component.set('v.utility', $A.get("{!$Label.c.National_Grid_Utility_Id}"));
        var action = component.get("c.getStartDateUAEs");
        action.setParams({  
            "selectedGroup" :component.find('selectGroup').get('v.value'),
            "selectedFilter":component.find('select').get('v.value'),
            "fromDate1" : component.get('v.fromDate'),
            "toDate1" : component.get('v.toDate'),
            "dateColumnName" : component.get('v.selectedDateColumn'),
            "selecteValues": selecteValues,
            "columnNameAndDataType": columnName,
            "allFilters": component.get('v.sQuery')
        });
        console.log('params set');
        action.setCallback(this,function(response){
            var state = response.getState();
            console.log('state='+state);
            if (state === "SUCCESS"){
                helper.hideSpinner(component);
                var resp = response.getReturnValue();
                component.set("v.currentPageNumber",1);
                component.set("v.totalRecordsCount", response.getReturnValue().length);
                component.set("v.utilityAccountEnrollments", response.getReturnValue());
                component.set('v.BatchData', response.getReturnValue());
                component.set("v.PaginationList",response.getReturnValue());
                component.set("v.ContractSignedDate", resp[0].contractSignedDate);
                component.set("v.warnMessage", resp[0].errorMsg);
                component.set("v.pageSize", 10);
                component.set("v.hasSelectedUAE",false);
                helper.buildData(component, helper);
                
                // var a = component.get('c.sortByCD');
                // $A.enqueueAction(a);
            }else{
                
            }
        });
        $A.enqueueAction(action); 
        if(selecteValues.length > 0 ){
            
            if(dataType === 'integer'){
                allWhereList = '('; 
                for (const element of selecteValues) {
                    
                    allWhereList= allWhereList.concat(element, ",");
                    
                    
                }
                allWhereList= allWhereList.substring(0, allWhereList.length - 1);
                allWhereList= allWhereList.concat(')');
                query = nameofcol.concat(" in ",allWhereList);
            }
            else if(dataType === 'string' ){
                allWhereList = '(';
                for (const element of selecteValues) {
                    
                    var temp ="'";
                    var temp1= temp.concat(element,"'");  
                    allWhereList= allWhereList.concat(temp1, ",");
                    
                    
                }
                allWhereList= allWhereList.substring(0, allWhereList.length - 1);
                allWhereList= allWhereList.concat(')');
                query = nameofcol.concat(" in ",allWhereList);
            }
                else if(dataType === 'boolean'){
                    query = nameofcol.concat("=",selecteValues[0])
                }
            
            finalQuery.push(query);
            component.set("v.sQuery",finalQuery );
            console.log('squery'+component.get('v.sQuery'))
        }
    },
    resetFilter: function (component, event, helper){
        var dataresponse;
        component.set('v.fromDate',null);
        component.set('v.toDate',null);
        component.set('v.selectedDateColumn',null);
        component.set("v.SelectedData",null);
        component.set("v.sQuery",null);
        component.set("v.spinner", true);
        component.set('v.utility', $A.get("{!$Label.c.National_Grid_Utility_Id}"));
        var action = component.get("c.getFilteredUAEs");
        action.setParams({  
            "enrollemtStatus" : "defaultUAEs",
            "isDoinIt" : true
        });
        action.setCallback(this,function(response){
            var state = response.getState();
            if (state === "SUCCESS"){
                var resp = response.getReturnValue();
                if(resp == ''){
                    component.set("v.spinner", false); 
                }
                dataresponse = response.getReturnValue();
                component.set("v.totalRecordsCount", response.getReturnValue().length);
                component.set("v.utilityAccountEnrollments", response.getReturnValue());
                component.set('v.BatchData', response.getReturnValue());
                component.set("v.PaginationList",response.getReturnValue());
                console.log('v.PaginationL-->> '+JSON.stringify(response.getReturnValue()));
                component.set("v.ContractSignedDate", resp[0].contractSignedDate);
                component.set("v.warnMessage", resp[0].errorMsg);
                component.set("v.pageSize",10);
                component.set("v.sortAsc",resp[0].checkCurrentSortOrder);
                var usrOpts = response.getReturnValue()[0].userOptions;
                component.set("v.prvSelectedOptions",usrOpts);
                if(usrOpts.includes("enrollmentID")){
                    component.set("v.selectedOptBoolean",true);
                }
                if(usrOpts.includes("customerID")){
                    component.set("v.selectedOptBoolean1",true);
                }
                if(usrOpts.includes("contract")){
                    component.set("v.selectedOptBoolean2",true);
                }
                if(usrOpts.includes("contractSignedDate")){
                    component.set("v.selectedOptBoolean3",true);
                }
                if(usrOpts.includes("billType")){
                    component.set("v.selectedOptBoolean4",true);
                }
                if(usrOpts.includes("product")){
                    component.set("v.selectedOptBoolean5",true);
                }
                if(usrOpts.includes("companyName")){
                    component.set("v.selectedOptBoolean6",true);
                }
                if(usrOpts.includes("utility")){
                    component.set("v.selectedOptBoolean7",true);
                }
                if(usrOpts.includes("utilityAccountNumber")){
                    component.set("v.selectedOptBoolean8",true);
                }
                if(usrOpts.includes("contractStart")){
                    component.set("v.selectedOptBoolean9",true);
                }
                if(usrOpts.includes("contractTerm")){
                    component.set("v.selectedOptBoolean10",true);
                }
                if(usrOpts.includes("rateAmount")){
                    component.set("v.selectedOptBoolean11",true);
                }
                if(usrOpts.includes("taxExempt")){
                    component.set("v.selectedOptBoolean12",true);
                }
                if(usrOpts.includes("customerType")){
                    component.set("v.selectedOptBoolean13",true);
                }
                if(usrOpts.includes("avgMeterReadDate")){
                    component.set("v.selectedOptBoolean14",true);
                }
                if(usrOpts.includes("broker")){
                    component.set("v.selectedOptBoolean15",true);
                }
                if(usrOpts.includes("accountOwner")){
                    component.set("v.selectedOptBoolean16",true);
                }
                if(usrOpts.includes("marketRateCode")){
                    component.set("v.selectedOptBoolean17",true);
                }
                if(usrOpts.includes("Status")){
                    component.set("v.selectedOptBoolean18",true);
                }
                if(usrOpts.includes("serviceAddress")){
                    component.set("v.selectedOptBoolean19",true);
                }
                if(usrOpts.includes("serviceClass")){
                    component.set("v.selectedOptBoolean20",true);
                }
                if(usrOpts.includes("taxablePortion")){
                    component.set("v.selectedOptBoolean21",true);
                }
                if(usrOpts.includes("autoSubmitFlag")){
                    component.set("v.selectedOptBoolean22",true);
                }
                if(usrOpts.includes("rateClass")){
                    component.set("v.selectedOptBoolean23",true);
                }
                var a = component.get('c.sortByEN');
                $A.enqueueAction(a);
                component.set("v.spinner", false);
                
            }else{
                component.set("v.spinner", false);
                alert('Apex CPU Limit Exceeded');
            }
            helper.ValidationMessages(component,dataresponse);
        });
        $A.enqueueAction(action);
    },
    dateFilterModal: function(component, event,helper ){
        component.set("v.dateFilterModal", true);
        component.set("v.selectedDateColumn",event.getSource().get("v.value"));
        component.set("v.nameOfColumn",event.getSource().get("v.name"));
    }
    
})