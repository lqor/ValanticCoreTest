global @isTest class TestContainer {
    

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


    global class TestFacadeA extends Facade {
        private TestFacadeB facadeB;

        global override void init() {
            this.facadeB = (TestFacadeB) this.getContainer().get(TestFacadeB.class);
        }

        global Integer incrementCounter() {
            return this.facadeB.incrementCounter();
        }
    }

    global class TestFacadeB extends Facade {
        private Integer counter = 5;

        global override void init() {
            this.counter = 10;
        }

        global Integer incrementCounter() {
            return ++this.counter;
        }
    }

    global class TestFacadeError extends Facade {
        

        global override void init() {
            throw new CalloutException('Test');
        }
    }

    class NotAFacade {

    }
}
