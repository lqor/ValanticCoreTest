public abstract class Facade {
    

    private ContainerInterface container;

    public Facade(){}
    

    /**
     * Gets called after init of facade
     */
    abstract public void init();

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
