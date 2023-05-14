public with sharing class AccountTriggerHandler extends TriggerHandler {

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
        List<Account> accountsWithTotalChanged = Filter.fieldChanged(newMap, oldMap, Account.Total__c);
        AccountsService.updateContactsShare(accountsWithTotalChanged);
    }
}
