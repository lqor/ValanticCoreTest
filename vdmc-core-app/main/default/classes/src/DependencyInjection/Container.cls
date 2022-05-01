public class Container implements ContainerInterface{
    
    private static Container instance;
    private static final Map<Type, Facade> facades = new Map<Type, Facade>();
    
    /**
     * @param type Type of the requested service
     * @return service Returns the requested service
     */
    public Facade get(Type type) {
        Logger.error('TEST ERROR FROM CLASS');
        Logger.saveLog();
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

    public static ContainerInterface getDi() {
        if(instance == null){
            instance = new Container();
        }
        
        return instance;
    }
}
