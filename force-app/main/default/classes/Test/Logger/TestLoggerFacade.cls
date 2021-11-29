global @isTest class TestLoggerFacade {
    
    @isTest static void testInit() {
        ContainerInterface container = Container.getDi();
        LoggerFacade loggerFacade = (LoggerFacade)container.get(LoggerFacade.class);
        System.assert(true);
    }

    @isTest static void testLogging() {
        ContainerInterface container = Container.getDi();
        LoggerFacade loggerFacade = (LoggerFacade)container.get(LoggerFacade.class);
        Test.setMock(HttpCalloutMock.class, new RestMock());
        Test.startTest();
        loggerFacade.logInfo('Test-Title', 'Test Info');
        loggerFacade.logWarning('Warning-Title', 'Test Warning');
        loggerFacade.logError(new InvalidLogLevelException());
        loggerFacade.save();
        Test.getEventBus().deliver();
        Test.stopTest();
    }

    @isTest static void testFacadeWithEmptyLogs() {
        ContainerInterface container = Container.getDi();
        LoggerFacade loggerFacade = (LoggerFacade)container.get(LoggerFacade.class);
        Test.startTest();
        loggerFacade.handleEvent(new List<LogEntryData>());
        Test.stopTest();
    }

    @isTest static void testUnsupportedLogType() {
        ContainerInterface container = Container.getDi();
        LoggerFacade loggerFacade = (LoggerFacade)container.get(LoggerFacade.class);
        Test.startTest();
        LogEntryData logEntryData = new LogEntryData();
        logEntryData.logLevel = 'UNSUPPORTED_TYPE';
        try {
            loggerFacade.handleEvent(new List<LogEntryData> {
                logEntryData
            });
            System.assert(false, 'InvalidLogLevelException was not throw!');
        } catch (InvalidLogLevelException ex) {
            System.assert(true, '');
        }
        
        Test.stopTest();
    }

    private class RestMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {

            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'text/json');
            res.setBody('true');
            res.setStatusCode(200);
            return res;
        }
    }
}
