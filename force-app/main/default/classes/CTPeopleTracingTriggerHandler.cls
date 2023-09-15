public with sharing class CTPeopleTracingTriggerHandler {
    public static void beforeInsert(List<People_Tracing__c> newRecords) {
List<People_Tracing__c> duplicates = CTPeopleTracingController.checkDuplicates(newRecords);
for(People_Tracing__c duplicate : duplicates){
    duplicate.addError('duplicate record found Person1:'+ duplicate.Person_1__c + ', Person 2 : '+ duplicate.Person_2__c);
}
    }
}