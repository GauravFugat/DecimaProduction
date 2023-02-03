({
    /* doInitHelper funcation to fetch all records, and set attributes value on component load */
    doInitHelper : function(component,event,helper, fieldname){ 
        var sortDir = component.get("v.sort");
        if(sortDir == 'ASC'){
            component.set("v.arrowDirection", 'arrowdown');
            sortDir = 'DESC';
            component.set('v.sort', 'DESC');
        }
        else{
            sortDir = 'ASC';
            component.set("v.arrowDirection", 'arrowup');
            component.set('v.sort', 'ASC');
        }
        
        var action = component.get("c.fetchAccountWrapper");
        action.setParams({  
            'oppId' : component.get("v.recordId"),
            'sortType' : sortDir,
            'sortField' : fieldname,
            'isInit' : component.get("v.isInit"),
            'priceIdToPass' : component.get("v.selectedPriceId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS" && response.getReturnValue().length > 0){
                component.set("v.totalPages", Math.ceil(response.getReturnValue().length/component.get("v.pageSize")));
                component.set("v.listOfAllAccounts", response.getReturnValue());
                component.set("v.currentPageNumber",1);
                
                component.set("v.totalRecordsCount", component.get("v.listOfAllAccounts").length);
                helper.buildData(component, helper);
                var annualVolume = 0;
                var volPrice = 0;
                var allRecords = component.get("v.listOfAllAccounts");
                var selectedCount = 0;
                var loadFactor = 0;
                var avgLF;
                component.set("v.EarliestDate",allRecords[0].objAccount.Opportunity__r.Start_Date__c);
                for (var i = 0; i < allRecords.length; i++) {
                    allRecords[i].objAccount.Utility_Account__r.Load_Factor__c = allRecords[i].objAccount.Utility_Account__r.Load_Factor__c / 100;
                    if (allRecords[i].isChecked) {
                        selectedCount++;
                        annualVolume = annualVolume + allRecords[i].objAccount.Utility_Account__r.Annual_Usage_kWh__c;
                        volPrice = volPrice + (parseFloat(allRecords[i].objAccount.Utility_Account__r.Annual_Usage_kWh__c) * parseFloat(allRecords[i].objAccount.Twelve_Month_Price__c));
                        loadFactor = loadFactor + parseFloat(allRecords[i].objAccount.Utility_Account__r.Load_Factor__c);
                    }
                }
                component.set("v.selectedCount" , selectedCount);
                var TwelveMonthAveragePrice = 0;
                if(volPrice != 0 && annualVolume != 0)
                    TwelveMonthAveragePrice = volPrice/annualVolume;
                TwelveMonthAveragePrice = parseFloat(TwelveMonthAveragePrice.toFixed(5));
                component.set("v.TwelveMonthAveragePrice", TwelveMonthAveragePrice);      
                if(loadFactor != 0)
                    avgLF = loadFactor/parseFloat(component.get("v.selectedCount"));
                component.set("v.AverageLoadFactor", avgLF);
                console.log(component.get("v.AverageLoadFactor")+'expected'+avgLF);
                component.set("v.spinner", false);
            } 
            else{
                if(response.getReturnValue().length == 0){
                    component.set("v.spinner", false);
                }
                else{
                    alert('Error...');
                }
            }
        });
        $A.enqueueAction(action);  
    },
    
    getPrices: function(component, helper){
        if(component.get("v.toggleValue") == false){
            
            //alert(component.get("v.storeVolumn"));
            var action = component.get("c.getPrice");
            action.setParams({  
                'oppId' : component.get("v.recordId"),
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS"){
                    var responseList = response.getReturnValue();
                    if(responseList == ''){
                        component.set("v.confirmation", false);
                        component.set("v.priceList",null);
                    }
                    else{
                        //alert('else');
                        component.set("v.priceList",responseList);
                        // alert(component.get("v.priceList"));
                        //component.set("v.selectedPriceId1",responseList[0].priceId);
                        //alert('sel--'+JSON.stringify(response.getReturnValue()));
                        
                        //part of SU - 880
                        //alert('vv'+response.getReturnValue()[0].isCreditExp);
                         component.set("v.isCreditExpToSetWarning",response.getReturnValue()[0].isCreditExp);
                        var event = component.getEvent("createQuoteToQuoteGenerator"); 
                        //alert('response.getReturnValue().isCreditCheckExpired'+response.getReturnValue().isCreditCheckExpired);
                        //set the response value inside eventResponse of componentEvent attribute   
                        event.setParams({
                            "eventResponse" :  response.getReturnValue()[0].isCreditExp
                        }); 
                        
                        //fire the event    
                        event.fire();   
                        
                        
                        
                        component.set("v.selectedPriceId", responseList[0].priceId);
                        component.set("v.PDValue",responseList[0].PDValue);
                        component.set("v.CreditValue",responseList[0].CreditValue);
                        
                        if(responseList[0].CreditValue || responseList[0].PDValue){
                            component.set("v.showToggle",true);
                        }
                        
                        if(responseList[0].PDValue == true && responseList[0].CreditValue == false && responseList[0].SubjectToCredit == false &&  responseList[0].FailedCredit){
                            component.set("v.PDTrue",true);
                        }
                        if(responseList[0].PDValue == false && responseList[0].CreditValue == true && responseList[0].SubjectToCredit == true &&  responseList[0].FailedCredit){
                            component.set("v.PDFalse",true);
                        }
                        
                        if((responseList[0].CreditValue == true || responseList[0].SubjectToCredit == true) && responseList[0].outcome == 'Refer'){
                            component.set("v.CreditAndSubject",true);
                        }
                        
                        //alert('responseList[0].PDValue-->>>'+responseList[0].PDValue+'responseList[0].CreditValue-->>'+responseList[0].CreditValue);
                        if(responseList[0].PDValue == true && responseList[0].CreditValue == false){
                            component.set("v.toggleValue",true);
                            component.set("v.isToggleDisabled",true);
                            
                        }else if(responseList[0].CreditValue == true && responseList[0].PDValue == false){
                            component.set("v.toggleValue",false);
                            component.set("v.isToggleDisabled",true);
                        }else if(responseList[0].CreditValue == true && responseList[0].PDValue == true){
                            component.set("v.toggleValue",false);
                            component.set("v.isToggleDisabled",false);
                        }else{
                            component.set("v.toggleValue",false);
                            component.set("v.isToggleDisabled",false);
                        }
                        
                        if(responseList[0].SubjectToCredit == true && responseList[0].CreditValue == true){
                            component.set("v.isCredit",true);
                        }
                        
                        if(responseList[0].priceId && responseList[0].TwoDaysOld == true ){
                            component.set("v.checkOldPrice", true);
                            component.set("v.confirmation", false);
                            
                        }
                        else{
                            component.set("v.checkOldPrice", false);    
                            component.set("v.confirmation", true);
                        }
                        
                    }
                    component.set("v.selectedProductName", responseList[0]);
                    helper.doInitHelper(component, event,helper, 'Utility_Account__r.Name');
                    helper.DisplayPDAndCredit(component, event,helper,component.get("v.selectedPriceId"));
                }
            });
            $A.enqueueAction(action);  
        }
        // Added function to set same value for Toggle after click on Previous.
        else{
            var action = component.get("c.getPrice");
            action.setParams({  
                'oppId' : component.get("v.recordId"),
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS"){
                    var responseList = response.getReturnValue();
                    if(responseList == ''){
                        component.set("v.confirmation", false);
                        component.set("v.priceList",null);
                    }
                    else{
                        //alert('176');
                        component.set("v.priceList",responseList);
                        //component.set("v.selectedPriceId1",responseList[0]);
                        component.set("v.selectedPriceId", responseList[0].priceId);
                        
                        if(responseList[0].priceId && responseList[0].TwoDaysOld == true ){
                            component.set("v.checkOldPrice", true);
                            component.set("v.confirmation", false);
                            
                        }
                        else{
                            component.set("v.checkOldPrice", false);    
                            component.set("v.confirmation", true);
                        }
                        
                    }
                    component.set("v.selectedProductName", responseList[0]);
                    helper.doInitHelper(component, event,helper, 'Utility_Account__r.Name');
                    helper.DisplayPDAndCredit(component, event,helper,component.get("v.selectedPriceId"));
                }
            });
            $A.enqueueAction(action);  
            
        }
        
        
    },
    // navigate to next pagination record set   
    buildData : function(component, helper) {
        var data = [];
        var pageNumber = component.get("v.currentPageNumber");
        var pageSize = component.get("v.pageSize");
        if(component.get("v.showUA") == false){
            var allData = component.get("v.listOfAllAccounts");
            component.set("v.totalPages", Math.ceil( component.get("v.listOfAllAccounts").length/component.get("v.pageSize")));
        }
        if(component.get("v.showUA")){
            var allData = component.get("v.utilityAccounts");
            component.set("v.totalPages", Math.ceil( component.get("v.utilityAccounts").length/component.get("v.pageSize")));
        }
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
        component.set("v.spinner", false);
    },
    calculateAveragePrice : function(component,event,helper){
        var annualVolume = 0;
        var volPrice = 0;
        var loadFactor = 0;
        var allRecords = component.get("v.listOfAllAccounts");
        for (var i = 0; i < allRecords.length; i++) {
            if (allRecords[i].isChecked) {
                if ( allRecords[i].objAccount.Utility_Account__r.Annual_Usage_kWh__c != undefined){
                    annualVolume = annualVolume + allRecords[i].objAccount.Utility_Account__r.Annual_Usage_kWh__c;
                    volPrice = volPrice + (allRecords[i].objAccount.Utility_Account__r.Annual_Usage_kWh__c * allRecords[i].objAccount.Twelve_Month_Price__c);
                    loadFactor = loadFactor + parseFloat(allRecords[i].objAccount.Utility_Account__r.Load_Factor__c);
                }
            }
        }
        var TwelveMonthAveragePrice = 0;
        var avgLF = 0;
        if(volPrice != 0 && annualVolume != 0)
            TwelveMonthAveragePrice = volPrice/annualVolume;
        if(loadFactor != 0)
            avgLF = loadFactor/parseFloat(component.get("v.selectedCount"));
        
        TwelveMonthAveragePrice = parseFloat(TwelveMonthAveragePrice.toFixed(4));
        component.set("v.TwelveMonthAveragePrice", TwelveMonthAveragePrice);
        component.set("v.AverageLoadFactor", avgLF);
        
    },
    
    //SU 620 Created to retirve Price record values
    getPriceValues: function(component,event,helper,priceId){
        //alert(priceId);
        var action = component.get("c.getPriceValues");
        action.setParams({  
            'priceId' : priceId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS"){
                var responseList = response.getReturnValue();
                //alert(JSON.stringify(responseList));
                component.set("v.PDValue",responseList.PDValue);
                component.set("v.CreditValue",responseList.CreditValue);
                
                if(responseList.CreditValue || responseList.PDValue){
                    component.set("v.showToggle",true);
                }
                else{
                    component.set("v.showToggle",false);
                }
                
                if(responseList.PDValue == true && responseList.CreditValue == false && responseList.SubjectToCredit == false &&  responseList.FailedCredit){
                    component.set("v.PDTrue",true);
                }
                else{
                    component.set("v.PDTrue",false);
                }
                
                if(responseList.PDValue == false && responseList.CreditValue == true && responseList.SubjectToCredit == true &&  responseList.FailedCredit){
                    component.set("v.PDFalse",true);
                }
                else{
                    component.set("v.PDFalse",false);
                }
                
                if((responseList.CreditValue == true || responseList.SubjectToCredit == true) && responseList.outcome == 'Refer'){
                    component.set("v.CreditAndSubject",true);
                }
                else{
                    component.set("v.CreditAndSubject",false);
                }
                
                //  alert('responseList.PDValue-->>>'+responseList.PDValue+'responseList.CreditValue-->>'+responseList.CreditValue);
                if(responseList.PDValue == true && responseList.CreditValue == false){
                    component.set("v.toggleValue",true);
                    component.set("v.isToggleDisabled",true);
                    
                }else if(responseList.CreditValue == true && responseList.PDValue == false){
                    component.set("v.toggleValue",false);
                    component.set("v.isToggleDisabled",true);
                }else if(responseList.CreditValue == true && responseList.PDValue == true){
                    component.set("v.toggleValue",false);
                    component.set("v.isToggleDisabled",false);
                }else{
                    component.set("v.toggleValue",false);
                    component.set("v.isToggleDisabled",false);
                }
                if(responseList.SubjectToCredit == true && responseList.CreditValue == true){
                    component.set("v.isCredit",true);
                }
            } 
        });
        $A.enqueueAction(action);  
    },
    DisplayPDAndCredit: function(component,event,helper,priceId){
        var action = component.get("c.getPriceValues");
        action.setParams({  
            'priceId' : priceId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS"){
                var responseList = response.getReturnValue();
                component.set("v.Prepayment_Amount",responseList.Prepayment_Amount);
                component.set("v.Deposit_Amount",responseList.Deposit_Amount);
                
            } 
        });
        $A.enqueueAction(action);  
    }
})