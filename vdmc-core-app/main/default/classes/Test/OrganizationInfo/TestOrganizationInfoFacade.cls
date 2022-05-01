public @isTest class TestOrganizationInfoFacade {
    
    @isTest static void testOrgDependedGetInfo() {
        ContainerInterface container = Container.getDi();
        OrganizationInfoFacade organizationInfoFacade = (OrganizationInfoFacade)container.get(OrganizationInfoFacade.class);
        
        
        OrganizationInfoData orgData = organizationInfoFacade.getInfo();
        System.assert(orgData != null, 'Could resolve organization-data');
    }
}
