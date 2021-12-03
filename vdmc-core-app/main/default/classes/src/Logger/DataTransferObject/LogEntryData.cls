public class LogEntryData implements DTO{
    
    public String uuid;
    public Datetime created;
    public Id owner;
    public String ownerEmail;
    public String ownerUsername;
    public String apiVersion;
    public String logLevel;

    public String transactionId;
    public String title;
    public String exceptionMessage;
    public String exceptionStacktrace;
}
