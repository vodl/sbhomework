/**
 * Created by vojtechdlapal on 2019-06-10.
 */

trigger CountryTrigger on Country__c (after insert, after update) {

    CountryTriggerHandler handler = new CountryTriggerHandler(Trigger.new, Trigger.oldMap);

    if(Trigger.isAfter){
        if(Trigger.isInsert){
            handler.afterInsert();
        } else if (Trigger.isUpdate){
            handler.afterUpdate();
        }
    }

}