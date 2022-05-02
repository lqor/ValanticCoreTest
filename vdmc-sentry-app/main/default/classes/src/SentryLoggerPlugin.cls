public without sharing class SentryLoggerPlugin extends LoggerSObjectHandlerPlugin implements Queueable, Database.AllowsCallouts {
    
    @TestVisible
    private static LoggingLevel SENTRY_LOGGING_LEVEL = Logger.getLoggingLevel(LoggerParameter.getString('SentryRequestLoggingLevel', null));
    @TestVisible
    private static String SENTRY_KEY = LoggerParameter.getString('SentryKey', null);
    @TestVisible
    private static String SENTRY_PROJECT_ID = LoggerParameter.getString('SentryProjectId', null);
    @TestVisible
    private static String SENTRY_URL = LoggerParameter.getString('SentryUrl', null);
    private static Integer SENTRY_VERIONS = 7;

    private SentryPayloadBuilder sentryPayloadBuilder;
    private List<Log__c> logs;

    public SentryLoggerPlugin() {
        this.sentryPayloadBuilder = new SentryPayloadBuilder();
    }

    private SentryLoggerPlugin(List<Log__c> unsentLogs) {
        this();
        this.logs = unsentLogs;
    }

    /**
     * @description Handles the queuable execute logic.
     * @param triggerOperationType Defines the trigger operation type
     * @param triggerNew contains a list of the new trigger context / records.
     * @param triggerNewMap contains a map of ids to new trigger records.
     * @param triggerOld old contains a list of the old trigger context / records.
     * @param triggerOldMap contains a map of ids to old trigger records.
     */
    public override void execute(
        TriggerOperation triggerOperationType,
        List<SObject> triggerNew,
        Map<Id, SObject> triggerNewMap,
        List<SObject> triggerOld,
        Map<Id, SObject> triggerOldMap
    ) {

        if(!this.isConfigured()) {
            return;
        }

        this.logs = (List<Log__c>) triggerNew;

        switch on triggerOperationType {
            when BEFORE_INSERT, BEFORE_UPDATE {
                this.flagLogsForSentryNotification();
            }
            when AFTER_INSERT, AFTER_UPDATE {
                this.sendAsyncSentryNotifications();
            }
        }
    }

    /**
     * @description Handles the queuable execute logic. Required by the Queueable interface.
     * @param queueableContext Context of the current queuable instance.
     */
    public void execute(System.QueueableContext queueableContext) {
        // SInce this runs in an async context, requery the logs just in case any field values have changed
        this.requeryLogs();

        if (this.logs.isEmpty() == true) {
            return;
        }

        List<Log__c> sentLogs = new List<Log__c>();
        List<Log__c> unsentLogs = new List<Log__c>();
        for (Log__c log : this.logs) {
            if (Limits.getCallouts() == Limits.getLimitCallouts()) {
                // If there are too many logs to send in the same transaction
                // add them to the unsentLogs list, which will be queued as a separate job
                unsentLogs.add(log);
            } else {

                SentryEventData.EventData sentryEvent = this.sentryPayloadBuilder.buildPayload(log);
                String payload = JSON.serialize(sentryEvent).replaceAll('"res_', '"');
        
                HttpResponse response = this.postData(this.getStoreEndpoint(), this.getSecurityHeader(), payload);

                System.debug(SENTRY_LOGGING_LEVEL, 'response.getStatusCode()==' + response.getStatusCode());
                System.debug(SENTRY_LOGGING_LEVEL, 'response.getStatus()==' + response.getStatus());
                
                log.SentryRequestDate__c = System.now();
                sentLogs.add(log);
            }
        }
        update sentLogs;

        // If any logs couldn't be sent due to governor limits, start a new instance of the job
        if (!unsentLogs.isEmpty()) {
            System.enqueueJob(new SentryLoggerPlugin(unsentLogs));
        }
    }

    private void flagLogsForSentryNotification() {
        if (SENTRY_LOGGING_LEVEL == null) {
            return;
        }

        for (Log__c log : this.logs) {
            if (log.MaxLogEntryLoggingLevelOrdinal__c >= SENTRY_LOGGING_LEVEL.ordinal()) {
                log.SendSentryRequest__c = true;
            }
        }
    }

    private void sendAsyncSentryNotifications() {
        List<Log__c> logsToSend = new List<Log__c>();
        for (Log__c log : this.logs) {
            if (log.SendSentryRequest__c == true) {
                logsToSend.add(log);
            }
        }

        // Since plugins are called from trigger handlers, and triggers can't make callouts
        // run this class as a queueable (async) job
        if (logsToSend.isEmpty() == false) {
            System.enqueueJob(new SentryLoggerPlugin(logsToSend));
        }
    }

    private void requeryLogs() {
        // TODO: switch to dynamically querying based on a new `Log__c` field set parameter
        this.logs = [
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
                    WHERE LoggingLevelOrdinal__c >= :SENTRY_LOGGING_LEVEL.ordinal()
                    ORDER BY TransactionEntryNumber__c ASC
                )
            FROM Log__c
            WHERE
                Id IN :this.logs
                AND MaxLogEntryLoggingLevelOrdinal__c >= :SENTRY_LOGGING_LEVEL.ordinal()
                AND SendSentryRequest__c = TRUE
                AND SentryRequestDate__c = NULL
        ];
    }

    private HttpResponse postData(String endpoint, String securityHeader, String payload) {
        HttpRequest request;
        Http http = new Http();
        
        request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setCompressed(true);
        request.setMethod('POST');
        request.setHeader('X-Sentry-Auth', securityHeader);
        request.setBody(payload);
        
        return http.send(request);
    }

    private String getStoreEndpoint() {
        return String.format(
                '{0}/api/{1}/store/',
                new List<Object> {
                    SENTRY_URL,//'https://o996722.ingest.sentry.io',//this.configReadRepository.getSentryUrl(),
                    SENTRY_PROJECT_ID,'5955214'//this.configReadRepository.getSentryProjectId()
                }
            );
    }

    private String getSecurityHeader() {
        return String.format(
            'Sentry sentry_version={0},sentry_key={1}', 
            new List<Object> {
                SENTRY_VERIONS, //7 //this.configReadRepository.getSentryVersion(),
                SENTRY_KEY//'7ded4c6396c64aac92a0e70f90a01e36'//this.configReadRepository.getSentryKey()
            });
    }

    private Boolean isConfigured() {
        if(String.isBlank(SENTRY_URL) || String.isBlank(SENTRY_PROJECT_ID) || String.isBlank(SENTRY_KEY)) {
            return false;
        }
        return true;
    }
}
