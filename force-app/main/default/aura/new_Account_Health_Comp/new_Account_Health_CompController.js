({
    doInit : function(component, event, helper) {
        var myPageRef = component.get("v.pageReference");
        var propertyValue = myPageRef.state.varasi_am__acctId;
        //alert(JSON.stringify(propertyValue));
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