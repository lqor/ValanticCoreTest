global class LoggerFacade extends Facade{

    private LogEventPublisherInterface logEventPublisher;

    global override void init() {
        this.logEventPublisher = new LogEventPublisher();
    }

    global void logError(Exception ex) {
        this.logEventPublisher.logError(ex);
    } 

    global void logWarning(String warning) {
        this.logEventPublisher.logWarning(warning);
    }

    global void logInfo(String info) {
        this.logEventPublisher.logInfo(info);
    }

    global void save() {
        this.logEventPublisher.save();
    }


}
