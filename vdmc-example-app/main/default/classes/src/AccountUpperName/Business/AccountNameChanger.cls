public with sharing class AccountNameChanger {
    
    /**
     * Does work, since accounts is a reference from the Trigger.New
     */
    public void convertNameToUppercase(List<Account> accounts) {
        for (Account account : accounts) {
            account.Name = account.Name.toUpperCase();
        }
    }
}
