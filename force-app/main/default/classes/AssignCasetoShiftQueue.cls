/**
 * @description: This class assigns cases to different shift queues based on custom-defined shift times.
 * @Author: Surendranath Reddy, Subba Reddy Venkata, Sprutiraj Panda, Sravani Bandaru
 * @Last Modified By: Subba Reddy, Surendranath Reddy
 * @Last Modified On: 20/04/2023
 * @Modification Log:
 * Ver    Date          Author               LastModification
 * 1.0    26/04/2023    Surendranath Reddy    Initial Version
 *        Subba Reddy Venkata
 **/
public with sharing class AssignCasetoShiftQueue {
    
    /**
     * @description Method to parse time value from string format and convert it to a Time instance.
     * @param timeValue The time value in the string format "hh:mm".
     * @return The parsed Time instance with seconds and milliseconds set to zero.
     */
    public static Time parseTime(String timeValue) {
        if (String.isNotBlank(timeValue) && timeValue.contains(':')) {
            String[] strTimeSplit = timeValue.split(':');
            if (strTimeSplit.size() == 3) {
                Integer hours = Integer.valueOf(strTimeSplit[0]);
                Integer minutes = Integer.valueOf(strTimeSplit[1]);
                return Time.newInstance(hours, minutes, 0, 0);
            }
        }
        return null;
    }
    
    
    
    /**
     * @description Helper method to determine the queue owner ID based on the current time.
     *
     * @param shiftTimingInfo The object containing shift timings and the current time.
     * @return The ID of the queue owner based on the current time.
     */
    private static Id getQueueOwnerIdBasedOnTime(ShiftTimingInfo shiftTimingInfo) {
        Id morningShiftQueueId = [SELECT Id FROM Group WHERE Type = 'Queue' AND Name ='Morning Shift' limit 1].Id;
        Id afternoonShiftQueueId = [SELECT Id FROM Group WHERE Type = 'Queue' AND Name ='Afternoon Shift' limit 1].Id;
        Id nightShiftQueueId = [SELECT Id FROM Group WHERE Type = 'Queue' AND Name ='Night Shift' limit 1].Id;
        
        Time currentTime = shiftTimingInfo.getCurrentTime();
        
        if (currentTime >= shiftTimingInfo.getShift1StartTime() && currentTime < shiftTimingInfo.getShift2StartTime()) {
            return morningShiftQueueId;
        } else if (currentTime >= shiftTimingInfo.getShift2StartTime() && currentTime < shiftTimingInfo.getShift3StartTime()) {
            return  afternoonShiftQueueId;
        } else {
            return nightShiftQueueId;
        }
    }
    
    /**
     * @description Helper method to determine the shift name based on the current time.
     *
     * @param shiftTimingInfo The object containing shift timings and the current time.
     * @return The name of the shift based on the current time.
     */
    private static String getShiftNameBasedOnTime(ShiftTimingInfo shiftTimingInfo) {
        Time currentTime = shiftTimingInfo.getCurrentTime();
        
        if (currentTime >= shiftTimingInfo.getShift1StartTime() && currentTime < shiftTimingInfo.getShift2StartTime()) {
            return 'Morning Shift';
        } else if (currentTime >= shiftTimingInfo.getShift2StartTime() && currentTime < shiftTimingInfo.getShift3StartTime()) {
            return 'Afternoon Shift';
        } else {
            return 'Night Shift';
        }
    }
    
    /**
     * @description Helper method to get the assigning user ID based on the queue owner ID.
     * @param queueOwnerId The ID of the queue owner.
     * @return The ID of the user to whom the case will be assigned.
     */
    private static Id getAssigningUserId(Id queueOwnerId) {
        List<Id> userIds = new List<Id>();
        
        // Query GroupMember records to get the users belonging to the specified queue owner (queueOwnerId)
        List<GroupMember> groupMembers = [SELECT UserOrGroupId FROM GroupMember WHERE GroupId = :queueOwnerId WITH SECURITY_ENFORCED];
        
        // Extract the User IDs from the GroupMember records
        for (GroupMember gm : groupMembers) {
            if (gm.UserOrGroupId != null && gm.UserOrGroupId.getSObjectType() == User.SObjectType) {
                userIds.add(gm.UserOrGroupId);
            }
        }
        
        if (userIds.isEmpty()) {
            // If there are no users in the queue, return null or any default user ID as per your requirement.
            return null;
        } else {
            // Get the index of the last assigned user from the list of user IDs
            Integer lastIndex = (Integer) Limits.getLimitQueries() - 1;
            if (lastIndex >= userIds.size()) {
                lastIndex = userIds.size() - 1;
            }
            
            // Return the ID of the user to whom the case will be assigned
            return userIds[lastIndex];
        }
    }
    
    /**
     * @description Assign cases to shift queues based on certain conditions.
     * @param caseList The list of cases to be assigned to shift queues.
     */
    
    public static void casetoshiftqueue(List<Case> caseList) {
        
        
        ShiftTimingInfo shiftTimingInfo = getShiftTimingInfo();
        Id queueOwnerId = getQueueOwnerIdAndShiftName(shiftTimingInfo);
        
        String shiftName = (queueOwnerId != null) ? getShiftNameBasedOnTime(shiftTimingInfo) : null;
        
        Id assigningUserId = getAssigningUserId(queueOwnerId);
        
        
        //Id assigningUserId = getAssigningUserId(queueOwnerId);
        
        for (Case c : caseList) {
            if ((c.Priority == 'Low' || c.Priority == 'Medium') && c.Skill_Name__c == null && c.Product__c == null) {
                c.Assigned_to__c = assigningUserId;
                c.OwnerId = queueOwnerId;
                c.Initial_Shift_Name__c = shiftName;
            }
        }
    }
    /**
     * @description Method to retrieve shift timing information.
     * @return An instance of ShiftTimingInfo containing shift timings and current time.
     */
    public static ShiftTimingInfo getShiftTimingInfo() {
        ShiftTime__c shiftTimes = ShiftTime__c.getInstance();
        Time shift1StartTime = parseTime(shiftTimes.Shift1StartTime__c);
        Time shift2StartTime = parseTime(shiftTimes.Shift2StartTime__c);
        Time shift3StartTime = parseTime(shiftTimes.Shift3StartTime__c);
        Time currentTime = Time.newInstance(
            Datetime.now().hour(),
            Datetime.now().minute(),
            Datetime.now().second(),
            0
        );
        
        return new ShiftTimingInfo.ShiftTimeInfoBuilder()
            .setShift1StartTime(shift1StartTime)
            .setShift2StartTime(shift2StartTime)
            .setShift3StartTime(shift3StartTime)
            .setCurrentTime(currentTime)
            .build();
    }
    /**
     * @description Helper method to retrieve queue owner ID and shift name based on the current time.
     * @param shiftTimingInfo The object containing shift timings and the current time.
     * @return The ID of the queue owner.
     */
    public static Id getQueueOwnerIdAndShiftName(ShiftTimingInfo shiftTimingInfo) {
        Time currentTime = shiftTimingInfo.getCurrentTime();
        Id queueOwnerId;
        String shiftName;
        
        if (currentTime >= shiftTimingInfo.getShift1StartTime() && currentTime < shiftTimingInfo.getShift2StartTime()) {
            queueOwnerId = getQueueOwnerIdBasedOnTime(shiftTimingInfo);
            shiftName = getShiftNameBasedOnTime(shiftTimingInfo);
        } else if (currentTime >= shiftTimingInfo.getShift2StartTime() && currentTime < shiftTimingInfo.getShift3StartTime()) {
            queueOwnerId = getQueueOwnerIdBasedOnTime(shiftTimingInfo);
            shiftName = getShiftNameBasedOnTime(shiftTimingInfo);
        } else {
            queueOwnerId = getQueueOwnerIdBasedOnTime(shiftTimingInfo);
            shiftName = getShiftNameBasedOnTime(shiftTimingInfo);
        }
        
        return queueOwnerId;
    }
}