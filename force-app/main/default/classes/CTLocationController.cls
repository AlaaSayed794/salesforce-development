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

  public static Map<String, Integer> getHealthStatusCount() {
    Map<String, Integer> healthStatusCount = new Map<String, Integer>();
    for (AggregateResult result : [
      SELECT COUNT(Id) healthCount, Status__c
      FROM Location__c
      GROUP BY Status__c
    ]) {
      healthStatusCount.put(
        String.valueOf(result.get('Status__c')),
        Integer.valueOf(result.get('healthCount'))
      );
    }
    return healthStatusCount;
  }

  public static void updateRedScore(Set<Id> locationIds) {
    List<Location__c> locationsUpdate = new List<Location__c>();
    List<AggregateResult> results = [
      SELECT Location__c, count(Id) total
      FROM Location_Tracing__c
      WHERE
        Person__R.Health_Status__c = 'Red'
        AND Visit_Date__c = LAST_N_DAYS:10
        AND Location__c IN :locationIds
      GROUP BY Location__c
    ];
    for (AggregateResult result : results) {
      String locationId =String.valueOf( result.get('Location__C'));
      Integer redScore = Integer.valueOf(result.get('total'));
      String status = getStatus(redScore);
      locationsUpdate.add(new Location__c(Id=locationId, Red_Score__c=redScore, Status__c=status));
    }
    if(locationsUpdate!=null && locationsUpdate.size()>0){
      update locationsUpdate;
    }
  }
  public static String getStatus(Integer redScore) {
    if (redScore==null || redScore==0 ) {
      return 'Green';
      
    } else if(redScore <= 5){
      return 'Yellow';

    }
    else if(redScore <= 10){
      return 'Orange';
    }
    else{
      return 'Red';
    }
    
  }
}
