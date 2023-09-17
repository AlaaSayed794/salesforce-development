public with sharing class CTLocationTracingTriggerHandler {
    public static void beforeInsert(List<Location_Tracing__c> newRecords) {
        List<Location_Tracing__c> duplicates = CTLocationTracingController.checkDuplicates(newRecords);
        for(Location_Tracing__c duplicate : duplicates){
            duplicate.addError('duplicate record found location:'+ duplicate.Location__c + ', Person  : '+ duplicate.Person__c);
        }
            }
}