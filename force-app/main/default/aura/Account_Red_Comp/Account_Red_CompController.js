({
    handleOnSubmit : function(component, event, helper) {
        event.preventDefault();
        //alert("Submit");
        var newCase = component.get("v.newCase");
        if(newCase){
            component.find("caseForm").submit();
            //alert("Success");
        }        
        var eventFields = event.getParam("fields");
        //alert(JSON.stringify(eventFields));
        if(eventFields.varasi_am__Is_Red_Account__c){
            var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
            //alert(today);
            eventFields["varasi_am__Red_Date__c"] = today;
        }
        //alert(JSON.stringify(eventFields));
        component.find("accForm").submit(eventFields);
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
    },

    // handleSuccess: function(cmp, event, helper) {
    //     alert("Success");
    //     component.find("caseForm").submit();
    // },

    changeRed : function(component, event, helper) {
        let newValue =  event.getSource().get("v.value") ;
        if(newValue){
            component.set("v.case",newValue);
            //alert(newValue);
        }
    },

    changeCase : function(component, event, helper) {
        let newValue =  event.getSource().get("v.value") ;
        if(newValue){
            component.set("v.newCase",newValue);
            //alert(newValue);
        }
    },

    // saveClick : function(component, event, helper) {
    //     // var eventFields = event.getParam("fields");
    //     // var today = new Date();
    //     // var d = helper.formatLocale(today);
    //     // eventFields["varasi_am__Red_Date__c"] = d;
    //     // event.setParam("fields", eventFields);
    //     component.find("accForm").submit();
    // },

    cancelClick : function(component, event, helper) {
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
    }

})