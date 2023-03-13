({
    doInit : function(component, event, helper) {
        //alert('1');
        var action = component.get('c.getMetaData');
        action.setCallback(this, function (response) {
            var state = response.getState();
            //alert(state);
            if (state === 'SUCCESS') {
                var data = response.getReturnValue();
                component.set("v.configRecs",data);
                //alert(JSON.stringify(component.get("v.configRecs")));
                var componentName = 'c:related_Account_Health';
        //alert(JSON.stringify(componentName));
        
            }
            
        });
        $A.enqueueAction(action);
        
    },

    redirectConfig: function(component, event, helper) {
        var rectarget = event.getParam("id");
        alert(rectarget+ '-->'+ component.find('account_Budget_Datatable'));
        var body = component.find(rectarget).get("v.body");
        body.length = 0;
        var componentName = 'varasi_am:'+rectarget;
        //alert(JSON.stringify(componentName));
        $A.createComponent(
            componentName,
            {
                "recordId" : component.get("v.recordId")
            },
            function (newButton, status, errorMessage) {
                //Add the new button to the body array
                if (status === "SUCCESS") {
                    body.push(newButton);
                    component.find(rectarget).set("v.body", body);
                    //alert('202');
                }
                else if (status === "INCOMPLETE") {
                    console.log("No response from server or client is offline.")
                    // Show offline error
                }
                    else if (state === "ERROR") {
                        let errors = response.getError();
                        let toastParams = {
                            title: "Error",
                            message: "Unknown error", // Default error message
                            type: "error"
                        };
                        // Pass the error message if any
                        if (errors && Array.isArray(errors) && errors.length > 0) {
                            toastParams.message = errors[0].message;
                        }
                        // Fire error toast
                        let toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams(toastParams);
                        toastEvent.fire();
                    }
            }
        );
        
       
       
    }
})