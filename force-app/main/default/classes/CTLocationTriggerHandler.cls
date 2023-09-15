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

      public static void afterUpdate(
    List<Location__C> locations,
    Map<Id, Location__C> oldLocations
  ) {
    Set<Id> redStatus = new Set<Id>();

    for (Location__c l : locations) {
      if (
        l.Status__c == 'Red' &&
        oldLocations.get(l.Id).Status__c != 'Red'
      ) {
        redStatus.add(l.Id);
      }
    }
    if(redStatus.size()>0){

        List<Location_Tracing__c> locationTracings = CTLocationTracingController.getLocationsByLocationIds(redStatus);
    Set<Id> personIds = new Set<Id>();
    for(Location_Tracing__c lt : locationTracings){
        personIds.add(lt.Person__c);
    }
    List<Person__c> peopleToUpdate = new List<Person__c>();
    for(Id pid : personIds){
        peopleToUpdate.add(new Person__c(Id=pid ,Health_Status__c='Yellow'));
    }
    if(peopleToUpdate.size()>0){
        update peopleToUpdate;
    }
    }
  }
}