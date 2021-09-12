public with sharing class SentryApi {
    
    private static final String SENTRY_URL = 'https://o996722.ingest.sentry.io';
    private static final String SENTRY_PROJECT_ID = '5955214';
    private static final Integer SENTRY_VERSION = 7;
    private static final String SENTRY_KEY = '7ded4c6396c64aac92a0e70f90a01e36';
    
    public SentryApi() {

    }


    public void sendEvent(List<LogEntryEvent__e> events) {
        
        if(events.size() == 0){
            return;
        }
        
        List<String> payloads = new List<String>();

        for(LogEntryEvent__e log:events){

        }

        postData(this.getStoreEndpoint(), this.getSecurityHeader(), payloads);
    }

    @future
    public static void postData(String endpoint, String securityHeader, List<String> payloads) {
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
