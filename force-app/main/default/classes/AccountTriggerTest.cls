@IsTest
private class AccountTriggerTest {

    private class ChildContactSharesTest {
        private Decimal oldTotal;
        private Decimal newTotal;
        private Decimal nContacts;
        private List<Decimal> expectedShares;

        private ChildContactSharesTest oldTotal(Decimal oldTotal) {
            this.oldTotal = oldTotal;
            return this;
        }

        private ChildContactSharesTest newTotal(Decimal newTotal) {
            this.newTotal = newTotal;
            return this;
        }

        private ChildContactSharesTest nContacts(Decimal nContacts) {
            this.nContacts = nContacts;
            return this;
        }

        private ChildContactSharesTest expectedShares(List<Decimal> expectedShares) {
            this.expectedShares = expectedShares;
            return this;
        }

        private void run() {
            Account acc = new Account(Name = 'Test', Total__c = oldTotal);
            insert acc;

            List<Contact> contacts = new List<Contact>();
            for (Integer i = 0; i < nContacts; i++) {
                contacts.add(new Contact(FirstName = 'John' + i, LastName = 'Smith' + i, AccountId = acc.Id));
            }
            insert contacts;

            acc.Total__c = newTotal;
            update acc;

            List<Contact> updatedContacts = [SELECT Id, Share__c FROM Contact WHERE AccountId = :acc.Id];
            System.assertEquals(expectedShares.size(), updatedContacts.size());

            List<Decimal> actualShares = new List<Decimal>();
            for (Contact c : updatedContacts) {
                actualShares.add(c.Share__c);
            }

            System.debug('actualShares: ' + actualShares);
            System.debug('expectedShares: ' + expectedShares);

            for (Decimal actualShare : actualShares) {
                Integer shareIndex = expectedShares.indexOf(actualShare);
                System.assertNotEquals(-1, shareIndex);
                expectedShares.remove(shareIndex);
            }
        }
    }
    
    @IsTest
    static void afterUpdate_childContactShares() {
        new ChildContactSharesTest()
            .oldTotal(0)
            .newTotal(100)
            .nContacts(3)
            .expectedShares(new Decimal[] {33.34, 33.33, 33.33})
            .run();
    }

    @IsTest
    static void afterUpdate_childContactShares_totalNull() {
        new ChildContactSharesTest()
            .oldTotal(0)
            .newTotal(null)
            .nContacts(3)
            .expectedShares(new Decimal[] {null, null, null})
            .run();
    }

}
