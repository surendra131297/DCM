@isTest
public class AssignCasetoShiftQueueTest {

    @isTest static void testCasetoShiftQueueAssignment() {
        testShiftTimeAndGroups();
        testCaseAssignments();
       // testInvalidShiftTime();
    }
@isTest
    static void testShiftTimeAndGroups() {
        // Create and insert ShiftTime__c record
        ShiftTime__c shiftTimes = new ShiftTime__c(
            Shift1StartTime__c = '08:00:00',
            Shift2StartTime__c = '16:00:00',
            Shift3StartTime__c = '21:00:00'
        );
        insert shiftTimes;

        // Create Queue Groups
        Group morningShiftGroup = new Group(Type = 'Queue', Name = 'Morning Shift');
        Group afternoonShiftGroup = new Group(Type = 'Queue', Name = 'Afternoon Shift');
        Group nightShiftGroup = new Group(Type = 'Queue', Name = 'Night Shift');
        insert new List<Group>{ morningShiftGroup, afternoonShiftGroup, nightShiftGroup };

        // Create Users and add them to groups
        User user1 = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name='Standard User'].Id,
            LastName = 'User1',
            Email = 'user1@example.com',
            Username = 'mission@example.com',
            Alias = 'u1',
            TimeZoneSidKey = 'GMT',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        User user2 = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name='Standard User'].Id,
            LastName = 'User2',
            Email = 'user2@example.com',
            Username = 'misson02@example.com',
            Alias = 'u2',
            TimeZoneSidKey = 'GMT',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        insert new List<User>{ user1, user2 };
       
    }
@isTest
    static void testCaseAssignments() {
        // Create test cases
        Case case1 = new Case(Priority = 'Low', Status = 'New',Origin = 'Phone', Subject = 'case1',SLA_Escalation_Time__c = '00:04:00');
        Case case2 = new Case(Priority = 'High', Status = 'New',Origin = 'Phone', Subject = 'case2',SLA_Escalation_Time__c = '00:04:00');
        Case case3 = new Case(Priority = 'Medium', Status = 'New',Origin = 'Phone', Subject = 'case3',SLA_Escalation_Time__c = '00:04:00');

        insert case1;
        insert case2;
        insert case3;
      Test.startTest();
        AssignCasetoShiftQueue.casetoshiftqueue(new List<Case>{ case1, case2, case3 });
        Test.stopTest();

        // Verify case assignments and ownership
        Case updatedCase1 = [SELECT Assigned_to__c, OwnerId, Initial_Shift_Name__c FROM Case WHERE Id = :case1.Id];
        Case updatedCase2 = [SELECT Assigned_to__c, OwnerId, Initial_Shift_Name__c FROM Case WHERE Id = :case2.Id];
        Case updatedCase3 = [SELECT Assigned_to__c, OwnerId, Initial_Shift_Name__c FROM Case WHERE Id = :case3.Id];

  //      System.assertEquals(user1.Id, updatedCase1.Assigned_to__c);
  //      System.assertEquals(morningShiftGroup.Id, updatedCase1.OwnerId);
  //      System.assertEquals('Morning Shift', updatedCase1.Initial_Shift_Name__c);

  //      System.assertEquals(user2.Id, updatedCase2.Assigned_to__c);
  //      System.assertEquals(afternoonShiftGroup.Id, updatedCase2.OwnerId);
  //      System.assertEquals('Afternoon Shift', updatedCase2.Initial_Shift_Name__c);

  //      System.assertEquals(user1.Id, updatedCase3.Assigned_to__c);
  //      System.assertEquals(morningShiftGroup.Id, updatedCase3.OwnerId);
  //      System.assertEquals('Morning Shift', updatedCase3.Initial_Shift_Name__c);
    }
@isTest
    static void testInvalidShiftTime() {
        // Create ShiftTime__c record with invalid shift time
        // 
          // Create a test DynamicTimeValuesForEscalation__c record
        DynamicTimeValuesForEscalation__c dynamicValues = new DynamicTimeValuesForEscalation__c();
            dynamicValues.CaseEscalationforLowMediumPriority__c = '00:10:00';
            dynamicValues.CaseEscalationforHighPriority__c = '00:05:00';
       
        insert dynamicValues;
        
        ShiftTime__c invalidShiftTimes = new ShiftTime__c(
            Shift1StartTime__c = '03:00:00',
            Shift2StartTime__c = '11:00:00', 
            Shift3StartTime__c = '19:00:00'
        );
        insert invalidShiftTimes;

        Case case4 = new Case(Priority = 'Low', Status = 'New',Origin = 'Phone', Subject = 'case4');
        insert case4;

        Test.startTest();
        AssignCasetoShiftQueue.casetoshiftqueue(new List<Case>{ case4 });
        Test.stopTest();

        Case updatedCase4 = [SELECT Assigned_to__c, OwnerId, Initial_Shift_Name__c FROM Case WHERE Id = :case4.Id];

        // Set the current time for the test
        Datetime now = Datetime.now();
        Time currentTime = Time.newInstance(now.hour(), now.minute(), now.second(), 0);
 // Create test cases
        Case case1 = new Case(Priority = 'Low', Status = 'New',Origin = 'Phone', Subject = 'case1');
        Case case2 = new Case(Priority = 'High', Status = 'New',Origin = 'Phone', Subject = 'case2');
        Case case3 = new Case(Priority = 'Medium', Status = 'New',Origin = 'Phone', Subject = 'case3');
        insert case1;
        insert case2;
     //   Test.startTest();
        AssignCasetoShiftQueue.casetoshiftqueue(new List<Case>{ case1, case2 });
     //   Test.stopTest();

        // Verify case assignments and ownership
        Case updatedCase1 = [SELECT Assigned_to__c, OwnerId, Initial_Shift_Name__c FROM Case WHERE Id = :case1.Id];
        Case updatedCase2 = [SELECT Assigned_to__c, OwnerId, Initial_Shift_Name__c FROM Case WHERE Id = :case2.Id];

  //      System.assertEquals(user1.Id, updatedCase1.Assigned_to__c);
  //      System.assertEquals(morningShiftGroup.Id, updatedCase1.OwnerId);
  //      System.assertEquals('Morning Shift', updatedCase1.Initial_Shift_Name__c);

  //      System.assertEquals(user2.Id, updatedCase2.Assigned_to__c);
  //      System.assertEquals(afternoonShiftGroup.Id, updatedCase2.OwnerId);
  //      System.assertEquals('Afternoon Shift', updatedCase2.Initial_Shift_Name__c);
    }
}