({
    doInit : function(component, event, helper) {
        //alert("In New Comp");
        var myPageRef = component.get("v.pageReference");
        var propertyValue = myPageRef.state.c__acctId;
        //alert(JSON.stringify(propertyValue));
        component.set("v.accId", propertyValue.acctId);
    }
})