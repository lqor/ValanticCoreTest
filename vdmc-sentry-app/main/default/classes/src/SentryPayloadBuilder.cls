public class SentryPayloadBuilder {
    
    private List<StacktraceExtractor> stacktraceExtractors;
    
    public SentryPayloadBuilder() {
        this.stacktraceExtractors = new List<StacktraceExtractor> {
            new StacktraceExtractor.ClassFunctionExtractor(),
            new StacktraceExtractor.AnonymousBlockExtractor(),
            new StacktraceExtractor.ClassExtractor()
        };
    }

    public SentryEventData.EventData buildPayload(Log__c log) {
        SentryEventData.EventData event = new SentryEventData.EventData();

        event.user = this.buildUserPayload(log);
        event.tags = this.buildTags(log);
        
        event.event_id = new Uuid().getValue().toLowerCase();
        event.timestamp = log.StartTime__c;
        event.platform = SentryConstants.PLATFORM;
        event.environment = log.OrganizationEnvironmentType__c;
        event.level = this.getSentryEventType(log.MaxLogEntryLoggingLevelOrdinal__c.intValue()).name().toLowerCase();
        event.server_name = log.OrganizationDomainUrl__c;

        event = this.addLog(event, log.LogEntries__r);

        if(String.isEmpty(event.res_transaction)) {
            event.res_transaction = log.LogEntries__r.get(log.LogEntries__r.size() -1).Origin__c;
        }
        
        return event;        
    }

    private SentryEventData.EventData addLog(SentryEventData.EventData event, List<LogEntry__c> logEntries) {
        
        for(LogEntry__c logEntry:logEntries) {
            SentryEventData.EventType entryType = this.getSentryEventType(logEntry.LoggingLevelOrdinal__c.intValue());
            if(entryType.ordinal() >= SentryEventData.EventType.ERROR.ordinal() || logEntry.HasException__c) {
                if(event.res_exception == null) {
                    event.res_exception = new SentryEventData.ExceptionData();
                    event.res_exception.values = new List<SentryEventData.ExceptionValueData>();
                }

                event.res_exception.values.add(this.buildExceptionPayload(logEntry));
                event.res_transaction = logEntry.Origin__c;
            }
            
            if(event.message == null) {
                event.message = new SentryEventData.MessageData();
                event.message.message = '';
            }else{
                event.message.message += '\n';
            }

            event.message.message += String.format(SentryConstants.LOG_SYNTAX, new List<Object> {
                logEntry.LoggingLevel__c,
                logEntry.Message__c
            });
        }

        return event;
    }

    private SentryEventData.ExceptionValueData buildExceptionPayload(LogEntry__c logEntry) {
        SentryEventData.ExceptionValueData exceptionValueData = new SentryEventData.ExceptionValueData();
        SentryEventData.StackTraceData stackTraceData = new SentryEventData.StackTraceData();
        List<String> lines = this.getStacktrace(logEntry);

        exceptionValueData.type = String.isEmpty(logEntry.ExceptionType__c)? SentryConstants.DEFAULT_EXCEPTION_TYPE: logEntry.ExceptionType__c;
        exceptionValueData.module = logEntry.Origin__c;
        exceptionValueData.value = logEntry.HasException__c ?logEntry.ExceptionMessage__c:logEntry.Message__c;
        exceptionValueData.mechanism = this.buildExceptionMechamismData(logEntry);
        stackTraceData.frames = this.getFrames(lines);

        if(stackTraceData.frames.size() > 0) {
            exceptionValueData.line_number = stackTraceData.frames[0].lineno;
        }
        
        exceptionValueData.stacktrace = stackTraceData;
        
        return exceptionValueData;
    }

    private List<String> getStacktrace(LogEntry__c logEntry) {
        List<String> lines;
        
        if(logEntry.HasExceptionStackTrace__c) {
            lines = logEntry.ExceptionStackTrace__c.split('\n');
        }else if(logEntry.HasStackTrace__c) {
            lines = logEntry.StackTrace__c.split('\n');
        }else {
            lines = new List<String>();
        }

        return lines;
    }

    private List<SentryEventData.FrameData> getFrames(List<String> lines) {
        List<SentryEventData.FrameData> frames = new List<SentryEventData.FrameData>();

        for (Integer i = lines.size() - 1; i >= 0; i--) {
            String line = lines[i];
            SentryEventData.FrameData frameData;

            for (StacktraceExtractor extractor:this.stacktraceExtractors) {
                
                frameData = extractor.extract(line);
                if(frameData != null) {
                    frames.add(frameData);
                    break;
                }
            }
        }

        return frames;
    }

    private SentryEventData.UserData buildUserPayload(Log__c log) {
        SentryEventData.UserData userData = new SentryEventData.UserData();

        userData.id = log.LoggedBy__c;
        userData.email = log.LoggedBy__r.Email;
        userData.ip_address = log.SourceIp__c;
        userData.username = log.LoggedBy__r.Username;
        userData.username_url = log.OrganizationDomainUrl__c + '/' + log.LoggedBy__c;
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
        
        mechanismData.type = SentryConstants.MECHAMISM_TYPE;

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
