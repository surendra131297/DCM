/**
@description			: This class was to clear the Schedule job .
@Author					: Sprutiraj Panda, Surendranath Reddy, SubbaReddy Venkata 
@Last Modified By		: Subba Reddy Venkata, Sprutiraj Panda
@Last Modified On		: 25/04/2023
@Modification Log		:
Ver					Date						Author										LastModification
1.0					26/04/2023					Sprutiraj Panda           					Initial Version
												SubbaReddy Venkata
**/
public with sharing class ClearCompletedScheduleJobsClass implements schedulable{
     /**
     * @description Schedulable method to execute and abort completed cron triggers.
     * This method queries for cron triggers with a state of 'DELETED' and no next fire time.
     * It then aborts each of these cron triggers using System.abortJob().
     * @param context The SchedulableContext containing information about the scheduled job (unused in this implementation).
     */
    public void execute(SchedulableContext context) {
        CronTrigger[] cronTriggers = [SELECT Id, State, NextFireTime FROM CronTrigger WHERE State = 'DELETED' AND NextFireTime = null WITH SECURITY_ENFORCED];
        for (CronTrigger cronTrigger : cronTriggers) {
            System.abortJob(cronTrigger.Id);
        }
    }
     /**
     * @description AuraEnabled method to schedule the ClearCompletedScheduleJobsClass.
     * This method schedules the ClearCompletedScheduleJobsClass to run daily at midnight (0 0 * * * ?).
     * This will help clear any completed cron triggers with a state of 'DELETED' and no next fire time.
     */
    @AuraEnabled
    public static void completedJobsScheduleMethod(){
        System.schedule('MyScheduleJobForCompletedScheduleJobs', '0 37 16 * * ?', new ClearCompletedScheduleJobsClass());
        
    }
}