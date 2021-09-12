public interface LogEventPublisherInterface {
    
    void logError(Exception ex);

    void logWarning(String warning);

    void logInfo(String info);

    void save();
}
