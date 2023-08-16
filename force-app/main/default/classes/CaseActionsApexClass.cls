/**
 * @description This class assigns cases to different queues based on their priority.
 * @Author: Sprutiraj Panda, Surendranath Reddy, SubbaReddy Venkata, Sravani Bandaru 
 * @Last Modified By: Subba Reddy Venkata, Sprutiraj Panda
 * @Last Modified On: 25/04/2023
 * @Modification Log:
 * Ver	Date						Author									Last Modification
 * 1.0	26/04/2023					Sprutiraj Panda           					Initial Version
 * 									SubbaReddy Venkata
**/
public without sharing class CaseActionsApexClass 
{
     /**
     * @description Assign cases to appropriate queues based on specific conditions.
     * @param casesToAssign The list of cases to be assigned.
     */
    public static void assignCases(List<Case> casesToAssign)
    {
        for (Case c : casesToAssign) {
            if (shouldAssignToProductSupportQueue(c)) {
                assignToProductSupportQueue(c);
            } else if (shouldAssignToHighPriorityQueue(c)) {
                assignToHighPriorityQueue(c);
            } else if (shouldShowErrorMessage(c)) {
                showErrorMessage(c);
            }
        }
    }
    
    private static boolean shouldAssignToProductSupportQueue(Case c) {
        return c.Product__c != null && c.Skill_Name__c == null && (c.Priority == 'Low' || c.Priority == 'Medium' || c.Priority == 'High');
    }
    
    private static void assignToProductSupportQueue(Case c) {
        Group supportOnProductQueueId = [SELECT Id FROM Group WHERE Type = 'Queue' AND Name = 'Product Support Case Team' WITH SECURITY_ENFORCED LIMIT 1 ];
        c.OwnerId = supportOnProductQueueId.Id;
    }
    
    private static boolean shouldAssignToHighPriorityQueue(Case c) {
        return c.Priority == 'High' && c.Skill_Name__c == null && c.Product__c == null;
    }
    
    private static void assignToHighPriorityQueue(Case c) {
        Group priorityHighQueueId = [SELECT Id FROM Group WHERE Type = 'Queue' AND Name = 'High Priority Case Team' WITH SECURITY_ENFORCED LIMIT 1];
        c.OwnerId = priorityHighQueueId.Id;
    }
    
    private static boolean shouldShowErrorMessage(Case c) {
        return (c.Priority == 'High' || c.Priority == 'Low' || c.Priority == 'Medium') && c.Skill_Name__c != null && c.Product__c != null;
    }
    
    private static void showErrorMessage(Case c) {
        c.addError('Both Product and My Skill Do not select at a time');
    }
}