public with sharing class AccountMarketoController {
    @AuraEnabled
    public static String serverGetAttributesForEmail(String id) {
        Map<String, Object> response = new Map<String, Object>();

        List<Contact> contacts = getContacts(id);

        String name = '';
        String email = '';
        String contactId = '0';
        String [] cc = new List<String>();

        for (Integer i = 0; i < contacts.size(); i = i + 1) {
            if (i == 0) {
                name = contacts[i].Name;
                email = contacts[i].Email;
                contactId = contacts[i].Id;
            } else {
                cc.add(contacts[i].Email);
            }
        }

        response.put('name', name);
        response.put('email', email);
        response.put('contactId', contactId);
        response.put('cc', cc);

        return JSON.serialize(response);
    }

    @AuraEnabled
    public static String serverGetContactsIds(String id) {
        Map<String, Object> response = new Map<String, Object>();

        List<Contact> contacts = getContacts(id);

        String [] contactIds = new List<String>();

        for (Contact contact: contacts) {
            contactIds.add(contact.Id);
        }

        response.put('contactIds', contactIds);

        return JSON.serialize(response);
    }

    private static List<Contact> getContacts(String accountId) {
        return [SELECT Id, Name, Email FROM Contact WHERE AccountId = :accountId];
    }
}