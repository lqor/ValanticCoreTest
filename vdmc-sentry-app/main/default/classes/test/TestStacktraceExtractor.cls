@isTest
private class TestStacktraceExtractor {
    

    @isTest static void testClassFunctionExtractor() {
        StacktraceExtractor.ClassFunctionExtractor extractor = new StacktraceExtractor.ClassFunctionExtractor();
        String testLine = 'Class.SampleClass.execute: line 36, column 3';
        String noExtractTestLine = 'AnonymousBlock: line 595, column 1';

        SentryEventData.FrameData result = extractor.extract(testLine);
        SentryEventData.FrameData result2 = extractor.extract(noExtractTestLine);

        System.assertEquals(3, result.column);
        System.assertEquals('SampleClass.cls', result.filename);
        System.assertEquals('SampleClass.execute, line 36', result.function);
        System.assertEquals(36, result.lineno);
        System.assertEquals('SampleClass', result.res_class);
        System.assert(result.in_app);

        System.assertEquals(null, result2);
    }

    @isTest static void testClassExtractor() {
        StacktraceExtractor.ClassExtractor extractor = new StacktraceExtractor.ClassExtractor();
        String testLine = 'Class.SampleClass1: line 595, column 3';
        String noExtractTestLine = 'AnonymousBlock: line 595, column 1';

        SentryEventData.FrameData result = extractor.extract(testLine);
        SentryEventData.FrameData result2 = extractor.extract(noExtractTestLine);

        System.assertEquals(3, result.column);
        System.assertEquals('SampleClass1.cls', result.filename);
        System.assertEquals('SampleClass1, line 595', result.function);
        System.assertEquals(595, result.lineno);
        System.assertEquals('SampleClass1', result.res_class);
        System.assert(result.in_app);

        System.assertEquals(null, result2);
    }

    @isTest static void testAnonymousBlockExtractor() {
        StacktraceExtractor.AnonymousBlockExtractor extractor = new StacktraceExtractor.AnonymousBlockExtractor();
        String testLine = 'AnonymousBlock: line 595, column 1';
        String noExtractTestLine1 = 'Class.SampleClass.execute: line 36, column 3';
        String noExtractTestLine2 = 'Class.SampleClass1: line 595, column 3';
        
        SentryEventData.FrameData result = extractor.extract(testLine);
        SentryEventData.FrameData result2 = extractor.extract(noExtractTestLine1);
        SentryEventData.FrameData result3 = extractor.extract(noExtractTestLine2);

        System.assertEquals(1, result.column);
        System.assertEquals('AnonymousBlock', result.filename);
        System.assertEquals('AnonymousBlock, line 595', result.function);
        System.assertEquals(595, result.lineno);
        System.assertEquals('Anonymous Console', result.res_class);
        System.assert(result.in_app == false);

        System.assertEquals(null, result2);
        System.assertEquals(null, result3);
    }
}
