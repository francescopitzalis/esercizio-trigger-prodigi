Codice 1:
```
Account acc = new Account(Name = 'Test', Total__c = 0);
insert acc;
```

AccountTrigger => Before Insert
```
Trigger.operationType = TriggerOperation.BEFORE_INSERT
Trigger.new = [ A(null, 'Test', 0) ]
Trigger.newMap = {}
Trigger.old = []
Trigger.oldMap = {}

Trigger.isInsert = true
Trigger.isUpdate = false
Trigger.isDelete = false

Trigger.isBefore = true
Trigger.isAfter = false
```

AccountTrigger => After Insert
```
Trigger.operationType = TriggerOperation.AFTER_INSERT
Trigger.new = [ A(1, 'Test', 0) ]
Trigger.newMap = { 1 => A(1, 'Test', 0) }
Trigger.old = []
Trigger.oldMap = {}

Trigger.isInsert = true
Trigger.isUpdate = false
Trigger.isDelete = false

Trigger.isBefore = false
Trigger.isAfter = true
```

Codice 2:
```
acc.Total__c = 100;
update acc;
```

AccountTrigger => Before Update
```
Trigger.operationType = TriggerOperation.BEFORE_UPDATE
Trigger.new = [ A(1, 'Test', 100) ]
Trigger.newMap = { 1 => A(1, 'Test', 100) }
Trigger.old = [ A(1, 'Test', 0) ]
Trigger.oldMap = { 1 => A(1, 'Test', 0) }

Trigger.isInsert = false
Trigger.isUpdate = true
Trigger.isDelete = false

Trigger.isBefore = true
Trigger.isAfter = false
```

AccountTrigger => After Update
```
Trigger.operationType = TriggerOperation.AFTER_UPDATE
Trigger.new = [ A(1, 'Test', 100) ]
Trigger.newMap = { 1 => A(1, 'Test', 100) }
Trigger.old = [ A(1, 'Test', 0) ]
Trigger.oldMap = { 1 => A(1, 'Test', 0) }

Trigger.isInsert = false
Trigger.isUpdate = true
Trigger.isDelete = false

Trigger.isBefore = false
Trigger.isAfter = true
```

## Unit Test
```
@IsTest
private class AccountTriggerTest {

    @IsTest
    static void sharesSplit_ZeroRemainder() {
        Account acc = new Account(Name = 'Test', Total__c = 0);
        insert acc;
        
        List<Contact> contacts = new List<Contact> {
            new Contact(AccountId = acc.Id, LastName = 'Test1'),
            new Contact(AccountId = acc.Id, LastName = 'Test2'),
            new Contact(AccountId = acc.Id, LastName = 'Test3'),
            new Contact(AccountId = acc.Id, LastName = 'Test4')
        };
        insert contacts;
        
        acc.Total__c = 100;
        Test.startTest();
        update acc;
        Test.stopTest();
        
        for (Contact c : [SELECT Share__c FROM Contact WHERE AccountId = :acc.Id]) {
            System.assertEquals(25.00, c.Share__c);
        }
    }
}

```
