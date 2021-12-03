trigger LogEntryEventTrigger on LogEntryEvent__e (after insert) {
    
    List<LogEntryData> logs = new List<LogEntryData>();
    
    for(LogEntryEvent__e event:Trigger.new){
        LogEntryData data = new LogEntryData();
        data.uuid = event.EventUuid;
        data.transactionId = event.TransactionId__c;
        data.created = event.CreatedDate;

        data.owner = event.CreatedById;
        data.ownerEmail = event.UserEmail__c;
        data.ownerUsername = event.UserName__c;

        data.logLevel = event.LogLevel__c;
        data.title = event.Title__c;
        data.exceptionMessage = event.ExceptionMessage__c;
        data.exceptionStacktrace = event.ExceptionStackTrace__c;

        logs.add(data);
    }

    if(logs.size() > 0) {
        LoggerFacade logger = (LoggerFacade)Container.getDi().get(LoggerFacade.class);
        System.debug('Start Logging from ' + logs.size() + ' events.');
        logger.handleEvent(logs);
    }
}