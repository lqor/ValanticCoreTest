public class SentryEvent{
    
    public class SentryTags implements DTO {
        public String type;
        public Id owner;
    }
    
    public abstract class BaseData implements DTO {
        public String event_id;
        public String res_transaction;
        public Datetime timestamp;
        public String environment;
        public String platform;
        public String level;
        
        public SentryTags tags;
    }

    public class InfoEvent extends BaseData{
        public MessageData message;
    }

    public class MessageData implements DTO{
        public String message;
    }

    public class ExceptionEvent extends BaseData {
        public ExceptionData res_exception;
    }

    public class ExceptionData implements DTO {
        public List<ExceptionValueData> values;
    }
    
    public class ExceptionValueData implements DTO{
        public String type;
        public String value;
        public String module;
        public Integer line_number;
        public StackTraceData stacktrace;
    }

    public class StackTraceData implements DTO {
        public List<FrameData> frames;
    }

    public class FrameData implements DTO {
        public String res_class;
        public String filename;
        public String function;
        public Integer lineno;
        public Integer column;
        public Boolean in_app;
        public Map<String, Object> vars;
    }
   
}


