/**
 * Created by vojtechdlapal on 2019-06-10.
 */

public with sharing class CountryTriggerHandler extends AbstractTriggerHandler {
    List<Country__c> newCountries;
    Map<Id, Country__c> oldCountriesMap;

    public CountryTriggerHandler(
            List<Country__c> newCountries,
            Map<Id, Country__c> oldCountriesMap
    ){
        this.newCountries = newCountries;
        this.oldCountriesMap = oldCountriesMap;
    }

    public void afterInsert(){

    }

    public void afterUpdate(){
        CountryHelper.updateCountriesOnLeads(newCountries);
    }

}