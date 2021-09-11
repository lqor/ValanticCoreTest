global @isTest class TestContainer {
    

    @isTest static void testGetFacade() {
        TestFacade testFacade = (TestFacade) Container.getDi().get(TestFacade.class);

        System.assertEquals(11, testFacade.incrementCounter());

        testFacade = (TestFacade) Container.getDi().get(TestFacade.class);

        System.assertEquals(12, testFacade.incrementCounter());
    }

    @isTest static  void testErrorGetFacade() {
        try {
            Container.getDi().get(NotAFacade.class);
        }catch(FacadeNotExistsException e){
            System.assert(true, 'Got FacadeNotExists exception!' + e.getMessage());
        }
    }


    global class TestFacade extends Facade {
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
