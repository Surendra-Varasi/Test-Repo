({
    doInit : function(component, event, helper) {
        var myPageRef = component.get("v.pageReference");
        var propertyValue = myPageRef.state.c__acctId;
        //alert(JSON.stringify(propertyValue));
        component.set("v.accId", propertyValue.acctId);
        //alert(component.get("v.accId"));
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