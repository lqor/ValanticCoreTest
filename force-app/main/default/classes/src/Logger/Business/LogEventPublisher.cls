public with sharing class LogEventPublisher implements LogEventPublisherInterface {
    
    private final String TRANSACTION_ID;
    private List<LogEntryEvent__e> logEvents;
    
    public LogEventPublisher() {
        this.TRANSACTION_ID = getTransactionId();
        this.logEvents = new List<LogEntryEvent__e>();
    }

    public void logError(Exception ex) {
        LogEntryEvent__e log = new LogEntryEvent__e();
        
        log.TransactionId__c = this.TRANSACTION_ID;
        log.ExceptionMessage__c = ex.getMessage();
        log.ExceptionStackTrace__c = ex.getStackTraceString();
        log.LogLevel__c = LogLevel.ERROR.name();

        this.logEvents.add(log);
    } 

    public void logWarning(String warning) {
        LogEntryEvent__e log = new LogEntryEvent__e();
        
        log.TransactionId__c = this.TRANSACTION_ID;
        log.ExceptionMessage__c = warning;
        log.LogLevel__c = LogLevel.WARNING.name();

        this.logEvents.add(log);
    }

    public void logInfo(String info) {
        LogEntryEvent__e log = new LogEntryEvent__e();
        
        log.TransactionId__c = this.TRANSACTION_ID;
        log.ExceptionMessage__c = info;
        log.LogLevel__c = LogLevel.INFO.name();

        this.logEvents.add(log);
    }

    public void save() {
        
        Eventbus.publish(this.logEvents);
        this.logEvents.clear();

    }

    private String getTransactionId() {
        return String.isNotBlank(System.Request.getCurrent().getRequestId())?
            System.Request.getCurrent().getRequestId(): new Uuid().getValue();
    }
}
