@IsTest
public class CustomMDTTriggerHandler_Test {


    @IsTest
    static void testTriggerMDTFrameworkInstanceError() {
        CustomMDTTriggerHandler handler = new CustomMDTTriggerHandler();

        handler.isTriggerExecuting = true;

        Test.startTest();
        handler.run();
        Test.stopTest();
    }
}