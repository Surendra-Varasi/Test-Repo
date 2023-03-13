/*({
    doInit : function(component, event, helper) {
        var pageRef = component.get("v.pageReference");
        //alert("page Ref : "+JSON.stringify(pageRef));

        var state = pageRef.state;
        //alert(JSON.stringify(state));

        var base64Context = state.inContextOfRef;
        //alert('base64Context = '+base64Context);	        
        if (base64Context.startsWith("1\.")) {	            
            base64Context = base64Context.substring(2);	            
            //alert('base64Context = '+base64Context);
        }	        
        var addressableContext = JSON.parse(window.atob(base64Context));	        
        //alert('addressableContext = '+JSON.stringify(addressableContext));
        //alert(addressableContext.attributes.recordId);
        component.set("v.recordId",addressableContext.attributes.recordId)
    }
})*/

({
    doInit : function(component, event, helper) {
        var myPageRef = component.get("v.pageReference");
        var propertyValue = myPageRef.state.c__acctId;
        //alert(JSON.stringify(propertyValue));
        //alert(JSON.stringify(propertyValue.acctId))
        component.set("v.accId", propertyValue.acctId);
    },
    handleFilterChange: function(component, event) {
        var CloseClicked = event.getParam('close');
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            workspaceAPI.closeTab({tabId: focusedTabId});
        })
        .catch(function(error) {
            console.log(error);
        });
    }
})