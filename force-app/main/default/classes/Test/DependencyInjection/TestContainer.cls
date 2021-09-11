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
            System.assert(false, 'Missing FacadeNotExists exception!');
        }catch(FacadeNotExistsException e){
            System.assert(true, 'Got FacadeNotExists exception!' + e.getMessage());
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

    class NotAFacade {

    }
}
