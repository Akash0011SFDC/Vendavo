@RestResource(urlMapping='/marketo-sales-engage-customization-version')
global with sharing class MarketoSalesEngageCustomizationVersion {
    @HttpGet
    global static String doGet() {
        return '1.3';
    }
}