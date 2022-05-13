public with sharing class AccountChangeTriggerHandler extends TriggerHandler {
    
    public override void beforeUpdate() {
        handleAccountChange();
    }
  
    public override void beforeInsert() {
        handleAccountChange();
    }
  
    private void handleAccountChange() {
        ContainerInterface container = Container.getDi();
        AccountUpperNameFacade accountUpperNameFacade = (AccountUpperNameFacade) container.get(AccountUpperNameFacade.class);
        
        List<Account> accounts = (List<Account>) Trigger.New;
        accountUpperNameFacade.convertNameToUppercase(accounts);
    }
}