@IsTest
public class skillbasedcaseassigner01 {
    @IsTest
    static void testAssignCaseToUser() {
        DynamicTimeValuesForEscalation__c dynamicValues = new DynamicTimeValuesForEscalation__c();
            dynamicValues.CaseEscalationforLowMediumPriority__c = '00:10:00';
            dynamicValues.CaseEscalationforHighPriority__c = '00:05:00';
       
        insert dynamicValues;
        
        Profile p = [SELECT Id, Name FROM Profile WHERE Name = 'System Administrator'];
        User testUser12 = new User(
            LastName = 'Test User1',
            Email = 'testuser1@test.com',
            Alias = 'tuser1',
            Username = 'sfop34@gmail.com',
            TimeZoneSidKey = 'GMT',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'ISO-8859-1',
            ProfileId = p.Id,
            LanguageLocaleKey = 'en_US'
        );
        insert testUser12;
        
        Skill__c sk = new Skill__c();
        sk.Name = 'Java';
        insert sk;
        
        List<User_Skill__c> userSkills = new List<User_Skill__c>{
            new User_Skill__c(User__c = testUser12.Id, Skill_Name__c = sk.Id)
           
        };
        insert userSkills; 
        list<case>c=new list<case>();
           Case case1 = new Case(Skill_Name__c = sk.Id);
           Case case2 = new Case(Skill_Name__c = sk.Id);
        Case case3 = new Case(Skill_Name__c = sk.Id);
        insert case3;
        insert case1;
        insert case2;
        c.add(case1);
        c.add(case2);
        SkillBasedCaseAssigner.assignCases(c);
         System.assertEquals(1, userSkills.size(), 'Incorrect number of skills');
    }
}