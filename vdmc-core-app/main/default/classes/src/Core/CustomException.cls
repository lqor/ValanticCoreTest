global abstract class CustomException extends Exception{
    
    private String stackTrackString = createStackTraceString();

    private String createStackTraceString() {
        stackTrackString = new DmlException().getStackTraceString();
        // The first thee lines are this method, the Exception constructor, and the subclass. So, discard them
        return stackTrackString.replaceFirst('(?m)(.*\\n){3}?', '');
    }

    public override String getStackTraceString() {
        return stackTrackString;
    }
}