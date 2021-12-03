public class LoggerConfigReadRepository {
    
    private Logger_Setting__mdt setting;

    public LoggerConfigReadRepository(OrganizationType type) {
        this.setting = Logger_Setting__mdt.getInstance(type.name().toLowerCase());
    }

    public Boolean isActive() {
        return (Boolean) this.setting.get('Active__c');
    }

    public String getSentryUrl() {
        return (String) this.setting.get('Sentry_Url__c');
    }

    public Integer getSentryVersion() {
        return Integer.valueOf(this.setting.get('Sentry_Version__c'));
    }

    public String getSentryKey() {
        return (String) this.setting.get('Sentry_Key__c');
    }

    public String getSentryProjectId() {
        return (String) this.setting.get('Sentry_Project_Id__c');
    }
}
