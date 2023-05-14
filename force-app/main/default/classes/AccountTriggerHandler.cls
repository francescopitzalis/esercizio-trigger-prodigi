public with sharing class AccountTriggerHandler extends TriggerHandler {

    private static final Decimal ONE_CENT = 0.01;

    private final List<Account> newList;
    private final List<Account> oldList;
    private final Map<Id, Account> newMap;
    private final Map<Id, Account> oldMap;

    private AccountTriggerHandler(TriggerOperation op,
                                List<Account> newList, List<Account> oldList,
                                Map<Id, Account> newMap, Map<Id, Account> oldMap) {
        super(op);
        this.newList = newList;
        this.oldList = oldList;
        this.newMap = newMap;
        this.oldMap = oldMap;
    }

    public static void handle(TriggerOperation op, List<Account> newList, List<Account> oldList, Map<Id, Account> newMap, Map<Id, Account> oldMap) {
        new AccountTriggerHandler(op, newList, oldList, newMap, oldMap).handle();
    }

    public override void afterUpdate() {
        updateContactsShare(Filter.fieldChanged(newMap, oldMap, Account.Total__c));
    }

    private void updateContactsShare(List<Account> accounts) {
        if (accounts.isEmpty()) return;

        Map<Id, List<Contact>> contactsByAccountId = new Map<Id, List<Contact>>();
        for (Contact c : [SELECT Id, AccountId FROM Contact WHERE AccountId IN :accounts]) {
            List<Contact> contactsForAccount = contactsByAccountId.get(c.AccountId);
            if (contactsForAccount == null) {
                contactsForAccount = new List<Contact>();
                contactsByAccountId.put(c.AccountId, contactsForAccount);
            }
            contactsForAccount.add(c);
        }

        for (Id accountId : contactsByAccountId.keySet()) {
            Account acc = newMap.get(accountId);
            List<Contact> childContacts = contactsByAccountId.get(accountId);
            Integer nShares = childContacts.size();

            if (acc.Total__c == null) {
                for (Contact c : childContacts) {
                    c.Share__c = null;
                }
                continue;
            }

            List<Decimal> shares = calculateShares(acc.Total__c, nShares);

            for (Integer i = 0; i < nShares; i++) {
                Contact c = childContacts[i];
                c.Share__c = shares[i];
            }
        }

        List<Contact> allChildContacts = new List<Contact>();
        for (List<Contact> contactsForAccount : contactsByAccountId.values()) {
            allChildContacts.addAll(contactsForAccount);
        }

        update allChildContacts;
    }

    private static List<Decimal> calculateShares(Decimal total, Integer nShares) {
        List<Decimal> shares = new List<Decimal>();
        Decimal share = total.divide(nShares, 2);
        for (Integer i = 0; i < nShares; i++) {
            shares.add(share);
        }

        Decimal remainder = total - (share * nShares);

        // Distribute the remainder, that can also be negative
        for (Integer i = 0; remainder != 0; i++) {
            if (remainder > 0) {
                shares[i] += ONE_CENT;
                remainder -= ONE_CENT;
            } else if (remainder < 0) {
                shares[i] -= ONE_CENT;
                remainder += ONE_CENT;
            }
        }

        return shares;
    }
}
