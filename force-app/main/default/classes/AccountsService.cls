public with sharing class AccountsService {

    public static void updateContactsShare(Set<Id> accountIds) {
        updateContactsShare([SELECT Id, Total__c FROM Account WHERE Id IN :accountIds]);
    }

    public static void updateContactsShare(List<Account> accounts) {
        if (accounts.isEmpty()) return;


        // Retrieve contacts and group by account
        Map<Id, List<Contact>> contactsByAccountId = new Map<Id, List<Contact>>();
        for (Contact c : [SELECT Id, AccountId FROM Contact WHERE AccountId IN :accounts]) {
            List<Contact> contactsForAccount = contactsByAccountId.get(c.AccountId);
            if (contactsForAccount == null) {
                contactsForAccount = new List<Contact>();
                contactsByAccountId.put(c.AccountId, contactsForAccount);
            }
            contactsForAccount.add(c);
        }

        Map<Id, Account> accountMap = new Map<Id, Account>(accounts);

        // Calculate shares for each account's contacts
        for (Id accountId : contactsByAccountId.keySet()) {
            Account acc = accountMap.get(accountId);
            List<Contact> childContacts = contactsByAccountId.get(accountId);
            Integer nShares = childContacts.size();

            // If total is null, set all shares to null
            if (acc.Total__c == null) {
                for (Contact c : childContacts) {
                    c.Share__c = null;
                }
                continue;
            }

            List<Decimal> shares = ShareUtils.calculateShares(acc.Total__c, nShares, 2);

            // Set shares on each contact
            for (Integer i = 0; i < nShares; i++) {
                Contact c = childContacts[i];
                c.Share__c = shares[i];
            }
        }

        // Update contacts in bulk
        List<Contact> allChildContacts = new List<Contact>();
        for (List<Contact> contactsForAccount : contactsByAccountId.values()) {
            allChildContacts.addAll(contactsForAccount);
        }

        update allChildContacts;
    }
}
