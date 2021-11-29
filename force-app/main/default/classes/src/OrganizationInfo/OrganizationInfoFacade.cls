global class OrganizationInfoFacade  extends Facade{
    
    @TestVisible
    private OrganizationInfoResolver organizationInfoResolver;

    override global void init() {
        OrganizationReadRepositoryInterface organizationReadRepository = new OrganizationReadRepository();
        this.organizationInfoResolver = new OrganizationInfoResolver(organizationReadRepository);
    }

    global OrganizationInfoData getInfo() {
        return this.organizationInfoResolver.getInfo();
    }
}
