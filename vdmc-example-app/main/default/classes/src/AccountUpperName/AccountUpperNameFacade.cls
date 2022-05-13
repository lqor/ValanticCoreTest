public class AccountUpperNameFacade  extends Facade{
    
    private AccountNameChanger accountNameChanger;
  
    override public void init() {
       this.accountNameChanger = new AccountNameChanger();
    }

   public void convertNameToUppercase(List<Account> accounts) {
        this.accountNameChanger.convertNameToUppercase(accounts);
   }
}
