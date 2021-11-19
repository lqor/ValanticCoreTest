public class WarningPayloadBuilder implements PayloadBuilder {

    public SentryEvent.BaseData buildPayLoad(LogEntryData logEntryData) {
        SentryEvent.WarningEvent event = new SentryEvent.WarningEvent();
        SentryEvent.MessageData msgData = new SentryEvent.MessageData();

        msgData.message = String.format(
            LoggerConstants.MSG_WARNING,
            new List<Object> {
                logEntryData.title,
                logEntryData.exceptionMessage
            }
        );

        event.message = msgData;
        
        return event;
    }
}