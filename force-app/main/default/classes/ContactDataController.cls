/**
 * @description This class allows users to see case details and filter them based on status, priority, and origin.
 * @Author Sprutiraj Panda, Surendranath Reddy, Subba Reddy Venkata, Sravani Bandaru
 * @Last Modified By Subba Reddy Venkata, Sprutiraj Panda
 * @Last Modified On 25/04/2023
 * @Modification Log:
 * Ver    Date          Author             Last Modification
 * 1.0    26/04/2023    Sprutiraj Panda     Initial Version
 *                           Subba Reddy Venkata
 **/
public with sharing class ContactDataController {
     /**
     * @description Fetches the list of cases.
     * This method retrieves all Case records with the specified fields.
     * @return List of Case records.
     */
    @AuraEnabled(cacheable=true)
    public static list<Case> fetchContacts(){ 
        list<Case> lstContact =  [SELECT Id, Status, Case_No__c, Case_Owner_Name__c, Reason, Origin, Subject, Priority, Product__c FROM Case WITH SECURITY_ENFORCED];
        return lstContact;     
    }

    /**
     * @description Fetches the list of cases based on the selected field and value.
     * This method retrieves Case records based on the specified filter field and value.
     * @param fieldApi The API name of the field to filter.
     * @param selectedValue The value to be used as a filter for the selected field.
     * @return List of filtered Case records.
     */
    @AuraEnabled(cacheable=true)
    public static list<Case> fetchContacts4(String fieldApi, String selectedValue){ 
        list<Case> lstContact = new list<Case>();
        String queryStr = 'SELECT Id, Status, Reason, Origin, Case_No__c, Case_Owner_Name__c, Subject, Priority, Product__c FROM Case';
        if (fieldApi != '' && selectedValue != '') {
            String filterFieldApi = String.escapeSingleQuotes(fieldApi);
            queryStr = queryStr + ' WHERE ' + filterFieldApi + '= :selectedValue';
            lstContact = Database.query(queryStr);
            return lstContact;  
        } else {
            lstContact = Database.query(queryStr);
            return lstContact; 
        }        
    }
}