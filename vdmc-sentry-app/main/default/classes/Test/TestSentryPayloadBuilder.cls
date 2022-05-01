@isTest
private class TestSentryPayloadBuilder {
    
    @TestSetup
    static void makeData(){
        buildLogData();
    }

    @isTest static void testPayloadBuilderWithMessage() {
        SentryPayloadBuilder payloadBuilder = new SentryPayloadBuilder();

        Log__c log = queryLogs().get(0);

        SentryEventData.EventData event = payloadBuilder.buildPayload(log);
        
        System.assertNotEquals(null, event.event_id);
        System.assertEquals('error', event.level);
        
        System.assert(event.message.message.length() != 0);
        System.assert(event.res_exception.values.size() != 0);
        System.assert(event.res_exception.values.get(0).stacktrace.frames.size() != 0);
        
        System.assertEquals('54.0', event.tags.api_version);
        System.assertEquals('SF 236', event.tags.api_release_version);
        System.assertEquals('Test', event.tags.instance_name);
        System.assertEquals('error', event.tags.type);
    }


    static List<Log__c> queryLogs() {
        return [
            SELECT
                Id,
                Name,
                ApiVersion__c,
                ApiReleaseVersion__c,
                LoggedBy__c,
                LoggedBy__r.Username,
                LoggedBy__r.Email,
                LoggedByUsernameLink__c,
                OwnerId,
                TYPEOF Owner
                    WHEN User THEN Username
                    ELSE Name
                END,
                UserType__c,
                UserLicenseName__c,
                UserLicenseDefinitionKey__c,
                SourceIp__c,
                Locale__c,
                MaxLogEntryLoggingLevelOrdinal__c,
                OrganizationId__c,
                OrganizationEnvironmentType__c,
                OrganizationInstanceName__c,
                OrganizationName__c,
                OrganizationDomainUrl__c,
                ProfileName__c,
                Priority__c,
                StartTime__c,
                TimeZoneId__c,
                TotalLogEntries__c,
                TotalERRORLogEntries__c,
                TotalWARNLogEntries__c,
                TransactionId__c,
                (
                    SELECT Id, LoggingLevel__c, Message__c, LoggingLevelOrdinal__c, ExceptionType__c,
                     ExceptionMessage__c, ExceptionStackTrace__c, HasException__c, HasExceptionStackTrace__c,
                     HasStackTrace__c, StackTrace__c, Origin__c, LimitsAggregateQueries__c, LimitsAsyncCalls__c,
                     LimitsCallouts__c, LimitsCpuTime__c, LimitsDmlRows__c, LimitsDmlStatements__c,
                     LimitsFutureCalls__c, LimitsHeapSize__c, LimitsQueueableJobs__c,
                     LimitsSoqlQueries__c, LimitsSoqlQueryRows__c, Timestamp__c
                    FROM LogEntries__r
                    ORDER BY TransactionEntryNumber__c ASC
                )
            FROM Log__c
        ];
    }

    private static Log__c buildLogData() {
        Log__c log = new Log__c();

        log = buildLogUserData(log);
        log = buildLogTagsData(log);

        //log.StartTime__c = Datetime.now();
        log.OrganizationType__c = 'Sandbox';
        
        insert log;

        log = buildLogEntryData(log);

        return log;
    }

    private static Log__c buildLogUserData(Log__c log){
    
        log.LoggedBy__c = UserInfo.getUserId();
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
        
        log.OrganizationInstanceName__c = 'Test';
        log.ApiVersion__c = '54.0';
        log.ApiReleaseVersion__c = 'SF 236';

        return log;
    }

    private static Log__c buildLogEntryData(Log__c log){
        
        List<LogEntry__c> logEntries = new List<LogEntry__c>();

        for (Integer i = 0; i < 3; i++) {
            LogEntry__c logEntry = new LogEntry__c();
            logEntry.Log__c = log.Id;
            logEntry.HasExceptionStackTrace__c = true;
            logEntry.ExceptionStackTrace__c = (new DmlException()).getStackTraceString();
            logEntry.ExceptionType__c = 'DmlException';
            logEntry.Timestamp__c = System.now();
            logEntry.ExceptionMessage__c = 'Test Error Msg';
            logEntry.LoggingLevel__c = LoggingLevel.ERROR.name();
            logEntry.LoggingLevelOrdinal__c = LoggingLevel.ERROR.ordinal();
            logEntry = buildLogEntryMechamismData(logEntry);

            logEntries.add(logEntry);
        }

        for (Integer i = 0; i < 3; i++) {
            LogEntry__c logEntry = new LogEntry__c();
            logEntry.Log__c = log.Id;
            logEntry.HasStackTrace__c = true;
            logEntry.StackTrace__c = (new DmlException()).getStackTraceString();
            logEntry.Timestamp__c = System.now();
            logEntry.Message__c = 'Test Error Msg';
            logEntry.LoggingLevel__c = LoggingLevel.INFO.name();
            logEntry.LoggingLevelOrdinal__c = LoggingLevel.WARN.ordinal();
            logEntry = buildLogEntryMechamismData(logEntry);

            logEntries.add(logEntry);
        }

        for (Integer i = 0; i < 3; i++) {
            LogEntry__c logEntry = new LogEntry__c();
            logEntry.Log__c = log.Id;
            logEntry.HasStackTrace__c = false;
            logEntry.Timestamp__c = System.now();
            logEntry.Message__c = 'Test Msg';
            logEntry.LoggingLevel__c = LoggingLevel.INFO.name();
            logEntry.LoggingLevelOrdinal__c = LoggingLevel.INFO.ordinal();
            logEntry = buildLogEntryMechamismData(logEntry);

            logEntries.add(logEntry);
        }

        insert logEntries;

        return log;
    }

    private static LogEntry__c buildLogEntryMechamismData(LogEntry__c logEntry) {
        
        logEntry.LimitsAggregateQueriesUsed__c = 10.0;
        logEntry.LimitsAggregateQueriesMax__c = 20.0;
        logEntry.LimitsAsyncCallsUsed__c = 10.0;
        logEntry.LimitsAsyncCallsMax__c = 20.0;
        logEntry.LimitsCalloutsUsed__c = 10.0;
        logEntry.LimitsCalloutsMax__c = 20.0;
        logEntry.LimitsCpuTimeUsed__c = 10.0;
        logEntry.LimitsCpuTimeMax__c = 20.0;
        logEntry.LimitsDmlRowsUsed__c = 10.0;
        logEntry.LimitsDmlRowsMax__c = 10.0;
        logEntry.LimitsDmlStatementsUsed__c = 10.0;
        logEntry.LimitsDmlStatementsMax__c = 20.0;
        logEntry.LimitsFutureCallsUsed__c = 10.0;
        logEntry.LimitsFutureCallsMax__c = 20.0;
        logEntry.LimitsHeapSizeUsed__c = 10.0;
        logEntry.LimitsHeapSizeMax__c = 20.0;
        logEntry.LimitsQueueableJobsUsed__c = 10.0;
        logEntry.LimitsQueueableJobsMax__c = 20.0;
        logEntry.LimitsSoqlQueriesUsed__c = 10.0;
        logEntry.LimitsSoqlQueriesMax__c = 20.0;
        logEntry.LimitsSoqlQueryRowsUsed__c = 10.0;
        logEntry.LimitsSoqlQueryRowsMax__c = 20.0;

        return logEntry;
    }

}
