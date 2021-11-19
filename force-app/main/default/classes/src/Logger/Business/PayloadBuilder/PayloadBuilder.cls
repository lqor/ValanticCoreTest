public interface PayloadBuilder {
    
    SentryEvent.BaseData buildPayLoad(LogEntryData logEntryData);
}