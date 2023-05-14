@IsTest
private class ContactTriggerTest {

    private class ContactShareTest {

        private Decimal accountTotal;
        private Integer initialContactsCount;
        private List<Decimal> expectedSharesBefore;
        private Integer nContactsToInsert = 0;
        private Integer nContactsToDelete = 0;
        private Integer nContactsToUndelete = 0;
        private List<Decimal> expectedSharesAfter;

        private ContactShareTest accountTotal(Decimal accountTotal) {
            this.accountTotal = accountTotal;
            return this;
        }

        private ContactShareTest initialContactsCount(Integer initialContactsCount) {
            this.initialContactsCount = initialContactsCount;
            return this;
        }

        private ContactShareTest expectedSharesBefore(List<Decimal> expectedSharesBefore) {
            this.expectedSharesBefore = expectedSharesBefore;
            return this;
        }

        private ContactShareTest insertNContacts(Integer nContactsToInsert) {
            this.nContactsToInsert = nContactsToInsert;
            return this;
        }

        private ContactShareTest deleteNContacts(Integer nContactsToDelete) {
            this.nContactsToDelete = nContactsToDelete;
            return this;
        }

        private ContactShareTest undeleteNContacts(Integer nContactsToUndelete) {
            this.nContactsToUndelete = nContactsToUndelete;
            return this;
        }

        private ContactShareTest expectedSharesAfter(List<Decimal> expectedSharesAfter) {
            this.expectedSharesAfter = expectedSharesAfter;
            return this;
        }

        private void run() {
            Account account = new Account(Name = 'Test Account', Total__c = accountTotal);
            insert account;

            List<Contact> initialContacts = new List<Contact>();
            for (Integer i = 0; i < initialContactsCount; i++) {
                initialContacts.add(new Contact(AccountId = account.Id, LastName = 'Test Contact ' + i));
            }
            insert initialContacts;

            assertShares(expectedSharesBefore, [SELECT Share__c FROM Contact WHERE AccountId = :account.Id]);

            List<Contact> contactsToInsert = new List<Contact>();
            for (Integer i = 0; i < nContactsToInsert; i++) {
                contactsToInsert.add(new Contact(AccountId = account.Id, LastName = 'Test Contact ' + (initialContactsCount + i)));
            }
            insert contactsToInsert;

            List<Contact> contactsToDelete = new List<Contact>();
            for (Integer i = 0; i < nContactsToDelete; i++) {
                contactsToDelete.add(initialContacts[i]);
            }
            delete contactsToDelete;

            List<Contact> contactsToUndelete = new List<Contact>();
            for (Integer i = 0; i < nContactsToUndelete; i++) {
                contactsToUndelete.add(initialContacts[i]);
            }
            undelete contactsToUndelete;

            assertShares(expectedSharesAfter, [SELECT Share__c FROM Contact WHERE AccountId = :account.Id]);
        }

        private void assertShares(List<Decimal> expectedShares, List<Contact> actualContacts) {
            List<Decimal> actualShares = new List<Decimal>();
            for (Contact c : actualContacts) {
                actualShares.add(c.Share__c);
            }

            System.debug('actualShares: ' + actualShares);
            System.debug('expectedShares: ' + expectedShares);

            List<Decimal> expectedSharesCopy = new List<Decimal>(expectedShares);

            for (Decimal actualShare : actualShares) {
                Integer shareIndex = expectedSharesCopy.indexOf(actualShare);
                System.assertNotEquals(-1, shareIndex);
                expectedSharesCopy.remove(shareIndex);
            }
        }
    }

    @IsTest
    static void afterInsert_updateContactsShare() {
        new ContactShareTest()
            .accountTotal(100)
            .initialContactsCount(2)
            .expectedSharesBefore(new Decimal[] {50.00, 50.00})
            .insertNContacts(2)
            .expectedSharesAfter(new Decimal[] {25.00, 25.00, 25.00, 25.00})
            .run();
    }

    @IsTest
    static void afterDelete_updateContactsShare() {
        new ContactShareTest()
            .accountTotal(100)
            .initialContactsCount(4)
            .expectedSharesBefore(new Decimal[] {25.00, 25.00, 25.00, 25.00})
            .deleteNContacts(2)
            .expectedSharesAfter(new Decimal[] {50.00, 50.00})
            .run();
    }

    @IsTest
    static void afterUndelete_updateContactsShare() {
        new ContactShareTest()
            .accountTotal(100)
            .initialContactsCount(4)
            .expectedSharesBefore(new Decimal[] {25.00, 25.00, 25.00, 25.00})
            .deleteNContacts(2)
            .undeleteNContacts(1)
            .expectedSharesAfter(new Decimal[] {33.34, 33.33, 33.33})
            .run();
    }
}
