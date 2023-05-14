public with sharing class ContactTriggerHandler extends TriggerHandler {

    private static Boolean UPDATING_SHARES = false;

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
        updateContactsShare(newList);
    }

    public override void afterDelete() {
        updateContactsShare(oldList);
    }

    public override void afterUndelete() {
        updateContactsShare(newList);
    }

    private static void updateContactsShare(List<Contact> contacts) {
        if (UPDATING_SHARES) return;
        if (contacts.isEmpty()) return;

        UPDATING_SHARES = true;
        Set<Id> accountIds = new Set<Id>();
        for (Contact c : contacts) {
            accountIds.add(c.AccountId);
        }

        AccountsService.updateContactsShare(accountIds);
        UPDATING_SHARES = false;
    }
}
