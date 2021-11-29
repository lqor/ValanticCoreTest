global @isTest class TestErrorPayloadBuilder {
    

    @isTest static void testBuildAnonymousException() {
        
        ErrorPayloadBuilder errorPayloadBuilder = new ErrorPayloadBuilder();
        LogEntryData logEntryData = new LogEntryData();

        logEntryData.exceptionMessage =  'Test-Error-Message';
        logEntryData.exceptionStacktrace = 'AnonymousBlock: line 24, column 1\nAnonymousBlock: line 20, column 1\nAnonymousBlock: line 7, column 1\nAnonymousBlock: line 7, column 1';
        
        Test.startTest();
        SentryEvent.ExceptionEvent event = (SentryEvent.ExceptionEvent) errorPayloadBuilder.buildPayLoad(logEntryData);
        Test.stopTest();
        System.assert(event.res_exception.values.size() != 0, 'No Exception found');
        System.assert(event.res_exception.values[0] != null, 'No Exception found');
        
        for(SentryEvent.ExceptionValueData data :event.res_exception.values){
            System.assert(data.stacktrace.frames.size() != 0, 'No frames found');
            for(SentryEvent.FrameData frameData:data.stacktrace.frames) {
                System.assert(frameData.function.length() != 0, 'Function is missing');
            }
        }
    }

    @isTest static void testBuildException() {
        
        ErrorPayloadBuilder errorPayloadBuilder = new ErrorPayloadBuilder();
        LogEntryData logEntryData = new LogEntryData();

        logEntryData.exceptionMessage =  'Test-Error-Message';
        logEntryData.exceptionStacktrace = 'Class.SampleClass.execute: line 36, column 1\nClass.SampleClass.test: line 72, column 1\nClass.SampleClass.compare: line 69, column 1';
        
        Test.startTest();
        SentryEvent.ExceptionEvent event = (SentryEvent.ExceptionEvent) errorPayloadBuilder.buildPayLoad(logEntryData);
        Test.stopTest();
        System.assert(event.res_exception.values.size() != 0, 'No Exception found');
        System.assert(event.res_exception.values[0] != null, 'No Exception found');
        
        for(SentryEvent.ExceptionValueData data :event.res_exception.values){
            System.assert(data.stacktrace.frames.size() != 0, 'No frames found');
            for(SentryEvent.FrameData frameData:data.stacktrace.frames) {
                System.assert(frameData.function.length() != 0, 'Function is missing');
            }
        }
    }

    @isTest static void testBuildWithoutFunctionException() {
        
        ErrorPayloadBuilder errorPayloadBuilder = new ErrorPayloadBuilder();
        LogEntryData logEntryData = new LogEntryData();

        logEntryData.exceptionMessage =  'Test-Error-Message';
        logEntryData.exceptionStacktrace = 'Class.SampleClass: line 36, column 1\nClass.SampleClass: line 72, column 1\nClass.SampleClass: line 69, column 1';
        
        Test.startTest();
        SentryEvent.ExceptionEvent event = (SentryEvent.ExceptionEvent) errorPayloadBuilder.buildPayLoad(logEntryData);
        Test.stopTest();
        System.assert(event.res_exception.values.size() != 0, 'No Exception found');
        System.assert(event.res_exception.values[0] != null, 'No Exception found');
        
        for(SentryEvent.ExceptionValueData data :event.res_exception.values){
            System.assert(data.stacktrace.frames.size() != 0, 'No frames found');
            for(SentryEvent.FrameData frameData:data.stacktrace.frames) {
                System.assert(frameData.function.length() != 0, 'Function is missing');
            }
        }
    }

}
