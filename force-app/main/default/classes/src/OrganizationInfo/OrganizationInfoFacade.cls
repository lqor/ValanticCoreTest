global class OrganizationInfoFacade  extends Facade{
    
    private OrganizationInfoResolver organizationInfoResolver;

    override global void init() {
        this.organizationInfoResolver = new OrganizationInfoResolver();
    }

    global OrganizationInfoData getInfo() {
        return this.organizationInfoResolver.getInfo();
    }
}
