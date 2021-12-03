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


    private List<Log__c> logs;

    public SentryLoggerPlugin() {
    }

    private SentryLoggerPlugin(List<Log__c> unsentLogs) {
        this();
        this.logs = unsentLogs;
    }

    // Instance methods

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

                SentryEventData.EventData sentryEvent = this.buildPayload(log);
                String payload = JSON.serialize(buildPayload(log)).replaceAll('"res_', '"');
        
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
                     StackTrace__c, Origin__c, LimitsAggregateQueries__c, LimitsAsyncCalls__c,
                     LimitsCallouts__c, LimitsCpuTime__c, LimitsDmlRows__c, LimitsDmlStatements__c,
                     LimitsFutureCalls__c, LimitsHeapSize__c, LimitsQueueableJobs__c,
                     LimitsSoqlQueries__c, LimitsSoqlQueryRows__c
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

    private SentryEventData.EventData buildPayload(Log__c log) {
        SentryEventData.EventData event = new SentryEventData.EventData();

        event.user = this.buildUserPayload(log);
        event.tags = this.buildTags(log);
        
        event.event_id = new Uuid().getValue().toLowerCase();
        event.res_transaction = log.TransactionId__c;
        event.timestamp = log.StartTime__c;
        event.platform = 'SALESFORCE';
        event.environment = log.OrganizationEnvironmentType__c;
        event.level = this.getSentryEventType(log.MaxLogEntryLoggingLevelOrdinal__c.intValue()).name().toLowerCase(); //Todo: Translate to SF types
        event.server_name = log.OrganizationDomainUrl__c;

        for(LogEntry__c logEntry:log.LogEntries__r) {
            SentryEventData.EventType entryType = this.getSentryEventType(logEntry.LoggingLevelOrdinal__c.intValue());
            if(entryType.ordinal() >= SentryEventData.EventType.ERROR.ordinal() || logEntry.HasException__c) {
                if(event.res_exception == null) {
                    event.res_exception = new SentryEventData.ExceptionData();
                    event.res_exception.values = new List<SentryEventData.ExceptionValueData>();
                }

                event.res_exception.values.add(this.buildExceptionPayload(logEntry));
            }else{
                if(event.message == null) {
                    event.message = new SentryEventData.MessageData();
                    event.message.message = '';
                }else{
                    event.message.message += '\n';
                }
                event.message.message += '['+ logEntry.LoggingLevel__c + '] ' + logEntry.Message__c;
            }
        }
        
        return event;
    }

    private SentryEventData.ExceptionValueData buildExceptionPayload(LogEntry__c logEntry) {
        SentryEventData.ExceptionValueData exceptionValueData = new SentryEventData.ExceptionValueData();
        SentryEventData.StackTraceData stackTraceData = new SentryEventData.StackTraceData();

        exceptionValueData.type = String.isEmpty(logEntry.ExceptionType__c)?'Error': logEntry.ExceptionType__c;
        exceptionValueData.module = logEntry.Origin__c;
        exceptionValueData.value = logEntry.HasException__c ?logEntry.ExceptionMessage__c:logEntry.Message__c;
        exceptionValueData.mechanism = this.buildExceptionMechamismData(logEntry);
        stackTraceData.frames = new List<SentryEventData.FrameData>();
        List<String> lines = logEntry.HasExceptionStackTrace__c ?
            logEntry.ExceptionStackTrace__c.split('\n'):logEntry.StackTrace__c.split('\n');

        for (Integer i = lines.size() - 1; i >= 0; i--) {
            String line = lines[i];
            Pattern p = Pattern.compile('Class\\.([^\\.]+)\\.([^:]+): line ([0-9]+), column ([0-9]+)');
            Matcher m = p.matcher(line);
            // Sample: Class.SampleClass.execute: line 36, column 1
            if (m.find()) 
            {
                SentryEventData.FrameData frameData = new SentryEventData.FrameData();
                frameData.res_class = m.group(1);
                frameData.filename = m.group(1) + '.cls';
                frameData.function = m.group(1) + '.' + m.group(2) + ', line ' + m.group(3);
                frameData.lineno = Integer.valueOf(m.group(3));
                frameData.column =Integer.valueOf(m.group(4));
                frameData.in_app = true;
                frameData.vars = new Map<String, Object> {
                    'column' => frameData.column,
                    'line' => frameData.lineno,
                    'class'=> frameData.res_class,
                    'function' => frameData.function
                };
                stackTraceData.frames.add(frameData);
            } else if(line.contains('AnonymousBlock')) {
                p = Pattern.compile('AnonymousBlock: line ([0-9]+), column ([0-9]+)');
                m = p.matcher(line);
                // Sample: Class.SampleClass1: line 595, column 1
                if (m.find()) 
                {
                    SentryEventData.FrameData frameData = new SentryEventData.FrameData();
                    frameData.res_class = 'Anonymous Console';
                    frameData.filename = '';
                    frameData.function = 'AnonymousBlock' + ', line ' + m.group(1);
                    frameData.lineno = Integer.valueOf(m.group(1));
                    frameData.column =Integer.valueOf(m.group(2));
                    frameData.in_app = true;
                    frameData.vars = new Map<String, Object> {
                        'column' => frameData.column,
                        'line' => frameData.lineno,
                        'class'=> frameData.res_class,
                        'function' => frameData.function
                    };
                    stackTraceData.frames.add(frameData);
                }
            } else {
                p = Pattern.compile('Class\\.([^\\.]+): line ([0-9]+), column ([0-9]+)');
                m = p.matcher(line);
                // Sample: Class.SampleClass1: line 595, column 1
                if (m.find()) 
                {
                    
                    SentryEventData.FrameData frameData = new SentryEventData.FrameData();
                    frameData.res_class = m.group(1);
                    frameData.filename = m.group(1) + '.cls';
                    frameData.function = m.group(1) + ', line ' + m.group(2);
                    frameData.lineno = Integer.valueOf(m.group(2));
                    frameData.column =Integer.valueOf(m.group(3));
                    frameData.in_app = true;
                    frameData.vars = new Map<String, Object> {
                        'column' => frameData.column,
                        'line' => frameData.lineno,
                        'class'=> frameData.res_class,
                        'function' => frameData.function
                    };
                    stackTraceData.frames.add(frameData);
                }
            }
        }

        if(stackTraceData.frames.size() > 0) {
            exceptionValueData.line_number = stackTraceData.frames[0].lineno;
        }
        
        exceptionValueData.stacktrace = stackTraceData;
        
        return exceptionValueData;
    }


    private SentryEventData.UserData buildUserPayload(Log__c log) {
        SentryEventData.UserData userData = new SentryEventData.UserData();

        userData.id = log.OwnerId;
        userData.email = log.LoggedBy__r.Email; //todo: resolve correct mail
        userData.ip_address = log.SourceIp__c;
        userData.username = log.LoggedBy__r.Username;
        userData.username_url = log.OrganizationDomainUrl__c + '/' + log.OwnerId;
        userData.profile = log.ProfileName__c;
        userData.user_type = log.UserType__c;
        userData.locale = log.Locale__c;
        userData.license = log.UserLicenseName__c;
        userData.license_definition_key = log.UserLicenseDefinitionKey__c;

        return userData;
    }

    private SentryEventData.SentryTags buildTags(Log__c log) {
        SentryEventData.SentryTags tags = new SentryEventData.SentryTags();

        tags.type = this.getSentryEventType(log.MaxLogEntryLoggingLevelOrdinal__c.intValue()).name().toLowerCase();
        tags.instance_name = log.OrganizationInstanceName__c;
        tags.api_version = log.ApiVersion__c;
        tags.api_release_version = log.ApiReleaseVersion__c;

        return tags;
    }

    private SentryEventData.MechanismData buildExceptionMechamismData(LogEntry__c logEntry) {
        SentryEventData.MechanismData mechanismData = new SentryEventData.MechanismData();
        SentryEventData.LimitData limitData = new SentryEventData.LimitData();
        mechanismData.handled = true;
        mechanismData.type = 'limits';

        limitData.aggregate_queries = logEntry.LimitsAggregateQueries__c;
        limitData.async_calls = logEntry.LimitsAsyncCalls__c;
        limitData.callouts = logEntry.LimitsCallouts__c;
        limitData.cpu_time = logEntry.LimitsCpuTime__c;
        limitData.dml_rows = logEntry.LimitsDmlRows__c;
        limitData.dml_statements = logEntry.LimitsDmlStatements__c;
        limitData.future_calls = logEntry.LimitsFutureCalls__c;
        limitData.heap_size = logEntry.LimitsHeapSize__c;
        limitData.queueable_jobs = logEntry.LimitsQueueableJobs__c;
        limitData.soql_queries = logEntry.LimitsSoqlQueries__c;
        limitData.soql_query_rows = logEntry.LimitsSoqlQueryRows__c;

        mechanismData.data = limitData;

        return mechanismData;
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

    private SentryEventData.EventType getSentryEventType(Integer loggingLevelOrdinal) {
        
        if(loggingLevelOrdinal >= 8) {
            return SentryEventData.EventType.ERROR;
        }else if(loggingLevelOrdinal >= 7) {
            return SentryEventData.EventType.WARNING;
        }else if(loggingLevelOrdinal >= 6) {
            return SentryEventData.EventType.INFO;
        }

        return SentryEventData.EventType.DEBUG;
    }

}
