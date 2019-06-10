/**
 * Created by vojtechdlapal on 2019-06-10.
 */

public with sharing class CountryHelper {

    public static void debugIt(List<Country__c> countries){
        for (Country__c c : countries){
            System.debug(c);
        }
    }

    public static void updateCountriesOnLeads(List<Country__c> countries){
        List<Lead> leadsToUpdate = [
                SELECT
                        Country__c,
                        Capital_cityt__c,
                        Country_ISO_code_2t__c,
                        Country_ISO_code_3t__c,
                        Regiont__c,
                        Subregiont__c,
                        RegionalBlocst__c
                FROM Lead
                WHERE Country__c IN :countries
        ];

        //it does not make sanse to do this update in trigger as it could be formulas but...
        //depending on number of leads this would have to be chunked/paralelized
        //also we would need befereInsert on Lead and so...
        Map<Id, Country__c> countryMap = new Map<Id, Country__c>(countries);
        for(Lead l : leadsToUpdate){
            Country__c country = countryMap.get(l.Country__c);
            l.Capital_cityt__c = country.Capital__c;
            l.Country_ISO_code_2t__c = country.Alpha2Code__c;
            l.Country_ISO_code_3t__c = country.Alpha3Code__c;
            l.Regiont__c = country.Region__c;
            l.Subregiont__c = country.Subregion__c;
            l.RegionalBlocst__c = country.RegionalBlocks__c;
        }
        update leadsToUpdate;
    }
}