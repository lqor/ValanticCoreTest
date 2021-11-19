public class ErrorPayloadBuilder implements PayloadBuilder {

    public SentryEvent.BaseData buildPayLoad(LogEntryData logEntryData) {
        SentryEvent.ExceptionEvent event = new SentryEvent.ExceptionEvent();
        SentryEvent.ExceptionData eventData = new SentryEvent.ExceptionData();
        SentryEvent.ExceptionValueData exceptionValueData = new SentryEvent.ExceptionValueData();
        SentryEvent.StackTraceData stackTraceData = new SentryEvent.StackTraceData();

        eventData.values = new List<SentryEvent.ExceptionValueData>();
        exceptionValueData.type = logEntryData.title;
        exceptionValueData.module = 'NOT SET';
        exceptionValueData.value = logEntryData.exceptionMessage;
        
        stackTraceData.frames = new List<SentryEvent.FrameData>();

        List<String> lines = logEntryData.exceptionStacktrace.split('\n');

        for (Integer i = lines.size() - 1; i >= 0; i--) {
            String line = lines[i];
            Pattern p = Pattern.compile('Class\\.([^\\.]+)\\.([^:]+): line ([0-9]+), column ([0-9]+)');
            Matcher m = p.matcher(line);
            // Sample: Class.SampleClass.execute: line 36, column 1
            if (m.find()) 
            {
                System.debug('@@m:--'+m);
                SentryEvent.FrameData frameData = new SentryEvent.FrameData();
                frameData.res_class = m.group(1);
                frameData.filename = m.group(1) + '.cls';
                frameData.function = m.group(1) + '.' + m.group(2) + ', line ' + m.group(3);
                frameData.lineno = Integer.valueOf(m.group(3));
                frameData.column =Integer.valueOf(m.group(4));
                frameData.in_app = true;
                frameData.vars = new Map<String, Object> {
                    'column' => frameData.column,
                    'line' => frameData.lineno,
                    'class'=> frameData.res_class,
                    'function' => frameData.function
                };
                stackTraceData.frames.add(frameData);
            } else if(line.contains('AnonymousBlock')) {
                System.debug('Got AnonymousBlock: '+ line);
                p = Pattern.compile('AnonymousBlock: line ([0-9]+), column ([0-9]+)');
                m = p.matcher(line);
                // Sample: Class.SampleClass1: line 595, column 1
                if (m.find()) 
                {
                    System.debug('@@m:--'+m);
                    SentryEvent.FrameData frameData = new SentryEvent.FrameData();
                    frameData.res_class = 'Anonymous Console';
                    frameData.filename = '';
                    frameData.function = 'AnonymousBlock' + ', line ' + m.group(1);
                    frameData.lineno = Integer.valueOf(m.group(1));
                    frameData.column =Integer.valueOf(m.group(2));
                    frameData.in_app = true;
                    frameData.vars = new Map<String, Object> {
                        'column' => frameData.column,
                        'line' => frameData.lineno,
                        'class'=> frameData.res_class,
                        'function' => frameData.function
                    };
                    stackTraceData.frames.add(frameData);
                }
            } else {
                p = Pattern.compile('Class\\.([^\\.]+): line ([0-9]+), column ([0-9]+)');
                m = p.matcher(line);
                // Sample: Class.SampleClass1: line 595, column 1
                if (m.find()) 
                {
                    System.debug('@@m:--'+m);
                    

                    SentryEvent.FrameData frameData = new SentryEvent.FrameData();
                    frameData.res_class = m.group(1);
                    frameData.filename = m.group(1) + '.cls';
                    frameData.function = m.group(1) + ', line ' + m.group(2);
                    frameData.lineno = Integer.valueOf(m.group(2));
                    frameData.column =Integer.valueOf(m.group(3));
                    frameData.in_app = true;
                    frameData.vars = new Map<String, Object> {
                        'column' => frameData.column,
                        'line' => frameData.lineno,
                        'class'=> frameData.res_class,
                        'function' => frameData.function
                    };
                    stackTraceData.frames.add(frameData);
                }
            }
        }
        System.debug('GOT ' + stackTraceData.frames.size() + ' lines of Stacktrace NXS');
        System.debug(stackTraceData.frames);

        exceptionValueData.stacktrace = stackTraceData;
        eventData.values.add(exceptionValueData);
        event.res_exception = eventData;

        //exceptionDataStack.put('frames', frames);
        //event.stac
        //exceptionData.put('stacktrace', exceptionDataStack);

        // add "value" in exceptionData
        //exceptionData.put('value', ex.getTypeName()+' '+ex.getMessage());
        //exceptionData.put('cause', ex.getCause());
        //exceptionData.put('line_number', ex.getLineNumber());

        return event;
    }
}