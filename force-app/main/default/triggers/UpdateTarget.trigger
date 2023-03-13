trigger UpdateTarget on Opportunity (before insert,after update,before update,before delete) {

    if(Trigger.isInsert){
        triggerHandler.updateTargetInsertTrigger(Trigger.New);
         if(Trigger.isAfter){
            //system.debug('Called:  '+Trigger.New);
            triggerHandler.updateAccountOfferings(Trigger.New,null);
             triggerHandler.updateAccountRelation(Trigger.New,Trigger.Old);
        }
    }


    else if(Trigger.isUpdate){
        triggerHandler.updateTargetUpdateTrigger(Trigger.New,Trigger.Old);
        if(Trigger.isAfter){
            //system.debug('Called:  '+Trigger.New);
            triggerHandler.updateAccountOfferings(Trigger.New,Trigger.Old);
            triggerHandler.updateAccountRelation(Trigger.New,Trigger.Old);
        }
    }

    if(Trigger.isDelete){
        triggerHandler.updateTargetDeleteTrigger(Trigger.Old);
    }
}