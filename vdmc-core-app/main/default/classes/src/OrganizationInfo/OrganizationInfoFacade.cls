public class OrganizationInfoFacade  extends Facade{
    
    @TestVisible
    private OrganizationInfoResolver organizationInfoResolver;

    override public void init() {
        OrganizationReadRepositoryInterface organizationReadRepository = new OrganizationReadRepository();
        this.organizationInfoResolver = new OrganizationInfoResolver(organizationReadRepository);
    }

    public OrganizationInfoData getInfo() {
        return this.organizationInfoResolver.getInfo();
    }
}
