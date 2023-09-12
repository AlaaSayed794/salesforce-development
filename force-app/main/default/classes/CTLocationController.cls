public with sharing class CTLocationController {
  public static List<Location__c> getRecentStatusChanges() {
    List<Location__c> locations = [
      SELECT
        Pincode__c,
        Status_Update_Date__c,
        Red_Score__c,
        Status__c,
        Address__c,
        Name,
        Id
      FROM Location__c
      ORDER BY Status_Update_Date__c DESC NULLS LAST
      LIMIT 100
    ];
    return locations;
  }

  public static List<Location__c> searchLocations(String searchTerm) {
    searchTerm = searchTerm + '%';

    List<Location__c> locations = [
      SELECT
        Id,
        Name,
        Pincode__c,
        Status_Update_Date__c,
        Red_Score__c,
        Status__c,
        Address__c
      FROM Location__c
      WHERE
        Pincode__c LIKE :searchTerm
        OR Address__c LIKE :searchTerm
        OR Name LIKE :searchTerm
      ORDER BY Status_Update_Date__c DESC NULLS LAST
    ];
    return locations;
  }

  public static Location__c getLocationById(String Id) {
    List<Location__c> locations = [
      SELECT
        Id,
        Name,
        Pincode__c,
        Status_Update_Date__c,
        Red_Score__c,
        Status__c,
        Address__c
      FROM Location__c
      WHERE Id = :Id
      LIMIT 1
    ];
    if (locations != null && locations.size() > 0) {
      return locations[0];
    }
    return null;
  }
}
