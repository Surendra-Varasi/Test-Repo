({
    init: function(cmp, evt, helper) {
        var myPageRef = cmp.get("v.pageReference");
        var brRecordId = myPageRef.state.c__brRecordId;
        cmp.set("v.brRecordId", brRecordId);
        var acctId = myPageRef.state.c__acctId;
        cmp.set("v.acctId", acctId);
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