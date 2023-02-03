({
	helperMethod : function() {
		
	},
    ApplyFilterHelper : function(component,event,helper){
        var selectedValues = component.get("v.selectedValues");
        console.log('selectedValues :'+JSON.stringify(selectedValues));
        var selectedList = [];
        var columnName  = component.get("v.SelectedColumn");
        console.log('columnName child'+columnName);
        for (var j=0; j<selectedValues.length; j++){
            var c = selectedValues[j];
            
            if(c.isSelected)
            {
                selectedList.push(c.label);
            }
        }
        var previousValues =[];
        var templist = component.get('v.previousValues');
        if(templist !== null){
            for(var element of templist){
                if(typeof element !== 'undefined'){
                    var temp = element.split('=');
                    previousValues.push(element);
                }
                
            }
        }
        
        var updatedselectedList = columnName.concat('=');
        
        for (var element of selectedList ){
            
            updatedselectedList = updatedselectedList.concat(element,',')
        }
        updatedselectedList = updatedselectedList.substring(0, updatedselectedList.length-1);
        console.log('updatedselectedList='+updatedselectedList);
        
        for(var i=0; i<previousValues.length ; i++){
            var temp = previousValues[i].split('=');
            var tempcurrent = updatedselectedList.split('=');
            if(temp[0] === tempcurrent[0] ){
                delete previousValues[i];
            }
        }
        if(selectedList.length > 0){
            previousValues.push(updatedselectedList);
        }        
        
        var compEvent = component.getEvent("compEvent");
        compEvent.setParams({
            "selectedValues" : previousValues,
            "selectedColumn" : columnName
        });
        compEvent.fire();
    },
})