public class AccountCaseUserWrapper {

    public Id accountId;
    public List<Case> cases;
    public List<User> users;
    public AccountCaseUserWrapper(Id accountId) {
        this.accountId = accountId;
        this.cases = new List<Case>();
        this.users = new List<User>();
    }
}