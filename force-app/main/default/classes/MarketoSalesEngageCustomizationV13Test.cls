@isTest
public class MarketoSalesEngageCustomizationV13Test {
    @isTest static void testDoGet() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestUri = '/services/apexrest/marketo-sales-engage-customization-version/';
        req.httpMethod = 'GET';

        RestContext.request = req;
        RestContext.response= res;

        Test.startTest();
        String result = MarketoSalesEngageCustomizationVersion.doGet();
        Test.stopTest();
        System.assertEquals(result, '1.3');
    }
}