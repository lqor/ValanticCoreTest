global class LoggerFacade extends Facade{

    private LogEventPublisherInterface logEventPublisher;
    private SentryApi sentryApi;

    global override void init() {
        this.logEventPublisher = new LogEventPublisher();
        this.sentryApi = new SentryApi();
    }

    global void logError(Exception ex) {
        this.logEventPublisher.logError(ex);
    }

    global void logError(String title, Exception ex) {
        this.logEventPublisher.logError(title, ex);
    } 

    global void logWarning(String title, String warning) {
        this.logEventPublisher.logWarning(title, warning);
    }

    global void logInfo(String title, String info) {
        this.logEventPublisher.logInfo(title, info);
    }

    global void save() {
        this.logEventPublisher.save();
    }

    public void handleEvent(List<LogEntryData> logs){
        this.sentryApi.sendEvent(logs);
    }

}
