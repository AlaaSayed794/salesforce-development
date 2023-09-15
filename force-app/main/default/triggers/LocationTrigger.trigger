trigger LocationTrigger on Location__c(
  before insert,
  before update
) {
  switch on Trigger.operationType {
    when BEFORE_INSERT {
        CTLocationTriggerHandler.beforeInsert(Trigger.new);
    }
    when BEFORE_UPDATE {
        CTLocationTriggerHandler.beforeUpdate(Trigger.new, Trigger.oldMap);
    }
   
  }
}
