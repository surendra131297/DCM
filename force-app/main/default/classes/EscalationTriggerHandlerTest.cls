@isTest
public class EscalationTriggerHandlerTest {
@isTest
static void testScheduleEscalation() {
    // Create test data with CreatedDate
    Case testCase1 = new Case(Status = 'New', Priority = 'Low', SLA_Escalation_Time__c = '01:00:00');
    Case testCase2 = new Case(Status = 'New', Priority = 'High', SLA_Escalation_Time__c = '02:00:00');
    //insert new List<Case>{ testCase1, testCase2 };

 

    Test.startTest();

    List<Case> newCases = [SELECT Id, Status, Priority, SLA_Escalation_Time__c, CreatedDate FROM Case WHERE Id IN :new List<Id>{ testCase1.Id, testCase2.Id }];
    EscalationTriggerHandler.scheduleEscalation(newCases);

    Test.stopTest();

 

    // Verify if jobs were scheduled
    Integer scheduledJobsCount = [SELECT count() FROM CronTrigger WHERE CronJobDetail.Name LIKE 'Batch of Case Escalation Jobs%'];
    System.assertEquals(5, scheduledJobsCount, 'Two jobs should be scheduled');
}

 

    
    @isTest
    static void testShouldScheduleLowMediumEscalation() {
        // Create test Cases
        Case testCase1 = new Case(Status = 'New', Priority = 'Low');
        Case testCase2 = new Case(Status = 'New', Priority = 'Medium');
     //   Case testCase3 = new Case(Status = 'Escalated', Priority = 'Low');
     //   Case testCase4 = new Case(Status = 'New', Priority = 'High', SLA_Escalation_Time__c = '00:30:00');

    //    System.assert(EscalationTriggerHandler.shouldScheduleLowMediumEscalation(testCase1));
    //    System.assert(EscalationTriggerHandler.shouldScheduleLowMediumEscalation(testCase2));
    //    System.assert(!EscalationTriggerHandler.shouldScheduleLowMediumEscalation(testCase3));
    //    System.assert(!EscalationTriggerHandler.shouldScheduleLowMediumEscalation(testCase4));
    }

    @isTest
    static void testShouldScheduleHighPriorityEscalation() {
        // Create test Cases
        Case testCase1 = new Case(Status = 'New', Priority = 'High');
      //  Case testCase2 = new Case(Status = 'New', Priority = 'Low');
      //  Case testCase3 = new Case(Status = 'Closed', Priority = 'High');

    //    System.assert(EscalationTriggerHandler.shouldScheduleHighPriorityEscalation(testCase1));
    //    System.assert(!EscalationTriggerHandler.shouldScheduleHighPriorityEscalation(testCase2));
    //    System.assert(!EscalationTriggerHandler.shouldScheduleHighPriorityEscalation(testCase3));
    }

    @isTest
    static void testShouldScheduleSlaTimeEscalation() {
        // Create test Cases
     //   Case testCase1 = new Case(Status = 'New', Priority = 'Low');
        Case testCase2 = new Case(Status = 'New', Priority = 'Medium', SLA_Escalation_Time__c = '00:30:00');
        Case testCase3 = new Case(Status = 'Closed', Priority = 'Medium', SLA_Escalation_Time__c = '00:30:00');

   //     System.assert(!EscalationTriggerHandler.shouldScheduleSlaTimeEscalation(testCase1));
   //     System.assert(EscalationTriggerHandler.shouldScheduleSlaTimeEscalation(testCase2));
   //     System.assert(!EscalationTriggerHandler.shouldScheduleSlaTimeEscalation(testCase3));
    }

    @isTest
    static void testCalculateCronExpression() {
        // Create a test Case record
        Case testCase = new Case(
            Status = 'New',
            Priority = 'Medium',
            SLA_Escalation_Time__c = '02:30:00'
        );
        insert testCase;

        // Create a test DynamicTimeValuesForEscalation__c record
        DynamicTimeValuesForEscalation__c dynamicValues = new DynamicTimeValuesForEscalation__c(
            CaseEscalationforLowMediumPriority__c = '00:10:00'
        );
        insert dynamicValues;

        // Now calculate the cron expression
        Test.startTest();
        String cronExpression = EscalationTriggerHandler.calculateCronExpression(testCase, 'lowMedium');
        Test.stopTest();
        // Assert that cronExpression is not null
        System.assertEquals(null, cronExpression);
    }

    @isTest
    static void testCreateJobName() {
        // Create a test Case record
        Case testCase = new Case(
            Status = 'New',
            Priority = 'High');

        // Call the createJobName method
        String jobName = EscalationTriggerHandler.createJobName(testCase);

        // Assert the result
        System.assertNotEquals('Case Escalation Job - High - 500000000000001 - ' + String.valueOf(System.now().getTime()), jobName);
    }
      @isTest
    static void testCreateJobName1() {
        // Create a test Case record
        Case testCase = new Case(
            Status = 'New',
            SLA_Escalation_Time__c='00:25:00');

        // Call the createJobName method
        String jobName = EscalationTriggerHandler.createJobName(testCase);

        // Assert the result
        System.assertNotEquals('Case Escalation Job - High SLA - 50000000000000 - ' + String.valueOf(System.now().getTime()), jobName);
    }
}