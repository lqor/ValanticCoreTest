global abstract class Facade {
    

    private ContainerInterface container;
    

    /**
     * Gets called after init of facade
     */
    abstract global void init();

    /**
     * @return container Returns the Container Dependency Injection
     */
    public ContainerInterface getContainer() {
        return this.container;
    }

    public void setContainer(ContainerInterface container) {
        this.container = container;
    }
}
