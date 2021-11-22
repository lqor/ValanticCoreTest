public class OrganizationInfoResolver {
    
    private OrganizationReadRepositoryInterface organziationReadRepository;
    private OrganizationInfoData info;

    public OrganizationInfoResolver() {
        this.organziationReadRepository = new OrganizationReadRepository();
    }

    public OrganizationInfoData getInfo() {
        
        if(this.info == null) {
            this.info = this.resolve();
        }

        return this.info;
    }

    private OrganizationInfoData resolve() {
        Organization org = this.organziationReadRepository.getOrganizationData();
        OrganizationInfoData info = new OrganizationInfoData();

        info.type = this.getType(org);

        return info;
    }

    private OrganizationType getType(Organization org) {
        OrganizationType type;
        Boolean isScratchOrg = org.IsSandbox && org.TrialExpirationDate != null;
        Boolean isTrialOrg = !org.IsSandbox && org.TrialExpirationDate != null;
        Boolean isSandbox = org.IsSandbox && !isScratchOrg && ! isTrialOrg;
        Boolean isProd = !org.IsSandbox && !isScratchOrg && ! isTrialOrg;

        if(isScratchOrg) {
            type = OrganizationType.SCRATCH;
        }else if(isTrialOrg) {
            type = OrganizationType.TRIAL;
        }else if(isSandbox) {
            type = OrganizationType.SANDBOX;
        }else {
            type = OrganizationType.PRODUCTION;
        }

        return type;
    }
}
