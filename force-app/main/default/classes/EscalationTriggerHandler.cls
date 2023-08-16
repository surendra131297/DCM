/**
* @description	 EscalationTriggerHandler 
* @Author	 Surendranath Reddy
* @Last Modified By	 Subba Reddy,Surendranath Reddy
* @Last Modified On 28/04/2023
* @Modification Log
* Ver    Date            Author             Last Modification
* 1.0    7/08/2023      Surendranath Reddy        Initial Version
**/
public with sharing class EscalationTriggerHandler {
     /**
     * @description BatchJobScheduler class schedules batches of jobs for execution.
     */
    public with Sharing  class BatchJobScheduler implements System.Schedulable {
        private List<System.Schedulable> jobsToSchedule;
        /**
     * @description Constructs a new instance of the BatchJobScheduler class with a list of jobs to schedule.
     * 
     * @param jobs A list of System.Schedulable jobs to be scheduled and executed in batches.
     */
        public BatchJobScheduler(List<System.Schedulable> jobs) {
            this.jobsToSchedule = jobs;
        }
         /**
     * @description Executes the scheduled batch jobs.
     * 
     * @param sc The context in which the job is being executed.
     */
        public void execute(SchedulableContext sc) {
            Database.executeBatch((Database.Batchable<Object>) jobsToSchedule);
        }
    }
    
    /**
     * @description ScheduleEscalation method schedules escalations for new cases based on different scenarios.
     * @param newCases List of new Case records.
     */
    public static void scheduleEscalation(List<Case> newCases) {
        List<System.Schedulable> jobsToSchedule = new List<System.Schedulable>();
        String cronExpression = '';
        Integer batchSize = 10; // Set the batch size based on your needs
        
        for (Case c : newCases) {
            System.Schedulable job = null;
            
            if (shouldScheduleLowMediumEscalation(c)) {
                cronExpression = calculateCronExpression(c, 'lowMedium');                
                job = new CaseEscalation(c, c.Id);
            } else if (shouldScheduleHighPriorityEscalation(c)) {
                cronExpression = calculateCronExpression(c, 'highPriority');
                job = new CaseEscalation(c, c.Id);
            } else if (shouldScheduleSlaTimeEscalation(c)) {
                cronExpression = calculateCronExpression(c, 'slaTime');
                job = new CaseEscalation(c, c.Id);
            }
            
            if (job != null) {
                jobsToSchedule.add(job);
            }
        }
        
        if (!jobsToSchedule.isEmpty()) {
            scheduleJobsInBatches(jobsToSchedule, cronExpression, batchSize);
        }
    }
    /**
     * @description ScheduleJobsInBatches method schedules batches of jobs.
     * @param jobsToSchedule List of jobs to schedule.
     * @param cronExpression Cron expression for scheduling.
     * @param batchSize Size of each batch.
     */
    private static void scheduleJobsInBatches(List<System.Schedulable> jobsToSchedule, String cronExpression, Integer batchSize) {
        if (jobsToSchedule.isEmpty() || String.isBlank(cronExpression) || batchSize <= 0) {
            return;
        }
 Integer totalJobs = jobsToSchedule.size();
    
    for (Integer i = 0; i < totalJobs; i += batchSize) {
        Integer endIndex = Math.min(i + batchSize, totalJobs);
        
        List<System.Schedulable> batch = new List<System.Schedulable>();
        for (Integer j = i; j < endIndex; j++) {
            batch.add(jobsToSchedule[j]);
        }
        
        String jobName = generateJobName(batch);
        
        // Schedule the batch jobs later, outside the loop
        scheduleBatchJobs(jobName, cronExpression, batch);
    }
}
/**
     * @description ScheduleBatchJobs method schedules batch jobs if future call limits allow.
     * @param jobName Name of the job.
     * @param cronExpression Cron expression for scheduling.
     * @param batch List of batch jobs to schedule.
     */
private static void scheduleBatchJobs(String jobName, String cronExpression, List<System.Schedulable> batch) {
    // Check available future calls before scheduling
    if (Limits.getLimitFutureCalls() - Limits.getFutureCalls() > 0) {
        System.schedule(jobName, cronExpression, new BatchJobScheduler(batch));
    } 
}

    /**
     * @description GenerateJobName method generates a name for the batch job.
     * @param batch List of batch jobs.
     * @return Name of the batch job.
     */
    private static String generateJobName(List<System.Schedulable> batch) {
        List<String> jobParts = new List<String>();
        for (System.Schedulable job : batch) {
            CaseEscalation caseJob = (CaseEscalation) job;
            jobParts.add(caseJob.getCaseId() + ' - ' + caseJob.getCasePriority());
        }
        jobParts.add(String.valueOf(System.now().getTime()));
        
        return 'Batch of Case Escalation Jobs - ' + String.join(jobParts, ', ');
    }
    /**
* @description Checks if low or medium priority escalation should be scheduled for the case.
* @param c Case record.
* @return True if escalation should be scheduled, false otherwise.
*/
    private static boolean shouldScheduleLowMediumEscalation(Case c) {
        return c.Status != 'Escalated' && c.Status != 'Closed' &&
            c.Priority != 'High' && (c.SLA_Escalation_Time__c == null || c.SLA_Escalation_Time__c == '');
    }
    /**
* @description Checks if low or medium priority escalation should be scheduled for the case.
* @param c Case record.
* @return True if escalation should be scheduled, false otherwise.
*/
    private static boolean shouldScheduleHighPriorityEscalation(Case c) {
        return c.Status != 'Escalated' && c.Status != 'Closed' &&
            c.Priority == 'High' && (c.SLA_Escalation_Time__c == null || c.SLA_Escalation_Time__c == '');
    }
    /**
* @description Checks if SLa Escalation Time is Not equal Null.
* @param c Case record.
* @return True if escalation should be scheduled, false otherwise.
*/
    private static boolean shouldScheduleSlaTimeEscalation(Case c) {
        return c.Status != 'Escalated' && c.Status != 'Closed' &&
            c.SLA_Escalation_Time__c != null && c.SLA_Escalation_Time__c != '';
    }
/**
 * @description Calculates the cron expression for scheduling escalations based on the given scenario.
 * @param c The Case record for which to calculate the cron expression.
 * @param scenario The scenario for which to calculate the cron expression ('lowMedium', 'highPriority', or 'slaTime').
 * @return The calculated cron expression for scheduling escalations.
 */
public static String calculateCronExpression(Case c, String scenario) {
    DynamicTimeValuesForEscalation__c dynamicCaseEscalationMentionedTimeValue = DynamicTimeValuesForEscalation__c.getInstance();
    String timeString;

    System.debug('dynamicCaseEscalationMentionedTimeValue: ' + dynamicCaseEscalationMentionedTimeValue);
    System.debug('c: ' + c);

    if (scenario.equals('lowMedium')) {
        timeString = dynamicCaseEscalationMentionedTimeValue.CaseEscalationforLowMediumPriority__c;
    } else if (scenario.equals('highPriority')) {
        timeString = dynamicCaseEscalationMentionedTimeValue.CaseEscalationforHighPriority__c;
    } else if (scenario.equals('slaTime')) {
        timeString = c.SLA_Escalation_Time__c;
    } else {
        return null; // Handle unsupported scenario
    }
    system.debug('esc time : ' + timeString);
   
    List<String> timeComponents = timeString.split(':');
    
    Integer hours = Integer.valueOf(timeComponents[0]);
    Integer minutes = Integer.valueOf(timeComponents[1]);
    //Integer seconds = Integer.valueOf(timeComponents[2]);
    
    // Check if CreatedDate is null
    if (c.CreatedDate == null) {
        return null;
    }
    
    DateTime createdDateTime = c.CreatedDate;
    Integer createdHour = createdDateTime.hour();
    Integer createdDay = createdDateTime.day();
    Integer createdMonth = createdDateTime.month();
    Integer createdYear = createdDateTime.year();
    Integer createdMinute = createdDateTime.minute();
    Integer createdSecond = createdDateTime.second();
    
    Integer escalatedHour;
    Integer escalatedDay;
    
    Integer totalMinutes = createdMinute + minutes;
    Integer extraHours = totalMinutes / 60;
    Integer adjustedMinutes = Math.mod(totalMinutes, 60);
    
    escalatedHour = createdHour + hours + extraHours;
    
    if (escalatedHour > 23) {
        escalatedHour = escalatedHour - 24;
        escalatedDay = createdDay + 1;
    } else {
        escalatedDay = createdDay;
    }
    
    // Handle months with 30 days
    Integer daysInMonth = Date.daysInMonth(createdYear, createdMonth);
    if (escalatedDay > daysInMonth) {
        escalatedDay = escalatedDay - daysInMonth;
        createdMonth++; // Increment the month
    }
    
    String scheduledHour = String.valueOf(escalatedHour);
    String scheduledDay = String.valueOf(escalatedDay);
    String scheduledMinute = String.valueOf(adjustedMinutes);
    String scheduledMonth = String.valueOf(createdMonth);
    String scheduledYear = String.valueOf(createdYear);
    String scheduledSecond = String.valueOf(createdSecond);
    
    String cronExpression = scheduledSecond + ' ' + scheduledMinute + ' ' + scheduledHour + ' ' + scheduledDay + ' ' + scheduledMonth + ' ? ' + scheduledYear;
    
    return cronExpression;
}

    /**
* @description Creating a Schedule JobName.
* @param c Case record.
* @return True if escalation should be scheduled, false otherwise.
*/
        @TestVisible
    private static String createJobName(Case c) {
        String jobName = 'Case Escalation Job - ' + c.Priority + ' - ' + c.Id + ' - ' + String.valueOf(System.now().getTime());
        return jobName;
    }
}