@isTest
public class BeforeEscalationMailHandlerTest {

    @isTest
    public static void testScheduleBeforeEscalation() {
        // Create test cases with different priorities and statuses
        List<Case> testCases = new List<Case>();
        testCases.add(new Case(Status = 'New', Priority = 'Low'));
        testCases.add(new Case(Status = 'New', Priority = 'Medium'));
        testCases.add(new Case(Status = 'New', Priority = 'High'));
        testCases.add(new Case(Status = 'Escalated', Priority = 'Medium'));
        testCases.add(new Case(Status = 'Closed', Priority = 'High'));

        Test.startTest();
        BeforeEscalationMailHandler.scheduleBeforeEscalation(testCases);
        Test.stopTest();

        // Assert that the correct number of jobs have been scheduled
        List<CronTrigger> cronTriggers = [SELECT Id FROM CronTrigger];
        System.assertEquals(12, cronTriggers.size(), 'Unexpected number of jobs scheduled.');
    }

    @isTest
    public static void testCalculateEscalatedDateTime() {
        // Test the calculateEscalatedDateTime method
        DateTime createdDateTime = DateTime.newInstance(2023, 6, 1, 12, 0, 0);
        String timeString = '01:30:00';
        DateTime escalatedDateTime = BeforeEscalationMailHandler.calculateEscalatedDateTime(createdDateTime, timeString);

        // Assert the expected escalated date and time
        System.assertEquals(1, escalatedDateTime.day(), 'Unexpected day value for escalatedDateTime.');
        System.assertEquals(13, escalatedDateTime.hour(), 'Unexpected hour value for escalatedDateTime.');
        System.assertEquals(30, escalatedDateTime.minute(), 'Unexpected minute value for escalatedDateTime.');
    }

    @isTest
    public static void testGetFormattedCronExpression() {
        // Test the getFormattedCronExpression method
        DateTime dt = DateTime.newInstance(2023, 6, 1, 12, 30, 0);
        String cronExpression = BeforeEscalationMailHandler.getFormattedCronExpression(dt);

        // Assert the expected cron expression
        System.assertEquals('0 30 12 1 6 ? 2023', cronExpression, 'Unexpected cron expression value.');
    }

    @isTest
    public static void testGetJobName() {
        // Test the getJobName method
        Case testCase = new Case(Id = '5001R0001234567ABC', Status = 'New', Priority = 'Low');
        String customSettingField = 'BeforeCaseEscalationTimeForEmailAlert__c';
        String jobName = BeforeEscalationMailHandler.getJobName(testCase, customSettingField);

        // Assert the expected job name
        System.assertEquals('Dynamic_Case_Before_Escalation_BeforeCaseEscalationTimeForEmailAlert__c_Schedule_Date_and_Time_5001R0001234567ABC', jobName, 'Unexpected job name.');
    }
}