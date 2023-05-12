trigger AccountTrigger on Account (after update) {

    AccountTriggerHandler.handle(Trigger.operationType, Trigger.new, Trigger.old, Trigger.newMap, Trigger.oldMap);
}
