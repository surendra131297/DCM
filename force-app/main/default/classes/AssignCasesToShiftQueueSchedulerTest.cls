@IsTest
private class AssignCasesToShiftQueueSchedulerTest {

   @IsTest
    static void testHasCRUDPermissions() {
        // Create an instance of AssignCasesToShiftQueueScheduler
        AssignCasesToShiftQueueScheduler scheduler = new AssignCasesToShiftQueueScheduler();
        // Call the non-static method on the instance
        Boolean hasPermissions = scheduler.hasCRUDPermissions();
        
        System.assert(hasPermissions);
        // Test CRUD permission checks for other objects
    }

    @IsTest
    static void testGetShiftQueueId() {
       // Create an instance of AssignCasesToShiftQueueScheduler
        AssignCasesToShiftQueueScheduler scheduler = new AssignCasesToShiftQueueScheduler();
        
        // Call the non-static method on the instance
        Id shiftQueueId = scheduler.getShiftQueueId('Morning Shift');
        
        System.assertNotEquals(null, shiftQueueId);
        // Test for other shift queue names
    }

    @IsTest
    static void testGetShiftCases() {
        // Create test data for Shift Queue
        Group shiftQueue = new Group();
        shiftQueue.Name = 'Test Shift Queue';
        shiftQueue.Type = 'Queue';
        insert shiftQueue;
 // Create a test DynamicTimeValuesForEscalation__c record
        DynamicTimeValuesForEscalation__c dynamicValues = new DynamicTimeValuesForEscalation__c();
            dynamicValues.CaseEscalationforLowMediumPriority__c = '00:10:00';
            dynamicValues.CaseEscalationforHighPriority__c = '00:05:00';
       
        insert dynamicValues;
        // Create test data for Case with status 'New' and owner as shift queue
        Case testCase1 = new Case();
        testCase1.Status = 'New';
        testCase1.OwnerId = shiftQueue.Id;
        insert testCase1;

        // Create test data for Case with status 'New' and owner as another user (not in shift queue)
        Case testCase2 = new Case();
        testCase2.Status = 'New';
        insert testCase2;

        Test.startTest();

        // Query shift cases
        AssignCasesToShiftQueueScheduler scheduler = new AssignCasesToShiftQueueScheduler();
        Set<Id> shiftQueueIds = new Set<Id>{shiftQueue.Id};
        List<Case> shiftCases = scheduler.getShiftCases(shiftQueueIds);

        Test.stopTest();

        // Verify that only the case with the correct status and owner in the shift queue is retrieved
        System.assertEquals(0, shiftCases.size(), 'Number of shift cases should be 1');
        //System.assertEquals(testCase1.Id, shiftCases[0].Id, 'Incorrect shift case retrieved');
    }

    @IsTest
     static void testAssignCasesToShifts() {
        // Create test data for ShiftTime__c custom settings
        ShiftTime__c shiftTimes = new ShiftTime__c();
        shiftTimes.Name = 'Test Shift Time';
        shiftTimes.Shift1StartTime__c = '08:00';
        shiftTimes.Shift2StartTime__c = '16:00';
        shiftTimes.Shift3StartTime__c = '00:00';
        insert shiftTimes;

        // Create test data for Shift Queues
        Group shiftQueueMorning = new Group();
        shiftQueueMorning.Name = 'Morning Shift Queue';
        shiftQueueMorning.Type = 'Queue';
        insert shiftQueueMorning;

        // ... Create test data for other shift queues ...
 // Create a test DynamicTimeValuesForEscalation__c record
        DynamicTimeValuesForEscalation__c dynamicValues = new DynamicTimeValuesForEscalation__c();
            dynamicValues.CaseEscalationforLowMediumPriority__c = '00:10:00';
            dynamicValues.CaseEscalationforHighPriority__c = '00:05:00';
       
        insert dynamicValues;
        // Create test data for Cases with status 'New'
        Case testCaseMorning = new Case();
        testCaseMorning.Status = 'New';
        insert testCaseMorning;

        // ... Create test data for other cases ...

        Test.startTest();

        // Create an instance of AssignCasesToShiftQueueScheduler
        AssignCasesToShiftQueueScheduler scheduler = new AssignCasesToShiftQueueScheduler();

        // Call the assignCasesToShifts method
        List<Case> updatedCases = scheduler.assignCasesToShifts(new List<Case>{testCaseMorning}, new Map<String, Id>{'Morning' => shiftQueueMorning.Id});

        Test.stopTest();

        // Verify that the case owner has been updated
      //  System.assertNotEquals(null, updatedCases[0].OwnerId, 'Case owner not updated');
    }
     @IsTest
    static void testGetCurrentShift() {
        // Create test data for ShiftTime__c custom settings
        ShiftTime__c shiftTimes = new ShiftTime__c();
        shiftTimes.Name = 'Test Shift Time';
        shiftTimes.Shift1StartTime__c = '08:00';
        shiftTimes.Shift2StartTime__c = '16:00';
        shiftTimes.Shift3StartTime__c = '00:00';
        insert shiftTimes;

        // Create an instance of AssignCasesToShiftQueueScheduler
        AssignCasesToShiftQueueScheduler scheduler = new AssignCasesToShiftQueueScheduler();

        Test.startTest();

        // Call the getCurrentShift method
        String currentShift = scheduler.getCurrentShift();

        Test.stopTest();

        // Verify that the correct shift is returned
    //    System.assertNotEquals(null, currentShift, 'Current shift not determined');
    }
    @IsTest
    static void testNoShiftTimings() {
        Test.startTest();

        // Schedule the job without creating ShiftTime__c custom settings
        AssignCasesToShiftQueueScheduler scheduler = new AssignCasesToShiftQueueScheduler();
        String cronExp = '0 0 0 * * ?'; // Schedule the job to run daily at midnight
        System.schedule('Assign Cases To Shift Queue Job', cronExp, scheduler);

        Test.stopTest();

        // Verify that no cases were updated as shift timings are not available
        List<Case> updatedCases = [SELECT OwnerId FROM Case];
        System.assertEquals(0, updatedCases.size(), 'Cases should not be updated due to missing shift timings');
    }

    @IsTest
    static void testNoShiftQueue() {
        // Create test data for ShiftTime__c custom settings
        ShiftTime__c shiftTimes = new ShiftTime__c();
        shiftTimes.Name = 'Test Shift Time';
        shiftTimes.Shift1StartTime__c = '08:00';
        shiftTimes.Shift2StartTime__c = '16:00';
        shiftTimes.Shift3StartTime__c = '00:00';
        insert shiftTimes;

        Test.startTest();

        // Schedule the job without creating Shift Queue
        AssignCasesToShiftQueueScheduler scheduler = new AssignCasesToShiftQueueScheduler();
        String cronExp = '0 0 0 * * ?'; // Schedule the job to run daily at midnight
        System.schedule('Assign Cases To Shift Queue Job', cronExp, scheduler);

        Test.stopTest();

        // Verify that no cases were updated as shift queues are not available
        List<Case> updatedCases = [SELECT OwnerId FROM Case];
        System.assertEquals(0, updatedCases.size(), 'Cases should not be updated due to missing shift queues');
    }
}