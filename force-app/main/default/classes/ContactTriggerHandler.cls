public with sharing class ContactTriggerHandler extends TriggerHandler {

    private final List<Contact> newList;
    private final List<Contact> oldList;
    private final Map<Id, Contact> newMap;
    private final Map<Id, Contact> oldMap;

    private ContactTriggerHandler(TriggerOperation op,
                                List<Contact> newList, List<Contact> oldList,
                                Map<Id, Contact> newMap, Map<Id, Contact> oldMap) {
        super(op);
        this.newList = newList;
        this.oldList = oldList;
        this.newMap = newMap;
        this.oldMap = oldMap;
    }

    public static void handle(TriggerOperation op, List<Contact> newList, List<Contact> oldList, Map<Id, Contact> newMap, Map<Id, Contact> oldMap) {
        new ContactTriggerHandler(op, newList, oldList, newMap, oldMap).handle();
    }

    public override void afterInsert() {
        updateContactsShare(Filter.fieldChanged(newMap, oldMap, Account.Total__c));
    }

    public override void afterDelete() {

    }

    public override void afterUndelete() {

    }

    private static Map<Id, List<Contact>> groupByAccountId(List<Contact> contacts) {
        Map<Id, List<Contact>> contactsByAccountId = new Map<Id, List<Contact>>();
        for (Contact c : contacts) {
            List<Contact> contactsForAccountId = contactsByAccountId.get(c.AccountId);
            if (contactsForAccountId == null) {
                contactsForAccountId = new List<Contact>();
                contactsByAccountId.put(c.AccountId, contactsForAccountId);
            }
            contactsForAccountId.add(c);
        }
    }
}