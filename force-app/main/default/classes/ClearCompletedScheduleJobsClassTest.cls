@IsTest
public class ClearCompletedScheduleJobsClassTest {
    
    @isTest
    static void testClearCompletedScheduleJobs() {
        // Get all deleted CronTriggers
        CronTrigger[] cronTriggers = [
            SELECT Id, State, NextFireTime
            FROM CronTrigger
            WHERE State = 'DELETED'
            AND NextFireTime = null limit 1
        ];
        
        // Simulate the scheduled class running
        Test.startTest();
        for (CronTrigger cronTrigger : cronTriggers) {
            ClearCompletedScheduleJobsClass.completedJobsScheduleMethod();
            System.abortJob(cronTrigger.Id);
        }
        Test.stopTest();

        // Add assertions to validate the expected results
        CronTrigger[] updatedCronTriggers = [
            SELECT Id, State, NextFireTime
            FROM CronTrigger
            WHERE State = 'DELETED'
            AND NextFireTime = null
        ];

        System.assertEquals(0, updatedCronTriggers.size(), 'No more CronTriggers should be in DELETED state with null NextFireTime.');
    }
}