public with sharing class OpportunityTriggerHandler extends TriggerHandler {

    private Map<Id, Opportunity> newOpportunityMap;
  
    public OpportunityTriggerHandler() {
      this.newOpportunityMap = (Map<Id, Opportunity>) Trigger.newMap;
    }

    public override void beforeInsert() {
        
        for(Opportunity o : (List<Opportunity>) Trigger.new) {
            o.Name ='TriggerHandlerTest';
        }
    }

    public override void afterInsert() {
        List<Account> accounts = new List<Account>();
        for (Opportunity opportunity : newOpportunityMap.values()) {
            accounts.add(
                new Account(
                    Name = opportunity.Name + ' Account'
                )
            );
        }

        if (accounts.size() > 0) {
            //hätten wir hier noch nen AccountTrigger, könnten wir den für diesen insert bypassen ( wichtig clearBypass )
            TriggerHandler.bypass('AccountTriggerHandler');
            insert accounts;
            TriggerHandler.clearBypass('AccountTriggerHandler');
            
        }
    }
}
