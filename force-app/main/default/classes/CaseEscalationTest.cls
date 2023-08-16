@isTest
private class CaseEscalationTest {
    @isTest
    static void testCaseEscalation() {
        // Create a test Case
         // Create a test DynamicTimeValuesForEscalation__c record
        DynamicTimeValuesForEscalation__c dynamicValues = new DynamicTimeValuesForEscalation__c();
            dynamicValues.CaseEscalationforLowMediumPriority__c = '00:10:00';
            dynamicValues.CaseEscalationforHighPriority__c = '00:05:00';
       
        insert dynamicValues;
        Case testCase = new Case(
            Status = 'New',
            Priority = 'Medium'
            // Add other required fields
        );
        insert testCase;

        // Schedule the CaseEscalation job
        Test.startTest();
        CaseEscalation caseEscalationJob = new CaseEscalation(testCase, testCase.Id);
        String jobId = System.schedule('Test CaseEscalation Job', '0 0 * * * ?', caseEscalationJob);
        Test.stopTest();

        // Verify the job is scheduled
        System.assertNotEquals(null, jobId);

        // Wait for the scheduled job to complete (you might need to adjust the wait time based on your scheduling frequency)
        // The following line of code might help to wait for a scheduled job to finish.
        // You'll need to adjust the wait time based on your scheduling frequency and expected execution time.
        // Test.setMock(SchedulableContext.class, new MySchedulableContext());
        // MySchedulableContext should implement the SchedulableContext interface and provide proper methods for testing.

        // Retrieve the updated Case
        Case updatedCase = [SELECT Id, Status, OwnerId, IsEscalated FROM Case WHERE Id = :testCase.Id];

        // Verify the expected outcome
        System.assertEquals('Escalated', updatedCase.Status);
        System.assertEquals(true, updatedCase.IsEscalated);
        // Verify any other expected changes
        
        // Clean up: Delete the scheduled job
        System.abortJob(jobId);
    }
}