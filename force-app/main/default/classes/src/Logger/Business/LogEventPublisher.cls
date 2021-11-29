public with sharing class LogEventPublisher implements LogEventPublisherInterface {
    
    private LoggerConfigReadRepository configReadRepository;
    private final String TRANSACTION_ID;
    private List<LogEntryEvent__e> logEvents;
    
    public LogEventPublisher(LoggerConfigReadRepository loggerConfigRepository) {
        this.configReadRepository = loggerConfigRepository;
        this.TRANSACTION_ID = getTransactionId();
        this.logEvents = new List<LogEntryEvent__e>();
    }

    public void logError(String title, Exception ex) {
        
        LogEntryEvent__e log = new LogEntryEvent__e();
        
        log.Title__c = title;
        log.TransactionId__c = this.TRANSACTION_ID;
        log.ExceptionMessage__c = ex.getMessage();
        log.ExceptionStackTrace__c = ex.getStackTraceString();
        log.LogLevel__c = LogLevel.ERROR.name();
        
        this.addEvent(log);
    } 

    public void logWarning(String title, String warning) {
        LogEntryEvent__e log = new LogEntryEvent__e();
        
        log.Title__c = title;
        log.TransactionId__c = this.TRANSACTION_ID;
        log.ExceptionMessage__c = warning;
        log.LogLevel__c = LogLevel.WARNING.name();

        this.addEvent(log);
    }

    public void logInfo(String title, String info) {
        LogEntryEvent__e log = new LogEntryEvent__e();
        
        log.Title__c = title;
        log.TransactionId__c = this.TRANSACTION_ID;
        log.ExceptionMessage__c = info;
        log.LogLevel__c = LogLevel.INFO.name();

        this.addEvent(log);
    }

    public void save() {
        
        Eventbus.publish(this.logEvents);
        this.logEvents.clear();
    }

    private void addEvent(LogEntryEvent__e log) {
        
        log = this.addUserData(log);

        if(this.shouldSendToSentry(log.LogLevel__c, log.ExceptionMessage__c)) {
            this.logEvents.add(log);
        }
    }

    private Boolean shouldSendToSentry(String type, String msg) {
        
        if (!Test.isRunningTest() && !this.configReadRepository.isActive()) {
            System.debug(
                String.format(
                    LoggerConstants.MSG_SF_LOG,
                    new List<Object>{type, msg}
                )
            );
            return false;
        }

        return true;
    }

    private LogEntryEvent__e addUserData(LogEntryEvent__e event) {
        
        event.UserName__c = UserInfo.getUserName();
        event.UserEmail__c = UserInfo.getUserEmail();

        return event;
    }

    private String getTransactionId() {
        return String.isNotBlank(System.Request.getCurrent().getRequestId())?
            System.Request.getCurrent().getRequestId(): new Uuid().getValue();
    }
}
