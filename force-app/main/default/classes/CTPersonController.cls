public with sharing class CTPersonController {
  public static String getToken(String mobile) {
    Blob value = Blob.valueOf(mobile);
    Blob hash = Crypto.generateDigest('MD5', value);
    return EncodingUtil.base64Encode(hash);
  }
  public static List<Person__C> getRecentHealthChanges() {
    List<Person__C> persons = [
      SELECT
        ID,
        Name,
        Mobile__c,
        Health_Status__c,
        Status_Update_Date__c,
        Token__c
      FROM Person__C
      ORDER BY Status_Update_Date__c DESC NULLS LAST
      LIMIT 100
    ];
    return persons;
  }

  public static List<Person__C> searchPeople(String searchTerm) {
    searchTerm = searchTerm + '%';

    List<Person__C> persons = [
      SELECT
        ID,
        Name,
        Mobile__c,
        Health_Status__c,
        Status_Update_Date__c,
        Token__c
      FROM Person__C
      WHERE
        Token__c LIKE :searchTerm
        OR Mobile__c LIKE :searchTerm
        OR Name LIKE :searchTerm
      ORDER BY Status_Update_Date__c DESC NULLS LAST
    ];
    return persons;
  }

  public static Person__C getPersonById(String Id) {
    List<Person__C> people = [
      SELECT
        ID,
        Name,
        Mobile__c,
        Health_Status__c,
        Status_Update_Date__c,
        Token__c
      FROM Person__C
      WHERE Id = :Id
      LIMIT 1
    ];
    if (people != null && people.size() > 0) {
      return people[0];
    }
    return null;
  }

  public static Map<String, Integer> getHealthStatusCount() {
    Map<String, Integer> healthStatusCount = new Map<String, Integer>();
    for (AggregateResult result : [
      SELECT COUNT(Id) healthCount, Health_Status__c
      FROM Person__C
      GROUP BY Health_Status__c
    ]) {
      healthStatusCount.put(
        String.valueOf(result.get('Health_Status__c')),
        Integer.valueOf(result.get('healthCount'))
      );
    }
    return healthStatusCount;
  }

  public static Set<Id> getNeighbours(
    Set<Id> personsIds,
    Set<Id> alreadyProcessed
  ) {
    Set<Id> result = new Set<Id>();
    List<People_Tracing__C> pts = [
      SELECT Id, Person_2__c, Person_1__c, Contact_Type__c
      FROM People_Tracing__c
      WHERE
        Contact_Type__C = 'Neighbour'
        AND (Person_2__c IN :personsIds
        OR Person_1__c IN :personsIds)
        AND (Person_1__R.Health_Status__c = 'Green'
        OR Person_2__R.Health_Status__c = 'Green')
    ];

    for (People_Tracing__C pt : pts) {
      if (!alreadyProcessed.contains(pt.Person_2__c)) {
        result.add(pt.Person_2__c);
        alreadyProcessed.add(pt.Person_2__c);
      }
      if (!alreadyProcessed.contains(pt.Person_1__c)) {
        result.add(pt.Person_1__c);
        alreadyProcessed.add(pt.Person_1__c);
      }
    }
    return result;
  }

  public static Set<Id> getCohabitants(
    Set<Id> personsIds,
    Set<Id> alreadyProcessed
  ) {
    Set<Id> result = new Set<Id>();
    List<String> status = new List<String>{ 'Green', 'Yellow' };
    List<People_Tracing__C> pts = [
      SELECT Id, Person_2__c, Person_1__c, Contact_Type__c
      FROM People_Tracing__c
      WHERE
        Contact_Type__C = 'Cohabitant'
        AND (Person_2__c IN :personsIds
        OR Person_1__c IN :personsIds)
        AND (Person_2__R.Health_Status__c IN :status
        OR Person_1__R.Health_Status__c IN :status)
    ];

    for (People_Tracing__C pt : pts) {
      if (!alreadyProcessed.contains(pt.Person_2__c)) {
        result.add(pt.Person_2__c);
        alreadyProcessed.add(pt.Person_2__c);
      }
      if (!alreadyProcessed.contains(pt.Person_1__c)) {
        result.add(pt.Person_1__c);
        alreadyProcessed.add(pt.Person_1__c);
      }
    }
    return result;
  }

  public static Set<Id> getPrimaryContactsByStatus(
    Set<Id> personsIds,
    List<String> status,
    Set<Id> alreadyProcessed
  ) {
    Set<Id> result = new Set<Id>();
    List<People_Tracing__C> pts = [
      SELECT Id, Person_2__c, Person_1__c, Contact_Type__c
      FROM People_Tracing__c
      WHERE
        Contact_Type__C = 'Other'
        AND (Person_2__c IN :personsIds
        OR Person_1__c IN :personsIds)
        AND (Person_2__R.Health_Status__c IN :status
        OR Person_1__R.Health_Status__c IN :status)
        AND Contact_Date__C = LAST_N_DAYS:10
    ];

    for (People_Tracing__C pt : pts) {
      if (!alreadyProcessed.contains(pt.Person_2__c)) {
        result.add(pt.Person_2__c);
        alreadyProcessed.add(pt.Person_2__c);
      }
      if (!alreadyProcessed.contains(pt.Person_1__c)) {
        result.add(pt.Person_1__c);
        alreadyProcessed.add(pt.Person_1__c);
      }
    }
    return result;
  }
}
