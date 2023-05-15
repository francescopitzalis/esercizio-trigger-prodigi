public with sharing class JsonDataLoader {

    public class AccountData {
        public Integer id;
        public String name;
        public Decimal total;
    }

    public class ContactData {
        public Integer id;
        public Integer accountId;
        public String firstName;
        public String lastName;
    }

    public static void loadData(String accountsResourceName, String contactsResourceName) {
        // Retrieve the JSON strings from the static resources
        Set<String> staticResourceNames = new Set<String>{
            accountsResourceName, contactsResourceName
        };

        Map<String, String> staticResourceNameToBody = new Map<String, String>();
        for (StaticResource sr : [SELECT Name, Body FROM StaticResource WHERE Name IN :staticResourceNames]) {
            staticResourceNameToBody.put(sr.Name, sr.Body.toString());
        }

        // Deserialize the JSON strings into lists of objects
        List<AccountData> accountDataList = (List<AccountData>)
            JSON.deserialize(staticResourceNameToBody.get(accountsResourceName), List<AccountData>.class);
        List<ContactData> contactDataList = (List<ContactData>)
            JSON.deserialize(staticResourceNameToBody.get(contactsResourceName), List<ContactData>.class);

        // Create the accounts
        Map<Integer, Account> idToAccount = new Map<Integer, Account>();
        for (AccountData accountData : accountDataList) {
            Account account = new Account(
                Name = accountData.name,
                Total__c = accountData.total
            );
            idToAccount.put(accountData.id, account);
        }
        insert idToAccount.values();

        // Create the contacts
        List<Contact> contactsToInsert = new List<Contact>();
        for (ContactData contactData : contactDataList) {
            Contact contact = new Contact(
                AccountId = idToAccount.get(contactData.accountId).Id,
                FirstName = contactData.firstName,
                LastName = contactData.lastName
            );
            contactsToInsert.add(contact);
        }
        insert contactsToInsert;
    }


}
