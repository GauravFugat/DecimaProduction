({
    doInit : function(component, event, helper){
        console.log('Inside Child');
        console.log('column='+component.get('v.SelectedColumn'));
        var columnSelected =component.get('v.SelectedColumn');
        var previousValues = component.get('v.previousValues');
        //var uaWrapper =component.get('v.PaginationList');
        var uaWrapper1 =component.get('v.GenericList');
        console.log('uaWrapper1====>'+ JSON.stringify(uaWrapper1));
        var flags = [], output = [], l = uaWrapper1.length, i;
        var utilityList = [];
        var SelectedValues = [];
        var optionList = [];
        
        for( i=0; i<l; i++) {
            
            if(columnSelected.includes("__r")){
                var columnlist = columnSelected.split(".");
                var columnName = columnlist[0];
                var lmn = uaWrapper1[i][columnName];
                var val;
                
                if(columnlist.length == 3)
                {
                    if(typeof lmn[columnlist[1]] !== 'undefined'){
                        val = lmn[columnlist[1]][columnlist[2]];
                    }
                    else continue;
                	
                }
                else if(columnlist.length == 6)
                {
                    if(typeof lmn[columnlist[1]] !== 'undefined'){
                        if(typeof lmn[columnlist[1]][columnlist[2]] !== 'undefined'){
                            if(typeof lmn[columnlist[1]][columnlist[2]][columnlist[3]] !== 'undefined'){
                                
                                if(typeof lmn[columnlist[1]][columnlist[2]][columnlist[3]][columnlist[4]] !== 'undefined'){
                                    
                                    val = lmn[columnlist[1]][columnlist[2]][columnlist[3]][columnlist[4]][columnlist[5]];
                                }
                                else continue;
                            }
                            else continue;
                            
                        }
                        else continue;
                    }
                    else continue;
                }
                else
                {
                    val = lmn[columnlist[1]];
                }
                console.log('split column='+JSON.stringify(val));
                if(typeof val !== 'undefined'){
                    if( flags[val]) continue;
                    flags[val] = true;
                    SelectedValues.push({"label":val,"isSelected":false});
                }
            }
            else
            {	
                if(typeof uaWrapper1[i][columnSelected] !== 'undefined'){
                    if( flags[uaWrapper1[i][columnSelected]]) continue;
                    flags[uaWrapper1[i][columnSelected]] = true;
                    SelectedValues.push({"label":uaWrapper1[i][columnSelected],"isSelected":false});
                }
            }
           
            //utilityList.push(uaWrapper[i]);*/
            
        }  
        if(typeof previousValues !== 'undefined' && previousValues !== null && previousValues.length > 0){
            for(var m=0; m < SelectedValues.length; m++)
            {
                for(var k=0; k < previousValues.length; k++)
                {
                    if(typeof previousValues[k] !== 'undefined'){
                    var temp = previousValues[k].split('=');
                    console.log('columnSelected='+temp[0]+columnSelected)
                    if(temp[0]===columnSelected){
                        var templist = temp[1].split(',');
                        for(var element of templist){
                            console.log('typeof SelectedValues[m].label'+ typeof SelectedValues[m].label);
                            if(typeof SelectedValues[m].label === 'number' ){
                                if(Number(element) === SelectedValues[m].label)
                                {
                                    SelectedValues[m].isSelected = true;
                                    break;
                                }
                            }
                            else{
                                if(element === SelectedValues[m].label)
                                {
                                    SelectedValues[m].isSelected = true;
                                    break;
                                }
                                else if(element === "true" && SelectedValues[m].label === true){
                                    SelectedValues[m].isSelected = true;
                                    break;
                                }else if(element === "false" && SelectedValues[m].label === false){
                                    SelectedValues[m].isSelected = true;
                                    break;
                                }
                            }
                        }
                        
                    }
                    } 
                }
            }
        }
        var check = true;
        for (var n=0; n<SelectedValues.length; n++){
            var c = SelectedValues[n];
            
            if(!c.isSelected) {
                check = false;
            }     
        }
        component.set("v.isSelectAllModalStatus",check);
        //console.log('utilityList==>'+JSON.stringify(SelectedValues));
        component.set("v.selectedValues",SelectedValues);
        //component.set("v.utilityStatusList",utilityList);
        
        component.set("v.openFilterModal", true);
    },
    closeModel: function(component, event, helper) {
        component.set("v.openFilterModal", false);
       // component.set("v.openStatusFilterModal", false);
        
    },
    myAction : function(component, event, helper) {
        
    },
    SelectAllStatusUtilities : function(component, event, helper){
        var isSelectAllModal = component.get("v.isSelectAllModalStatus");
        if(isSelectAllModal == true){
            var utilityList = component.get("v.selectedValues");
            var updatedUtilityList = [];
            for(var i=0; i<utilityList.length; i++){
                utilityList[i].isSelected = true;
                updatedUtilityList.push(utilityList[i]);
            }
            
        }
        else{
            var utilityList = component.get("v.selectedValues");
            var updatedUtilityList = [];
            for(var i=0; i<utilityList.length; i++){
                utilityList[i].isSelected = false;
                updatedUtilityList.push(utilityList[i]);
            }
        }
        
        //component.set("v.utilityStatusList",updatedUtilityList);
        component.set("v.selectedValues",updatedUtilityList);
        
    },
    handleDeSelectedStatus: function(component, event, helper) {
        component.set("v.isSelectAllModalStatus",false);
        var UAList = component.get("v.selectedValues");
        var isSelectAll = component.get("v.isSelectAll");
        
        var selectedContacts = [];
        
        if(isSelectAll){
            selectedContacts = UAList;
        }
        else{
            var k = 0;
            var check = true;
            for (var i=0; i<UAList.length; i++){
                var c = UAList[i];
                
                if(!c.isSelected) {
                    check = false;
                }     
            }
            component.set("v.isSelectAllModalStatus",check);
        }
        
    },
    ApplyFilter: function(component, event, helper) {
        component.set("v.openFilterModal", false);
        helper.ApplyFilterHelper(component, event, helper)
        
    },
})