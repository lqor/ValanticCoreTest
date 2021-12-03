public interface LogEventPublisherInterface {
    
    void logError(String title, Exception ex);

    void logWarning(String title, String warning);

    void logInfo(String title, String info);

    void save();
}
