/**
 * @description This schedulable Apex class automatically sends email alerts or notifications to the Case Owner when a Case is created, based on the Case Escalation time values specified in the Custom Settings. 
 * The purpose of these notifications is to remind the Case Owner to take action on the Case before it reaches the specified Case Escalation time.
 * @Author Surendranath Reddy, Subba Reddy, Sprutiraj Panda
 * @Last Modified By Surendranath Reddy, Sprutiraj
 * @Last Modified On 21/04/2023
 * @Modification Log:
 * Ver     Date            Author                  Last Modification
 * 1.0     26/04/2023      Surendranath, Subba     Initial Version
 *                        Reddy, Sprutiraj Panda
 **/
public with sharing class SendMailtoQueueMembers implements Schedulable {
    private Case newListCase;
    private Id caseId;

    /**
     * @description Constructor for the SendMailtoQueueMembers class.
     * @param newListCase The Case object to process.
     * @param caseId The Id of the case to process.
     **/
    public SendMailtoQueueMembers(Case newListCase, Id caseId) {
        // Represents a Case object (presumably a newly created case) that needs to be escalated.
        this.newListCase = newListCase;
        // Represents the Id of the case that needs to be escalated.
        this.caseId = caseId;
    }

    /**
     * @description This method executes when the scheduled job is run.
     * It sends email notifications to the Case Owner based on certain conditions.
     * @param sc The SchedulableContext object.
     **/
    public void execute(SchedulableContext sc) {
        // Check CRUD permissions before performing the SOQL and DML operations.
        if (!Schema.sObjectType.Case.isUpdateable()) {
            return;
        }

        // Query the Case based on the provided caseId
        Case c = [SELECT Id, Skill_Name__c, OwnerId, CaseNumber, Owner.Name, Subject, Description, Priority, Status 
                  FROM Case WHERE Id = :caseId WITH SECURITY_ENFORCED];

        if (shouldSendEmailNotification(c)) {
            sendEmailNotification(c);
        }
    }

    /**
     * @description Checks if the Case meets the criteria for sending the email notification.
     * @param c The Case object.
     * @return True if the email notification should be sent, false otherwise.
     **/
    private Boolean shouldSendEmailNotification(Case c) {
        return (c.Status != 'Escalated' && c.Status != 'Closed');
    }

    /**
     *@description Sends the email notification to the Case Owner.
     * @param c The Case object.
     **/
    private void sendEmailNotification(Case c) {
        Set<Id> userIds = new Set<Id>();

        if (c.Skill_Name__c == null) {
            Set<Id> queueIds = new Set<Id>();
            queueIds.add(c.OwnerId);
            List<Group> queues = [SELECT Id FROM Group WHERE Id IN :queueIds WITH SECURITY_ENFORCED];

            for (GroupMember gm : [SELECT Id, UserOrGroupId FROM GroupMember WHERE GroupId IN :queues WITH SECURITY_ENFORCED]) {
                userIds.add(gm.UserOrGroupId);
            }
        } else if (c.Skill_Name__c != null) {
            userIds.add(c.OwnerId);
        }

        List<User> users = [SELECT Id, Email FROM User WHERE Id IN :userIds WITH SECURITY_ENFORCED];
        List<String> emailAddresses = new List<String>();

        for (User u : users) {
            emailAddresses.add(u.Email);
        }

        if (!emailAddresses.isEmpty()) {
            Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
            // Set the recipient email addresses for the email message to the values in the "emailAddresses" list
            msg.setToAddresses(emailAddresses);
            // Compose the body of the email message
            String body = '<p>Dear Team,</p>';
            body += '<p>This is to inform you that Case ' + c.CaseNumber + ' needs your attention. The Case is going to be Escalated, Still it has not been actioned and resolved yet.</p>';
            body += '<p>Please review the details below and take appropriate action before the Case is escalated:</p>';
            body += '<p><li>Case Number: ' + c.CaseNumber + '</li><br/><li> Subject: ' + c.Subject + '</li><br/><li> Reason for Escalation: ' + c.Description + '</li><br/><li> +  Priority: ' + c.Priority + '</li><br/><li> Status: ' + c.Status + '</li> <br/> Please note that the Case is scheduled to be escalated in the next few hours. If you are unable to resolve the Case by then, please reassign it to an appropriate resource or escalate it to the next level of support.</p>';
            body += '<p>Thank you for your prompt attention to this matter. Please go through the below case details.</p>';
            body += '<p><a href="' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + c.Id + '">View Case Details</a></p>';
            body += '<p>Thanks & Regards,</p>';
            body += '<p>Support Team</p>';
            // Set the HTML body of the email message using the composed body string
            msg.setHtmlBody(body);
            // Set the subject of the email message
            msg.setSubject('Case is going to be Escalated');
            // Set the sender display name for the email message
            msg.setSenderDisplayName('Salesforce Admin');
            // Send the email message
            Messaging.sendEmail(new List<Messaging.Email>{ msg });
        }
    }
}