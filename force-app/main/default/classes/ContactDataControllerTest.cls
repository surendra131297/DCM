@isTest
public class ContactDataControllerTest {

    @isTest
    public static void testFetchContacts() {
         // Create a test DynamicTimeValuesForEscalation__c record
        DynamicTimeValuesForEscalation__c dynamicValues = new DynamicTimeValuesForEscalation__c();
            dynamicValues.CaseEscalationforLowMediumPriority__c = '00:10:00';
            dynamicValues.CaseEscalationforHighPriority__c = '00:05:00';
       
        insert dynamicValues;
        // Create test cases
        List<Case> testCases = new List<Case>();
        testCases.add(new Case(Status = 'New', Subject = 'Test Case 1', Priority = 'High', Origin = 'Email'));
        testCases.add(new Case(Status = 'Closed', Subject = 'Test Case 2', Priority = 'Low', Origin = 'Phone'));
        insert testCases;

        Test.startTest();
        List<Case> result = ContactDataController.fetchContacts();
        Test.stopTest();

        // Assert that the method returns a list of cases
        System.assertNotEquals(null, result, 'Result should not be null.');
        System.assertEquals(2, result.size(), 'Unexpected size of the result.');
    }

    @isTest
    public static void testFetchContacts4() {
         // Create a test DynamicTimeValuesForEscalation__c record
        DynamicTimeValuesForEscalation__c dynamicValues = new DynamicTimeValuesForEscalation__c();
            dynamicValues.CaseEscalationforLowMediumPriority__c = '00:10:00';
            dynamicValues.CaseEscalationforHighPriority__c = '00:05:00';
       
        insert dynamicValues;
        // Create test cases
        List<Case> testCases = new List<Case>();
        testCases.add(new Case(Status = 'New', Subject = 'Test Case 1', Priority = 'High', Origin = 'Email'));
        testCases.add(new Case(Status = 'Closed', Subject = 'Test Case 2', Priority = 'Low', Origin = 'Phone'));
        insert testCases;

        Test.startTest();
        List<Case> result = ContactDataController.fetchContacts4('Status', 'New');
        Test.stopTest();

        // Assert that the method returns a filtered list of cases
        System.assertNotEquals(null, result, 'Result should not be null.');
        System.assertEquals(1, result.size(), 'Unexpected size of the result.');
        System.assertEquals('New', result[0].Status, 'Unexpected status value.');
    }
}