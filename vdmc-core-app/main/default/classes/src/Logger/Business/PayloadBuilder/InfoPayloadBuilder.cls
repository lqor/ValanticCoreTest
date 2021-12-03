public class InfoPayloadBuilder implements PayloadBuilder {

    public SentryEvent.BaseData buildPayLoad(LogEntryData logEntryData) {
        SentryEvent.InfoEvent event = new SentryEvent.InfoEvent();
        SentryEvent.MessageData msgData = new SentryEvent.MessageData();

        msgData.message = String.format(
            LoggerConstants.MSG_INFO,
            new List<Object> {
                logEntryData.title,
                logEntryData.exceptionMessage
            }
        );

        event.message = msgData;
        
        return event;
    }
}