global class Container implements ContainerInterface{
    
    private static Container instance;
    private static final Map<Type, Facade> facades = new Map<Type, Facade>();
    
    /**
     * @param type Type of the requested service
     * @return service Returns the requested service
     */
    global Facade get(Type type) {
        
        if(!facades.containsKey(type)){
            Facade facade;
            try{
                facade = (Facade)type.newInstance();
            }catch(Exception e){
                throw new FacadeInvalidClassException(type, e);
            }

            try {
                facade.setContainer(this);
                facade.init();

                facades.put(type, facade);
                
                return facade;
            } catch (Exception e) {
                throw new FacadeInitializeException(type, e);
            }
        }

        return facades.get(type);
    }

    global static ContainerInterface getDi() {
        if(instance == null){
            instance = new Container();
        }
        
        return instance;
    }
}
