public with sharing class CTLocationTriggerHandler {
    public static void beforeInsert(List<Location__c> locations) {
        for (Location__c l : locations) {
          l.Status__c = 'Green';
        }
      }
    
      public static void beforeUpdate(
        List<Location__c> locations,
        Map<Id, Location__c> oldLocations
      ) {
        for (Location__c l : locations) {
          if (l.Status__c != oldLocations.get(l.Id).Status__c) {
            l.Status_Update_Date__c = Date.today();
          }
        }
      }
}