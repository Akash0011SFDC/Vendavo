@isTest
public class OpportunityMarketoControllerTest {
    @isTest static void testServerGetAttributesForEmail() {
        Opportunity opp = new Opportunity(StageName='Prospecting',
                                          CloseDate=Date.today(),
                                          Name='Test Account');
        insert opp;
        Contact contact1 = new Contact(LastName='Test Contact 1',
                                       email= 'test@contact1.com');
        insert contact1;
        Contact contact2 = new Contact(LastName= 'Test Contact 2',
                                       email= 'test@contact2.com');
        insert contact2;
		OpportunityContactRole opportunityContactRole1 =
			new OpportunityContactRole(IsPrimary=true,
                                       ContactId=contact1.Id,
                                       OpportunityId=opp.Id);
        insert opportunityContactRole1;
		OpportunityContactRole opportunityContactRole2 =
			new OpportunityContactRole(IsPrimary=false,
                                       ContactId=contact2.Id,
                                       OpportunityId=opp.Id);
        insert opportunityContactRole2;

        Test.startTest();
        String result = OpportunityMarketoController.serverGetAttributesForEmail(opp.Id);
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
        Opportunity opp = new Opportunity(StageName='Prospecting',
                                          CloseDate=Date.today(),
            							  Name='Test Account');
        insert opp;
        Contact contact1 = new Contact(LastName='Test Contact 1',
                                       email= 'test@contact1.com');
        insert contact1;
        Contact contact2 = new Contact(LastName= 'Test Contact 2',
                                       email= 'test@contact2.com');
        insert contact2;
		OpportunityContactRole opportunityContactRole1 =
			new OpportunityContactRole(IsPrimary=true,
                                       ContactId=contact1.Id,
                                       OpportunityId=opp.Id);
        insert opportunityContactRole1;
		OpportunityContactRole opportunityContactRole2 =
			new OpportunityContactRole(IsPrimary=false,
                                       ContactId=contact2.Id,
                                       OpportunityId=opp.Id);
        insert opportunityContactRole2;

        Test.startTest();
        String result = OpportunityMarketoController.serverGetContactsIds(opp.Id);
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