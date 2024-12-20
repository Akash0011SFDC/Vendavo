({
    myAction : function(component) {
        var id = component.get("v.recordObject.Id");
        var action = component.get("c.serverGetAttributesForEmail");
        action.setParams({ id : id });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var accountAttrs = JSON.parse(response.getReturnValue());

                var url = "https://toutapp.com/pitches/new?name=" + accountAttrs.name +
                        "&email=" + accountAttrs.email +
                        "&salesforce_contact_id=" + accountAttrs.contactId +
                        "&salesforce_account_id=" + id +
                        "&cc=" + accountAttrs.cc.join(",") +
                        "&force_bookmarklet=true&style=salesforce"

                var w = window;
                var height = w.screen.height < 970 ? w.screen.height : 970;
                w.open(url, 'Send Marketo Sales Email', 'scrollbars=1,status=1,width=762,height=' + height);
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