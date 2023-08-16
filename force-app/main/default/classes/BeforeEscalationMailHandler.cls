/**
 * @description This class handles scheduling of jobs for case escalation emails based on custom settings.
 * @Author: Surendranath Reddy
 * @Last Modified By: Surendranath Reddy, Subba Reddy
 * @Last Modified On: 02/06/2023
 * @Modification Log:
 * Ver	Date				Author								Last Modification
 * 1.0	28/05/2023		Surendranath Reddy, Subba Reddy		Initial Version
**/
public class BeforeEscalationMailHandler {

   /**
     * @description Schedules the before escalation job for cases based on their priority.
     * @param newCases The list of new Case records to be processed for scheduling the job.
     */
    public static void scheduleBeforeEscalation(List<Case> newCases) {
        for (Case c : newCases) {
            if (c.Status != 'Escalated' && c.Status != 'Closed') {
                if (c.Priority != 'High') {
                    scheduleCaseEscalation(c, 'BeforeCaseEscalationTimeForEmailAlert__c');
                } else {
                    scheduleCaseEscalation(c, 'BeforeEscEmailAlertforHIGHpriority__c');
                }
            }
        }
    }

   /**
     * @description Schedules the case escalation job based on the specified time value.
     * @param c The Case record to be processed for scheduling the job.
     * @param customSettingField The field name in the Custom Settings containing the escalation time value.
     */
     private static void scheduleCaseEscalation(Case c, String customSettingField) {
        DynamicTimeValuesForEscalation__c escalationTimeValue = DynamicTimeValuesForEscalation__c.getInstance();
        if (escalationTimeValue != null) {
            String timeString = (String)escalationTimeValue.get(customSettingField); // Explicit casting to String
            if (timeString != null) {
                DateTime createdDateTime = c.CreatedDate;
                DateTime escalatedDateTime = calculateEscalatedDateTime(createdDateTime, timeString);
                String cronExpression = getFormattedCronExpression(escalatedDateTime);
                System.schedule(getJobName(c, customSettingField), cronExpression, new SendMailtoQueueMembers(c, c.Id));
            }
        }
    }

    /**
     * @description Calculates the escalated DateTime based on the specified time value.
     * @param createdDateTime The DateTime when the Case was created.
     * @param timeString The time value in the format "HH:mm:ss".
     * @return The DateTime representing the escalated time.
     */
    @TestVisible
    private static DateTime calculateEscalatedDateTime(DateTime createdDateTime, String timeString) {
        List<String> timeComponents = timeString.split(':');
        Integer hours = Integer.valueOf(timeComponents[0]);
        Integer minutes = Integer.valueOf(timeComponents[1]);
        Integer seconds = Integer.valueOf(timeComponents[2]);

        Integer totalMinutes = createdDateTime.minute() + minutes;
        Integer extraHours = totalMinutes / 60;
        Integer adjustedMinutes = Math.mod(totalMinutes, 60);
        Integer escalatedHour = createdDateTime.hour() + hours + extraHours;

        Integer escalatedDay;
        if (escalatedHour > 23) {
            escalatedHour -= 24;
            escalatedDay = createdDateTime.day() + 1;
        } else {
            escalatedDay = createdDateTime.day();
        }

        Integer daysInMonth = Date.daysInMonth(createdDateTime.year(), createdDateTime.month());
        if (escalatedDay > daysInMonth) {
            escalatedDay -= daysInMonth;
        }

        return DateTime.newInstance(createdDateTime.year(), createdDateTime.month(), escalatedDay, escalatedHour, adjustedMinutes, seconds);
    }

    /**
     * @description Formats the DateTime into a cron expression.
     * @param dt The DateTime to be formatted.
     * @return The cron expression in the format "ss mm HH dd MM ? yyyy".
     */
    @TestVisible
     private static String getFormattedCronExpression(DateTime dt) {
        return '' + dt.second() + ' ' + dt.minute() + ' ' + dt.hour() + ' ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();
    }

    /**
     * @description Generates a job name based on the Case Id and custom setting field.
     * @param c The Case record.
     * @param customSettingField The custom setting field name.
     * @return The job name.
     */
    @TestVisible
   private static String getJobName(Case c, String customSettingField) {
        String sanitizedField = customSettingField.replaceAll('[^a-zA-Z0-9]', '_'); // Replace non-alphanumeric characters with underscore
        return 'Dynamic_Case_Before_Escalation_' + sanitizedField + '_Schedule_Date_and_Time_' + c.Id;
    }
}