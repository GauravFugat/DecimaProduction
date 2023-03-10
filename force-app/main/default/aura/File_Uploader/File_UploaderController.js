/***************************************************************************************************************************
* Name:        File_UploaderController
* Description: Controller for File_Uploader Component 
* 
* Version History
* Date             Developer               Comments
* ---------------  --------------------    --------------------------------------------------------------------------------
* 2019-11-04       Aress Dev               	Selects the file and check whether it is csv file or not. 
****************************************************************************************************************************/

({
   /* doInit: function(component, event, helper) {
         var checkCmp = component.find("tglbtn").set("v.checked");
        component.set("v.chkboxvalue",true);
    },*/
    
     handleUpload: function (component, event, helper) {
        // Get the list of uploaded files
        var uploadedFiles = event.getParam("files");
        //alert("Files uploaded : " + uploadedFiles.length);
        
        // To get the file name
        uploadedFiles.forEach(file => helper.ProcessData(component, file.documentId));      
        
        //Call methodTwo from methodone
        //var action = component.get('c.methodTwo');
        //$A.enqueueAction(action);
        
        
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
            console.log('file==>> '+file);
            console.log('file JSON==>> '+JSON.stringify(file));
            if (file) {
                var reader = new FileReader();
                reader.readAsText(file, "UTF-8");
                reader.onload = function (evt) {
                    var csv = evt.target.result; 
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
    getToggleButtonValue:function(component,event,helper){
        var checkCmp = component.find("tglbtn").get("v.checked");
        component.set("v.chkboxvalue",checkCmp);
        //alert(component.get("v.chkboxvalue"));

    },
 	getToggleButtonValueFile:function(component,event,helper){
        var checkCmp = component.find("tglbtnFile").get("v.checked");
        component.set("v.chkboxvalueFile",checkCmp);
        //alert(component.get("v.chkboxvalue"));

    },
})