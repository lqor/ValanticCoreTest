public with sharing class SentryApi {
    
    private static final String SENTRY_URL = 'https://o996722.ingest.sentry.io';
    private static final String SENTRY_PROJECT_ID = '5955214';
    private static final Integer SENTRY_VERSION = 7;
    private static final String SENTRY_KEY = '7ded4c6396c64aac92a0e70f90a01e36';
    
    public SentryApi() {

    }


    public void sendEvent(List<LogEntryData> logs) {
        
        if(logs.size() == 0){
            return;
        }
        
        List<String> payloads = new List<String>();

        for(LogEntryData log:logs){

            payloads.add(JSON.serialize(buildPayload(log)).replaceAll('"res_', '"'));
        }
        System.debug('TEST DEBUG WIEDERFINDEN');
        System.debug(payloads);

        postData(this.getStoreEndpoint(), this.getSecurityHeader(), payloads);
    }

    private SentryEvent.BaseData buildPayload(LogEntryData logEntryData) {
        SentryEvent.BaseData event;

        if(logEntryData.logLevel == LogLevel.ERROR.name()){
            event = new SentryEvent.ExceptionEvent();
        }else{
            event = new SentryEvent.InfoEvent();
            
        }
        event.res_transaction = logEntryData.transactionId;
        event.event_id = logEntryData.uuid;
        event.environment = 'Test';
        event.platform = 'salesforce';
        event.level = logEntryData.logLevel.toLowerCase();
        event.timestamp = logEntryData.created;

        return event;
    }

    @future(callout=true)
    private static void postData(String endpoint, String securityHeader, List<String> payloads) {
        HttpRequest request;
        Http http = new Http();
        
        for(String payload:payloads) {
            request = new HttpRequest();
            request.setEndpoint(endpoint);
            request.setCompressed(true);
            request.setMethod('POST');
            request.setHeader('X-Sentry-Auth', securityHeader);
            request.setBody(payload);
            
            http.send(request);
        }
    }

    private String getStoreEndpoint() {
        return String.format(
                '{0}/api/{1}/store/',
                new List<Object> {
                    SENTRY_URL,
                    SENTRY_PROJECT_ID
                }
            );
    }

    private String getSecurityHeader() {
        return String.format(
            'Sentry sentry_version={0},sentry_key={1}', 
            new List<Object> {
                SENTRY_VERSION,
                SENTRY_KEY
            });
    }


}
