global interface ContainerInterface {
 
    /**
     * @param type Type of the requested service
     * @return service Returns the requested service
     */
    Facade get(Type type);

}