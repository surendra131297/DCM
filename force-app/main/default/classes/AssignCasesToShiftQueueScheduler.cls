/**
 * @description This schedulable Apex class automatically assigns cases to different shifts based on their respective shift times.
 * Each case is assigned to the appropriate shift queue according to the time boundaries defined for each shift.
 * 
 * @Author Surendranath Reddy
 * @Last Modified By Surendranath Reddy
 * @Last Modified On 21/04/2023
 * @Modification Log:
 * Ver    Date          Author                  Last Modification
 * 1.0    26/04/2023    Surendranath Reddy      Initial Version
 **/
public with sharing class AssignCasesToShiftQueueScheduler implements Schedulable {
    private Map<String, Time> shiftTimings;

    /**
     * @description Constructor to initialize shift timings and other data.
     */
    public AssignCasesToShiftQueueScheduler() {
        shiftTimings = new Map<String, Time>();
        initShiftTimings();
    }

    /**
     * @description Initialize shift timings from ShiftTime__c custom settings.
     */
    private void initShiftTimings() {
        // Retrieve ShiftTime__c custom settings
        ShiftTime__c shiftTimes = ShiftTime__c.getInstance();
        if (shiftTimes != null) {
            shiftTimings.put('Morning', parseTime(shiftTimes.Shift1StartTime__c));
            shiftTimings.put('Afternoon', parseTime(shiftTimes.Shift2StartTime__c));
            shiftTimings.put('Night', parseTime(shiftTimes.Shift3StartTime__c));
        }
    }

    /**
     * @description Method to parse time value from string format and convert it to a Time instance.
     * 
     * @param timeValue The time value in the string format "hh:mm".
     * @return The parsed Time instance with seconds and milliseconds set to zero. Returns null if parsing fails.
     */
    private static Time parseTime(String timeValue) {
        try {
            // Splitting the time value string by ":" delimiter
            String[] strTimeSplit = timeValue.split(':');
            // Creating a new instance of Time with the parsed hour and minute values
            // The seconds and milliseconds are set to 0
            return Time.newInstance(Integer.valueOf(strTimeSplit[0]), Integer.valueOf(strTimeSplit[1]), 0, 0);
        } catch (Exception ex) {
            // Log the error instead of using System.debug
            return null;
        }
    }

    /**
     * @description Scheduler execution method. This method is called when the scheduler is executed, and it automatically assigns cases to different shifts.
     * Validate CRUD permission before SOQL/DML operation or enforce user mode.
     * 
     * @param sc The SchedulableContext containing information about the scheduled job (unused in this implementation).
     */
    public void execute(SchedulableContext sc) {
        // Ensure shift timings are available
        if (shiftTimings.isEmpty() || !hasCRUDPermissions()) {
            // No shift timings or insufficient permissions, exit the scheduler
            return;
        }

        // Get the map of shift queue IDs
        Map<String, Id> shiftQueueIds = getShiftQueueIds();

        // No shift queue IDs found, exit the scheduler
        if (shiftQueueIds.isEmpty()) {
            return;
        }

        // Get the cases that are in the shift queues and not closed yet
        List<Case> allShiftCases = getShiftCases(new Set<Id>(shiftQueueIds.values()));

        // Assign cases to different shifts based on their current time and update the case owners
        List<Case> allShiftsUpdatedCases = assignCasesToShifts(allShiftCases, shiftQueueIds);

        // Update cases if there are any changes
        updateCases(allShiftsUpdatedCases);
    }

    /**
     * @description Checks if the user has CRUD permissions on relevant objects.
     * 
     * @return True if the user has CRUD permissions; otherwise, false.
     */
    private Boolean hasCRUDPermissions() {
        return Schema.sObjectType.Case.isAccessible() && Schema.sObjectType.Group.isAccessible() && Schema.sObjectType.User_Skill__c.isAccessible();
    }

    /**
     * @description Gets the map of shift queue IDs based on their names.
     * 
     * @return A map with shift names as keys and their corresponding queue IDs as values.
     */
    private Map<String, Id> getShiftQueueIds() {
        Map<String, Id> shiftQueueIds = new Map<String, Id>();
        shiftQueueIds.put('Morning', getShiftQueueId('Morning Shift'));
        shiftQueueIds.put('Afternoon', getShiftQueueId('Afternoon Shift'));
        shiftQueueIds.put('Night', getShiftQueueId('Night Shift'));
        return shiftQueueIds;
    }

    /**
     * @description Gets the ID of a shift queue based on its name.
     * 
     * @param queueName The name of the shift queue.
     * @return The ID of the shift queue if found; otherwise, null.
     */
    private Id getShiftQueueId(String queueName) {
        Group shiftQueue = [SELECT Id FROM Group WHERE Type = 'Queue' AND Name = :queueName WITH SECURITY_ENFORCED LIMIT 1];
        return shiftQueue != null ? shiftQueue.Id : null;
    }

     /**
     * @description Gets the cases that belong to the shift queues and are not closed yet.
     * 
     * @param shiftQueueIds A set of shift queue IDs.
     * @return A list of cases in the specified shift queues and with status 'New'.
     */
    public List<Case> getShiftCases(Set<Id> shiftQueueIds) {
        return [SELECT Id, OwnerId, Status FROM Case WHERE Status = 'New' AND OwnerId IN :shiftQueueIds WITH SECURITY_ENFORCED];
    }

    /**
     * @description Assigns cases to different shifts based on their current time.
     * 
     * @param cases A list of cases to be assigned to shifts.
     * @param shiftQueueIds A map with shift names as keys and their corresponding queue IDs as values.
     * @return A list of cases with updated owners based on their assigned shifts.
     */
    private List<Case> assignCasesToShifts(List<Case> cases, Map<String, Id> shiftQueueIds) {
        List<Case> updatedCases = new List<Case>();
        for (Case cs : cases) {
            String currentShift = getCurrentShift();
            if (currentShift != null && shiftTimings.containsKey(currentShift)) {
                cs.OwnerId = shiftQueueIds.get(currentShift);
                if (Schema.sObjectType.Case.fields.OwnerId.isAccessible()) {
                updatedCases.add(cs);
            }
        }
        
    }
        return updatedCases;
    }

    /**
     * @description Gets the current shift based on the current time.
     * 
     * @return The name of the current shift if found; otherwise, null.
     */
    private String getCurrentShift() {
        Time currentTime = Time.newInstance(Datetime.now().hour(), Datetime.now().minute(), Datetime.now().second(), 0);
        for (String shiftName : shiftTimings.keySet()) {
            Time shiftStartTime = shiftTimings.get(shiftName);
            Time shiftEndTime = Time.newInstance(shiftStartTime.hour() + 8, shiftStartTime.minute(), 0, 0); // Assuming each shift is 8 hours long
            if (shiftStartTime != null && shiftEndTime != null && currentTime >= shiftStartTime && currentTime < shiftEndTime) {
                return shiftName;
            }
        }
        return null;
    }

    /**
     * @description Updates the specified cases in the database.
     * 
     * @param casesToUpdate A list of cases to be updated in the database.
     */
    private void updateCases(List<Case> casesToUpdate) {
        if (!casesToUpdate.isEmpty() && Schema.sObjectType.Case.isUpdateable()) {
            update casesToUpdate;
        }
    }
}