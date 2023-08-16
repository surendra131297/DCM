/**
* @description This class represents the assignment of cases based on skill to respective users using a round-robin method.
* @Author Subba Reddy
* @Last Modified By Subba Reddy, Surendranath Reddy
* @Last Modified On 05/08/2023
* @Modification Log:
* Ver Date       Author             Last Modification
* 1.0 26/04/2023 Subba Reddy        Initial Version
*     Surendranath Reddy
**/
public with sharing class SkillBasedCaseAssigner {
    /**
* @description Represents assignment parameters for a case.
*/
    public class AssignmentParameters {
        /**
*  @description Represents the case to be assigned.
*/
        public Case newCase;
         public id assignskilluserId;
        /**
*  @description Represents the list of user IDs for the skill.
*/
        public List<String> userIdList;
        
        /**
* @description Represents the set of all user IDs.
*/
        public Set<String> userIds;
        
        /**
* @description Represents the last assigned case for the skill.
*/
        public Case lastAssignedSkillCase;
        
      //  public id firstuserid;
    }
    
    /**
* @description Assigns cases to respective users based on skill using a round-robin method.
* @param caseList The list of cases to be assigned.
*/
    //global id firstuserid;
    public static void assignCases(List<Case> caseList) {
        if (caseList.isEmpty()) {
            return;
        }
        
        Map<String, List<String>> skillUserMap = buildSkillUserMap(caseList);
        if (skillUserMap.isEmpty()) {
            
            return;
        }
        List<Case> caseListttt=caseList;
        string skillName=caseListttt[0].Skill_Name__c;
        Set<String> userIds = gatherUserIds(skillUserMap);
        User_Skill__c userSkillDetails=[select User__c from User_Skill__c where Skill_Name__c=:skillName WITH SECURITY_ENFORCED limit 1];
        
        for (Case newCase : caseList) {
            if (isAssignableCase(newCase) && skillUserMap.containsKey(newCase.Skill_Name__c)) {
                Case lastAssignedSkillCase = getLastAssignedSkillCase(newCase.Skill_Name__c);
                List<String> userIdList = skillUserMap.get(newCase.Skill_Name__c);
                AssignmentParameters params = new AssignmentParameters();
                params.newCase = newCase;
                params.userIdList = userIdList;
                params.userIds = userIds;
                params.lastAssignedSkillCase = lastAssignedSkillCase;
                params.assignskilluserId=userSkillDetails.User__c;
                assignCaseToUser(params);
                
            }
        }
    }
    
    /**
*  @description Builds a map of skill names to lists of user IDs.
* @param caseList The list of cases for which to build the map.
* @return A map of skill names to user IDs.
*/
    public static Map<String, List<String>> buildSkillUserMap(List<Case> caseList) {
        Map<String, List<String>> skillUserMap = new Map<String, List<String>>();
        Set<String> skillSet = new Set<String>();
        
        for (Case caseRecord : caseList) {
            if (caseRecord.Skill_Name__c != null) {
                skillSet.add(caseRecord.Skill_Name__c);
            }
        }
        
        if (!skillSet.isEmpty()) {
            List<User_Skill__c> userSkills = [SELECT User__c, Skill_Name__c FROM User_Skill__c WHERE Skill_Name__c IN :skillSet WITH SECURITY_ENFORCED];
            
            for (User_Skill__c userSkill : userSkills) {
                skillUserMap.put(userSkill.Skill_Name__c, new List<String>());
            }
            
            for (User_Skill__c userSkill : userSkills) {
                skillUserMap.get(userSkill.Skill_Name__c).add(userSkill.User__c);
            }
        }
        
        return skillUserMap;
    }
    
    /**
*  @description Retrieves the most recently assigned case for a specific skill.
* @return The last assigned case for a specific skill.
*@param  skillName is getting case 
*/
    public static Case getLastAssignedSkillCase(String skillName) {
        List<Case> assignedCases = [SELECT Id, OwnerId, Skill_Name__c FROM Case WHERE OwnerId != null AND Skill_Name__c = :skillName WITH SECURITY_ENFORCED ORDER BY CreatedDate DESC LIMIT 1];
        return assignedCases.isEmpty() ? null : assignedCases[0];
    }
    
    
    /**
* @description  Gathers all user IDs from the skillUserMap.
* @param skillUserMap A map of skill names to user IDs.
* @return A set of user IDs.
*/
    public static Set<String> gatherUserIds(Map<String, List<String>> skillUserMap) {
        Set<String> userIds = new Set<String>();
        for (List<String> userList : skillUserMap.values()) {
            userIds.addAll(userList);
        }
        return userIds;
    }
    
    /**
*  @description Checks if a case is assignable based on skill, priority, and product.
* @param newCase The case to check for assignability.
* @return True if the case is assignable, False otherwise.
*/
    public static Boolean isAssignableCase(Case newCase) {
        return newCase.Skill_Name__c != null && isPriorityValid(newCase) && newCase.Product__c == null;
    }
    
    /**
*  @description Assigns a case to a user based on the round-robin method.
* @param params The AssignmentParameters object containing necessary parameters.
*/
    public static void assignCaseToUser(AssignmentParameters params) {
        Case newCase = params.newCase;
        List<String> userIdList = params.userIdList;
        Set<String> userIds = params.userIds;
        Case lastAssignedSkillCase = params.lastAssignedSkillCase;
        id assignskilluserId=params.assignskilluserId;
        
        if (userIds.size() <= 1) {
            //newCase.OwnerId = userIdList.isEmpty() ? null : userIdList[0];
             newCase.OwnerId= assignskilluserId; 
        } else if (lastAssignedSkillCase != null && userIdList.contains(lastAssignedSkillCase.OwnerId)) {
            List<String> userIdsList = new List<String>(userIds);
            Integer userIndex = Math.mod(userIdsList.indexOf(lastAssignedSkillCase.OwnerId) + 1, userIds.size());
            newCase.OwnerId = userIdsList[userIndex];
            
        }else{
          newCase.OwnerId= assignskilluserId; 
            
        }
    }
    
    /**
*  @description Checks if the priority of a case is valid.
* @param newCase The case to check for valid priority.
* @return True if the priority is valid, False otherwise.
*/
    public static Boolean isPriorityValid(Case newCase) {
        return newCase.Priority == 'Low' || newCase.Priority == 'Medium' || newCase.Priority == 'High';
    }
}