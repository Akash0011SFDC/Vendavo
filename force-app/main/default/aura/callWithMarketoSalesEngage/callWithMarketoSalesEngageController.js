({
    myAction : function(component) {
        var id = component.get("v.recordObject.Id");
        var email = encodeURIComponent(component.get("v.recordObject.Email"));
        var objectType = component.get("v.sobjecttype");
        var query_params = "sf_object=" + objectType + "&email=" + email + "&sf_id=" + id;
        var url = 'https://toutapp.com/salesforce/phone?' + query_params;

        var height = 400;
        var width = 380;
        var top = window.screenY + (window.outerHeight - window.innerHeight);
        var left = window.screenX + window.outerWidth - width;

        var options = 'scrollbars=1,status=1,height=' + height +
                      ',width=' + width +
                      ',top=' + top +
                      ',left=' + left;

        window.open(url, 'Call with Marketo Sales Connect', options);
    }
})