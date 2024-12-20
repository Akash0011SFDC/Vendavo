({
    myAction : function(component) {
        var id = component.get("v.recordObject.Id");
        var action = component.get("c.serverGetContactsIds");
        action.setParams({ id : id });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var contactIds = JSON.parse(response.getReturnValue()).contactIds;

                if(contactIds.length > 0) {
                    // create the form. Set it up to POST the transaction
                    var f = document.createElement("form");
                    f.action = "https://toutapp.com/salesforce_bridge";
                    f.method = "post";
                    f.target = "_blank";

                    // add the idArray as a parameter
                    var i = document.createElement("input");
                    i.id = "ids";
                    i.name = "ids";
                    i.type = "hidden";
                    i.value = contactIds;
                    f.appendChild(i);

                    // add the object type
                    i = document.createElement("input");
                    i.id = "object_type";
                    i.name = "object_type";
                    i.type = "hidden";
                    i.value = "Contact";
                    f.appendChild(i);

                    // add the form to the document.
                    document.body.appendChild(f);

                    // submit the form
                    f.submit();
                }
            } else if (state === "INCOMPLETE") {
                alert("Request to Salesforce is Incomplete!");
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });

        $A.enqueueAction(action);
    }
})