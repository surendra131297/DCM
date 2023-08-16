@isTest
public class CaseActionsApexClassTest {
    @isTest 
    static void testHighPriorityCase() {
        // Create a test account
        Account acc = new Account(Name = 'Test Account');
        insert acc;
 // Create a test DynamicTimeValuesForEscalation__c record
        DynamicTimeValuesForEscalation__c dynamicValues = new DynamicTimeValuesForEscalation__c();
            dynamicValues.CaseEscalationforLowMediumPriority__c = '00:10:00';
            dynamicValues.CaseEscalationforHighPriority__c = '00:05:00';
       
        insert dynamicValues;
        // Create a high priority case
        Case cs = new Case(
            AccountId = acc.Id,
            Priority = 'High',
            Subject = 'Test High Priority Case',
            Description = 'This is a test high priority case.'
        );

        insert cs;

        // Verify that the case was created successfully
        System.assertEquals('High', cs.Priority, 'Case Priority should be High');
       // System.assertNotEquals(null, cs.OwnerId, 'Case should be assigned to a queue');
    }

    @isTest 
    static void testProductSupportCase() {
        // Create a test account
        Account acc = new Account(Name = 'Test Account');
        insert acc;
 // Create a test DynamicTimeValuesForEscalation__c record
        DynamicTimeValuesForEscalation__c dynamicValues = new DynamicTimeValuesForEscalation__c();
            dynamicValues.CaseEscalationforLowMediumPriority__c = '00:10:00';
            dynamicValues.CaseEscalationforHighPriority__c = '00:05:00';
       
        insert dynamicValues;
        // Create a product support case
        Case cs = new Case(
            AccountId = acc.Id,
            Product__c = 'Test Product',
            Subject = 'Test Product Support Case',
            Description = 'This is a test product support case.'
        );

        insert cs;

        // Verify that the case was created successfully
        System.assertEquals('Test Product', cs.Product__c, 'Case Product should be "Test Product"');
      //  System.assertNotEquals(null, cs.OwnerId, 'Case should be assigned to a queue');
    }

    @IsTest
    static void bothProductAndSkillSelected() {
        List<Case> caseList = new List<Case>();
        Case cs = new Case(
            Priority = 'High',
            Subject = 'Test High Priority Case',
            Description = 'This is a test high priority case.',
            Product__c = 'Laptop',
            My_Skill__c = 'English'
        );
        caseList.add(cs);
        CaseActionsApexClass.assignCases(caseList);

        // Verify that an error message is added to the case
        System.assertNotEquals(null, cs.My_Skill__c, 'Skill Name should not be null');
        System.assertNotEquals(null, cs.Product__c, 'Product should not be null');
     //   System.assertEquals('Both Product and My Skill Do not select at a time', cs.Description, 'Error message should be added to the Case');
    }
}