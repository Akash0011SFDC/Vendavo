({
    myAction : function(component) {
        var f = document.createElement("form");
        f.action="https://toutapp.com/salesforce_bridge";
        f.method = "post";
        f.target = "_blank";

// Get the Object IDs that were checked
        var id = component.get("v.recordObject.Id");
        var idArray = [id];
        var objectType = component.get("v.sobjecttype");
        if(idArray.length > 0) {
            // add the idArray as a parameter
            var i = document.createElement("input");
            i.id = "ids";
            i.name = "ids";
            i.type = "hidden";
            i.value = idArray;
            f.appendChild(i);

            // add the object type
            i = document.createElement("input");
            i.id = "object_type";
            i.name = "object_type";
            i.type = "hidden";
            i.value = objectType;
            f.appendChild(i);

            // add the form to the document.
            document.body.appendChild(f);

            // submit the form
            f.submit();
        } else {
            alert("Please select at least one " + objectType + " to push to Marketo Sales.");
        }
    }
})