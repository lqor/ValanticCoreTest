public abstract class StacktraceExtractor {

    public abstract SentryEventData.FrameData extract(String line);



    public class ClassFunctionExtractor extends StacktraceExtractor {

        /**
        * Extract Frame data from log line: "Class.SampleClass.execute: line 36, column 1"
        */
        public override SentryEventData.FrameData extract(String line) {
            Pattern p = Pattern.compile('Class\\.([^\\.]+)\\.([^:]+): line ([0-9]+), column ([0-9]+)');
            Matcher m = p.matcher(line);
            SentryEventData.FrameData frameData = null;

            if (m.find()) {
                frameData = new SentryEventData.FrameData();
                frameData.res_class = m.group(1);
                frameData.filename = m.group(1) + '.cls';
                frameData.function = m.group(1) + '.' + m.group(2) + ', line ' + m.group(3);
                frameData.lineno = Integer.valueOf(m.group(3));
                frameData.column = Integer.valueOf(m.group(4));
                frameData.in_app = true;
                frameData.vars = new Map<String, Object> {
                    'column' => frameData.column,
                    'line' => frameData.lineno,
                    'class'=> frameData.res_class,
                    'function' => frameData.function
                };
            }
            
            return frameData;
        }
    }

    public class ClassExtractor extends StacktraceExtractor {

        /**
         * Extract Frame data from log line: "Class.SampleClass1: line 595, column 1"
         */
        public override SentryEventData.FrameData extract(String line) {
            Pattern p = Pattern.compile('Class\\.([^\\.]+): line ([0-9]+), column ([0-9]+)');
            Matcher m = p.matcher(line);
            SentryEventData.FrameData frameData = null;

            if (m.find()) {
                frameData = new SentryEventData.FrameData();
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
            }

            return frameData;
        }
    }

    public class AnonymousBlockExtractor extends StacktraceExtractor {


        /**
        * Extract Frame data from log line: "AnonymousBlock: line 595, column 1"
        */
        public override SentryEventData.FrameData extract(String line) {
            Pattern p = Pattern.compile('AnonymousBlock: line ([0-9]+), column ([0-9]+)');
            Matcher m = p.matcher(line);
            SentryEventData.FrameData frameData = null;
            
            if (m.find()) 
            {
                frameData = new SentryEventData.FrameData();
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
                
                return frameData;
            }

            return frameData;
        }
    }
}
