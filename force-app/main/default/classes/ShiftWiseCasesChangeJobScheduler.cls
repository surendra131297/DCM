/**
 * @description: ShiftWiseCasesChangeJobScheduler 
 * @Author: Subba Reddy
 * @Last Modified By: Subba Reddy
 * @Last Modified On: 28/04/2023
 * @Modification Log:
 * Ver    Date            Author             Last Modification
 * 1.0    26/04/2023      Subba Reddy        Initial Version
 **/
public with sharing class ShiftWiseCasesChangeJobScheduler {
    /**
* @description Schedule a job to run AssignCasesToShiftQueueScheduler at specified intervals.
* @AuraEnabled

**/
    @AuraEnabled
    public static void scheduleJobMethod() {
        ShiftWiseChangeScheduleJobTimeValues__c shiftQueueSchedule = ShiftWiseChangeScheduleJobTimeValues__c.getOrgDefaults();
        string k=shiftQueueSchedule.ScheduleTimeForMinutes__c;
        AssignCasesToShiftQueueScheduler scheduler = new AssignCasesToShiftQueueScheduler(); 
      String schedule = '0 ' + shiftQueueSchedule.ScheduleTimeForMinutes__c + ' ' + shiftQueueSchedule.ScheduleTimeForHours__c + ' * * ?'; // runs at midnight, 3am, 11am, 7pm
       	     
        String jobName = 'ShiftWise Change Cases Shift Schedule Job'; 
        System.schedule(jobName, schedule, scheduler);
    }
}