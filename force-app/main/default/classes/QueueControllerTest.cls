@isTest
public class QueueControllerTest {
    
    @TestSetup
    static void setupTestData() {
        // Create a test queue
        Group testQueue = new Group(Name = 'Test Queue', Type = 'Queue');
        insert testQueue;
        
        // Create test users with required fields set
        User testUser1 = new User(
            LastName = 'Test User1',
            Email = 'testuser1@test.com',
            Alias = 'tuser1',
            Username='sfop34@gmail.com',
            TimeZoneSidKey = 'GMT',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'ISO-8859-1',
            ProfileId = getProfileId('Standard User'), // Replace 'Standard User' with the actual Profile Name
            LanguageLocaleKey = 'en_US'
        );
        
        User testUser2 = new User(
            LastName = 'Test User2',
            Email = 'testuser2@test.com',
            Alias = 'tuser2',
            TimeZoneSidKey = 'GMT',
            Username='port3@gmail.com',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'ISO-8859-1',
            ProfileId = getProfileId('Standard User'), // Replace 'Standard User' with the actual Profile Name
            LanguageLocaleKey = 'en_US'
        );
        
        insert new List<User>{ testUser1, testUser2 };
            
            // Add users to the queue
            insert new List<GroupMember>{
                new GroupMember(UserOrGroupId = getUserByName('Test User1').Id, GroupId = testQueue.Id),
                    new GroupMember(UserOrGroupId = getUserByName('Test User2').Id, GroupId = testQueue.Id)
                    };
                        }
    
    @isTest
    public static void testGetQueues() {
        // Test the getQueues method
        
        // Call the method and get the result
        List<Group> queues = QueueController.getQueues();
        
        // Assert that the result contains the test queue
        System.assertEquals(7, queues.size(),'Queue size');
        System.assertEquals('Afternoon Shift', queues[0].Name,'Queue Name');
    }
    
    @isTest
    public static void testGetQueueUsers() {
        // Test the getQueueUsers method
        
        // Retrieve the test queue created in @TestSetup
        Group testQueue = [SELECT Id, Name FROM Group WHERE Name = 'Test Queue' LIMIT 1];
        // Create a test DynamicTimeValuesForEscalation__c record
        DynamicTimeValuesForEscalation__c dynamicValues = new DynamicTimeValuesForEscalation__c();
        dynamicValues.CaseEscalationforLowMediumPriority__c = '00:10:00';
        dynamicValues.CaseEscalationforHighPriority__c = '00:05:00';
        
        insert dynamicValues;
        // Create test cases assigned to the test users
        Case testCase1 = new Case(Assigned_to__c = getUserByName('Test User1').Id, Status = 'New');
        Case testCase2 = new Case(Assigned_to__c = getUserByName('Test User1').Id, Status = 'Closed');
        Case testCase3 = new Case(Assigned_to__c = getUserByName('Test User2').Id, Status = 'Escalated');
        insert new List<Case>{ testCase1, testCase2, testCase3 };
            
            // Call the method and get the result
            List<QueueController.UserCaseCountWrapper> userCaseCounts = QueueController.getQueueUsers(testQueue.Id);
        
        // Assert that the result contains the correct user case counts
        System.assertEquals(0, userCaseCounts.size(),'Defined Queue Size');
        for (QueueController.UserCaseCountWrapper uc : userCaseCounts) {
            if (uc.username.equals('Test User1')) {
                System.assertEquals(1, uc.caseCount,'user count'); // Only 1 open case for testUser1
            } else if (uc.username.equals('Test User2')) {
                System.assertEquals(1, uc.caseCount,'count the Queue'); // Only 1 open case for testUser2
            } else {
                System.assert(false, 'Unexpected user in the result.'); // Test failure
            }
        }
    }
    
    
    // Helper method to get Profile Id by Profile Name
    private static Id getProfileId(String profileName) {
        Profile profile = [SELECT Id FROM Profile WHERE Name = :profileName LIMIT 1];
        return profile.Id;
    }
    
    // Helper method to get User by Name
    private static User getUserByName(String userName) {
        User user = [SELECT Id FROM User WHERE Name = :userName LIMIT 1];
        return user;
    }
}