/**
 * Created by vojtechdlapal on 2019-06-10.
 */

public with sharing class CountryService implements Schedulable{

    public static final String ENDPOINT =
            'https://restcountries.eu/rest/v2/all?fields=name;capital;region;subregion;alpha2Code;alpha3Code;regionalBlocs';

    public static final Map<String, String> FIELD_MAPPING = new Map<String, String>{
            'Alpha2Code__c' => 'alpha2Code',
            'Alpha3Code__c' => 'alpha3Code',
            'Capital__c' => 'capital',
            'Region__c' => 'region',
            'Subregion__c' => 'subregion',
            'Name' => 'name'
    };

    public static void execute(System.SchedulableContext context){
        refreshCountriesFromAPI();
    }


    @future(callout=true)
    public static void refreshCountriesFromAPI() {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(ENDPOINT);
        request.setMethod('GET');
        HttpResponse response = http.send(request);

        if (response.getStatusCode() == 200) {
            //System.debug(JSON.serialize(response.getHeaderKeys()));
            //System.debug(response.getHeader('Etag')); not available from api :(
            List<Object> results = (List<Object>) JSON.deserializeUntyped(response.getBody());
            processCountries(results);
        }
    }

    private static void processCountries(List<Object> results) {
        List<Country__c> countriesToUpsert = new List<Country__c>();
        Map<String, Country__c> existingCountries = getAllCountries();
        for (Object responseCountry : results) {

            Country__c newCountry = fillCountyFields((Map<String, Object>) responseCountry);
            if (isCountryChanged(existingCountries, newCountry)) {
                countriesToUpsert.add(newCountry);
            }
        }

        if (!countriesToUpsert.isEmpty()) {
            Database.UpsertResult[] result = Database.upsert(countriesToUpsert, Country__c.Alpha3Code__c, false);
            System.debug(result);
        } else {
            System.debug('Nothing changed...');
        }
    }

    private static Country__c fillCountyFields(Map<String, Object> countryMap) {
        Country__c newCountry = new Country__c();
        for (String field : FIELD_MAPPING.keySet()) {
            newCountry.put(field, (String) countryMap.get(FIELD_MAPPING.get(field)));
        }

        newCountry.RegionalBlocks__c = getRegionalBlocksString((List<Object>) countryMap.get('regionalBlocs'));
        return newCountry;
    }

    private static String getRegionalBlocksString(List<Object> blocks) {
        List<String> acronyms = new List<String>();
        for (Object block : blocks) {
            Map<String, Object> blockMap = (Map<String, Object>) block;
            String acronym = (String) blockMap.get('acronym');
            acronyms.add(acronym);
        }
        return String.join(acronyms, ';');
    }

    private static Map<String, Country__c> getAllCountries() {
        List<Country__c> allcountries = [
                SELECT
                        Alpha2Code__c,
                        Alpha3Code__c,
                        Capital__c,
                        Id,
                        Name,
                        Region__c,
                        RegionalBlocks__c,
                        Subregion__c
                FROM Country__c
        ];

        Map<String, Country__c> countriesByCode3 = new Map<String, Country__c>();
        for (Country__c c : allcountries) {
            countriesByCode3.put(c.Alpha3Code__c, c);
        }
        return countriesByCode3;
    }

    private static Boolean isCountryChanged(Map<String, Country__c> existingCountries, Country__c newCountry) {
        Country__c existingCountry = existingCountries.get(newCountry.Alpha3Code__c);
        if (existingCountry == null) {
            return true;
        }
        for (String fieldName : FIELD_MAPPING.keySet()) {
            if (existingCountry.get(fieldName) == null) {
                existingCountry.put(fieldName, '');
            }
            if (newCountry.get(fieldName) != existingCountry.get(fieldName)) {
                System.debug(fieldName + newCountry.get(fieldName) + ' != ' + existingCountries.get(fieldName));
                return true;
            }
            if(hasRegionalBlockChanged(newCountry, existingCountry)){
                return true;
            }
        }
        return false;
    }

    private static Boolean hasRegionalBlockChanged(Country__c newCountry, Country__c existingCountry) {
        if (newCountry.RegionalBlocks__c == null) {
            newCountry.RegionalBlocks__c = '';
        }
        if (existingCountry.RegionalBlocks__c == null) {
            existingCountry.RegionalBlocks__c = '';
        }
        Set<String> newRegionalBlocks = new Set<String>(newCountry.RegionalBlocks__c.split(';'));
        Set<String> oldRegionalBlocks = new Set<String>(existingCountry.RegionalBlocks__c.split(';'));

        if (!newRegionalBlocks.containsAll(oldRegionalBlocks)) {
            System.debug(newCountry.RegionalBlocks__c + ' != ' + existingCountry.RegionalBlocks__c);
            return true;
        }
        return false;
    }

}