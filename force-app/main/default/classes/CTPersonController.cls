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
    if(people!=null && people.size()>0){
      return people[0];
    }
    return null;
  }
}
