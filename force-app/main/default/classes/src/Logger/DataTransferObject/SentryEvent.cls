public class SentryEvent implements DTO{
    public String event_id;
    public String res_transaction;
    public Datetime timestamp;
    public String environment;
    public String platform;
    public String level;
    
    public class SentryTags implements DTO {
        public String type;
    }
}


