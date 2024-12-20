@isTest
public class ToutDataMigratorTest {
    @isTest static void testDoGetSuccess() {

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestUri = '/services/apexrest/tout-data-migrate/';
        req.httpMethod = 'GET';
        req.addParameter('total_rows', '10');
        req.addParameter('job_ids', '[]');

        RestContext.request = req;
        RestContext.response= res;

        Test.startTest();
        ToutDataMigrator.doGet();
        Test.stopTest();

        Map<String, String> expectedMap = new Map<String, String>();
        expectedMap.put('status', 'success');
        expectedMap.put('message', 'Migration completed successfully.');
        expectedMap.put('state', 'complete');

        String expected = JSON.serialize(expectedMap);

        String result = res.responseBody.toString();

        System.assertEquals(res.statusCode, 200);
        System.assertEquals(result, expected);
    }
    @isTest static void testDoGetError() {

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestUri = '/services/apexrest/tout-data-migrate/';
        req.httpMethod = 'GET';
        req.addParameter('total_rows', '10');
        req.addParameter('job_ids', 'fake');

        RestContext.request = req;
        RestContext.response= res;

        Test.startTest();
        ToutDataMigrator.doGet();
        Test.stopTest();

        System.assertEquals(res.statusCode, 200);
    }
    @isTest static void testDoPost() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestUri = '/services/apexrest/tout-data-migrate/';
        req.httpMethod = 'POST';

        RestContext.request = req;
        RestContext.response= res;

        Test.startTest();
        ToutDataMigrator.doPost();
        Test.stopTest();

        System.assertEquals(202, res.statusCode);
    }
}