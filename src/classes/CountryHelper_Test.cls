/**
 * Created by vojtechdlapal on 2019-06-10.
 * tests are not really comprehensive as the purpose of the trigger is not clear to me after all...
 */
@IsTest
public with sharing class CountryHelper_Test {

    //todo: bulk test...

    testMethod private static void testUpdateCountriesOnLeads(){
        Country__c newCountry = new Country__c();
        newCountry.Name = 'Narnia';
        newCountry.Alpha3Code__c = 'NNN';
        newCountry.Alpha2Code__c = 'NN';
        insert newCountry;

        Lead newLead = new Lead();
        newLead.Country__c = newCountry.Id;
        newLead.LastName = 'smth';
        newLead.Company = 'smth';
        insert newLead;

        newCountry.Alpha2Code__c = 'EE';

        Test.startTest();
        update newCountry;
        Test.stopTest();

        List<Country__c> retrievedCountries = [SELECT Alpha2Code__c FROM Country__c];
        System.assertEquals('EE', retrievedCountries[0].Alpha2Code__c, 'Code 2 should be changed');

        List<Lead> updatedLeads = [
                SELECT
                        Country__c,
                        Capital_cityt__c,
                        Country_ISO_code_2t__c,
                        Country_ISO_code_3t__c,
                        Regiont__c,
                        Subregiont__c,
                        RegionalBlocst__c
                FROM Lead
        ];

        System.assertEquals(newCountry.Alpha3Code__c, updatedLeads[0].Country_ISO_code_3t__c, 'ISO COde SHould be updated');
        System.assertEquals(newCountry.Alpha2Code__c, updatedLeads[0].Country_ISO_code_2t__c, 'ISO COde SHould be updated');
    }

}