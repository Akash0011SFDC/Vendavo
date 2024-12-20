public with sharing class OpportunityMarketoController {
    @AuraEnabled
    public static String serverGetAttributesForEmail(String id) {
        Map<String, Object> response = new Map<String, Object>();

        List<OpportunityContactRole> opportunityContactRoles = getContactRoles(id);

        String name = '';
        String email = '';
        String contactId = '0';
        String [] cc = new List<String>();

        for (OpportunityContactRole opportunityContactRole: opportunityContactRoles) {
            if (opportunityContactRole.IsPrimary) {
                name = opportunityContactRole.Contact.Name;
                email = opportunityContactRole.Contact.Email;
                contactId = opportunityContactRole.Contact.Id;
            } else {
                cc.add(opportunityContactRole.Contact.Email);
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

        List<OpportunityContactRole> opportunityContactRoles = getContactRoles(id);

        String [] contactIds = new List<String>();

        for (OpportunityContactRole opportunityContactRole: opportunityContactRoles) {
            contactIds.add(opportunityContactRole.ContactId);
        }

        response.put('contactIds', contactIds);

        return JSON.serialize(response);
    }

    private static List<OpportunityContactRole> getContactRoles(String opportunityId) {
        return [SELECT c.Id, c.Name, c.Email, isPrimary, Role FROM OpportunityContactRole o, o.Contact c WHERE OpportunityId = :opportunityId];
    }
}