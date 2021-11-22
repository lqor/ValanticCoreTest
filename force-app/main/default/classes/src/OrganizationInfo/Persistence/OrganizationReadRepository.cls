public class OrganizationReadRepository implements OrganizationReadRepositoryInterface{

    public Organization getOrganizationData() {
        return [SELECT IsSandbox, TrialExpirationDate FROM Organization LIMIT 1];
    }
}
