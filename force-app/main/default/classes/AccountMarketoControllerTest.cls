@isTest
public class AccountMarketoControllerTest {
    @isTest static void testServerGetAttributesForEmail() {
        Account acct = new Account(Name='Test Account');
        insert acct;
        Contact contact1 = new Contact(LastName='Test Contact 1',
                                       email= 'test@contact1.com',
                                       AccountId=acct.Id);
        insert contact1;
        Contact contact2 = new Contact(LastName= 'Test Contact 2',
                                       email= 'test@contact2.com',
                                       AccountId=acct.Id);
        insert contact2;

        Test.startTest();
        String result = AccountMarketoController.serverGetAttributesForEmail(acct.Id);
        Test.stopTest();

        String[] cc = new List<String>();
        cc.add('test@contact2.com');

        Map<String, Object> validMap = new Map<String, Object>();
        validMap.put('name', 'Test Contact 1');
        validMap.put('email', 'test@contact1.com');
        validMap.put('contactId', contact1.Id);
        validMap.put('cc', cc);

		String valid = JSON.serialize(validMap);

        System.assertEquals(valid, result);
    }
    @isTest static void testServerGetContactsIds() {
        Account acct = new Account(Name='Test Account');
        insert acct;
        Contact contact1 = new Contact(LastName='Test Contact 1',
                                       email= 'test@contact1.com',
                                       AccountId=acct.Id);
        insert contact1;
        Contact contact2 = new Contact(LastName= 'Test Contact 2',
                                       email= 'test@contact2.com',
                                       AccountId=acct.Id);
        insert contact2;

        Test.startTest();
        String result = AccountMarketoController.serverGetContactsIds(acct.Id);
        Test.stopTest();

        Map<String, Set<String>> parsedResponse = (Map<String, Set<String>>)
            JSON.deserialize(result, Map<String, Set<String>>.class);
        Set<String> parsedIds = parsedResponse.get('contactIds');

        Set<String> contactIds = new Set<String>();
        contactIds.add(contact1.Id);
        contactIds.add(contact2.Id);

        System.assertEquals(contactIds, parsedIds);
    }
}