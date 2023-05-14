trigger ContactTrigger on Contact (after insert, after delete, after undelete) {

    ContactTriggerHandler.handle(Trigger.operationType, Trigger.new, Trigger.old, Trigger.newMap, Trigger.oldMap);
}
