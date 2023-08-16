@IsTest
public class ShiftWiseCasesChangeJobSchedulerTest {
    @IsTest
    static void testScheduleJobMethod() {
        // Create test data
        ShiftWiseChangeScheduleJobTimeValues__c scheduleJobTimeValues =new ShiftWiseChangeScheduleJobTimeValues__c();
        scheduleJobTimeValues.ScheduleTimeForMinutes__c = '1';
        scheduleJobTimeValues.ScheduleTimeForHours__c = '13,14,15';
        insert scheduleJobTimeValues;
        List<String> hours = new List<String>{'13', '14', '15'};
            ShiftTime__c shiftTimes = new ShiftTime__c();
        	shiftTimes.Shift1StartTime__c = '03:00:00';
        	shiftTimes.Shift2StartTime__c = '11:00:00';
        	shiftTimes.Shift3StartTime__c = '12:00:00';
        //Execute the scheduled job
        Test.startTest();
      
			ShiftWiseCasesChangeJobScheduler.scheduleJobMethod();

        Test.stopTest();

        // Verify the scheduled job has been created
        List<CronTrigger> cronTriggers = [SELECT Id, State, NextFireTime,CronJobDetail.Name, CronExpression FROM CronTrigger WHERE CronJobDetail.Name = 'ShiftWise Change Cases Shift Schedule Job 3'];
        System.assertNotEquals(1, cronTriggers.size(), 'One cron trigger should be created for the scheduled job');

    }
}