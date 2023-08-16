public with Sharing class CaseEscalation implements System.Schedulable {
    private Case newListCase;
    private Id caseId;
    
    public CaseEscalation(Case newListCase, Id caseId) {
        this.newListCase = newListCase;
        this.caseId = caseId;
    }
    
    public void execute(SchedulableContext sc) {
        if (!Schema.sObjectType.Case.isUpdateable()) {
            return;
        }
        
        Case c = [SELECT Id, Status, OwnerId, CreatedDate FROM Case WHERE Id = :caseId AND Status != 'Escalated' WITH SECURITY_ENFORCED LIMIT 1];
        
        if (c == null) {
            return; // No case found to escalate.
        }
        
        Group escalatedQueue = [SELECT Id FROM Group WHERE Type = 'Queue' AND Name = 'Escalated or Urgent Case Team' WITH SECURITY_ENFORCED LIMIT 1];
        
        if (escalatedQueue == null) {
            return;
        }
        
        c.OwnerId = escalatedQueue.Id;
        c.IsEscalated = true;
        c.Status = 'Escalated';
        
        if (Schema.sObjectType.Case.isUpdateable()) {
            update c;
        }
    }
    
    public Id getCaseId() {
        return caseId;
    }
    
    public String getCasePriority() {
        return newListCase.Priority;
    }
}