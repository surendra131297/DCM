/**
 * @description: This class is used to fetch queue details and associated users' case counts.
 * @Author: Sprutiraj Panda, Surendranath Reddy, SubbaReddy Venkata
 * @Last Modified By: Subba Reddy Venkata, Sprutiraj Panda
 * @Last Modified On: 25/04/2023
 * @Modification Log:
 * Ver  Date          Author                   Last Modification
 * 1.0  26/04/2023    Sprutiraj Panda          Initial Version
 *                   SubbaReddy Venkata
 **/
public with sharing class QueueController {

    /**
     * @description Gets a list of queues.
     * This method queries the 'Group' object to fetch all queues and their owner's name and email.
     * @return List of Group records representing queues.
     */
    @AuraEnabled
    public static List<Group> getQueues() {
        List<Group> queues = [SELECT Id, Name, Owner.Name, Owner.Email FROM Group WHERE Type = 'Queue' WITH SECURITY_ENFORCED];
        return queues;
    }

    /**
     * @description Gets a list of users associated with a specific queue along with their case counts.
     * This method queries the 'GroupMember' object to fetch the users belonging to the specified queue.
     * It then queries the 'Case' object to get the case counts for each user based on the Assigned_to__c field.
     * The result is returned as a list of UserCaseCountWrapper instances.
     * @param queueId The ID of the queue for which to fetch the users and their case counts.
     * @return List of UserCaseCountWrapper instances representing users and their case counts for the specified queue.
     */
    @AuraEnabled
    public static List<UserCaseCountWrapper> getQueueUsers(String queueId) {
        List<GroupMember> groupMembers = [SELECT UserOrGroupId FROM GroupMember WHERE GroupId = :queueId WITH SECURITY_ENFORCED];

        Set<Id> userIds = new Set<Id>();
        for (GroupMember gm : groupMembers) {
            if (gm.UserOrGroupId.getSObjectType() == User.SObjectType) {
                userIds.add(gm.UserOrGroupId);
            }
        }

        List<User> userList = [SELECT Id, Name, Username FROM User WHERE Id IN :userIds WITH SECURITY_ENFORCED];
        List<AggregateResult> caseCounts = [SELECT COUNT(Id) caseCount, Assigned_to__c FROM Case WHERE Assigned_to__c IN :userList WITH SECURITY_ENFORCED GROUP BY Assigned_to__c];

        // Create a map to store user IDs and their case counts
        Map<Id, Integer> userCaseCountMap = new Map<Id, Integer>();
        for (AggregateResult result : caseCounts) {
            Id userId = (Id) result.get('Assigned_to__c');
            Integer caseCount = (Integer) result.get('caseCount');
            userCaseCountMap.put(userId, caseCount);
        }

        // Create UserCaseCountWrapper instances and populate the list
        List<UserCaseCountWrapper> userListWithCaseCount = new List<UserCaseCountWrapper>();
        for (User user : userList) {
            Integer caseCount = userCaseCountMap.get(user.Id);
            if (caseCount != null) {
                UserCaseCountWrapper uc = new UserCaseCountWrapper();
                uc.username = user.Name;
                uc.caseCount = caseCount;
                userListWithCaseCount.add(uc);
            }
        }
        return userListWithCaseCount;
    }

    // Wrapper class to hold user name and case count
    /**
     * @description A wrapper class to hold user name and case count information.
     * This inner class provides properties to store the username and the case count associated with a user.
     */
    public class UserCaseCountWrapper {
        @AuraEnabled
        public String username;
        @AuraEnabled
        public Integer caseCount;
    }
}