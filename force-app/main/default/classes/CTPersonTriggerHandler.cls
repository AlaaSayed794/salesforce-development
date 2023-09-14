public with sharing class CTPersonTriggerHandler {
  public static void beforeInsert(List<Person__C> persons) {
    for (Person__c p : persons) {
      p.Health_Status__c = 'Green';
      p.Token__C = CTPersonController.getToken(p.Mobile__c);
    }
  }

  public static void beforeUpdate(
    List<Person__C> persons,
    Map<Id, Person__C> oldPersons
  ) {
    for (Person__c p : persons) {
      if (p.Health_Status__c != oldPersons.get(p.Id).Health_Status__c) {
        p.Status_Update_Date__c = Date.today();
      }
    }
  }

  public static void afterUpdate(
    List<Person__C> persons,
    Map<Id, Person__C> oldPersons
  ) {
    Set<Id> statusChange = new Set<Id>();
    Set<Id> redStatus = new Set<Id>();

    for (Person__c p : persons) {
      if (p.Health_Status__c != oldPersons.get(p.Id).Health_Status__c) {
        statusChange.add(p.Id);
      }
      if (
        p.Health_Status__c == 'Red' &&
        oldPersons.get(p.Id).Health_Status__c != 'Red'
      ) {
        redStatus.add(p.Id);
      }
    }

    Set<Id> setToOrange = new Set<Id>();
    Set<Id> setToYellow = new Set<Id>();

    Set<Id> alreadyProcessed = new Set<Id>();
    alreadyProcessed.addAll(redStatus);

    setToOrange.addAll(
      CTPersonController.getCohabitants(redStatus, alreadyProcessed)
    );

    setToOrange.addAll(CTPersonController.getPrimaryContactsByStatus(
      redStatus,
      new List<String>{ 'Green', 'Yellow' },
      alreadyProcessed
    ));

    setToYellow.addAll(
      CTPersonController.getNeighbours(redStatus, alreadyProcessed)
    );
    setToYellow.addAll(
      CTPersonController.getPrimaryContactsByStatus(
        CTPersonController.getPrimaryContactsByStatus(
      redStatus,
      new List<String>{ 'Green', 'Yellow','Orange' },
      alreadyProcessed
    ),
        new List<String>{ 'Green' },
        alreadyProcessed
      )
    );

    List<Person__C> personsUpdate = new List<Person__C>();
    for (Id pid : setToOrange) {
      personsUpdate.add(new Person__C(Id = pid, Health_Status__c = 'Orange'));
    }
    for (Id pid : setToYellow) {
      personsUpdate.add(new Person__C(Id = pid, Health_Status__c = 'Yellow'));
    }

    if (personsUpdate.size() > 0) {
      update personsUpdate;
    }

    List<Location_Tracing__c> lts = CTLocationTracingController.getLocationsByPersonIds(
      statusChange
    );
    if (lts != null && lts.size() > 0) {
      Set<ID> locationIds = new Set<ID>();
      for (Location_Tracing__c lt : lts) {
        locationIds.add(lt.Location__c);
      }
    }
  }
}
