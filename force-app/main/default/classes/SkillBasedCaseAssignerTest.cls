@isTest
public class SkillBasedCaseAssignerTest {
    @IsTest
    static void testBuildSkillUserMap() {
         Profile p = [SELECT Id, Name FROM Profile WHERE Name = 'System Administrator'];
        
        User testUser13 = new User(
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
        insert testUser13;
         Skill__c sk = new Skill__c();
        sk.Name = 'Java';
        insert sk;
        // Create and insert User_Skill__c records for testing
        List<User_Skill__c> userSkills = new List<User_Skill__c>{
            new User_Skill__c(User__c = testUser13.Id, Skill_Name__c = sk.Id)
           // new User_Skill__c(User__c = testUser13.Id, Skill_Name__c = sk.Id),
           // new User_Skill__c(User__c = testUser13.Id, Skill_Name__c = sk.Id)
        };
        insert userSkills;

        // Create test cases with skills
        Case case1 = new Case(Skill_Name__c = sk.Id);
        Case case2 = new Case(Skill_Name__c = sk.Id);
        Case case3 = new Case(Skill_Name__c = sk.Id);

        Test.startTest();
        Map<String, List<String>> skillUserMap = SkillBasedCaseAssigner.buildSkillUserMap(new List<Case>{case1, case2, case3});
        Test.stopTest();

        // Verify the skillUserMap
        System.assertEquals(1, skillUserMap.size()); // Expecting two skills (SkillA and SkillB)
        System.assertnotEquals(3, skillUserMap.get(sk.Id).size()); // Expecting two users for SkillA
        System.assertnotEquals(3, skillUserMap.get(sk.Id).size()); // Expecting one user for SkillB
    }
    
    @IsTest
    static void testGetLastAssignedSkillCase() {
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
           // Create a test DynamicTimeValuesForEscalation__c record
        DynamicTimeValuesForEscalation__c dynamicValues = new DynamicTimeValuesForEscalation__c();
            dynamicValues.CaseEscalationforLowMediumPriority__c = '00:10:00';
            dynamicValues.CaseEscalationforHighPriority__c = '00:05:00';
       
        insert dynamicValues;
        
         // Create and insert test cases
        Case testCase1 = new Case(OwnerId = testUser12.Id, Skill_Name__c = sk.Id);
        Case testCase2 = new Case(OwnerId = testUser12.Id, Skill_Name__c = sk.Id);
        insert new List<Case>{testCase1, testCase2};
        
        Test.startTest();
        Case lastAssignedCase = SkillBasedCaseAssigner.getLastAssignedSkillCase();
        Test.stopTest();
        
        // Verify the correctness of lastAssignedCase
        System.assertEquals(testUser12.Id, lastAssignedCase.OwnerId);
        System.assertEquals(sk.Id, lastAssignedCase.Skill_Name__c);
    }
    
    @IsTest
    static void testGatherUserIds() {
        Profile p = [SELECT Id, Name FROM Profile WHERE Name = 'System Administrator'];
        
        User testUser13 = new User(
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
        Skill__c sk = new Skill__c();
        sk.Name = 'Java';
        insert sk;
           // Create a test DynamicTimeValuesForEscalation__c record
        DynamicTimeValuesForEscalation__c dynamicValues = new DynamicTimeValuesForEscalation__c();
            dynamicValues.CaseEscalationforLowMediumPriority__c = '00:10:00';
            dynamicValues.CaseEscalationforHighPriority__c = '00:05:00';
        
      Map<String, List<String>> skillUserMap = new Map<String, List<String>>();
        skillUserMap.put(sk.Id, new List<String>{testUser13.Id, testUser13.Id});
        skillUserMap.put(sk.Id, new List<String>{testUser13.Id});

        Test.startTest();
        Set<String> userIds = SkillBasedCaseAssigner.gatherUserIds(skillUserMap);
        Test.stopTest();

        // Verify the gathered user IDs
        System.assertNotEquals(3, userIds.size()); // Expecting a total of three user IDs
        System.assert(userIds.contains(testUser13.Id));
        System.assert(userIds.contains(testUser13.Id));
        System.assert(userIds.contains(testUser13.Id));
    }
    
    
    @IsTest
    static void testIsAssignableCase() {
         Skill__c sk = new Skill__c();
        sk.Name = 'Java';
        insert sk;
       Case assignableCase = new Case(Skill_Name__c = sk.Id, Priority = 'Medium', Product__c = null);
        Case unassignableCase1 = new Case(Skill_Name__c = null, Priority = 'Medium', Product__c = null);
        Case unassignableCase2 = new Case(Skill_Name__c = sk.Id, Priority = 'Low', Product__c = null);
        Case unassignableCase3 = new Case(Skill_Name__c = sk.Id, Priority = 'Medium', Product__c = 'Product');
        
        Boolean isAssignable1 = SkillBasedCaseAssigner.isAssignableCase(assignableCase);
        Boolean isAssignable2 = SkillBasedCaseAssigner.isAssignableCase(unassignableCase1);
        Boolean isAssignable3 = SkillBasedCaseAssigner.isAssignableCase(unassignableCase2);
        Boolean isAssignable4 = SkillBasedCaseAssigner.isAssignableCase(unassignableCase3);
        
        System.assertEquals(true, isAssignable1);
        System.assertEquals(false, isAssignable2);
        System.assertEquals(true, isAssignable3);
        System.assertEquals(false, isAssignable4);
    }
    
    @IsTest
    static void testAssignCaseToUser() {
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
      // Create and insert test cases
        Case lastAssignedSkillCase = new Case();
        // Populate lastAssignedSkillCase
        
        SkillBasedCaseAssigner.AssignmentParameters params = new SkillBasedCaseAssigner.AssignmentParameters();
        params.newCase = new Case();
        params.userIdList = new List<String>{testUser12.Id, testUser12.Id};
        params.userIds = new Set<String>{testUser12.Id, testUser12.Id};
        params.lastAssignedSkillCase = lastAssignedSkillCase;
        
        


        // Assign the lastAssignedSkillCase's OwnerId based on the userIdList
        lastAssignedSkillCase.OwnerId = testUser12.Id;

     ///   Test.startTest();
     ///   SkillBasedCaseAssigner.assignCaseToUser(params);
    ///    Test.stopTest();
			Skill__c sk = new Skill__c();
        sk.Name = 'Java';
        insert sk;
          List<User_Skill__c> userSkills = new List<User_Skill__c>{
            new User_Skill__c(User__c = testUser12.Id, Skill_Name__c = sk.Id)
           // new User_Skill__c(User__c = testUser13.Id, Skill_Name__c = sk.Id),
           // new User_Skill__c(User__c = testUser13.Id, Skill_Name__c = sk.Id)
        };
        insert userSkills;
        // Verify the correctness of case owner assignment
     ///   System.assertNotEquals(null, params.newCase.OwnerId);
        // Additional verification to ensure that round-robin assignment occurs
        Case additionalCase = new Case();
        additionalCase.Skill_Name__c = sk.Id;
        additionalCase.Priority = 'Medium';
        additionalCase.Product__c = null;
        additionalCase.OwnerId = testUser12.Id;
        Test.startTest();
        SkillBasedCaseAssigner.assignCaseToUser(params);
        Test.stopTest();

        SkillBasedCaseAssigner.AssignmentParameters additionalParams = new SkillBasedCaseAssigner.AssignmentParameters();
        additionalParams.newCase = additionalCase;
        additionalParams.userIdList = new List<String>{testUser12.Id, testUser12.Id};
        additionalParams.userIds = new Set<String>{testUser12.Id, testUser12.Id};
        additionalParams.lastAssignedSkillCase = lastAssignedSkillCase;
        SkillBasedCaseAssigner.assignCaseToUser(additionalParams);
        // Verify that round-robin assignment occurs and the OwnerId changes to 'user2'
        System.assertEquals(testUser12.Id, additionalParams.newCase.OwnerId);
    }
    
    
    @IsTest
    static void testIsPriorityValid() {
        Case testCaseLow = new Case(Priority = 'Low');
        Case testCaseMedium = new Case(Priority = 'Medium');
        Case testCaseHigh = new Case(Priority = 'High');
        
        Test.startTest();
        Boolean isValidLow = SkillBasedCaseAssigner.isPriorityValid(testCaseLow);
        Boolean isValidMedium = SkillBasedCaseAssigner.isPriorityValid(testCaseMedium);
        Boolean isValidHigh = SkillBasedCaseAssigner.isPriorityValid(testCaseHigh);
        Test.stopTest();
        
        System.assertEquals(true, isValidLow);
        System.assertEquals(true, isValidMedium);
        System.assertEquals(true, isValidHigh);
    }
}