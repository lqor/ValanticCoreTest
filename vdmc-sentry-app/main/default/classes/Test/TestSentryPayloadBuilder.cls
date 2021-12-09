@isTest
private class TestSentryPayloadBuilder {
    

    @TestSetup
    static void makeData(){
        
    }

    @isTest static void testPayloadBuilderWithMessage() {
        SentryPayloadBuilder payloadBuilder = new SentryPayloadBuilder();

        Log__c log = buildLogData();


        SentryEventData.EventData event = payloadBuilder.buildPayload(log);
        
    }


    private static Log__c buildLogData() {
        Log__c log = new Log__c();

        log = buildLogUserData(log);

        return log;
    }

    private static Log__c buildLogUserData(Log__c log){
        
        User user =  new User(
            Id=UserInfo.getUserId(),
            Email=UserInfo.getUserEmail(),
            Username=UserInfo.getUserName()
        );

        log.LoggedBy__c = user.Id;
        log.LoggedBy__r = user;
        log.SourceIp__c = '1.1.1.1';
        log.OrganizationDomainUrl__c = 'vdmc.test';
        log.ProfileName__c = 'TestProfile';
        log.UserType__c = UserInfo.getUserType();
        log.Locale__c = UserInfo.getLocale();
        log.UserLicenseName__c = 'salesforce';
        log.UserLicenseDefinitionKey__c = 'test';

        return log;
    }

    private static Log__c buildLogTagsData(Log__c log){
        
        log.MaxLogEntryLoggingLevelOrdinal__c = 5;
        

        return log;
    }
}
