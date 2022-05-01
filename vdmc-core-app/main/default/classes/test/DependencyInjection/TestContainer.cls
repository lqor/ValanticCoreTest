public @isTest class TestContainer {
    

    @isTest static void testGetFacade() {
        ContainerInterface container = Container.getDi();
        TestFacadeA testFacade = (TestFacadeA) container.get(TestFacadeA.class);

        System.assertEquals(11, testFacade.incrementCounter());

        testFacade = (TestFacadeA) container.get(TestFacadeA.class);

        System.assertEquals(12, testFacade.incrementCounter());
    }

    @isTest static  void testErrorGetFacade() {
        ContainerInterface container = Container.getDi();
        try {
            container.get(NotAFacade.class);
            System.assert(false, 'Missing FacadeInvalidClassException exception!');
        }catch(FacadeInvalidClassException e){
            System.assert(true, 'Got FacadeInvalidClassException exception!' + e.getMessage());
        }

        try {
            container.get(TestFacadeError.class);
            System.assert(false, 'Missing init error handling');
        }catch(FacadeInitializeException e){
            System.assert(true, 'Got FacadeInitializeException exception!' + e.getMessage());
        }
    }


    public class TestFacadeA extends Facade {
        private TestFacadeB facadeB;

        public override void init() {
            this.facadeB = (TestFacadeB) this.getContainer().get(TestFacadeB.class);
        }

        public Integer incrementCounter() {
            return this.facadeB.incrementCounter();
        }
    }

    public class TestFacadeB extends Facade {
        private Integer counter = 5;

        public override void init() {
            this.counter = 10;
        }

        public Integer incrementCounter() {
            return ++this.counter;
        }
    }

    public class TestFacadeError extends Facade {
        

        public override void init() {
            throw new CalloutException('Test');
        }
    }

    class NotAFacade {

    }
}
