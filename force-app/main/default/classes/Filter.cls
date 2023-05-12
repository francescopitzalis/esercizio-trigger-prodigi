public with sharing class Filter {

    public static List<SObject> fieldNotNull(List<SObject> sobs, SObjectField sobField) {
        List<SObject> result = new List<SObject>();
        for (SObject sob : sobs) {
            if (sob.get(sobField) != null) {
                result.add(sob);
            }
        }
        return result;
    }

    public static List<SObject> fieldChanged(Map<Id, SObject> newMap, Map<Id, SObject> oldMap, SObjectField sobField) {
        List<SObject> result = new List<SObject>();
        for (Id sobId : newMap.keySet()) {
            SObject newSob = newMap.get(sobId);
            SObject oldSob = oldMap.get(sobId);

            if (newSob.get(sobField) != oldSob.get(sobField)) {
                result.add(newSob);
            }
        }
        return result;
    }
}
