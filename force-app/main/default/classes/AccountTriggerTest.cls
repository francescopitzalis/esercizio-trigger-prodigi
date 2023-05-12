@IsTest
private class AccountTriggerTest {

    private Decimal oldTotal;
    private Decimal newTotal;
    private Decimal nContacts;
    private List<Decimal> expectedShares;

    private AccountTriggerTest oldTotal(Decimal oldTotal) {
        this.oldTotal = oldTotal;
        return this;
    }

    private AccountTriggerTest newTotal(Decimal newTotal) {
        this.newTotal = newTotal;
        return this;
    }

    private AccountTriggerTest nContacts(Decimal nContacts) {
        this.nContacts = nContacts;
        return this;
    }

    private AccountTriggerTest expectedShares(List<Decimal> expectedShares) {
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
    
    @IsTest
    static void totalNull() {
        new AccountTriggerTest()
            .oldTotal(0)
            .newTotal(null)
            .nContacts(3)
            .expectedShares(new Decimal[] {null, null, null})
            .run();
    }

    @IsTest
    static void remainderZero() {
        new AccountTriggerTest()
            .oldTotal(0)
            .newTotal(100)
            .nContacts(4)
            .expectedShares(new Decimal[] {25.00, 25.00, 25.00, 25.00})
            .run();
    }

    @IsTest
    static void remainderOneCent() {
        new AccountTriggerTest()
            .oldTotal(0)
            .newTotal(100)
            .nContacts(3)
            .expectedShares(new Decimal[] {33.34, 33.33, 33.33})
            .run();
    }

    @IsTest
    static void remainderTwoCents() {
        new AccountTriggerTest()
            .oldTotal(0)
            .newTotal(200)
            .nContacts(11)
            .expectedShares(new Decimal[] {18.19, 18.19, 18.18, 18.18, 18.18, 18.18, 18.18, 18.18, 18.18, 18.18, 18.18})
            .run();
    }

    @IsTest
    static void remainderThreeCents() {
        new AccountTriggerTest()
            .oldTotal(0)
            .newTotal(100)
            .nContacts(13)
            .expectedShares(new Decimal[] {7.70, 7.70, 7.70, 7.69, 7.69, 7.69, 7.69, 7.69, 7.69, 7.69, 7.69, 7.69, 7.69})
            .run();
    }

    @IsTest
    static void remainderMinusOneCent() {
        new AccountTriggerTest()
            .oldTotal(0)
            .newTotal(200)
            .nContacts(3)
            .expectedShares(new Decimal[] {66.66, 66.67, 66.67})
            .run();
    }

    @IsTest
    static void remainderMinusTwoCents() {
        new AccountTriggerTest()
            .oldTotal(0)
            .newTotal(100)
            .nContacts(6)
            .expectedShares(new Decimal[] {16.66, 16.66, 16.67, 16.67, 16.67, 16.67})
            .run();
    }

    @IsTest
    static void remainderMinusThreeCents() {
        new AccountTriggerTest()
            .oldTotal(0)
            .newTotal(100)
            .nContacts(7)
            .expectedShares(new Decimal[] {14.28, 14.28, 14.28, 14.29, 14.29, 14.29, 14.29})
            .run();
    }
}
