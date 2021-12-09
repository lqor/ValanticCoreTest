public class SentryEventData{

    public enum EventType {
        DEBUG,
        INFO,
        WARNING,
        ERROR,
        FATAL
    }

    public class SentryTags {
        public String type;
        public String instance_name;
        public String api_version;
        public String api_release_version;
    }
    
    public class EventData {
        public String event_id;
        public String res_transaction;
        public Datetime timestamp;
        public String environment;
        public String platform;
        public String server_name;
        public String level;
        
        public SentryTags tags;
        public UserData user;

        public MessageData message;
        public ExceptionData res_exception;
    }

    public class UserData {
        public Id id;
        public String username;
        public String email;
        public String ip_address;
        public String username_url;
        public String profile;
        public String user_type;
        public String locale;
        public String license;
        public String license_definition_key;
    }

    public class MessageData{
        public String message;
    }

    public class ExceptionData {
        public List<ExceptionValueData> values;
    }
    
    public class ExceptionValueData {
        public String type;
        public String value;
        public String module;
        public Integer line_number;
        public StackTraceData stacktrace;
        public MechanismData mechanism;
    }

    public class StackTraceData {
        public List<FrameData> frames;
    }

    public class FrameData {
        public String res_class;
        public String filename;
        public String function;
        public Integer lineno;
        public Integer column;
        public Boolean in_app;
        public Map<String, Object> vars;
    }

    public class MechanismData {
        public String type;
        public LimitData data;
    }

    public class LimitData {
        public String aggregate_queries;
        public String heap_size;
        public String async_calls;
        public String callouts;
        public String cpu_time;
        public String queueable_jobs;
        public String dml_rows;
        public String soql_queries;
        public String dml_statements;
        public String soql_query_rows;
        public String future_calls;
    }
    
   
}