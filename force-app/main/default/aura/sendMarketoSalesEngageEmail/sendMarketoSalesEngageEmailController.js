({
    myAction : function(component) {
        var name = component.get("v.recordObject.Name");
        var id = component.get("v.recordObject.Id");
        var encodedEmail = encodeURIComponent(component.get("v.recordObject.Email"));
        var objectType = component.get("v.sobjecttype");
        var url = "https://toutapp.com/pitches/new?name=" + name +
                "&email=" + encodedEmail +
                "&salesforce_" + objectType.toLowerCase() + "_id=" + id +
                "&force_bookmarklet=true&style=salesforce";
        var w = window;
        var height = w.screen.height < 970 ? w.screen.height : 970;
        w.open(url,'Send Marketo Sales Connect Email','scrollbars=1,status=1,width=762,height=' + height);
    }
})